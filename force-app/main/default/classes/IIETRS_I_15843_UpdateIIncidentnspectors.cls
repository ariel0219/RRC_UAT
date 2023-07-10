/*
IIETRS_I_15843_UpdateIIncidentnspectors batchJob = new IIETRS_I_15843_UpdateIIncidentnspectorss();
ID jobID = Database.executeBatch(batchJob,70);
*/
global  class IIETRS_I_15843_UpdateIIncidentnspectors implements Database.Batchable<SObject>{
    global final String Query = 'Select Id, IETRS_Lead_Inspector__c,Lead_Inspector_Fullname__c FROM IETRS_Incident__c where IETRS_Lead_Inspector__c =\'\'  ';
    
    public IIETRS_I_15843_UpdateIIncidentnspectors() {
        System.debug('Update Inspectors: Constructor');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Update Inspectors: Start');
        System.debug(Query);
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<IETRS_Incident__c> scope){
        String InspectorName = '';
        String recordId = '';
     
        List<IETRS_Incident__c> ww = new List<IETRS_Incident__c>();     
        System.debug('Update Inspectors: Execute');
        for (IETRS_Incident__c i: scope) {
            
            List <User> u = [Select Id, Name, UserRoleId from User where Name =: i.Lead_Inspector_Fullname__c Limit 1];
            
            //   isRoleInspection = ur.get(u.UserRoleId);
            
            If (u.size()>0) {
                
                List<UserRole> ur = [Select Name from UserRole where Id =:u[0].UserRoleId Limit 1];
                if(ur.size() >0 && ur[0].Name.contains('Inspection')) {
                    system.debug(' Inspectors Name & Id '+ u[0].Name + '/'+u[0].Id);
                    i.IETRS_Lead_Inspector__c = u[0].Id;
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