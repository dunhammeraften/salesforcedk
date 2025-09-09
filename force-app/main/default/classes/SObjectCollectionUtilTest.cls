@isTest
private class SObjectCollectionUtilTest {
	static Id firstUserId = '005RR00000CaWSTYA3';
	static Id secondUserId = '005RR00000CbWSTYA3';

	static List<Account> testAccounts() {
		return new List<Account>{
			new Account(Id = '0011U00000TFV6MQAX', OwnerId = firstUserId, Name = 'Foo', AnnualRevenue = 100),
			new Account(Id = '0011U00000TFV7MQAX', OwnerId = firstUserId, Name = 'Bar', AnnualRevenue = 60),
			new Account(Id = '0011U00000TFV8MQAX', OwnerId = secondUserId, Name = 'Foo', AnnualRevenue = 150),
			new Account(Id = '0011U00000TFV9MQAX', OwnerId = secondUserId, Name = 'Bar', AnnualRevenue = 150)
		};
	}

	@IsTest
	private static void of_givenListOfAccount_returnsCollection() {
		//Arrange
		List<Account> accounts = new List<Account>{ new Account(Name = 'Foo'), new Account(Name = 'Bar') };

		//ACT
		SObjectCollectionUtil collection = SObjectCollectionUtil.of(accounts);

		//ASSERT
		Assert.isNotNull(collection, 'The collection has been initiated.');
		Assert.areEqual(((Account) collection.asList().get(0)).Name, 'Foo', 'The name of the first account is foo');
	}

	@IsTest
	private static void pluckId_givenListWithAccountRelation_returnsAccountIds() {
		//ARRANGE
		Account fooAccount = new Account(Id = '0011U00000TFV7MQAX');
		Account barAccount = new Account(Id = '0011U00000TFV8MQAX');
		List<Opportunity> opportunities = new List<Opportunity>{
			new Opportunity(Name = 'Foo', Account = fooAccount),
			new Opportunity(Name = 'Bar', Account = barAccount)
		};

		SObjectCollectionUtil c = SObjectCollectionUtil.of(opportunities);

		//ACT
		List<Id> accountIds = c.pluckIds('Account.Id');

		//ASSERT
		Assert.areEqual(2, accountIds.size(), 'Should have the size of 2');
		Assert.areEqual(fooAccount.Id, accountIds[0], 'Should be fooAccount Id');
		Assert.areEqual(barAccount.Id, accountIds[1], 'Should be barAccount Id');
	}

	@IsTest
	private static void size_withList_returnsNumberOfRecords() {
		SObjectCollectionUtil c = SObjectCollectionUtil.of(
			new List<Account>{ new Account(Name = 'Foo'), new Account(Name = 'Bar') }
		);
		Assert.areEqual(2, c.size(), 'Size should be 2');

		c = SObjectCollectionUtil.of(new List<Account>());
		Assert.areEqual(0, c.size(), 'Size should be 0');
	}

	@IsTest
	private static void groupByDates_returnsDateMap() {
		Date today = Date.today();
		SObjectCollectionUtil c = SObjectCollectionUtil.of(
			new List<Opportunity>{
				new Opportunity(CloseDate = today, Name = 'Today'),
				new Opportunity(CloseDate = today, Name = 'Today'),
				new Opportunity(CloseDate = today.addDays(1), Name = 'Tomorrow')
			}
		);
		Map<Date, List<Opportunity>> oppsByDate = c.groupByDates(Opportunity.CloseDate);

		Assert.areEqual(2, oppsByDate.size());

		List<Opportunity> todaysOpps = oppsByDate.get(today);
		Assert.areEqual(2, todaysOpps.size());
		for (Opportunity o : todaysOpps) {
			Assert.areEqual('Today', o.Name);
		}

		List<Opportunity> tomorrowsOpps = oppsByDate.get(today.addDays(1));
		Assert.areEqual(1, tomorrowsOpps.size());
		for (Opportunity o : tomorrowsOpps) {
			Assert.areEqual('Tomorrow', o.Name);
		}
	}

