/**
 * @File Name          : IETRS_BoxUpload.cls
 * @Description        : Used by Case upload flows to move file(s) to Box and update F&C record
 * @Author             : Mark Frizzell
 * @Group              : IETRS - Case
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 2/26/2020, 1:46:18 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.1    5/21/2019, 12:01:43 PM    Mark Frizzell       Initial Version
 * 1.2    6/2/2019                  Mark Frizzell       Improved loop and map logic
 * 1.3    6/4/2019                  Mark Frizzell       Changes to folder and file structure
 * 1.4    6/5/2019                  Mark Frizzell       Modified for violation parent records
 *                                                      Delete unused ContentDocument records
 * 1.5    6/18/2019                 Mark Frizzell       Check file size before upload
 *                                                      Create folder if necessary
 * 1.6    6/21/2019                 Mark Frizzell       Delete files from SF after upload/failure
 * 1.7    7/19/2019                 Mark Frizzell       Changed to async, updated logic, check file 
                                                        size, send email on error
 * 1.8    8/18/2019                 Mark Frizzell       If file is too large, provide a link to the 
                                                        folder in the error msg
 * 2.0    02/20/2020                Kevin Lu            Modified code to store case-related files in one folder per case              
**/
public class IETRS_BoxUpload {
    
    private static final Integer MAX_FILE_SIZE = Test.isRunningTest() ? 4000 : 8 * 1024 * 1024 * 1024; // can't make an 8MB blob in test class

