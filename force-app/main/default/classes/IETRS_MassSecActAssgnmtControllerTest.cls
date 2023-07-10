@isTest
public with sharing class IETRS_MassSecActAssgnmtControllerTest {
    @isTest
    static void massSecondaryAcctControllerTest() {
        Account acct = new Account(
            Name = 'Test',
            IETRS_Lease_Number__c = '12345'
        );
        insert acct;

        Case c = new Case(
            IETRS_Primary_Account_Assignment__c = acct.Id,
            Status = 'Active',
            Type = 'AFR'
        );
        insert c;

        system.assertEquals(
            1,
            IETRS_MassSecActAssgnmtController.getAccountList('12345', c.Id)
                .size()
        );
        //system.assertEquals(0, IETRS_MassSecActAssgnmtController.getAccountList('65432', c.Id).size());
    }

    @isTest
    static void massSecondaryAcctControllerCreationTest() {
        Account acct = new Account(
            Name = 'Test',
            IETRS_Lease_Number__c = '12345'
        );
        insert acct;
        Case c = new Case(
            IETRS_Primary_Account_Assignment__c = acct.Id,
            Status = 'Active',
            Type = 'AFR'
        );
        insert c;
        List<String> lstAcctIds = new List<String>();
        lstAcctIds.add(acct.Id);

        IETRS_MassSecActAssgnmtController.createSecondaryAccountList(
            lstAcctIds,
            c.Id
        );
        System.assertEquals(
            1,
            [SELECT Id FROM IETRS_Case_Secondary_Account_Assignment__c].size()
        );
    }

    @isTest
    static void massSecondaryAcctControllerCaseUpdateTest() {
        List<Account> lstAccts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            Account acct = new Account(
                Name = 'Lease ' + i,
                IETRS_Lease_Number__c = '12345',
                IETRS_Lease_Name__c = 'Lease Name ' + i,
                Type = 'Lease'
            );
            lstAccts.add(acct);
        }
        for (Integer i = 0; i < 10; i++) {
            Account acct = new Account(
                Name = 'Well ' + i,
                IETRS_Well_Number__c = 'WN' + i,
                Type = 'Well'
            );
            lstAccts.add(acct);
        }
        lstAccts.add(
            new Account(Name = 'Drilling Permit', Type = 'Drilling Permit')
        );
        
        lstAccts.add(
            new Account(Name = 'Permitted 001',
                        IETRS_Field_Name__c='Permitted Account(007)',
                        IETRS_Field_Number__c='4353454', Type = 'Permitted Field')
        );        
        insert lstAccts;

        Account acctPrime = new Account(Name = 'Prime Acct');
        insert acctPrime;

        Case c = new Case(
            IETRS_Primary_Account_Assignment__c = acctPrime.Id,
            Status = 'Active',
            Type = 'AFR'
        );
        insert c;

        List<IETRS_Case_Secondary_Account_Assignment__c> lstSaas = new List<IETRS_Case_Secondary_Account_Assignment__c>();
        for (Account acct : lstAccts) {
            IETRS_Case_Secondary_Account_Assignment__c saa = new IETRS_Case_Secondary_Account_Assignment__c(
                IETRS_Account__c = acct.Id,
                IETRS_Case__c = c.Id,
                IETRS_Mass_Add__c = true
            );
            lstSaas.add(saa);
        }
        insert lstSaas;

        List<String> lstSaaIds = new List<String>();
        for (IETRS_Case_Secondary_Account_Assignment__c saa : lstSaas) {
            lstSaaIds.add(saa.Id);
        }

        IETRS_MassSecActAssgnmtController.updateCaseMassSAADetails(
            lstSaaIds,
            c.Id
        );

        Case c2 = [
            SELECT Id, IETRS_Secondary_Account_Details__c
            FROM Case
            WHERE Id = :c.Id
        ];
        system.debug(c2.IETRS_Secondary_Account_Details__c);
    }
    
    @isTest
    static void getAccountListNewTest() {
        Account acct = new Account(
            Name = 'Test',
            IETRS_Lease_Number__c = '12345',
            IETRS_Drilling_Permit_Number__c='Permit 1234'
        );
        insert acct;

        Case c = new Case(
            IETRS_Primary_Account_Assignment__c = acct.Id,
            Status = 'Active',
            Type = 'AFR'
        );
        insert c;
		List<Account> listAccount = IETRS_MassSecActAssgnmtController.getAccountListNew('Lease','12345','','', c.Id);
        system.assertEquals(1,listAccount.size());
		listAccount = IETRS_MassSecActAssgnmtController.getAccountListNew('Permit','','','Permit 1234', c.Id);
        system.assertEquals(1,listAccount.size());
		listAccount = IETRS_MassSecActAssgnmtController.getAccountListNew('Lease','235235','','', c.Id);
        system.assertEquals(0,listAccount.size());
    }    
    
    
}