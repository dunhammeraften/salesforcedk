/**
 * @description A fluent interface for creating sObject test data.
 */
public class NorlysSUnitDataFactory {

    private SObjectType currentObjectType;
    private Integer recordCount;
    private Map<String, Object> fieldValues;

    /**
     * @description Starts a new build process for a given number of sObjects of a specific type.
     * @param sObjectType The API name of the sObject to create (e.g., 'Account').
     * @param count The number of records to create.
     * @return The factory instance for method chaining.
     */
    public NorlysSUnitDataFactory create(String sObjectType, Integer count) {
        // Reset state for a new creation process
        this.currentObjectType = Schema.getGlobalDescribe().get(sObjectType)?.getDescribe().getSObjectType();
        if (this.currentObjectType == null) {
            throw new SUnitDataFactoryException('Invalid sObject type: ' + sObjectType);
        }
        this.recordCount = count;
        this.fieldValues = new Map<String, Object>();
        return this;
    }

    /**
     * @description Starts a new build process for a single sObject.
     * @param sObjectType The API name of the sObject to create.
     * @return The factory instance for method chaining.
     */
    public NorlysSUnitDataFactory create(String sObjectType) {
        return create(sObjectType, 1);
    }

    /**
     * @description Sets a field value on the sObject(s) being built.
     * @param fieldName The API name of the field.
     * @param value The value to set.
     * @return The factory instance for method chaining.
     */
    public NorlysSUnitDataFactory set(String fieldName, Object value) {
        if (this.currentObjectType == null) {
            throw new SUnitDataFactoryException('You must call "create" before "set".');
        }
        this.fieldValues.put(fieldName, value);
        return this;
    }

    /**
     * @description Builds and returns a single sObject record without inserting it.
     * @return The constructed sObject.
     */
    public sObject getRecord() {
        if (recordCount != 1) {
            throw new SUnitDataFactoryException('Use getList() when recordCount is not 1. Current count: ' + recordCount);
        }
        return buildRecords().get(0);
    }

    /**
     * @description Builds and returns a list of sObject records without inserting them.
     * @return A list of the constructed sObjects.
     */
    public List<sObject> getList() {
        return buildRecords();
    }

    /**
     * @description Builds, inserts, and returns a single sObject record.
     * @return The inserted sObject, now with an ID.
     */
    public sObject insertRecord() {
        sObject record = getRecord();
        insert record;
        return record;
    }

    /**
     * @description Builds, inserts, and returns a list of sObject records.
     * @return The inserted sObjects, now with IDs.
     */
    public List<sObject> insertList() {
        List<sObject> records = getList();
        insert records;
        return records;
    }

    private List<sObject> buildRecords() {
        if (currentObjectType == null) {
            throw new SUnitDataFactoryException('You must call "create" to specify an sObject type first.');
        }
        List<sObject> records = new List<sObject>();
        for (Integer i = 0; i < recordCount; i++) {
            sObject record = currentObjectType.newSObject();
            for (String fieldName : fieldValues.keySet()) {
                record.put(fieldName, fieldValues.get(fieldName));
            }
            records.add(record);
        }
        return records;
    }

    /**
     * @description Custom exception for the data factory.
     */
    public class SUnitDataFactoryException extends Exception {}
}