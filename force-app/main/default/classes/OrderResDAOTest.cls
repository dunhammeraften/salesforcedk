/**
 * @author Mujahid
 * @since 27/02/2023
 */

@IsTest
public class OrderResDAOTest {
	// This test method should give 100% coverage
	@IsTest
	static void testParse() {
		String json =
			'{' +
			'    \"data\": {' +
			'        \"channel\": \"SALES_FORCE\",' +
			'        \"id\": \"57164\",' +
			'        \"channelOrderReference\": \"SF57164\",' +
			'        \"processingStatus\": \"SUBMITTED\",' +
			'        \"orderId\": \"SF57164\",' +
			'        \"dealer\": {' +
			'            \"salesAgentTcad\": \"lgh629\"' +
			'        },' +
			'        \"segment\": \"B2B\",' +
			'        \"brand\": \"teliadk\",' +
			'        \"flags\": {' +
			'            \"termsAccepted\": true,' +
			'            \"consentsAccepted\": false,' +
			'            \"cprCheckFailed\": false,' +
			'            \"creditCheckFailed\": false,' +
			'            \"needsConfirmation\": false,' +
			'            \"dirty\": true,' +
			'            \"doLogistics\": false,' +
			'            \"providerChangeAccountNumberMissing\": false,' +
			'            \"homeOfficeOrder\": true' +
			'        },' +
			'        \"createdDate\": \"2023-02-22T11:25:40.531117105+01:00\",' +
			'        \"orderer\": {' +
			'            \"type\": \"ORGANIZATION\",' +
			'            \"name\": \"2 Test Order API\",' +
			'            \"cvr\": \"77712079\",' +
			'            \"address\": {' +
			'                \"type\": \"DANISH_ADDRESS\",' +
			'                \"city\": \"København S\",' +
			'                \"zipCode\": \"2300\",' +
			'                \"country\": \"DNK\",' +
			'                \"streetName\": \"Holmbladsgade\",' +
			'                \"streetNumber\": \"133\"' +
			'            },' +
			'            \"email\": \"meghana.kumari@teliacompany.com\",' +
			'            \"customerId\": \"1000532775\"' +
			'        },' +
			'        \"orderParts\": [' +
			'            {' +
			'                \"references\": [' +
			'                    {' +
			'                        \"type\": \"BILLING_ACCOUNT_NUMBER\",' +
			'                        \"value\": \"461855314\"' +
			'                    }' +
			'                ],' +
			'                \"type\": \"ACCOUNT\",' +
			'                \"activity\": \"CHANGE\",' +
			'                \"changeTypes\": [],' +
			'                \"orderParts\": [' +
			'                    {' +
			'                        \"references\": [],' +
			'                        \"type\": \"ACCOUNT\",' +
			'                        \"activity\": \"CREATE\",' +
			'                        \"changeTypes\": [],' +
			'                        \"processingStatus\": \"RECEIVED\",' +
			'                        \"channelOrderPartId\": \"a2J7E0000019FXxUAM\",' +
			'                        \"splitOrderId\": \"SF63327\",' +
			'                        \"orderItems\": [' +
			'                            {' +
			'                                \"type\": \"ACCOUNT_ITEM\",' +
			'                                \"legalParty\": {' +
			'                                    \"type\": \"PERSON\",' +
			'                                    \"firstName\": \"Tanya\",' +
			'                                    \"lastName\": \"Nihorodova\",' +
			'                                    \"address\": {' +
			'                                        \"type\": \"DANISH_ADDRESS\",' +
			'                                        \"city\": \"Ballerup\",' +
			'                                        \"zipCode\": \"2750\",' +
			'                                        \"country\": \"DNK\",' +
			'                                        \"streetName\": \"Linde Alle\",' +
			'                                        \"streetNumber\": \"19\",' +
			'                                        \"streetNumberSuffix\": \"E\"' +
			'                                    },' +
			'                                    \"email\": \"tnihorodova@jabra.com\",' +
			'                                    \"telephoneNumber\": {' +
			'                                        \"countryCode\": \"45\",' +
			'                                        \"localNumber\": \"52766579\"' +
			'                                    }' +
			'                                },' +
			'                                \"paymentMethod\": \"GIRO\",' +
			'                                \"activity\": \"CREATE\",' +
			'                                \"id\": 8,' +
			'                                \"validationErrors\": [' +
			'                                    {' +
			'                                        \"errorCode\": \"INVALID_ORDER_ITEM\",' +
			'                                        \"parameters\": [' +
			'                                            {' +
			'                                                \"target\": \"ACCOUNT_ITEM\",' +
			'                                                \"reason\": \"legalParty  must not be null\"' +
			'                                            },' +
			'                                            {' +
			'                                                \"target\": \"ACCOUNT_ITEM\",' +
			'                                                \"reason\": \"billingCycle must not be null\"' +
			'                                            },' +
			'                                            {' +
			'                                                \"target\": \"ACCOUNT_ITEM\",' +
			'                                                \"reason\": \"invoiceType must not be null\"' +
			'                                            }' +
			'                                        ]' +
			'                                    }' +
			'                                ],' +
			'                                \"origin\": \"CLIENT\"' +
			'                            }' +
			'                        ],' +
			'                        \"orderParts\": [' +
			'                            {' +
			'                                \"references\": [],' +
			'                                \"type\": \"SUBSCRIPTION\",' +
			'                                \"activity\": \"CREATE\",' +
			'                                \"changeTypes\": [],' +
			'                        		 \"processingStatus\": \"RECEIVED\",' +
			'                                \"orderItems\": [' +
			'                                    {' +
			'                                        \"type\": \"SUBSCRIPTION_ITEM\",' +
			'                                        \"productType\": \"BROADBAND_FIBER\",' +
			'                                        \"newOffering\": {' +
			'                                            \"priceplan\": \"FIBEBTC14\",' +
			'                                            \"campaign\": \"FIBTC14PP\",' +
			'                                            \"name\": \"Telia Home - 199kr./md. Første 6 md. herefter 349kr.\",' +
			'                                            \"description\": \"Telia Home - 199kr./md. Første 6 md. herefter 349kr.\",' +
			'                                            \"bindingPeriod\": 6,' +
			'                                            \"recurringPrice\": {' +
			'                                                \"amount\": 349.0,' +
			'                                                \"currency\": \"DKK\",' +
			'                                                \"vat\": 69.8,' +
			'                                                \"catalogAmount\": 349.0,' +
			'                                                \"catalogVat\": 69.8,' +
			'                                                \"originalAmount\": 349.0,' +
			'                                                \"originalVat\": 69.8' +
			'                                            },' +
			'                                            \"technicalProduct\": \"Telia_Home_1000\",' +
			'                                            \"erpTsProduct\": \"TSA1000020\",' +
			'                                            \"characteristics\": []' +
			'                                        },' +
			'                                        \"productCategory\": \"broadband\",' +
			'                                        \"fixedNetDetails\": {' +
			'                                            \"fixedNetFlags\": {' +
			'                                                \"skipStateEvent\": false,' +
			'                                                \"skipCpeTechnician\": true,' +
			'                                                \"skipIp\": false,' +
			'                                                \"skipInvoice\": true,' +
			'                                                \"hasInstallationTypeConflict\": false,' +
			'                                                \"manualChangeProvider\": false,' +
			'                                                \"coaxDifferentProvider\": false,' +
			'                                                \"diggingNeeded\": true,' +
			'                                                \"manualOrdering\": false' +
			'                                            },' +
			'                                            \"installationAddress\": {' +
			'                                                \"postalAddress\": {' +
			'                                                    \"type\": \"DANISH_ADDRESS\",' +
			'                                                    \"city\": \"Virum\",' +
			'                                                    \"zipCode\": \"2830\",' +
			'                                                    \"country\": \"DNK\",' +
			'                                                    \"streetName\": \"Virumbakken\",' +
			'                                                    \"streetNumber\": \"1\"' +
			'                                                },' +
			'                                                \"municipalityCode\": \"0173\",' +
			'                                                \"streetCode\": \"0864\"' +
			'                                            },' +
			'                                            \"speedDown\": \"1000\",' +
			'                                            \"speedUp\": \"1000\",' +
			'                                            \"networkConfiguration\": [],' +
			'                                            \"doItYourselfInstallation\": true,' +
			'                                            \"providerReuseOfAddress\": false' +
			'                                        },' +
			'                                        \"preferredActivationDate\": \"2023-01-22\",' +
			'                                        \"activity\": \"CREATE\",' +
			'                                        \"id\": 4,' +
			'                                        \"origin\": \"CLIENT\"' +
			'                                    },' +
			'                                    {' +
			'                                        \"type\": \"ADDITIONAL_PRODUCT_ITEM\",' +
			'                                        \"productCode\": \"STATICIP\",' +
			'                                        \"productCategory\": \"VAS\",' +
			'                                        \"quantity\": 1,' +
			'                                        \"characteristics\": [],' +
			'                                        \"activity\": \"CREATE\",' +
			'                                        \"id\": 5,' +
			'                                        \"origin\": \"CLIENT\"' +
			'                                    },' +
			'                                    {' +
			'                                        \"type\": \"FEE_ITEM\",' +
			'                                        \"feeType\": \"ACT_FEE\",' +
			'                                        \"displayName\": \"FIBER Activation Fee\",' +
			'                                        \"recurring\": false,' +
			'                                        \"price\": {' +
			'                                            \"amount\": 0.0,' +
			'                                            \"currency\": \"DKK\",' +
			'                                            \"vat\": 0.0,' +
			'                                            \"catalogAmount\": 0.0,' +
			'                                            \"catalogVat\": 0.0,' +
			'                                            \"originalAmount\": 0.0,' +
			'                                            \"originalVat\": 0.0' +
			'                                        },' +
			'                                        \"activity\": \"CREATE\",' +
			'                                        \"id\": 6,' +
			'                                        \"origin\": \"CLIENT\"' +
			'                                    },' +
			'                                    {' +
			'                                        \"type\": \"FEE_ITEM\",' +
			'                                        \"feeType\": \"INSTALLATION_FEE\",' +
			'                                        \"billingCode\": \"CHXTK1\",' +
			'                                        \"displayName\": \"FIBER Installation Fee\",' +
			'                                        \"recurring\": false,' +
			'                                        \"price\": {' +
			'                                            \"amount\": 895.0,' +
			'                                            \"currency\": \"DKK\",' +
			'                                            \"vat\": 0.0,' +
			'                                            \"catalogAmount\": 895.0,' +
			'                                            \"catalogVat\": 0.0,' +
			'                                            \"originalAmount\": 895.0,' +
			'                                            \"originalVat\": 0.0' +
			'                                        },' +
			'                                        \"activity\": \"CREATE\",' +
			'                                        \"id\": 7,' +
			'                                        \"origin\": \"CLIENT\"' +
			'                                    }' +
			'                                ],' +
			'                                \"id\": 3,' +
			'                                \"partTotal\": {' +
			'                                    \"amount\": 895.0,' +
			'                                    \"currency\": \"DKK\",' +
			'                                    \"vat\": 0.0,' +
			'                                    \"catalogAmount\": 895.0,' +
			'                                    \"catalogVat\": 0.0,' +
			'                                    \"originalAmount\": 895.0,' +
			'                                    \"originalVat\": 0.0' +
			'                                },' +
			'                                \"servicesRecurringTotal\": {' +
			'                                    \"amount\": 349.0,' +
			'                                    \"currency\": \"DKK\",' +
			'                                    \"vat\": 69.8,' +
			'                                    \"catalogAmount\": 349.0,' +
			'                                    \"catalogVat\": 69.8,' +
			'                                    \"originalAmount\": 349.0,' +
			'                                    \"originalVat\": 69.8' +
			'                                },' +
			'                                \"minimumPrice\": {' +
			'                                    \"amount\": 2989.0,' +
			'                                    \"currency\": \"DKK\",' +
			'                                    \"vat\": 418.8,' +
			'                                    \"catalogAmount\": 2989.0,' +
			'                                    \"catalogVat\": 418.8,' +
			'                                    \"originalAmount\": 2989.0,' +
			'                                    \"originalVat\": 418.8' +
			'                                },' +
			'                                \"firstMonthPrice\": {' +
			'                                    \"amount\": 349.0,' +
			'                                    \"currency\": \"DKK\",' +
			'                                    \"vat\": 69.8,' +
			'                                    \"catalogAmount\": 349.0,' +
			'                                    \"catalogVat\": 69.8,' +
			'                                    \"originalAmount\": 349.0,' +
			'                                    \"originalVat\": 69.8' +
			'                                }' +
			'                            }' +
			'                        ],' +
			'                        \"id\": 2,' +
			'                        \"partTotal\": {' +
			'                            \"amount\": 895.0,' +
			'                            \"currency\": \"DKK\",' +
			'                            \"vat\": 0.0,' +
			'                            \"catalogAmount\": 895.0,' +
			'                            \"catalogVat\": 0.0,' +
			'                            \"originalAmount\": 895.0,' +
			'                            \"originalVat\": 0.0' +
			'                        },' +
			'                        \"servicesRecurringTotal\": {' +
			'                            \"amount\": 349.0,' +
			'                            \"currency\": \"DKK\",' +
			'                            \"vat\": 69.8,' +
			'                            \"catalogAmount\": 349.0,' +
			'                            \"catalogVat\": 69.8,' +
			'                            \"originalAmount\": 349.0,' +
			'                            \"originalVat\": 69.8' +
			'                        },' +
			'                        \"minimumPrice\": {' +
			'                            \"amount\": 2989.0,' +
			'                            \"currency\": \"DKK\",' +
			'                            \"vat\": 418.8,' +
			'                            \"catalogAmount\": 2989.0,' +
			'                            \"catalogVat\": 418.8,' +
			'                            \"originalAmount\": 2989.0,' +
			'                            \"originalVat\": 418.8' +
			'                        },' +
			'                        \"firstMonthPrice\": {' +
			'                            \"amount\": 349.0,' +
			'                            \"currency\": \"DKK\",' +
			'                            \"vat\": 69.8,' +
			'                            \"catalogAmount\": 349.0,' +
			'                            \"catalogVat\": 69.8,' +
			'                            \"originalAmount\": 349.0,' +
			'                            \"originalVat\": 69.8' +
			'                        }' +
			'                    }' +
			'                ],' +
			'                \"validationErrors\": [],' +
			'                \"id\": 1,' +
			'                \"partTotal\": {' +
			'                    \"amount\": 895.0,' +
			'                    \"currency\": \"DKK\",' +
			'                    \"vat\": 0.0,' +
			'                    \"catalogAmount\": 895.0,' +
			'                    \"catalogVat\": 0.0,' +
			'                    \"originalAmount\": 895.0,' +
			'                    \"originalVat\": 0.0' +
			'                },' +
			'                \"servicesRecurringTotal\": {' +
			'                    \"amount\": 349.0,' +
			'                    \"currency\": \"DKK\",' +
			'                    \"vat\": 69.8,' +
			'                    \"catalogAmount\": 349.0,' +
			'                    \"catalogVat\": 69.8,' +
			'                    \"originalAmount\": 349.0,' +
			'                    \"originalVat\": 69.8' +
			'                },' +
			'                \"minimumPrice\": {' +
			'                    \"amount\": 2989.0,' +
			'                    \"currency\": \"DKK\",' +
			'                    \"vat\": 418.8,' +
			'                    \"catalogAmount\": 2989.0,' +
			'                    \"catalogVat\": 418.8,' +
			'                    \"originalAmount\": 2989.0,' +
			'                    \"originalVat\": 418.8' +
			'                },' +
			'                \"firstMonthPrice\": {' +
			'                    \"amount\": 349.0,' +
			'                    \"currency\": \"DKK\",' +
			'                    \"vat\": 69.8,' +
			'                    \"catalogAmount\": 349.0,' +
			'                    \"catalogVat\": 69.8,' +
			'                    \"originalAmount\": 349.0,' +
			'                    \"originalVat\": 69.8' +
			'                }' +
			'            }' +
			'        ],' +
			'        \"validationErrors\": [' +
			'            {' +
			'                \"errorCode\": \"INVALID_DEALER\",' +
			'                \"parameters\": [' +
			'                    {' +
			'                        \"reason\": \"Dealer code must not be null\"' +
			'                    }' +
			'                ]' +
			'            },' +
			'            {' +
			'                \"errorCode\": \"INVALID_HW_DELIVERY\",' +
			'                \"parameters\": [' +
			'                    {' +
			'                        \"target\": \"HARDWARE_DELIVERIES ID: 1\",' +
			'                        \"reason\": \"firstName and lastName must not be null\"' +
			'                    }' +
			'                ]' +
			'            }' +
			'        ],' +
			'        \"hasValidationErrors\": true,' +
			'        \"hardwareDeliveries\": [' +
			'            {' +
			'                \"id\": 1,' +
			'                \"recipientParty\": {' +
			'                    \"type\": \"PERSON\",' +
			'                    \"firstName\": \"Tanya\",' +
			'                    \"lastName\": \"Nihorodova\",' +
			'                    \"address\": {' +
			'                        \"type\": \"DANISH_ADDRESS\",' +
			'                        \"city\": \"Ballerup\",' +
			'                        \"zipCode\": \"2750\",' +
			'                        \"country\": \"DNK\",' +
			'                        \"streetName\": \"Shipping Alle\",' +
			'                        \"streetNumber\": \"18\",' +
			'                        \"streetNumberSuffix\": \"E\"' +
			'                    },' +
			'                    \"email\": \"tnihorodova@jabra.com\",' +
			'                    \"customerId\": \"12345678\",' +
			'                    \"telephoneNumber\": {' +
			'                        \"countryCode\": \"45\",' +
			'                        \"localNumber\": \"52766579\"' +
			'                    }' +
			'                },' +
			'                \"billingParty\": {' +
			'                    \"type\": \"PERSON\",' +
			'                    \"firstName\": \"Tanya\",' +
			'                    \"lastName\": \"Nihorodova\",' +
			'                    \"address\": {' +
			'                        \"type\": \"DANISH_ADDRESS\",' +
			'                        \"city\": \"Ballerup\",' +
			'                        \"zipCode\": \"2750\",' +
			'                        \"country\": \"DNK\",' +
			'                        \"streetName\": \"Shipping Alle\",' +
			'                        \"streetNumber\": \"18\",' +
			'                        \"streetNumberSuffix\": \"E\"' +
			'                    },' +
			'                    \"email\": \"tnihorodova@jabra.com\",' +
			'                    \"customerId\": \"12345678\",' +
			'                    \"telephoneNumber\": {' +
			'                        \"countryCode\": \"45\",' +
			'                        \"localNumber\": \"52766579\"' +
			'                    }' +
			'                },' +
			'                \"deliveryMethod\": \"POST\",' +
			'                \"preferredContactMethod\": \"PHONE\",' +
			'                \"preferredSendDate\": \"2020-09-26\"' +
			'            }' +
			'        ],' +
			'        \"orderTotal\": {' +
			'            \"amount\": 895.0,' +
			'            \"currency\": \"DKK\",' +
			'            \"vat\": 0.0,' +
			'            \"catalogAmount\": 895.0,' +
			'            \"catalogVat\": 0.0,' +
			'            \"originalAmount\": 895.0,' +
			'            \"originalVat\": 0.0' +
			'        },' +
			'        \"servicesRecurringTotal\": {' +
			'            \"amount\": 349.0,' +
			'            \"currency\": \"DKK\",' +
			'            \"vat\": 69.8,' +
			'            \"catalogAmount\": 349.0,' +
			'            \"catalogVat\": 69.8,' +
			'            \"originalAmount\": 349.0,' +
			'            \"originalVat\": 69.8' +
			'        },' +
			'        \"orderMinimumPrice\": {' +
			'            \"amount\": 2989.0,' +
			'            \"currency\": \"DKK\",' +
			'            \"vat\": 418.8,' +
			'            \"catalogAmount\": 2989.0,' +
			'            \"catalogVat\": 418.8,' +
			'            \"originalAmount\": 2989.0,' +
			'            \"originalVat\": 418.8' +
			'        },' +
			'        \"firstMonthPrice\": {' +
			'            \"amount\": 349.0,' +
			'            \"currency\": \"DKK\",' +
			'            \"vat\": 69.8,' +
			'            \"catalogAmount\": 349.0,' +
			'            \"catalogVat\": 69.8,' +
			'            \"originalAmount\": 349.0,' +
			'            \"originalVat\": 69.8' +
			'        },' +
			'        \"documents\": []' +
			'    }' +
			'}';

		Test.startTest();
		OrderResDAO r = OrderResDAO.parse(json);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.OrderItems objOrderItems = new OrderResDAO.OrderItems(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.Address objAddress = new OrderResDAO.Address(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.RecurringPrice objRecurringPrice = new OrderResDAO.RecurringPrice(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.HardwareDeliveries objHardwareDeliveries = new OrderResDAO.HardwareDeliveries(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.TelephoneNumber objTelephoneNumber = new OrderResDAO.TelephoneNumber(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.LegalParty objLegalParty = new OrderResDAO.LegalParty(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.InstallationAddress objInstallationAddress = new OrderResDAO.InstallationAddress(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.FixedNetDetails objFixedNetDetails = new OrderResDAO.FixedNetDetails(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.FixedNetFlags objFixedNetFlags = new OrderResDAO.FixedNetFlags(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.RecipientParty objRecipientParty = new OrderResDAO.RecipientParty(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.OrderPartsRoot objOrderPartsRoot = new OrderResDAO.OrderPartsRoot(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.Orderer objOrderer = new OrderResDAO.Orderer(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.Parameters objParameters = new OrderResDAO.Parameters(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.NewOffering objNewOffering = new OrderResDAO.NewOffering(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.Data objData = new OrderResDAO.Data(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.Flags objFlags = new OrderResDAO.Flags(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO objOrderResDAO = new OrderResDAO(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.ValidationErrors objValidationErrors = new OrderResDAO.ValidationErrors(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.References objReferences = new OrderResDAO.References(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.OrderPartsAccount objOrderPartsAccounts = new OrderResDAO.OrderPartsAccount(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.OrderPartsSubscription objOrderPartsSubscription = new OrderResDAO.OrderPartsSubscription(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.ChangeTypes objChangeTypes = new OrderResDAO.ChangeTypes(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderResDAO.Dealer objDealer = new OrderResDAO.Dealer(System.JSON.createParser(json));

		Test.stopTest();

		Assert.isTrue(r != null);

		Assert.isTrue(objOrderItems != null);
		Assert.isTrue(objOrderItems.type == null);

		Assert.isTrue(objOrderItems.legalParty == null);
		Assert.isTrue(objOrderItems.paymentMethod == null);
		Assert.isTrue(objOrderItems.activity == null);
		Assert.isTrue(objOrderItems.id == null);
		Assert.isTrue(objOrderItems.validationErrors == null);
		Assert.isTrue(objOrderItems.origin == null);

		Assert.isTrue(objOrderItems.productType == null);
		Assert.isTrue(objOrderItems.newOffering == null);
		Assert.isTrue(objOrderItems.productCategory == null);
		Assert.isTrue(objOrderItems.fixedNetDetails == null);
		Assert.isTrue(objOrderItems.preferredActivationDate == null);
		Assert.isTrue(objOrderItems.activity == null);
		Assert.isTrue(objOrderItems.productCode == null);
		Assert.isTrue(objOrderItems.quantity == null);
		Assert.isTrue(objOrderItems.characteristics == null);
		Assert.isTrue(objOrderItems.feeType == null);
		Assert.isTrue(objOrderItems.displayName == null);
		Assert.isTrue(objOrderItems.recurring == null);
		Assert.isTrue(objOrderItems.price == null);
		Assert.isTrue(objOrderItems.billingCode == null);

		Assert.isTrue(objAddress != null);
		Assert.isTrue(objAddress.type == null);
		Assert.isTrue(objAddress.city == null);
		Assert.isTrue(objAddress.zipCode == null);
		Assert.isTrue(objAddress.country == null);
		Assert.isTrue(objAddress.streetName == null);
		Assert.isTrue(objAddress.streetNumber == null);
		Assert.isTrue(objAddress.streetNumberSuffix == null);

		Assert.isTrue(objRecurringPrice != null);
		Assert.isTrue(objRecurringPrice.amount == null);
		Assert.isTrue(objRecurringPrice.vat == null);
		Assert.isTrue(objRecurringPrice.catalogAmount == null);
		Assert.isTrue(objRecurringPrice.catalogVat == null);
		Assert.isTrue(objRecurringPrice.originalAmount == null);
		Assert.isTrue(objRecurringPrice.originalVat == null);

		Assert.isTrue(objHardwareDeliveries != null);
		Assert.isTrue(objHardwareDeliveries.id == null);
		Assert.isTrue(objHardwareDeliveries.recipientParty == null);
		Assert.isTrue(objHardwareDeliveries.billingParty == null);
		Assert.isTrue(objHardwareDeliveries.deliveryMethod == null);
		Assert.isTrue(objHardwareDeliveries.preferredContactMethod == null);
		Assert.isTrue(objHardwareDeliveries.preferredSendDate == null);

		Assert.isTrue(objTelephoneNumber != null);
		Assert.isTrue(objTelephoneNumber.countryCode == null);
		Assert.isTrue(objTelephoneNumber.localNumber == null);

		Assert.isTrue(objLegalParty != null);
		Assert.isTrue(objLegalParty.type == null);
		Assert.isTrue(objLegalParty.firstName == null);
		Assert.isTrue(objLegalParty.lastName == null);
		Assert.isTrue(objLegalParty.address == null);
		Assert.isTrue(objLegalParty.email == null);
		Assert.isTrue(objLegalParty.telephoneNumber == null);

		Assert.isTrue(objInstallationAddress != null);
		Assert.isTrue(objInstallationAddress.postalAddress == null);
		Assert.isTrue(objInstallationAddress.municipalityCode == null);
		Assert.isTrue(objInstallationAddress.streetCode == null);

		Assert.isTrue(objFixedNetDetails != null);
		Assert.isTrue(objFixedNetDetails.fixedNetFlags == null);
		Assert.isTrue(objFixedNetDetails.installationAddress == null);
		Assert.isTrue(objFixedNetDetails.speedDown == null);
		Assert.isTrue(objFixedNetDetails.speedUp == null);
		Assert.isTrue(objFixedNetDetails.networkConfiguration == null);
		Assert.isTrue(objFixedNetDetails.doItYourselfInstallation == null);
		Assert.isTrue(objFixedNetDetails.providerReuseOfAddress == null);

		Assert.isTrue(objFixedNetFlags != null);
		Assert.isTrue(objFixedNetFlags.skipStateEvent == null);
		Assert.isTrue(objFixedNetFlags.skipCpeTechnician == null);
		Assert.isTrue(objFixedNetFlags.skipIp == null);
		Assert.isTrue(objFixedNetFlags.skipInvoice == null);
		Assert.isTrue(objFixedNetFlags.hasInstallationTypeConflict == null);
		Assert.isTrue(objFixedNetFlags.manualChangeProvider == null);
		Assert.isTrue(objFixedNetFlags.coaxDifferentProvider == null);
		Assert.isTrue(objFixedNetFlags.diggingNeeded == null);
		Assert.isTrue(objFixedNetFlags.manualOrdering == null);

		Assert.isTrue(objRecipientParty != null);
		Assert.isTrue(objRecipientParty.type == null);
		Assert.isTrue(objRecipientParty.firstName == null);
		Assert.isTrue(objRecipientParty.lastName == null);
		Assert.isTrue(objRecipientParty.address == null);
		Assert.isTrue(objRecipientParty.email == null);
		Assert.isTrue(objRecipientParty.customerId == null);
		Assert.isTrue(objRecipientParty.telephoneNumber == null);

		Assert.isTrue(objOrderPartsRoot != null);
		Assert.isTrue(objOrderPartsRoot.references == null);
		Assert.isTrue(objOrderPartsRoot.type == null);
		Assert.isTrue(objOrderPartsRoot.activity == null);
		Assert.isTrue(objOrderPartsRoot.changeTypes == null);
		Assert.isTrue(objOrderPartsRoot.orderParts == null);
		Assert.isTrue(objOrderPartsRoot.id == null);
		Assert.isTrue(objOrderPartsRoot.partTotal == null);
		Assert.isTrue(objOrderPartsRoot.servicesRecurringTotal == null);
		Assert.isTrue(objOrderPartsRoot.minimumPrice == null);
		Assert.isTrue(objOrderPartsRoot.firstMonthPrice == null);

		Assert.isTrue(objOrderer != null);
		Assert.isTrue(objOrderer.type == null);
		Assert.isTrue(objOrderer.name == null);
		Assert.isTrue(objOrderer.cvr == null);
		Assert.isTrue(objOrderer.address == null);
		Assert.isTrue(objOrderer.email == null);
		Assert.isTrue(objOrderer.customerId == null);

		Assert.isTrue(objParameters != null);
		Assert.isTrue(objParameters.target == null);
		Assert.isTrue(objParameters.reason == null);

		Assert.isTrue(objNewOffering != null);
		Assert.isTrue(objNewOffering.priceplan == null);
		Assert.isTrue(objNewOffering.campaign == null);
		Assert.isTrue(objNewOffering.name == null);
		Assert.isTrue(objNewOffering.description == null);
		Assert.isTrue(objNewOffering.bindingPeriod == null);
		Assert.isTrue(objNewOffering.recurringPrice == null);
		Assert.isTrue(objNewOffering.technicalProduct == null);
		Assert.isTrue(objNewOffering.erpTsProduct == null);
		Assert.isTrue(objNewOffering.characteristics == null);

		Assert.isTrue(objData != null);
		Assert.isTrue(objData.id == null);
		Assert.isTrue(objData.orderId == null);
		Assert.isTrue(objData.channelOrderReference == null);
		Assert.isTrue(objData.processingStatus == null);
		Assert.isTrue(objData.channel == null);
		Assert.isTrue(objData.dealer == null);
		Assert.isTrue(objData.segment == null);
		Assert.isTrue(objData.brand == null);
		Assert.isTrue(objData.flags == null);
		Assert.isTrue(objData.createdDate == null);
		Assert.isTrue(objData.orderer == null);
		Assert.isTrue(objData.orderParts == null);
		Assert.isTrue(objData.validationErrors == null);
		Assert.isTrue(objData.hasValidationErrors == null);
		Assert.isTrue(objData.hardwareDeliveries == null);
		Assert.isTrue(objData.orderTotal == null);
		Assert.isTrue(objData.servicesRecurringTotal == null);
		Assert.isTrue(objData.orderMinimumPrice == null);
		Assert.isTrue(objData.firstMonthPrice == null);
		Assert.isTrue(objData.documents == null);

		Assert.isTrue(objFlags != null);
		Assert.isTrue(objFlags.termsAccepted == null);
		Assert.isTrue(objFlags.consentsAccepted == null);
		Assert.isTrue(objFlags.cprCheckFailed == null);
		Assert.isTrue(objFlags.creditCheckFailed == null);
		Assert.isTrue(objFlags.needsConfirmation == null);
		Assert.isTrue(objFlags.dirty == null);
		Assert.isTrue(objFlags.doLogistics == null);
		Assert.isTrue(objFlags.providerChangeAccountNumberMissing == null);
		Assert.isTrue(objFlags.homeOfficeOrder == null);

		Assert.isTrue(objOrderResDAO != null);
		Assert.isTrue(objOrderResDAO.data == null);

		Assert.isTrue(objValidationErrors != null);
		Assert.isTrue(objValidationErrors.errorCode == null);
		Assert.isTrue(objValidationErrors.parameters == null);

		Assert.isTrue(objReferences != null);
		Assert.isTrue(objReferences.type == null);
		Assert.isTrue(objReferences.value == null);

		Assert.isTrue(objOrderPartsAccounts != null);
		Assert.isTrue(objOrderPartsAccounts.references == null);
		Assert.isTrue(objOrderPartsAccounts.type == null);
		Assert.isTrue(objOrderPartsAccounts.processingStatus == null);
		Assert.isTrue(objOrderPartsAccounts.activity == null);
		Assert.isTrue(objOrderPartsAccounts.changeTypes == null);
		Assert.isTrue(objOrderPartsAccounts.orderItems == null);
		Assert.isTrue(objOrderPartsAccounts.orderParts == null);
		Assert.isTrue(objOrderPartsAccounts.id == null);
		Assert.isTrue(objOrderPartsAccounts.partTotal == null);
		Assert.isTrue(objOrderPartsAccounts.servicesRecurringTotal == null);
		Assert.isTrue(objOrderPartsAccounts.minimumPrice == null);
		Assert.isTrue(objOrderPartsAccounts.firstMonthPrice == null);
		Assert.isTrue(objOrderPartsAccounts.channelOrderPartId == null);
		Assert.isTrue(objOrderPartsAccounts.splitOrderId == null);

		Assert.isTrue(objOrderPartsSubscription != null);
		Assert.isTrue(objOrderPartsSubscription.references == null);
		Assert.isTrue(objOrderPartsSubscription.type == null);
		Assert.isTrue(objOrderPartsSubscription.processingStatus == null);
		Assert.isTrue(objOrderPartsSubscription.activity == null);
		Assert.isTrue(objOrderPartsSubscription.changeTypes == null);
		Assert.isTrue(objOrderPartsSubscription.orderItems == null);
		Assert.isTrue(objOrderPartsSubscription.validationErrors == null);
		Assert.isTrue(objOrderPartsSubscription.id == null);
		Assert.isTrue(objOrderPartsSubscription.partTotal == null);
		Assert.isTrue(objOrderPartsSubscription.servicesRecurringTotal == null);
		Assert.isTrue(objOrderPartsSubscription.minimumPrice == null);
		Assert.isTrue(objOrderPartsSubscription.firstMonthPrice == null);

		Assert.isTrue(objChangeTypes != null);

		Assert.isTrue(objDealer != null);
		Assert.isTrue(objDealer.salesAgentTcad == null);
	}
}