@istest(SeeallData=false)
class EEM_CloseRegistrationSchedulerTest{
    public static testMethod void testschedule() {
        EEM_Venue__c ven = new EEM_Venue__c();
        ven.Name='Austin Railroad Commission of Texas';
        ven.EEM_Street_Address1__c='4044 Promontory Point';
        ven.EEM_City__c='Austin';
        ven.EEM_State__c='TX';
        ven.EEM_Zip_Code__c='78744';
        ven.EEM_Total_Capacity__c=50;
        insert ven;
        
        List<EEM_Event__c> eventList=new List<EEM_Event__c>();
        EEM_Event__c testValue=new EEM_Event__c();
        testValue.EEM_Event_Title__c='Test';
        //testValue.EEM_Class_Level__c='Continuing Education';
        testValue.EEM_Exam_Level__c='Employee';
        testValue.EEM_Event_Type__c='Online';
        testValue.EEM_Fuel_Type__c='LPG';
        testValue.EEM_Description__c='Test Description';
        testValue.EEM_Event_Start_Date_And_Time__c=datetime.newInstance(2022, 2, 22, 12, 30, 0);
        testValue.EEM_Event_End_Date_And_Time__c=datetime.newInstance(2022, 2, 23, 12, 30, 0);
        testValue.EEM_Venue__c=ven.Id;
        testValue.EEM_Event_Status__c='Closed For Registration';
        //testValue.EEM_Class_Duration__c='8-hour';
       // testValue.Close_Registration_Date__c=
        testValue.EEM_Total_Capacity__c=0;
        insert testValue;
        Test.StartTest();
        EEM_CloseRegistrationScheduler testsche = new EEM_CloseRegistrationScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        System.assertEquals('Closed For Registration',testValue.EEM_Event_Status__c );
        Test.stopTest();
    }
}