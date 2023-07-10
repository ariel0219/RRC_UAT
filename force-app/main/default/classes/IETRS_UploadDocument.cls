/*
  @Class Name         : IETRS_UploadDocument
  @Description        : Generate the Documents to Box from Files.
  @Author             : Srilu Mamillapalli
  @Group              : 
  @Last Modified By   : Srilu Mamillapalli
  @Last Modified On   : 4/07/2020
  @Modification Log   : 
  ==============================================================================
  Ver         Date                     Author                 Modification
  ==============================================================================
  1.0    3/20/2020,    Srilu Mamillapalli     Initial Version
*/

public class IETRS_UploadDocument {
    private static final Integer MAX_FILE_SIZE = Test.isRunningTest() ? 4000 : 8 * 1024 * 1024; // can't make an 8MB blob in test class

    /**
     * @description Async method that gathers related records and starts the upload process
     * @author  Srilu Mamillapalli | 3/20/2020
     * @param List<Id> fcRecordIds - F&C record Ids to use
     * @return void
     */
    @Future(callout=true)
    public static void prepareUploadAsync(set<Id> fcRecordIds) {
        Map<Id, SObject> parentMap = new Map<Id, SObject>();
        Map<Id, List<ContentDocumentLink>> cdlMap = new Map<Id, List<ContentDocumentLink>>();
        Map<Id, ContentVersion> versionMap = new Map<Id, ContentVersion>();
        List<Id> versionIds = new List<Id>();
        List<ContentDocumentLink> tempCDLs = new List<ContentDocumentLink>();

        // Map F&C records to parent records
        String fcQuery =
            'SELECT Id, Name, IETRS_Box_File_ID__c, IETRS_Box_File_Folder__c ' +
            'FROM IETRS_Files_Correspondence__c ' +
            'WHERE Id IN :fcRecordIds';
        for (IETRS_Files_Correspondence__c fc : Database.query(fcQuery)) {
            // if(fc.IETRS_Box_File_ID__c != null) {
            parentMap.put(fc.Id, fc);
            //  }
        }

        // Map F&C records to ContentDocumentLink records
        String cdlQuery =
            'SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, ' +
            'LinkedEntityId, LinkedEntity.Name ' +
            'FROM ContentDocumentLink ' +
            'WHERE LinkedEntityId IN :fcRecordIds';
        for (ContentDocumentLink cdl : Database.query(cdlQuery)) {
            if (cdlMap.containsKey(cdl.LinkedEntityId)) {
                tempCDLs = cdlMap.get(cdl.LinkedEntityId);
            }
            versionIds.add(cdl.ContentDocument.LatestPublishedVersionId); // used for next query
            tempCDLs.add(cdl);
            cdlMap.put(cdl.LinkedEntityId, tempCDLs);
        }

        // Map F&C records to ContentVersions
        String cvQuery =
            'SELECT Id, VersionData, PathOnClient, ContentSize, FileExtension, FileType ' +
            'FROM ContentVersion ' +
            'WHERE Id IN :versionIds';
        for (ContentVersion cv : Database.query(cvQuery)) {
            versionMap.put(cv.Id, cv);
        }

        // Upload files to Box
        String uploadResult = uploadFiles(cdlMap, versionMap, parentMap);
        System.debug('uploadResult: ' + uploadResult);
        // fire the box upload event to indicate an upload is finished
        EventBus.publish(new List<Box_Upload__e>{ new Box_Upload__e() });

        // Send email on error (except file size)
        if (uploadResult != 'Success') {
            // sendEmail(uploadResult);
        }
    }

