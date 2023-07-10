@isTest
public with sharing class DTBL_RelatedList_Test {
    @TestSetup
    static void makeData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact cont = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Accountid = testAccount.id
        );
        insert cont;
    }
    @isTest
    static void buildFieldJSON_Test() {
        Test.startTest();
        User testUser = [SELECT id FROM user WHERE id = :UserInfo.getUserId()];
        DTBL_RelatedList.ListResults results;
        System.runAs(testUser) {
            results = DTBL_RelatedList.buildFieldJSON(
                'SELECT ID,FirstName,Accountid From Contact',
                'Contact',
                '',
                '{ "AccountId":{"label":"Account Record Id"}} }',
                false
            );
        }
        System.assertEquals(results != null, true);
        Test.stopTest();
    }
    @isTest
    static void itShouldExecuteElevatedContextQuery() {
        Test.startTest();
        User testUser = [SELECT id FROM user WHERE id = :UserInfo.getUserId()];
        DTBL_RelatedList.ListResults results;
        System.runAs(testUser) {
            results = DTBL_RelatedList.buildFieldJSON(
                'SELECT ID,FirstName,Accountid From Contact',
                'Contact',
                '',
                '{ "AccountId":{"label":"Account Record Id"}} }',
                true
            );
        }
        System.assertEquals(results != null, true);
        Test.stopTest();
    }
    @IsTest
    static void getRecords_Test() {
        Test.startTest();
        User testUser = [SELECT id FROM user WHERE id = :UserInfo.getUserId()];
        List<Sobject> results;
        System.runAs(testUser) {
            results = DTBL_RelatedList.getRecords(
                'Select id from contact limit 10',
                false
            );
        }
        System.assertEquals(results.size() > 0, true);
        Test.stopTest();
    }

    @IsTest
    static void countRecords_Test() {
        User testUser = [SELECT id FROM user WHERE id = :UserInfo.getUserId()];
        Test.startTest();
        System.runAs(testUser) {
            DTBL_RelatedList.countRecords('Contact', '', false);
            DTBL_RelatedList.countRecords(null, '', false);
        }
        Test.stopTest();
    }

    @IsTest
    static void onSearch_Test() {
        Test.startTest();
        User testUser = [SELECT id FROM user WHERE id = :UserInfo.getUserId()];
        List<SObject> results;
        System.runAs(testUser) {
            Test.setFixedSearchResults(
                new List<Id>{ [SELECT Id FROM Contact LIMIT 1][0].Id }
            );
            results = DTBL_RelatedList.onSearch(
                'Fi',
                'Contact',
                'FirstName,LastName',
                'FirstName = \'First\''
            );
        }
        System.assertEquals(results.size() > 0, true);
        Test.stopTest();
    }

    @IsTest
    static void initPicklistColumn_Test() {
        Map<String, DTBL_RelatedList.ColumnJson> colsJson = new Map<String, DTBL_RelatedList.ColumnJson>{
            'StageName' => new DTBL_RelatedList.ColumnJson()
        };

        DTBL_RelatedList.initPicklistColumn(
            colsJson,
            'Opportunity',
            'StageName'
        );

        DTBL_RelatedList.TypeAttributeColumnJsonWithPicklist typesAttributesPicklist = (DTBL_RelatedList.TypeAttributeColumnJsonWithPicklist) colsJson.get(
                'StageName'
            )
            .typeAttributes;
        System.assert(typesAttributesPicklist.options.size() >= 0);
    }

    @IsTest
    static void itShouldGetCustomObjectIcon() {
        User testUser = [SELECT id FROM user WHERE id = :UserInfo.getUserId()];
        Test.startTest();
        System.runAs(testUser) {
            String icon = DTBL_IconUtils.getIconName('IETRS_Inspection__c');
            System.assertEquals(icon != null, true);
        }
        Test.stopTest();
    }
}