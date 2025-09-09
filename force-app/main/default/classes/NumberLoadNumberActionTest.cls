/**
 * The NumberLoadNumberActionTest class is responsible for testing the NumberLoadNumberAction class.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
@IsTest(IsParallel = true)
public class NumberLoadNumberActionTest {
    /**
     * @description This method tests that the loadPhoneNumbers method returns the correct data.
     */
	@IsTest
    public static void loadPhoneNumbers_returns_tableData(){
        //Arrange
        Mock numberClientMock = Mock.forType(NumberClient.class);
        MethodSpy getNumberDetailsSpy = numberClientMock.spyOn('getNumberDetails');
        
        NumberClientResponseDTO.NumberDetails numberDetailsResponse = new NumberClientResponseDTO.NumberDetails();
        numberDetailsResponse.data = new List<NumberClientResponseDTO.NumberData>();
        
        for(Integer I = 0; i<10; i++){
            NumberClientResponseDTO.NumberData numberData = new NumberClientResponseDTO.NumberData();
            numberData.id = '1234567'+i;
            numberData.countryCode = 'DK';
            numberData.phoneNumber = '1234567'+i;
            numberData.numberGroup = 'P';
            numberData.numberLocation = 'EKC';
            numberData.numberStatus = 'AR';
            numberData.productType = new List<String>{'GSM'};
            
            numberDetailsResponse.data.add(numberData);
        }

        
        numberDetailsResponse.pageSize = 10;
        
        getNumberDetailsSpy.returns(numberDetailsResponse);

        
        List<NumberLoadNumberAction.InputVariables> inputVariables = new List<NumberLoadNumberAction.InputVariables>();
        NumberLoadNumberAction.InputVariables vars = new NumberLoadNumberAction.InputVariables();
        vars.serie = new Account_Phone_Number_Series__c(Product_Type__c = 'GSM', Number_Group__c = 'P', Number_Location__c = 'EKC');
        vars.amountOfNumbers = 10;
        inputVariables.add(vars);
        
        
        NumberLoadNumberAction.numberClient = (NumberClient) numberClientMock.stub;

        //Act
        List<NumberLoadNumberAction.OutputVariables> outputs = NumberLoadNumberAction.loadPhoneNumbers(inputVariables);
        //Assert
        Expect.that(getNumberDetailsSpy).hasBeenCalled();
        
        //Ensure that we return all the numbers in the phoneNumberOutput that was returned from the NumberClient.
        Assert.areEqual(outputs.get(0).phoneNumbers.size(), 10, 'We have 10 numbers');
        
    }
}