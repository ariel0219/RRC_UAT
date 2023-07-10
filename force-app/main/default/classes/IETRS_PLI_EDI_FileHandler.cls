/*
 ** Creator: Steve Villanueva
 ** Date Created: 12/17/2020
 ** Parameter: strEDIFileId - Content Document ID of EDI File uploaded to Salesforce Files.
 ** Usage: Reads the loaded file and returns the Version Data of the file as a string. This method is invoked by the IETRS_PLI_EDI LWC.
 ** Version History:
 ** Version     Date             Developer                Description
 ** -------  ----------       ----------------        --------------------
 ** v1.0     12/17/2020       Steve Villanueva        Initial Creation
 ** v2.0     07/16/2021       Forrest Chang           Post Go Live Updates and comments
 */
global with sharing class IETRS_PLI_EDI_FileHandler {
    /* 
    Creator: Steve Villanueva
    Date Created: 12/17/2020
    Parameter: strEDIFileId - Content Document ID of EDI File uploaded to Salesforce Files.
    Usage: Reads the loaded file and returns the Version Data of the file as a string. This method is invoked by the IETRS_PLI_EDI LWC.
    */
    @AuraEnabled(cacheable=true)
    public static String readEDIFile(String strEDIFileId) {
        //Get the ContentVerionID from the provided EDI File
        String strBody;
        ContentVersion objVersion = [
            SELECT Id, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId = :strEDIFileId
        ];
        //Validates content is returned
        if (objVersion != null) {
            strBody = objVersion.VersionData.toString();
        }
        return strBody;
    }
    /* 
    Creator: Steve Villanueva
    Date Created: 12/17/2020
    Usage: Get Custom Metadata translating EDI Code Values into Salesforce picklist values. This method is invoked by the IETRS_PLI_EDI LWC.
    */
    @AuraEnabled(cacheable=true)
    public static List<IETRS_PLI_PS95_EDI_Code_Mappings__mdt> getEDICustomMetadata() {
        return [
            SELECT
                Label,
                DeveloperName,
                IETRS_Code_Type__c,
                IETRS_EDI_Code__c,
                IETRS_Salesforce_Value__c,
                IETRS_EDI_Column_Number__c,
                Id
            FROM IETRS_PLI_PS95_EDI_Code_Mappings__mdt
            ORDER BY IETRS_Code_Type__c ASC NULLS FIRST, IETRS_EDI_CODE__C ASC
        ];
    }

    /* 
    Creator: Forrest Chang
    Date Created: 07/16/2021
    Parameter: lstInsertNotifDetails - List of Notification Details to be inserted.
    Usage: Saves information brought in from loaded EDI file as a Notification Detail.
    */
    @AuraEnabled
    public static String saveEDIRepairedLeaks(
        List<IETRS_Insp_Notification_Detail__c> lstInsertNotifDetails,
        boolean blnSendEventOnFinish
    ) {
        System.debug('saveEDIRepairedLeaks()');
        try {
            //Execute batch job to insert Notification Details
            IETRS_EDI_NotifDetail_Batch batchInsert = new IETRS_EDI_NotifDetail_Batch(
                lstInsertNotifDetails,
                blnSendEventOnFinish
            );
            ID jobID = Database.executeBatch(batchInsert, 200);
            System.debug('Notification Detail Batch jobID: ' + jobID);
            if (blnSendEventOnFinish) {
                return jobID;
            } else {
                return '';
            }
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    /**
     * Create a File & Correspondence record representing the uploaded PS-95 file.
     * @param notificationId Id of the IETRS_Notification__c record associated with the file.
     * @param fileId ContentDocumentId of the PS-95 file uploaded by the user.
     * @return  `Id`
     */
    public static Id createFCRecord(Id notificationId, Id fileId) {
        // get file
        ContentVersion cv = [
            SELECT PathOnClient, Title, FileExtension, FileType
            FROM ContentVersion
            WHERE ContentDocumentId = :fileId AND IsLatest = TRUE
            LIMIT 1
        ];
        // create f&c
        IETRS_Files_Correspondence__c fcRecord = new IETRS_Files_Correspondence__c(
            IETRS_Business_Area_Division__c = 'Pipeline Safety',
            IETRS_Document_Type__c = 'PS-95 Submission',
            IETRS_File_Name__c = cv.Title + cv.FileExtension,
            IETRS_Notification__c = notificationId,
            IETRS_Date_Filed__c = System.now(),
            IETRS_File_Format__c = cv.FileType,
            IETRS_Original_File_Name__c = cv.PathOnClient
        );
        insert fcRecord;

        return fcRecord.Id;
    }

    @AuraEnabled
    /**
     * Create a new Box file using details from the notification and uploaded file.
     * @param notificationId Id of the IETRS_Notification__c record associated with the file.
     * @param fileId Id of the ContentDocument of the PS-95 file uploaded by the user.
     * @return  `IETRS_Files_Correspondence__c`
     */
    public static IETRS_Files_Correspondence__c createBoxFile(
        Id notificationId,
        Id fileId
    ) {
        // get record name for folder
        String notificationName = [
            SELECT Name
            FROM IETRS_Insp_Notification__c
            WHERE Id = :notificationId
            LIMIT 1
        ]
        ?.Name;

        // get file
        ContentVersion cv = [
            SELECT VersionData, PathOnClient
            FROM ContentVersion
            WHERE ContentDocumentId = :fileId AND IsLatest = TRUE
            LIMIT 1
        ];

        // upload file
        BoxFolder.Info folderInfo;
        BoxFile.Info file = new BoxFile.Info();
        if (!Test.isRunningTest()) {
            IETRSBox box = new IETRSBox();
            folderInfo = box.createFolder(notificationName);
            file = box.uploadFile(
                cv.VersionData,
                cv.PathOnClient,
                folderInfo.id
            );
        } else {
            folderInfo = new BoxFolder.Info();
            folderInfo.id = '12345678900';
            file.id = '00987654321';
            file.name = cv.PathOnClient;
            file.size = 10000;
        }

        // populate fc with box file details for update in separate execution context
        IETRS_Files_Correspondence__c fcRecord = new IETRS_Files_Correspondence__c();
        fcRecord.IETRS_Box_File_Folder__c = folderInfo.id;
        fcRecord.IETRS_Box_File_ID__c = file.id;
        fcRecord.IETRS_File_Size__c = String.valueOf(file.size);
        fcRecord.IETRS_File_Name__c = file.name;
        fcRecord.IETRS_Public__c = true;
        return fcRecord;
    }

    @AuraEnabled
    /**
     * Used to update the IETRS_Files_Correspondence__c with the values set
     *  from the uploaded Box file.
     * @param fcRecord The IETRS_Files_Correspondence__c record to update.
     */
    public static void updateFCRecord(IETRS_Files_Correspondence__c fcRecord) {
        update fcRecord;
    }

    /* 
    Creator: Steve Villanueva
    Date Created: 12/17/2020
    Parameter: strEDIFileId - Content Document ID of EDI File uploaded to Salesforce Files.
    Usage: Removes the EDI file that is loaded to read as a temporary file.
    */
    @AuraEnabled
    public static String deleteDocument(String strEDIFileId) {
        try {
            delete [SELECT Id FROM ContentDocument WHERE Id = :strEDIFileId];
            return 'SUCCESS';
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /* 
    Creator: Steve Villanueva
    Date Created: 12/17/2020
    Usage: Gets list of County Codes to translate County Codes to Salesforce IDs of County Codes.
    */
    @AuraEnabled(cacheable=true)
    public static List<IETRS_County__c> getCountyCode() {
        return [SELECT Id, IETRS_Oil_Gas_County_Code__c FROM IETRS_County__c];
    }
    /* 
    Creator: Steve Villanueva
    Date Created: 12/17/2020
    Usage: Get Operator Leak Id from Notification Details.
    */
    @AuraEnabled(cacheable=false)
    public static List<IETRS_Insp_Notification_Detail__c> getOperLeakId(
        String strNotificationID
    ) {
        system.debug(strNotificationID);
        return [
            SELECT IETRS_Operator_Leak_ID__c
            FROM IETRS_Insp_Notification_Detail__c
            WHERE
                IETRS_Operator_Leak_ID__c != NULL
                AND IETRS_Notification__c = :strNotificationID
            ORDER BY IETRS_Operator_Leak_ID__c ASC NULLS LAST
        ];
    }
    /* 
    Creator: Steve Villanueva
    Date Created: 12/28/2020
    Parameter: strOrgID - The Salesforce ID of the Organization grandparent of a set of Regulated Entities.
    Usage: Returns list of Regulated Entities associated the the Organization ID paramter.
    */
    @AuraEnabled(cacheable=true)
    public static List<Account> getRegEntIdList(string strOrgID) {
        try {
            List<Account> regEntList = [
                SELECT Id, IETRS_Regulated_Entity_ID__c
                FROM Account
                WHERE
                    parent.ParentId = :strOrgID
                    AND RecordType.Name = 'Regulated Entity - PS'
            ];
            return regEntList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /* 
    Creator: Steve Villanueva
    Date Created: 01/12/2021
    Usage: Get ID from Record type for PS-95 on the Notification Details object.
    */
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getIdOfNotDetRecType() {
        return [
            SELECT Id
            FROM RecordType
            WHERE
                SobjectType = 'IETRS_Insp_Notification_Detail__c'
                AND DeveloperName = 'IETRS_PS_95'
        ];
    }

    /* 
    Creator: Forrest Chang
    Date Created: 07/27/2021
    Usage: Get the status of ongoing async batch apex.
    */
    @AuraEnabled
    public static string getBatchStatus(String strJobId) {
        try {
            return [
                SELECT Status, NumberOfErrors
                FROM AsyncApexJob
                WHERE Id = :strJobId
                LIMIT 1
            ]
            .Status;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}