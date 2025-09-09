@isTest 
private class MilestoneTimeCalculatorTest {
    static testMethod void testMilestoneTimeCalculator() {        
      
        // Select an existing milestone type to test with
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        
        // Create case data.
        // Typically, the milestone type is related to the case, 
        // but for simplicity, the case is created separately for this test.
        Case c = new Case(priority = 'High');
        insert c;
        
        myMilestoneTimeCalculator calculator = new myMilestoneTimeCalculator();
        Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(c.Id, mt.Id);
        
        if(mt.name != null && mt.Name.equals('Express')) {
            System.assertEquals(actualTriggerTime, 7);
        }
        else {
            System.assertEquals(actualTriggerTime, 0);
        }
        
        c.priority = 'Low';
        update c;
        actualTriggerTime = calculator.calculateMilestoneTriggerTime(c.Id, mt.Id);
        System.assertEquals(actualTriggerTime, 0);
    }
}