//This class is to mass update all legacy compliant records in a terminal status so they pass through the new sharing automation
/* apex code to execute anonymously this class in prod:
IETRS_UpdateComplaint_15828 batchJob = new IETRS_UpdateComplaint_15828();
ID jobID = Database.executeBatch(batchJob,10);
System.debug(jobID);
*/
global with sharing class IETRS_UpdateComplaint_15828 implements Database.Batchable<SObject>{
    //query to select legacy compliant records in a terminal status
    global final String Query = 'SELECT Id '+
                                'FROM IETRS_Complaint__c '+
                                'WHERE IETRS_Complaint_Resolution_Status__c = \'Closed\'';

    //batch start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }   

    //batch execute method
    global void execute(Database.BatchableContext BC, List<IETRS_Complaint__c> scope){
        //we don't need to make changes, just get salesforce to trigger automation on the records in scope
        update scope;
    }

    //batch finish method
    global void finish(Database.BatchableContext BC){}
}