    /**
    * @description Invocable method called from flow that checks file sizes and calls async method
    * @author Mark Frizzell | 5/21/2019
    * @param List<Id> fcRecordIds - F&C record ids passed in from the flow
    * @return List<String> - result message(s) to be passed back to the flow before the async code runs
    */
    @InvocableMethod
    public static List<String> init(List<Id> fcRecordIds) {
        IETRSBox box = new IETRSBox();
        List<SObject> updates = new List<SObject>();
        Map<Id, String> mapCaseFolderId = new Map<Id, String>();
        String folderId = '';

        // Check if current folder id is valid, and create folder if necessary
        for(IETRS_Files_Correspondence__c fc : [SELECT 
                                                    Id, Name, IETRS_Box_File_Folder__c, IETRS_Case__c,
                                                    IETRS_Case__r.CaseNumber, IETRS_Case__r.IETRS_BoxFolderID__c
                                                FROM IETRS_Files_Correspondence__c
                                                WHERE Id IN :fcRecordIds]) {            
            if(fc.IETRS_Box_File_Folder__c != null && isValidFolder(fc.IETRS_Box_File_Folder__c, box.api)) {
                //If the F&C record already has a folder
                folderId = fc.IETRS_Box_File_Folder__c;
            } else if(fc.IETRS_Box_File_Folder__c == null && fc.IETRS_Case__r.IETRS_BoxFolderID__c != null && isValidFolder(fc.IETRS_Case__r.IETRS_BoxFolderID__c, box.api)) {
                //If the related Case already has a folder
                folderId = fc.IETRS_Case__r.IETRS_BoxFolderID__c;
            } else if(mapCaseFolderId.containsKey(fc.IETRS_Case__c)) {
                //If the folder has already been created in this method
                folderId = mapCaseFolderId.get(fc.IETRS_Case__c);
            } else {
                //No folder, so create one
                if(fc.IETRS_Case__c != null) {
                    //If the case relationship is populated, make the folder based on the case name
                    BoxFolder.Info folderInfo = box.createFolder('CASE-' + fc.IETRS_Case__r.CaseNumber);
                    folderId = folderInfo.id;
                    mapCaseFolderId.put(fc.IETRS_Case__c, folderId);

                    //Update Case as well
                    Case c = new Case();
                    c.Id = fc.IETRS_Case__c;
                    c.IETRS_BoxFolderID__c = folderId;
                    updates.add(c);
                } else {
                    //Otherwise, make the folder based on the F&C name
                    BoxFolder.Info folderInfo = box.createFolder(fc.Name);
                    folderId = folderInfo.id;
                }
            }
            System.debug('folderId: ' + folderId);
            fc.IETRS_Box_File_Folder__c = folderId;
            updates.add(fc);
        }
        try {
            if(updates.size() > 0) {
                update updates;
            }
        } catch(DmlException dex) {
            return new List<String> { 'Error storing Box folder ID: ' + dex.getMessage() };
        }

        // Check file sizes before starting
        Set<Id> versionIds = new Set<Id>();
        Set<Id> docIds = new Set<Id>();
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId 
                                       FROM ContentDocumentLink 
                                       WHERE LinkedEntityId IN :fcRecordIds]) 
        {
            versionIds.add(cdl.ContentDocument.LatestPublishedVersionId);
            docIds.add(cdl.ContentDocumentId);
        }        
        for(ContentVersion cv : [SELECT ContentSize FROM ContentVersion WHERE Id IN :versionIds]) {
            if(cv.ContentSize > MAX_FILE_SIZE) {
                deleteRecords(docIds);
                return new List<String> { Label.Box_File_Size_Error };
            }
        }
        
        // Prepare files and upload to Box
        prepareUploadAsync(fcRecordIds);

        return new List<String> { 'Success' };
    }
    

    /**
    * @description Async method that gathers related records and starts the upload process
    * @author Mark Frizzell | 7/18/2019
    * @param List<Id> fcRecordIds - F&C record Ids to use
    * @return void
    */
    @Future(callout=true)
    private static void prepareUploadAsync(List<Id> fcRecordIds) {
        Map<Id, SObject> fcMap = new Map<Id, SObject>();
        Map<Id, List<ContentDocumentLink>> cdlMap = new Map<Id, List<ContentDocumentLink>>();
        Map<Id, ContentVersion> versionMap = new Map<Id, ContentVersion>();
        List<Id> versionIds = new List<Id>();
        List<ContentDocumentLink> tempCDLs = new List<ContentDocumentLink>();
        
        // Map F&C records
        String fcQuery = 'SELECT Id, Name, IETRS_Box_File_Folder__c ' +
                         'FROM IETRS_Files_Correspondence__c ' +
                         'WHERE Id IN :fcRecordIds';
        for(IETRS_Files_Correspondence__c fc : Database.query(fcQuery)) {
            fcMap.put(fc.Id, fc);
        }

        // Map F&C records to ContentDocumentLink records
        String cdlQuery = 'SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, ' +
                                'LinkedEntityId, LinkedEntity.Name ' +
                          'FROM ContentDocumentLink ' +
                          'WHERE LinkedEntityId IN :fcRecordIds';
        for(ContentDocumentLink cdl : Database.query(cdlQuery)) {
            if(cdlMap.containsKey(cdl.LinkedEntityId)) {
                tempCDLs = cdlMap.get(cdl.LinkedEntityId);
            }
            versionIds.add(cdl.ContentDocument.LatestPublishedVersionId); // used for next query
            tempCDLs.add(cdl);
            cdlMap.put(cdl.LinkedEntityId, tempCDLs);
        }
        
        // Map F&C records to ContentVersions
        String cvQuery = 'SELECT Id, VersionData, PathOnClient, ContentSize, FileExtension, FileType ' +
                         'FROM ContentVersion ' +
                         'WHERE Id IN :versionIds';
        for(ContentVersion cv : Database.query(cvQuery)) {
            versionMap.put(cv.Id, cv);
        }

        // Upload files to Box
        String uploadResult = uploadFiles(cdlMap, versionMap, fcMap);
        System.debug('uploadResult: ' + uploadResult);

        // Send email on error (except file size)
        if(uploadResult != 'Success') {
            sendEmail(uploadResult);
        }
    }

    
    /**
    * @description Saves file(s) to Box in the parent record's Box folder
    * @author Mark Frizzell | 5/21/2019
    * @param Map<Id, Map<Id, List<ContentDocumentLink>> cdlMap - Map of F&C record ids to ContentDocumentLinks
    * @param Map<Id, ContentVersion> versionMap - Map of ContentVersions including file blobs
    * @param Map<Id, String> fcMap - Map of F&C records
    * @return String - Result message passed back to the async method
    */
    private static String uploadFiles(Map<Id, List<ContentDocumentLink>> cdlMap, Map<Id, ContentVersion> versionMap, Map<Id, SObject> fcMap) {
        IETRSBox box = new IETRSBox();
        Map<Id, List<BoxFile.Info>> fileMap = new Map<Id, List<BoxFile.Info>>();

        for(Id recordId : cdlMap.keySet()) {
            IETRS_Files_Correspondence__c fc = (IETRS_Files_Correspondence__c) fcMap.get(recordId);
            List<BoxFile.Info> fileList = new List<BoxFile.Info>();

            for(ContentDocumentLink cdl : cdlMap.get(recordId)) {
                ContentVersion cv = versionMap.get(cdl.ContentDocument.LatestPublishedVersionId);
                String folderId = fc.IETRS_Box_File_Folder__c != null ? fc.IETRS_Box_File_Folder__c : '0';
                BoxFile.Info file = new BoxFile.Info();
                String fileName;
                fileName = 
                    cdl.LinkedEntity.Name + 
                    string.valueof(Datetime.now())+
                    (cv.FileExtension == null ? '' : ('.' + cv.FileExtension));
                
                try {
                    // Upload file
                    System.debug('folderId: ' + folderId + ' fileName: ' + fileName);
                    if(!Test.isRunningTest()) {
                        file = box.uploadFile(cv.VersionData, fileName, folderId);
                    } else { // for unit tests only
                        file.id = '00987654321';
                        file.name = fileName;
                    }
                    // Get file type, store original filename
                    file.etag = cv.FileType;
                    file.description = cv.PathOnClient;
                } catch(Exception ex) {
                    return 'Error uploading file: ' + ex.getMessage() + ' @ ' + ex.getLineNumber();
                }

                if(fileMap.containsKey(recordId)) {
                    fileList = fileMap.get(recordId);
                }
                fileList.add(file);
                fileMap.put(recordId, fileList);
            }
        }

        String updateResult = updateRecords(fileMap, fcMap);
        if(updateResult == 'Success') {
            return deleteRecords(cdlMap);
        } else {
            return updateResult;
        }
    }


    /**
    * @description Updates F&C record(s) with Box file details
    * @author Mark Frizzell | 5/21/2019
    * @param Map<Id, List<String>> fileMap - Map of record ids to box files
    * @param Map<Id, String> fcMap - Map of F&C records
    * @return String - Result message passed back to the async method
    */
    private static String updateRecords(Map<Id, List<BoxFile.Info>> fileMap, Map<Id, SObject> fcMap) {
        List<SObject> updates = new List<SObject>();

        // Create list of F&C record updates
        for(Id recordId : fileMap.keySet()) {
            for(BoxFile.Info file : fileMap.get(recordId)) {
                updates.add(new IETRS_Files_Correspondence__c(
                    Id = recordId,
                    IETRS_Box_File_ID__c = file.id,
                    IETRS_File_Size__c = String.valueOf(file.size),
                    IETRS_File_Name__c = file.name,
                    IETRS_File_Format__c = file.etag,
                    // IETRS_Description__c = file.description,
                    IETRS_Original_File_Name__c = file.description
                ));
            }
        }

        try {
            update updates;
            return 'Success';
        } catch(Exception ex) {
            return 'Error: Could not update F&C records: ' + ex.getMessage();
        }
    }
    

    /**
    * @description Deletes ContentDocumentLink records, and associated ContentDocument records
    * @author Mark Frizzell | 6/20/2019
    * @param Map<Id, List<ContentDocumentLink>> cdlMap - Map of F&C record ids to ContentDocumentLinks
    * @return String - Result message passed back to the async method
    */
    private static String deleteRecords(Map<Id, List<ContentDocumentLink>> cdlMap) {
        List<ContentDocument> deletions = new List<ContentDocument>();
        
        for(Id recordId : cdlMap.keySet()) {        
            for(ContentDocumentLink cdl : cdlMap.get(recordId)) {
                deletions.add(new ContentDocument(
                    Id = cdl.ContentDocumentId
                ));
            }
        }
        return deleteRecords(deletions);
    }

    private static String deleteRecords(Set<Id> recordIds) {
        List<SObject> deletions = new List<SObject>();
        
        for(Id recId : recordIds) {
            SObject obj = recId.getSobjectType().newSObject(recId);
            deletions.add(obj);
        }
        return deleteRecords(deletions);
    }

    private static String deleteRecords(List<SObject> deletions) {
        try {
            delete deletions;
            return 'Success';
        } catch(Exception ex) {
            return 'Error: Could not delete Salesforce temporary file(s): ' + ex.getMessage();
        }
    }
    
    /**
    * @description Sends an email to the user on error
    * @author Mark Frizzell | 7/19/2019
    * @param String message - Error message to include in email
    * @return void
    */
    public static void sendEmail(String message) {
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] { UserInfo.getUserEmail() };
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('ietrs@rrc.tx.gov');  
            mail.setSenderDisplayName('Texas Railroad Commission - IETRS');
            mail.setSubject('IETRS File Upload Error');
            mail.setPlainTextBody(
                'Your recent file upload in IETRS (Salesforce) failed.  Please try to upload the file again.\n\n' +
                message);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch(Exception ex) {
            System.debug('Problem sending the Box upload error email: ' + ex.getMessage());
        }
    }
    
    /**
    * @description Determines whether a box folder ID exists
    * @author Kevin Lu | 2/20/2020 
    * @param boxFolderId The input Box Folder ID
    * @param api The API connection used to make the check
    * @return boolean Whether or not the Box Folder exists
    **/
    private static boolean isValidFolder(String boxFolderId, BoxApiConnection api) {
        BoxFolder folder = new BoxFolder(api, boxFolderId);
        BoxFolder.Info folderInfo;
        if(boxFolderId == null || boxFolderId == '') {
            //File id is blank, so don't even bother getting file info
            return false;
        }
        try {
            // Valid folder
            folderInfo = folder.getFolderInfo();
            return true;
        }
        catch(BoxApiRequest.BoxApiRequestException ex) {
            // Invalid folder, so create one
            return false;
        }
    }
    
}