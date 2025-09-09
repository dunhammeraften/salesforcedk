@IsTest
private class ErrorLogging_Test {
	@IsTest
    private static void addingToListAndControlersInsertAtTheEnd(){
        String testErrorText = 'Test Error Text Lorem Ipsum Parolem', testAddInfo = 'Error happened in some class', startOriginName = 'Apex', switchOriginName = 'Flow', defoultOrigin = 'Not defined';
        ErrorLogging withOriginSetUp = new ErrorLogging( startOriginName ), WithOutOriginSetUp = new ErrorLogging();
        
        withOriginSetUp.addError( testErrorText, testAddInfo );
        withOriginSetUp.addError( testErrorText, testAddInfo, switchOriginName );
        
        WithOutOriginSetUp.addError( testErrorText, testAddInfo );
        WithOutOriginSetUp.addError( testErrorText, testAddInfo, switchOriginName );
        
        System.assertEquals( 2, withOriginSetUp.listOfLogs.size(), 'Number of record for set up origin is wrong.');
        System.assertEquals( 2, WithOutOriginSetUp.listOfLogs.size(), 'Number of record for not set up origin is wrong.');
        
        for( System_Log__c singleLog : withOriginSetUp.listOfLogs ){
            System.assertEquals( testErrorText, singleLog.Error_Body__c, 'The error text body is incorect.');
            if( singleLog.Origin__c != startOriginName ) System.assertEquals( switchOriginName, singleLog.Origin__c, 'The origin should be Flow.');
            else System.assertEquals( startOriginName, singleLog.Origin__c, 'The origin should be Apex.');
        }        
        for( System_Log__c singleLog : WithOutOriginSetUp.listOfLogs ){
            System.assertEquals( testErrorText, singleLog.Error_Body__c, 'The error text body is incorect.');
            if( singleLog.Origin__c != defoultOrigin ) System.assertEquals( switchOriginName, singleLog.Origin__c, 'The origin should be Flow.');
            else System.assertEquals( defoultOrigin, singleLog.Origin__c, 'The origin should be "Not defined".');
        }
        
        withOriginSetUp.logErrors();
        WithOutOriginSetUp.logErrors();
        
        List<System_Log__c> theLogs = [SELECT Id FROM System_Log__c];
        System.assertEquals( 4, theLogs.size(), 'Number of inserted logs is not correct');
    }
}