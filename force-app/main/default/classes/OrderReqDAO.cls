/**
 * @author Mujahid
 * @since 24/02/2023
 */

public class OrderReqDAO {
	public class Address {
		public String streetName { get; set; }
		public String streetNumber { get; set; }
		public String streetNumberSuffix { get; set; }
		public String floorNumber { get; set; }
		public String doorNumber { get; set; }
		public String direction { get; set; }
		public String city { get; set; }
		public String zipCode { get; set; }
		public String country { get; set; }

		public Address() {
		}

		public Address(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'streetName') {
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
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'zipCode') {
							zipCode = parser.getText();
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

	public class NewOffering {
		public String priceplan { get; set; }
		public String campaign { get; set; }

		public NewOffering() {
		}

		public NewOffering(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'priceplan') {
							priceplan = parser.getText();
						} else if (text == 'campaign') {
							campaign = parser.getText();
						} else {
							logError('NewOffering', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Flags {
		public Boolean needsConfirmation { get; set; }
		public Boolean consentsAccepted { get; set; }
		public Boolean termsAccepted { get; set; }
		public Boolean dirty { get; set; }

		public Flags() {
		}

		public Flags(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'needsConfirmation') {
							needsConfirmation = parser.getBooleanValue();
						} else if (text == 'consentsAccepted') {
							consentsAccepted = parser.getBooleanValue();
						} else if (text == 'termsAccepted') {
							termsAccepted = parser.getBooleanValue();
						} else if (text == 'dirty') {
							dirty = parser.getBooleanValue();
						} else {
							logError('Flags', text);
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

	public class LegalParty {
		public String type { get; set; }
		public String firstName { get; set; }
		public String lastName { get; set; }
		public Address address { get; set; }
		public TelephoneNumber telephoneNumber { get; set; }
		public String email { get; set; }

		public LegalParty() {
		}

		public LegalParty(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'firstName') {
							firstName = parser.getText();
						} else if (text == 'lastName') {
							lastName = parser.getText();
						} else if (text == 'address') {
							address = new Address(parser);
						} else if (text == 'telephoneNumber') {
							telephoneNumber = new TelephoneNumber(parser);
						} else if (text == 'email') {
							email = parser.getText();
						} else {
							logError('LegalParty', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class InstallationAddress {
		public String municipalityCode { get; set; }
		public String streetCode { get; set; }
		public Address postalAddress { get; set; }
		public String addressRefId { get; set; }
		public String siteId { get; set; }
		public String floorNumber {get; set;}
		public String doorNumber {get; set;}

		public InstallationAddress() {
		}

		public InstallationAddress(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'municipalityCode') {
							municipalityCode = parser.getText();
						} else if (text == 'streetCode') {
							streetCode = parser.getText();
						} else if (text == 'postalAddress') {
							postalAddress = new Address(parser);
						} else if (text == 'addressRefId') {
							addressRefId = parser.getText();
						} else if (text == 'siteId') {
							siteId = parser.getText();
						} else if (text == 'floorNumber') {
							floorNumber = parser.getText();
						} else if (text == 'doorNumber') {
							doorNumber = parser.getText();
						} else{
							logError('InstallationAddress', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class FixedNetDetails {
		public FixedNetFlags fixedNetFlags { get; set; }
		public InstallationAddress installationAddress { get; set; }
		public String speedUp { get; set; }
		public String speedDown { get; set; }
		public Boolean doItYourselfInstallation { get; set; }
		public Boolean providerReuseOfAddress { get; set; }
		public String previousEmployerAdminEmail { get; set; }
		public String vendor { get; set; }
		public String vendorProductCode { get; set; }
		public String vendorProductCatalogId { get; set; }
		public String lineConnectionStatus { get; set; }

		public FixedNetDetails() {
		}

		public FixedNetDetails(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'fixedNetFlags') {
							fixedNetFlags = new FixedNetFlags(parser);
						} else if (text == 'installationAddress') {
							installationAddress = new InstallationAddress(parser);
						} else if (text == 'speedUp') {
							speedUp = parser.getText();
						} else if (text == 'speedDown') {
							speedDown = parser.getText();
						} else if (text == 'doItYourselfInstallation') {
							doItYourselfInstallation = parser.getBooleanValue();
						} else if (text == 'providerReuseOfAddress') {
							providerReuseOfAddress = parser.getBooleanValue();
						} else if (text == 'previousEmployerAdminEmail') {
							previousEmployerAdminEmail = parser.getText();
						} else if (text == 'vendor') {
							vendor = parser.getText();							
						} else if (text == 'vendorProductCode') {
							vendorProductCode = parser.getText();
						} else if (text == 'vendorProductCatalogId') {
							vendorProductCatalogId = parser.getText();
						} else if (text == 'lineConnectionStatus') {
							lineConnectionStatus = parser.getText();
						} else {
							logError('FixedNetDetails', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public String brand { get; set; }
	public String channel { get; set; }
	public String segment { get; set; }
	public String implementationCaseId { get; set; }
	public Dealer dealer { get; set; }
	public Flags flags { get; set; }
	public List<OrderParts> orderParts { get; set; }

	public OrderReqDAO() {
	}

	public OrderReqDAO(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'brand') {
						brand = parser.getText();
					} else if (text == 'channel') {
						channel = parser.getText();
					} else if (text == 'segment') {
						segment = parser.getText();
					} else if (text == 'dealer') {
						dealer = new Dealer(parser);
					} else if (text == 'flags') {
						flags = new Flags(parser);
					} else if (text == 'orderParts') {
						orderParts = arrayOfOrderParts(parser);
					} else {
						logError('OrderReqDAO', text);
						consumeObject(parser);
					}
				}
			}
		}
	}

	public class Price {
		public Double amount { get; set; }
		public String currency_Z { get; set; } // in json: currency
		public Double vat { get; set; }

		public Price() {
		}

		public Price(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'amount') {
							amount = parser.getDoubleValue();
						} else if (text == 'currency') {
							currency_Z = parser.getText();
						} else if (text == 'vat') {
							vat = parser.getDoubleValue();
						} else {
							logError('Price', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class References {
		public String type { get; set; }
		public String value { get; set; }

		public References() {
		}

		public References(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'value') {
							value = parser.getText();
						} else {
							logError('References', text);
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
		public NewOffering newOffering { get; set; }
		public FixedNetDetails fixedNetDetails { get; set; }
		public Date preferredActivationDate { get; set; }
		public Boolean productDeliveryAsap { get; set; }
		public String productCategory { get; set; }
		public String productCode { get; set; }
		public Integer quantity { get; set; }
		public String feeId { get; set; }
		public String feeType { get; set; }
		public String displayName { get; set; }
		public Price price { get; set; }
		public Boolean recurring { get; set; }
		public String billingCode { get; set; }
		public String billingCycle { get; set; }
		public String invoiceType { get; set; }
		public String paymentMethod { get; set; }
		public LegalParty legalParty { get; set; }
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
						} else if (text == 'newOffering') {
							newOffering = new NewOffering(parser);
						} else if (text == 'fixedNetDetails') {
							fixedNetDetails = new FixedNetDetails(parser);
						} else if (text == 'preferredActivationDate') {
							preferredActivationDate = parser.getDateValue();
						} else if (text == 'productDeliveryAsap') {
							productDeliveryAsap = parser.getBooleanValue();
						} else if (text == 'productCategory') {
							productCategory = parser.getText();
						} else if (text == 'productCode') {
							productCode = parser.getText();
						} else if (text == 'quantity') {
							quantity = parser.getIntegerValue();
						} else if (text == 'feeId') {
							feeId = parser.getText();
						} else if (text == 'feeType') {
							feeType = parser.getText();
						} else if (text == 'displayName') {
							displayName = parser.getText();
						} else if (text == 'price') {
							price = new Price(parser);
						} else if (text == 'recurring') {
							recurring = parser.getBooleanValue();
						} else if (text == 'billingCode') {
							billingCode = parser.getText();
						} else if (text == 'paymentMethod') {
							paymentMethod = parser.getText();
						} else if (text == 'billingCycle') {
							billingCycle = parser.getText();
						} else if (text == 'invoiceType') {
							invoiceType = parser.getText();
						} else if (text == 'legalParty') {
							legalParty = new LegalParty(parser);
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

	public class FixedNetFlags {
		public Boolean customerRequestsChangeProvider { get; set; }
		public Boolean diggingNeeded { get; set; }
		public Boolean plugPresentPositiveValidation { get; set; }
		public Boolean activeBlockingLinePresent { get; set; }
		public Boolean plugTechnicianRequired { get; set; }

		public FixedNetFlags() {
		}

		public FixedNetFlags(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'diggingNeeded') {
							diggingNeeded = parser.getBooleanValue();
						} else if (text == 'customerRequestsChangeProvider') {
							customerRequestsChangeProvider = parser.getBooleanValue();
						} else if (text == 'plugPresentPositiveValidation') {
							plugPresentPositiveValidation = parser.getBooleanValue();
						} else if (text == 'activeBlockingLinePresent') {
							activeBlockingLinePresent = parser.getBooleanValue();
						} else if (text == 'plugTechnicianRequired') {
							plugTechnicianRequired = parser.getBooleanValue();
						} else {
							logError('FixedNetFlags', text);
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
		public String channelOrderPartId { get; set; }
		public List<OrderItems> orderItems { get; set; }
		public List<OrderParts> orderParts { get; set; }
		public List<References> references { get; set; }

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
						} else if (text == 'channelOrderPartId') {
							channelOrderPartId = parser.getText();
						} else if (text == 'orderItems') {
							orderItems = arrayOfOrderItems(parser);
						} else if (text == 'orderParts') {
							orderParts = arrayOfOrderParts(parser);
						} else if (text == 'references') {
							references = arrayOfReferences(parser);
						} else {
							logError('OrderParts', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Dealer {
		public String dealerCode { get; set; }
		public String salesAgentTcad { get; set; }

		public Dealer() {
		}

		public Dealer(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'dealerCode') {
							dealerCode = parser.getText();
						} else if (text == 'salesAgentTcad') {
							salesAgentTcad = parser.getText();
						} else {
							logError('Dealer', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public static OrderReqDAO parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new OrderReqDAO(parser);
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

	private static List<OrderItems> arrayOfOrderItems(System.JSONParser p) {
		List<OrderItems> res = new List<OrderItems>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new OrderItems(p));
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

	private static void logError(String component, String text) {
		System_Log__c logError = new System_Log__c(
			Origin__c = 'Apex',
			Error_Body__c = component + ' ' + Label.RootBan_Request_DAO_Warning + ' : ' + text,
			Additional_Information__c = 'OrderReqDAO'
		);
		insert logError;
	}
}