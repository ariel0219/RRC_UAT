/**
 * @File Name          : IETRS_PLI_Unit_Extract.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 2020-09-01
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      06/16/2020      Kevin Lu                Initial Version
 * 2.0      09/01/2020      Kevin Lu                Removed truncation logic
**/
global class IETRS_PLI_Unit_Extract implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Truncate the object before beginning the new load
        /*List<IETRS_PLI_Extract_Unit__c> lstDelete = [Select Id From IETRS_PLI_Extract_Unit__c];
        delete lstDelete;*/

        /* 
        Formatted Query
        Select 
            Parent.IETRS_P5_Number__c
            ,IETRS_Account_ID__c
        From 
            Account
        Where 
            RecordType.Name = 'Unit'
            And Parent.IETRS_P5_Number__c != Null
            And Parent.IETRS_P5_Number__c != '000000'
            And ParentId In (
                Select AccountId
                From Contact
                Where IETRS_Contact_Type__c In ('Company Representative', 'TPD Representative')
            )
        */

        String strQuery = 'Select Parent.IETRS_P5_Number__c ,IETRS_Account_ID__c From Account Where RecordType.Name = \'Unit\' And Parent.IETRS_P5_Number__c != Null And Parent.IETRS_P5_Number__c != \'000000\' And ParentId In (Select AccountId From Contact Where IETRS_Contact_Type__c In (\'Company Representative\', \'TPD Representative\'))';
        return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        List<IETRS_PLI_Extract_Unit__c> lstExtract = new List<IETRS_PLI_Extract_Unit__c>();
        for(Account acct : scope) {
            IETRS_PLI_Extract_Unit__c extract = new IETRS_PLI_Extract_Unit__c(
                IETRS_LDR_Unit_Reps_Number__c = acct.IETRS_Account_ID__c.leftPad(6, '0'),
                IETRS_LDR_Operator_Number__c = acct.Parent.IETRS_P5_Number__c.leftPad(6, '0')
            );

            lstExtract.add(extract);
        }
        
        insert lstExtract;
    }

    global void finish(Database.BatchableContext bc) {
        IETRS_GoAnywhere websvc = new IETRS_GoAnywhere();
        websvc.runGoAnywhereJob(null, 'PLI Extracts - Unit', 'PIPES PLI Extract');
    }
}