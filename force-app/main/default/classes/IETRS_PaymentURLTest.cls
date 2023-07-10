/**
 * @File Name          : IETRS_PaymentURLTest.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 4/13/2020, 1:49:39 PM
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      04/13/2020      Kevin Lu                Initial Version
**/
@IsTest
private class IETRS_PaymentURLTest {
    @TestSetup
    static void makeData(){
        RecordType organizationRecordType = [Select Id From RecordType Where SObjectType = 'Account' And Name = 'Organization' Limit 1];

        Account operator = new Account(
            RecordTypeId = organizationRecordType.Id,
            Name = 'ELECTRAGAS, INC.',
            IETRS_P5_Number__c = '247628'
        );
        insert operator;

        Case c = new Case();
        c.IETRS_Business_Area__c = 'Oil and Gas';
        c.IETRS_Primary_Account_Assignment__c = operator.Id;
        insert c;
        
        IETRS_Transaction__c t = new IETRS_Transaction__c(
            IETRS_Transaction_Amount__c = 51.38
            ,IETRS_Case__c = c.Id
        );
        insert t;
    }

    @IsTest
    static void testPaymentURL(){
        List<Id> lstID = new List<Id>();
        IETRS_Transaction__c t = [Select Id From IETRS_Transaction__c Limit 1];
        lstID.add(t.Id);
        String strURL = IETRS_PaymentURLController.getPaymentURLInvoc(lstID).get(0);
        System.debug(strURL);
        System.assertNotEquals('Error', strURL, 'Unexpected Error');
    }
}