public class Activation_check {
	private static final String ERROR_ORIGIN = 'Apex';
	private static final String ERROR_ADDITIONAL_INFO = 'Activation_check';

	private static ErrorLogging errorLogging = new ErrorLogging(ERROR_ORIGIN);

	public string resultText { get; set; }
	public string recordId;
	Activation__c Activation_record;
	String QuoteId;

	public map<String, decimal> ActivationLineAvailability(string recordId) {
		try {
			list<Product2> ProductInfoList = [
				SELECT Name, Id, ProductAPI_Telia_Product_Id__c
				FROM Product2
				WHERE IsActive = TRUE AND Requires_Activation_Check__c = TRUE
			];
			Map<String, String> ALLProductNames = new Map<String, String>();
			//Name,ProductId
			for (Product2 pr : ProductInfoList) {
				ALLProductNames.put(pr.Name, pr.Id);
			}

			List<Activation__c> Activation_records = [
				SELECT Id, Case__r.Root_BAN__c, Case__r.Quote__c
				FROM Activation__c
				WHERE Id = :recordId
				LIMIT 1
			];
			if (Activation_records.size() <= 0) {
				resultText = 'Activation details can not be found with the Id value from:' + recordId;
				return null;
			} else {
				Activation_record = Activation_records[0];
			}

			list<Product2> VASProductInfoList = [
				SELECT Name, Id, ProductAPI_Telia_Product_Id__c
				FROM Product2
				WHERE IsActive = TRUE AND activate_with_other_products__c = TRUE AND Requires_Activation_Check__c = TRUE
			];
			Map<String, String> VasProducts = new Map<String, String>();
			//TeliaProductId,Id

			for (Product2 prVas : VASProductInfoList) {
				VasProducts.put(prVas.ProductAPI_Telia_Product_Id__c, prVas.Id);
			}

			//Query the VAS services list
			Schema.DescribeSObjectResult activationline_desc = Activation_line__c.sObjectType.getDescribe();

			Map<String, Schema.SObjectField> activationline_fields = activationline_desc.fields.getMap();
			Map<String, String> Vasfields = new Map<String, String>();
			String columnNames = 'Id';

			for (Schema.sObjectField fld : activationline_fields.values()) {
				if (string.valueof(fld).indexOf('VAS_') == 0) {
					columnNames = columnNames + ',' + fld.getDescribe().getName();
					Vasfields.put(fld.getDescribe().getName(), fld.getDescribe().getType().name().toupperCase());
				}
			}
			String ProductId;
			string VasName;
			//Query the ActivationLines
			List<Activation_line__c> Activation_line_list = Database.query(
				'SELECT ' +
					columnNames +
					',name, Product__c, Case__c, First_name__c, BAN__c , Manual_Product__r.Name , ' +
					' Manual_Product__r.ProductAPI_Telia_Product_Id__c, Manual_Product__c,  ' +
					' Touchpoint_Bruger__c, Touchpoint_Receptionist__c ,Touchpoint_Softphone__c, Touchpoint_Statistik__c ' +
					' FROM Activation_line__c WHERE Activation__c= :recordId and Not_to_Activation__c = false ' +
					' AND Manual_Product__r.Requires_Activation_Check__c = true  order by BAN__c'
			);

			//Loop through the activation lines
			Map<String, integer> ActivationLineProducts = new Map<String, integer>();
			integer quantity;
			boolean added = false;
			for (Activation_line__c ActivationLineData : Activation_line_list) {
				//START OF LOOPING ACTIVATION LINES
				//
				ProductId = ActivationLineData.Manual_Product__c;
				added = false;
				for (string key : ActivationLineProducts.keySet()) {
					if (key == ProductId) {
						quantity = ActivationLineProducts.get(ProductId) + 1;
						ActivationLineProducts.remove(ProductId);
						ActivationLineProducts.put(ProductId, quantity);
						added = true;
						break;
					}
				}
				if (added == false) {
					ActivationLineProducts.put(ProductId, 1);
				}

				added = false;

				//Touchpoint section
				if (ActivationLineData.Touchpoint_Bruger__c) {
					ProductId = ALLProductNames.get('Touchpoint Bruger');
					if (ActivationLineProducts.get(ProductId) > 0) {
						quantity = ActivationLineProducts.get(ProductId) + 1;
						ActivationLineProducts.remove(ProductId);
						ActivationLineProducts.put(ProductId, quantity);
					} else {
						ActivationLineProducts.put(ProductId, 1);
					}
				}
				if (ActivationLineData.Touchpoint_Receptionist__c) {
					ProductId = ALLProductNames.get('Touchpoint Receptionist');
					if (ActivationLineProducts.get(ProductId) > 0) {
						quantity = ActivationLineProducts.get(ProductId) + 1;
						ActivationLineProducts.remove(ProductId);
						ActivationLineProducts.put(ProductId, quantity);
					} else {
						ActivationLineProducts.put(ProductId, 1);
					}
				}
				if (ActivationLineData.Touchpoint_Statistik__c) {
					ProductId = ALLProductNames.get('Touchpoint Statistik');
					if (ActivationLineProducts.get(ProductId) > 0) {
						quantity = ActivationLineProducts.get(ProductId) + 1;
						ActivationLineProducts.remove(ProductId);
						ActivationLineProducts.put(ProductId, quantity);
					} else {
						ActivationLineProducts.put(ProductId, 1);
					}
				}
				if (ActivationLineData.Touchpoint_Softphone__c) {
					ProductId = ALLProductNames.get('Touchpoint Softphone');
					if (ActivationLineProducts.get(ProductId) > 0) {
						quantity = ActivationLineProducts.get(ProductId) + 1;
						ActivationLineProducts.remove(ProductId);
						ActivationLineProducts.put(ProductId, quantity);
					} else {
						ActivationLineProducts.put(ProductId, 1);
					}
				}

				//VAS services section
				boolean VASExistInQuoteDetails = false;
				for (string key : Vasfields.keySet()) {
					if (Vasfields.get(key) == 'BOOLEAN' && ActivationLineData.get(key) == true) {
						VasName = key.remove('VAS_').remove('__c');
						for (string vasTeliaProductId : VasProducts.keySet()) {
							if (VasName == vasTeliaProductId) {
								ProductId = VasProducts.get(vasTeliaProductId);
								break;
							}
						}
						system.debug('boolean VAS to be added ' + VasName);

						for (string vaskey : ActivationLineProducts.keySet()) {
							if (ProductId == vaskey) {
								quantity = ActivationLineProducts.get(ProductId) + 1;
								ActivationLineProducts.remove(ProductId);
								ActivationLineProducts.put(ProductId, quantity);
								added = true;
								break;
							}
						}
						if (added == false) {
							ActivationLineProducts.put(ProductId, 1);
						}
					}
					added = false;

					if (Vasfields.get(key) == 'INTEGER' && integer.valueof(ActivationLineData.get(key)) > 0) {
						system.debug('integer VAS to be added (not implemented) ' + VasName);
					}
					if ((Vasfields.get(key) == 'PICKLIST' || Vasfields.get(key) == 'STRING') && ActivationLineData.get(key) != null) {
						VasName = String.Valueof(ActivationLineData.get(key));
						system.debug('picklist or string VAS to be added ' + VasName);

						for (string vasTeliaProductId : VasProducts.keySet()) {
							if (VasName == vasTeliaProductId) {
								ProductId = VasProducts.get(vasTeliaProductId);
								break;
							}
						}
						for (string vasPickkey : ActivationLineProducts.keySet()) {
							if (ProductId == vasPickkey) {
								quantity = ActivationLineProducts.get(ProductId) + 1;
								ActivationLineProducts.remove(ProductId);
								ActivationLineProducts.put(ProductId, quantity);
								added = true;
								break;
							}
						}
						if (added == false) {
							ActivationLineProducts.put(ProductId, 1);
						}
					}
					added = false;
				}
			} //END OF LOOPING ACTIVATION LINES
			//system.debug(ActivationLineProducts);
			return ActivationLineProducts;
		} catch (Exception e) {
			System.debug('Error occured : ' + e.getMessage());
			errorLogging.addError('Error occured : ' + e.getMessage(), ERROR_ADDITIONAL_INFO);
			return null;
		} finally {
			errorLogging.logErrors();
		}
	}

