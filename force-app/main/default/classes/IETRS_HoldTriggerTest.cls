/**
 * @description       : Test class for Hold Trigger
 * @author            : Kevin Lu
 * @group             : 
 * @last modified on  : 2020-07-20
 * @last modified by  : Kevin Lu
 * Modifications Log 
 * Ver   Date         Author     Modification
 * 1.0   2020-07-20   Kevin Lu   Initial Version
**/
@IsTest
public class IETRS_HoldTriggerTest {
    private static final Id OG_RECORD_TYPE_ID = [Select Id From RecordType Where SObjectType = 'Account' And Name = 'Regulated Entity - OG' Limit 1].Id;
    private static final Id GFC_RECORD_TYPE_ID = [Select Id From RecordType Where SObjectType = 'IETRS_Hold__c' And Name = 'Good Faith Claim Hold' Limit 1].Id;
    @TestSetup
    static void makeAccounts(){
        Account acct = new Account(
            RecordTypeId = OG_RECORD_TYPE_ID,
            Name = 'APEXTEST Test Account'
        );
        insert acct;

        Account acct2 = new Account(
            RecordTypeId = OG_RECORD_TYPE_ID,
            Name = 'APEXTEST Test Account 2'
        );
        insert acct2;

        IETRS_Hold__c activeHold = new IETRS_Hold__c();
        activeHold.RecordTypeId = GFC_RECORD_TYPE_ID;
        insert activeHold;

        IETRS_Hold__c inactiveHold = new IETRS_Hold__c();
        inactiveHold.RecordTypeId = GFC_RECORD_TYPE_ID;
        inactiveHold.IETRS_Active__c = false;
        insert inactiveHold;
    }

    @IsTest
    static void testDelete() {
        Test.startTest();
        List<IETRS_Hold__c> lstHolds = [
            Select Id
            From IETRS_Hold__c
            Where IETRS_Active__c = True
        ];
        delete lstHolds;
        Test.stopTest();

        Account a = [
            Select Id, IETRS_Good_Faith_Claim_Hold__c
            From Account
            Where Name = 'APEXTEST Test Account'
            Limit 1
        ];
        System.assertEquals(false, a.IETRS_Good_Faith_Claim_Hold__c, 'Delete test failed');
    }

    @IsTest
    static void testUpdate() {
        Test.startTest();
        List<IETRS_Hold__c> lstHolds = [
            Select Id, IETRS_Active__c
            From IETRS_Hold__c
        ];
        for(IETRS_Hold__c hold : lstHolds) {
            hold.IETRS_Active__c = false;
        }
        update lstHolds;
        Test.stopTest();

        Account a = [
            Select Id, IETRS_Good_Faith_Claim_Hold__c
            From Account
            Where Name = 'APEXTEST Test Account'
            Limit 1
        ];
        System.assertEquals(false, a.IETRS_Good_Faith_Claim_Hold__c, 'Update test failed');
    }

    @IsTest
    static void testInsert() {
        Account b = [
            Select Id
            From Account
            Where Name = 'APEXTEST Test Account 2'
            Limit 1
        ];

        Test.startTest();
        IETRS_Hold__c hold = new IETRS_Hold__c();
        hold.IETRS_Regulated_Entity__c = b.Id;
        hold.RecordTypeId = GFC_RECORD_TYPE_ID;
        insert hold;
        Test.stopTest();

        b = [
            Select Id, IETRS_Good_Faith_Claim_Hold__c
            From Account
            Where Name = 'APEXTEST Test Account 2'
            Limit 1
        ];
        System.assertEquals(true, b.IETRS_Good_Faith_Claim_Hold__c, 'Insert test failed');
    }
}