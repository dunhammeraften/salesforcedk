/**
 * @description This class is a selector for the Activation_line__c object.
 * It provides methods to query for activation lines based on different criteria.
 *  -----------------------------------------------------------------------------
 *  Developer               Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         2025-08-19      Initial version.
 *  Kirstine Nielsen        2025-08-21      Add field to query Mobile_no__c in getActivationLinesByIds method.
 *
 * @author Kenneth Houkjær
 * @date 2025-08-19
 */
public with sharing class ActivationLineSelector {
	public static final String RECORD_TYPE_HOME_OFFICE_ACTIVATION_LINE = 'Home_office_activation_line';

	/**
	 * @description Retrieves a list of activation lines by case Id.
	 * @param caseId The Id of the case.
	 * @return A list of Activation_line__c records.
	 */
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

	/**
	 * @description Retrieves a list of activation lines by case Id with extra columns.
	 * @param caseId The Id of the case.
	 * @param extracolumns A string of extra columns to query.
	 * @return A list of Activation_line__c records.
	 */
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

	/**
	 * @description Retrieves a list of business internet activation lines by case Id.
	 * @param caseId The Id of the case.
	 * @return A list of Activation_line__c records.
	 */
	@AuraEnabled(cacheable=true)
	public static List<Activation_line__c> getBusinessInternetActivationLinesByCaseId(String caseId) {
		if (String.isBlank(caseId)) {
			return new List<Activation_line__c>();
		}

		return [
			SELECT
				Id,
				Name,
				Line_ID__c,
				Location__c,
				Product__c,
				Billing_Account_Name_For_Portal__c,
				Full_name__c,
				Email__c,
				Onsite_Contact_Mobile__c
			FROM Activation_line__c
			WHERE Activation__r.Case__c = :caseId
			ORDER BY CreatedDate DESC
		];
	}

	/**
	 * @description Retrieves a list of activation lines by activation Id.
	 * @param activationId The Id of the activation.
	 * @return A list of Activation_line__c records.
	 */
	@AuraEnabled(cacheable=true)
	public static List<Activation_line__c> getActivationLinesByActivationId(String activationId) {
		if (String.isBlank(activationId)) {
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
	 * @description Returns a list of billing account names and the number of times they have been subscribed to.
	 * @param activationId The Id of the activation.
	 * @return A list of AggregateResult records.
	 */
	public static List<AggregateResult> getBillingAccountsBySubscriptionCount(String activationId) {
		List<AggregateResult> results = new List<AggregateResult>();

		if (String.isBlank(activationId)) {
			return results;
		}

		for (AggregateResult activationLine : [
			SELECT Billing_Account__r.Billing_Name__c billingAccountName, count(Id) subscriptionCount
			FROM Activation_line__c
			WHERE
				Billing_Account__c != NULL
				AND Activation__c = :activationId
				AND (Manual_Product__r.Onboarding_Configuration__c INCLUDES ('ShowInBillingAccountSummary')
				OR Order_Product__r.Product2.Onboarding_Configuration__c INCLUDES ('ShowInBillingAccountSummary'))
			GROUP BY Billing_Account__r.Billing_Name__c
		]) {
			results.add(activationLine);
		}
		return results;
	}

	/**
	 * @description Retrieves a map of voice product status lines.
	 * @param activationLines A list of activation lines.
	 * @return A map of Activation_line__c records keyed by their Id.
	 */
	public static Map<Id, Activation_line__c> getMapOfVoiceProductStatusLines(List<Activation_line__c> activationLines) {
		if (activationLines == null || activationLines.isEmpty()) {
			return new Map<Id, Activation_line__c>();
		}

		Map<Id, Activation_line__c> mapOfActivationLines = new Map<Id, Activation_line__c>(
			[
				SELECT id, Billing_Account__r.Billing_Name__c, Phone_no_Status__c, Product__c
				FROM Activation_line__c
				WHERE
					id IN :activationLines
					AND Phone_no_Status__c != NULL
					AND (Manual_Product__r.Onboarding_Configuration__c INCLUDES ('ShowInSubscriptionSummary')
					OR Order_Product__r.Product2.Onboarding_Configuration__c INCLUDES ('ShowInSubscriptionSummary'))
			]
		);

		return mapOfActivationLines;
	}

	/**
	 * @description Retrieves a list of activation lines by their Ids.
	 * @param activationLineIds A set of activation line Ids.
	 * @return A list of Activation_line__c records.
	 */
	public static List<Activation_line__c> getActivationLinesByIds(Set<Id> activationLineIds) {
		if (activationLineIds == null || activationLineIds.isEmpty()) {
			return new List<Activation_line__c>();
		}

		return [
			SELECT
				Name,
				Activation__c,
				BAN__c,
				Billing_Account__c,
				Case__c,
				City__c,
				Door__c,
				Email_address__c,
				Email__c,
				First_name__c,
				Floor__c,
				Last_name__c,
				Line_ID__c,
				Mobile_no__c,
				Number__c,
				Onsite_Contact_Mobile__c,
				Street_Name__c,
				ZIP_Code__c,
				Product__c,
				Activation__r.Case__r.AccountId
			// Manual_Product__r.Product_Group__c,
			// Manual_Product__r.Name,
			FROM Activation_line__c
			WHERE Id IN :activationLineIds
		];
	}

	/**
	 * @description Retrieve Activation Line records by Opportunity Id where record type is Home_office_activation_line.
	 * @param opportunityIdSet A set of Opportunity Ids.
	 * @return A list of Activation_line__c records.
	 */
	public static List<Activation_line__c> getHomeOfficeActivationLinesByOpportunityIds(Set<Id> opportunityIdSet) {
		return [
			SELECT
				Id,
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
			WHERE
				Opportunity_ID__c IN :opportunityIdSet
				AND RecordType.DeveloperName = :RECORD_TYPE_HOME_OFFICE_ACTIVATION_LINE
		];
	}

	/**
	 * @description Retrieves a map of activation lines by their Ids.
	 * @param activationLineIds A set of activation line Ids.
	 * @return A map of Activation_line__c records keyed by their Id.
	 */
	public static Map<Id, Activation_line__c> getMapOfActivationLinesByIds(Set<Id> activationLineIds) {
		if (activationLineIds == null || activationLineIds.isEmpty()) {
			return new Map<Id, Activation_line__c>();
		}

		return new Map<Id, Activation_line__c>(
			[
				SELECT Id, Mobile_No__c
				FROM Activation_line__c
				WHERE Id IN :activationLineIds
			]
		);
	}

	public static List<AggregateResult> getActivationLineCountsByQuoteLineIds(List<Id> listOfQuoteLineIds) {
		return new Query('activation_line__c')
			.selectField('Manual_Product__c')
			.count('Id', 'quantity')
			.addConditionIn('Quote_line__c', listOfQuoteLineIds)
			.groupBy('Manual_Product__c')
			.aggregate();
	}
}
