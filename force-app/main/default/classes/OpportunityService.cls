public class OpportunityService {
    private final OpportunitySelector opportunitySelector;

    @TestVisible
    private OpportunityService(OpportunitySelector opportunitySelector) {
        this.opportunitySelector = opportunitySelector;
    }

    public OpportunityService() {
        this(SingletonFactory.getFactory());
    }

    private OpportunityService(SingletonFactory singletonFactory) {
        this.opportunitySelector = (OpportunitySelector) singletonFactory.getOrRegisterSingleton(OpportunitySelector.class);
    }

    public List<String> getOpportunitesForProductOfferingQualification(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunitiesMap){
        Logger.logInfo(String.format('getOpportunitesForProductOfferingQualification( {0} )', new List<Object>{newOpportunities, oldOpportunitiesMap}));

        List<String> qualifyingOpportunityIds = new List<String>();
        
        // Iterate through the updated Opportunities
        for(Opportunity newOpportunity : newOpportunities){
            Opportunity oldOpportunity = oldOpportunitiesMap.get(newOpportunity.Id);

            // Check if the Product Qualification Status has changed to "Ready"
			if (newOpportunity.POQ_Status__c == 'Ready' && oldOpportunity.POQ_Status__c != 'Ready' ) {
				qualifyingOpportunityIds.add(newOpportunity.Id);
			}
        }

        return qualifyingOpportunityIds;
    }

    public List<Opportunity> getOpportunitesWithProcessedQualification(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunitiesMap){
        Logger.logInfo(String.format('getOpportunitesWithProcessedQualification( {0} )', new List<Object>{newOpportunities, oldOpportunitiesMap}));
        
        List<Opportunity> qualifyingOpportunityIds = new List<Opportunity>();
        
        // Iterate through the updated Opportunities
        for(Opportunity newOpportunity : newOpportunities){
            Opportunity oldOpportunity = oldOpportunitiesMap.get(newOpportunity.Id);

            // Check if the Product Qualification Status has changed to "Ready"
			if (newOpportunity.POQ_Status__c == 'Done' && oldOpportunity.POQ_Status__c != 'Done' ) {
				qualifyingOpportunityIds.add(newOpportunity);
			}
        }

        return qualifyingOpportunityIds;
    }

    public void enqueueOpportunitesForProductOfferingQualification(List<String> opportunityIds){
        Logger.logInfo(String.format('enqueueOpportunitesForProductOfferingQualification( {0} )', new List<Object>{opportunityIds}));
        if(opportunityIds.isEmpty()){
            return;
        }

        List<Location_Line__c> locationLines = opportunitySelector.getLocationLinesByOpportunityIds(opportunityIds);
        
		//We have at least one opportunity and locationline to process. The QueueablePOQ handles the processing.
		if (!locationLines.isEmpty()) {
			QueueablePOQ job = new QueueablePOQ(opportunityIds);
			System.enqueueJob(job);
		}
    }

    public void processLocationLineItemsByOpportunitys(List<Opportunity> opportunitys){
        Logger.logInfo(String.format('processLocationLineItemsByOpportunity( {0} )', new List<Object>{opportunitys}));
        if(opportunitys.isEmpty()){
            return;
        }

        UpdateLocationLines.finalUpdate(opportunitys);
    }
}