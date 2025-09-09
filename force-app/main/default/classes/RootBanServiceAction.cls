/**
 *
 * @author Mujahid
 * @since 25/01/2023
 * @description RootBanServiceAction uses the values from the Home Office Billing Account flow and will create a Root Ban in Fokus
 * @see [Root Ban Integration](https://itwiki.atlassian.teliacompany.net/display/SFDK/Home+Office+Root+Ban+Integration)
 *
 *
 * @author  Mujahid
 * @since 22/06/2023
 * Update -  Discount code is partially implemented here. The PC team has trouble configuring the products, so the correct discount code cannot be retrieved. When it's ready, the DiscountSelector class should be updated
 */
public with sharing class RootBanServiceAction {
	private static APISettings__mdt api;
	private static final String ADDITIONAL_INFO = 'RootBanServiceAction';
	private static final String ORIGIN = 'Apex';
	private static final String DEFAULT_SEGMENT = 'B2B';
	private static final String TYPE_ORGANIZATION = 'ORGANIZATION';
	private static final String TYPE_DISCOUNT_ITEM = 'DISCOUNT_ITEM';
	private static final String TYPE_ACCOUNT_ITEM = 'ACCOUNT_ITEM';
	private static final String TYPE_ACCOUNT = 'ACCOUNT';
	private static final String ACTIVITY_CREATE = 'CREATE';
	private static final String DEFAULT_COUNTRY_CODE = '45';
	private static final String INVOICE_TYPE_PDF_EMAIL = 'PDF_BY_EMAIL';
	private static final String BILLING_CYCLE_MONTHLY = 'MONTHLY';
	private static final String UP_TRANSFER_CHARGE_CODE = 'THOD22';
	private static final String HOME_OFFICE_SUBSCRIPTION_FAMILY = 'Home Office (NEW) Subscription';
	private static final String BAN_TYPE_HOME_OFFICE = 'Home Office';

	private static final List<String> DOOR_DIRECTIONS = new List<String>{ 'tv', 'th', 'mf' };

	@InvocableMethod(label='Create Root Ban' description='Create Root Ban Record in Fokus')
	public static List<RootBanServiceAction.RootBanResult> createRootBan(List<Request> request) {
		List<RootBanServiceAction.RootBanResult> rootBanResults = new List<RootBanServiceAction.RootBanResult>();
		try {
			api = MetadataSelector.getAPISettings('OrderAPIHomeOfficeSettings');
			String body = createRequestBody(request);
			String endpoint = api.API_PartialEndPoint__c + '/orders';
			String token = AuthorizationWrapper.getAPIToken(api);

			Map<String, String> headers = new Map<String, String>{ 'Authorization' => 'Bearer ' + token, 'Content-Type' => 'application/json' };
			Logger.logDebug('body = ' + body);
			HttpResponse resp = HttpWrapper.post(endpoint, body, headers);
			Logger.logDebug('resp = ' + resp);
			RootBanResDAO result = (RootBanResDAO) JSON.deserialize(resp.getBody(), RootBanResDAO.class);
			Logger.logDebug('result = ' + result);
			Logger.logDebug('restul data = ' + result.data);
			RootBanServiceAction.RootBanResult rootBanResult = new RootBanServiceAction.RootBanResult();
			rootBanResult.hasErrors = result.data.hasValidationErrors;

			if (result.data.hasValidationErrors) {
				Logger.logDebug('result.data.hasValidationErrors = ' + result.data.hasValidationErrors);
				saveErrors(result.data);
				rootBanResult.errors = Label.Create_BAN_Error_Message;
				rootBanResult.billingAccountNumber = null;
			} else {
				String banNumber = result.data.orderParts.get(0).orderItems.get(0).billingAccountNumber;
				rootBanResult.billingAccountNumber = Decimal.valueOf(banNumber);
			}

			rootBanResults.add(rootBanResult);
			return rootBanResults;
		} catch (Exception ex) {
			Logger.logError('RootbanServiceAction', ex);
			System_Log__c exceptionLog = new System_Log__c(Origin__c = ORIGIN, Error_Body__c = ex.getMessage(), Additional_Information__c = ADDITIONAL_INFO);
			insert exceptionLog;
			return new List<RootBanServiceAction.RootBanResult>{ createErrorResult() };
		} finally {
			Logger.emit();
		}
	}

	private static RootBanServiceAction.RootBanResult createErrorResult() {
		RootBanServiceAction.RootBanResult errorResult = new RootBanServiceAction.RootBanResult();
		errorResult.billingAccountNumber = null;
		errorResult.errors = Label.Create_BAN_Error_Message;
		errorResult.hasErrors = true;
		return errorResult;
	}

	private static void saveErrors(RootBanResDAO.Data data) {
		String serverErrors = '';
		if (data.validationErrors != null) {
			serverErrors += getErrors(data.validationErrors) + '\n';
		}
		if (data.orderParts.get(0).validationErrors != null) {
			serverErrors += getErrors(data.orderParts.get(0).validationErrors) + '\n';
		}
		if (data.orderParts.get(0).orderItems.get(0).validationErrors != null) {
			serverErrors += getErrors(data.orderParts.get(0).orderItems.get(0).validationErrors) + '\n';
		}
		System_Log__c errorLog = new System_Log__c(Origin__c = ORIGIN, Error_Body__c = serverErrors, Additional_Information__c = ADDITIONAL_INFO);

		insert errorLog;
	}

	private static String getErrors(List<RootBanResDAO.ValidationErrors> validationErrors) {
		String rootBanErrors = '';
		for (RootBanResDAO.ValidationErrors error : validationErrors) {
			for (RootBanResDAO.Parameters err : error.parameters) {
				rootBanErrors += error.errorCode + ' : ' + err.reason + '\n';
			}
		}
		return rootBanErrors;
	}

	@TestVisible
	private static String createRequestBody(List<Request> request) {
		Request input = request.get(0);
		Account inputAcc = input.inputAccount;
		Opportunity inputOpp = input.inputOppoty;
		RootBanReqDAO req = new RootBanReqDAO();
		req.brand = api.brand__c;
		req.segment = DEFAULT_SEGMENT;
		req.channel = api.channel__c;

		//TODO : Dealer information must be removed when the Order API made it not required
		RootBanReqDAO.Dealer dealer = new RootBanReqDAO.Dealer();
		dealer.dealerCode = api.dealerCode__c;
		req.dealer = dealer;	

		// Flags
		RootBanReqDAO.Flags flags = new RootBanReqDAO.Flags();
		flags.homeOfficeOrder = (input.BanType != BAN_TYPE_HOME_OFFICE) ? false : true;
		req.flags = flags;

		// Orderer
		RootBanReqDAO.Orderer orderer = new RootBanReqDAO.Orderer();
		orderer.type = TYPE_ORGANIZATION;
		orderer.name = input.companyName.left(60);
		orderer.cvr = inputAcc.CVR__c;
		orderer.address = getBanAddress(input);

		RootBanReqDAO.TelephoneNumber tPhone = new RootBanReqDAO.TelephoneNumber();
		tPhone.countryCode = DEFAULT_COUNTRY_CODE;
		tPhone.localNumber = inputAcc.Phone;
		orderer.telephoneNumber = tPhone;
		req.orderer = orderer;

		RootBanReqDAO.OrderItems orderItem = new RootBanReqDAO.OrderItems();
		orderItem.type = TYPE_ACCOUNT_ITEM;
		orderItem.activity = ACTIVITY_CREATE;
		orderItem.billingCycle = BILLING_CYCLE_MONTHLY;
		orderItem.upTransferChargeCode = UP_TRANSFER_CHARGE_CODE;
		orderItem.invoiceType = INVOICE_TYPE_PDF_EMAIL;
		orderItem.productGroup = (input.BanType != BAN_TYPE_HOME_OFFICE) ? 'BusinessInternet' : 'HomeOffice';

		Logger.logDebug('Productgroup set to ' + orderItem.productGroup);
		if(orderItem.productGroup == 'BusinessInternet' || orderItem.productGroup == 'HomeOffice'){
			orderItem.category = 'VIP_TML_ROOT';
			Logger.logDebug('category set to ' + orderItem.category);
		}

		// legalParty
		RootBanReqDAO.Orderer legalParty = new RootBanReqDAO.Orderer();
		legalParty.type = TYPE_ORGANIZATION;
		legalParty.name = inputAcc.Name.left(60);
		legalParty.cvr = inputAcc.CVR__c;
		legalParty.address = getLegalAddress(inputAcc, input.billingAtt);

		RootBanReqDAO.TelephoneNumber legalPhone = new RootBanReqDAO.TelephoneNumber();
		legalPhone.countryCode = DEFAULT_COUNTRY_CODE;
		legalPhone.localNumber = inputAcc.Phone;
		legalParty.telephoneNumber = legalPhone;
		orderItem.legalParty = legalParty;

		// billingParty
		RootBanReqDAO.BillingParty billingParty = new RootBanReqDAO.BillingParty();
		billingParty.type = TYPE_ORGANIZATION;
		billingParty.name = inputAcc.Name.left(60);
		billingParty.cvr = inputAcc.CVR__c;
		billingParty.address = getLegalAddress(inputAcc, input.billingAtt);

		RootBanReqDAO.TelephoneNumberCCode billingPartyCCode = new RootBanReqDAO.TelephoneNumberCCode();
		billingPartyCCode.countryCode = DEFAULT_COUNTRY_CODE;
		billingParty.telephoneNumber = billingPartyCCode;
		orderItem.billingParty = billingParty;

		RootBanReqDAO.OrderItems orderItemDiscount = new RootBanReqDAO.OrderItems();
		orderItemDiscount.type = TYPE_DISCOUNT_ITEM;
		orderItemDiscount.activity = ACTIVITY_CREATE;
		// orderItemDiscount.discountCode = getDiscountCode(inputOpp);
		orderItemDiscount.discountCode = 'HOF001';

		// OrderParts
		RootBanReqDAO.OrderParts orderPart = new RootBanReqDAO.OrderParts();
		orderPart.type = TYPE_ACCOUNT;
		orderPart.activity = ACTIVITY_CREATE;
		List<RootBanReqDAO.OrderParts> orderParts = new List<RootBanReqDAO.OrderParts>();
		List<RootBanReqDAO.OrderItems> orderItems = new List<RootBanReqDAO.OrderItems>();
		orderItems.add(orderItem);

		if (input.BanType == BAN_TYPE_HOME_OFFICE) { // TEMPORARY AS WE DONT KNOW HOW THE DISCOUNT WILL WORK WITH BI
			orderItems.add(orderItemDiscount);
		}
		
		orderPart.orderItems = orderItems;
		orderParts.add(orderPart);
		req.orderParts = orderParts;

		return JSON.serialize(req, true);
	}

	@TestVisible
	private static RootBanReqDAO.Address getBanAddress(Request input) {
		System.debug('BAN Address Input = ' + input);
		RootBanReqDAO.Address address = new RootBanReqDAO.Address();
		address.attention = input.billingAtt;
		address.zipCode = input.postalCode;
		address.streetName = input.streetName;
		address.streetNumber = input.streetNumber;
		address.city = input.city;
		address.country = input.country;
		System.debug('ban address = ' + address);
		return address;
	}

	@TestVisible
	private static RootBanReqDAO.Address getLegalAddress(Account input, String attention) {
		System.debug('Account input = ' + input);
		RootBanReqDAO.Address address = new RootBanReqDAO.Address();
		address.attention = attention;
		address.zipCode = input.BillingPostalCode;
		address.streetName = input.Billing_Street_Name__c;
		address.streetNumber = input.Billing_Street_Number__c;
		address.streetNumberSuffix = input.Billing_Street_Number_Suffix__c;
		address.floorNumber = input.Billing_Floor_Number__c;
		address.city = input.BillingCity;
		address.country = input.BillingCountry;
		mapBillingDoor(address, input.Billing_Door_Number__c);
		System.debug('legal address = ' + address);
		return address;
	}

	/**
	 * 
	 * @param address The root account address
	 * @param billingDoorNumber Billing_Door_Number__c field in the account record
	 * @description This method added, to determine if the Billing_Door_Number__c field value is a direction of the door or actual door number as we're using the same column to store both values in SF
	 */
	@TestVisible
	private static void mapBillingDoor(RootBanReqDAO.Address address, String billingDoorNumber) {
		if (DOOR_DIRECTIONS.contains(billingDoorNumber)) {
			address.direction = billingDoorNumber;
		} else {
			address.doorNumber = billingDoorNumber;
		}
	}

	/**
	 * All the variable starting with input are the values of the related Account and the User.
	 * Others are newly created Business Account values
	 */
	public class Request {
		@InvocableVariable
		public Account inputAccount;
		@InvocableVariable
		public Opportunity inputOppoty;
		@InvocableVariable
		public String companyName;
		@InvocableVariable
		public String billingAtt;
		@InvocableVariable
		public String email;
		@InvocableVariable
		public String streetName;
		@InvocableVariable
		public String streetNumber;
		@InvocableVariable
		public String postalCode;
		@InvocableVariable
		public String city;
		@InvocableVariable
		public String country;
		@InvocableVariable
		public String BanType;
	}

	public class RootBanResult {
		@InvocableVariable
		public Decimal billingAccountNumber;
		@InvocableVariable
		public Boolean hasErrors;
		@InvocableVariable
		public String errors;
	}

	@TestVisible
	class RootBanServiceActionException extends Exception {
	}
}