	@IsTest
	private static void groupByDatetimes() {
		Datetime now = Datetime.now();
		SObjectCollectionUtil c = SObjectCollectionUtil.of(
			new List<Event>{
				new Event(ActivityDateTime = now),
				new Event(ActivityDateTime = now),
				new Event(ActivityDateTime = now.addHours(1))
			}
		);
		Map<Datetime, List<Event>> eventsByDatetimes = c.groupByDatetimes(Event.ActivityDateTime);
		Assert.areEqual(2, eventsByDatetimes.size());

		List<Event> nowEvents = eventsByDatetimes.get(now);
		Assert.areEqual(2, nowEvents.size());

		for (Event e : nowEvents) {
			Assert.areEqual(now, e.ActivityDateTime);
		}

		List<Event> nextHourEvents = eventsByDatetimes.get(now.addHours(1));
		Assert.areEqual(1, nextHourEvents.size());
		for (Event e : nextHourEvents) {
			Assert.areEqual(now.addHours(1), e.ActivityDateTime);
		}
	}

	@IsTest
	private static void testAsMap() {
		Map<Id, SObject> recordMap = SObjectCollectionUtil.of(testAccounts()).asMap();
		Assert.areEqual(4, recordMap.size());
	}

	@IsTest
	private static void testPluckDecimalsWithRelation() {
		List<Decimal> revenues = SObjectCollectionUtil.of(testAccounts()).pluckDecimals('AnnualRevenue');
		Assert.areEqual(4, revenues.size());
		Assert.areEqual(100.0, revenues[0]);
		Assert.areEqual(60.0, revenues[1]);
		Assert.areEqual(150.0, revenues[2]);
		Assert.areEqual(150.0, revenues[3]);
	}

	@IsTest
	private static void testPluckStrings() {
		List<String> names = SObjectCollectionUtil.of(testAccounts()).pluckStrings(Account.Name);
		Assert.areEqual(4, names.size());
		Assert.areEqual('Foo', names[0]);
		Assert.areEqual('Bar', names[1]);
		Assert.areEqual('Foo', names[2]);
		Assert.areEqual('Bar', names[3]);
	}

	@IsTest
	private static void testPluckStringsWithRelation() {
		List<String> names = SObjectCollectionUtil.of(testAccounts()).pluckStrings('Name');
		Assert.areEqual(4, names.size());
		Assert.areEqual('Foo', names[0]);
		Assert.areEqual('Bar', names[1]);
		Assert.areEqual('Foo', names[2]);
		Assert.areEqual('Bar', names[3]);
	}

	@IsTest
	private static void testPluckIdsAsStrings() {
		List<String> ownerIds = SObjectCollectionUtil.of(testAccounts()).pluckStrings(Account.OwnerId);
		Assert.areEqual(4, ownerIds.size());
		Assert.areEqual(firstUserId, ownerIds[0]);
		Assert.areEqual(firstUserId, ownerIds[1]);
		Assert.areEqual(secondUserId, ownerIds[2]);
		Assert.areEqual(secondUserId, ownerIds[3]);
	}

	@IsTest
	private static void testPluckIds() {
		List<Id> ownerIds = SObjectCollectionUtil.of(testAccounts()).pluckIds(Account.OwnerId);
		// workaround for List.contains bug
		Set<Id> idSet = new Set<Id>(ownerIds);
		Assert.areEqual(2, idSet.size());
		Assert.isTrue(idSet.contains(firstUserId));
		Assert.isTrue(idSet.contains(secondUserId));
	}

	@IsTest
	private static void testPluckRecordIds() {
		List<Account> accounts = testAccounts();
		List<Id> recordIds = SObjectCollectionUtil.of(accounts).pluckIds();
		Assert.areEqual(4, recordIds.size());
		// workaround for List.contains bug
		Set<Id> idSet = new Set<Id>(recordIds);
		Assert.isTrue(idSet.contains(accounts[0].Id));
		Assert.isTrue(idSet.contains(accounts[1].Id));
		Assert.isTrue(idSet.contains(accounts[2].Id));
		Assert.isTrue(idSet.contains(accounts[3].Id));
	}

