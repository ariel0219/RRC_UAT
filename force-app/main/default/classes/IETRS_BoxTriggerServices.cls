/**
 * @File Name          : IETRS_BoxTriggerServices.cls
 * @Description        : Box-related methods for triggers
 * @Author             : Mark Frizzell
 * @Group              : 
 * @Last Modified By   : Mark Frizzell
 * @Last Modified On   : 8/20/2019, 10:01:54 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    6/3/2019                Mark Frizzell     Initial Version
**/
public class IETRS_BoxTriggerServices {

    private static final Integer MAX_FILE_SIZE = 8 * 1024 * 1024 * 1024;

    /**
    * @description Cleans up ContentDocument records for DocuSign status records
    * @author Mark Frizzell | 6/29/2019
    * @param List<dsfs__DocuSign_Status__c> records - List of DocuSign status records to clean up
    * @return void
    */
    public static void cleanupFiles(List<dsfs__DocuSign_Status__c> records) {
        List<ContentDocument> deletions = new List<ContentDocument>();
        Set<Id> fcIds = new Set<Id>();

        for(dsfs__DocuSign_Status__c rec : records) {
            fcIds.add(rec.IETRS_Files_Correspondence__c);
        }
        
        String fcQuery = 'SELECT Id, Name, ' +
                            '(SELECT ContentDocumentId ' +
                             'FROM ContentDocumentLinks) ' +
                         'FROM IETRS_Files_Correspondence__c ' +
                         'WHERE Id IN :fcIds';
        for(IETRS_Files_Correspondence__c fcRecord : Database.query(fcQuery)) {
            for(ContentDocumentLink cd : fcRecord.ContentDocumentLinks) {
                deletions.add(new ContentDocument(Id = cd.ContentDocumentId));
            }
        }

        try {
            delete deletions;
        } catch(Exception ex) {
            System.debug('Error cleaning up temporary files: ' + ex.getMessage());
        }
    }

    /**
    * @description Uploads files to Box from dsfs_DocuSign_Status__c records and updates F&C records with new file info
    * @author Mark Frizzell | 6/29/2019
    * @param Set<Id> statusIds - Ids of dsfs_DocuSign_Status__c records containing the files to upload
    * @return void
    */
    @Future(callout=true)
    public static void uploadFiles(Set<Id> statusIds) { 
        Map<Id, dsfs__DocuSign_Status__c> statusMap = new Map<Id, dsfs__DocuSign_Status__c>();
        Map<Id, List<ContentDocumentLink>> cdlMap = new Map<Id, List<ContentDocumentLink>>();
        Map<Id, ContentVersion> versionMap = new Map<Id, ContentVersion>();
        Set<Id> versionIds = new Set<Id>();
        List<SObject> updates = new List<SObject>();
        List<SObject> deletions = new List<SObject>();
        
        // Map DS Status records
        String statusQuery = 'SELECT Id, IETRS_Files_Correspondence__c, ' +
                                 'IETRS_Files_Correspondence__r.IETRS_Box_File_Folder__c, ' +
                                 '(SELECT Id, LinkedEntityId, ContentDocumentId, ' +
                                         'ContentDocument.LatestPublishedVersionId ' +
                                  'FROM ContentDocumentLinks) ' +
                             'FROM dsfs__DocuSign_Status__c ' +
                             'WHERE Id IN :statusIds';
        for(dsfs__DocuSign_Status__c status : Database.query(statusQuery)) {
            statusMap.put(status.Id, status);
            
            // Map ContentDocumentLinks to DS Status records
            for(ContentDocumentLink cdl : status.ContentDocumentLinks) {
                List<ContentDocumentLink> tempCDLs = new List<ContentDocumentLink>();
                if(cdlMap.containsKey(status.Id)) {
                    tempCDLs = cdlMap.get(status.Id);
                } 
                versionIds.add(cdl.ContentDocument.LatestPublishedVersionId); // used for next query
                tempCDLs.add(cdl);
                cdlMap.put(status.Id, tempCDLs);
            }
        }

        // Map DS Status records to ContentVersions and check file size
        String cvQuery = 'SELECT Id, VersionData, PathOnClient, ContentSize, FileExtension, FileType ' +
                         'FROM ContentVersion ' + 
                         'WHERE Id IN :versionIds';
        for(ContentVersion cv : Database.query(cvQuery)) {
            if(cv.VersionData.size() <= MAX_FILE_SIZE) {
                versionMap.put(cv.Id, cv);
            }
        }

        // Upload files to Box and update related F&C record with new file info
        for(Id recordId : cdlMap.keySet()) {
            for(ContentDocumentLink cdl : cdlMap.get(recordId)) {
                ContentVersion cv = versionMap.get(cdl.ContentDocument.LatestPublishedVersionId);
                dsfs__DocuSign_Status__c status = statusMap.get(recordId);
                BoxFile.Info file = new BoxFile.Info();

                if(!Test.isRunningTest()) {
                    IETRSBox box = new IETRSBox();
                    file = box.uploadFile(
                        cv.VersionData, 
                        cv.PathOnClient,
                        status.IETRS_Files_Correspondence__r.IETRS_Box_File_Folder__c
                    );
                } else { // for unit tests only
                    BoxFolder.Info folder = new BoxFolder.Info();
                    folder.id = '12345678900';
                    file.id = '00987654321';
                    file.name = cv.PathOnClient;
                    file.parent = folder;
                    file.size = 1000000;
                }

                updates.add(new IETRS_Files_Correspondence__c(
                    Id = status.IETRS_Files_Correspondence__c,
                    IETRS_Box_File_ID__c = file.id,
                    IETRS_Box_File_Folder__c = file.parent.id,
                    IETRS_File_Size__c = String.valueOf(file.size),
                    IETRS_File_Name__c = file.name,
                    IETRS_File_Format__c = cv.FileType
                ));

                deletions.add(new ContentDocument(
                    Id = cdl.ContentDocumentId
                ));
            }
        }

        try {
            update updates;
        } catch(Exception ex) { 
            System.debug('Error updating F&C records: ' + ex.getMessage());
        }

        try {
            delete deletions;
        } catch(Exception ex) {
            System.debug('Error cleaning up temporary files: ' + ex.getMessage());
        }
        
    }

}