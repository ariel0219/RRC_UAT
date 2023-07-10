/**
 * This class is used to search for organizations from a screen flow.
 */
public inherited sharing class CIIS_OrgSearchAction {
    @TestVisible
    static final String ERROR_NO_BULK = 'This action was invoked in a bulk context. It is designed to be used in screen flows only.';

    @InvocableMethod(
        label='Search Organizations'
        description='Returns the list of organization accounts matching the search query.'
        category='CIIS'
    )
    /**
     * This method is used to search for organizations from a screen flow.
     * @param searchQueries The list of search queries to execute.
     */
    public static List<List<Account>> execute(List<String> searchQueries) {
        // while we need to accept a list of search queries, we don't want this action to be invoked in a bulk context
        // for this reason we're only going to process the first search query and we'll throw an error if there are more
        // to avoid running into governor limits if this action is executed in the wrong way
        List<List<Account>> results = new List<List<Account>>();
        // get the record type id for the organization record type using the schema
        String orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Organization')
            .getRecordTypeId();
        if (searchQueries.size() > 1) {
            throw new CIIS_OrgSearchActionException(ERROR_NO_BULK);
        }
        String searchQuery = searchQueries[0] + '*';

        // search for organizations matching the search query
        List<List<SObject>> searchResults = [
            FIND :searchQuery
            IN ALL FIELDS
            RETURNING
                Account(
                    Id,
                    Name,
                    IETRS_P5_Number__c
                    WHERE
                        IETRS_Status__c = 'Active'
                        AND RecordTypeId = :orgRecordTypeId
                    LIMIT 20)
        ];

        // set up and return the result
        if (searchResults.size() > 0) {
            List<Account> listAccount = (List<Account>) searchResults[0];
            if (listAccount.size() > 0) {
                results.add(listAccount);
            }
        }

        return results;
    }

    /**
     * Exception class for this invocable action.
     */
    public class CIIS_OrgSearchActionException extends Exception {
    }
}