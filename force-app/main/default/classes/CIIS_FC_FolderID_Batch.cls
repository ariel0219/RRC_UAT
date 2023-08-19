public class CIIS_FC_FolderID_Batch implements Database.Batchable<Sobject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([ SELECT ID,
                                         rrc_Generate_Box_Folder_Structure__c,
                                         rrc_Box_App_Folder_Id__c,
                                         rrc_Workstream_Box_Folder_Id__c,
                                         rrc_Organization_Box_Folder_Id__c,
                                         rrc_Parent_Object_Box_Folder_Id__c
                                         FROM IETRS_Files_Correspondence__c WHERE 
                                         rrc_Box_App_Folder_Id__c = '' OR
                                         rrc_Workstream_Box_Folder_Id__c = '' OR
                                         rrc_Organization_Box_Folder_Id__c = '' OR
                                         rrc_Parent_Object_Box_Folder_Id__c = ''  LIMIT 25
                                        ]);
    }
    public void execute(Database.BatchableContext bc, List<IETRS_Files_Correspondence__c> scope){
        for(IETRS_Files_Correspondence__c fc: scope)
            fc.rrc_Generate_Box_Folder_Structure__c = true;
        
        Update scope;
    }
    public void finish(Database.BatchableContext bc){} 
}