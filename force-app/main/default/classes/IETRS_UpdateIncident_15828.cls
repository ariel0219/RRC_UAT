//This class is to mass update all legacy incident records in a terminal status so they pass through the new sharing automation
/* apex code to execute anonymously this class in prod:
IETRS_UpdateIncident_15828 batchJob = new IETRS_UpdateIncident_15828();
ID jobID = Database.executeBatch(batchJob,10);
System.debug(jobID);
*/
global with sharing class IETRS_UpdateIncident_15828 implements Database.Batchable<SObject>{
    //query to select legacy incident records in a terminal status
    global final String Query = 'SELECT Id '+
                                'FROM IETRS_Incident__c '+
                                'WHERE (IETRS_Incident_Status__c = \'Closed\' '+
                                    'OR IETRS_Incident_Status__c = \'Complete\') ';

    //batch start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }   

    //batch execute method
    global void execute(Database.BatchableContext BC, List<IETRS_Incident__c> scope){
        //we don't need to make changes, just get salesforce to trigger automation on the records in scope
        update scope;
    }

    //batch finish method
    global void finish(Database.BatchableContext BC){}
}