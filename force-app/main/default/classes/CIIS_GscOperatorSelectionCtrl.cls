/**
 * This class is used to get the list of operators for the current user.
 * @author CGI
 */
public with sharing class CIIS_GscOperatorSelectionCtrl {
    /**
     * This method is used to get the list of operators for the current user.
     * @return List<Account> operatorList
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getOperatorList() {
        List<Account> operatorList = new List<Account>();
        String userId = UserInfo.getUserId();
        User userObj = [
            SELECT Id, ContactId
            FROM User
            WHERE Id = :userId
            WITH SECURITY_ENFORCED
        ];

        String contactId = userObj.ContactId;
        operatorList = (List<Account>) [
            SELECT Id, Name
            FROM Account
            WHERE
                Id IN (
                    SELECT AccountId
                    FROM AccountContactRelation
                    WHERE IsActive = TRUE AND ContactId = :contactId
                )
                AND RecordType.DeveloperName = 'Organization'
            WITH SECURITY_ENFORCED
        ];
        return operatorList;
    }
}