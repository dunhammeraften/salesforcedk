public with sharing class NumbersGetByCvrAction {
    @TestVisible
    private static final String ASSIGNED_AVAILABLE = 'AA';
    @TestVisible
    private static final String ASSIGNED_RESERVED = 'AR';
    @TestVisible
    private static final String NUMBER_GROUP_P = 'P';
    @TestVisible
    private static final String NUMBER_LOCATION_BUSINESS = 'BUS';

    /*
    First try to get all the numbers as AA by CVR
    If not enough numbers in that state then try to get the remainder as AR by CVR
    If there are still not enough numbers then try to get the remainder as AA without CVR
    If at any point the response has an error, an exception is thrown and caugh to and return the error as we otherwise risk getting numbers from an incorrect assignment
        if the API is temporaribly not available in the middle of these chained callouts. The prioritized order must be followed in all cases.
    */
    @InvocableMethod(label='Get numbers by CVR' description='Get AA Numbers by CVR and if not enough then AR numbers by CVR and if not enough then AA numbers without CVR' category='Number API')
    public static List<Response> invoke(List<Request> requests) {
        List<Response> responses = new List<Response>();
        ErrorLogging logs = new ErrorLogging('Apex');
        for(Request request : requests) {
            Response response = new Response();
            try {
                Integer amountOfNumbersToGet = request.amountOfNumbers;
                Integer amountOfNumbersReceived = 0;
                NumberResDAO.NumberDetails numberDetailsByCvrInAssignedAvailableStatus = getNumberDetails(getNumbersByCvrAndStatusParameters(request.cvr, ASSIGNED_AVAILABLE, amountOfNumbersToGet));
                response.numbersByCvrInAssignedAvailableStatus = getNumbersFromNumberDetails(numberDetailsByCvrInAssignedAvailableStatus);
                amountOfNumbersReceived = response.numbersByCvrInAssignedAvailableStatus.size();
                if(amountOfNumbersReceived < amountOfNumbersToGet) {
                    amountOfNumbersToGet -= amountOfNumbersReceived;
                    NumberResDAO.NumberDetails numberDetailsByCvrInAssignedReservedStatus = getNumberDetails(getNumbersByCvrAndStatusParameters(request.cvr, ASSIGNED_RESERVED, amountOfNumbersToGet));
                    response.numbersByCvrInAssignedReservedStatus = getNumbersFromNumberDetails(numberDetailsByCvrInAssignedReservedStatus);
                    amountOfNumbersReceived = response.numbersByCvrInAssignedReservedStatus.size();
                    if(amountOfNumbersReceived < amountOfNumbersToGet) {
                        amountOfNumbersToGet -= amountOfNumbersReceived;
                        NumberResDAO.NumberDetails numberDetailsWithoutCvrInAssignedAvailableStatus = getNumberDetails(getGenerallyAvailableNumbersParameters(amountOfNumbersToGet));
                        response.numbersWithoutCvrInAssignedAvailableStatus = getNumbersFromNumberDetails(numberDetailsWithoutCvrInAssignedAvailableStatus);
                        if(request.reserveNumbersNotCvrAssigned) {
                            List<String> msisdns = getMsisdnsFromNumberDetails(numberDetailsWithoutCvrInAssignedAvailableStatus);
                            NumberServiceBatch batchJob = new NumberServiceBatch(NumberServiceBatch.Action.RESERVE, msisdns);
                            batchJob.run();
                        }
                    }
                }
                response.isSuccess = true;
            } catch(Exception ex) {
                response.isSuccess = false;
                response.errorMessage = ex.getMessage();
                logs.addError(ex.getMessage(), NumberService.class.getName() + '.invoke');
            } finally {
                responses.add(response);
            }
        }
        logs.logErrors();

        return responses;
    }

    private static NumberService.GetNumbersParameterbuilder getNumbersByCvrAndStatusParameters(String cvr, String numberStatus, Integer amountOfNumbers) {
        return new NumberService.GetNumbersParameterbuilder()
            .withCvr(cvr)
            .withNumberStatus(numberStatus)
            .withAmountOfNumbers(amountOfNumbers);
    }

    private static NumberService.GetNumbersParameterbuilder getGenerallyAvailableNumbersParameters(Integer amountOfNumbers) {
        return new NumberService.GetNumbersParameterbuilder()
            .withNumberGroup(NUMBER_GROUP_P)
            .withNumberLocation(NUMBER_LOCATION_BUSINESS)
            .withNumberStatus(ASSIGNED_AVAILABLE)
            .withAmountOfNumbers(amountOfNumbers);
    }

    private static NumberResDAO.NumberDetails getNumberDetails(NumberService.GetNumbersParameterbuilder parameters) {
        NumberResDAO.NumberDetails numberDetails = NumberService.getNumberDetails(parameters);
        if(numberDetails.error != null) {
            throw new NumbersGetByCvrActionException(numberDetails.error.message);
        }

        return numberDetails;
    }

    private static List<String> getNumbersFromNumberDetails(NumberResDAO.NumberDetails numberDetails) {
        List<String> numbers = new List<String>();
        for(NumberResDAO.NumberData numberData : numberDetails.data) {
            numbers.add(numberData.phoneNumber);
        }

        return numbers;
    }

    private static List<String> getMsisdnsFromNumberDetails(NumberResDAO.NumberDetails numberDetails) {
        List<String> msisdns = new List<String>();
        for(NumberResDAO.NumberData numberData : numberDetails.data) {
            msisdns.add(numberData.id);
        }

        return msisdns;
    }

    public class Request {
        @InvocableVariable(label='Amount of numbers to get' required=true)
        public Integer amountOfNumbers;

        @InvocableVariable(label='CVR' required=true)
        public String cvr;

        @InvocableVariable(label='Reserve numbers not CVR assigned' description='Defaults to false. If set to true and if there are not enough numbers by CVR, then the generally available numbers found will be reserved')
        public Boolean reserveNumbersNotCvrAssigned = false;
    }

    public class Response {
        @InvocableVariable(label='Numbers by CVR in Assigned Available status' description='AA numbers available by CVR are provided here.')
        public List<String> numbersByCvrInAssignedAvailableStatus = new List<String>();

        @InvocableVariable(label='Numbers by CVR in Assigned Reserved status' description='If there are not enough AA numbers by CVR then AR numbers by CVR are provided here.')
        public List<String> numbersByCvrInAssignedReservedStatus = new List<String>();

        @InvocableVariable(label='Numbers without CVR in Assigned Available status' description='If there are not enough AA and AR numbers by CVR then numbers without CVR in AA are provided here.')
        public List<String> numbersWithoutCvrInAssignedAvailableStatus = new List<String>();

        @InvocableVariable(label='Is Success' description='Set to false if an exception was thrown in Apex')
        public Boolean isSuccess;

        @InvocableVariable(label='Error Message' description='Only avaliable if Is Success = false')
        public String errorMessage;
    }

    private class NumbersGetByCvrActionException extends Exception {}
}