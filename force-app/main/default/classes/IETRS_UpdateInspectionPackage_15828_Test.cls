@isTest
private class IETRS_UpdateInspectionPackage_15828_Test {
    @TestSetup
    //doing our test setup for the one method in a test setup method
    static void makeData(){
     //taking advantage of the makeData utility class to generate usable org, unit, and RE records
     IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
     //create a reasonable number of records to test that the batch works, say 25
     testUtils.createData(10, 1);
     //list to hold the inspection packages that will be processed by the batch class
     List<IETRS_Inspection_Package__c> ipList = new List<IETRS_Inspection_Package__c>();
     //for each RE
     for(IETRS_Inspection_Package__c ip : [
         SELECT id, IETRS_Status__c
         FROM IETRS_Inspection_Package__c
     ]){
         //set the inspection packages in status 'closed'
         ip.IETRS_Status__c = 'Closed';
         //add the new inspection packages to the inspection packages list
         ipList.add(ip);
     }
     //insert the inspection packages list
     update ipList;
    }
    static TestMethod void UpdateInspectionPackage_15828_Test() {
        //run the batch class, which should 'touch' each record, which should trigger all automation for the inspection packages object
        IETRS_UpdateInspectionPackage_15828 batchJob = new IETRS_UpdateInspectionPackage_15828();
    	ID jobID = Database.executeBatch(batchJob,15);
    }
}