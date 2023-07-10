/**
 * @File Name          : IETRS_EDI_NotifDetail_Batch_Test.cls
 * @Description        : Batch class to be called during the PLI EDI process to insert Notification Detail records.
 * @Author             : Forrest Chang
 * @Group              :
 * @Last Modified By   : Forrest Chang
 * @Last Modified On   : 7/16/2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0      7/16/2021               Forrest Chang     			Initial Version
 **/
@isTest
public with sharing class IETRS_EDI_NotifDetail_Batch_Test {
    @isTest
    public static void positiveBatchInsertTest() {
        //get required record types
        Id accRegEntPSRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Regulated_Entity_PS')
            .getRecordTypeId();
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Organization')
            .getRecordTypeId();
        Id accUnitRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Unit')
            .getRecordTypeId();

        //randomizer for unique Id
        String uniqueId = String.valueOf(Math.random()).right(6);

        //create test organization
        Account orgAcct = new Account(
            Name = 'Organization ' + uniqueId,
            RecordTypeId = accOrgRecordTypeId,
            IETRS_Company_ID__c = uniqueId
        );
        insert orgAcct;
        
        //create test unit
        Account unitAcct = new Account(
            Name = 'Unit ' + uniqueId,
            RecordTypeId = accUnitRecordTypeId,
            ParentId = orgAcct.Id,
            Type='Distribution',
            IETRS_Unit_ID__c = 'Unit' + uniqueId
        );
        insert unitAcct;

        //create pair of regulated entities
        Account reAcctGas = new Account(
            Name = 'Regulated Entity PS ' + uniqueId + ' Gas',
            RecordTypeId = accRegEntPSRecordTypeId,
            IETRS_OrganizationofRegEntity__c = orgAcct.Id,
            IETRS_Unit_Parent__c = unitAcct.Id,
            ParentId = unitAcct.Id
        );
        insert reAcctGas;
        
        List<IETRS_Insp_Notification_Detail__c> lstInsertNotifDetails = new List<IETRS_Insp_Notification_Detail__c>();
        IETRS_Insp_Notification__c notificationRec = new IETRS_Insp_Notification__c(IETRS_PS95_Organization__c=orgAcct.Id
                                                                                    , RecordTypeId=Schema.SObjectType.IETRS_Insp_Notification__c.getRecordTypeInfosByName().get('PS-95').getRecordTypeId()
                                                                                    , IETRS_Submitted__c='No'
                                                                                    , IETRS_Report_Period__c='2021 Jan-Jun');
        insert notificationRec;
        
        for(Integer i=0; i<100;i++){
            IETRS_Insp_Notification_Detail__c nfd = new IETRS_Insp_Notification_Detail__c(IETRS_Notification__c = notificationRec.Id
                                                                                        , IETRS_Pipelines_System_ID__c = reAcctGas.Id
                                                                                        , IETRS_Operator_Leak_ID__c='1233'+i
                                                                                        , IETRS_Leak_Cause__c='Static Electricity'
                                                                                        , IETRS_Repair_Date__c=System.today()
                                                                                        , IETRS_Leak_Location__c='Above Ground Piping'
                                                                                        );
            lstInsertNotifDetails.add(nfd);                                                                                                                                                                                
        }
        IETRS_EDI_NotifDetail_Batch batchInsert = new IETRS_EDI_NotifDetail_Batch(lstInsertNotifDetails, true);
        ID jobID = Database.executeBatch(batchInsert, 200);
    }
}