	@IsTest
	private static void testPluckBooleans() {
		List<User> users = new List<User>{
			new User(Title = 'Foo', IsActive = true),
			new User(Title = 'Bar', IsActive = true),
			new User(Title = 'Baz', IsActive = false)
		};
		List<Boolean> active = SObjectCollectionUtil.of(users).pluckBooleans(User.IsActive);
		Assert.areEqual(3, active.size());
		Assert.isTrue(active[0]);
		Assert.isTrue(active[1]);
		Assert.isFalse(active[2]);
	}

	@IsTest
	private static void testPluckBooleansWithRelation() {
		List<User> users = new List<User>{
			new User(Title = 'Foo', IsActive = true),
			new User(Title = 'Bar', IsActive = true),
			new User(Title = 'Baz', IsActive = false)
		};
		List<Boolean> active = SObjectCollectionUtil.of(users).pluckBooleans('IsActive');
		Assert.areEqual(3, active.size());
		Assert.isTrue(active[0]);
		Assert.isTrue(active[1]);
		Assert.isFalse(active[2]);
	}

	@IsTest
	private static void testPluckDates() {
		Date today = Date.today();
		List<Opportunity> opps = new List<Opportunity>{
			new Opportunity(CloseDate = today),
			new Opportunity(CloseDate = today.addDays(1)),
			new Opportunity(CloseDate = today.addDays(2))
		};
		List<Date> closeDates = SObjectCollectionUtil.of(opps).pluckDates(Opportunity.CloseDate);
		Assert.areEqual(3, closeDates.size());
		Assert.areEqual(today, closeDates[0]);
		Assert.areEqual(today.addDays(1), closeDates[1]);
		Assert.areEqual(today.addDays(2), closeDates[2]);
	}

	@IsTest
	private static void testPluckDatesWithRelation() {
		Date today = Date.today();
		List<Opportunity> opps = new List<Opportunity>{
			new Opportunity(CloseDate = today),
			new Opportunity(CloseDate = today.addDays(1)),
			new Opportunity(CloseDate = today.addDays(2))
		};
		List<Date> closeDates = SObjectCollectionUtil.of(opps).pluckDates('CloseDate');
		Assert.areEqual(3, closeDates.size());
		Assert.areEqual(today, closeDates[0]);
		Assert.areEqual(today.addDays(1), closeDates[1]);
		Assert.areEqual(today.addDays(2), closeDates[2]);
	}

	@IsTest
	private static void testPluckDatetimes() {
		Datetime now = Datetime.now();
		List<Event> events = new List<Event>{
			new Event(ActivityDateTime = now),
			new Event(ActivityDateTime = now.addHours(1))
		};
		List<Datetime> completedDatetimes = SObjectCollectionUtil.of(events).pluckDatetimes(Event.ActivityDateTime);
		Assert.areEqual(2, completedDatetimes.size());
		Assert.areEqual(now, completedDatetimes[0]);
		Assert.areEqual(now.addHours(1), completedDatetimes[1]);
	}

	@IsTest
	private static void testPluckDatetimesWithRelation() {
		Datetime now = Datetime.now();
		List<Event> events = new List<Event>{
			new Event(ActivityDateTime = now),
			new Event(ActivityDateTime = now.addHours(1))
		};
		List<Datetime> completedDatetimes = SObjectCollectionUtil.of(events).pluckDatetimes('ActivityDateTime');
		Assert.areEqual(2, completedDatetimes.size());
		Assert.areEqual(now, completedDatetimes[0]);
		Assert.areEqual(now.addHours(1), completedDatetimes[1]);
	}

	@IsTest
	private static void testGroupByStrings() {
		SObjectCollectionUtil c = SObjectCollectionUtil.of(testAccounts());
		Map<String, List<Account>> accountsByName = c.groupByStrings(Account.Name);
		Assert.areEqual(2, accountsByName.size());
		Assert.isTrue(accountsByName.keySet().contains('Foo'));
		Assert.isTrue(accountsByName.keySet().contains('Bar'));
		Assert.areEqual(2, accountsByName.get('Foo').size());
		Assert.areEqual(2, accountsByName.get('Bar').size());
		for (Account a : accountsByName.get('Foo')) {
			Assert.areEqual('Foo', a.Name);
		}
		for (Account a : accountsByName.get('Bar')) {
			Assert.areEqual('Bar', a.Name);
		}
	}

