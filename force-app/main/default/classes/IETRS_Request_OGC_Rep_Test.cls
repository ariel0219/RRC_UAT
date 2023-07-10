@isTest
public class IETRS_Request_OGC_Rep_Test {
    
    public static TestMethod void IETRS_Request_OGC_Rep_Test() {
        Account acct = new Account(Name='Test');
        insert acct;
        String recTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('AFS').getRecordTypeId();

        Case c = new Case(IETRS_Primary_Account_Assignment__c = acct.Id, IETRS_Business_Area__c = 'Alternative Fuels', Type = 'AFS', RecordTypeId = recTypeId, IETRS_OGC_Representation_Requested__c = false);
        insert c;
        List<String> lstCaseIds = new List<String>();
        lstCaseIds.add(c.Id);

        Test.startTest();
        IETRS_Request_OGC_Representation.IETRS_Request_OGC_Representation(lstCaseIds);
        Case cReturned = [SELECT Id, IETRS_OGC_Representation_Requested__c FROM Case WHERE Id = :c.Id LIMIT 1];
        system.assertEquals(true, cReturned.IETRS_OGC_Representation_Requested__c);
        Test.stopTest();

    }
}