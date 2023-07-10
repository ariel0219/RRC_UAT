/**
 * @File Name          : IETRS_BoxDocusignController.cls
 * @Description        : Controller for IETRS_BoxDocusign component
 * @Author             : Mark Frizzell
 * @Group              : 
 * @Last Modified By   : Mark Frizzell
 * @Last Modified On   : 8/20/2019, 7:52:08 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    6/14/2019                Mark Frizzell     Initial Version
 * 1.1    
 * 1.2
**/
public class IETRS_BoxDocusignController {
    
    /**
    * @description - Downloads the F&C file from Box to SF files
    * @author Mark Frizzell | 6/14/2019
    * @param Id recordId - Id of the F&C record
    * @return String - Result message to return to the component
    */
    @AuraEnabled
    public static String downloadFile(Id recordId) {
        IETRS_Files_Correspondence__c fcRecord = new IETRS_Files_Correspondence__c();
        Blob fileBlob = null;
        ContentVersion cv = new ContentVersion();
        ContentDocumentLink cdl = new ContentDocumentLink();

        // Get F&C record details
        try {
            fcRecord = [SELECT Id, IETRS_Box_File_ID__c, IETRS_File_Name__c
                        FROM IETRS_Files_Correspondence__c 
                        WHERE Id = :recordId 
                        LIMIT 1];
        } catch(Exception ex) {
            return 'Error loading F&C record: ' + ex.getMessage();
        }

        // Download file from Box
        try {
            if(!Test.isRunningTest()) {
                IETRSBox box = new IETRSBox();
                fileBlob = box.downloadFile(fcRecord.IETRS_Box_File_ID__c);
            } else {
                fileBlob = Blob.valueOf('test data');
            }
        } catch(Exception ex) {
            return 'Error downloading file from Box: ' + ex.getMessage();
        }

        // Create ContentVersion (automatically generates ContentDocument record)
        try {
            cv.ContentLocation = 'S';
            cv.VersionData = fileBlob;
            cv.Title = fcRecord.IETRS_File_Name__c;
            cv.PathOnClient = fcRecord.IETRS_File_Name__c;
            insert cv;
        } catch(Exception ex) {
            return 'Error saving file to Salesforce: ' + ex.getMessage();
        }

        // Create link to F&C record
        try {
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = fcRecord.Id;
            cdl.ShareType = 'V';
            insert cdl;
        } catch(Exception ex) {
            return 'Error linking file to F&C record: ' + ex.getMessage();
        }

        return 'Success';
    }

    /**
    * @description Builds the "Send with DocuSign" URL
    * @author Mark Frizzell | 6/28/2019
    * @param Id recordId - Record Id to associate the DS envelope with
    * @return String - Page URL
    */
    @AuraEnabled
    public static String buildURL(Id recordId) {
        Map<String,String> parameters = new Map<String,String>{
            'SourceID'  => recordId,
            'OCO'       => 'Tag',
            'LA'        => '1',
            'LF'        => '1'
        };
        System.PageReference pageReference = new System.PageReference('/apex/dsfs__DocuSign_CreateEnvelope');
        pageReference.getParameters().putAll(parameters);
        return pageReference.getUrl();
    }

}