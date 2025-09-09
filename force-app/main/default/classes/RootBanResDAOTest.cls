/**
 *
 * @author Mujahid
 * @since 27/02/2023
 */
@IsTest
public class RootBanResDAOTest {
	@isTest
	static void testParse() {
		String json =
			'{' +
			'    \"data\": {' +
			'        \"channel\": \"SALES_FORCE\",' +
			'        \"dealer\": {' +
			'            \"dealerCode\": \"1018\",' +
			'            \"dealerName\": \"CO BtB Amager\",' +
			'            \"salesAgentCode\": \"22334\"' +
			'        },' +
			'        \"orderId\": \"SF53567\",' +
			'        \"id\": \"53567\",' +
			'        \"segment\": \"B2B\",' +
			'        \"channelOrderReference\": \"SF53567\",' +
			'        \"brand\": \"teliadk\",' +
			'        \"createdDate\": \"2023-01-27T14:06:58.726443691+01:00\",' +
			'        \"processingStatus\": \"SUBMITTED\",' +
			'        \"orderer\": {' +
			'            \"type\": \"ORGANIZATION\",' +
			'            \"name\": \"Test A/S\",' +
			'            \"cvr\": \"77712079\",' +
			'            \"address\": {' +
			'                \"type\": \"DANISH_ADDRESS\",' +
			'                \"city\": \"København\",' +
			'                \"zipCode\": \"2300\",' +
			'                \"country\": \"DNK\",' +
			'                \"streetName\": \"Holmbladsgade\",' +
			'                \"streetNumber\": \"133\"' +
			'            },' +
			'            \"telephoneNumber\": {' +
			'                \"countryCode\": \"45\",' +
			'                \"localNumber\": \"73193137\"' +
			'            }' +
			'        },' +
			'        \"orderParts\": [' +
			'            {' +
			'                \"references\": [],' +
			'                \"type\": \"ACCOUNT\",' +
			'                \"activity\": \"CREATE\",' +
			'                \"changeTypes\": [],' +
			'                \"orderItems\": [' +
			'                    {' +
			'                        \"type\": \"ACCOUNT_ITEM\",' +
			'                        \"billingAccountNumber\": \"863855318\",' +
			'                        \"legalParty\": {' +
			'                            \"type\": \"ORGANIZATION\",' +
			'                            \"name\": \"Test A/S\",' +
			'                            \"cvr\": \"77712079\",' +
			'                            \"address\": {' +
			'                                \"type\": \"DANISH_ADDRESS\",' +
			'                                \"city\": \"København\",' +
			'                                \"zipCode\": \"2300\",' +
			'                                \"country\": \"DNK\",' +
			'                                \"streetName\": \"Holmbladsgade\",' +
			'                                \"streetNumber\": \"133\"' +
			'                            },' +
			'                            \"telephoneNumber\": {' +
			'                                \"countryCode\": \"45\",' +
			'                                \"localNumber\": \"73193137\"' +
			'                            }' +
			'                        },' +
			'                        \"billingParty\": {' +
			'                            \"type\": \"ORGANIZATION\",' +
			'                            \"name\": \"Test A/S\",' +
			'                            \"cvr\": \"77712079\",' +
			'                            \"address\": {' +
			'                                \"type\": \"DANISH_ADDRESS\",' +
			'                                \"city\": \"København\",' +
			'                                \"zipCode\": \"2300\",' +
			'                                \"attention\": \"Mr. Secretary\",' +
			'                                \"country\": \"DNK\",' +
			'                                \"streetName\": \"Holmbladsgade\",' +
			'                                \"streetNumber\": \"133\",' +
			'                                \"streetNumberSuffix\": \"B\",' +
			'                                \"floorNumber\": \"12\",' +
			'                                \"doorNumber\": \"1203\",' +
			'                                \"direction\": \"tv\"' +
			'                            },' +
			'                            \"telephoneNumber\": {' +
			'                                \"countryCode\": \"45\"' +
			'                            }' +
			'                        },' +
			'                        \"billingCycle\": \"MONTHLY\",' +
			'                        \"invoiceType\": \"PDF_BY_EMAIL\",' +
			'                        \"label\": \"My account\",' +
			'                        \"upTransferChargeCode\": \"THOD22\",' +
			'                        \"activity\": \"CREATE\",' +
			'                        \"id\": 2,' +
			'                        \"origin\": \"CLIENT\"' +
			'                    },' +
			'                    {' +
			'                        \"type\": \"DISCOUNT_ITEM\",' +
			'                        \"discountCode\": \"HOF001\",' +
			'                        \"activity\": \"CREATE\",' +
			'                        \"id\": 3,' +
			'                        \"origin\": \"CLIENT\"' +
			'                    }' +
			'                ],' +
			'                \"validationErrors\": [],' +
			'                \"id\": 1' +
			'            }' +
			'        ],' +
			'        \"validationErrors\": [],' +
			'        \"hasValidationErrors\": false,' +
			'        \"documents\": []' +
			'    }' +
			'}';

		Test.startTest();
		RootBanResDAO r = RootBanResDAO.parse(json);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO.TelephoneNumberCCode objTelephoneNumberCCode = new RootBanResDAO.TelephoneNumberCCode(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO.OrderItems objOrderItems = new RootBanResDAO.OrderItems(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO.ValidationErrors objValidationErrors = new RootBanResDAO.ValidationErrors(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO.Parameters objValidationErrorParameters = new RootBanResDAO.Parameters(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO.Address objAddress1 = new RootBanResDAO.Address(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO.References objReferences = new RootBanResDAO.References(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO.OrderParts objOrderParts = new RootBanResDAO.OrderParts(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO.Data objData = new RootBanResDAO.Data(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO objRootBanResDAO = new RootBanResDAO(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO.TelephoneNumber objTelephoneNumber = new RootBanResDAO.TelephoneNumber(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO.Address objAddress = new RootBanResDAO.Address(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO.Orderer objOrderer = new RootBanResDAO.Orderer(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO.BillingParty objBillingParty = new RootBanResDAO.BillingParty(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		RootBanResDAO.Dealer objDealer = new RootBanResDAO.Dealer(System.JSON.createParser(json));

		Test.stopTest();

		Assert.isTrue(r != null);

		Assert.isTrue(objValidationErrors != null);
		Assert.isTrue(objValidationErrors.errorCode == null);
		Assert.isTrue(objValidationErrors.parameters == null);

		Assert.isTrue(objValidationErrorParameters != null);
		Assert.isTrue(objValidationErrorParameters.reason == null);
		Assert.isTrue(objValidationErrorParameters.target == null);

		Assert.isTrue(objTelephoneNumberCCode != null);
		Assert.isTrue(objTelephoneNumberCCode.countryCode == null);

		Assert.isTrue(objOrderItems != null);
		Assert.isTrue(objOrderItems.type == null);
		Assert.isTrue(objOrderItems.legalParty == null);
		Assert.isTrue(objOrderItems.billingParty == null);
		Assert.isTrue(objOrderItems.billingCycle == null);
		Assert.isTrue(objOrderItems.invoiceType == null);
		Assert.isTrue(objOrderItems.label == null);
		Assert.isTrue(objOrderItems.upTransferChargeCode == null);
		Assert.isTrue(objOrderItems.activity == null);
		Assert.isTrue(objOrderItems.id == null);
		Assert.isTrue(objOrderItems.origin == null);
		Assert.isTrue(objOrderItems.discountCode == null);

		Assert.isTrue(objAddress1 != null);
		Assert.isTrue(objAddress1.type == null);
		Assert.isTrue(objAddress1.city == null);
		Assert.isTrue(objAddress1.zipCode == null);
		Assert.isTrue(objAddress1.country == null);
		Assert.isTrue(objAddress1.streetName == null);
		Assert.isTrue(objAddress1.streetNumber == null);

		Assert.isTrue(objReferences != null);

		Assert.isTrue(objOrderParts != null);
		Assert.isTrue(objOrderParts.references == null);
		Assert.isTrue(objOrderParts.type == null);
		Assert.isTrue(objOrderParts.activity == null);
		Assert.isTrue(objOrderParts.changeTypes == null);
		Assert.isTrue(objOrderParts.orderItems == null);
		Assert.isTrue(objOrderParts.validationErrors == null);
		Assert.isTrue(objOrderParts.id == null);

		Assert.isTrue(objData != null);
		Assert.isTrue(objData.channel == null);
		Assert.isTrue(objData.dealer == null);
		Assert.isTrue(objData.orderId == null);
		Assert.isTrue(objData.id == null);
		Assert.isTrue(objData.segment == null);
		Assert.isTrue(objData.channelOrderReference == null);
		Assert.isTrue(objData.brand == null);
		Assert.isTrue(objData.createdDate == null);
		Assert.isTrue(objData.processingStatus == null);
		Assert.isTrue(objData.orderer == null);
		Assert.isTrue(objData.orderParts == null);
		Assert.isTrue(objData.validationErrors == null);
		Assert.isTrue(objData.hasValidationErrors == null);
		Assert.isTrue(objData.documents == null);

		Assert.isTrue(objRootBanResDAO != null);
		Assert.isTrue(objRootBanResDAO.data == null);

		Assert.isTrue(objTelephoneNumber != null);
		Assert.isTrue(objTelephoneNumber.countryCode == null);
		Assert.isTrue(objTelephoneNumber.localNumber == null);

		Assert.isTrue(objAddress != null);
		Assert.isTrue(objAddress.type == null);
		Assert.isTrue(objAddress.city == null);
		Assert.isTrue(objAddress.zipCode == null);
		Assert.isTrue(objAddress.attention == null);
		Assert.isTrue(objAddress.country == null);
		Assert.isTrue(objAddress.streetName == null);
		Assert.isTrue(objAddress.streetNumber == null);
		Assert.isTrue(objAddress.streetNumberSuffix == null);
		Assert.isTrue(objAddress.floorNumber == null);
		Assert.isTrue(objAddress.doorNumber == null);
		Assert.isTrue(objAddress.direction == null);

		Assert.isTrue(objOrderer != null);
		Assert.isTrue(objOrderer.type == null);
		Assert.isTrue(objOrderer.name == null);
		Assert.isTrue(objOrderer.cvr == null);
		Assert.isTrue(objOrderer.address == null);
		Assert.isTrue(objOrderer.telephoneNumber == null);

		Assert.isTrue(objBillingParty != null);
		Assert.isTrue(objBillingParty.type == null);
		Assert.isTrue(objBillingParty.name == null);
		Assert.isTrue(objBillingParty.cvr == null);
		Assert.isTrue(objBillingParty.address == null);
		Assert.isTrue(objBillingParty.telephoneNumber == null);

		Assert.isTrue(objDealer != null);
		Assert.isTrue(objDealer.dealerCode == null);
		Assert.isTrue(objDealer.dealerName == null);
		Assert.isTrue(objDealer.salesAgentCode == null);
	}
}