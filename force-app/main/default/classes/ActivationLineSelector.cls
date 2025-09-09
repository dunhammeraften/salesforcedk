public with sharing class ActivationLineSelector {

	public static final String RECORD_TYPE_HOME_OFFICE_ACTIVATION_LINE = 'Home_office_activation_line';

	@AuraEnabled(cacheable=true)
	public static List<Activation_line__c> getActivationLinesByCaseId(String caseId) {
		return [
			SELECT
				Name,
				VAS_SIMBTB2__c,
				VAS_SIMBX2__c,
				VAS_SIMBX3__c,
				VAS_SIMBX4__c,
				VAS_SIMBTB11__c,
				VAS_SIMBX5__c,
				VAS_SIMBX6__c,
				VAS_SIMBX7__c,
				Power_of_Attorney_record__c,
				Product__c,
				Case__c,
				First_name__c,
				BAN__c,
				Planned_delivery_date__c,
				Modified_delivery_date__c,
				Last_name__c,
				Email_address__c,
				SIM_number__c,
				Services__c,
				EAN_number__c,
				Number_Porting_Specific_Date__c,
				Phone_no_Status__c,
				Manual_Product__r.ProductAPI_Telia_Product_Id__c,
				Delivery_Email__c,
				Ekstra_Data_SIM_number__c,
				Existing_SIM_number__c,
				Mobile_no__c,
				Actual_delivery_date__c,
				Invoice_Type__c,
				Delivery_Street_and_number__c,
				Delivery_Att__c,
				Number_Porting_End_of_Commitment__c,
				Telia_INSIGHT_e_mail_contact__c,
				Manual_Product__r.Product_Group__c,
				Manual_Product__r.Name,
				Funktionsnr__c
			FROM Activation_line__c
			WHERE Activation__r.Case__c = :caseId AND Not_to_Activation__c = FALSE
		];
	}

	public static List<Activation_line__c> getActivationLinesByCaseId(String caseId, String extracolumns) {
		return Database.query(
			'SELECT ' +
				extracolumns +
				',Name, Product__c, Case__c, First_name__c, BAN__c , Manual_Product__r.Name , ' +
				' Manual_Product__r.ProductAPI_Telia_Product_Id__c, Manual_Product__c,  ' +
				' Touchpoint_Bruger__c, Touchpoint_Receptionist__c ,Touchpoint_Softphone__c, Touchpoint_Statistik__c  ' +
				' FROM Activation_line__c WHERE Activation__r.Case__r.Id= :caseId and Not_to_Activation__c = false ' +
				' order by BAN__c'
		);
	}

	@AuraEnabled(cacheable=true)
	public static List<Activation_line__c> getBusinessInternetActivationLinesByCaseId(String caseId) {
		if(String.isBlank(caseId)){
			return new List<Activation_line__c>();
		}
		
		return [SELECT Id, Name, Line_ID__c, Location__c, Product__c, Billing_Account_Name_For_Portal__c, Full_name__c, Email__c, Onsite_Contact_Mobile__c FROM Activation_line__c WHERE Activation__r.Case__c = :caseId ORDER BY CreatedDate DESC];
	}

	@AuraEnabled(cacheable=true)
	public static List<Activation_line__c> getActivationLinesByActivationId(String activationId) {
		if(String.isBlank(activationId)){
			return new List<Activation_line__c>();
		}
		
		return [
			SELECT
				Name,
				VAS_SIMBTB2__c,
				VAS_SIMBX2__c,
				VAS_SIMBX3__c,
				VAS_SIMBX4__c,
				VAS_SIMBTB11__c,
				VAS_SIMBX5__c,
				VAS_SIMBX6__c,
				VAS_SIMBX7__c,
				Power_of_Attorney_record__c,
				Product__c,
				Case__c,
				First_name__c,
				BAN__c,
				Billing_Account__c,
				Planned_delivery_date__c,
				Modified_delivery_date__c,
				Last_name__c,
				Email_address__c,
				SIM_number__c,
				Services__c,
				EAN_number__c,
				Number_Porting_Specific_Date__c,
				Phone_no_Status__c,
				Manual_Product__r.ProductAPI_Telia_Product_Id__c,
				Delivery_Email__c,
				Ekstra_Data_SIM_number__c,
				Existing_SIM_number__c,
				Mobile_no__c,
				Actual_delivery_date__c,
				Invoice_Type__c,
				Delivery_Street_and_number__c,
				Delivery_Att__c,
				Number_Porting_End_of_Commitment__c,
				Telia_INSIGHT_e_mail_contact__c,
				Manual_Product__r.Product_Group__c,
				Manual_Product__r.Name,
				Funktionsnr__c
			FROM Activation_line__c
			WHERE Activation__c = :activationId AND Not_to_Activation__c = FALSE
		];
	}

	/**
	 * Returns a list of billing account names and the number of times they have been subscribed to
	 * 
	 * @param activationId 
	 * @return  `List<AggregateResult>`
	 */
	public static List<AggregateResult> getBillingAccountsBySubscriptionCount(String activationId) {
		List<AggregateResult> results = new List<AggregateResult>();

		if(String.isBlank(activationId)){
			return results;
		}

		for (AggregateResult activationLine : [
			SELECT Billing_Account__r.Billing_Name__c billingAccountName, count(Id) subscriptionCount
			FROM Activation_line__c
			WHERE
			 Billing_Account__c != null AND  
			 Activation__c = :activationId
			AND (
				Manual_Product__r.Onboarding_Configuration__c INCLUDES ('ShowInBillingAccountSummary')
				OR Order_Product__r.Product2.Onboarding_Configuration__c INCLUDES ('ShowInBillingAccountSummary')
			)
			GROUP BY Billing_Account__r.Billing_Name__c
		]) {
			results.add(activationLine);
		}
		return results;
	}

	public static Map<Id, Activation_line__c> getMapOfVoiceProductStatusLines(List<Activation_line__c> activationLines){
		if(activationLines == null || activationLines.isEmpty()){
			return new Map<Id, Activation_line__c>();
		}
		
		Map<Id, Activation_line__c> mapOfActivationLines = new Map<Id, Activation_line__c>([					
		SELECT id, 
				Billing_Account__r.Billing_Name__c, 
				Phone_no_Status__c,
				Product__c			
		FROM Activation_line__c 
		WHERE id IN :activationLines
		AND Phone_no_Status__c != null
		AND (
			Manual_Product__r.Onboarding_Configuration__c INCLUDES ('ShowInSubscriptionSummary')	
			OR Order_Product__r.Product2.Onboarding_Configuration__c INCLUDES ('ShowInSubscriptionSummary')
		)]);

		return mapOfActivationLines;
	}

	public static List<Activation_line__c> getActivationLinesByIds(Set<Id> activationLineIds) {	
		if(activationLineIds == null || activationLineIds.isEmpty()){
			return new List<Activation_line__c>();
		}
		
		return [
			SELECT
				Name,
				Product__c,
				Case__c,
				First_name__c,
				BAN__c,
				Billing_Account__c,
				Last_name__c,
				Email_address__c,
				City__c,
				Email__c,
				Line_ID__c,
				Number__c, 
				Onsite_Contact_Mobile__c,
				Street_Name__c,
				ZIP_Code__c,
				Floor__c,
				Door__c
				// Manual_Product__r.Product_Group__c,
				// Manual_Product__r.Name,
			FROM Activation_line__c
			WHERE Id IN :activationLineIds
		];
	}	
	
	/**
	 * Retrieve Activation Line records by Opportunity Id where record type is Home_office_activation_line.
	 * 
	 * @param Set<Id> activationIdSet
	 * @return List<Activation_line__c>
	 */
	public static List<Activation_line__c> getHomeOfficeActivationLinesByOpportunityIds(Set<Id> opportunityIdSet) {
		return [
            SELECT Id, 
                Name,
                Activation__c,
                Active_Blocking_Line_Present__c,
                Employee_Number__c,
                Home_Office__c,
                Home_Office_OTC_Product__c,
                Home_Office_VAS_Product__c,
                Installation_address__c,
                Location_Line__c, 
                Manual_Product__c,
                Municipality_Code__c,
                Opportunity_ID__c, 
                plugPresentPositiveValidation__c,
                Plug_Technician_Required__c,
                Quote_line__c,
                Street_Code__c,
                VAS_CHXT01__c,
                VAS_CHXT02__c,
                VAS_CHXT03__c,
                VAS_CHXT04__c,
                VAS_CHXT05__c,
                VAS_CHXT06__c,
                VAS_CHXT07__c,
                VAS_CHXT08__c,
                VAS_CHXT11__c,
                VAS_CHXT12__c,
                VAS_FASTIP__c 
            FROM Activation_Line__c 
            WHERE Opportunity_ID__c IN :opportunityIdSet 
            AND RecordType.DeveloperName = :RECORD_TYPE_HOME_OFFICE_ACTIVATION_LINE
        ];	
	}
}