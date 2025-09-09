/**
 * The OrgUtilsTest class is responsible for unit testing the methods made available by the OrgUtils class
 * @log:
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Sergio Pedro         18/03/2025      Initial version
 * 
 * @author Sergio Pedro
 * @date 18/03/2025
 */
@IsTest
private class OrgUtilsTest {

    @IsTest
    public static void testIsSandbox_NoInput_Success() {
        // Set the organization to a sandbox environment
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];

        Test.startTest();
        Boolean isSandbox = OrgUtils.isSandbox();
        Test.stopTest();

        // Assert that the method returns true for a sandbox environment
        Assert.areEqual(org.IsSandbox, isSandbox, 'Organization type is not correctly identified');
    }

    @IsTest
    public static void testGenerateGUID_NoInput_success() {
        Test.startTest();
        String guid = OrgUtils.generateGUID();
        Test.stopTest();

        // Assert that the generated GUID is not empty and has the correct format
        Assert.isNotNull(guid, 'GUID is null');
        Assert.areEqual(36, guid.length(), 'GUID length is incorrect');
        Assert.isTrue(guid.contains('-'), 'GUID does not contain hyphens');
    }

    @IsTest
    private static void testGetUsernameForCompanySFSystemUser() {
        //ARRANGE
        Company_Settings__mdt companySFSystemUserSetting = 
            Company_Settings__mdt.getInstance(OrgUtils.COMPANY_SF_SYSTEM_USER_DEVELOPERNAME);
        String usernameFromCustomMetadata = companySFSystemUserSetting.Configuration_Value__c;
        String currentUsername = usernameFromCustomMetadata;
        Boolean runningInSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

        //ACT
		Test.startTest();

        String testUsername = OrgUtils.getUsernameForCompanySFSystemUser();

		Test.stopTest();
		
        //ASSERT
        if (runningInSandbox) {
            String sandboxName = DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName();
            currentUsername += '.' + sandboxName;
        }
        Assert.areEqual(currentUsername, testUsername, 'Username is not correct');
    }

    @IsTest
    private static void getCompanySettingsConfigurationValueByDeveloperName() {
        //ARRANGE
        List<Company_Settings__mdt> companySettingsList = Company_Settings__mdt.getAll().values();

        String expectedDeveloperName = '';
        String expectedConfigurationValue = '';

        if (!companySettingsList.isEmpty()) {
            // there is at least one item in the list, so get the first item
            expectedDeveloperName = companySettingsList[0].DeveloperName;
            expectedConfigurationValue = companySettingsList[0].Configuration_Value__c;
            System.debug('expectedDeveloperName: ' + expectedDeveloperName);
            System.debug('expectedConfigurationValue: ' + expectedConfigurationValue);
        }

        //ACT
		Test.startTest();

        String testConfigurationValue = OrgUtils.getCompanySettingsConfigurationValueByDeveloperName(expectedDeveloperName);

		Test.stopTest();
		
        //ASSERT
        Assert.areEqual(expectedConfigurationValue, testConfigurationValue, 'Configuration value is not correct');
    }

    @IsTest
    static void testClearOrgConfigurationCache() {
        // Set up test data
        OrgUtils.getUsernameForCompanySFSystemUser();

        // Call the method to be tested
        Test.startTest();
        OrgUtils.clearOrgConfigurationCache();
        Test.stopTest();

        // Verify that the cache has been cleared
        System.assertEquals(null, OrgUtils.orgConfig.get(OrgUtils.COMPANY_SF_SYSTEM_USER_DEVELOPERNAME), 'Cache should be cleared');
    }
}