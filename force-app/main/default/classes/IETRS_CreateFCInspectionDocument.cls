public class IETRS_CreateFCInspectionDocument {
    public static void createFCInspDocuemtns(){
        List <IETRS_Files_Correspondence__c> fcList = new List<IETRS_Files_Correspondence__c>();
        if(!Test.isRunningTest())
        fcList = 
            [SELECT ID, IETRS_Public_Inspection_Document_Created__c, IETRS_Box_File_ID__c, IETRS_Complaint__c,
             IETRS_Incident__c,
             IETRS_Inspection_Package__c,
             IETRS_Notification__c,
             IETRS_Original_File_Name__c
             FROM IETRS_Files_Correspondence__c WHERE IETRS_Document_Type__c = 'PS-95 Submission' AND IETRS_Public_Inspection_Document_Created__c = false];
        else{
            fcList = 
            [SELECT ID, IETRS_Public_Inspection_Document_Created__c, IETRS_Box_File_ID__c, IETRS_Complaint__c,
             IETRS_Incident__c,
             IETRS_Inspection_Package__c,
             IETRS_Notification__c,
             IETRS_Original_File_Name__c
             FROM IETRS_Files_Correspondence__c WHERE IETRS_Public_Inspection_Document_Created__c = false];
        }
        
        List <IETRS_Inspection_Public_FC_Document__c> inspectionDocuments = new List<IETRS_Inspection_Public_FC_Document__c>();
        for (IETRS_Files_Correspondence__c fc : fcList) {
            try {
                IETRS_Inspection_Public_FC_Document__c inspectionDocument = new IETRS_Inspection_Public_FC_Document__c(
                    IETRS_Box_File_ID__c = fc.IETRS_Box_File_ID__c,
                    IETRS_Complaint__c = fc.IETRS_Complaint__c,
                    IETRS_Incident__c = fc.IETRS_Incident__c,
                    IETRS_Inspection_Package__c = fc.IETRS_Inspection_Package__c,
                    IETRS_Notification__c = fc.IETRS_Notification__c,
                    IETRS_Original_File_Name__c = fc.IETRS_Original_File_Name__c,
                    IETRS_Related_File_Correspondence__c = fc.id,
                    IETRS_Shared_Public_Record_Account__c = System.Label.IETRS_Portal_Sharing_Account_ID
                );
                inspectionDocuments.add(inspectionDocument);
                fc.IETRS_Public_Inspection_Document_Created__c = true;
            } catch (Exception e) {
            }
        }
	    insert inspectionDocuments;
        update fcList;
    }
}