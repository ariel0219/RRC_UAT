/**
 * Invocable action class used to get users who are subscribed to receive
 *  notifcations for case documents created in the previous day.
 * @author CGI
 */
public with sharing class IETRS_GetSubscribedUsersAction {
    /**
     * Invocable method returns a list of unique user ids
     *  who are subscribed to receive notifications to any of
     *  the case documents created in the previous day.
     * @return  `List<List<String>>`
     */
    @InvocableMethod(
        label='Get Subscribed Users'
        description='Returns a unique list of ids of the user who are subscribed to be notified about case documents created in the previous day.'
    )
    public static List<List<String>> execute() {
        List<List<String>> result = new List<List<String>>();
        Map<Id, Set<String>> userIdsByCaseId = new Map<Id, Set<String>>();
        Set<Id> caseIds = new Set<Id>();
        Set<String> userIds = new Set<String>();
        Date dt = System.today().addDays(-1);
        DateTime startDt = DateTime.newInstance(
            dt.year(),
            dt.month(),
            dt.day(),
            0,
            0,
            0
        );

        // look for new case docs
        for (IETRS_Public_File_Correspondence__c doc : [
            SELECT Id, IETRS_Case__c
            FROM IETRS_Public_File_Correspondence__c
            WHERE CreatedDate >= :startDt AND CreatedDate < :startDt.addDays(1)
            WITH SECURITY_ENFORCED
        ]) {
            caseIds.add(doc.IETRS_Case__c);
        }

        // exit early if none are found
        if (caseIds.isEmpty()) {
            result.add(new List<String>());
            return result;
        }

        // find all subscribed users
        for (IETRS_Case_Subscription__c cs : [
            SELECT Id, OwnerId, IETRS_Case__c
            FROM IETRS_Case_Subscription__c
            WHERE IETRS_Case__c IN :caseIds
            WITH SECURITY_ENFORCED
        ]) {
            userIds.add(cs.OwnerId);
        }

        result.add(new List<String>(userIds));
        return result;
    }
}