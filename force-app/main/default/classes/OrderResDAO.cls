/**
 *
 * @author Mujahid
 * @since 24/02/2023
 */

public class OrderResDAO {
	public class RecurringPrice {
		public Double amount { get; set; }
		public Double vat { get; set; }
		public Double catalogAmount { get; set; }
		public Double catalogVat { get; set; }
		public Double originalAmount { get; set; }
		public Double originalVat { get; set; }

		public RecurringPrice(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'amount') {
							amount = parser.getDoubleValue();
						} else if (text == 'vat') {
							vat = parser.getDoubleValue();
						} else if (text == 'catalogAmount') {
							catalogAmount = parser.getDoubleValue();
						} else if (text == 'catalogVat') {
							catalogVat = parser.getDoubleValue();
						} else if (text == 'originalAmount') {
							originalAmount = parser.getDoubleValue();
						} else if (text == 'originalVat') {
							originalVat = parser.getDoubleValue();
						} else {
							logError('RecurringPrice', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class HardwareDeliveries {
		public Integer id { get; set; }
		public RecipientParty recipientParty { get; set; }
		public RecipientParty billingParty { get; set; }
		public String deliveryMethod { get; set; }
		public String preferredContactMethod { get; set; }
		public String preferredSendDate { get; set; }

		public HardwareDeliveries(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'recipientParty') {
							recipientParty = new RecipientParty(parser);
						} else if (text == 'billingParty') {
							billingParty = new RecipientParty(parser);
						} else if (text == 'deliveryMethod') {
							deliveryMethod = parser.getText();
						} else if (text == 'preferredContactMethod') {
							preferredContactMethod = parser.getText();
						} else if (text == 'preferredSendDate') {
							preferredSendDate = parser.getText();
						} else {
							logError('HardwareDeliveries', text);
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
		public String email { get; set; }
		public TelephoneNumber telephoneNumber { get; set; }

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
						} else if (text == 'email') {
							email = parser.getText();
						} else if (text == 'telephoneNumber') {
							telephoneNumber = new TelephoneNumber(parser);
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
		public Address postalAddress { get; set; }
		public String municipalityCode { get; set; }
		public String streetCode { get; set; }

		public InstallationAddress(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'postalAddress') {
							postalAddress = new Address(parser);
						} else if (text == 'municipalityCode') {
							municipalityCode = parser.getText();
						} else if (text == 'streetCode') {
							streetCode = parser.getText();
						} else {
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
		public String speedDown { get; set; }
		public String speedUp { get; set; }
		public List<ChangeTypes> networkConfiguration { get; set; }
		public Boolean doItYourselfInstallation { get; set; }
		public Boolean providerReuseOfAddress { get; set; }

		public FixedNetDetails(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'fixedNetFlags') {
							fixedNetFlags = new FixedNetFlags(parser);
						} else if (text == 'installationAddress') {
							installationAddress = new InstallationAddress(parser);
						} else if (text == 'speedDown') {
							speedDown = parser.getText();
						} else if (text == 'speedUp') {
							speedUp = parser.getText();
						} else if (text == 'networkConfiguration') {
							networkConfiguration = arrayOfChangeTypes(parser);
						} else if (text == 'doItYourselfInstallation') {
							doItYourselfInstallation = parser.getBooleanValue();
						} else if (text == 'providerReuseOfAddress') {
							providerReuseOfAddress = parser.getBooleanValue();
						} else {
							logError('FixedNetDetails', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class FixedNetFlags {
		public Boolean skipStateEvent { get; set; }
		public Boolean skipCpeTechnician { get; set; }
		public Boolean skipIp { get; set; }
		public Boolean skipInvoice { get; set; }
		public Boolean hasInstallationTypeConflict { get; set; }
		public Boolean manualChangeProvider { get; set; }
		public Boolean coaxDifferentProvider { get; set; }
		public Boolean diggingNeeded { get; set; }
		public Boolean manualOrdering { get; set; }

		public FixedNetFlags(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'skipStateEvent') {
							skipStateEvent = parser.getBooleanValue();
						} else if (text == 'skipCpeTechnician') {
							skipCpeTechnician = parser.getBooleanValue();
						} else if (text == 'skipIp') {
							skipIp = parser.getBooleanValue();
						} else if (text == 'skipInvoice') {
							skipInvoice = parser.getBooleanValue();
						} else if (text == 'hasInstallationTypeConflict') {
							hasInstallationTypeConflict = parser.getBooleanValue();
						} else if (text == 'manualChangeProvider') {
							manualChangeProvider = parser.getBooleanValue();
						} else if (text == 'coaxDifferentProvider') {
							coaxDifferentProvider = parser.getBooleanValue();
						} else if (text == 'diggingNeeded') {
							diggingNeeded = parser.getBooleanValue();
						} else if (text == 'manualOrdering') {
							manualOrdering = parser.getBooleanValue();
						} else {
							logError('FixedNetFlags', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class RecipientParty {
		public String type { get; set; }
		public String firstName { get; set; }
		public String lastName { get; set; }
		public Address address { get; set; }
		public String email { get; set; }
		public String customerId { get; set; }
		public TelephoneNumber telephoneNumber { get; set; }

		public RecipientParty(JSONParser parser) {
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
						} else if (text == 'email') {
							email = parser.getText();
						} else if (text == 'customerId') {
							customerId = parser.getText();
						} else if (text == 'telephoneNumber') {
							telephoneNumber = new TelephoneNumber(parser);
						} else {
							logError('RecipientParty', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class OrderPartsSubscription {
		public List<ChangeTypes> references { get; set; }
		public String type { get; set; }
		public String processingStatus { get; set; }
		public String activity { get; set; }
		public List<ChangeTypes> changeTypes { get; set; }
		public List<OrderItems> orderItems { get; set; }
		public Integer id { get; set; }
		public RecurringPrice partTotal { get; set; }
		public RecurringPrice servicesRecurringTotal { get; set; }
		public RecurringPrice minimumPrice { get; set; }
		public RecurringPrice firstMonthPrice { get; set; }
		public List<ValidationErrors> validationErrors { get; set; }

		public OrderPartsSubscription(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'references') {
							references = arrayOfChangeTypes(parser);
						} else if (text == 'processingStatus') {
							processingStatus = parser.getText();
						} else if (text == 'type') {
							type = parser.getText();
						} else if (text == 'activity') {
							activity = parser.getText();
						} else if (text == 'changeTypes') {
							changeTypes = arrayOfChangeTypes(parser);
						} else if (text == 'orderItems') {
							orderItems = arrayOfOrderItems(parser);
						} else if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'partTotal') {
							partTotal = new RecurringPrice(parser);
						} else if (text == 'servicesRecurringTotal') {
							servicesRecurringTotal = new RecurringPrice(parser);
						} else if (text == 'minimumPrice') {
							minimumPrice = new RecurringPrice(parser);
						} else if (text == 'firstMonthPrice') {
							firstMonthPrice = new RecurringPrice(parser);
						} else if (text == 'validationErrors') {
							validationErrors = arrayOfValidationErrors(parser);
						} else {
							logError('OrderPartsSubscription', text);
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
		public String email { get; set; }
		public String customerId { get; set; }

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
						} else if (text == 'email') {
							email = parser.getText();
						} else if (text == 'customerId') {
							customerId = parser.getText();
						} else {
							logError('Orderer', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Parameters {
		public String target { get; set; }
		public String reason { get; set; }

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

	public class NewOffering {
		public String priceplan { get; set; }
		public String campaign { get; set; }
		public String name { get; set; }
		public String description { get; set; }
		public Integer bindingPeriod { get; set; }
		public RecurringPrice recurringPrice { get; set; }
		public String technicalProduct { get; set; }
		public String erpTsProduct { get; set; }
		public List<ChangeTypes> characteristics { get; set; }

		public NewOffering(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'priceplan') {
							priceplan = parser.getText();
						} else if (text == 'campaign') {
							campaign = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'bindingPeriod') {
							bindingPeriod = parser.getIntegerValue();
						} else if (text == 'recurringPrice') {
							recurringPrice = new RecurringPrice(parser);
						} else if (text == 'technicalProduct') {
							technicalProduct = parser.getText();
						} else if (text == 'erpTsProduct') {
							erpTsProduct = parser.getText();
						} else if (text == 'characteristics') {
							characteristics = arrayOfChangeTypes(parser);
						} else {
							logError('NewOffering', text);
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
		public String segment { get; set; }
		public String brand { get; set; }
		public Flags flags { get; set; }
		public String createdDate { get; set; }
		public Orderer orderer { get; set; }
		public List<OrderPartsRoot> orderParts { get; set; }
		public List<ValidationErrors> validationErrors { get; set; }
		public Boolean hasValidationErrors { get; set; }
		public List<HardwareDeliveries> hardwareDeliveries { get; set; }
		public RecurringPrice orderTotal { get; set; }
		public RecurringPrice servicesRecurringTotal { get; set; }
		public RecurringPrice orderMinimumPrice { get; set; }
		public RecurringPrice firstMonthPrice { get; set; }
		public List<ChangeTypes> documents { get; set; }
		public String id { get; set; }
		public String orderId { get; set; }
		public String channelOrderReference { get; set; }
		public String processingStatus { get; set; }

		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'channel') {
							channel = parser.getText();
						} else if (text == 'dealer') {
							dealer = new Dealer(parser);
						} else if (text == 'segment') {
							segment = parser.getText();
						} else if (text == 'brand') {
							brand = parser.getText();
						} else if (text == 'flags') {
							flags = new Flags(parser);
						} else if (text == 'createdDate') {
							createdDate = parser.getText();
						} else if (text == 'orderer') {
							orderer = new Orderer(parser);
						} else if (text == 'orderParts') {
							orderParts = arrayOfOrderParts(parser);
						} else if (text == 'validationErrors') {
							validationErrors = arrayOfValidationErrors(parser);
						} else if (text == 'hasValidationErrors') {
							hasValidationErrors = parser.getBooleanValue();
						} else if (text == 'hardwareDeliveries') {
							hardwareDeliveries = arrayOfHardwareDeliveries(parser);
						} else if (text == 'orderTotal') {
							orderTotal = new RecurringPrice(parser);
						} else if (text == 'servicesRecurringTotal') {
							servicesRecurringTotal = new RecurringPrice(parser);
						} else if (text == 'orderMinimumPrice') {
							orderMinimumPrice = new RecurringPrice(parser);
						} else if (text == 'firstMonthPrice') {
							firstMonthPrice = new RecurringPrice(parser);
						} else if (text == 'documents') {
							documents = arrayOfChangeTypes(parser);
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'orderId') {
							orderId = parser.getText();
						} else if (text == 'channelOrderReference') {
							channelOrderReference = parser.getText();
						} else if (text == 'processingStatus') {
							processingStatus = parser.getText();
						} else {
							logError('Data', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Flags {
		public Boolean termsAccepted { get; set; }
		public Boolean consentsAccepted { get; set; }
		public Boolean cprCheckFailed { get; set; }
		public Boolean creditCheckFailed { get; set; }
		public Boolean needsConfirmation { get; set; }
		public Boolean dirty { get; set; }
		public Boolean doLogistics { get; set; }
		public Boolean providerChangeAccountNumberMissing { get; set; }
		public Boolean homeOfficeOrder { get; set; }

		public Flags(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'termsAccepted') {
							termsAccepted = parser.getBooleanValue();
						} else if (text == 'consentsAccepted') {
							consentsAccepted = parser.getBooleanValue();
						} else if (text == 'cprCheckFailed') {
							cprCheckFailed = parser.getBooleanValue();
						} else if (text == 'creditCheckFailed') {
							creditCheckFailed = parser.getBooleanValue();
						} else if (text == 'needsConfirmation') {
							needsConfirmation = parser.getBooleanValue();
						} else if (text == 'dirty') {
							dirty = parser.getBooleanValue();
						} else if (text == 'doLogistics') {
							doLogistics = parser.getBooleanValue();
						} else if (text == 'providerChangeAccountNumberMissing') {
							providerChangeAccountNumberMissing = parser.getBooleanValue();
						} else if (text == 'homeOfficeOrder') {
							homeOfficeOrder = parser.getBooleanValue();
						} else {
							logError('Flags', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public Data data { get; set; }

	public OrderResDAO(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'data') {
						data = new Data(parser);
					} else {
						logError('OrderResDAO', text);
						consumeObject(parser);
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

	public class References {
		public String type { get; set; }
		public String value { get; set; }

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
		public String productType { get; set; }
		public NewOffering newOffering { get; set; }
		public String productCategory { get; set; }
		public FixedNetDetails fixedNetDetails { get; set; }
		public String preferredActivationDate { get; set; }
		public String activity { get; set; }
		public Integer id { get; set; }
		public String origin { get; set; }
		public String productCode { get; set; }
		public Integer quantity { get; set; }
		public List<ChangeTypes> characteristics { get; set; }
		public String feeType { get; set; }
		public String displayName { get; set; }
		public Boolean recurring { get; set; }
		public RecurringPrice price { get; set; }
		public String billingCode { get; set; }
		public List<ValidationErrors> validationErrors { get; set; }
		public String paymentMethod { get; set; }
		public LegalParty legalParty { get; set; }

		public OrderItems(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'productType') {
							productType = parser.getText();
						} else if (text == 'newOffering') {
							newOffering = new NewOffering(parser);
						} else if (text == 'productCategory') {
							productCategory = parser.getText();
						} else if (text == 'fixedNetDetails') {
							fixedNetDetails = new FixedNetDetails(parser);
						} else if (text == 'preferredActivationDate') {
							preferredActivationDate = parser.getText();
						} else if (text == 'activity') {
							activity = parser.getText();
						} else if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'origin') {
							origin = parser.getText();
						} else if (text == 'productCode') {
							productCode = parser.getText();
						} else if (text == 'quantity') {
							quantity = parser.getIntegerValue();
						} else if (text == 'characteristics') {
							characteristics = arrayOfChangeTypes(parser);
						} else if (text == 'feeType') {
							feeType = parser.getText();
						} else if (text == 'displayName') {
							displayName = parser.getText();
						} else if (text == 'recurring') {
							recurring = parser.getBooleanValue();
						} else if (text == 'price') {
							price = new RecurringPrice(parser);
						} else if (text == 'billingCode') {
							billingCode = parser.getText();
						} else if (text == 'validationErrors') {
							validationErrors = arrayOfValidationErrors(parser);
						} else if (text == 'paymentMethod') {
							paymentMethod = parser.getText();
						} else if (text == 'legalParty') {
							legalParty = new LegalParty(parser);
						} else {
							logError('OrderItems', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class OrderPartsAccount {
		public List<References> references { get; set; }
		public String processingStatus { get; set; }
		public String type { get; set; }
		public String activity { get; set; }
		public List<ChangeTypes> changeTypes { get; set; }
		public List<OrderItems> orderItems { get; set; }
		public List<OrderPartsSubscription> orderParts { get; set; }
		public Integer id { get; set; }
		public String channelOrderPartId { get; set; }
		public String splitOrderId { get; set; }
		public RecurringPrice partTotal { get; set; }
		public RecurringPrice servicesRecurringTotal { get; set; }
		public RecurringPrice minimumPrice { get; set; }
		public RecurringPrice firstMonthPrice { get; set; }

		public OrderPartsAccount(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'references') {
							references = arrayOfReferences(parser);
						} else if (text == 'processingStatus') {
							processingStatus = parser.getText();
						} else if (text == 'type') {
							type = parser.getText();
						} else if (text == 'activity') {
							activity = parser.getText();
						} else if (text == 'changeTypes') {
							changeTypes = arrayOfChangeTypes(parser);
						} else if (text == 'orderItems') {
							orderItems = arrayOfOrderItems(parser);
						} else if (text == 'orderParts') {
							orderParts = arrayOfOrderPartsSubscriptions(parser);
						} else if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'channelOrderPartId') {
							channelOrderPartId = parser.getText();
						} else if (text == 'splitOrderId') {
							splitOrderId = parser.getText();
						} else if (text == 'partTotal') {
							partTotal = new RecurringPrice(parser);
						} else if (text == 'servicesRecurringTotal') {
							servicesRecurringTotal = new RecurringPrice(parser);
						} else if (text == 'minimumPrice') {
							minimumPrice = new RecurringPrice(parser);
						} else if (text == 'firstMonthPrice') {
							firstMonthPrice = new RecurringPrice(parser);
						} else {
							logError('OrderPartsAccount', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class OrderPartsRoot {
		public List<References> references { get; set; }
		public String type { get; set; }
		public String activity { get; set; }
		public List<ChangeTypes> changeTypes { get; set; }
		public List<OrderPartsAccount> orderParts { get; set; }
		public List<ValidationErrors> validationErrors { get; set; }
		public Integer id { get; set; }
		public RecurringPrice partTotal { get; set; }
		public RecurringPrice servicesRecurringTotal { get; set; }
		public RecurringPrice minimumPrice { get; set; }
		public RecurringPrice firstMonthPrice { get; set; }

		public OrderPartsRoot(JSONParser parser) {
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
							changeTypes = arrayOfChangeTypes(parser);
						} else if (text == 'orderParts') {
							orderParts = arrayOfOrderPartsAccount(parser);
						} else if (text == 'validationErrors') {
							validationErrors = arrayOfValidationErrors(parser);
						} else if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'partTotal') {
							partTotal = new RecurringPrice(parser);
						} else if (text == 'servicesRecurringTotal') {
							servicesRecurringTotal = new RecurringPrice(parser);
						} else if (text == 'minimumPrice') {
							minimumPrice = new RecurringPrice(parser);
						} else if (text == 'firstMonthPrice') {
							firstMonthPrice = new RecurringPrice(parser);
						} else {
							logError('OrderPartsRoot', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class ChangeTypes {
		public ChangeTypes(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							logError('ChangeTypes', text);
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
		public String country { get; set; }
		public String streetName { get; set; }
		public String streetNumber { get; set; }
		public String streetNumberSuffix { get; set; }

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
						} else if (text == 'country') {
							country = parser.getText();
						} else if (text == 'streetName') {
							streetName = parser.getText();
						} else if (text == 'streetNumber') {
							streetNumber = parser.getText();
						} else if (text == 'streetNumberSuffix') {
							streetNumberSuffix = parser.getText();
						} else {
							logError('Address', text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Dealer {
		public String salesAgentTcad { get; set; }

		public Dealer(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'salesAgentTcad') {
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

	public static OrderResDAO parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new OrderResDAO(parser);
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

	private static List<HardwareDeliveries> arrayOfHardwareDeliveries(System.JSONParser p) {
		List<HardwareDeliveries> res = new List<HardwareDeliveries>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new HardwareDeliveries(p));
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

	private static List<OrderPartsSubscription> arrayOfOrderPartsSubscriptions(System.JSONParser p) {
		List<OrderPartsSubscription> res = new List<OrderPartsSubscription>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new OrderPartsSubscription(p));
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

	private static List<Parameters> arrayOfParameters(System.JSONParser p) {
		List<Parameters> res = new List<Parameters>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new Parameters(p));
		}
		return res;
	}

	private static List<OrderPartsRoot> arrayOfOrderParts(System.JSONParser p) {
		List<OrderPartsRoot> res = new List<OrderPartsRoot>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new OrderPartsRoot(p));
		}
		return res;
	}

	private static List<OrderPartsAccount> arrayOfOrderPartsAccount(System.JSONParser p) {
		List<OrderPartsAccount> res = new List<OrderPartsAccount>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new OrderPartsAccount(p));
		}
		return res;
	}

	private static List<ChangeTypes> arrayOfChangeTypes(System.JSONParser p) {
		List<ChangeTypes> res = new List<ChangeTypes>();
		if (p.getCurrentToken() == null)
			p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new ChangeTypes(p));
		}
		return res;
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

	private static void logError(String component, String text) {
		System_Log__c logError = new System_Log__c(
			Origin__c = 'Apex',
			Error_Body__c = component + ' ' + Label.RootBan_Request_DAO_Warning + ' : ' + text,
			Additional_Information__c = 'OrderResDAO'
		);
		insert logError;
	}
}