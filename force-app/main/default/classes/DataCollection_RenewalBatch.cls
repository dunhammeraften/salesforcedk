public class DataCollection_RenewalBatch implements Database.Batchable<sObject> {
	public String query;
	public Database.querylocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		try {
			system.debug('start batch' + scope);
			SBQQ__Quote__c Quote_record = (SBQQ__Quote__c) scope[0];

			String quoteId = String.valueOf(Quote_record.Id);
			String quoteAccount = String.valueOf(Quote_record.SBQQ__Account__c);
			system.debug('start quote Id' + quoteId);
			system.debug('start quote Account' + quoteAccount);
			Map<String, String> TouchpointProducts = new Map<String, String>();
			//FieldName,ProductCode
			TouchpointProducts.put('Touchpoint_Bruger__c', 'TPSUSER');
			TouchpointProducts.put('Touchpoint_Receptionist__c', 'TPSRECEP');
			TouchpointProducts.put('Touchpoint_Softphone__c', 'TPSSOFT');
			TouchpointProducts.put('Touchpoint_Statistik__c', 'TPSSTAT');

			List<String> lstServices;
			List<Activation_line__c> ActivationLines = new List<Activation_line__c>();
			Activation_line__c ActivationLine = new Activation_line__c();

			List<Fokus_Subscription__c> Fokus_Subscription_list = [
				SELECT
					AVG_MONTHLY_DATA_CONSUMPTION_MB__c,
					BAN__c,
					BAN_OWNER_CONTROL_NUA__c,
					BILLING_CITY__c,
					BILLING_COUNTRY__c,
					BILLING_NAME__c,
					BILLING_POSTAL_CODE__c,
					BILLING_STREET_NO__c,
					BROADBAND_NO__c,
					CALLS_FROM_DK_TO_EUNB_MIN__c,
					COMPANY_NAME__c,
					CUSTOMER_CURRENT_KEY__c,
					CVR_NO__c,
					DISCOUNT__c,
					EAN_NUMBER__c,
					EXISTING_SIM__c,
					EXTRA_SIM_NUMBER__c,
					FIRST_NAME__c,
					FIX_NO__c,
					INVOICE_EMAIL__c,
					LAST_NAME__c,
					LOOKUP_MOBILE_USER__c,
					MAX_MONTHLY_DATA_CONSUMPTION_MB__c,
					Name,
					ORDER_PRODUCT__c,
					MOBILE_NO__c,
					OWNER_CONTROL_NUA__c,
					OWNER_CONTROL_RCC__c,
					OWNER_CONTROL_TSRR__c,
					ROOT_CVR_NO__c,
					SERVICE_CODE__c,
					SF_ACCOUNT_KEY__c,
					SUBSCRIBER_CURRENT_KEY__c,
					SUBSCRIBER_EMAIL__c,
					SUBSCRIBER_ID__c,
					SUBSCRIBER_NO__c
				FROM Fokus_Subscription__c
				WHERE SF_ACCOUNT_KEY__c = :quoteAccount
				ORDER BY ORDER_PRODUCT__c DESC
			];

			//Query the VAS services list
			Schema.DescribeSObjectResult activationline_desc = Activation_line__c.sObjectType.getDescribe();

			Map<String, Schema.SObjectField> activationline_fields = activationline_desc.fields.getMap();
			Map<String, String> Vasfields = new Map<String, String>();
			Map<String, List<String>> M2MPicklistProducts = new Map<String, List<String>>();
			//FieldName,FieldValue

			String columnNames = 'Id';

			for (Schema.sObjectField fld : activationline_fields.values()) {
				if (string.valueof(fld).indexOf('VAS_') == 0) {
					if (fld.getDescribe().getType().name().toupperCase() == 'BOOLEAN') {
						columnNames = columnNames + ',' + fld.getDescribe().getName();
					}
					Vasfields.put(fld.getDescribe().getName(), fld.getDescribe().getType().name().toupperCase());
					if (fld.getDescribe().getType().name().toupperCase() == 'PICKLIST') {
						List<String> lstPickvals = new List<String>();
						List<Schema.PicklistEntry> pick_list_values = fld.getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
						for (Schema.PicklistEntry a : pick_list_values) {
							//for all values in the picklist list
							lstPickvals.add(a.getValue()); //add the value  to our final list
						}
						M2MPicklistProducts.put(fld.getDescribe().getName(), lstPickvals); //add the value  to our final list
					}
				}
			}
			system.debug('quote id before soql ' + quoteId);

			List<Activation_line__c> ActivationLinesSelected = [
				SELECT
					Id,
					Mobile_no__c,
					First_name__c,
					Last_name__c,
					Phone_no__c,
					Touchpoint_Bruger__c,
					Touchpoint_Receptionist__c,
					Touchpoint_Softphone__c,
					Touchpoint_Statistik__c,
					Max_Monthly_Data_Used__c,
					Avg_Monthly_Data_Used__c,
					Calls_from_DK_to_EU__c,
					Case__c,
					Activation__c
				FROM Activation_line__c
				WHERE Activation__r.Case__r.Quote__c = :quoteId
			];
			system.debug('act lines ' + ActivationLinesSelected);

			integer i = 0;
			string service_name;
			string strServices = '';
			system.debug('act lines ' + ActivationLinesSelected);
			for (Activation_line__c ActivationLineRecord : ActivationLinesSelected) {
				ActivationLine.id = String.valueOf(ActivationLineRecord.Id);
				ActivationLine.Mobile_no__c = String.valueOf(Fokus_Subscription_list[i].MOBILE_NO__c);
				ActivationLine.First_name__c = Fokus_Subscription_list[i].FIRST_NAME__c;
				ActivationLine.Last_name__c = Fokus_Subscription_list[i].LAST_NAME__c;
				ActivationLine.Email_address__c = Fokus_Subscription_list[i].SUBSCRIBER_EMAIL__c;
				ActivationLine.Phone_no__c = String.valueOf(Fokus_Subscription_list[i].FIX_NO__c);
				ActivationLine.Existing_SIM_number__c = Fokus_Subscription_list[i].EXISTING_SIM__c;
				ActivationLine.Max_Monthly_Data_Used__c = Fokus_Subscription_list[i].MAX_MONTHLY_DATA_CONSUMPTION_MB__c;
				ActivationLine.Avg_Monthly_Data_Used__c = Fokus_Subscription_list[i].AVG_MONTHLY_DATA_CONSUMPTION_MB__c;
				ActivationLine.Calls_from_DK_to_EU__c = Fokus_Subscription_list[i].CALLS_FROM_DK_TO_EUNB_MIN__c;
				if (string.isNotBlank(String.valueOf(Fokus_Subscription_list[i].SERVICE_CODE__c))) {
					strServices = Fokus_Subscription_list[i].SERVICE_CODE__c;
					lstServices = Fokus_Subscription_list[i].SERVICE_CODE__c.split(',');
				}

				//Touchpoint assignments
				for (string key : TouchpointProducts.keySet()) {
					if (strServices.indexOf(TouchpointProducts.get(key)) >= 0) {
						ActivationLine.put(key, true);
					}
				}
				system.debug('M2MPicklistProducts:' + M2MPicklistProducts);
				//Picklist VAS assignments
				if (String.isNotBlank(strServices)) {
					for (string key : M2MPicklistProducts.keySet()) {
						for (String M2MPicklistVal : M2MPicklistProducts.get(key)) {
							if (strServices.indexOf(M2MPicklistVal) >= 0) {
								ActivationLine.put(key, M2MPicklistVal);
								system.debug(key);
								system.debug(M2MPicklistVal);
							}
						}
					}

					//VAS assignments
					for (String service_record : lstServices) {
						if (columnNames.indexOf(service_record) >= 0) {
							service_name = 'VAS_' + service_record + '__c';
							ActivationLine.put(service_name, true);
						}
					}
				}

				ActivationLines.add(ActivationLine);
				ActivationLine = new Activation_line__c();
				i = i + 1;
			}

			update ActivationLines;
			system.debug(ActivationLines);

			//Create a notification
			CustomNotificationType notificationType = [
				SELECT Id, DeveloperName
				FROM CustomNotificationType
				WHERE DeveloperName = 'Case_notifications'
			];

			Messaging.CustomNotification notification = new Messaging.CustomNotification();
			notification.setTitle('Renewal Quote is ready');
			notification.setBody('The renewal quote is ready for you to review');

			notification.setNotificationTypeId(notificationType.Id);
			notification.setTargetId(quoteId);
			set<String> recipientsIds = new Set<String>{ UserInfo.getUserId() };
			notification.send(recipientsIds);

			//Update the Activation Progress status as Cancelled
			Activation__c RenewalActivation = new Activation__c();

			if (ActivationLinesSelected.size() > 0) {
				RenewalActivation.Id = ActivationLinesSelected[0].Activation__c;
				RenewalActivation.Activation_progress__c = 'Fulfilled';
				RenewalActivation.Actual_Delivery_date__c = Date.today();
				RenewalActivation.SLA_due_date__c = null;
				update RenewalActivation;
			}

			//Update Case status ac Case Close -- ActivationLinesSelected[0].Case__c
			Case RenewalCase = new Case();
			if (ActivationLinesSelected.size() > 0) {
				RenewalCase.Id = ActivationLinesSelected[0].Case__c;
				RenewalCase.Status = 'Close case';
				RenewalCase.Power_of_attorney__c = 'Received and attached to case';
				update RenewalCase;
			}
		} catch (Exception e) {
		}
	}
	public void finish(Database.BatchableContext BC) {
	}
}