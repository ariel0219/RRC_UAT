@isTest
public with sharing class IETRS_Task_UpdateWhatsId_Test {
    public static TestMethod void IETRS_Task_UpdateWhatsId_Test() {
        //create parent records for the task records we need for our test
            //user for record assignment
            User usr = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];

            //account test record - name required
            Account parAct = new Account(Name = 'Test Account');
            //insert the account so it gets assigned a record Id
            insert parAct;
            //incident test record - has no required fields
            IETRS_Incident__c parInc = new IETRS_Incident__c();
            //insert the incident so it gets assigned a record Id
            insert parInc;
            //Inspection Package - has no required fields
            IETRS_Inspection_Package__c parIspPkg = new IETRS_Inspection_Package__c();
            //insert the inspection package so it gets assigned a record Id
            insert parIspPkg;
            //weekly work report - total field hours required
            IETRS_Insp_Weekly_Work_Report__c parWklRpt = new IETRS_Insp_Weekly_Work_Report__c(IETRS_Status__c  = 'Work in Progress', IETRS_Employee_Name__c = usr.Id);
            //insert the weekly work report so it gets assigned a record Id
            insert parWklRpt;

            //list to hold tasks to insert for use in test 'SYSTEM', 'ORG', 'UNIT', 'WEEKLY_REPORT', 'IP', 'INCIDENT'
            List<Task> tskList = new List<Task>();

            //set value of Event_ID_External__c to each value checked for 
            //creates over two hundred records so the batch process runs through multiple batches
            for(Integer i=0; i<33; i++){
                //Set values for a system external Id record
                Task taskSys = new Task(IETRS_Incident__c = parInc.Id, IETRS_Inspection_Package__c = parIspPkg.Id, IETRS_Primary_Account__c = parAct.Id,
                IETRS_Weekly_Work_Report__c = parWklRpt.Id, Priority = 'Normal', OwnerId = usr.Id, Subject = 'Other', Event_ID_External__c = 'SYSTEM-'+i);
                //add the system task record to the record list
                tskList.add(taskSys);

                //Set values for an org external Id record
                Task taskOrg = new Task(IETRS_Incident__c = parInc.Id, IETRS_Inspection_Package__c = parIspPkg.Id, IETRS_Primary_Account__c = parAct.Id,
                IETRS_Weekly_Work_Report__c = parWklRpt.Id, Priority = 'Normal', OwnerId = usr.Id, Subject = 'Other', Event_ID_External__c = 'ORG-'+i);
                //add the org task record to the record list
                tskList.add(taskOrg);

                //Set values for a unit external Id record
                Task taskUnit = new Task(IETRS_Incident__c = parInc.Id, IETRS_Inspection_Package__c = parIspPkg.Id, IETRS_Primary_Account__c = parAct.Id,
                IETRS_Weekly_Work_Report__c = parWklRpt.Id, Priority = 'Normal', OwnerId = usr.Id, Subject = 'Other', Event_ID_External__c = 'UNIT-'+i);
                //add the unit task record to the record list
                tskList.add(taskUnit);

                //Set values for a weekly report external Id record
                Task taskWklRpt = new Task(IETRS_Incident__c = parInc.Id, IETRS_Inspection_Package__c = parIspPkg.Id, IETRS_Primary_Account__c = parAct.Id,
                IETRS_Weekly_Work_Report__c = parWklRpt.Id, Priority = 'Normal', OwnerId = usr.Id, Subject = 'Other', Event_ID_External__c = 'WEEKLY_REPORT-'+i);
                //add the weekly report task record to the record list
                tskList.add(taskWklRpt);

                //Set values for an ip external Id record
                Task taskIP = new Task(IETRS_Incident__c = parInc.Id, IETRS_Inspection_Package__c = parIspPkg.Id, IETRS_Primary_Account__c = parAct.Id,
                IETRS_Weekly_Work_Report__c = parWklRpt.Id, Priority = 'Normal', OwnerId = usr.Id, Subject = 'Other', Event_ID_External__c = 'IP-'+i);
                //add the ip task record to the record list
                tskList.add(taskIP);

                //Set values for an incident external Id record
                Task taskInc = new Task(IETRS_Incident__c = parInc.Id, IETRS_Inspection_Package__c = parIspPkg.Id, IETRS_Primary_Account__c = parAct.Id,
                IETRS_Weekly_Work_Report__c = parWklRpt.Id, Priority = 'Normal', OwnerId = usr.Id, Subject = 'Other', Event_ID_External__c = 'INCIDENT-'+i);
                //add the incident task record to the record list
                tskList.add(taskInc);
            }
            //insert the task records
            insert tskList;

            Test.startTest();
            IETRS_Task_UpdateWhatsId batchJob = new IETRS_Task_UpdateWhatsId();
            ID jobID = Database.executeBatch(batchJob,200);
            Test.stopTest();
    }
}