	@IsTest
	private static void testGroupByStringsApiFieldName() {
		SObjectCollectionUtil c = SObjectCollectionUtil.of(testAccounts());
		Map<String, List<Account>> accountsByName = c.groupByStrings('Name');
		Assert.areEqual(2, accountsByName.size());
		Assert.isTrue(accountsByName.keySet().contains('Foo'));
		Assert.isTrue(accountsByName.keySet().contains('Bar'));
		Assert.areEqual(2, accountsByName.get('Foo').size());
		Assert.areEqual(2, accountsByName.get('Bar').size());
		for (Account a : accountsByName.get('Foo')) {
			Assert.areEqual('Foo', a.Name);
		}
		for (Account a : accountsByName.get('Bar')) {
			Assert.areEqual('Bar', a.Name);
		}
	}

	@IsTest
	private static void testGroupByDecimals() {
		SObjectCollectionUtil c = SObjectCollectionUtil.of(testAccounts());
		Map<Decimal, List<Account>> accountsByRevenue = c.groupByDecimals(Account.AnnualRevenue);
		Assert.areEqual(3, accountsByRevenue.size());
		Assert.isTrue(accountsByRevenue.keySet().contains(60));
		Assert.isTrue(accountsByRevenue.keySet().contains(100));
		Assert.isTrue(accountsByRevenue.keySet().contains(150));
		Assert.areEqual(1, accountsByRevenue.get(60).size());
		Assert.areEqual(1, accountsByRevenue.get(100).size());
		Assert.areEqual(2, accountsByRevenue.get(150).size());
		for (Account a : accountsByRevenue.get(150)) {
			Assert.areEqual(150.0, a.AnnualRevenue);
		}
	}

	@IsTest
	private static void testGroupByDecimalsApiFieldName() {
		SObjectCollectionUtil c = SObjectCollectionUtil.of(testAccounts());
		Map<Decimal, List<Account>> accountsByRevenue = c.groupByDecimals('AnnualRevenue');
		Assert.areEqual(3, accountsByRevenue.size());
		Assert.isTrue(accountsByRevenue.keySet().contains(60));
		Assert.isTrue(accountsByRevenue.keySet().contains(100));
		Assert.isTrue(accountsByRevenue.keySet().contains(150));
		Assert.areEqual(1, accountsByRevenue.get(60).size());
		Assert.areEqual(1, accountsByRevenue.get(100).size());
		Assert.areEqual(2, accountsByRevenue.get(150).size());
		for (Account a : accountsByRevenue.get(150)) {
			Assert.areEqual(150.0, a.AnnualRevenue);
		}
	}

	@IsTest
	private static void testGroupByIds() {
		SObjectCollectionUtil c = SObjectCollectionUtil.of(testAccounts());
		Map<Id, List<Account>> accountsByOwners = c.groupByIds(Account.OwnerId);
		Assert.areEqual(2, accountsByOwners.size());
		Assert.isTrue(accountsByOwners.keySet().contains(firstUserId));
		Assert.isTrue(accountsByOwners.keySet().contains(secondUserId));
		Assert.areEqual(2, accountsByOwners.get(firstUserId).size());
		Assert.areEqual(2, accountsByOwners.get(secondUserId).size());
		for (Account a : accountsByOwners.get(firstUserId)) {
			Assert.areEqual(firstUserId, a.OwnerId);
		}
	}

	@IsTest
	private static void testGroupByIdsApiFieldName() {
		SObjectCollectionUtil c = SObjectCollectionUtil.of(testAccounts());
		Map<Id, List<Account>> accountsByOwners = c.groupByIds('OwnerId');
		Assert.areEqual(2, accountsByOwners.size());
		Assert.isTrue(accountsByOwners.keySet().contains(firstUserId));
		Assert.isTrue(accountsByOwners.keySet().contains(secondUserId));
		Assert.areEqual(2, accountsByOwners.get(firstUserId).size());
		Assert.areEqual(2, accountsByOwners.get(secondUserId).size());
		for (Account a : accountsByOwners.get(firstUserId)) {
			Assert.areEqual(firstUserId, a.OwnerId);
		}
	}

