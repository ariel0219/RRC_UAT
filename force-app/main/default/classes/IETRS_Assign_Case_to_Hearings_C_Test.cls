@isTest
public class IETRS_Assign_Case_to_Hearings_C_Test {


    public static TestMethod void getRelatedFCsTest() {
        Account acct = new Account(Name='Test');
        insert acct;
        String recTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('AFS').getRecordTypeId();

        Case c = new Case(IETRS_Primary_Account_Assignment__c = acct.Id, IETRS_Business_Area__c = 'Alternative Fuels', Type = 'AFS', RecordTypeId = recTypeId);
        insert c;
        
        IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c(IETRS_Case__c = c.id);
        insert fc;

        IETRS_File_Correspondence_Assignment__c rfc = new IETRS_File_Correspondence_Assignment__c(IETRS_Case__c = c.Id, IETRS_File_and_Correspondence__c = fc.Id);
        insert rfc;
        
        Test.StartTest();
        List<IETRS_Files_Correspondence__c> lstFCreturn = IETRS_Assign_Case_to_Hearings_Controller.getRelatedFCs(c.Id);
        system.assertEquals(fc.Id, lstFCreturn[0].Id);
        Test.StopTest();
    }

    public static TestMethod void assignToHearingsOrLETest(){
        Account acct = new Account(Name='Test');
        insert acct;

        String recTypeIdV3 = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('SMRD').getRecordTypeId();
        String recTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('AFS').getRecordTypeId();
        String strShareWithFieldName = 'IETRS_Shared_With_Hearings__c';
        String strShareWithFieldNameV2 = 'IETRS_Privileged__c';

        //Hearings test Case
        Case c = new Case(IETRS_Primary_Account_Assignment__c = acct.Id, 
                        IETRS_Docket_Group__c = 'OS - Oversight and Safety',
                        //strShareWithFieldName = 'IETRS_Shared_With_Hearings__c',
                        Type = 'R15',
                        RecordTypeId = recTypeId);
        insert c;
        //LE test Case
        Case cV2 = new Case(IETRS_Primary_Account_Assignment__c = acct.Id, 
                        IETRS_Docket_Group__c = 'OS - Oversight and Safety',
                        //strShareWithFieldNameV2 = 'IETRS_Privileged__c',
                        Type = 'AFS',
                        RecordTypeId = recTypeId);
        insert cV2;

        Case cV3 = new Case(IETRS_Primary_Account_Assignment__c = acct.Id, 
                        IETRS_Docket_Group__c = 'MR - Mining and Reclamation',
                        //strShareWithFieldNameV2 = 'IETRS_Privileged__c',
                        Type = 'ADM',
                        RecordTypeId = recTypeIdV3);
        insert cV3;
        
        //New F&C for Hearings
        IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c(IETRS_Case__c = c.id);
        insert fc;
        List<String> lstFCIds = new List<String>();
        lstFCIds.add(fc.Id);

        //New F&C for LE
        IETRS_Files_Correspondence__c fcV2 = new IETRS_Files_Correspondence__c(IETRS_Case__c = cV2.id);
        insert fcV2;
        List<String> lstFCIdsV2 = new List<String>();
        lstFCIdsV2.add(fcV2.Id);
        
        
        
        //New F&C unshared with Hearings
        IETRS_Files_Correspondence__c fc1 = new IETRS_Files_Correspondence__c(IETRS_Shared_With_Hearings__c = True, IETRS_Case__c = c.id);
        insert fc1;
        List<String> lstUnshareFCIds = new List<String>();
        lstUnshareFCIds.add(fc1.Id);
        
        //New F&C unshared with LE
        IETRS_Files_Correspondence__c fc1V2 = new IETRS_Files_Correspondence__c(IETRS_Privileged__c = True, IETRS_Case__c = cV2.id);
        insert fc1V2;
        List<String> lstUnshareFCIdsV2 = new List<String>();
        lstUnshareFCIdsV2.add(fc1V2.Id);


        Test.startTest();
        //Assgin to Hearings test
        IETRS_Assign_Case_to_Hearings_Controller.assignToHearingOrLE(lstFCIds, c.Id, lstUnshareFCIds, strShareWithFieldName);
        fc = [SELECT Id, IETRS_Shared_With_Hearings__c FROM IETRS_Files_Correspondence__c WHERE Id = :fc.Id];
        system.assertEquals(true, fc.IETRS_Shared_With_Hearings__c);
        fc1 = [SELECT Id, IETRS_Shared_With_Hearings__c FROM IETRS_Files_Correspondence__c WHERE Id = :fc1.Id];
        system.assertEquals(false, fc1.IETRS_Shared_With_Hearings__c);
        c = [SELECT Id, IETRS_Refer_to_Hearings__c, IETRS_Hearings_Status__c FROM Case WHERE Id = :c.Id];
        system.assertEquals(true, c.IETRS_Refer_to_Hearings__c);
        //system.assertEquals(System.Label.IETRS_Hearings_Status_Open_Needs_Assignment, c.IETRS_Hearings_Status__c);


        //Refer to Legal test non SMRD
        IETRS_Assign_Case_to_Hearings_Controller.assignToHearingOrLE(lstFCIdsV2, cV2.Id, lstUnshareFCIdsV2, strShareWithFieldNameV2);
        fcV2 = [SELECT Id, IETRS_Privileged__c FROM IETRS_Files_Correspondence__c WHERE Id = :fcV2.Id];
        system.assertEquals(true, fcV2.IETRS_Privileged__c);
        fc1V2 = [SELECT Id, IETRS_Privileged__c FROM IETRS_Files_Correspondence__c WHERE Id = :fc1V2.Id];
        system.assertEquals(false, fc1V2.IETRS_Privileged__c);
        cV2 = [SELECT Id, IETRS_Refer_to_Legal_Enforcement__c, IETRS_Legal_Enforcement_Status__c FROM Case WHERE Id = :cV2.Id];
        system.assertEquals(true, cV2.IETRS_Refer_to_Legal_Enforcement__c);
        system.assertEquals(System.Label.IETRS_Legal_Status_Open_Needs_Assignment, cV2.IETRS_Legal_Enforcement_Status__c);


        //Refer to Legal test SMRD
        IETRS_Assign_Case_to_Hearings_Controller.assignToHearingOrLE(lstFCIdsV2, cV3.Id, lstUnshareFCIdsV2, strShareWithFieldNameV2);
        fcV2 = [SELECT Id, IETRS_Privileged__c FROM IETRS_Files_Correspondence__c WHERE Id = :fcV2.Id];
        system.assertEquals(true, fcV2.IETRS_Privileged__c);
        fc1V2 = [SELECT Id, IETRS_Privileged__c FROM IETRS_Files_Correspondence__c WHERE Id = :fc1V2.Id];
        system.assertEquals(false, fc1V2.IETRS_Privileged__c);
        cV3 = [SELECT Id, IETRS_Refer_to_Legal_Enforcement__c, IETRS_Legal_Enforcement_Status__c FROM Case WHERE Id = :cV3.Id];
        system.assertEquals(true, cV3.IETRS_Refer_to_Legal_Enforcement__c);
        //system.assertEquals(System.Label.IETRS_Legal_Status_Open_Needs_Assignment, cV3.IETRS_Legal_Enforcement_Status__c);
        
        Test.stopTest();    

    }

