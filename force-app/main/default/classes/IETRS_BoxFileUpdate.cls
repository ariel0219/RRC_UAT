/**
 * @File Name          : IETRS_BoxFileUpdate.cls
 * @Description        : For use by F&C update flows to move file(s) within Box and update F&C record
 * @Author             : Sebastian Wittenstein
 * @Group              : IETRS - M&O
 * @Last Modified By   : Sebastian Wittenstein
 * @Last Modified On   : 07/12/2023
 * @Modification Log   : 
 *==============================================================================
 * Ver      Date            Author                      Modification
 *==============================================================================
 * 1.0      07/12/2023      Sebastian Wittenstein       Initial Version
 **/
 public without sharing class IETRS_BoxFileUpdate {
    
    /**
    * @description Invocable method called from flow that moves a file from it's current location to the folder Id in the F&C record
    * @author Sebastian Wittenstein | 07/12/2023
    * @param List<Id> fcRecordIds - F&C record ids passed in from the flow
    * @return List<String> - result message(s) to be passed back to the flow before the async code runs
    */
    @InvocableMethod
    public static void updateFiles(List<Id> fcRecordIds) {
        // IETRSBox.cls handles the API connection call out
        IETRSBox box;
        if (!Test.isRunningTest()) {
            box = new IETRSBox();
        }

        // List of the F&C records to be updated after the move command
        List<IETRS_Files_Correspondence__c> updateFCList = new List<IETRS_Files_Correspondence__c>();

        // Map to join fcRecordIds to the box file information after the move command
        Map<Id, BoxFile.Info> filesMap = new Map<Id, BoxFile.Info>();

        // Map of the F&C records who's Id's have been passed into the method
        Map<Id, IETRS_Files_Correspondence__c> fcMap = new Map<Id, IETRS_Files_Correspondence__c>(
            [
                SELECT Id, IETRS_Box_File_ID__c, IETRS_Box_File_Folder__c, IETRS_Case__r.IETRS_BoxFolderID__c
                FROM IETRS_Files_Correspondence__c
                WHERE Id IN :fcRecordIds
            ]
        );

        // Map of the F&C frup records, baseed on the F&C Id's have been passed into the method
        Map<Id, box__FRUP__c> frupMap = new Map<Id, box__FRUP__c>();

        // Populated the frupMap
        for(box__FRUP__c frup : 
            [
                SELECT Id, box__Folder_ID__c, box__Record_ID__c
                FROM box__FRUP__c
                WHERE box__Record_ID__c IN :fcRecordIds
            ]
        ) {
            frupMap.put(frup.box__Record_ID__c, frup);
        } 
        // Build the file.info values from the fcMap
        for(
            IETRS_Files_Correspondence__c fc : fcMap.values()
        ) { 
            // Create a BoxFile.Info variable to hold the response from the move file method
            BoxFile.Info file = new BoxFile.Info();
            // Create and set a Box File Id variable (type String) for use by the move file method
            String fileId = fc.IETRS_Box_File_ID__c;
            // Create a Box Folder Id variable (type String) for use by the move file method
            String folderId;
            
            if(
                // If the F&C Box Folder Id isn't popualted, but there is a FRUP record for the F&C record
                (
                    fc.IETRS_Box_File_Folder__c == null ||
                    fc.IETRS_Box_File_Folder__c == ''
                ) &&
                frupMap.get(fc.Id) != null
            ) { 
                // Pull out the frup needed to build the file info
                box__FRUP__c frup = new box__FRUP__c();
                frup = frupMap.get(fc.Id);
                folderId = frup.box__Folder_ID__c;
            } else {
                // If F&C Box Folder Id is populated, use that instead
                folderId = fc.IETRS_Box_File_Folder__c;
            }
            // Handling for unit tests 
            if(
                Test.isRunningTest()
            ) {
                // Don't actually run the move file command, just use some dummy returned values
                file.id = '00987654321';
                BoxFolder.Info folder = new BoxFolder.Info();
                folder.id = '1234567890';
                file.parent = folder;
            // When not part of a unit test
            } else{
                // Call the move file method of the IETRSBox class 
                file = box.MoveFile(fileId, folderId);
            }
            // After getting the file.info, add it to the filesMap
            filesMap.put(fc.Id, file);

        }
        // After individual file handling, update the F&C records
        for(
            Id recordId : filesMap.keySet()
        ) {
            // Create a BoxFile.Info variable to hold the response from the move file method
            BoxFile.Info file = new BoxFile.Info();
            // Assign the mapped file to the the file variable
            file = filesMap.get(recordId);
            // Extract the Folder from the file so we can reference it
            BoxFolder.Info folder = file.parent;
            // Then create an F&C record to be updated
            updateFCList.add(
                new IETRS_Files_Correspondence__c(
                    Id = recordId,
                    IETRS_Box_File_ID__c = file.id,
                    IETRS_Box_File_Folder__c = folder.id
                )
            );
            // Debug statment to allow visiblity into where files were moved from 
            System.debug('F&C initial Box File Id:'+fcMap.get(recordId).IETRS_Box_File_ID__c);
            System.debug('F&C updated Box File Id:'+file.id);
            // If the file is in the root folder (no folder ID on F&C)
            if(
                fcMap.get(recordId).IETRS_Box_File_ID__c == null ||
                fcMap.get(recordId).IETRS_Box_File_ID__c == ''
            ) {
                // Let the user know that and display the root folder instead
                System.debug('File in Root Folder:'+box.rootFolder.id);
            } else {
                // Otherwise pass the prior folder value
                System.debug('F&C initial Box Folder Id:'+fcMap.get(recordId).IETRS_Box_File_Folder__c);
            }
            System.debug('F&C updated Box Folder Id:'+folder.id);
        }
        try{
            update updateFCList;
        } catch(Exception e) {
            System.debug('Error updating F&C records: ' + e);
        }
    }
}