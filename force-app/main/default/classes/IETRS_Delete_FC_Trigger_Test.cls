/**
 * @File Name          : IETRS_Delete_FC_Trigger_Test.cls
 * @Description        : Tests IETRS_Delete_FC_Trigger.trigger
 *                     : Deletes Related Files and Correspondence and Case Document records associated with a deleted File
 *                     : and Correspondence Record.
 * @Author             : Forrest Chang
 * @Group              : 
 * @Last Modified By   : Forrest Chang
 * @Last Modified On   : 01/17/2020
 * @Modification Log   : 
 * Ver          Date            Author          Modification
 * 1.0          01/17/2020      Forrest Chang   Initial Version
**/
@isTest
public with sharing class IETRS_Delete_FC_Trigger_Test {
    @isTest
    public static void IETRS_Delete_FC_Trigger_Test() {
        Id idCaseHearingRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Hearings').getRecordTypeId();
        Id idAcctOrgRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        
        Account acctNew = new Account(Name='Test Account', RecordTypeId=idAcctOrgRecType);
        insert acctNew;

        Case caseNew = new Case(RecordTypeId=idCaseHearingRecType,
                                IETRS_Primary_Account_Assignment__c=acctNew.Id,
                                Status='Active',
                                Type='AFR');
        insert caseNew;

        IETRS_Files_Correspondence__c fcNew = new IETRS_Files_Correspondence__c(
                                                IETRS_Business_Area_Division__c='Hearings',
                                                IETRS_Case__c=caseNew.Id,
                                                IETRS_File_With_Docket_Services__c=false,
                                                IETRS_Confidential__c=false,
                                                IETRS_Document_Type__c='Memo',
                                                IETRS_Draft__c=false,
                                                IETRS_Privileged__c=false
                                                );
        insert fcNew;

        IETRS_File_Correspondence_Assignment__c relfcNew = new IETRS_File_Correspondence_Assignment__c(
                                                            IETRS_File_and_Correspondence__c=fcNew.Id,
                                                            IETRS_Case__c=caseNew.Id
                                                            );
        insert relfcNew;

        fcNew.IETRS_Public__c = true;
        update fcNew;

        list<IETRS_Public_File_Correspondence__c> listCaseDoc = [SELECT Id 
                                                                FROM IETRS_Public_File_Correspondence__c
                                                                WHERE IETRS_Related_File_Correspondence__c=:relfcNew.Id];

        test.startTest();
        delete fcNew;
        test.stopTest();

        List<IETRS_File_Correspondence_Assignment__c> lstDeletedRFC = new List<IETRS_File_Correspondence_Assignment__c>();
        lstDeletedRFC = [SELECT Id
                        FROM IETRS_File_Correspondence_Assignment__c
                        WHERE Id = :relfcNew.Id
        ];

        List<IETRS_Public_File_Correspondence__c> lstDeletedCDoc = new List<IETRS_Public_File_Correspondence__c>();
        lstDeletedCDoc = [SELECT Id
                         FROM IETRS_Public_File_Correspondence__c
                         WHERE Id = :listCaseDoc[0].Id
        ];

        System.assertEquals(0, lstDeletedRFC.size());
        System.assertEquals(0, lstDeletedCDoc.size());
    }
}