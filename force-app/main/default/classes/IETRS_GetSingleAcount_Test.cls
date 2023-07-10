@isTest
public inherited sharing class IETRS_GetSingleAcount_Test {
    @TestSetup
    static void makeData(){
        Account acct = new Account();
        acct.Name = 'Test Acct';
        insert acct;
    }
    

    @IsTest
    static void methodName(){
        
        Test.startTest();
        String strExpectedId = [SELECT Id FROM Account LIMIT 1].Id;
        String strResultId =  IETRS_GetSingleAccount.getAccountID();
        Test.stopTest();

        system.assert(strResultId == strExpectedId);
        
    }
}