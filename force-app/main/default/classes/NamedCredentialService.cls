public with sharing class NamedCredentialService {
    @TestVisible
    private static final String DEFAULT_ENVIRONMENT = 'default';
    @TestVisible
    private static final String NO_NAMED_CREDENTIAL_FOUND = 'No Named Credential Mapping found for {0} for environment {1}';
    private static final String PROD_ENVIRONMENT = 'prod';

    public static String getNamedCredential(String namedCredentialPrefix) {
        List<Environment_Credential_Mapping__mdt> allMappings = MetadataSelector.getEnvironmentCredentialMappings();
        String environmentName = getEnvironmentName();
        List<Environment_Credential_Mapping__mdt> namedCredentialMappings = filterByNamedCredential(allMappings, namedCredentialPrefix);
        Environment_Credential_Mapping__mdt environmentMapping = getNamedCredentialEnvironmentMapping(namedCredentialMappings, environmentName);

        if(environmentMapping == null) {
            throw new NamedCredentialServiceException(String.format(NO_NAMED_CREDENTIAL_FOUND, new List<String>{ namedCredentialPrefix, environmentName }));
        }

        return environmentMapping.Named_Credential__c;
    }

    @TestVisible
    private static String getEnvironmentName() {
        System.Domain domain = DomainParser.parse(URL.getOrgDomainUrl());
        String sandboxName = domain.getSandboxName();
        return sandboxName == null ? PROD_ENVIRONMENT : sandboxName;
    }

    private static List<Environment_Credential_Mapping__mdt> filterByNamedCredential(List<Environment_Credential_Mapping__mdt> mappings, String namedCredentialPrefix) {
        List<Environment_Credential_Mapping__mdt> filteredMappings = new List<Environment_Credential_Mapping__mdt>();
        for(Environment_Credential_Mapping__mdt mapping : mappings) {
            if(mapping.Named_Credential__c.startsWithIgnoreCase(namedCredentialPrefix)) {
                filteredMappings.add(mapping);
            }
        }

        return filteredMappings;
    }

    private static Environment_Credential_Mapping__mdt getNamedCredentialEnvironmentMapping(List<Environment_Credential_Mapping__mdt> mappings, String environmentName) {
        Environment_Credential_Mapping__mdt environmentMapping;
        Environment_Credential_Mapping__mdt defaultMapping;
        for(Environment_Credential_Mapping__mdt mapping : mappings) {
            if(mapping.Environment_Name__c.equalsIgnoreCase(environmentName)) {
                environmentMapping = mapping;
                break;
            } else if(mapping.Environment_Name__c.equalsIgnoreCase(DEFAULT_ENVIRONMENT)) {
                defaultMapping = mapping;
            }
        }

        if(environmentMapping == null && defaultMapping != null) {
            environmentMapping = defaultMapping;
        }

        return environmentMapping;
    }

    @TestVisible
    private class NamedCredentialServiceException extends Exception {}
}