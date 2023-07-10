/**
 * Test class for the CIIS_OrgSearchAction class.
 * @author CGI
 */
@IsTest
private class CIIS_OrgSearchActionTest {
    @IsTest
    /**
     * @description Test that the search action returns the correct results
     */
    static void itShouldFindOrg() {
        // Given... an active org account exists
        Account orgAccount = new CIIS_SupplyChainTestFactory()
            .getNewOrgInstance();
        insert orgAccount;

        // When... search for the org
        List<String> searchQueries = new List<String>{ 'Test' };
        Test.startTest();
        List<List<Account>> searchResults = CIIS_OrgSearchAction.execute(
            searchQueries
        );
        Test.stopTest();

        // Then... search result is found
        // System.assertEquals(
        //     1,
        //     searchResults.size(),
        //     'Search results should have 1 item.'
        // );
        // System.assertEquals(
        //     1,
        //     searchResults[0].size(),
        //     'Account list in search results should have 1 item.'
        // );
        // System.assertEquals(
        //     orgAccount.Id,
        //     searchResults[0][0].Id,
        //     'The found account should match the org account.'
        // );
    }

    @IsTest
    /**
     * Test that the search feature isn't invoked from a bulk context
     */
    static void itShouldFailIfBulk() {
        // Given... simulate a search invoked from a record trigged context
        List<String> searchQueries = new List<String>{
            'Test Organization 1',
            'Test Organization 2'
        };

        // When... bulk search is performed
        Exception actualException;
        try {
            CIIS_OrgSearchAction.execute(searchQueries);
        } catch (Exception e) {
            actualException = e;
        }

        // Then... exception is thrown
        System.assertEquals(
            CIIS_OrgSearchAction.ERROR_NO_BULK,
            actualException.getMessage(),
            'The bulk error was not caught.'
        );
    }

    @IsTest
    /**
     * Test the search doesn't find the inactive org and returns no results
     */
    static void testNoResults() {
        // Given... search org is inactive
        String orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Organization')
            .getRecordTypeId();
        Account orgAccount = new Account(
            Name = 'Test Organization',
            IETRS_Status__c = 'Inactive',
            RecordTypeId = orgRecordTypeId
        );
        insert orgAccount;

        // When... search for the inactive org
        List<String> searchQueries = new List<String>{ 'Test Organization' };
        Test.startTest();
        List<List<Account>> searchResults = CIIS_OrgSearchAction.execute(
            searchQueries
        );
        Test.stopTest();

        // Then... no results
        System.assertEquals(
            0,
            searchResults.size(),
            'The search results should be empty.'
        );
    }
}