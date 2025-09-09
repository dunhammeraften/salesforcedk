@IsTest
public with sharing class NamedCredentialServiceTest {
    @IsTest
    private static void testFindMetadataByEnvironmentSuccess() {
        String namedCredentialPrefix = 'MyTestCredential';
        String environmentName = NamedCredentialService.getEnvironmentName();

        List<Environment_Credential_Mapping__mdt> testMappings = new List<Environment_Credential_Mapping__mdt>();
        Environment_Credential_Mapping__mdt testMapping = new Environment_Credential_Mapping__mdt();
        testMapping.Environment_Name__c = environmentName;
        testMapping.Named_Credential__c = namedCredentialPrefix + environmentName;
        testMappings.add(testMapping);
        
        MetadataSelector.setMock(new MetadataSelectorMock(testMappings));
        
        Test.startTest();
        String namedCredential = NamedCredentialService.getNamedCredential(namedCredentialPrefix);
        Test.stopTest();

        Assert.areEqual(testMapping.Named_Credential__c, namedCredential, 'Response should match the Named_Credential__c field from Custom Metadata');
    }

    @IsTest
    private static void testFindMetadataByDefaultSuccess() {
        String namedCredentialPrefix = 'MyTestCredential';
        String environmentName = NamedCredentialService.DEFAULT_ENVIRONMENT;

        List<Environment_Credential_Mapping__mdt> testMappings = new List<Environment_Credential_Mapping__mdt>();
        Environment_Credential_Mapping__mdt testMapping = new Environment_Credential_Mapping__mdt();
        testMapping.Environment_Name__c = environmentName;
        testMapping.Named_Credential__c = namedCredentialPrefix + environmentName;
        testMappings.add(testMapping);
        
        MetadataSelector.setMock(new MetadataSelectorMock(testMappings));
        
        Test.startTest();
        String namedCredential = NamedCredentialService.getNamedCredential(namedCredentialPrefix);
        Test.stopTest();

        Assert.areEqual(testMapping.Named_Credential__c, namedCredential, 'Response should match the Named_Credential__c field from Custom Metadata');
    }

    @IsTest
    private static void testThrowExceptionWhenNoMetadataMatching() {
        String namedCredentialPrefix = 'MyTestCredential';
        String environmentName = NamedCredentialService.getEnvironmentName();
        String badNamedCredentialPrefix = 'ThisIsNotMatching';

        List<Environment_Credential_Mapping__mdt> testMappings = new List<Environment_Credential_Mapping__mdt>();
        Environment_Credential_Mapping__mdt testMapping = new Environment_Credential_Mapping__mdt();
        testMapping.Environment_Name__c = environmentName;
        testMapping.Named_Credential__c = namedCredentialPrefix + environmentName;
        testMappings.add(testMapping);
        
        MetadataSelector.setMock(new MetadataSelectorMock(testMappings));

        NamedCredentialService.NamedCredentialServiceException testException;
        Test.startTest();
        try {
            String namedCredential = NamedCredentialService.getNamedCredential(badNamedCredentialPrefix);
        } catch(NamedCredentialService.NamedCredentialServiceException e) {
            testException = e;
        }
        Test.stopTest();

        Assert.isNotNull(testException, 'An exception should be thrown');
        Assert.areEqual(
            String.format(NamedCredentialService.NO_NAMED_CREDENTIAL_FOUND, new List<String>{badNamedCredentialPrefix, environmentName}),
            testException.getMessage(),
            'Exception message should match'
        );
    }
}