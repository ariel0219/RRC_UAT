public with sharing class IETRS_GetSingleAccount {
    
    @AuraEnabled
    public static string getAccountID(){
        Account acct = [SELECT ID FROM ACCOUNT LIMIT 1];
        return String.valueof(acct.Id);
    }
    
    
}