	@IsTest
	private static void testGroupByBooleans() {
		SObjectCollectionUtil c = SObjectCollectionUtil.of(
			new List<User>{
				new User(Title = 'Foo', IsActive = true),
				new User(Title = 'Bar', IsActive = true),
				new User(Title = 'Baz', IsActive = false)
			}
		);
		Map<Boolean, List<User>> usersByActive = c.groupByBooleans(User.IsActive);
		Assert.areEqual(2, usersByActive.size());
		Assert.isTrue(usersByActive.keySet().contains(true));
		Assert.isTrue(usersByActive.keySet().contains(false));
		Assert.areEqual(2, usersByActive.get(true).size());
		Assert.areEqual(1, usersByActive.get(false).size());
		for (User u : usersByActive.get(true)) {
			Assert.isTrue(u.IsActive);
		}
	}

	@IsTest
	private static void testGroupByBooleansApiFieldName() {
		SObjectCollectionUtil c = SObjectCollectionUtil.of(
			new List<User>{
				new User(Title = 'Foo', IsActive = true),
				new User(Title = 'Bar', IsActive = true),
				new User(Title = 'Baz', IsActive = false)
			}
		);
		Map<Boolean, List<User>> usersByActive = c.groupByBooleans('IsActive');
		Assert.areEqual(2, usersByActive.size());
		Assert.isTrue(usersByActive.keySet().contains(true));
		Assert.isTrue(usersByActive.keySet().contains(false));
		Assert.areEqual(2, usersByActive.get(true).size());
		Assert.areEqual(1, usersByActive.get(false).size());
		for (User u : usersByActive.get(true)) {
			Assert.isTrue(u.IsActive);
		}
	}

	@IsTest
	private static void pickShouldPickFields() {
		SObjectCollectionUtil c = SObjectCollectionUtil.of(
			new List<Account>{
				new Account(Name = 'Test1', AnnualRevenue = 100),
				new Account(Name = 'Test2', AnnualRevenue = 200)
			}
		);
		verifyNamePick(c.pick(new List<Schema.SObjectField>{ Account.Name }));
		verifyNamePick(c.pick(new Set<Schema.SObjectField>{ Account.Name }));
		verifyNamePick(c.pick(new List<String>{ 'Name' }));
		verifyNamePick(c.pick(new Set<String>{ 'Name' }));
	}

	@IsTest
	private static void pickedFieldsShouldHaveValues() {
		SObjectCollectionUtil c = SObjectCollectionUtil.of(
			new List<Opportunity>{ new Opportunity(Name = 'Test', Amount = 100, Description = 'Test description') }
		);
		List<Opportunity> picked = c.pick(new List<String>{ 'Name', 'Amount' }).asList();
		Assert.areEqual(1, picked.size());
		for (Opportunity opp : picked) {
			Assert.areEqual('Test', opp.Name);
			Assert.areEqual(100, opp.Amount);
		}
	}

	@IsTest
	private static void pickShouldPickHeterogenousRecords() {
		SObjectCollectionUtil c = SObjectCollectionUtil.of(
			new List<SObject>{
				new Account(Name = 'Test1', AnnualRevenue = 100),
				new Opportunity(Name = 'Test1', Description = 'Test description')
			}
		);
		verifyNamePick(c.pick(new List<String>{ 'Name' }));
		verifyNamePick(c.pick(new Set<String>{ 'Name' }));
	}

	@IsTest
	private static void pickShouldHaveMatchingObjectTypes() {
		SObjectCollectionUtil c = SObjectCollectionUtil.of(
			new List<SObject>{
				new Account(Name = 'Test1', AnnualRevenue = 100),
				new Opportunity(Name = 'Test1', Description = 'Test description')
			}
		);
		List<SObject> picked = c.pick(new List<String>{ 'Name' }).asList();
		Assert.areEqual(Account.SObjectType, picked[0].getSObjectType(), 'First picked element should be an Account.');
		Assert.areEqual(
			Opportunity.SObjectType,
			picked[1].getSObjectType(),
			'Second picked element should be an Opportunity.'
		);
	}

	private static void verifyNamePick(SObjectCollectionUtil picked) {
		for (SObject obj : picked.asList()) {
			Map<String, Object> fields = obj.getPopulatedFieldsAsMap();
			Assert.areEqual(1, fields.size());
			Assert.isTrue(fields.containsKey('Name'));
		}
	}
}