@IsTest
public with sharing class MetadataSelectorMock extends MetadataSelector.Service {
    private final List<SObject> records;
    private final SObject record;

    public MetadataSelectorMock(List<SObject> mockRecords) {
        this.records = mockRecords;
    }

    public MetadataSelectorMock(SObject mockRecord) {
        this.record = mockRecord;
    }

    protected override List<SObject> passThrough(List<SObject> ignore) {
        return this.records;
    }

    protected override SObject passThrough(SObject ignore) {
        return this.record;
    }
}