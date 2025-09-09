/**
 * The NumberLoadNumberAction class is responsible for loading phone numbers from the Number API.
 * It is an invocable action that can be called from a flow.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
public with sharing class NumberLoadNumberAction {
    @TestVisible
    private static NumberClient numberClient;
    
    static {
        SingletonFactory factory = SingletonFactory.getFactory();
        
        numberClient = (NumberClient) factory.getOrRegisterSingleton(NumberClient.class);
    }

    /**
     * @description This method is called from a flow to load phone numbers from the Number API.
     * @param inputVariables A list of input variables from the flow.
     * @return A list of output variables containing the loaded phone numbers.
     */
    @InvocableMethod(category='Number' label='Get numbers for serie' description='Fetch numbers with numberclient with data request information provided by the number serie.')
    public static List<OutputVariables> loadPhoneNumbers(List<InputVariables> inputVariables) {        
        OutputVariables output = new OutputVariables();
        
        try{
			logger.logInfo('inputVariables ' + inputVariables);
            logger.logInfo('inputVariables size ' + inputVariables.size());

            NumberClientRequestDTO.NumberDetails detailsRequest = getNumberDetailsRequest(inputVariables.get(0));
            
            //get a number of possible numbers from the number api to present to the user for choosing
        	NumberClientResponseDTO.NumberDetails numberDetailsResponse = numberClient.getNumberDetails(detailsRequest);
            
            logger.logInfo('numberDetailsResponse ' + numberDetailsResponse);
            logger.logInfo('numberDetailsResponse.data ' + numberDetailsResponse.data);

            for(NumberClientResponseDTO.NumberData data : numberDetailsResponse.data ){
                output.phoneNumbers.add(data.id);
            }
        }catch(HTTPException ex){
            Logger.logError(ex);
            Logger.emit();
            throw ex;
        }
        
        return new List<OutputVariables>{output};
	}
    
    /**
     * @description This method creates a NumberClientRequestDTO.NumberDetails object from the input variables.
     * @param inputVar The input variables from the flow.
     * @return A NumberClientRequestDTO.NumberDetails object.
     */
    private static NumberClientRequestDTO.NumberDetails getNumberDetailsRequest(InputVariables inputVar){
        NumberClientRequestDTO.NumberDetails detailsRequest = new NumberClientRequestDTO.NumberDetails();
        
        detailsRequest.numberStatus = SFConstants.ASSIGNED_AVAILABLE;
        detailsRequest.product_type = inputVar.serie.Product_Type__c;
        detailsRequest.numberGroup = inputVar.serie.Number_Group__c;
        detailsRequest.numberLocation = inputVar.serie.Number_Location__c;

        if(inputVar.amountOfNumbers == null){
            detailsRequest.amountOfNumbers = 1;
        }
        else{
            detailsRequest.amountOfNumbers = inputVar.amountOfNumbers;
        }

        return detailsRequest;
    }
    
	public class InputVariables {
		@InvocableVariable
		public Account_Phone_Number_Series__c serie;
		@InvocableVariable
        public Integer amountOfNumbers;
	}

	public class OutputVariables {
        @InvocableVariable
        public List<String> phoneNumbers = new List<String>();
	}
}