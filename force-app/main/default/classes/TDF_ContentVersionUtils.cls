@IsTest
public with sharing class TDF_ContentVersionUtils {
    public static ContentVersion createContentVersion(String title, String fileFormat, String fileData) {
        ContentVersion contentVersion = new ContentVersion(
            Title = title,
            PathOnClient='/' + title + '.' + fileFormat,
            VersionData = Blob.valueOf(fileData)
        ); 
        insert contentVersion;

        return contentVersion;
    }
}