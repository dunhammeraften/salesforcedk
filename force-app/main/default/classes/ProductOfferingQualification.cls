/**
 *
 * @author Frederik
 *
 * @author Mujahid (qet9252)
 * @description ProductOfferingQualification is the main class which will make the first call to get available products for a given set of address.
 * Then the second call will be made to confirm the user selections for a given address.
 * * *
 */
public without sharing class ProductOfferingQualification {
	private static APISettings__mdt api;
	private static final String ERROR_ADDITIONAL_INFO = 'ProductOfferingQualification';
	private static final String ERROR_ORIGIN = 'Apex';
	private static final String ADDRESS_STATUS_VALID = 'Valid';
	private static final String ADDRESS_STATUS_INVALID = 'Not Valid';
	private static final String ACTION_ADD = 'add';
	private static final String CATEGORY_NAME_HOMEOFFICE = 'homeoffice';
	private static final String CATEGORY_NAME_BUSINESSINTERNET = 'businessinternet';
	private static final String CHANNEL_NAME_SF = 'salesForce';
	private static final String REFERRED_TYPE_PLACE = 'place';
	private static final String PLACE_TYPE = 'GeographicAddress';
	private static final String AUTHORIZATION_TXT = 'Authorization';
	private static final String CONTENT_TYPE_TXT = 'Content-Type';
	private static final String CONTENT_TYPE_VALUE = 'application/json';
	private static final String BEARER_TXT = 'Bearer ';
	private static final String FIRST_CALL = 'First Call';
	private static final String SECOND_CALL = 'Second Call';
	private static final String ERROR_FIELDS = ' Fields that affected this error: ';
	private static final String LOCATION_LINES_UPDATE_ERROR = 'Location Line Update Error : ';
	private static final String POQ_ITEMS_UPDATE_ERROR = 'POQItems Update Error : ';
	private static List<System_Log__c> errorsList = new List<System_Log__c>();

	@AuraEnabled(cacheable=false)
	public static void activationLineQualification(List<Id> activationLineIds) {
		List<Activation_line__c> activationLines = ActivationLineSelector.getActivationLinesByIds(
			new Set<Id>(activationLineIds)
		);

		api = MetadataSelector.getAPISettings('ProductOfferingQualificationAPI');
		String token = null;

		if (Test.isRunningTest()) {
			token = 'TestToken';
		} else {
			token = AuthorizationWrapper.getAPIToken(api);
		}

		try {
			List<List<String>> reqBodiesChunks = generateRequestBodies(
				activationLines,
				false,
				CATEGORY_NAME_BUSINESSINTERNET
			);

			List<POQres> responses = new List<POQres>();

			for (List<String> chunk : reqBodiesChunks) {
				HttpResponse res = makeRequest(token, chunk);
				if (res != null) {
					String respBody = res.getBody().replace('@', '');
					List<POQres> poqResponse = (List<POQres>) JSON.deserialize(respBody, List<POQres>.class);
					responses.addAll(poqResponse);
				}
			}

			// Batch instance
			POQresBatch parsedResult = new POQresBatch();
			parsedResult.batch = responses;

			qualify5G(parsedResult);
		} catch (Exception e) {
			handleException(e);
		} finally {
			insert errorsList;
		}
	}

	private static void qualify5G(POQresBatch parsedResult) {
		List<Activation_line__c> activationLinesToBeUpdated = new List<Activation_line__c>();
		Set<Id> activationLineIds = new Set<Id>();
		for (POQres poqRes : parsedResult.batch) {
			activationLineIds.add(poqRes.id);
		}
		Map<Id, Activation_line__c> activationLinesMap = new Map<Id, Activation_line__c>(
			ActivationLineSelector.getActivationLinesByIds(activationLineIds)
		);

		for (POQres poqRes : parsedResult.batch) {
			for (ProductOfferingQualificationItem poqItem : poqRes.productOfferingQualificationItem) {
				if (
					poqItem.productOffering.priceplanCode == 'FWABIS01' &&
					activationLinesMap.get(poqRes.id)?.Manual_Product__c == null
				) {
					Activation_line__c line = new Activation_line__c();
					line.Id = poqRes.id;
					line.Manual_Product__c = ProductSelector.getProductByPriceplanCode(poqItem.productOffering.priceplanCode)[0]
						.Id;
					activationLinesToBeUpdated.add(line);
				}
			}
		}

		try {
			Database.SaveResult[] activationLineResults = Database.update(activationLinesToBeUpdated, false);
			for (Database.SaveResult sr : activationLineResults) {
				if (!sr.isSuccess()) {
					for (Database.Error err : sr.getErrors()) {
						String errorMsg =
							LOCATION_LINES_UPDATE_ERROR +
							err.getStatusCode() +
							': ' +
							err.getMessage() +
							', ' +
							ERROR_FIELDS +
							err.getFields();
						errorsList.add(createErrorLog(errorMsg));
					}
				}
			}
		} catch (Exception e) {
			handleException(e);
		}
	}

	@AuraEnabled(cacheable=false)
	public static void main(List<List<SObject>> lines, Boolean fullQualification) {
		api = MetadataSelector.getAPISettings('ProductOfferingQualificationAPI');
		String token = null;

		if (Test.isRunningTest()) {
			token = 'TestToken';
		} else {
			token = AuthorizationWrapper.getAPIToken(api);
		}

		List<POQ_Item__c> poqItems = new List<POQ_Item__c>();
		List<Location_Line__c> locationLinesToBeUpdated = new List<Location_Line__c>();

		try {
			List<List<String>> reqBodiesChunks = generateRequestBodies(lines[0], fullQualification, CATEGORY_NAME_HOMEOFFICE);
			List<POQres> responses = new List<POQres>();
			for (List<String> chunk : reqBodiesChunks) {
				HttpResponse res = makeRequest(token, chunk);
				if (res != null) {
					String respBody = res.getBody().replace('@', '');
					List<POQres> poqResponse = (List<POQres>) JSON.deserialize(respBody, List<POQres>.class);
					responses.addAll(poqResponse);
				}
			}

			// Batch instance
			POQresBatch parsedResult = new POQresBatch();
			parsedResult.batch = responses;

			if (fullQualification == false) {
				List<POQ_Item__c> tmpPOQitems = createPoqItems(parsedResult);
				List<Location_Line__c> updatedAddressLines = new List<Location_Line__c>();
				updatedAddressLines = enrichAddresses(parsedResult);

				poqItems.addAll(tmpPOQitems);
				locationLinesToBeUpdated.addAll(updatedAddressLines);
				changePOQStage(updatedAddressLines, FIRST_CALL);
			} else {
				sleep(750);

				// Update POQ Items
				List<Location_Line__c> allLines = new List<Location_Line__c>();
				for (List<Location_Line__c> listOfLines : lines) {
					allLines.addAll(listOfLines);
				}

				List<POQ_Item__c> tmpPoqItems = updatePoqItems(parsedResult, allLines); // Updated inside
				poqItems.addAll(tmpPOQitems);

				// Bad solution, fix later
				// Find Location lines to update POQ stage on
				Set<Location_Line__c> linesSetToUpdatePOQStage = new Set<Location_Line__c>();

				for (POQ_Item__c item : tmpPoqItems) {
					Location_Line__c line = new Location_Line__c(id = item.Location_Line__c);
					linesSetToUpdatePOQStage.add(line);
				}
				List<Location_Line__c> linesListToUpdatePOQStage = new List<Location_Line__c>();
				linesListToUpdatePOQStage.addAll(linesSetToUpdatePOQStage);
				changePOQStage(linesListToUpdatePOQStage, SECOND_CALL);
				locationLinesToBeUpdated.addAll(linesListToUpdatePOQStage);
			}

			updateLocationLinesAndPOQItems(poqItems, locationLinesToBeUpdated);
		} catch (Exception e) {
			handleException(e);
		} finally {
			insert errorsList;
		}
	}

	@InvocableMethod(label='Product Offering Qualification' description='CALL POQ.' callout=true)
	public static void qualifyProducts(List<List<SObject>> lines) {
		main(lines, false);
	}

	private static GeographicAddress createGeographicAddress(SObject line) {
		GeographicAddress address = new GeographicAddress();
		address.streetName = String.valueOf(line.get('Street_Name__c'));
		address.houseNo = cleanHouseNumber(String.valueOf(line.get('Number__c')));
		address.houseLetter = cleanHouseLetter(String.valueOf(line.get('Number__c')));
		address.floor = cleanFloor(String.valueOf(line.get('Floor__c')));
		address.door = String.valueOf(line.get('Door__c'));
		address.postDistrict = String.valueOf(line.get('City__c'));
		address.zip = String.valueOf(line.get('ZIP_Code__c'));

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

	@TestVisible
	private static String cleanFloor(String floor) {
		if (floor == null) {
			return null;
		}
		return floor.replaceAll('\\.', '');
	}

	@TestVisible
	private static void sleep(Integer milliseconds) {
		Long startTime = DateTime.now().getTime();
		Long finalTime = DateTime.now().getTime();
		Long millisecondsToWait = milliseconds;
		while (finalTime - startTime < millisecondsToWait) {
			finalTime = DateTime.now().getTime();
		}
	}

	@TestVisible
	private static List<Location_Line__c> enrichAddresses(POQresBatch batch) {
		// Here we could also update if lines has been called
		List<Location_Line__c> returnList = new List<Location_Line__c>();
		for (POQres res : batch.batch) {
			Location_Line__c line = new Location_Line__c();
			line.id = res.id == null ? null : res.id;
			if (res.code == 'SERVICE_LOCATION_NOT_FOUND') {
				line.Address_Wash_Status__c = ADDRESS_STATUS_INVALID;
			} else {
				line.Address_Wash_Status__c = ADDRESS_STATUS_VALID;
				line.Street_Code__c = res.Place[0]?.geographicAddress?.streetCode;
				line.Municipality_Code__c = res.Place[0]?.geographicAddress?.municipalityCode;
			}

			returnList.add(line);
		}
		return returnList;
	}

	private static List<POQ_Item__c> createPoqItems(POQresBatch batch) {
		List<String> homeOfficeProductCodes = getHomeOfficeProductCodes();
		List<POQ_Item__c> poqItems = new List<POQ_Item__c>();

		for (POQres res : batch.batch) {
			if (res.code != 'SERVICE_LOCATION_NOT_FOUND') {
				for (ProductOfferingQualificationItem item : res.ProductOfferingQualificationItem) {
					if (homeOfficeProductCodes.contains(item.productOffering.priceplanCode) && item.action == ACTION_ADD) {
						POQ_Item__c poqItem = createPOQItem(item, res.id);
						updatePOQItemWithNotes(poqItem, item.note);
						updatePOQItemWithEligibilityReasons(poqItem, item.eligibilityUnavailabilityReason);
						updatePOQItemWithPseudoProduct(poqItem);
						poqItems.add(poqItem);
					}
				}
			}
		}

		return poqItems;
	}

	private static List<POQ_Item__c> updatePoqItems(POQresBatch batch, List<Location_Line__c> locationLines) {
		List<String> homeOfficeProductCodes = getHomeOfficeProductCodes();
		List<POQ_Item__c> poqItems = new List<POQ_Item__c>();

		Map<Id, Map<String, POQ_Item__c>> oldPoqItemsMap = new Map<Id, Map<String, POQ_Item__c>>();

		for (POQ_Item__c oldPoqItem : [
			SELECT
				Id,
				Name,
				Location_Line__c,
				DIGGING_NEEDED__c,
				NETWORK_PROVIDER_NOT_SUPPORTED__c,
				NEW_ROUTER_NEEDED__c,
				NOT_SALEABLE__c,
				Pseudo_Product_DA__c,
				Pseudo_Product__c,
				Rank__c,
				plugPresentPositiveValidation__c,
				plugTechnicianRequired__c,
				priceplanCode__c,
				Active_Blocking_Line_Present__c
			FROM POQ_Item__c
			WHERE Location_Line__c IN :locationLines
		]) {
			Id id = oldPoqItem.Location_Line__c;
			Map<String, POQ_Item__c> itemsMap = oldPoqItemsMap.get(id);

			if (itemsMap == null) {
				itemsMap = new Map<String, POQ_Item__c>();

				itemsMap.put(oldPoqItem.priceplanCode__c, oldPoqItem);

				oldPoqItemsMap.put(id, itemsMap);
			} else {
				itemsMap.put(oldPoqItem.priceplanCode__c, oldPoqItem);

				oldPoqItemsMap.put(id, itemsMap);
			}
		}
		for (POQres res : batch.batch) {
			if (res.code != 'SERVICE_LOCATION_NOT_FOUND' || res.code != 'THIRD_PARTY_COMPONENT_CONNECTION_FAILURE') {
				Map<String, POQ_Item__c> poqItemsByPriceplanCode = oldPoqItemsMap.get(res.id);
				System.debug('res.ProductOfferingQualificationItem  = ' + res.ProductOfferingQualificationItem);
				for (ProductOfferingQualificationItem item : res.ProductOfferingQualificationItem) {
					if (homeOfficeProductCodes.contains(item.productOffering.priceplanCode) && item.action == ACTION_ADD) {
						POQ_Item__c poqItem = poqItemsByPriceplanCode.get(item.productOffering.priceplanCode);
						updatePOQItemWithNotes(poqItem, item.note);
						updatePOQItemWithEligibilityReasons(poqItem, item.eligibilityUnavailabilityReason);
						updatePOQItemWithPseudoProduct(poqItem);
						poqItems.add(poqItem);
					}
				}
			}
		}
		return poqItems;
	}

	private static List<String> getHomeOfficeProductCodes() {
		List<String> homeOfficeProductCodes = new List<String>();

		for (Product2 p : [SELECT ProductAPI_Telia_Product_Id__c FROM Product2 WHERE ProductCode LIKE '330%']) {
			homeOfficeProductCodes.add(p.ProductAPI_Telia_Product_Id__c);
		}

		return homeOfficeProductCodes;
	}

	@TestVisible
	private static POQ_Item__c createPOQItem(ProductOfferingQualificationItem item, String lineId) {
		POQ_Item__c poqItem = new POQ_Item__c();
		poqItem.Name = item.productOffering.name;
		poqItem.priceplanCode__c = item.productOffering.priceplanCode;
		poqItem.Location_Line__c = lineId;
		poqItem.Pseudo_Product__c = 'Noname';
		poqItem.Pseudo_Product_DA__c = 'Noname';
		poqItem.ProductOfferingQualificationItemId__c = item.id;
		poqItem.ProductOfferingId__c = item.productOffering.id;

		return poqItem;
	}

	@TestVisible
	private static void updatePOQItemWithNotes(POQ_Item__c poqItem, List<Note> notes) {
		for (Note note : notes) {
			if (note.type.equals('ConsequenceNote') && note.code.equals('NEW_ROUTER_NEEDED')) {
				poqItem.NEW_ROUTER_NEEDED__c = true;
			}

			if (note.type.equals('LineAttributesNote')) {
				updateLineAttributes(poqItem, note);
			}

			if (note.type.equals('NetworkProviderProductCatalogIdNote')) {
				poqItem.VendorProductCatalogId__c = note.catalogId;
			}

			if (note.type.equals('NetworkProviderProductCodeNote')) {
				poqItem.VendorProductCode__c = note.code;
			}
		}
	}

	private static void updateLineAttributes(POQ_Item__c poqItem, Note note) {
		if (note.plugTechnicianRequired != null) {
			poqItem.plugTechnicianRequired__c = note.plugTechnicianRequired;
		}
		if (note.plugPresentPositiveValidation != null) {
			poqItem.plugPresentPositiveValidation__c = note.plugPresentPositiveValidation;
		}
		if (note.activeBlockingLinePresent != null) {
			poqItem.Active_Blocking_Line_Present__c = note.activeBlockingLinePresent;
		}
		if (note.diggingRequired != null) {
			poqItem.DIGGING_NEEDED__c = note.diggingRequired;
		}
		if (note.addressId != null) {
			poqItem.AddressRefId__c = note.addressId;
		}
		if (note.siteId != null) {
			poqItem.SiteId__c = note.siteId;
		}
		if (note.lineConnectionStatus != null) {
			poqItem.lineConnectionStatus__c = note.lineConnectionStatus;
		}
		if (note.lineProvider != null) {
			poqItem.lineProvider__c = note.lineProvider;
		}
	}

	@TestVisible
	private static void updatePOQItemWithEligibilityReasons(
		POQ_Item__c poqItem,
		List<EligibilityUnavailabilityReason> reasons
	) {
		for (EligibilityUnavailabilityReason reason : reasons) {
			if (reason.code == 'NETWORK_PROVIDER_NOT_SUPPORTED') {
				poqItem.NETWORK_PROVIDER_NOT_SUPPORTED__c = true;
			}

			if (reason.code == 'NOT_SALEABLE') {
				poqItem.NOT_SALEABLE__c = true;
			}
		}
	}

	private static void updatePOQItemWithPseudoProduct(POQ_Item__c poqItem) {
		List<Home_Office_Product_Preferences__mdt> hopps = Home_Office_Product_Preferences__mdt.getAll().values();

		for (Home_Office_Product_Preferences__mdt hopp : hopps) {
			List<String> productCodes = String.valueOf(hopp.get('Product_Codes__c')).split(',');

			if (productCodes.contains(poqItem.priceplanCode__c)) {
				boolean diggingNeeded = poqItem.DIGGING_NEEDED__c;
				boolean hoppDiggingNeeded = Boolean.valueOf(hopp.get('DIGGING_NEEDED__c'));

				if (
					(diggingNeeded && hoppDiggingNeeded) || (!diggingNeeded && (hoppDiggingNeeded == null || !hoppDiggingNeeded))
				) {
					poqItem.Pseudo_Product__c = String.valueOf(hopp.get('Label'));
					poqItem.Pseudo_Product_DA__c = String.valueOf(hopp.get('Product_Da_Translation__c'));
					poqItem.Rank__c = Integer.valueOf(hopp.get('Product_Sequence__c'));
				}
			}
		}
	}

	private static void changePOQStage(List<Location_Line__c> locationLines, String stage) {
		List<Location_Line__c> toBeUpdated = new List<Location_Line__c>();

		for (Location_Line__c line : locationLines) {
			line.POQ_Stage__c = stage;
		}
	}

	private static List<List<String>> generateRequestBodies(
		List<SObject> lines,
		Boolean fullQualification,
		String categoryName
	) {
		List<String> reqBodies = new List<String>();

		for (SObject line : lines) {
			POQreq request = createPOQRequest(line, fullQualification, categoryName);
			String reqBody = JSON.serialize(request, true)
				.replace('theType', '@type')
				.replace('theReferredType', '@referredType');
			System.debug('reqBody = ' + reqBody);
			reqBodies.add(reqBody);
		}

		return splitRequestBodiesIntoChunks(reqBodies, fullQualification);
	}

	private static POQreq createPOQRequest(SObject line, Boolean fullQualification, String categoryName) {
		POQreq request = new POQreq();
		request.id = String.valueOf(line.get('Id'));
		request.provideOnlyAvailable = true;
		request.provideUnavailabilityReason = false;
		request.provideAllAvailableItems = !fullQualification; // this flag will determind if there will be productOfferingQualificationItem or not
		request.usePlaceMultiStepQualification = true;

		request.category = new Category();
		request.category.name = categoryName;

		request.channel = new Channel();
		request.channel.name = CHANNEL_NAME_SF;

		relatedParty rp = new RelatedParty();
		rp.theReferredType = REFERRED_TYPE_PLACE;
		rp.place = new Place();
		rp.place.theType = PLACE_TYPE;

		rp.place.geographicAddress = createGeographicAddress(line);
		request.relatedParty = new List<RelatedParty>();
		request.relatedParty.add(rp);

		System.debug('fullQualification = ' + fullQualification);

		if (fullQualification) {
			System.debug('inside full qualification');
			request.productOfferingQualificationItem = new List<ProductOfferingQualificationItem>(); // List
			ProductOfferingQualificationItem pi = new ProductOfferingQualificationItem();
			System.debug('POQ_ProductOfferingId__c = ' + line.get('POQ_ProductOfferingId__c'));
			if (line.get('POQ_ProductOfferingId__c') != null) {
				pi.id = String.valueOf(line.get('POQ_ProductOfferingQualificationItemId__c'));
				pi.action = ACTION_ADD;
				pi.productOffering = new productOffering();
				pi.productOffering.id = String.valueOf(line.get('POQ_ProductOfferingId__c'));
				request.productOfferingQualificationItem.add(pi);
			}
			System.debug('request.productOfferingQualificationItem  = ' + request.productOfferingQualificationItem);
		}
		System.debug('request with fullQualification = ' + request);
		return request;
	}

	private static List<List<String>> splitRequestBodiesIntoChunks(List<String> reqBodies, Boolean fullQualification) {
		POQ_batch_chunks__c batchChunks = POQ_batch_chunks__c.getOrgDefaults();
		List<List<String>> reqBodiesChunks = new List<List<String>>();
		Integer chunkSize = fullQualification
			? batchChunks.Full_Qualification_Batch_Size__c.intValue()
			: batchChunks.Basic_Qualification_Batch_Size__c.intValue();
		List<String> currentChunk = new List<String>();

		for (String reqBody : reqBodies) {
			if (currentChunk.size() < chunkSize) {
				currentChunk.add(reqBody);
			} else {
				reqBodiesChunks.add(currentChunk);
				currentChunk = new List<String>{ reqBody };
			}
		}

		if (!currentChunk.isEmpty()) {
			reqBodiesChunks.add(currentChunk);
		}

		return reqBodiesChunks;
	}

	private static HttpResponse makeRequest(String token, List<String> chunks) {
		Map<String, String> headers = new Map<String, String>{
			AUTHORIZATION_TXT => BEARER_TXT + token,
			CONTENT_TYPE_TXT => CONTENT_TYPE_VALUE
		};
		String endpoint = api.API_PartialEndPoint__c;
		String requestBody = '[' + String.join(chunks, ',') + ']';
		HttpResponse res = HttpWrapper.post(endpoint, requestBody, headers);
		if (res.getStatusCode() != 200) {
			createErrorLog('Request failed with status code: ' + res.getStatusCode());
			return null;
		}
		return res;
	}

	@TestVisible
	private static List<Id> getLocationLineIds(List<Location_Line__c> locationLines) {
		List<Id> ids = new List<Id>();
		for (Location_Line__c line : locationLines) {
			ids.add(line.Id);
		}
		return ids;
	}

	private static void updateLocationLinesAndPOQItems(
		List<POQ_Item__c> poqItems,
		List<Location_Line__c> locationLinesToBeUpdated
	) {
		try {
			Database.SaveResult[] locationLineResults = Database.update(locationLinesToBeUpdated, false);
			Database.UpsertResult[] poqItemsResults = Database.upsert(poqItems, false);
			for (Database.SaveResult sr : locationLineResults) {
				if (!sr.isSuccess()) {
					for (Database.Error err : sr.getErrors()) {
						String errorMsg =
							LOCATION_LINES_UPDATE_ERROR +
							err.getStatusCode() +
							': ' +
							err.getMessage() +
							', ' +
							ERROR_FIELDS +
							err.getFields();
						errorsList.add(createErrorLog(errorMsg));
					}
				}
			}

			for (Database.UpsertResult sr : poqItemsResults) {
				if (!sr.isSuccess()) {
					for (Database.Error err : sr.getErrors()) {
						String errorMsg =
							POQ_ITEMS_UPDATE_ERROR +
							err.getStatusCode() +
							': ' +
							err.getMessage() +
							', ' +
							ERROR_FIELDS +
							err.getFields();
						errorsList.add(createErrorLog(errorMsg));
					}
				}
			}
		} catch (Exception e) {
			handleException(e);
		}
	}

	@TestVisible
	private static void handleException(Exception e) {
		errorsList.add(createErrorLog('Error on line ' + e.getLineNumber() + ' : message = ' + e.getMessage()));
	}

	@TestVisible
	private static System_Log__c createErrorLog(String errorMsg) {
		System.debug('errorMsg = ' + errorMsg);
		System_Log__c errorLog = new System_Log__c(
			Origin__c = ERROR_ORIGIN,
			Error_Body__c = errorMsg,
			Additional_Information__c = ERROR_ADDITIONAL_INFO
		);
		return errorLog;
	}

	private class POQreqBatch {
		List<POQreq> batch;
	}

	private class POQreq {
		private String id;
		private Boolean provideOnlyAvailable;
		private Boolean provideUnavailabilityReason;
		private Boolean provideAllAvailableItems;
		private Boolean usePlaceMultiStepQualification;
		private List<productOfferingQualificationItem> productOfferingQualificationItem;
		private Category category;
		private Channel channel;
		private List<relatedParty> relatedParty;
	}

	@TestVisible
	private class POQresBatch {
		@TestVisible
		List<POQres> batch;
	}

	@TestVisible
	private class POQres {
		@TestVisible
		private String id;
		private String expirationDate; //YYYY-MM-ddTHH:mm:ss.SSSZ / 2023-01-05T09:31:05.566Z
		private Boolean provideAlternative;
		private Boolean provideOnlyAvailable;
		private Boolean provideUnavailabilityReason;
		private Boolean provideAllAvailableItems;
		private String qualificationNewResult; // [ GREEN, YELLOW, RED ]
		private String qualificationResult; // [ QUALIFIED, UNQUALIFIED, ALTERNATE ]
		private Category category;
		private Channel channel;
		private marketSegment marketSegment;
		@TestVisible
		private List<Place> place;
		private List<ProductOfferingQualificationItem> productOfferingQualificationItem;
		private List<relatedParty> relatedParty;
		private String state; // [ acknowledged, terminatedWithError, inProgress, done ]
		@TestVisible
		private String code;
	}

	private class Category {
		private String id;
		private String name;
	}

	private class Channel {
		private String id;
		private String name;
	}

	private class MarketSegment {
		private String id;
		private String name;
	}

	@TestVisible
	private class Place {
		private String id;
		@TestVisible
		private String name;
		private String theType; // '@type' is replaced by 'theType' for Apex to be able to handle it.
		@TestVisible
		private GeographicAddress geographicAddress;
	}

	@TestVisible
	private class GeographicAddress {
		@TestVisible
		private String streetName;
		private String houseNo;
		private String houseLetter;
		private String floor;
		private String door;
		private String postDistrict;
		@TestVisible
		private Integer streetCode;
		@TestVisible
		private Integer municipalityCode;
		private String zip;
	}

	@TestVisible
	private class ProductOfferingQualificationItem {
		private String id;
		private String qualificationItemResult;
		private String action; // [ add, modify, delete, noChange ]
		@TestVisible
		private List<EligibilityUnavailabilityReason> eligibilityUnavailabilityReason;
		private List<Note> note;
		private String product;
		@TestVisible
		private ProductOffering productOffering;
		private String state;
		private String type; // '@type' is replaced by 'theType' for Apex to be able to handle it.
	}

	@TestVisible
	private class Note {
		private String id;
		private String text;
		private String baseType;
		@TestVisible
		private String type;
		@TestVisible
		private String code;
		private Boolean plugTechnicianRequired;
		private Boolean plugPresentPositiveValidation;
		private Boolean activeBlockingLinePresent;
		private Boolean diggingRequired;
		private String catalogId;
		private String lineConnectionStatus;
		private String addressId;
		private String siteId;
		private String lineProvider;
	}

	private class RelatedParty {
		private String id;
		private String name;
		private String role;
		private Place place;
		private String theReferredType; // [ account, subscription, customer, place, cpr, orderId ]
	}

	private class Price {
		private Double percentage;
		private Double taxRate;
	}

	private class ProductOfferingPrice {
		private String description;
		private String name;
		private String code;
		private String priceType;
		private String recurringChargePeriod;
		private String unitOfMeasure;
		private Price price;
	}

	@TestVisible
	private class EligibilityUnavailabilityReason {
		@TestVisible
		private String code; // [
		// NOT_SALEABLE, INVALID_LIFECYCLE, INCLUDED, SUBSTITUTE, UNAVAILABLE,
		// SELECTION_ERROR, EXCLUDED, IN_BINDING_PERIOD, ONGOING_ORDER, IS_SUSPENDED,
		// SUBSCRIPTION_CANCELLED, SUBSCRIPTION_RESERVED, MASTER_OFFERING_NOT_PRESENT,
		// MEMBER_OFFERING_EXCEEDS, MANDATORY_OFFERING_FOR_EXTRA_DATA_CARD,
		// MASTER_OFFERING_HAS_EXISTING_MEMBER, PRICEPLAN_EXISTS, ONE_EXTRA_DATA_CARD_PER_SUBSCRIPTION_ONLY, SUBSCRIPTION_NOT_SUPPORTED, FUTURE_CANCELLATION,
		// ACTIVE_VAS, ONGOING_PORTOUT, ACTIVE_DISCOUNT, ACTIVE_BARRING, ACTIVE_INSURANCE,
		// ADD_COMMAND_NOT_ALLOWED, NO_ALTERNATE_AVAILABLE, MULTIPLE_PRICES_EXIST, PRICE_DOES_NOT_EXIST, SELECTED_SUBSCRIPTION_LESS_EXPENSIVE,
		// EXISTING_VAS_OFFERING_LESS_EXPENSIVE, ALTERNATE_VAS_OFFERING_LESS_EXPENSIVE, NOT_AVAILABLE_IN_PROLONG, NOT_AVAILABLE_IN_MODIFY, BROADBAND_SERVICE_NOT_AVAILABLE,
		// BROADBAND_SERVICE_SPEED_NOT_SUPPORTED, NETWORK_PROVIDER_NOT_SUPPORTED, PREFERRED_NETWORK_PROVIDER_AVAILABLE, PREFERRED_NETWORK_TECHNOLOGY_AVAILABLE, EXISTING_SUBSCRIPTION_MORE_EXPENSIVE,
		// PRICE_NOT_AVAILABLE_WITH_EXISTING_SUBSCRIPTION, DIGGING_DISTANCE_TOO_LONG, REQUIRES_SUBSCRIPTION_WITH_SPECIFIC_PRODUCT_OFFERING_ON_ANY_CUSTOMER_ACCOUNT, VAS_NOT_AVAILABLE_WITH_SELECTED_OFFERING, INSURANCE_NOT_AVAILABLE_WITH_SELECTED_OFFERING,
		// NOT_AVAILABLE_IN_CHANNEL, UNKNOWN_MIN_COMMITMENT_LENGTH, ADDRESS_ALREADY_IN_USE, NOT_IN_CONTRACT, COMMITMENT_NOT_IN_CONTRACT,
		// LOYALTY_VAS_NOT_AVAILABLE, UPCOMING_ADDRESS
		// ]
		@TestVisible
		private String subCode;
		@TestVisible
		private String label;
	}

	@TestVisible
	private class ProductOffering {
		private String id;
		@TestVisible
		private String name;
		@TestVisible
		private String code;
		@TestVisible
		private String priceplanCode;
		private List<ProductOfferingPrice> productOfferingPrice;
	}

	class ProductOfferingQualificationException extends Exception {
	}
}
