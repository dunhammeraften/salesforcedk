/**
 * The NumberClientResponseDTO class contains the data transfer objects (DTOs) used for handling responses from the Number API.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
public class NumberClientResponseDTO {
    /**
     * @description Response structure for single number detail operations.
     */
    public class NumberDetail {
        public NumberData data;
        public NumberError error;
    }

    /**
     * @description Response structure for multiple number listings.
     */
    public class NumberDetails {
        public List<NumberData> data;
        public Integer pageSize;
        public NumberError error;
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
     * @description Response structure for port orders operations.
     */
    public class PortOrders {
        public List<PortOrderData> data;
        public NumberError error;
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
    public class NumberError {
        public Integer code;
        public String message;
        public List<NumberErrorParameter> parameters;

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
    public class NumberErrorParameter {
        public String key;
        public String value;
    }
}