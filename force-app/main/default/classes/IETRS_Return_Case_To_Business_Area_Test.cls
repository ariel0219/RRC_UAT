@isTest
public with sharing class IETRS_Return_Case_To_Business_Area_Test {
    
    public static testMethod void IETRS_Return_Case_To_Business_Area_Test() {
        Account acct = new Account(Name='Test');
        insert acct;

        String recTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('AFS').getRecordTypeId();
        //Assign to Hearings test Case
        Case c = new Case(IETRS_Primary_Account_Assignment__c = acct.Id, 
                        IETRS_Docket_Group__c = 'OS - Oversight and Safety',
                        RecordTypeId = recTypeId);
        insert c;

        List<String> lstCaseIds = new List<String>();
        lstCaseIds.add(c.Id);

        c.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Hearings').getRecordTypeId();
        update c;

        //Refer to Legal test Case
        Case cV2 = new Case(IETRS_Primary_Account_Assignment__c = acct.Id, 
                        IETRS_Docket_Group__c = 'OS - Oversight and Safety',
                        RecordTypeId = recTypeId);
        insert cV2;

        List<String> lstCaseIdsV2 = new List<String>();
        lstCaseIdsV2.add(cV2.Id);

        cV2.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Legal Enforcement').getRecordTypeId();
        cV2.IETRS_Refer_to_Legal_Enforcement__c = true;
        update cV2;


        //Assign to Hearings test Case with SMRD
        Case cV3 = new Case(IETRS_Primary_Account_Assignment__c = acct.Id, 
                        IETRS_Docket_Group__c = 'OS - Oversight and Safety',
                        IETRS_Original_Record_Type__c = 'SMRD',
                        RecordTypeId = recTypeId);
        insert cV3;

        List<String> lstCaseIdsV3 = new List<String>();
        lstCaseIdsV3.add(cV3.Id);
        cV3.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Hearings').getRecordTypeId();
        cV3.IETRS_Refer_to_Hearings__c = true;
        update cV3;

        //Assign to Hearings test Case with SSE
        Case cV4 = new Case(IETRS_Primary_Account_Assignment__c = acct.Id, 
                        IETRS_Docket_Group__c = 'OS - Oversight and Safety',
                        IETRS_Original_Record_Type__c = 'SSE',
                        RecordTypeId = recTypeId);
        insert cV4;

        List<String> lstCaseIdsV4 = new List<String>();
        lstCaseIdsV4.add(cV4.Id);
        cV4.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Hearings').getRecordTypeId();
        cV4.IETRS_Refer_to_Hearings__c = true;
        update cV4;
        

        Test.startTest();
        
        IETRS_Return_Case_To_Business_Area.returnToBusinessArea(lstCaseIds);
        c = [SELECT Id, RecordTypeId FROM Case WHERE Id = :c.Id];
        System.assertEquals(recTypeId, c.RecordTypeId);

        IETRS_Return_Case_To_Business_Area.returnToBusinessArea(lstCaseIdsV2);
        cV2 = [SELECT Id, RecordTypeId FROM Case WHERE Id = :cV2.Id];
        System.assertEquals(recTypeId, cV2.RecordTypeId);

        IETRS_Return_Case_To_Business_Area.returnToBusinessArea(lstCaseIdsV3);
        cV3 = [SELECT Id, RecordTypeId,IETRS_Original_Record_Type__c,IETRS_SMRD_Compliance_Status__c FROM Case WHERE Id = :cV3.Id];
        //System.assertEquals(recTypeId, cV3.RecordTypeId);
        System.assertEquals('Final Action', cV3.IETRS_SMRD_Compliance_Status__c);

        IETRS_Return_Case_To_Business_Area.returnToBusinessArea(lstCaseIdsV4);
        cV4 = [SELECT Id, RecordTypeId,IETRS_Original_Record_Type__c,IETRS_SSE_Case_Status__c FROM Case WHERE Id = :cV4.Id];
        //System.assertEquals(recTypeId, cV4.RecordTypeId);
        System.assertEquals('Application Complete', cV4.IETRS_SSE_Case_Status__c);

        Test.stopTest();

    }
}