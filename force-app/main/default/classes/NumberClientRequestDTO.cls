/**
 * The NumberClientRequestDTO class contains the data transfer objects (DTOs) used for creating requests to the Number API.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
public with sharing class NumberClientRequestDTO {
    /**
     * @description Request structure for number reservation operations.
     */
    public class NumberReservation {
        public String productType;
        public String cvr;
    }

    /**
     * @description Request structure for filtering number lists. This is parsed as query parameters.
     */
    public class NumberDetails {
        public String product_type = 'GSM';
        public String numberGroup;
        public String numberLocation;
        public Integer amountOfNumbers;
        public String numberStatus;
        public String cvr;
        public String numberPattern;
    }
}