	public map<String, integer> QuoteAvailability(string recordId) {
		try {
			List<Activation__c> Activation_records = [
				SELECT Id, Case__r.Root_BAN__c, Case__r.Quote__c
				FROM Activation__c
				WHERE Id = :recordId
				LIMIT 1
			];
			if (Activation_records.size() <= 0) {
				resultText = 'Activation details can not be found with the Id value from:' + recordId;
				return null;
			} else {
				Activation_record = Activation_records[0];
			}

			QuoteId = Activation_record.Case__r.Quote__c;

			if (String.isEmpty(QuoteId)) {
				resultText = 'Required field missing on Case: Quote';
				return null;
			}

			list<SBQQ__QuoteLine__c> QuoteLineInfoList = [
				SELECT
					SBQQ__ProductName__c,
					SBQQ__Product__c,
					SBQQ__Product__r.ProductAPI_Telia_Product_Id__c,
					SBQQ__Product__r.Activation_Record_Type__c,
					SBQQ__Quantity__c
				FROM SBQQ__QuoteLine__c
				WHERE SBQQ__Quote__c = :QuoteId AND SBQQ__Product__r.Requires_Activation_Check__c = TRUE
			];

			Map<String, integer> QuoteProducts = new Map<String, integer>();
			//ProductId, Quantity

			for (SBQQ__QuoteLine__c ql : QuoteLineInfoList) {
				QuoteProducts.put(ql.SBQQ__Product__c, Integer.valueOf(ql.SBQQ__Quantity__c));
			}
			return QuoteProducts;
		} catch (Exception e) {
			System.debug('Error occured : ' + e.getMessage());
			errorLogging.addError('Error occured : ' + e.getMessage(), ERROR_ADDITIONAL_INFO);
			return null;
		} finally {
			errorLogging.logErrors();
		}
	}

