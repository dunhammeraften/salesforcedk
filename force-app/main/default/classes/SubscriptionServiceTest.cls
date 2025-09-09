@IsTest(IsParallel = true)
public with sharing class SubscriptionServiceTest {

    //USED TO BE ABLE TO SERIALIZE TO A CHILDREN__R
    private class ChildrenList {
        integer totalSize;
        Boolean done = true;
        List<Sobject> records;
    }

    @IsTest
    static void cstor_SubscriptionService_shouldInitiateDatabaseServiceAndSelector(){
        //Arrange

        //Act
        SubscriptionService s = new SubscriptionService();

        //Assert
        Assert.isNotNull(s.dataBaseService, 'databaseservice should be set');
        Assert.isNotNull(s.subscriptionSelector, 'subscriptionSelector should be set');
    }

    @IsTest
    static void updateSubscriptionQuantity_withEmptySet_shouldNotThrowException(){
        //Arrange

        //Act
        SubscriptionService s = new SubscriptionService();
        s.updateSubscriptionQuantity(new Set<Id>());

        //Assert
        Assert.isTrue(true, 'We get to this point');
    }

    @IsTest
    static void updateSubscriptionQuantity_withSubscriptionLineDetails_aggregateQuantity(){
        //Arrange
        DatabaseService myDatabaseService = new DatabaseService().mockDmls();
        
        Mock subscriptionSelectorMock = Mock.forType(SubscriptionSelector.class);
        MethodSpy getSubscriptionByIdSpy = subscriptionSelectorMock.spyOn('getSubscriptionById');

        List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();

        SBQQ__Subscription__c subscriptionOne = new SBQQ__Subscription__c();
        subscriptionOne.Id = DatabaseService.getFakeId(SBQQ__Subscription__c.getSObjectType());

        List<Subscription_Line_Detail__c> details = new List<Subscription_Line_Detail__c>();
        Subscription_Line_Detail__c subscriptionOneDetailsOne = new Subscription_Line_Detail__c();
        subscriptionOneDetailsOne.Id = DatabaseService.getFakeId(Subscription_Line_Detail__c.getSObjectType());
        subscriptionOneDetailsOne.Quantity__c = 1;
        details.add(subscriptionOneDetailsOne);

        Subscription_Line_Detail__c subscriptionOneDetailsTwo = new Subscription_Line_Detail__c();
        subscriptionOneDetailsTwo.Id = DatabaseService.getFakeId(Subscription_Line_Detail__c.getSObjectType());
        subscriptionOneDetailsTwo.Quantity__c = 15;
        details.add(subscriptionOneDetailsTwo);

        //This is stupid cannot set it explicitly
        //subscriptionOne.Subscription_Line_Details__r = details;
        String jsonString = JSON.serialize(subscriptionOne);
        Map<String,Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);

        //Adding the children listed.
        ChildrenList subscriptionLineDetails = new ChildrenList();
        subscriptionLineDetails.totalSize = 2;
        subscriptionLineDetails.records = details;
        dataMap.put('Subscription_Line_Details__r', subscriptionLineDetails);
        jsonString = JSON.serialize(dataMap);
        
        subscriptionOne = (SBQQ__Subscription__c)JSON.deserialize(jsonString, SBQQ__Subscription__c.class);
	subs.add(subscriptionOne);
        
        getSubscriptionByIdSpy.whenCalledWith(Argument.any()).thenReturn(subs);

        //Act
        SubscriptionService s = new SubscriptionService(myDatabaseService, (SubscriptionSelector) subscriptionSelectorMock.stub);

        s.updateSubscriptionQuantity(new set<Id>{subscriptionOne.Id});

        //Assert
        Assert.areEqual(16,((SBQQ__Subscription__c) myDatabaseService.register.updated[0]).SBQQ__Quantity__c,'We have a total quantity of 16');
    }
}