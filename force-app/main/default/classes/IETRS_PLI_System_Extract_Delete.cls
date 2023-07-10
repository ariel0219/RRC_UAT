/**
 * @description       : Batch class to delete PLI Extract System records
 * @author            : Kevin Lu
 * @group             : 
 * @last modified on  : 2020-09-01
 * @last modified by  : Kevin Lu
 * Modifications Log 
 * Ver   Date         Author     Modification
 * 1.0   2020-09-01   Kevin Lu   Initial Version
**/
public class IETRS_PLI_System_Extract_Delete implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = 'Select Id From IETRS_PLI_Extract_System__c';
        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext bc, List<IETRS_PLI_Extract_System__c> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext bc) {
        Database.executeBatch(new IETRS_PLI_System_Extract());
    }
}