public class OpportunityTriggerHandler extends TriggerHandler{
    /**
     * Singleton instance of the OpportunityService
     */
    private final OpportunityService opportunityService;


    /**
     * Collection of newly inserted Opportunity records from the trigger context
     */
    private List<Opportunity> newOpportunities;
    
    /**
     * Collection of previosuly Opportunity records from the trigger context
     */
    private Map<Id, Opportunity> oldOpportunitiesMap;

    @TestVisible
    private OpportunityTriggerHandler(OpportunityService opportunityService) {
        this.opportunityService = opportunityService;
    }

    public OpportunityTriggerHandler() {
        this(SingletonFactory.getFactory());
    }

    public OpportunityTriggerHandler(SingletonFactory singletonFactory) {
        this.opportunityService = (OpportunityService) singletonFactory.getOrRegisterSingleton(OpportunityService.class);
        this.newOpportunities = (List<Opportunity>) Trigger.new;
        this.oldOpportunitiesMap = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    public override void afterUpdate() {
        Logger.logInfo('afterUpdate()');

        List<String> qualifyingOpportunityIds = opportunityService.getOpportunitesForProductOfferingQualification(newOpportunities, oldOpportunitiesMap);

        if(!qualifyingOpportunityIds.isEmpty()){
            opportunityService.enqueueOpportunitesForProductOfferingQualification(qualifyingOpportunityIds);
        }

        List<Opportunity> opportunitiesWithLocationLinesReadyToProcess = opportunityService.getOpportunitesWithProcessedQualification(newOpportunities, oldOpportunitiesMap);

        if(!opportunitiesWithLocationLinesReadyToProcess.isEmpty()){
            opportunityService.processLocationLineItemsByOpportunitys(opportunitiesWithLocationLinesReadyToProcess);
        }
    }
}