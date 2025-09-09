/**
 *
 * @author Mujahid
 * @since 06/03/2023
 * @description OrderAPIAction send the activation lines to create orders to Order API.
 * The relevant information will be fetched from Home Office Activation Lines (Activation_line_home_office) sub flow
 * @see [Home Office Order API](https://itwiki.atlassian.teliacompany.net/display/SFDK/Home+Office+Order+API)
 *
 *
 * Update 1: Set the Fokus Campaign optional. If it's empty, it will not be in the request body.
 * Update 2: Reset the selected activation lines, if the server responded with 400 or 504. Implemented in resetActivationLines() method
 * Update 3: activeBlockingLinePresent, plugPresentTechnicianRequired flags are added to the request body
 * Update 4: order api request now contain the activation line as channelOrderPartId and the response has splitOrderId, which is the order id for a given activation line. So the activaiton line will be updated based on the channelOrderPartId
 */
public with sharing class OrderAPIAction {
	private static APISettings__mdt api;
	private static Map<Id, Location_Line__c> locationsByIds;
	private static Map<String, Fokus_Campaign__c> campaignsByProductIds;
	private static List<System_Log__c> errorsList = new List<System_Log__c>();

	private static Activation__c activation;
	private static String caseNumber;
	private static String orderType; // HO, BI, VTPX
	private static final String TYPE_BILLING_ACCOUNT_NUMBER = 'BILLING_ACCOUNT_NUMBER';
	private static final String TYPE_ACCOUNT = 'ACCOUNT';
	private static final String TYPE_ACCOUNT_ITEM = 'ACCOUNT_ITEM';
	private static final String TYPE_ADDITIONAL_PRODUCT_ITEM = 'ADDITIONAL_PRODUCT_ITEM';
	private static final String TYPE_FEE_ITEM = 'FEE_ITEM';
	private static final String TYPE_SUBSCRIPTION_ITEM = 'SUBSCRIPTION_ITEM';
	private static final String TYPE_SUBSCRIPTION = 'SUBSCRIPTION';
	private static final String TYPE_PERSON = 'PERSON';
	private static final String ACTIVITY_CREATE = 'CREATE';
	private static final String ACTIVITY_CHANGE = 'CHANGE';
	private static final String COUNTRY_CODE = '45';
	private static final String DEFAULT_COUNTRY = 'DNK';
	private static final String DEFAULT_VAS_CATEGORY = 'VAS';
	private static final String DEFAULT_SEGMENT = 'B2B';
	private static final String DISPLAY_NAME_FIBER_INSTALLATION_FEE = 'Tekniker';
	private static final String FEE_ID_FIBER_INSTALLATION_FEE = 'FIBERINSTFEE';
	private static final String FEE_TYPE_INSTALLATION = 'INSTALLATION_FEE';
	private static final String PROCESSING_STATUS_RECEIVED = 'RECEIVED';
	private static final String PROCESSING_STATUS_SUBMITTED = 'SUBMITTED';
	private static final String STATUS_PENDING = 'Pending fulfilment';
	private static final String STATUS_FAILED = 'Fulfilment failed';
	private static final String ERROR_ORIGIN = 'Apex';
	private static final String ERROR_ADDITIONAL_INFO = 'OrderAPIAction';
	private static final String ERROR_FIELDS = ' Fields that affected this error: ';
	private static final String PRODUCT_SPEED_UNIT = 'Mbit/s';
	private static final String PRODUCT_NAME_SPLIT_BY = ' ';
	private static final String EMPTY_VALUE = '';
	private static final String ERROR_LINE_TXT = 'Error on line : ';
	private static final String ERROR_MSG_TXT = '. Error message:  ';
	private static final String AUTHORIZATION_TXT = 'Authorization';
	private static final String CONTENT_TYPE_TXT = 'Content-Type';
	private static final String CONTENT_TYPE_VALUE = 'application/json';
	private static final String BEARER_TXT = 'Bearer ';
	private static final String ENDPOINT_BASE = '/accounts/';
	private static final String ENDPOINT_PATH = '/orders';

	@InvocableMethod(label='Create Home Office Order' description='Create New Home Office Order in Fokus')
	public static List<Result> createOrder(List<Request> requests) {
		System.debug('createOrder called');
		try {
			api = MetadataSelector.getAPISettings('OrderAPIHomeOfficeSettings');
			String token = AuthorizationWrapper.getAPIToken(api);

			Map<String, String> headers = new Map<String, String>{ AUTHORIZATION_TXT => BEARER_TXT + token, CONTENT_TYPE_TXT => CONTENT_TYPE_VALUE };
			List<Activation_line__c> activationLines = requests.get(0).activationLines;
			Map<String, String> requestBodiesByBAN = createRequestBodiesByBAN(activationLines);
			System.debug(LoggingLevel.INFO, 'requestBodiesByBAN = ' + requestBodiesByBAN);
			List<OrderResDAO> responses = new List<OrderResDAO>();

			for (String ban : requestBodiesByBAN.keySet()) {
				String endpoint = api.API_PartialEndPoint__c + ENDPOINT_BASE + ban + ENDPOINT_PATH;
				System.debug('req.body = ' + requestBodiesByBAN.get(ban));
				HttpResponse resp = HttpWrapper.post(endpoint, requestBodiesByBAN.get(ban), headers);
				System.debug('resp.getBody() = ' + resp.getBody());
				System.debug('resp.getStatusCode() = ' + resp.getStatusCode());
				if (resp.getStatusCode() == 201) {
					OrderResDAO result = (OrderResDAO) JSON.deserialize(resp.getBody(), OrderResDAO.class);
					if (result.data != null) {
						if (result.data.hasValidationErrors) {
							errorsList.add(saveErrors(result.data));
						} else {
							responses.add(result);
						}
					}
				} else if (resp.getStatusCode() == 200) {
					OrderResDAO result = (OrderResDAO) JSON.deserialize(resp.getBody(), OrderResDAO.class);
					if (result.data != null) {
						errorsList.add(saveErrors(result.data));
					} else {
						errorsList.add(createErrorLog(Label.API_Exception_Flow_Message));
					}
				} else if (resp.getStatusCode() == 400 || resp.getStatusCode() == 504) {
					ErrorResult errorResult = (ErrorResult) JSON.deserialize(resp.getBody(), ErrorResult.class);
					String errorMsg = errorResult.error.code + ' : ' + errorResult.error.message;
					errorsList.add(createErrorLog(errorMsg));
				} else {
					errorsList.add(createErrorLog(Label.API_Exception_Flow_Message));
				}
			}
			System.debug('errorList.size : ' + errorsList.size());
			if (errorsList.size() > 0) {
				return createErrorResult(requests.get(0).activationLines);
			} else {
				updateResults(createResultsToUpdate(responses, requests));
			}
			return null;
		} catch (Exception ex) {
			String errorMsg = ERROR_LINE_TXT + ex.getLineNumber() + ERROR_MSG_TXT + ex.getMessage();
			errorsList.add(createErrorLog(errorMsg));
			return createErrorResult(requests.get(0).activationLines);
		} finally {
			insert errorsList;
		}
	}

	@TestVisible
	private static System_Log__c createErrorLog(String errorMsg) {
		System_Log__c errorLog = new System_Log__c(Origin__c = ERROR_ORIGIN, Error_Body__c = errorMsg, Additional_Information__c = ERROR_ADDITIONAL_INFO);
		return errorLog;
	}

	@TestVisible
	private static List<Result> createErrorResult(List<Activation_line__c> activationLines) {
		Result errorResult = new Result();
		errorResult.hasError = true;
		errorResult.errorMessage = Label.API_Exception_Flow_Message;
		return new List<Result>{ errorResult };
	}

	@TestVisible
	private static System_Log__c saveErrors(OrderResDAO.Data data) {
		String errors = EMPTY_VALUE;
		if (data.validationErrors != null) {
			errors += getErrors(data.validationErrors) + '\n';
		}
		if (data.orderParts.get(0).validationErrors != null) {
			errors += getErrors(data.orderParts.get(0).validationErrors) + '\n';
		}
		if (data.orderParts.get(0).orderParts.get(0).orderItems.get(0).validationErrors != null) {
			errors += getErrors(data.orderParts.get(0).orderParts.get(0).orderItems.get(0).validationErrors) + '\n';
		}
		if (data.orderParts.get(0).orderParts.get(0).orderParts.get(0).orderItems.get(0).validationErrors != null) {
			errors += getErrors(data.orderParts.get(0).orderParts.get(0).orderParts.get(0).orderItems.get(0).validationErrors) + '\n';
		}
		return createErrorLog(errors);
	}

	@TestVisible
	private static String getErrors(List<OrderResDAO.ValidationErrors> validationErrors) {
		String orderErrors = EMPTY_VALUE;
		for (OrderResDAO.ValidationErrors error : validationErrors) {
			for (OrderResDAO.Parameters err : error.parameters) {
				orderErrors += error.errorCode + ' : ' + err.reason + '\n';
			}
		}
		return orderErrors;
	}

	@TestVisible
	private static List<Result> createResult(List<Activation_line__c> activationLines) {
		Result result = new Result();
		result.errorMessage = null;
		result.hasError = false;
		List<Result> results = new List<Result>();
		results.add(result);
		return results;
	}

	@TestVisible
	private static void updateResults(List<Activation_line__c> activationLines) {
		System.debug('updateResults called');
		Database.SaveResult[] srList = Database.update(activationLines, false);
		for (Database.SaveResult sr : srList) {
			if (!sr.isSuccess()) {
				System.debug('sr = ' + sr);
				for (Database.Error err : sr.getErrors()) {
					System.debug('err = ' + err);
					String errorMsg = err.getStatusCode() + ': ' + err.getMessage() + ', ' + ERROR_FIELDS + err.getFields();
					errorsList.add(createErrorLog(errorMsg));
				}
			}
		}
	}

	@TestVisible
	private static List<Activation_line__c> createResultsToUpdate(List<OrderResDAO> responses, List<Request> requests) {
		Map<string, OrderResDAO.OrderPartsAccount> successAccountsByActivationId = new Map<String, OrderResDAO.OrderPartsAccount>();
		Map<string, OrderResDAO.OrderPartsAccount> failAccountsByActivationId = new Map<String, OrderResDAO.OrderPartsAccount>();
		List<Activation_line__c> activationLinesReqs = requests.get(0).activationLines;
		List<Activation_line__c> activationLinesResp = new List<Activation_line__c>();
		for (OrderResDAO res : responses) {
			List<OrderResDAO.OrderPartsAccount> accountOrderParts = res.data.orderParts.get(0).orderParts;
			for (OrderResDAO.OrderPartsAccount account : accountOrderParts) {
				String activationId = account.channelOrderPartId;
				if (account.processingStatus == PROCESSING_STATUS_RECEIVED && account.splitOrderId != null) {
					successAccountsByActivationId.put(activationId, account);
				} else {
					failAccountsByActivationId.put(activationId, account);
				}
			}
		}

		for (Activation_line__c actLine : activationLinesReqs) {
			if (successAccountsByActivationId.get(actLine.Id) != null) {
				OrderResDAO.OrderPartsAccount account = successAccountsByActivationId.get(actLine.Id);
				System.debug('success account :' + account);
				System.debug('success actLine before :' + actLine);
				System.debug('success orderId :' + account.splitOrderId);
				actLine.Home_Office_Activation_Accepted__c = true;
				actLine.Home_Office_Request_Activation__c = true;
				actLine.Status__c = STATUS_PENDING;
				actLine.Home_Office_Requested_Activation_Date__c = Date.today();
				actLine.Home_Office_Order_Id__c = account.splitOrderId;
				System.debug('success actLine after :' + actLine);
			}
			if (failAccountsByActivationId.get(actLine.Id) != null) {
				System.debug('fail actLine : ' + actLine);
				actLine.Home_Office_Activation_Accepted__c = false;
				actLine.Status__c = STATUS_FAILED;
				actLine.Home_Office_Request_Activation__c = false;
				actLine.Home_Office_Requested_Activation_Date__c = null;
				actLine.Home_Office_Order_Id__c = null;
			}
			activationLinesResp.add(actLine);
		}

		return activationLinesResp;
	}

	@TestVisible
	private static Map<String, String> createRequestBodiesByBAN(List<Activation_line__c> activationLines) {
		System.debug('activationLines = ' + activationLines);
		locationsByIds = getLocationLineByIds(activationLines);
		caseNumber = activationLines.get(0).Case__c; // getCaseId(activationLines);
		System.debug('caseNumber = ' + caseNumber);
		activation = ActivationSelector.getActivationById(activationLines.get(0).Activation__c);
		System.debug('activation = ' + activation);
		campaignsByProductIds = getCampaignsByProductId(locationsByIds.values());
		Map<String, List<Activation_line__c>> activationLinesByBans = getActivationLinesByBans(activationLines);
		List<OrderReqDAO.OrderParts> orderParts = new List<OrderReqDAO.OrderParts>();
		Map<String, List<OrderReqDAO.OrderParts>> rootOrdersByBan = createRootOrderParts(activationLinesByBans);
		Map<String, String> requestsByBan = new Map<String, String>();
		for (String ban : rootOrdersByBan.keySet()) {
			String requestBody = createRequestBody(rootOrdersByBan.get(ban));
			requestsByBan.put(ban, requestBody);
		}

		// cleanup the temporary objects
		activationLines = null;
		orderParts = null;

		return requestsByBan;
	}

	@TestVisible
	private static Map<String, Fokus_Campaign__c> getCampaignsByProductId(List<Location_Line__c> locations) {
		List<String> subscriptionProducts = new List<String>();
		for (Location_Line__c location : locations) {
			subscriptionProducts.add(location.Subscription_product__c);
		}
		return CampaignSelector.getCampaignsByProductIds(subscriptionProducts);
	}

	@TestVisible
	private static String getCaseId(List<Activation_line__c> activationLines) {
		return activationLines.get(0).Case__c;
	}

	@TestVisible
	private static Map<String, List<Activation_line__c>> getActivationLinesByBans(List<Activation_line__c> activationLines) {
		Map<String, List<Activation_line__c>> activationLinesByBans = new Map<String, List<Activation_line__c>>();
		for (Activation_line__c activationLine : activationLines) {
			if (activationLinesByBans.containsKey(activationLine.Billing_Account_Number__c)) {
				activationLinesByBans.get(activationLine.Billing_Account_Number__c).add(activationLine);
			} else {
				activationLinesByBans.put(activationLine.Billing_Account_Number__c, new List<Activation_line__c>{ activationLine });
			}
		}
		return activationLinesByBans;
	}

	@TestVisible
	private static String createRequestBody(List<OrderReqDAO.OrderParts> orderParts) {
		OrderReqDAO.Dealer dealer = createDealer();
		OrderReqDAO.Flags flags = createFlags();
		OrderReqDAO order = new OrderReqDAO();
		order.brand = api.brand__c;
		order.channel = api.channel__c;
		order.segment = DEFAULT_SEGMENT;
		order.dealer = dealer;
		order.flags = flags;
		order.implementationCaseId = caseNumber;
		order.orderParts = orderParts;
		return JSON.serialize(order, true);
	}

	@TestVisible
	private static Map<String, List<OrderReqDAO.OrderParts>> createRootOrderParts(Map<String, List<Activation_line__c>> actLinesByBans) {
		Map<String, List<OrderReqDAO.OrderParts>> orderPartsByBan = new Map<String, List<OrderReqDAO.OrderParts>>();
		for (String ban : actLinesByBans.keySet()) {
			List<OrderReqDAO.OrderParts> rootOrderParts = new List<OrderReqDAO.OrderParts>();
			rootOrderParts.add(createRootOrderPart());
			List<OrderReqDAO.References> references = createReferences(ban);
			List<OrderReqDAO.OrderParts> accountOrderParts = createAccountOrderParts(actLinesByBans.get(ban));
			rootOrderParts.get(0).references = references;
			rootOrderParts.get(0).orderParts = accountOrderParts;
			orderPartsByBan.put(ban, rootOrderParts);
		}
		return orderPartsByBan;
	}

	@TestVisible
	private static Map<Id, Location_Line__c> getLocationLineByIds(List<Activation_line__c> activationLines) {
		Map<Id, Location_Line__c> locationLinesByActivationLineIds = new Map<Id, Location_Line__c>();
		List<Id> locationIds = new List<Id>();
		for (Activation_line__c activationLine : activationLines) {
			locationIds.add(activationLine.Location_Line__c);
		}
		Map<Id, Location_Line__c> locations = LocationLineSelector.getLocationLinesByIds(locationIds);
		return locations;
	}

	@TestVisible
	private static OrderReqDAO.Dealer createDealer() {
		OrderReqDAO.Dealer dealer = new OrderReqDAO.Dealer();
		dealer.dealerCode = api.dealerCode__c;
		return dealer;
	}

	// The following flags are requested as it is. The important flag 'dirty' means that the current request does not have all the information to fullfill an order
	// and the order api will fetch them from different services
	@TestVisible
	private static OrderReqDAO.Flags createFlags() {
		OrderReqDAO.Flags flags = new OrderReqDAO.Flags();
		flags.needsConfirmation = false;
		flags.consentsAccepted = false;
		flags.termsAccepted = true;
		flags.dirty = true;
		return flags;
	}

	@TestVisible
	private static List<OrderReqDAO.OrderParts> createAccountOrderParts(List<Activation_line__c> activationLines) {
		List<OrderReqDAO.OrderParts> accountOrderParts = new List<OrderReqDAO.OrderParts>();
		try {
			for (Activation_line__c activationLine : activationLines) {
				List<OrderReqDAO.OrderParts> subscriptionOrderParts = createSubscriptions(activationLine);
				List<OrderReqDAO.OrderItems> accountOrderItems = createAccountOrderItems(activationLine);
				OrderReqDAO.OrderParts accountOrderPart = createAccountOrderPart(activationLine);
				accountOrderPart.orderItems = accountOrderItems;
				accountOrderPart.orderParts = subscriptionOrderParts;

				if (accountOrderPart != null) {
					accountOrderParts.add(accountOrderPart);
				}
			}
		} catch (Exception ex) {
			String errorMsg = ERROR_LINE_TXT + ex.getLineNumber() + ERROR_MSG_TXT + ex.getMessage();
			errorsList.add(createErrorLog(errorMsg));
		}
		return accountOrderParts.size() > 0 ? accountOrderParts : null;
	}

	@TestVisible
	private static List<OrderReqDAO.References> createReferences(String ban) {
		List<OrderReqDAO.References> references = new List<OrderReqDAO.References>();
		try {
			OrderReqDAO.References reference = createBillingAccountReference(ban);
			if (reference != null) {
				references.add(reference);
			}
		} catch (Exception ex) {
			String errorMsg = ERROR_LINE_TXT + ex.getLineNumber() + ERROR_MSG_TXT + ex.getMessage();
			errorsList.add(createErrorLog(errorMsg));
		}

		return references.size() > 0 ? references : null;
	}

	@TestVisible
	private static OrderReqDAO.References createBillingAccountReference(String ban) {
		OrderReqDAO.References reference = new OrderReqDAO.References();
		reference.type = TYPE_BILLING_ACCOUNT_NUMBER;
		reference.value = ban;
		return reference;
	}

	@TestVisible
	private static OrderReqDAO.OrderParts createRootOrderPart() {
		OrderReqDAO.OrderParts rootOrderPart = new OrderReqDAO.OrderParts();
		rootOrderPart.type = TYPE_ACCOUNT;
		rootOrderPart.activity = ACTIVITY_CHANGE;
		return rootOrderPart;
	}

	@TestVisible
	private static OrderReqDAO.OrderParts createAccountOrderPart(Activation_line__c activationLine) {
		OrderReqDAO.OrderParts accountOrderPart = new OrderReqDAO.OrderParts();
		accountOrderPart.type = TYPE_ACCOUNT;
		accountOrderPart.activity = ACTIVITY_CREATE;
		accountOrderPart.channelOrderPartId = activationLine.Id;
		return accountOrderPart;
	}

	@TestVisible
	private static List<OrderReqDAO.OrderItems> createAccountOrderItems(Activation_line__c activationLine) {
		List<OrderReqDAO.OrderItems> accountOrderItems = new List<OrderReqDAO.OrderItems>();
		try {
			OrderReqDAO.OrderItems orderItem = createAccountOrderItem(activationLine);
			if (orderItem != null) {
				accountOrderItems.add(orderItem);
			}
		} catch (Exception ex) {
			String errorMsg = ERROR_LINE_TXT + ex.getLineNumber() + ERROR_MSG_TXT + ex.getMessage();
			errorsList.add(createErrorLog(errorMsg));
		}

		return accountOrderItems.size() > 0 ? accountOrderItems : null;
	}

	@TestVisible
	private static List<OrderReqDAO.OrderParts> createSubscriptions(Activation_line__c activationLine) {
		List<OrderReqDAO.OrderParts> subscriptions = new List<OrderReqDAO.OrderParts>();
		try {
			OrderReqDAO.OrderParts subscription = new OrderReqDAO.OrderParts();
			List<OrderReqDAO.OrderItems> orderItems = createOrderItems(activationLine);
			subscription.activity = ACTIVITY_CREATE;
			subscription.type = TYPE_SUBSCRIPTION;
			subscription.orderItems = orderItems;
			if (subscription != null) {
				subscriptions.add(subscription);
			}
		} catch (Exception ex) {
			String errorMsg = ERROR_LINE_TXT + ex.getLineNumber() + ERROR_MSG_TXT + ex.getMessage();
			errorsList.add(createErrorLog(errorMsg));
		}

		return subscriptions.size() > 0 ? subscriptions : null;
	}

	@TestVisible
	private static List<OrderReqDAO.OrderItems> createOrderItems(Activation_line__c activationLine) {
		List<OrderReqDAO.OrderItems> orderItems = new List<OrderReqDAO.OrderItems>();
		try {
			OrderReqDAO.OrderItems subscriptionOrderItem = createSubscriptionOrderItem(activationLine);
			if (subscriptionOrderItem != null) {
				orderItems.add(subscriptionOrderItem);
			}
			if (activationLine.Home_Office_VAS_Product__c != null) {
				OrderReqDAO.OrderItems vasProductItem = createVasProductItem(activationLine);
				if (vasProductItem != null) {
					orderItems.add(vasProductItem);
				}
			}
			if (activationLine.Home_Office_OTC_Product__c != null) {
				OrderReqDAO.OrderItems otcProductItem = createOtcProductItem(activationLine);
				if (otcProductItem != null) {
					orderItems.add(otcProductItem);
				}
			}
		} catch (Exception ex) {
			String errorMsg = ERROR_LINE_TXT + ex.getLineNumber() + ERROR_MSG_TXT + ex.getMessage();
			errorsList.add(createErrorLog(errorMsg));
		}

		return orderItems.size() > 0 ? orderItems : null;
	}

	@TestVisible
	private static OrderReqDAO.OrderItems createVasProductItem(Activation_line__c activationLine) {
		OrderReqDAO.OrderItems vasProduct = new OrderReqDAO.OrderItems();
		vasProduct.productCode = activationLine.Home_Office_VAS_Product__c;
		vasProduct.activity = ACTIVITY_CREATE;
		vasProduct.type = TYPE_ADDITIONAL_PRODUCT_ITEM;
		vasProduct.productCategory = DEFAULT_VAS_CATEGORY;
		vasProduct.quantity = 1;
		return vasProduct;
	}

	@TestVisible
	private static OrderReqDAO.OrderItems createOtcProductItem(Activation_line__c activationLine) {
		OrderReqDAO.OrderItems otcProduct = new OrderReqDAO.OrderItems();
		otcProduct.billingCode = activationLine.Home_Office_OTC_Product__c;
		otcProduct.activity = ACTIVITY_CREATE;
		otcProduct.type = TYPE_FEE_ITEM;
		otcProduct.feeType = FEE_TYPE_INSTALLATION;
		otcProduct.feeId = FEE_ID_FIBER_INSTALLATION_FEE;
		otcProduct.displayName = DISPLAY_NAME_FIBER_INSTALLATION_FEE;
		otcProduct.recurring = false;
		return otcProduct;
	}

	@TestVisible
	private static OrderReqDAO.OrderItems createSubscriptionOrderItem(Activation_line__c activationLine) {
		OrderReqDAO.OrderItems subscriptionItem = new OrderReqDAO.OrderItems();
		OrderReqDAO.NewOffering newOffering = createNewOffering(activationLine);
		OrderReqDAO.FixedNetDetails fixedNetDetails = createFixedNetDetails(activationLine);
		subscriptionItem.type = TYPE_SUBSCRIPTION_ITEM;
		subscriptionItem.activity = ACTIVITY_CREATE;
		subscriptionItem.newOffering = newOffering;
		subscriptionItem.fixedNetDetails = fixedNetDetails;
		subscriptionItem.preferredActivationDate = activationLine.Home_Office_Requested_Activation_Date__c;
		subscriptionItem.productDeliveryAsap = activationLine.Express_Delivery__c;
		return subscriptionItem;
	}

	@TestVisible
	private static OrderReqDAO.FixedNetDetails createFixedNetDetails(Activation_line__c activationLine) {
		OrderReqDAO.FixedNetDetails fixedNetDetails = new OrderReqDAO.FixedNetDetails();
		Location_Line__c location = locationsByIds.get(activationLine.Location_Line__c);
		OrderReqDAO.InstallationAddress installationAddress = createInstalltionAddress(activationLine);
		fixedNetDetails.installationAddress = installationAddress;
		fixedNetDetails.fixedNetFlags = createFixedNetFlags(activationLine);
		fixedNetDetails.speedDown = getSpeedFromProductName(activationLine); // Need clarification
		fixedNetDetails.speedUp = getSpeedFromProductName(activationLine);
		fixedNetDetails.doItYourselfInstallation = activationLine.DIY_Installation__c;
		fixedNetDetails.vendor = (location != null) ? location.lineProvider__c : null; // maybe not needed for BI5G
		fixedNetDetails.vendorProductCatalogId = (location != null) ? location.VendorProductCatalogId__c : null; // maybe not needed for BI5G
		fixedNetDetails.vendorProductCode =  (location != null) ? location.VendorProductCode__c : null; // maybe not needed for BI5G
		fixedNetDetails.lineConnectionStatus = (location != null) ? location.lineConnectionStatus__c : null; // maybe not needed for BI5G
		return fixedNetDetails;
	}

	@TestVisible
	private static OrderReqDAO.FixedNetFlags createFixedNetFlags(Activation_line__c activationLine) {
		OrderReqDAO.FixedNetFlags fixedNetFlags = new OrderReqDAO.FixedNetFlags();
		fixedNetFlags.customerRequestsChangeProvider = false;
		fixedNetFlags.plugPresentPositiveValidation = activationLine.plugPresentPositiveValidation__c;
		fixedNetFlags.diggingNeeded = activationLine.Is_Digging_Needed__c;
		fixedNetFlags.activeBlockingLinePresent = activationLine.Active_Blocking_Line_Present__c;
		fixedNetFlags.plugTechnicianRequired = activationLine.Plug_Technician_Required__c;
		return fixedNetFlags;
	}

	@TestVisible
	private static OrderReqDAO.InstallationAddress createInstalltionAddress(Activation_line__c activationLine) {
		OrderReqDAO.InstallationAddress installationAddress = new OrderReqDAO.InstallationAddress();
		Location_Line__c location = locationsByIds.get(activationLine.Location_Line__c);
		OrderReqDAO.Address postalAddress = createAddress(activationLine);
		installationAddress.postalAddress = postalAddress;
		installationAddress.municipalityCode = String.valueOf(activationLine.Municipality_Code__c);
		installationAddress.streetCode = String.valueOf(activationLine.Street_Code__c);
		installationAddress.addressRefId = (location != null) ? location.AddressRefId__c : null;
		installationAddress.siteId = (location != null) ? location.SiteId__c : null;
		installationAddress.floorNumber = String.valueOf(activationLine.Floor__c);
		installationAddress.doorNumber = String.valueOf(activationLine.Door__c);
		return installationAddress;
	}

	@TestVisible
	private static OrderReqDAO.NewOffering createNewOffering(Activation_line__c activationLine) {
		OrderReqDAO.NewOffering newOffering = new OrderReqDAO.NewOffering();
		Location_Line__c location = locationsByIds.get(activationLine.Location_Line__c);
		newOffering.priceplan = (location != null && location.Subscription_product__c != null) ? location.Subscription_product__c : activationLine.Priceplan_Code__c;
		
		//// Commented out for now - as it is troublesome for Business Internet. ALSO, it does not seems to be used in PROD.
		//// As of 13/11/2024, the most recent Fokus_Campaign__c created in prod was from 17/08/2023 by Product API
		
		// Fokus_Campaign__c campaign = campaignsByProductIds.get(location.Subscription_product__c);
		// if (campaign != null) {
			// newOffering.campaign = campaign.Campaign_Id__c;
		// }
		return newOffering;
	}

	@TestVisible
	private static OrderReqDAO.OrderItems createAccountOrderItem(Activation_line__c activationLine) {
		OrderReqDAO.LegalParty legalParty = createLegalParty(activationLine);
		OrderReqDAO.OrderItems accountOrderItem = new OrderReqDAO.OrderItems();
		accountOrderItem.activity = ACTIVITY_CREATE;
		accountOrderItem.type = TYPE_ACCOUNT_ITEM;
		accountOrderItem.legalParty = legalParty;
		accountOrderItem.invoiceType = activationLine.Invoice_Type_F__c;
		accountOrderItem.billingCycle = activation.Billing_Frequency__c; // !!!!

		String homeOfficeActivationLineRecordTypeId = Schema.sObjectType.Activation_line__c.getRecordTypeInfosByDeveloperName().get('Home_office_activation_line').getRecordTypeId();
		String businessInternetActivationLineRecordTypeId = Schema.sObjectType.Activation_line__c.getRecordTypeInfosByDeveloperName().get('Business_Internet_activation_line').getRecordTypeId();
		
        Logger.logDebug(homeOfficeActivationLineRecordTypeId + '-' + businessInternetActivationLineRecordTypeId + '-' + activationLine.RecordTypeId);
        
		if(activationLine.RecordTypeId == homeOfficeActivationLineRecordTypeId){
			Logger.logDebug('productGroup set to HomeOffice');
			accountOrderItem.productGroup = 'HomeOffice';
			accountOrderItem.productCategory = 'EMPLOYEE_BROADBAND';
		}
		else if (activationLine.RecordTypeId == businessInternetActivationLineRecordTypeId){
			
			Logger.logDebug('productGroup set to BusinessInternet');
			accountOrderItem.productGroup = 'BusinessInternet';
			accountOrderItem.productCategory = 'EMPLOYEE_BROADBAND';
		}
		
		Logger.emit();
		
		return accountOrderItem;
	}

	@TestVisible
	private static OrderReqDAO.TelephoneNumber createPhoneNumber(Activation_line__c activationLine) {
		OrderReqDAO.TelephoneNumber telephoneNumber = new OrderReqDAO.TelephoneNumber();
		telephoneNumber.countryCode = COUNTRY_CODE;
		telephoneNumber.localNumber = activationLine.Mobile_no__c;
		return telephoneNumber;
	}

	@TestVisible
	private static OrderReqDAO.LegalParty createLegalParty(Activation_line__c activationLine) {
		OrderReqDAO.Address address = createAddress(activationLine);
		OrderReqDAO.TelephoneNumber telephoneNumber = createPhoneNumber(activationLine);
		OrderReqDAO.LegalParty legalParty = new OrderReqDAO.LegalParty();
		legalParty.type = TYPE_PERSON;
		legalParty.email = activationLine.Email__c;
		legalParty.firstName = activationLine.First_name__c;
		legalParty.lastName = activationLine.Last_name__c;
		legalParty.telephoneNumber = telephoneNumber;
		legalParty.address = address;
		return legalParty;
	}

	@TestVisible
	private static OrderReqDAO.Address createAddress(Activation_line__c activationLine) {
		OrderReqDAO.Address address = new OrderReqDAO.Address();
		Location_Line__c location = locationsByIds.get(activationLine.Location_Line__c);

		address.streetName = (location != null && location.Street_Name__c != null) ? location.Street_Name__c : activationLine.Street_Name__c;
		address.city = (location != null && location.City__c != null) ? location.City__c : activationLine.City__c;
		address.streetNumber = cleanHouseNumber((location != null && location.Number__c != null) ? location.Number__c : activationLine.Number__c);
		address.streetNumberSuffix = cleanHouseLetter((location != null && location.Number__c != null) ? location.Number__c : activationLine.Number__c);
		address.floorNumber = (location != null && location.Floor__c != null) ? location.Floor__c : activationLine.Floor__c;
		address.doorNumber = (location != null && location.Door__c != null) ? location.Door__c : activationLine.Door__c;
		address.zipCode = (location != null && location.ZIP_Code__c != null) ? location.ZIP_Code__c : activationLine.ZIP_Code__c;
		address.country = DEFAULT_COUNTRY;

		return address;
	}

	@TestVisible
	private static String cleanHouseNumber(String houseNumber) {
		if (houseNumber == null) {
			return null;
		}
		return houseNumber.replaceAll('[A-Za-z]', '');
	}

	@TestVisible
	private static String cleanHouseLetter(String houseNumber) {
		if (houseNumber == null) {
			return null;
		}
		return houseNumber.replaceAll('[^A-Za-z]', '');
	}

	// Salesforce doesn't have the speed information for subscriptions and it can be taken from the name of the product, hence the solution below
	@TestVisible
	private static String getSpeedFromProductName(Activation_line__c activationLine) {
		String productName = activationLine.Product__c;
		if (productName != null && productName.contains(PRODUCT_SPEED_UNIT)) {
			List<String> splittedName = productName.split(PRODUCT_NAME_SPLIT_BY);
			return splittedName.get(splittedName.size() - 2);
		}
		return null;
	}

	public class Request {
		@InvocableVariable
		public List<Activation_line__c> activationLines;
		@InvocableVariable
		public Account account;
	}

	public class Result {
		@InvocableVariable
		public Boolean hasError;
		@InvocableVariable
		public String errorMessage;
	}

	public class ErrorResult {
		public ErrorResultBody error;
	}

	public class ErrorResultBody {
		public String code;
		public String message;
	}

	class OrderAPIActionException extends Exception {
	}
}