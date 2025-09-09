/**
 * 
 * @author keh
 * @since 14032025
 */
@isTest
public class AddressAutocompleteTest {

    /**
     * uploadLines_validInput_resultsInCorrectLines
     */
    @isTest
    public static void uploadLines_validInput_resultsInCorrectLines() {
        
        //ARRANGE
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner();
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Name', 
            StageName = 'Qualification', 
            CloseDate = Date.today(),
            AccountId = acc.Id
        );
        insert opp;
        
        Location_Line__c line = new Location_Line__c(
            City__c = 'Test City',
            Door__c = 'Test Door',
            Floor__c = 'Test Floor',
            Number__c = 'Test Number',
            Street_Name__c = 'Test Street',
            ZIP_Code__c = 'Test Zip',
            Opportunity__c = opp.Id
        );
        List<Location_Line__c> linesToInsert = new List<Location_Line__c>{ line };
        String jsonData = JSON.serialize(linesToInsert);
        
        //ACT
        Test.startTest();
        AddressAutocomplete.uploadLines(jsonData);
        Test.stopTest();
        
        //ASSERT
        List<Location_Line__c> insertedLines = [
            SELECT Id, City__c, Door__c, Floor__c, Number__c, Street_Name__c, ZIP_Code__c
            FROM Location_Line__c
        ];
        System.assertEquals(1, insertedLines.size(), 'Expected one line to be inserted');
        
        Location_Line__c insertedLine = insertedLines[0];
        System.assertEquals(line.City__c, insertedLine.City__c, 'City should match');
        System.assertEquals(line.Door__c, insertedLine.Door__c, 'Door should match');
        System.assertEquals(line.Floor__c, insertedLine.Floor__c, 'Floor should match');
        System.assertEquals(line.Number__c, insertedLine.Number__c, 'Number should match');
        System.assertEquals(line.Street_Name__c, insertedLine.Street_Name__c, 'Street should match');
        System.assertEquals(line.ZIP_Code__c, insertedLine.ZIP_Code__c, 'Zip should match');
    }
}