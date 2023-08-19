@isTest
public class CIIS_FC_FolderID_Batch_Test {
@TestSetup
    public static void makeData() {
       IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c();
        Insert fc;
    }
    
    @IsTest
    public static void testmethod1(){
        Database.executeBatch(new CIIS_FC_FolderID_Batch(), 200);
    }
}