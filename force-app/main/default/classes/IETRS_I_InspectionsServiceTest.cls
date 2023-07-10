/**
 * @author Greg Lovelidge - Sense Corp
 * @date 8/18/2020
 *
 * @description Tests for the inspection service class
 */
@isTest
private class IETRS_I_InspectionsServiceTest {
    @TestSetup
    static void makeData() {
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        IETRS_I_TestUtils.createUsers('IETRS Inspections - Inspector', 'PS Inspection Inspector', 3);
        testUtils.createData(2, 2);
        testUtils.createCounties();
    }

    @isTest
    static void itShouldUpdateCountyListOnInspections() {
        List<IETRS_Insp_Inspection_Counties_at_Eval__c> countiesAtEval = new List<IETRS_Insp_Inspection_Counties_at_Eval__c>();
        IETRS_Inspection__c testInspection = [SELECT Id, IETRS_Inspection_Counties__c FROM IETRS_Inspection__c LIMIT 1];
        for (IETRS_County__c county : [SELECT Id FROM IETRS_County__c]) {
            countiesAtEval.add(
                new IETRS_Insp_Inspection_Counties_at_Eval__c(
                    IETRS_County__c = county.Id,
                    IETRS_Inspection__c = testInspection.Id
                )
            );
        }
        Test.startTest();
        // insert
        insert countiesAtEval;
        // update
        countiesAtEval[0].IETRS_County__c = countiesAtEval[1].IETRS_County__c;
        update countiesAtEval[0];
        // delete
        Id deleteId = countiesAtEval[0].Id;
        delete countiesAtEval[0];
        // undelete
        undelete [SELECT Id FROM IETRS_Insp_Inspection_Counties_at_Eval__c WHERE Id = :deleteId ALL ROWS];
        Test.stopTest();
        IETRS_Inspection__c postTestInspection = [
            SELECT Id, IETRS_Inspection_Counties__c
            FROM IETRS_Inspection__c
            WHERE Id = :testInspection.Id
            LIMIT 1
        ];
        System.assert(
            postTestInspection.IETRS_Inspection_Counties__c != null,
            'The inspection counties should have been set on this field.'
        );
    }


    @isTest
    static void itShouldUpdateInspectorListOnIPs() {
        List<IETRS_Insp_Inspection_Package_Inspector__c> ipInspectors = new List<IETRS_Insp_Inspection_Package_Inspector__c>();
        IETRS_Inspection_Package__c testIp = [
            SELECT Id, IETRS_Lead_Inspector__c
            FROM IETRS_Inspection_Package__c
            LIMIT 1
        ];
        Profile inspectorProfile = [SELECT Id FROM Profile WHERE Name = 'IETRS Inspections - Inspector' LIMIT 1];
        for (User u : [SELECT Id FROM User WHERE ProfileId = :inspectorProfile.Id AND UserName Like '%@testuser.com' LIMIT 3]) {
            if (testIp.IETRS_Lead_Inspector__c == null) {
                testIp.IETRS_Lead_Inspector__c = u.Id;
            } else {
                ipInspectors.add(
                    new IETRS_Insp_Inspection_Package_Inspector__c(
                        IETRS_Inspector__c = u.Id,
                        IETRS_Inspection_Package__c = testIp.Id
                    )
                );
            }
        }
        Test.startTest();
        // update test ip with a lead inspector
        update testIp;
        // insert
        insert ipInspectors;
        // update
        ipInspectors[0].IETRS_Inspector__c = ipInspectors[1].IETRS_Inspector__c;
        update ipInspectors[0];
        // delete
        Id deleteId = ipInspectors[0].Id;
        delete ipInspectors[0];
        // undelete
        undelete [SELECT Id FROM IETRS_Insp_Inspection_Package_Inspector__c WHERE Id = :deleteId ALL ROWS];
        Test.stopTest();
        IETRS_Inspection_Package__c postTestIp = [
            SELECT Id, IETRS_Assigned_Inspector_List__c
            FROM IETRS_Inspection_Package__c
            WHERE Id = :testIp.Id
            LIMIT 1
        ];
        
        System.assert(
            postTestIp.IETRS_Assigned_Inspector_List__c != null,
            'The IP assigned inspector list should have been set on this field.'
        );
    }


    @isTest
    static void itShouldUpdateMilesOfHighConsequenceLiquid() {
        Decimal milesOfHCA = 100.0;
        IETRS_Inspection__c testInspection = [SELECT Id, IETRS_Regulated_Entity__c FROM IETRS_Inspection__c LIMIT 1];
        IETRS_Pipes_by_Class_Haz_Liq__c pipesByClass = new IETRS_Pipes_by_Class_Haz_Liq__c(
            IETRS_Miles_of_HCA__c = 99.0,
            IETRS_Inspection__c = testInspection.Id
        );

        Test.startTest();
        // insert
        insert pipesByClass;
        // update
        pipesByClass.IETRS_Miles_of_HCA__c = milesOfHCA;
        update pipesByClass;
        // delete
        delete pipesByClass;
        // undelete
        undelete [SELECT Id FROM IETRS_Pipes_by_Class_Haz_Liq__c WHERE Id = :pipesByClass.Id ALL ROWS];
        Test.stopTest();
        Account relatedEntity = [
            SELECT Id, IETRS_OrganizationofRegEntity__r.Total_Miles_of_High_Consequence_Liq__c
            FROM Account
            WHERE Id = :testInspection.IETRS_Regulated_Entity__c
            LIMIT 1
        ];
        System.assertEquals(
            relatedEntity.IETRS_OrganizationofRegEntity__r.Total_Miles_of_High_Consequence_Liq__c,
            milesOfHCA,
            'The total miles of high consequence liquid should have been set on the org.'
        );
    }

    @isTest
    static void itShouldUpdateMilesOfHighConsequenceGas() {
        Decimal milesOfHCA = 100.0;
        IETRS_Inspection__c testInspection = [SELECT Id, IETRS_Regulated_Entity__c FROM IETRS_Inspection__c LIMIT 1];
        IETRS_Pipes_by_Class__c pipesByClass = new IETRS_Pipes_by_Class__c(
            IETRS_Miles_of_HCA__c = 99.0,
            IETRS_Inspection__c = testInspection.Id
        );

        Test.startTest();
        // insert
        insert pipesByClass;
        // update
        pipesByClass.IETRS_Miles_of_HCA__c = milesOfHCA;
        update pipesByClass;
        // delete
        delete pipesByClass;
        // undelete
        undelete [SELECT Id FROM IETRS_Pipes_by_Class__c WHERE Id = :pipesByClass.Id ALL ROWS];
        Test.stopTest();
        Account relatedEntity = [
            SELECT Id, IETRS_OrganizationofRegEntity__r.Total_Miles_of_High_Consequence_Gas__c
            FROM Account
            WHERE Id = :testInspection.IETRS_Regulated_Entity__c
            LIMIT 1
        ];
        System.assertEquals(
            relatedEntity.IETRS_OrganizationofRegEntity__r.Total_Miles_of_High_Consequence_Gas__c,
            milesOfHCA,
            'The total miles of high consequence gas should have been set on the org.'
        );
    }

    // IETRS_PipesByClassTrigger
}