@isTest
public class IETRS_MassRelatedFCControllerTest {
    static testMethod void IETRS_MassRelatedFCControllerTest() {
        Account acct = new Account(Name = 'Test');
        insert acct;
        Date key3 = date.Today() + 1;
        Account acct1 = new Account(Name = 'Test1');
        insert acct1;

        Case c = new Case(
            IETRS_Primary_Account_Assignment__c = acct1.Id,
            IETRS_Ready_for_Conference__c = false,
            IETRS_Agenda_Section__c = 'Agreed Enforcement Orders',
            IETRS_Conference_Date__c = key3
        );
        //c.IETRS_Conference_Date__c = Date.newInstance(2020, 12, 9);
        insert c;

        Case c1 = new Case(
            IETRS_Primary_Account_Assignment__c = acct.Id,
            IETRS_Ready_for_Conference__c = true,
            IETRS_Agenda_Section__c = 'Agreed Enforcement Orders',
            ParentId = c.id,
            IETRS_Conference_Date__c = key3
        );
        //c.IETRS_Conference_Date__c = Date.newInstance(2020, 12, 9);
        insert c1;

        List<String> lstCaseIds = new List<String>();
        lstCaseIds.add(c.Id);
        lstCaseIds.add(c1.Id);

        IETRS_Files_Correspondence__c fc1 = new IETRS_Files_Correspondence__c(
            IETRS_Public__c = true
        );
        IETRS_Files_Correspondence__c fc2 = new IETRS_Files_Correspondence__c();

        insert fc1;
        insert fc2;

        // create tracking date
        IETRS_Tracking_Date__c trackingDate = new IETRS_Tracking_Date__c(
            IETRS_Case__c = c.Id,
            IETRS_Date_Value__c = System.today(),
            IETRS_File_Correspondence__c = fc1.Id,
            IETRS_Type_of_Date__c = 'Hearing Letter Due'
        );
        insert trackingDate;

        Test.startTest();
        Map<String, List<Case>> lstCasesPositiveTest = IETRS_MassRelatedFCController.getCaseList(
            true,
            null,
            key3,
            null,
            fc1.Id
        );

        try {
            Map<String, List<Case>> lstCasesNegativeTest = IETRS_MassRelatedFCController.getCaseList(
                true,
                null,
                date.today(),
                null,
                fc1.Id
            );
        } catch (Exception e) {
            system.debug(e);
        }

        IETRS_MassRelatedFCController.createRelatedFCs(lstCaseIds, fc1.Id);
        IETRS_MassRelatedFCController.createRelatedFCs(
            lstCaseIds,
            trackingDate.Id
        );
        Test.stopTest();

        system.assertEquals(c1.id, lstCasesPositiveTest.get('cases')[0].id);

        List<IETRS_File_Correspondence_Assignment__c> lstRFCs = [
            SELECT Id
            FROM IETRS_File_Correspondence_Assignment__c
            WHERE IETRS_Case__c IN :lstCaseIds
        ];

        system.assertEquals(2, lstRFCs.size());

        List<String> lstRFCIds = new List<String>();
        for (IETRS_File_Correspondence_Assignment__c cd : lstRFCs) {
            lstRFCIds.add(cd.Id);
        }

        List<IETRS_Public_File_Correspondence__c> lstCaseDocs = [
            SELECT Id
            FROM IETRS_Public_File_Correspondence__c
            WHERE IETRS_Related_File_Correspondence__c IN :lstRFCIds
        ];

        //system.assertEquals(2, lstCaseDocs.size());

        // list<Case> lstCasesPositiveTest = IETRS_MassRelatedFCController.getCaseList(true, 'Agreed Enforcement Orders', Date.newInstance(2020, 12, 9), null, fc.Id);
        // system.assertEquals(c1.id, lstCasesPositiveTest[0].id);

        //list<Case> lstCasesNegativeTest = IETRS_MassRelatedFCController.getCaseList(false, 'Agreed Enforcement Orders', Date.newInstance(2020, 12, 9));
        //system.assertEquals(0, lstCasesNegativeTest.size());
    }
}