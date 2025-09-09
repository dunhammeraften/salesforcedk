@IsTest
public with sharing class MetadataSelectorTest {
	@IsTest
	private static void testGetAPISettingsSuccess(){
		String metadataDeveloperName = 'MyTestSetting';
		String brand = 'CompanyName';

		APISettings__mdt mockedSetting = new APISettings__mdt();
		mockedSetting.DeveloperName = metadataDeveloperName;
		mockedSetting.brand__c = brand;

		MetadataSelector.setMock(new MetadataSelectorMock(mockedSetting));

		Test.startTest();
		APISettings__mdt mdt = MetadataSelector.getAPISettings(metadataDeveloperName);
		Test.stopTest();

		Assert.isNotNull(mdt, 'A metadata record should be returned');
		Assert.areEqual(brand, mdt.brand__c, 'The returned metadata brand should match');
	}

	@IsTest
	private static void testGetApiSettingsNotFound(){
		Test.startTest();
		APISettings__mdt noMdt = MetadataSelector.getAPISettings(StringUtils.makeRandomStringNoNumerics(20));
		Test.stopTest();

		Assert.isNull(noMdt, 'Random DeveloperName should not find any valid metadata records');
	}

	@IsTest
	private static void testGetEnvironmentCredentialMappingsSuccess(){
		String namedCredentialPrefix = 'MyTestCredential';
		String environmentName = NamedCredentialService.getEnvironmentName();

		List<Environment_Credential_Mapping__mdt> mockedMappings = new List<Environment_Credential_Mapping__mdt>();
		Environment_Credential_Mapping__mdt mockedMapping = new Environment_Credential_Mapping__mdt();
		mockedMapping.Environment_Name__c = environmentName;
		mockedMapping.Named_Credential__c = namedCredentialPrefix + environmentName;
		mockedMappings.add(mockedMapping);

		MetadataSelector.setMock(new MetadataSelectorMock(mockedMappings));

		Test.startTest();
		List<Environment_Credential_Mapping__mdt> mappings = MetadataSelector.getEnvironmentCredentialMappings();
		Test.stopTest();

		Assert.isNotNull(mappings, 'Mappings should be returned');
		Assert.areEqual(mockedMappings.size(), mappings.size(), 'Amount of mappings returned should match the amount of test mappings');
		Assert.areEqual(mockedMapping.Named_Credential__c, mappings[0].Named_Credential__c, 'Response should match the Named_Credential__c field from Custom Metadata');
	}

	@IsTest
	private static void testGetEnvironmentCredentialMappingsNoRecords(){
		String namedCredentialPrefix = 'MyTestCredential';
		String environmentName = NamedCredentialService.getEnvironmentName();

		List<Environment_Credential_Mapping__mdt> mockedMappings = new List<Environment_Credential_Mapping__mdt>();

		MetadataSelector.setMock(new MetadataSelectorMock(mockedMappings));

		Test.startTest();
		List<Environment_Credential_Mapping__mdt> mappings = MetadataSelector.getEnvironmentCredentialMappings();
		Test.stopTest();

		Assert.isTrue(mappings.isEmpty(), 'No mappings should be returned');
	}

	@IsTest
	private static void testGetEnvironmentCredentialMappingsNotMocked(){
		Test.startTest();
		List<Environment_Credential_Mapping__mdt> mappings = MetadataSelector.getEnvironmentCredentialMappings();
		Test.stopTest();

		Assert.areEqual(Environment_Credential_Mapping__mdt.getAll().size(), mappings.size(), 'The amount of mappings returned should match that of the org');
	}

	@IsTest
	private static void testGetDocumentIdentifierMappingsSuccess(){
		String label = 'Custom_Field__c';
		String productDocumentIdentifier = 'Mobile Type Products';

		List<Document_Identifier__mdt> mockedMappings = new List<Document_Identifier__mdt>();
		Document_Identifier__mdt mockedMapping = new Document_Identifier__mdt();
		mockedMapping.Label = label;
		mockedMapping.Product_Document_Identifier__c = productDocumentIdentifier;
		mockedMappings.add(mockedMapping);

		MetadataSelector.setMock(new MetadataSelectorMock(mockedMappings));

		Test.startTest();
		List<Document_Identifier__mdt> mappings = MetadataSelector.getDocumentIdentifierMappings();
		Test.stopTest();

		Assert.isNotNull(mappings, 'Mappings should be returned');
		Assert.areEqual(mockedMappings.size(), mappings.size(), 'Amount of mappings returned should match the amount of test mappings');
		Assert.areEqual(productDocumentIdentifier, mappings[0].Product_Document_Identifier__c, 'Response should match the Product_Document_Identifier__c field from Custom Metadata');
	}

	@IsTest
	private static void testGetDocumentIdentifierMappingsNoMappings(){
		List<Document_Identifier__mdt> mockedMappings = new List<Document_Identifier__mdt>();

		MetadataSelector.setMock(new MetadataSelectorMock(mockedMappings));

		Test.startTest();
		List<Document_Identifier__mdt> mappings = MetadataSelector.getDocumentIdentifierMappings();
		Test.stopTest();

		Assert.isTrue(mappings.isEmpty(), 'No mappings should be returned');
	}

	@IsTest
	private static void testGetDocumentIdentifierMappingsNotMocked(){
		Test.startTest();
		List<Document_Identifier__mdt> mappings = MetadataSelector.getDocumentIdentifierMappings();
		Test.stopTest();

		Assert.areEqual(Document_Identifier__mdt.getAll().size(), mappings.size(), 'The amount of mappings returned should match that of the org');
	}

}