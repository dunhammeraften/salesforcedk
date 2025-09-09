/**
 * The NumberClientDTO class contains the data transfer objects (DTOs) used for interacting with the Number API.
 * This class defines the structure of requests and responses for various API operations.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
public class NumberClientDTO {
    /**
     * @description Response structure for port orders operations.
     */
    public class PortOrdersResponse {
        public List<PortOrderData> data;
        public Error error;
    }

    /**
     * @description Request structure for number reservation operations.
     */
    public class NumberReserveRequest {
        public String productType;
    }

    /**
     * @description Response structure for single number detail operations.
     */
    public class NumberDetailResponse {
        public NumberData data;
        public Error error;
    }

    /**
     * @description Request structure for filtering number lists.
     */
    public class NumberDetailsRequest {
        public String product_type = 'GSM';
        public String numberGroup;
        public String numberLocation;
        public Integer amountOfNumbers;
        public String numberStatus;
        public String cvr;
        public String numberPattern;

        /**
         * Generates URL query parameters based on the request properties
         * @return Formatted query string for API requests
         */
        public String getQueryParameters() {
            String urlQueryParameters = 'product_type=' + product_type;

            if (String.isNotBlank(this.numberGroup)) {
                urlQueryParameters += '&number_group=' + this.numberGroup;
            }
            if (String.isNotBlank(this.numberLocation)) {
                urlQueryParameters += '&number_location=' + this.numberLocation;
            }
            if (String.isNotBlank(this.numberStatus)) {
                urlQueryParameters += '&number_status=' + this.numberStatus;
            }
            if (this.amountOfNumbers > 0) {
                urlQueryParameters += '&page_size=' + this.amountOfNumbers;
            }
            if (String.isNotBlank(this.cvr)) {
                urlQueryParameters += '&cvr=' + this.cvr;
            }
            if (String.isNotBlank(this.numberPattern)) {
                // Prefix with ___ to match API pattern requirements
                urlQueryParameters += '&number_pattern=___' + this.numberPattern;
            }

            return urlQueryParameters;
        }
    }

    /**
     * @description Response structure for multiple number listings.
     */
    public class NumberDetailsResponse {
        public List<NumberData> data;
        public Integer pageSize;
        public Error error;
    }

    /**
     * @description Structure representing a single number's data.
     */
    public class NumberData {
        public String id;
        public String countryCode;
        public String phoneNumber;
        public String numberGroup;
        public String numberLocation;
        public String numberStatus;
        public List<String> productType;
    }

    /**
     * @description Structure representing port order data.
     */
    public class PortOrderData {
        public Integer currentStatusCode;
        public String externalStatusCode;
        public String iccNumber;
        public String msisdn;
        public String ochNumber;
        public String orderId;
        public String portingCase;
        public Datetime requestExecutionDate;
        public String subStatusCode;
        public String transactionStatusCode;
    }

    /**
     * @description Generic error response structure.
     */
    public class Error {
        public Integer code;
        public String message;
        public List<ErrorParameter> parameters;

        /**
         * Formats error details into a readable string
         * @return Formatted error message including code and message
         */
        public override String toString() {
            return String.format(
                'Code: {0}, message: {1}, parameters: {2}',
                new List<Object>{ code, message, parameters }
            );
        }
    }

    /**
     * @description Structure for error parameters.
     */
    public class ErrorParameter {
        public String key;
        public String value;
    }
}