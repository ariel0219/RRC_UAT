@isTest
private class IETRS_UpdateIncident_15828_Test {
    @TestSetup
   //doing our test setup for the one method in a test setup method
   static void makeData(){
    //taking advantage of the makeData utility class to generate usable org, unit, and RE records
    IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
    //create a reasonable number of records to test that the batch works, say 25
    testUtils.createData(25, 1);
    //list to hold the incidents that will be processed by the batch class
    List<IETRS_Incident__c> iList = new List<IETRS_Incident__c>();
    //for each RE
    for(Account a : [
        SELECT id, IETRS_OrganizationofRegEntity__c
        FROM Account
        WHERE RecordType.Name = 'Regulated Entity - PS'
    ]){
        //create a incident in status 'closed'
        IETRS_Incident__c i = new IETRS_Incident__c(
            IETRS_Public_Portal_Record_Visible__c = false,
            IETRS_Regulated_Entity__c = a.id, 
            IETRS_Organization__c = a.IETRS_OrganizationofRegEntity__c,
            IETRS_Incident_Status__c = 'Closed'
        );
        //add the new incident to the incident list
        iList.add(i);
    }
    //insert the incident list
    insert iList;
    }
    static TestMethod void UpdateIncident_15828_Test() {
        //run the batch class, which should 'touch' each record, which should trigger all automation for the incident object
        IETRS_UpdateIncident_15828 batchJob = new IETRS_UpdateIncident_15828();
        ID jobID = Database.executeBatch(batchJob,50);
    }
}