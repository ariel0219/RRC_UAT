/**
 * @description       : Helper class to set GFC flag on Account after Holds are changed
 * @author            : Kevin Lu
 * @group             : 
 * @last modified on  : 2020-07-20
 * @last modified by  : Kevin Lu
 * Modifications Log 
 * Ver   Date         Author     Modification
 * 1.0   2020-07-20   Kevin Lu   Initial Version
**/
public class IETRS_HoldTriggerHelper {
    private static final Id GFC_RECORD_TYPE_ID = [Select Id From RecordType Where SObjectType = 'IETRS_Hold__c' And Name = 'Good Faith Claim Hold' Limit 1].Id;

    public static void handleAfter(List<IETRS_Hold__c> lstChanges) {
        Set<Id> setAffectedAccountIDs = new Set<Id>();
        List<Account> lstAffectedAccounts = new List<Account>();

        for(IETRS_Hold__c hold : lstChanges) {
            if(hold.RecordTypeId == GFC_RECORD_TYPE_ID) {
                setAffectedAccountIDs.add(hold.IETRS_Regulated_Entity__c);
            }
        }

        for(Account affectedAccount : [
            Select Id, IETRS_Good_Faith_Claim_Hold__c,
                (Select Id 
                From Holds__r 
                Where RecordTypeId = :GFC_RECORD_TYPE_ID 
                And IETRS_Active__c = True)
            From Account
            Where Id In :setAffectedAccountIDs
        ]) {
            if(affectedAccount.Holds__r != null && affectedAccount.Holds__r.size() > 0) { //has active GFC holds
                affectedAccount.IETRS_Good_Faith_Claim_Hold__c = true;
            } else {
                affectedAccount.IETRS_Good_Faith_Claim_Hold__c = false;
            }
            lstAffectedAccounts.add(affectedAccount);
        }

        update lstAffectedAccounts;
    }
}