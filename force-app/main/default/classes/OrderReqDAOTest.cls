/**
 *
 * @author Mujahid
 * @since 24/02/2023
 */
@IsTest
public class OrderReqDAOTest {
	// This test method should give 100% coverage
	@IsTest
	static void testParse() {
		String json =
			'{' +
			'    \"brand\": \"teliadk\",' +
			'    \"channel\": \"SALES_FORCE\",' +
			'    \"segment\": \"B2B\",' +
			'    \"dealer\": {' +
			'        \"dealerCode\": \"7500\",' +
			'        \"salesAgentTcad\": \"lgh629\"' +
			'    },' +
			'    \"flags\": {' +
			'        \"needsConfirmation\": false,' +
			'        \"consentsAccepted\": false,' +
			'        \"termsAccepted\": true,' +
			'        \"dirty\": true' +
			'    },' +
			'    \"orderParts\": [' +
			'        {' +
			'            \"type\": \"ACCOUNT\",' +
			'            \"activity\": \"CHANGE\",' +
			'            \"references\": [' +
			'                {' +
			'                    \"type\": \"BILLING_ACCOUNT_NUMBER\",' +
			'                    \"value\": \"461855314\"' +
			'                }' +
			'            ],' +
			'            \"orderParts\": [' +
			'                {' +
			'                    \"type\": \"ACCOUNT\",' +
			'                    \"activity\": \"CREATE\",' +
			'                    \"channelOrderPartId\": \"a2J7E0000019FXxUAM\",' +
			'                    \"orderItems\": [' +
			'                        {' +
			'                            \"type\": \"ACCOUNT_ITEM\",' +
			'                            \"activity\": \"CREATE\",' +
			'                            \"paymentMethod\": \"GIRO\",' +
			'                            \"billingCycle\": \"Monthly\",' +
			'                            \"invoiceType\": \"PDF\",' +
			'                            \"legalParty\": {' +
			'                                \"type\": \"PERSON\",' +
			'                                \"firstName\": \"Tanya\",' +
			'                                \"lastName\": \"Nihorodova\",' +
			'                                \"address\": {' +
			'                                    \"streetName\": \"Linde Alle\",' +
			'                                    \"streetNumber\": \"19\",' +
			'                                    \"streetNumberSuffix\": \"E\",' +
			'                                    \"floorNumber\": \"2\",' +
			'                                    \"doorNumber\": \"2\",' +
			'                                    \"direction\": \"th\",' +
			'                                    \"city\": \"Ballerup\",' +
			'                                    \"zipCode\": \"2750\",' +
			'                                    \"country\": \"DNK\"' +
			'                                },' +
			'                                \"telephoneNumber\": {' +
			'                                    \"countryCode\": \"45\",' +
			'                                    \"localNumber\": \"52766579\"' +
			'                                },' +
			'                                \"email\": \"tnihorodova@jabra.com\"' +
			'                            }' +
			'                        }' +
			'                    ],' +
			'                    \"orderParts\": [' +
			'                        {' +
			'                            \"type\": \"SUBSCRIPTION\",' +
			'                            \"activity\": \"CREATE\",' +
			'                            \"orderItems\": [' +
			'                                {' +
			'                                    \"type\": \"SUBSCRIPTION_ITEM\",' +
			'                                    \"activity\": \"CREATE\",' +
			'                                    \"newOffering\": {' +
			'                                        \"priceplan\": \"FIBEBTC14\",' +
			'                                        \"campaign\": \"FIBTC14PP\"' +
			'                                    },' +
			'                                    \"fixedNetDetails\": {' +
			'                                        \"fixedNetFlags\": {' +
			'                                            \"diggingNeeded\": true,' +
			'                                            \"customerRequestsChangeProvider\": true,' +
			'                                            \"plugPresentPositiveValidation\": true,' +
			'                                            \"activeBlockingLinePresent\": true,' +
			'                                            \"plugTechnicianRequired\": true' +
			'                                        },' +
			'                                        \"installationAddress\": {' +
			'                                            \"municipalityCode\": \"0173\",' +
			'                                            \"streetCode\": \"0864\",' +
			'                                            \"postalAddress\": {' +
			'                                                \"streetName\": \"Virumbakken\",' +
			'                                                \"streetNumber\": \"1\",' +
			'                                                \"streetNumberSuffix\": null,' +
			'                                                \"city\": \"Virum\",' +
			'                                                \"zipCode\": \"2830\",' +
			'                                                \"country\": \"DNK\"' +
			'                                            }' +
			'                                        },' +
			'                                        \"speedUp\": \"1000\",' +
			'                                        \"speedDown\": \"1000\",' +
			'                                        \"doItYourselfInstallation\": true,' +
			'                                        \"providerReuseOfAddress\": false,' +
			'                                        \"previousEmployerAdminEmail\": \"dattatraya.gavhane@teliacompany.com\"' +
			'                                    },' +
			'                                    \"preferredActivationDate\": \"2023-01-22\",' +
			'                                    \"productDeliveryAsap\": false' +
			'                                },' +
			'                                {' +
			'                                    \"type\": \"ADDITIONAL_PRODUCT_ITEM\",' +
			'                                    \"activity\": \"CREATE\",' +
			'                                    \"productCategory\": \"VAS\",' +
			'                                    \"productCode\": \"STATICIP\",' +
			'                                    \"quantity\": 1' +
			'                                },' +
			'                                {' +
			'                                    \"type\": \"FEE_ITEM\",' +
			'                                    \"activity\": \"CREATE\",' +
			'                                    \"feeId\": \"FIBERACTFEE\",' +
			'                                    \"feeType\": \"ACT_FEE\",' +
			'                                    \"displayName\": \"FIBER Activation Fee\",' +
			'                                    \"price\": {' +
			'                                        \"amount\": 0.0,' +
			'                                        \"currency\": \"DKK\",' +
			'                                        \"vat\": 0.0' +
			'                                    },' +
			'                                    \"recurring\": false' +
			'                                },' +
			'                                {' +
			'                                    \"type\": \"FEE_ITEM\",' +
			'                                    \"feeId\": \"FIBERINSTFEE\",' +
			'                                    \"activity\": \"CREATE\",' +
			'                                    \"feeType\": \"INSTALLATION_FEE\",' +
			'                                    \"displayName\": \"FIBER Installation Fee\",' +
			'                                    \"billingCode\": \"CHXTK1\",' +
			'                                    \"price\": {' +
			'                                        \"amount\": 895.0,' +
			'                                        \"currency\": \"DKK\",' +
			'                                        \"vat\": 0.0' +
			'                                    },' +
			'                                    \"recurring\": false' +
			'                                }' +
			'                            ]' +
			'                        }' +
			'                    ]' +
			'                }' +
			'            ]' +
			'        }' +
			'    ]' +
			'}';

		Test.startTest();
		OrderReqDAO r = OrderReqDAO.parse(json);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO.Address objAddress = new OrderReqDAO.Address(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO.NewOffering objNewOffering = new OrderReqDAO.NewOffering(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO.Flags objFlags = new OrderReqDAO.Flags(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO.TelephoneNumber objTelephoneNumber = new OrderReqDAO.TelephoneNumber(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO.LegalParty objLegalParty = new OrderReqDAO.LegalParty(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO.InstallationAddress objInstallationAddress = new OrderReqDAO.InstallationAddress(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO.FixedNetDetails objFixedNetDetails = new OrderReqDAO.FixedNetDetails(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO objOrderReqDAO = new OrderReqDAO(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO.Price objPrice = new OrderReqDAO.Price(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO.References objReferences = new OrderReqDAO.References(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO.OrderItems objOrderItems = new OrderReqDAO.OrderItems(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO.FixedNetFlags objFixedNetFlags = new OrderReqDAO.FixedNetFlags(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO.OrderParts objOrderParts = new OrderReqDAO.OrderParts(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		OrderReqDAO.Dealer objDealer = new OrderReqDAO.Dealer(System.JSON.createParser(json));

		Test.stopTest();

		Assert.isTrue(r != null);

		Assert.isTrue(objAddress != null);
		Assert.isTrue(objAddress.streetName == null);
		Assert.isTrue(objAddress.streetNumber == null);
		Assert.isTrue(objAddress.streetNumberSuffix == null);
		Assert.isTrue(objAddress.city == null);
		Assert.isTrue(objAddress.zipCode == null);
		Assert.isTrue(objAddress.country == null);

		Assert.isTrue(objNewOffering != null);
		Assert.isTrue(objNewOffering.priceplan == null);
		Assert.isTrue(objNewOffering.campaign == null);

		Assert.isTrue(objFlags != null);
		Assert.isTrue(objFlags.needsConfirmation == null);
		Assert.isTrue(objFlags.consentsAccepted == null);
		Assert.isTrue(objFlags.termsAccepted == null);
		Assert.isTrue(objFlags.dirty == null);

		Assert.isTrue(objTelephoneNumber != null);
		Assert.isTrue(objTelephoneNumber.countryCode == null);
		Assert.isTrue(objTelephoneNumber.localNumber == null);

		Assert.isTrue(objLegalParty != null);
		Assert.isTrue(objLegalParty.type == null);
		Assert.isTrue(objLegalParty.firstName == null);
		Assert.isTrue(objLegalParty.lastName == null);
		Assert.isTrue(objLegalParty.address == null);
		Assert.isTrue(objLegalParty.telephoneNumber == null);
		Assert.isTrue(objLegalParty.email == null);

		Assert.isTrue(objInstallationAddress != null);
		Assert.isTrue(objInstallationAddress.municipalityCode == null);
		Assert.isTrue(objInstallationAddress.streetCode == null);
		Assert.isTrue(objInstallationAddress.postalAddress == null);
		Assert.isTrue(objInstallationAddress.addressRefId == null);
		Assert.isTrue(objInstallationAddress.siteId == null);

		Assert.isTrue(objFixedNetDetails != null);
		Assert.isTrue(objFixedNetDetails.fixedNetFlags == null);
		Assert.isTrue(objFixedNetDetails.installationAddress == null);
		Assert.isTrue(objFixedNetDetails.speedUp == null);
		Assert.isTrue(objFixedNetDetails.speedDown == null);
		Assert.isTrue(objFixedNetDetails.doItYourselfInstallation == null);
		Assert.isTrue(objFixedNetDetails.providerReuseOfAddress == null);
		Assert.isTrue(objFixedNetDetails.previousEmployerAdminEmail == null);
		Assert.isTrue(objFixedNetDetails.vendor == null);
		Assert.isTrue(objFixedNetDetails.vendorProductCatalogId == null);
		Assert.isTrue(objFixedNetDetails.vendorProductCode == null);
		Assert.isTrue(objFixedNetDetails.lineConnectionStatus == null);

		Assert.isTrue(objOrderReqDAO != null);
		Assert.isTrue(objOrderReqDAO.brand == null);
		Assert.isTrue(objOrderReqDAO.channel == null);
		Assert.isTrue(objOrderReqDAO.segment == null);
		Assert.isTrue(objOrderReqDAO.dealer == null);
		Assert.isTrue(objOrderReqDAO.flags == null);
		Assert.isTrue(objOrderReqDAO.orderParts == null);

		Assert.isTrue(objPrice != null);
		Assert.isTrue(objPrice.amount == null);
		Assert.isTrue(objPrice.currency_Z == null);
		Assert.isTrue(objPrice.vat == null);

		Assert.isTrue(objReferences != null);
		Assert.isTrue(objReferences.type == null);
		Assert.isTrue(objReferences.value == null);

		Assert.isTrue(objOrderItems != null);
		Assert.isTrue(objOrderItems.type == null);
		Assert.isTrue(objOrderItems.activity == null);
		Assert.isTrue(objOrderItems.newOffering == null);
		Assert.isTrue(objOrderItems.fixedNetDetails == null);
		Assert.isTrue(objOrderItems.preferredActivationDate == null);
		Assert.isTrue(objOrderItems.productDeliveryAsap == null);
		Assert.isTrue(objOrderItems.productCategory == null);
		Assert.isTrue(objOrderItems.productCode == null);
		Assert.isTrue(objOrderItems.quantity == null);
		Assert.isTrue(objOrderItems.feeId == null);
		Assert.isTrue(objOrderItems.feeType == null);
		Assert.isTrue(objOrderItems.displayName == null);
		Assert.isTrue(objOrderItems.price == null);
		Assert.isTrue(objOrderItems.recurring == null);
		Assert.isTrue(objOrderItems.billingCode == null);
		Assert.isTrue(objOrderItems.paymentMethod == null);
		Assert.isTrue(objOrderItems.legalParty == null);

		Assert.isTrue(objFixedNetFlags != null);
		Assert.isTrue(objFixedNetFlags.diggingNeeded == null);

		Assert.isTrue(objOrderParts != null);
		Assert.isTrue(objOrderParts.type == null);
		Assert.isTrue(objOrderParts.activity == null);
		Assert.isTrue(objOrderParts.orderItems == null);
		Assert.isTrue(objOrderParts.orderParts == null);
		Assert.isTrue(objOrderParts.references == null);
		Assert.isTrue(objOrderParts.channelOrderPartId == null);

		Assert.isTrue(objDealer != null);
		Assert.isTrue(objDealer.dealerCode == null);
		Assert.isTrue(objDealer.salesAgentTcad == null);
	}
}