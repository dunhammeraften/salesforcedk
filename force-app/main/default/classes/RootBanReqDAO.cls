/**
 *
 * @author Mujahid
 * @since 23-01-2023
 * @description DAO class for creating new root ban in fokus request body
 */
public class RootBanReqDAO {
	public String brand { get; set; }
	public String segment { get; set; }
	public String channel { get; set; }
	public Dealer dealer { get; set; }
	public Flags flags { get; set; }
	public Orderer orderer { get; set; }
	public List<OrderParts> orderParts { get; set; }

	public RootBanReqDAO() {
	}

	public RootBanReqDAO(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'brand') {
						brand = parser.getText();
					} else if (text == 'segment') {
						segment = parser.getText();
					} else if (text == 'channel') {
						channel = parser.getText();
					} else if (text == 'dealer') {
						dealer = new Dealer(parser);
					} else if (text == 'flags') {
						flags = new Flags(parser);
					} else if (text == 'orderer') {
						orderer = new Orderer(parser);
					} else if (text == 'orderParts') {
						orderParts = arrayOfOrderParts(parser);
					} else {
						logError('RootBanReqDAO', text);
						consumeObject(parser);
					}
				}
			}
		}
	}

	public class TelephoneNumberCCode {
		public String countryCode { get; set; }

		public TelephoneNumberCCode() {
		}

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

	public class OrderItems {
		public String type { get; set; }
		public String activity { get; set; }
		public String billingCycle { get; set; }
		public String invoiceType { get; set; }
		public String label { get; set; }
		public String upTransferChargeCode { get; set; }
		public Orderer legalParty { get; set; }
		public BillingParty billingParty { get; set; }
		public String discountCode { get; set; }
		public String category { get; set; }
		public String productGroup { get; set; }

		public OrderItems() {
		}

		public OrderItems(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'activity') {
							activity = parser.getText();
						} else if (text == 'billingCycle') {
							billingCycle = parser.getText();
						} else if (text == 'invoiceType') {
							invoiceType = parser.getText();
						} else if (text == 'label') {
							label = parser.getText();
						} else if (text == 'upTransferChargeCode') {
							upTransferChargeCode = parser.getText();
						} else if (text == 'legalParty') {
							legalParty = new Orderer(parser);
						} else if (text == 'billingParty') {
							billingParty = new BillingParty(parser);
						} else if (text == 'discountCode') {
							discountCode = parser.getText();
						} else if (text == 'category') {
							category = parser.getText();
						} else if (text == 'productGroup'){
							productGroup = parser.getText();
						} 
						else {
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
		public String type { get; set; }
		public String activity { get; set; }
		public List<References> references { get; set; }
		public List<OrderItems> orderItems { get; set; }

		public OrderParts() {
		}

		public OrderParts(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'activity') {
							activity = parser.getText();
						} else if (text == 'references') {
							references = arrayOfReferences(parser);
						} else if (text == 'orderItems') {
							orderItems = arrayOfOrderItems(parser);
						} else {
							logError('OrderParts', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class TelephoneNumber {
		public String countryCode { get; set; }
		public String localNumber { get; set; }

		public TelephoneNumber() {
		}

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
		public String attention { get; set; }
		public String zipCode { get; set; }
		public String streetNumber { get; set; }
		public String streetName { get; set; }
		public String streetNumberSuffix { get; set; }
		public String floorNumber { get; set; }
		public String doorNumber { get; set; }
		public String direction { get; set; }
		public String city { get; set; }
		public String country { get; set; }

		public Address() {
		}

		public Address(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'attention') {
							attention = parser.getText();
						} else if (text == 'zipCode') {
							zipCode = parser.getText();
						} else if (text == 'streetNumber') {
							streetNumber = parser.getText();
						} else if (text == 'streetName') {
							streetName = parser.getText();
						} else if (text == 'streetNumberSuffix') {
							streetNumberSuffix = parser.getText();
						} else if (text == 'floorNumber') {
							floorNumber = parser.getText();
						} else if (text == 'doorNumber') {
							doorNumber = parser.getText();
						} else if (text == 'direction') {
							direction = parser.getText();
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'country') {
							country = parser.getText();
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
		public TelephoneNumber telephoneNumber { get; set; }
		public String name { get; set; }
		public String cvr { get; set; }
		public Address address { get; set; }

		public Orderer() {
		}

		public Orderer(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'telephoneNumber') {
							telephoneNumber = new TelephoneNumber(parser);
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'cvr') {
							cvr = parser.getText();
						} else if (text == 'address') {
							address = new Address(parser);
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
		public TelephoneNumberCCode telephoneNumber { get; set; }
		public String name { get; set; }
		public String cvr { get; set; }
		public String label { get; set; }
		public Address address { get; set; }

		public BillingParty() {
		}

		public BillingParty(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'telephoneNumber') {
							telephoneNumber = new TelephoneNumberCCode(parser);
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'cvr') {
							cvr = parser.getText();
						} else if (text == 'label') {
							label = parser.getText();
						} else if (text == 'address') {
							address = new Address(parser);
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
		public String salesAgentCode { get; set; }
		public String dealerCode { get; set; }

		public Dealer() {
		}

		public Dealer(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'salesAgentCode') {
							salesAgentCode = parser.getText();
						} else if (text == 'dealerCode') {
							dealerCode = parser.getText();
						} else {
							logError('Dealer', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Flags {
		public Boolean homeOfficeOrder { get; set; }

		public Flags() {
		}

		public Flags(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'homeOfficeOrder') {
							homeOfficeOrder = Boolean.valueOf(parser.getText());
						} else {
							logError('Flags', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public static RootBanReqDAO parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new RootBanReqDAO(parser);
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

	private static List<References> arrayOfReferences(System.JSONParser p) {
		List<References> res = new List<References>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new References(p));
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

	private static List<OrderParts> arrayOfOrderParts(System.JSONParser p) {
		List<OrderParts> res = new List<OrderParts>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new OrderParts(p));
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