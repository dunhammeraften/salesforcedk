/**
 * @author Mujahid
 * @since 23/01/2023
 */

@IsTest
public class RootBanReqDAOTest {
	static testMethod void testParse() {
		String json =
			'{' +
			'    \"brand\": \"teliadk\",' +
			'    \"segment\": \"B2B\",' +
			'    \"channel\": \"SALES_FORCE\",' +
			'    \"dealer\": {' +
			'        \"salesAgentCode\": \"22334\",' +
			'        \"dealerCode\": \"1018\"' +
			'    },' +
			'    \"orderer\": {' +
			'        \"type\": \"ORGANIZATION\",' +
			'        \"telephoneNumber\": {' +
			'            \"countryCode\": \"45\",' +
			'            \"localNumber\": \"73193137\"' +
			'        },' +
			'        \"name\": \"Test A/S\",' +
			'        \"cvr\": \"77712079\",' +
			'        \"address\": {' +
			'            \"zipCode\": \"2300\",' +
			'            \"streetNumber\": \"133\",' +
			'            \"streetName\": \"Holmbladsgade\",' +
			'            \"city\": \"København\",' +
			'            \"country\": \"DNK\"' +
			'        }' +
			'    },' +
			'    \"orderParts\": [' +
			'        {' +
			'            \"type\": \"ACCOUNT\",' +
			'            \"activity\": \"CREATE\",' +
			'            \"references\": [],' +
			'            \"orderItems\": [' +
			'                {' +
			'                    \"type\": \"ACCOUNT_ITEM\",' +
			'                    \"activity\": \"CREATE\",' +
			'                    \"billingCycle\": \"MONTHLY\",' +
			'                    \"invoiceType\": \"PDF_BY_EMAIL\",' +
			'                    \"label\": \"My account\",' +
			'                    \"upTransferChargeCode\": \"THOD22\",' +
			'                    \"legalParty\": {' +
			'                        \"type\": \"ORGANIZATION\",' +
			'                        \"telephoneNumber\": {' +
			'                            \"countryCode\": \"45\",' +
			'                            \"localNumber\": \"73193137\"' +
			'                        },' +
			'                        \"name\": \"Test A/S\",' +
			'                        \"cvr\": \"77712079\",' +
			'                        \"address\": {' +
			'                            \"type\": \"DANISH_ADDRESS\",' +
			'                            \"zipCode\": \"2300\",' +
			'                            \"streetNumber\": \"133\",' +
			'                            \"streetName\": \"Holmbladsgade\",' +
			'                            \"city\": \"København\",' +
			'                            \"country\": \"DNK\"' +
			'                        }' +
			'                    },' +
			'                    \"billingParty\": {' +
			'                        \"type\": \"ORGANIZATION\",' +
			'                        \"telephoneNumber\": {' +
			'                            \"countryCode\": \"45\"' +
			'                        },' +
			'                        \"name\": \"Test A/S\",' +
			'                        \"cvr\": \"77712079\",' +
			'                        \"label\": \"My account\",' +
			'                        \"address\": {' +
			'                            \"attention\": \"Mr. Secretary\",' +
			'                            \"zipCode\": \"2300\",' +
			'                            \"streetNumber\": \"133\",' +
			'                            \"streetName\": \"Holmbladsgade\",' +
			'                            \"streetNumberSuffix\": \"B\",' +
			'                            \"floorNumber\": \"12\",' +
			'                            \"doorNumber\": \"1203\",' +
			'                            \"direction\": \"tv\",' +
			'                            \"city\": \"København\",' +
			'                            \"country\": \"DNK\"' +
			'                        }' +
			'                    }' +
			'                },' +
			'                {' +
			'                    \"type\": \"DISCOUNT_ITEM\",' +
			'                    \"activity\": \"CREATE\",' +
			'                    \"discountCode\": \"HOF001\"' +
			'                }' +
			'            ]' +
			'        }' +
			'    ]' +
			'}';

		Test.startTest();
		RootBanReqDAO r = RootBanReqDAO.parse(json);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanReqDAO.TelephoneNumberCCode objTelephoneNumberZ = new RootBanReqDAO.TelephoneNumberCCode(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanReqDAO.OrderItems objOrderItems = new RootBanReqDAO.OrderItems(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanReqDAO.Address objAddress = new RootBanReqDAO.Address(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanReqDAO objRootBanReqDAO = new RootBanReqDAO(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanReqDAO.References objReferences = new RootBanReqDAO.References(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanReqDAO.OrderParts objOrderParts = new RootBanReqDAO.OrderParts(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanReqDAO.TelephoneNumber objTelephoneNumber = new RootBanReqDAO.TelephoneNumber(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanReqDAO.Address objAddressZ = new RootBanReqDAO.Address(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanReqDAO.Orderer objOrderer = new RootBanReqDAO.Orderer(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanReqDAO.BillingParty objBillingParty = new RootBanReqDAO.BillingParty(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanReqDAO.Dealer objDealer = new RootBanReqDAO.Dealer(System.JSON.createParser(json));

		Test.stopTest();

		Assert.isTrue(r != null);

		Assert.isTrue(objTelephoneNumberZ != null);
		Assert.isTrue(objTelephoneNumberZ.countryCode == null);

		Assert.isTrue(objOrderItems != null);
		Assert.isTrue(objOrderItems.type == null);
		Assert.isTrue(objOrderItems.activity == null);
		Assert.isTrue(objOrderItems.billingCycle == null);
		Assert.isTrue(objOrderItems.invoiceType == null);
		Assert.isTrue(objOrderItems.label == null);
		Assert.isTrue(objOrderItems.upTransferChargeCode == null);
		Assert.isTrue(objOrderItems.legalParty == null);
		Assert.isTrue(objOrderItems.billingParty == null);
		Assert.isTrue(objOrderItems.discountCode == null);

		Assert.isTrue(objAddress != null);
		Assert.isTrue(objAddress.zipCode == null);
		Assert.isTrue(objAddress.streetNumber == null);
		Assert.isTrue(objAddress.streetName == null);
		Assert.isTrue(objAddress.city == null);
		Assert.isTrue(objAddress.country == null);

		Assert.isTrue(objRootBanReqDAO != null);
		Assert.isTrue(objRootBanReqDAO.brand == null);
		Assert.isTrue(objRootBanReqDAO.segment == null);
		Assert.isTrue(objRootBanReqDAO.channel == null);
		Assert.isTrue(objRootBanReqDAO.dealer == null);
		Assert.isTrue(objRootBanReqDAO.orderer == null);
		Assert.isTrue(objRootBanReqDAO.orderParts == null);

		Assert.isTrue(objReferences != null);

		Assert.isTrue(objOrderParts != null);
		Assert.isTrue(objOrderParts.type == null);
		Assert.isTrue(objOrderParts.activity == null);
		Assert.isTrue(objOrderParts.references == null);
		Assert.isTrue(objOrderParts.orderItems == null);

		Assert.isTrue(objTelephoneNumber != null);
		Assert.isTrue(objTelephoneNumber.countryCode == null);
		Assert.isTrue(objTelephoneNumber.localNumber == null);

		Assert.isTrue(objAddressZ != null);
		Assert.isTrue(objAddressZ.attention == null);
		Assert.isTrue(objAddressZ.zipCode == null);
		Assert.isTrue(objAddressZ.streetNumber == null);
		Assert.isTrue(objAddressZ.streetName == null);
		Assert.isTrue(objAddressZ.streetNumberSuffix == null);
		Assert.isTrue(objAddressZ.floorNumber == null);
		Assert.isTrue(objAddressZ.doorNumber == null);
		Assert.isTrue(objAddressZ.direction == null);
		Assert.isTrue(objAddressZ.city == null);
		Assert.isTrue(objAddressZ.country == null);

		Assert.isTrue(objOrderer != null);
		Assert.isTrue(objOrderer.type == null);
		Assert.isTrue(objOrderer.telephoneNumber == null);
		Assert.isTrue(objOrderer.name == null);
		Assert.isTrue(objOrderer.cvr == null);
		Assert.isTrue(objOrderer.address == null);

		Assert.isTrue(objBillingParty != null);
		Assert.isTrue(objBillingParty.type == null);
		Assert.isTrue(objBillingParty.telephoneNumber == null);
		Assert.isTrue(objBillingParty.name == null);
		Assert.isTrue(objBillingParty.cvr == null);
		Assert.isTrue(objBillingParty.label == null);
		Assert.isTrue(objBillingParty.address == null);

		Assert.isTrue(objDealer != null);
		Assert.isTrue(objDealer.salesAgentCode == null);
		Assert.isTrue(objDealer.dealerCode == null);
	}
}