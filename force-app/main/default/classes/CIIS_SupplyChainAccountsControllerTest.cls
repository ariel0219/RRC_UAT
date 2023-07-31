@IsTest
private class CIIS_SupplyChainAccountsControllerTest {
    @TestSetup
    static void makeData() {
        CIIS_SUpplyChainTestFactory testFactory = new CIIS_SUpplyChainTestFactory();
        Account org = testFactory.getNewOrgInstance();
        insert org;
        List<Account> accs = new List<Account>();
        accs.addAll(
            testFactory.getNewSupplyChainAccountInstances(
                'Power Plant',
                org.Id,
                Schema.SObjectType.Account.getRecordTypeInfosByName().get('Regulated Entity - PP').getRecordTypeId(),
                2
            )
        );
        accs.addAll(
            testFactory.getNewSupplyChainAccountInstances(
                'Gas Processing Facility',
                org.Id,
                Schema.SObjectType.Account.getRecordTypeInfosByName().get('Regulated Entity - PS').getRecordTypeId(),
                2
            )
        );
        insert accs;
    }

    @isTest
    static void itShouldGetRecords() {
        List<Account> accounts = CIIS_SupplyChainAccountsController.getRecords(
            'Power Plant',
            null,
            null
        );
        System.assertNotEquals(
            null,
            accounts,
            'The Accounts list should not be null'
        );
    }

    @isTest
    static void itShouldGetRecord() {
        Id ppId = [
            SELECT Id
            FROM Account
            WHERE Type = 'Gas Processing Facility'
            LIMIT 1
        ]
        .Id;
        Test.startTest();
        Account acc = CIIS_SupplyChainAccountsController.getRecord(
            'Gas Processing Facility',
            ppId
        );
        IETRS_AccountTriggerHelper.processAccounts(new Set<Id>{ acc.Id });
        Test.stopTest();
        System.assertNotEquals(null, acc, 'The Account should not be null');
        delete acc;
        undelete acc;
    }

    @isTest
    static void itShouldGetEntityWithDefaultValues() {
        Id orgId = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = 'Organization'
            LIMIT 1
        ]
        .Id;
        Account account = CIIS_SupplyChainAccountsController.getEntityWithDefaultValues(
            'Gas Processing Facility',
            orgId
        );
        System.assertNotEquals(null, account, 'The account should not be null');
    }

    @isTest
    static void itShouldGetColumns() {
        List<CIIS_SupplyChainType.Column> columns = CIIS_SupplyChainAccountsController.getColumns(
            'Gas Processing Facility'
        );
        System.assertNotEquals(
            null,
            columns,
            'The list of columns should not be null'
        );
    }

    @isTest
    static void itShouldGetInputFields() {
        List<CIIS_SupplyChainType.Column> inputFields = CIIS_SupplyChainAccountsController.getInputFields(
            'Gas Processing Facility'
        );
        System.assertNotEquals(
            null,
            inputFields,
            'The list of input fields should not be null'
        );
    }

    @isTest
    static void itShouldGetAccountGeolocations() {
        Id ppId = [
            SELECT Id
            FROM Account
            WHERE Type = 'Power Plant - Gas Reliant'
            LIMIT 1
        ]
        .Id;
        List<Id> accountIds = new List<Id>{ ppId };
        Map<Id, List<CIIS_Account_Geolocation__c>> accountGeolocations = CIIS_SupplyChainAccountsController.getAccountGeolocations(
            'Power Plant',
            accountIds
        );
        System.assertNotEquals(
            null,
            accountGeolocations,
            'The account geolocations map should not be null'
        );
    }

    @IsTest
    static void itShouldTestAllSupplyChainTypes() {
        Boolean canInitializeAllTypes = true;
        String failedSupplyType;
        CIIS_SupplyChainTestFactory testFactory = new CIIS_SupplyChainTestFactory();
        for (String typeLabel : testFactory.settingByLabel.keySet()) {
            try {
                CIIS_SupplyChainType supplyChainType = new CIIS_SupplyChainType(
                    typeLabel
                );
                supplyChainType.getColumns();
                supplyChainType.getInputFields();
            } catch (Exception e) {
                canInitializeAllTypes = false;
                failedSupplyType = typeLabel;
            }
        }
        System.assert(
            canInitializeAllTypes,
            'The supply chain type ' + failedSupplyType + ' should be valid'
        );
    }

    @IsTest
    static void itShouldFailToGetBadSupplyType() {
        Boolean itFailed = false;

        Test.startTest();
        try {
            CIIS_SupplyChainType supplyChainType = new CIIS_SupplyChainType(
                'bad supply type'
            );
            supplyChainType.getColumns();
        } catch (CIIS_SupplyChainType.CIIS_SupplyChainTypeException e) {
            itFailed = true;
        }
        Test.stopTest();

        System.assert(
            itFailed,
            'It should have failed to initialize a bad supply chain type'
        );
    }
    
    @IsTest
    static void getCountyTest1(){
        IETRS_County__c countyc = new IETRS_County__c(IETRS_County_Code__c = '093', IETRS_Oil_Gas_County_Code__c = '185');
        Insert countyc;
        CIIS_SupplyChainAccountsController.getCounty('185');
    }
}