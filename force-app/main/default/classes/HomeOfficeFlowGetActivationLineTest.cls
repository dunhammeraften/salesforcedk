/**
 * 
 * @author keh
 * @since 14032025
 */
@IsTest
private class HomeOfficeFlowGetActivationLineTest {

    /**
     * getActivationLine_validInput_returnsCorrectResult
     */
    @IsTest
    static void getActivationLine_validInput_returnsCorrectResult() {
        //ARRANGE
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner();
        insert acc;

        // Create test data
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Qualification';
        opp.CloseDate = date.today();
        opp.AccountId = acc.Id;
        insert opp;
        
        Location_Line__c locationLine1 = new Location_Line__c(Opportunity__c = opp.id);
        Location_Line__c locationLine2 = new Location_Line__c(Opportunity__c = opp.id);
        Location_Line__c locationLine3 = new Location_Line__c(Opportunity__c = opp.id);
        insert new List<Location_Line__c>{locationLine1, locationLine2, locationLine3};
        
        Case case1 = new Case();
        insert case1;
            
       	Activation__c activation1 = new Activation__c(Case__c = case1.id);
        insert activation1;
            
        Activation_Line__c activationLine1 = new Activation_Line__c(Location_Line__c = locationLine1.Id, Activation__c = activation1.id);
        Activation_Line__c activationLine2 = new Activation_Line__c(Location_Line__c = locationLine2.Id, Activation__c = activation1.id);
        Activation_Line__c activationLine3 = new Activation_Line__c(Location_Line__c = locationLine3.Id, Activation__c = activation1.id);
        insert new List<Activation_Line__c>{activationLine1, activationLine2, activationLine3};

        List<Id> processedActivationLineIds = new List<Id>();
        processedActivationLineIds.add(activationLine1.Id);

        List<HomeOfficeFlowGetActivationLine.InputVariables> inputVariablesList = new List<HomeOfficeFlowGetActivationLine.InputVariables>();
        HomeOfficeFlowGetActivationLine.InputVariables inputVariables = new HomeOfficeFlowGetActivationLine.InputVariables();
        inputVariables.activationLines = new List<Activation_Line__c>{activationLine1, activationLine2, activationLine3};
        inputVariables.processedActivationLineIds = processedActivationLineIds;
        inputVariables.agreementType = 'Framework';
        inputVariables.selectionRecordId = activationLine2.Location_Line__c;
        inputVariablesList.add(inputVariables);

        //ACT
        // Call the method
        Test.startTest();
        List<HomeOfficeFlowGetActivationLine.OutputVariables> output = HomeOfficeFlowGetActivationLine.getActivationLine(inputVariablesList);
        Test.stopTest();

        //ASSERT
        // Verify the output
        System.assertEquals(1, output.size(), 'Expected one output record');
        Activation_Line__c selectedActivationLine = output[0].activationLine;
        System.assertEquals(activationLine2.Id, selectedActivationLine.Id, 'Unexpected activation line selected');
    }
}