	@InvocableMethod
	public static void PortalEntryValidation(list<id> recordId) {
		String CaseId;
		String QuoteId;
		String VASresult = '';
		String EkstraDataresult = '';
		Case updateCase = new Case();
		try {
			List<Activation__c> Activation_records = [
				SELECT Id, Case__c, Case__r.Quote__c
				FROM Activation__c
				WHERE Id IN :recordId
				LIMIT 1
			];
			CaseId = Activation_records[0].Case__c;
			QuoteId = Activation_records[0].Case__r.Quote__c;

			list<Product2> ProductInfoList = [
				SELECT Name, Id, ProductAPI_Telia_Product_Id__c
				FROM Product2
				WHERE IsActive = TRUE AND Requires_Activation_Check__c = TRUE
			];
			Map<String, String> ALLProducts = new Map<String, String>();
			//ProductId,Name
			Map<String, String> ALLProductNames = new Map<String, String>();
			//Name,ProductId
			for (Product2 pr : ProductInfoList) {
				ALLProducts.put(pr.Id, pr.Name);
				ALLProductNames.put(pr.Name, pr.Id);
			}

			list<Product2> VASProductInfoList = [
				SELECT Name, Id, ProductAPI_Telia_Product_Id__c
				FROM Product2
				WHERE IsActive = TRUE AND activate_with_other_products__c = TRUE AND Requires_Activation_Check__c = TRUE
			];
			Map<String, String> VasProducts = new Map<String, String>();
			//TeliaProductId,Id

			for (Product2 prVas : VASProductInfoList) {
				VasProducts.put(prVas.ProductAPI_Telia_Product_Id__c, prVas.Id);
			}

			//Query the VAS products in the Quote lines
			list<SBQQ__QuoteLine__c> QuoteLineInfoList = [
				SELECT
					SBQQ__ProductName__c,
					SBQQ__Product__c,
					SBQQ__Product__r.ProductAPI_Telia_Product_Id__c,
					SBQQ__Product__r.Activation_Record_Type__c,
					SBQQ__Quantity__c
				FROM SBQQ__QuoteLine__c
				WHERE
					SBQQ__Quote__c = :QuoteId
					AND SBQQ__Product__r.Requires_Activation_Check__c = TRUE
					AND SBQQ__Product__r.activate_with_other_products__c = TRUE
			];

			Map<String, integer> QuoteProducts = new Map<String, integer>();
			//ProductId, Quantity

			for (SBQQ__QuoteLine__c ql : QuoteLineInfoList) {
				QuoteProducts.put(ql.SBQQ__Product__c, Integer.valueOf(ql.SBQQ__Quantity__c));
			}

			//Query the VAS services list
			Schema.DescribeSObjectResult activationline_desc = Activation_line__c.sObjectType.getDescribe();

			Map<String, Schema.SObjectField> activationline_fields = activationline_desc.fields.getMap();
			Map<String, String> Vasfields = new Map<String, String>();
			String columnNames = 'Id';

			for (Schema.sObjectField fld : activationline_fields.values()) {
				if (string.valueof(fld).indexOf('VAS_') == 0) {
					columnNames = columnNames + ',' + fld.getDescribe().getName();
					Vasfields.put(fld.getDescribe().getName(), fld.getDescribe().getType().name().toupperCase());
				}
			}

			String ProductId;
			String VasName;

			//Query the ActivationLines
			List<Activation_line__c> Activation_line_list = Database.query(
				'SELECT ' +
					columnNames +
					',name, Product__c, Case__c, First_name__c, BAN__c , Manual_Product__r.Name , ' +
					' Manual_Product__r.ProductAPI_Telia_Product_Id__c, Manual_Product__c,  ' +
					' Touchpoint_Bruger__c, Touchpoint_Receptionist__c ,Touchpoint_Softphone__c, Touchpoint_Statistik__c  ' +
					' FROM Activation_line__c WHERE Activation__c in:recordId and Not_to_Activation__c = false ' +
					' AND Manual_Product__r.Requires_Activation_Check__c = true  order by BAN__c'
			);

			//Loop through the activation lines
			Map<String, integer> ActivationLineProducts = new Map<String, integer>();
			integer quantity;
			boolean added = false;
			for (Activation_line__c ActivationLineData : Activation_line_list) {
				//START OF LOOPING ACTIVATION LINES
				//
				//Touchpoint section
				if (ActivationLineData.Touchpoint_Bruger__c) {
					ProductId = ALLProductNames.get('Touchpoint Bruger');
					if (ActivationLineProducts.get(ProductId) > 0) {
						quantity = ActivationLineProducts.get(ProductId) + 1;
						ActivationLineProducts.remove(ProductId);
						ActivationLineProducts.put(ProductId, quantity);
					} else {
						ActivationLineProducts.put(ProductId, 1);
					}
				}
				if (ActivationLineData.Touchpoint_Receptionist__c) {
					ProductId = ALLProductNames.get('Touchpoint Receptionist');
					if (ActivationLineProducts.get(ProductId) > 0) {
						quantity = ActivationLineProducts.get(ProductId) + 1;
						ActivationLineProducts.remove(ProductId);
						ActivationLineProducts.put(ProductId, quantity);
					} else {
						ActivationLineProducts.put(ProductId, 1);
					}
				}
				if (ActivationLineData.Touchpoint_Statistik__c) {
					ProductId = ALLProductNames.get('Touchpoint Statistik');
					if (ActivationLineProducts.get(ProductId) > 0) {
						quantity = ActivationLineProducts.get(ProductId) + 1;
						ActivationLineProducts.remove(ProductId);
						ActivationLineProducts.put(ProductId, quantity);
					} else {
						ActivationLineProducts.put(ProductId, 1);
					}
				}
				if (ActivationLineData.Touchpoint_Softphone__c) {
					ProductId = ALLProductNames.get('Touchpoint Softphone');
					if (ActivationLineProducts.get(ProductId) > 0) {
						quantity = ActivationLineProducts.get(ProductId) + 1;
						ActivationLineProducts.remove(ProductId);
						ActivationLineProducts.put(ProductId, quantity);
					} else {
						ActivationLineProducts.put(ProductId, 1);
					}
				}

				//VAS services section
				boolean VASExistInQuoteDetails = false;
				for (string key : Vasfields.keySet()) {
					if (Vasfields.get(key) == 'BOOLEAN' && ActivationLineData.get(key) == true) {
						VasName = key.remove('VAS_').remove('__c');
						for (string vasTeliaProductId : VasProducts.keySet()) {
							if (VasName == vasTeliaProductId) {
								ProductId = VasProducts.get(vasTeliaProductId);
								break;
							}
						}
						system.debug('boolean VAS to be added ' + VasName);

						for (string vaskey : ActivationLineProducts.keySet()) {
							if (ProductId == vaskey) {
								quantity = ActivationLineProducts.get(ProductId) + 1;
								ActivationLineProducts.remove(ProductId);
								ActivationLineProducts.put(ProductId, quantity);
								added = true;
								break;
							}
						}
						if (added == false) {
							ActivationLineProducts.put(ProductId, 1);
						}
					}
					added = false;

					if (Vasfields.get(key) == 'INTEGER' && integer.valueof(ActivationLineData.get(key)) > 0) {
						system.debug('integer VAS to be added (not implemented) ' + VasName);
					}
					if ((Vasfields.get(key) == 'PICKLIST' || Vasfields.get(key) == 'STRING') && ActivationLineData.get(key) != null) {
						VasName = String.Valueof(ActivationLineData.get(key));
						system.debug('picklist or string VAS to be added ' + VasName);

						for (string vasTeliaProductId : VasProducts.keySet()) {
							if (VasName == vasTeliaProductId) {
								ProductId = VasProducts.get(vasTeliaProductId);
								break;
							}
						}
						for (string vasPickkey : ActivationLineProducts.keySet()) {
							if (ProductId == vasPickkey) {
								quantity = ActivationLineProducts.get(ProductId) + 1;
								ActivationLineProducts.remove(ProductId);
								ActivationLineProducts.put(ProductId, quantity);
								added = true;
								break;
							}
						}
						if (added == false) {
							ActivationLineProducts.put(ProductId, 1);
						}
					}
					added = false;
				}
			} //END OF LOOPING ACTIVATION LINES

			//Vær opmærksom på at kunden vil aktivere færre VAS end aftalt
			integer i;

			for (String keyId : QuoteProducts.Keyset()) {
				//if Activation lines does not have that key
				if (!ActivationLineProducts.keyset().contains(keyId)) {
					VASresult = VASresult + '<font style="color:blue;">Available ' + ALLProducts.get(keyId) + ':';
					VASresult = VASresult + String.valueOf(QuoteProducts.get(keyId)) + '</font> <br/>';
				} else {
					if (QuoteProducts.get(keyId) != ActivationLineProducts.get(keyId)) {
						i = Integer.valueOf(QuoteProducts.get(keyId)) - Integer.valueOf(ActivationLineProducts.get(keyId));
						if (i > 0) {
							VASresult = VASresult + '<font style="color:blue;">Available ' + ALLProducts.get(keyId) + ':';
							VASresult = VASresult + String.valueof(i) + '</font> <br/>';
						}
					}
				}
			} //for

			if (String.isNotBlank(VASresult)) {
				VASresult = '<font style="color:red;">Vær opmærksom på at kunden vil aktivere færre VAS end aftalt' + '</font><br/> ' + VASresult;
				updateCase.Id = CaseId;
				updateCase.Validation_Check_Result__c = VASresult;
				update updateCase;
			}
		} catch (Exception e) {
			System.debug('Error Occured : ' + e.getMessage());
			errorLogging.addError('Error occured : ' + e.getMessage(), ERROR_ADDITIONAL_INFO);
		} finally {
			errorLogging.logErrors();
		}
	}
}