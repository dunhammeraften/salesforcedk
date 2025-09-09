global class myMilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {   
     global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Case c = [SELECT Special_Delivery_date_milestone_timer__c FROM Case WHERE Id=:caseId];
        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
        if (c.Special_Delivery_date_milestone_timer__c> 0)
             {return c.Special_Delivery_date_milestone_timer__c.intValue();}
        else {return 0;}
        }                
     }