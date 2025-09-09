/**
 *
 * @author Mujahid
 * @since 27/01/2023
 * @description Response DAO for Create Rootban Request from Fokus
 */
public class RootBanResDAO {
	public class TelephoneNumberCCode {
		public String countryCode { get; set; }

		public TelephoneNumberCCode(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'countryCode') {
							countryCode = parser.getText();
						} else {
							logError('TelephoneNumberCCode', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class ValidationErrors {
		public String errorCode { get; set; }
		public List<Parameters> parameters { get; set; }

		public ValidationErrors(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'errorCode') {
							errorCode = parser.getText();
						} else if (text == 'parameters') {
							parameters = arrayOfParameters(parser);
						} else {
							logError('ValidationErrors', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	private static List<Parameters> arrayOfParameters(System.JSONParser p) {
		List<Parameters> res = new List<Parameters>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new Parameters(p));
		}
		return res;
	}

	public class Parameters {
		public String target { get; set; }
		public String reason { get; set; }

		public Parameters() {
		}

		public Parameters(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'target') {
							target = parser.getText();
						} else if (text == 'reason') {
							reason = parser.getText();
						} else {
							logError('Parameters', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class OrderItems {
		public String type { get; set; }
		public String billingAccountNumber { get; set; }
		public Orderer legalParty { get; set; }
		public BillingParty billingParty { get; set; }
		public String billingCycle { get; set; }
		public String invoiceType { get; set; }
		public String label { get; set; }
		public String upTransferChargeCode { get; set; }
		public String activity { get; set; }
		public Integer id { get; set; }
		public String origin { get; set; }
		public String discountCode { get; set; }
		public List<ValidationErrors> validationErrors { get; set; }

		public OrderItems(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'billingAccountNumber') {
							billingAccountNumber = parser.getText();
						} else if (text == 'legalParty') {
							legalParty = new Orderer(parser);
						} else if (text == 'billingParty') {
							billingParty = new BillingParty(parser);
						} else if (text == 'billingCycle') {
							billingCycle = parser.getText();
						} else if (text == 'invoiceType') {
							invoiceType = parser.getText();
						} else if (text == 'label') {
							label = parser.getText();
						} else if (text == 'upTransferChargeCode') {
							upTransferChargeCode = parser.getText();
						} else if (text == 'activity') {
							activity = parser.getText();
						} else if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'origin') {
							origin = parser.getText();
						} else if (text == 'discountCode') {
							discountCode = parser.getText();
						} else if (text == 'validationErrors') {
							validationErrors = arrayOfValidationErrors(parser);
						} else {
							logError('OrderItems', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class References {
		public References(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							logError('References', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class OrderParts {
		public List<References> references { get; set; }
		public String type { get; set; }
		public String activity { get; set; }
		public List<References> changeTypes { get; set; }
		public List<OrderItems> orderItems { get; set; }
		public Integer id { get; set; }
		public List<ValidationErrors> validationErrors { get; set; }

		public OrderParts(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'references') {
							references = arrayOfReferences(parser);
						} else if (text == 'type') {
							type = parser.getText();
						} else if (text == 'activity') {
							activity = parser.getText();
						} else if (text == 'changeTypes') {
							changeTypes = arrayOfReferences(parser);
						} else if (text == 'orderItems') {
							orderItems = arrayOfOrderItems(parser);
						} else if (text == 'validationErrors') {
							validationErrors = arrayOfValidationErrors(parser);
						} else if (text == 'id') {
							id = parser.getIntegerValue();
						} else {
							logError('OrderParts', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Data {
		public String channel { get; set; }
		public Dealer dealer { get; set; }
		public String orderId { get; set; }
		public String id { get; set; }
		public String segment { get; set; }
		public String channelOrderReference { get; set; }
		public String brand { get; set; }
		public String createdDate { get; set; }
		public String processingStatus { get; set; }
		public Orderer orderer { get; set; }
		public List<OrderParts> orderParts { get; set; }
		public Boolean hasValidationErrors { get; set; }
		public List<References> documents { get; set; }
		public List<ValidationErrors> validationErrors { get; set; }

		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'channel') {
							channel = parser.getText();
						} else if (text == 'dealer') {
							dealer = new Dealer(parser);
						} else if (text == 'orderId') {
							orderId = parser.getText();
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'segment') {
							segment = parser.getText();
						} else if (text == 'channelOrderReference') {
							channelOrderReference = parser.getText();
						} else if (text == 'brand') {
							brand = parser.getText();
						} else if (text == 'createdDate') {
							createdDate = parser.getText();
						} else if (text == 'processingStatus') {
							processingStatus = parser.getText();
						} else if (text == 'orderer') {
							orderer = new Orderer(parser);
						} else if (text == 'orderParts') {
							orderParts = arrayOfOrderParts(parser);
						} else if (text == 'validationErrors') {
							validationErrors = arrayOfValidationErrors(parser);
						} else if (text == 'hasValidationErrors') {
							hasValidationErrors = parser.getBooleanValue();
						} else if (text == 'documents') {
							documents = arrayOfReferences(parser);
						} else {
							logError('Data', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public Data data { get; set; }

	public RootBanResDAO(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'data') {
						data = new Data(parser);
					} else {
						logError('RootBanResDAO', text);
						consumeObject(parser);
					}
				}
			}
		}
	}

	public class TelephoneNumber {
		public String countryCode { get; set; }
		public String localNumber { get; set; }

		public TelephoneNumber(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'countryCode') {
							countryCode = parser.getText();
						} else if (text == 'localNumber') {
							localNumber = parser.getText();
						} else {
							logError('TelephoneNumber', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Address {
		public String type { get; set; }
		public String city { get; set; }
		public String zipCode { get; set; }
		public String attention { get; set; }
		public String country { get; set; }
		public String streetName { get; set; }
		public String streetNumber { get; set; }
		public String streetNumberSuffix { get; set; }
		public String floorNumber { get; set; }
		public String doorNumber { get; set; }
		public String direction { get; set; }

		public Address(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'zipCode') {
							zipCode = parser.getText();
						} else if (text == 'attention') {
							attention = parser.getText();
						} else if (text == 'country') {
							country = parser.getText();
						} else if (text == 'streetName') {
							streetName = parser.getText();
						} else if (text == 'streetNumber') {
							streetNumber = parser.getText();
						} else if (text == 'streetNumberSuffix') {
							streetNumberSuffix = parser.getText();
						} else if (text == 'floorNumber') {
							floorNumber = parser.getText();
						} else if (text == 'doorNumber') {
							doorNumber = parser.getText();
						} else if (text == 'direction') {
							direction = parser.getText();
						} else {
							logError('Address', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Orderer {
		public String type { get; set; }
		public String name { get; set; }
		public String cvr { get; set; }
		public Address address { get; set; }
		public TelephoneNumber telephoneNumber { get; set; }
		public List<ValidationErrors> validationErrors { get; set; }

		public Orderer(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'cvr') {
							cvr = parser.getText();
						} else if (text == 'address') {
							address = new Address(parser);
						} else if (text == 'telephoneNumber') {
							telephoneNumber = new TelephoneNumber(parser);
						} else if (text == 'validationErrors') {
							validationErrors = arrayOfValidationErrors(parser);
						} else {
							logError('Orderer', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class BillingParty {
		public String type { get; set; }
		public String name { get; set; }
		public String cvr { get; set; }
		public Address address { get; set; }
		public TelephoneNumberCCode telephoneNumber { get; set; }
		public List<ValidationErrors> validationErrors { get; set; }

		public BillingParty(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'cvr') {
							cvr = parser.getText();
						} else if (text == 'address') {
							address = new Address(parser);
						} else if (text == 'telephoneNumber') {
							telephoneNumber = new TelephoneNumberCCode(parser);
						} else if (text == 'validationErrors') {
							validationErrors = arrayOfValidationErrors(parser);
						} else {
							logError('BillingParty', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Dealer {
		public String dealerCode { get; set; }
		public String dealerName { get; set; }
		public String salesAgentCode { get; set; }
		public List<ValidationErrors> validationErrors { get; set; }

		public Dealer(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'dealerCode') {
							dealerCode = parser.getText();
						} else if (text == 'dealerName') {
							dealerName = parser.getText();
						} else if (text == 'salesAgentCode') {
							salesAgentCode = parser.getText();
						} else if (text == 'validationErrors') {
							validationErrors = arrayOfValidationErrors(parser);
						} else {
							logError('Dealer', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public static RootBanResDAO parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new RootBanResDAO(parser);
	}

	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT || curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

	private static List<ValidationErrors> arrayOfValidationErrors(System.JSONParser p) {
		List<ValidationErrors> res = new List<ValidationErrors>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new ValidationErrors(p));
		}
		return res;
	}

	private static List<References> arrayOfReferences(System.JSONParser p) {
		List<References> res = new List<References>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new References(p));
		}
		return res;
	}

	private static List<OrderParts> arrayOfOrderParts(System.JSONParser p) {
		List<OrderParts> res = new List<OrderParts>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new OrderParts(p));
		}
		return res;
	}

	private static List<OrderItems> arrayOfOrderItems(System.JSONParser p) {
		List<OrderItems> res = new List<OrderItems>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new OrderItems(p));
		}
		return res;
	}

	private static void logError(String component, String text) {
		System_Log__c logError = new System_Log__c(
			Origin__c = 'Apex',
			Error_Body__c = component + ' ' + Label.RootBan_Request_DAO_Warning + ' : ' + text,
			Additional_Information__c = 'RootBanReqDAO'
		);
		insert logError;
	}
}