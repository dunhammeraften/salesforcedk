@IsTest
public with sharing class TDF_ProductUtils {
    public static List<Product2> createProductsForTests(Integer numOfProds) {
		List<Product2> result = new List<Product2>();
		for (Integer i = 0; i < numOfProds; ++i) {
			if (i == 0) {
				result.add(setUpAddressProductInformation());
			}
			else {
				result.add(setUpProductInformation(i));
			}
		}
		insert result;

		SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c(
			SBQQ__Quantity__c = 1,
			SBQQ__Number__c = 1,
			SBQQ__ConfiguredSKU__c = result[0].Id,
			SBQQ__OptionalSKU__c = result[0].Id
		);

		insert productOption;

		return result;
	}

    public static List<Product2> createNoActionProducts(Integer numOfNoActionProds) {
		List<Product2> result = new List<Product2>();
		for (Integer i = 0; i < numOfNoActionProds; ++i) {
			result.add(setUpProductInformation(i));
			result[i].Activation_Record_Type__c = TDF_Constants.NO_ACTIVATION_NEEDED;
		}
		insert result;
		return result;
	}

    public static List<PricebookEntry> createStandardPricebookEntriesForProducts(List<Product2> theProducts) {
		List<PricebookEntry> result = new List<PricebookEntry>();
		Id standardPricebookId = Test.getStandardPricebookId();
		for (Product2 singleProduct : theProducts) {
			result.add(new PricebookEntry(IsActive = true, Pricebook2Id = standardPricebookId, Product2Id = singleProduct.Id, UnitPrice = 100));
		}
		insert result;
		return result;
	}

    public static Map<Id, PricebookEntry> createProductIdToPricebookEntryMap(List<PricebookEntry> listOfPricebookEntries, List<Product2> productsToUse) {
        Map<Id, PricebookEntry> productIdToPricebookEntryMap = new Map<Id, PricebookEntry>();
		for (Product2 singleProduct : productsToUse) {
			for (PricebookEntry singleEntry : listOfPricebookEntries) {
				if (singleEntry.Product2Id == singleProduct.Id) {
					productIdToPricebookEntryMap.put(singleProduct.Id, singleEntry);
				}
			}
		}
        return productIdToPricebookEntryMap;
    }

    public static List<Product2> createHomeOfficeProducts(Integer numberOfHomeOfficeProducts) {
		List<Product2> result = new List<Product2>();
		for (Integer i = 0; i < numberOfHomeOfficeProducts; ++i) {
			result.add(setUpProductInformation(i));
			result[i].Activation_Record_Type__c = TDF_Constants.HOME_OFFICE;
			result[i].ProductCode = '3122';
			result[i].address_required__c = true;
		}
		insert result;
		return result;
	}

	public static Product2 setUpAddressProductInformation() {
		Product2 result = new Product2(
			Name = 'Test Address Product',
			isActive = true,
			ProductCode = '3122',
			address_required__c = true,
			Activation_Record_Type__c = 'Home office',
			Delivery_Product_Group__c = 'Home office'
		);
		return result;
	}

	public static Product2 setUpProductInformation(Integer i) {
		List<String> activationRecordTypeValues = new List<String>();
		for (Schema.PicklistEntry singleValue : Product2.Activation_Record_Type__c.getDescribe().getPicklistValues()) {
			if (singleValue.getValue() != 'No activation needed') {
				activationRecordTypeValues.add(singleValue.getLabel());
			}
		}
		return new Product2(
			Name = 'Test Product nr:' + i,
			isActive = true,
			Activation_Record_Type__c = activationRecordTypeValues[Math.mod(Integer.valueOf(Math.random() * 100), activationRecordTypeValues.size())],
			Delivery_Product_Group__c = Product2.Delivery_Product_Group__c.getDescribe().getPicklistValues()[0].getValue()
		);
	}
}