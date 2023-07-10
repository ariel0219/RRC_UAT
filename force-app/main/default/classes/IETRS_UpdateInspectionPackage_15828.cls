//This class is to mass update all legacy inspection package records in a terminal status so they pass through the new sharing automation
/* apex code to execute anonymously this class in prod:
IETRS_UpdateInspectionPackage_15828 batchJob = new IETRS_UpdateInspectionPackage_15828();
ID jobID = Database.executeBatch(batchJob,10);
System.debug(jobID);
*/
global with sharing class IETRS_UpdateInspectionPackage_15828 implements Database.Batchable<SObject>{
    //query to select legacy inspection package records in a terminal status
    global final String Query = 'SELECT Id '+
                                'FROM IETRS_Inspection_Package__c '+
                                'WHERE IETRS_Status__c  != \'Initial\' '+
                                'AND IETRS_Status__c  != \'WIP/Rejected\' ' +
                                'AND IETRS_Status__c  != \'Work in Progress\' ';

    //batch start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }   

    //batch execute method
    global void execute(Database.BatchableContext BC, List<IETRS_Inspection_Package__c> scope){
        //we don't need to make changes, just get salesforce to trigger automation on the records in scope
        update scope;
    }

    //batch finish method
    global void finish(Database.BatchableContext BC){}
}