    public static TestMethod void returnToHearingsTest(){
        Account acct = new Account(Name='Test');
        insert acct;
        //Hearings Case 
        String recTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('AFS').getRecordTypeId();
        Case c = new Case(IETRS_Primary_Account_Assignment__c = acct.Id, 
                        IETRS_Docket_Group__c = 'OS - Oversight and Safety',
                        Type = 'AFS',
                        IETRS_Refer_to_Hearings__c = true,
                        RecordTypeId = recTypeId);
        insert c;

        List<String> lstCaseIds = new List<String>();
        lstCaseIds.add(c.Id);

        //Legal Case
        String recTypeIdV2 = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('AFS').getRecordTypeId();
        Case cV2 = new Case(IETRS_Primary_Account_Assignment__c = acct.Id, 
                        IETRS_Docket_Group__c = 'OS - Oversight and Safety',
                        Type = 'AFS',
                        IETRS_Refer_to_Legal_Enforcement__c = true,
                        RecordTypeId = recTypeIdV2);
        insert cV2;
        
        List<String> lstCaseIdsV2 = new List<String>();
        lstCaseIdsV2.add(cV2.Id);
        /*
        //Case for return to business form legal
        String recTypeIdV3 = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Legal Enforcement').getRecordTypeId();
        Case cV3 = new Case(IETRS_Primary_Account_Assignment__c = acct.Id, 
                        IETRS_Docket_Group__c = 'OS - Oversight and Safety',
                        Type = 'AFS',
                        IETRS_Original_Record_Type__c = 'AFS',
                        IETRS_Refer_to_Legal_Enforcement__c = true,
                        RecordTypeId = recTypeIdV3);
        insert cV3;

        List<String> lstCaseIdsV3 = new List<String>();
        lstCaseIdsV3.add(cV3.Id);

        //Case for return to business form legal
        String recTypeIdV4 = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Hearings').getRecordTypeId();
        Case cV4 = new Case(IETRS_Primary_Account_Assignment__c = acct.Id, 
                        IETRS_Docket_Group__c = 'OS - Oversight and Safety',
                        Type = 'AFS',
                        IETRS_Original_Record_Type__c = 'AFS',
                        IETRS_Refer_to_Hearings__c = true,
                        RecordTypeId = recTypeIdV4);
        insert cV4;

        List<String> lstCaseIdsV4 = new List<String>();
        lstCaseIdsV4.add(cV4.Id);
        */
        Test.startTest();
        //Hearings Case test
        IETRS_Assign_Case_to_Hearings_Controller.returnToHearings(lstCaseIds);
        c = [SELECT Id, IETRS_Refer_to_Hearings__c, IETRS_Hearings_Status__c FROM Case WHERE Id = :c.Id];
        system.assertEquals(false, c.IETRS_Refer_to_Hearings__c);
        system.assertEquals(System.Label.IETRS_Returned_to_Business_Area, c.IETRS_Hearings_Status__c);
        
        //Legal Case test
        IETRS_Assign_Case_to_Hearings_Controller.returnToHearings(lstCaseIdsV2);
        cV2 = [SELECT Id, IETRS_Refer_to_Legal_Enforcement__c, IETRS_Legal_Enforcement_Status__c FROM Case WHERE Id = :cV2.Id];
        system.assertEquals(false, cV2.IETRS_Refer_to_Legal_Enforcement__c);
        system.assertEquals(System.Label.IETRS_Returned_to_Business_Area, cV2.IETRS_Legal_Enforcement_Status__c);

        //Legal Case test - Returned by not rejected 
        //IETRS_Assign_Case_to_Hearings_Controller.returnToHearings(lstCaseIdsV3);
        //cV3 = [SELECT Id, IETRS_Refer_to_Legal_Enforcement__c, IETRS_Legal_Enforcement_Status__c, IETRS_AFS_Case_Status__c FROM Case WHERE Id = :cV3.Id];
        //system.assertEquals('Returned From Legal Enforcement', cV3.IETRS_AFS_Case_Status__c);
        //system.assertEquals(System.Label.IETRS_Returned_to_Business_Area, cV3.IETRS_Legal_Enforcement_Status__c);

        //Legal Case test - Returned by not rejected
        //IETRS_Assign_Case_to_Hearings_Controller.returnToHearings(lstCaseIdsV4);
        //cV4 = [SELECT Id, IETRS_Refer_to_Hearings__c, IETRS_Hearings_Status__c, IETRS_AFS_Case_Status__c FROM Case WHERE Id = :cV4.Id];
        //system.assertEquals('Returned From Hearings', cV4.IETRS_AFS_Case_Status__c);

        //IETRS_Return_Case_To_Business_Area.returnToBusinessArea(lstCaseIdsV2);
        //cV2 = [SELECT Id, IETRS_Refer_to_Legal_Enforcement__c, IETRS_Legal_Enforcement_Status__c FROM Case WHERE Id = :cV2.Id];
        //system.assertEquals(false, cV3.IETRS_Refer_to_Legal_Enforcement__c);
        //system.assertEquals(System.Label.IETRS_Returned_to_Business_Area, cV3.IETRS_Legal_Enforcement_Status__c);
        //system.assertEquals(Legal, actual)

        //IETRS_Return_Case_To_Business_Area.helperReturnCaseUpdater(cV3.Id);
        //cV3 = [SELECT Id, IETRS_Refer_to_Legal_Enforcement__c, IETRS_Legal_Enforcement_Status__c, IETRS_AFS_Case_Status__c FROM Case WHERE Id = :cV3.Id];
        //system.assertEquals(System.Label.IETRS_Returned_from_Legal_Pick_Val, cV3.IETRS_AFS_Case_Status__c);
    

        Test.stopTest();
    }

}