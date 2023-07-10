@isTest
private class IETRS_UpdateComplaint_15828_Test {
    @TestSetup
    //doing our test setup for the one method in a test setup method
    static void makeData(){
        //taking advantage of the makeData utility class to generate usable org, unit, and RE records
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        //create a reasonable number of records to test that the batch works, say 25
        testUtils.createData(25, 1);
        //list to hold the complaints that will be processed by the batch class
        List<IETRS_Complaint__c> cList = new List<IETRS_Complaint__c>();
        //for each RE
        for(Account a : [
            SELECT id, IETRS_OrganizationofRegEntity__c
            FROM Account
            WHERE RecordType.Name = 'Regulated Entity - PS'
        ]){
            //create a complaint in resolution status 'closed'
            IETRS_Complaint__c c = new IETRS_Complaint__c(
                IETRS_Regulated_Entity_Name__c= a.id, 
                IETRS_Organization__c = a.IETRS_OrganizationofRegEntity__c,
                ITRES_Complaint_Received__c = System.today(),
                IETRS_Public_Portal_Record_Visible__c = true,
                IETRS_Complaint_Resolution_Status__c = 'Closed'
            );
            //add the new complaint to the complaint list
            cList.add(c);
        }
        //insert the complaint list
        insert cList;
    }
    static TestMethod void UpdateCoimplaint_15828_Test() {
        //run the batch class, which should 'touch' each record, which should trigger all automation for the complaint object
        IETRS_UpdateComplaint_15828 batchJob = new IETRS_UpdateComplaint_15828();
        ID jobID = Database.executeBatch(batchJob,50);
    }
}