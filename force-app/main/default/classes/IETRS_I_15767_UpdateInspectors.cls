/*
IETRS_I_15767_UpdateInspectors batchJob = new IETRS_I_15767_UpdateInspectors();
ID jobID = Database.executeBatch(batchJob,70);
*/
global  class IETRS_I_15767_UpdateInspectors implements Database.Batchable<SObject>{
    global final String Query = 'Select IETRS_Inspector_Fullname_Legacy__c,Id From IETRS_Insp_Inspection_Package_Inspector__c Where IETRS_Inspector__c =\'\'  ';
    
    public IETRS_I_15767_UpdateInspectors() {
        System.debug('Update Inspectors: Constructor');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Update Inspectors: Start');
        System.debug(Query);
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<IETRS_Insp_Inspection_Package_Inspector__c> scope){
        String InspectorName = '';
        String recordId = '';
        List<IETRS_Insp_Inspection_Package_Inspector__c> ww = new List<IETRS_Insp_Inspection_Package_Inspector__c>();
        //    List<UserRole> ur = [Select Id,Name from UserRole where Name like '%Inspection%'];
        
        System.debug('Update Inspectors: Execute');
        for (IETRS_Insp_Inspection_Package_Inspector__c i: scope) {
            
            List <User> u = [Select Id, Name, UserRoleId from User where Name =: i.IETRS_Inspector_Fullname_Legacy__c Limit 1];
            
            //   isRoleInspection = ur.get(u.UserRoleId);
            
            If (u.size()>0) {
                
                List<UserRole> ur = [Select Name from UserRole where Id =:u[0].UserRoleId Limit 1];
                if(ur.size() >0 && ur[0].Name.contains('Inspection')) {
                    system.debug(' Inspectors Name & Id '+ u[0].Name + '/'+u[0].Id);
                    i.IETRS_Inspector__c = u[0].Id;
                    ww.add(i);
                }
            } 
            
        }
        
        update ww;
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('Update IETRS_Files_Correspondence__c.IETRS_Public__c: Finish');
    }
    
}