    /**
     * @description Saves file(s) to Box in the parent record's Box folder
     * @author  Srilu Mamillapalli | 3/20/2020
     * @param Map<Id, Map<Id, List<ContentDocumentLink>> cdlMap - Map of F&C record ids to ContentDocumentLinks
     * @param Map<Id, ContentVersion> versionMap - Map of ContentVersions including file blobs
     * @param Map<Id, String> parentMap - Map of F&C records to parent records
     * @return String - Result message passed back to the async method
     */
    public static String uploadFiles(
        Map<Id, List<ContentDocumentLink>> cdlMap,
        Map<Id, ContentVersion> versionMap,
        Map<Id, SObject> parentMap
    ) {
        IETRSBox box;
        if (!Test.isRunningTest()) {
            box = new IETRSBox();
        }
        Map<Id, List<BoxFile.Info>> fileMap = new Map<Id, List<BoxFile.Info>>();

        for (Id recordId : cdlMap.keySet()) {
            List<BoxFile.Info> fileList = new List<BoxFile.Info>();

            for (ContentDocumentLink cdl : cdlMap.get(recordId)) {
                ContentVersion cv = versionMap.get(cdl.ContentDocument.LatestPublishedVersionId);
                BoxFolder.Info folder = new BoxFolder.Info();
                BoxFile.Info file = new BoxFile.Info();
                String fileName = cdl.LinkedEntity.Name + (cv.FileExtension == null ? '' : ('.' + cv.FileExtension));
                system.debug('fileName' + fileName);
                try {
                    if (parentMap.containsKey(recordId)) {
                        // Parent record exists
                        SObject parent = parentMap.get(recordId);
                        if (parent.get('IETRS_Box_File_Folder__c') != null) {
                            // Use existing parent folder
                            folder.id = String.valueOf(parent.get('IETRS_Box_File_Folder__c'));
                        } else {
                            // No folder on parent, so create one and update parent
                            String folderName = (String) parent.get('Id');
                            if (!Test.isRunningTest()) {
                                folder = box.createFolder(folderName);
                            } else {
                                folder.id = '1234567890';
                                folder.name = folderName;
                            }
                            parent.put('IETRS_Box_File_Folder__c', folder.id);
                            parentMap.put(recordId, parent);
                        }
                    } else {
                        // No parent record exists, so create folder for F&C record instead
                        String folderName = cdl.LinkedEntity.Id;
                        system.debug('folderName' + folderName);
                        if (!Test.isRunningTest()) {
                            folder = box.createFolder(folderName);
                        } else {
                            // for unit tests only
                            folder.id = '12345678900';
                            folder.name = folderName;
                        }
                    }

                    // Upload file
                    System.debug('folder.id: ' + folder.id + ' fileName: ' + fileName);
                    if (!Test.isRunningTest()) {
                        file = box.uploadFile(cv.VersionData, fileName, folder.id);
                    } else {
                        // for unit tests only
                        file.id = '00987654321';
                        file.name = fileName;
                        file.parent = folder;
                        file.size = 1000000;
                    }
                    // Get file type, store original filename
                    file.etag = cv.FileType;
                    file.description = cv.PathOnClient;
                    if (!Test.isRunningTest()) {
                        box.addFileMetadata(
                            new Map<String, String>{ 'Original File Name' => file.description },
                            file.id
                        );
                    }
                } catch (Exception ex) {
                    return 'Error uploading file: ' + ex.getMessage() + ' @ ' + ex.getLineNumber();
                }
                system.debug('fileMap1' + fileMap);
                if (fileMap.containsKey(recordId)) {
                    fileList = fileMap.get(recordId);
                }
                system.debug('fileList' + fileList);
                fileList.add(file);
                fileMap.put(recordId, fileList);
            }
        }
        system.debug('fileMap' + fileMap);
        String updateResult = updateRecords(fileMap, parentMap);
        system.debug('updateResult' + updateResult);
        if (updateResult == 'Success') {
            return deleteRecords(cdlMap);
        } else {
            // attempt to set Is Uploading to false if the upload or update fails
            List<IETRS_Files_Correspondence__c> fileRecords = new List<IETRS_Files_Correspondence__c>();
            for (Id recordId : fileMap.keySet()) {
                fileRecords.add(new IETRS_Files_Correspondence__c(Id = recordId, IETRS_Is_Uploading__c = false));
            }
            if (!fileRecords.isEmpty()) {
                update fileRecords;
            }
            return updateResult;
        }
    }

    /**
     * @description Updates F&C record(s) with Box file details
     * @author Mark Frizzell | 5/21/2019
     * @param Map<Id, List<String>> fileMap - Map of record ids to box files
     * @param Map<Id, String> parentMap - Map of F&C records to parent records
     * @return String - Result message passed back to the async method
     */
    public static String updateRecords(Map<Id, List<BoxFile.Info>> fileMap, Map<Id, SObject> parentMap) {
        List<SObject> updates = new List<SObject>();
        set<SObject> updates1 = new Set<SObject>();

        // Create list of F&C record updates
        for (Id recordId : fileMap.keySet()) {
            if (parentMap.containsKey(recordId)) {
                updates.add(parentMap.get(recordId));
            }
            system.debug('fileMap' + fileMap);
            system.debug('fileMap' + fileMap.get(recordId));
            for (BoxFile.Info file : fileMap.get(recordId)) {
                System.debug('file');
                System.debug(file.id);
                System.debug(file.parent.id);
                updates1.add(
                    new IETRS_Files_Correspondence__c(
                        Id = recordId,
                        IETRS_Box_File_ID__c = file.id,
                        IETRS_Box_File_Folder__c = file.parent.id,
                        IETRS_File_Size__c = String.valueOf(file.size),
                        IETRS_File_Name__c = file.name,
                        IETRS_File_Format__c = file.etag,
                        // IETRS_Description__c = file.description,
                        IETRS_Original_File_Name__c = file.description,
                        IETRS_Is_Uploading__c = false
                    )
                );
            }
        }
        map<Id, Sobject> mapofREc = new Map<Id, Sobject>();
        for (Sobject rec : updates1) {
            mapofREc.put(rec.Id, rec);
        }
        system.debug('updates1' + mapofREc.values().size());
        try {
            updates = mapofREc.values();
            // updates.addAll(updates1);
            system.debug('updates' + updates.size());
            update updates;
            return 'Success';
        } catch (Exception ex) {
            return 'Error: Could not update F&C records: ' + ex.getMessage();
        }
    }

    /**
     * @description Deletes ContentDocumentLink records, and associated ContentDocument records
     * @author Mark Frizzell | 6/20/2019
     * @param Map<Id, List<ContentDocumentLink>> cdlMap - Map of F&C record ids to ContentDocumentLinks
     * @return String - Result message passed back to the async method
     */
    public static String deleteRecords(Map<Id, List<ContentDocumentLink>> cdlMap) {
        List<ContentDocument> deletions = new List<ContentDocument>();

        for (Id recordId : cdlMap.keySet()) {
            for (ContentDocumentLink cdl : cdlMap.get(recordId)) {
                deletions.add(new ContentDocument(Id = cdl.ContentDocumentId));
            }
        }
        return deleteRecords(deletions);
    }

    public static String deleteRecords(Set<Id> recordIds) {
        List<SObject> deletions = new List<SObject>();

        for (Id recId : recordIds) {
            SObject obj = recId.getSobjectType().newSObject(recId);
            deletions.add(obj);
        }
        return deleteRecords(deletions);
    }

    public static String deleteRecords(List<SObject> deletions) {
        try {
            delete deletions;
            return 'Success';
        } catch (Exception ex) {
            return 'Error: Could not delete Salesforce temporary file(s): ' + ex.getMessage();
        }
    }
}