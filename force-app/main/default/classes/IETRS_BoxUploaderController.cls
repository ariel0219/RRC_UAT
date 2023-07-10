/**
 * @File Name          : IETRS_BoxUploaderController.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 5/13/2020, 2:34:29 PM
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      3/13/2020       Kevin Lu                Initial Version
 * 2.0      05/13/2020      Kevin Lu                Changed to "without sharing" to account for users uploading files to cases that have since changed record types
**/
public without sharing class IETRS_BoxUploaderController {
    /**
    * @description Invocable method to get a Box access token downscoped for file uploads
    * @author Kevin Lu | 3/13/2020 
    * @return List<String> The downscoped Box access token in a list
    **/
    @InvocableMethod(label='Get Downscoped Access Token' description='Returns a downscoped access token for Box Upload')
    public static List<String> getDownscopedAccessToken() {
        IETRSBox box = new IETRSBox();
        return new List<String> {box.getDownscopeToken('')}; //Empty parameter for file upload token
    }

    /**
    * @description Updates an F&C record after successful file upload to Box
    * @author Kevin Lu | 3/13/2020 
    * @param boxFileId The Box File Id of the file
    * @param fcRecordId The Salesforce ID of the F&C record
    * @param originalFileName The original file name
    * @param fileSize The size of the file
    * @return void
    **/
    @AuraEnabled
    public static void processFileUpload(String boxFileId, String fcRecordId, String originalFileName, String fileSize) {
        System.debug('**** Inside process File Upload ****');
        List<SObject> updates = new List<SObject>();
        IETRSBox box = new IETRSBox();
        BoxFolder.Info folderInfo;
        String folderId = '';
        //Get the FC record
        IETRS_Files_Correspondence__c fc = [
            Select 
                Id, Name, IETRS_Box_File_ID__c, IETRS_Original_File_Name__c, IETRS_Box_File_Folder__c,
                IETRS_Case__c, IETRS_Case__r.CaseNumber, IETRS_Case__r.IETRS_BoxFolderID__c, 
                AFS_Exemption__c, AFS_Exemption__r.AFS_Box_FolderID__c, AFS_Exemption__r.Name
            From IETRS_Files_Correspondence__c
            Where Id = :fcRecordId
            Limit 1
        ].get(0);
        System.debug('Exemption id: ' + fc.AFS_Exemption__c);
        Schema.SObjectType exm = Schema.AFS_Exemption__c.getSObjectType();
        //Schema.DisplayType exm = Schema.SObjectType.AFS_Exemption__c();
        if(fc.IETRS_Case__c != null){
            System.debug('Inside case not null');

            //Logic for Box folder identification
            if(fc.IETRS_Box_File_Folder__c != null && isValidFolder(fc.IETRS_Box_File_Folder__c, box.api)) {
                //If the F&C record already has a folder
                folderId = fc.IETRS_Box_File_Folder__c;
            } else if(fc.IETRS_Box_File_Folder__c == null && fc.IETRS_Case__r.IETRS_BoxFolderID__c != null && isValidFolder(fc.IETRS_Case__r.IETRS_BoxFolderID__c, box.api)) {
                //If the related Case already has a folder
                folderId = fc.IETRS_Case__r.IETRS_BoxFolderID__c;
            } else {
                //No folder, so create one
                if(fc.IETRS_Case__c != null) {
                    //If the case relationship is populated, make the folder based on the case name
                    folderInfo = box.createFolder('CASE-' + fc.IETRS_Case__r.CaseNumber);
                    folderId = folderInfo.id;

                    //Update Case as well
                    Case c = new Case();
                    c.Id = fc.IETRS_Case__c;
                    c.IETRS_BoxFolderID__c = folderId;
                    updates.add(c);
                } else {
                    //Otherwise, make the folder based on the F&C name
                    folderInfo = box.createFolder(fc.Name);
                    folderId = folderInfo.id;
                }
            }
        }
            
            ////Update FC Box info, Update the file name to the F&C name and move to a new folder
            //updateFCBoxInfo(boxFileId, fc, originalFileName, fileSize, folderId);
            //Update FC Box info
        fc.IETRS_Box_File_ID__c = boxFileId;
        fc.IETRS_Original_File_Name__c = originalFileName;
        fc.IETRS_File_Size__c = fileSize;
        fc.IETRS_File_Format__c = originalFileName.substringAfterLast('.').toUpperCase();
        fc.IETRS_Box_File_Folder__c = folderId;
        updates.add(fc);

        //Update the file name to the F&C name and move to a new folder
        try {
            box.moveFile(boxFileId, folderId);
            box.updateFileName(boxFileId, fc.Name + '.' + originalFileName.substringAfterLast('.'));
        } catch (Exception e) {
            System.debug('File rename/move failed for Box File Id ' + boxFileId + ' ' + e.getMessage() + ' ');
        }
        
        //Perform updates
        try {
            update updates;
        } catch (Exception e) {
            System.debug('Update failed: ' + e.getMessage());
        }
        
    }

    public static void processFileUploadExemption(String boxFileId, IETRS_Files_Correspondence__c fc, String originalFileName, String fileSize, String excemptionID){
        System.debug('**** Inside Exemption Load ****');
        //Schema.DisplayType exm = Schema.SObjectType.AFS_Exemption__c();
        IETRSBox box = new IETRSBox();
        BoxFolder.Info folderInfo;
        String folderId = '';
        List<SObject> updates = new List<SObject>();

        if(fc.IETRS_Box_File_Folder__c != null && isValidFolder(fc.IETRS_Box_File_Folder__c, box.api)) {
            //If the F&C record already has a folder
            folderId = fc.IETRS_Box_File_Folder__c;
        }  else if(fc.IETRS_Box_File_Folder__c == null && fc.AFS_Exemption__r.AFS_Box_FolderID__c != null && isValidFolder(fc.AFS_Exemption__r.AFS_Box_FolderID__c, box.api)) {
            //If the related Exemption already has a folder
            folderId = fc.AFS_Exemption__r.AFS_Box_FolderID__c;
        } else {
            //No folder, so create one
            if(fc.AFS_Exemption__r.AFS_Box_FolderID__c == null) {
                //If the Exemption relationship is populated, make the folder based on the Exemption name
                folderInfo = box.createFolder('CASE-' + fc.AFS_Exemption__r.Name);
                folderId = folderInfo.id;

                //Update Exemption as well
                AFS_Exemption__c exec = new AFS_Exemption__c();
                exec.Id = fc.AFS_Exemption__c;
                exec.AFS_Box_FolderID__c = folderId;
                updates.add(exec);
            } else {
                //Otherwise, make the folder based on the F&C name
                folderInfo = box.createFolder(fc.Name);
                folderId = folderInfo.id;
            }
        }

        ////Update FC Box info, Update the file name to the F&C name and move to a new folder
        //updateFCBoxInfo(boxFileId, fc, originalFileName, fileSize, folderId);
        //Update FC Box info
        fc.IETRS_Box_File_ID__c = boxFileId;
        fc.IETRS_Original_File_Name__c = originalFileName;
        fc.IETRS_File_Size__c = fileSize;
        fc.IETRS_File_Format__c = originalFileName.substringAfterLast('.').toUpperCase();
        fc.IETRS_Box_File_Folder__c = folderId;
        updates.add(fc);

        //Update the file name to the F&C name and move to a new folder
        try {
            box.moveFile(boxFileId, folderId);
            box.updateFileName(boxFileId, fc.Name + '.' + originalFileName.substringAfterLast('.'));
        } catch (Exception e) {
            System.debug('File rename/move failed for Box File Id ' + boxFileId + ' ' + e.getMessage() + ' ');
        }
        
        //Perform updates
        try {
            update updates;
        } catch (Exception e) {
            System.debug('Update failed: ' + e.getMessage());
        }
    }

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