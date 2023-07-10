@isTest(SeeAllData=false)
public class EEM_TestEventTriggerHelper {
    public static testMethod void validateRegistrationCloseDate()
    {
        EEM_Venue__c ven = new EEM_Venue__c();
        ven.Name='Austin Railroad Commission of Texas';
        ven.EEM_Street_Address1__c='4044 Promontory Point';
        ven.EEM_City__c='Austin';
        ven.EEM_State__c='TX';
        ven.EEM_Zip_Code__c='78744';
        ven.EEM_Total_Capacity__c=50;
        insert ven;
        
        EEM_Venue__c ven1 = new EEM_Venue__c();
        ven1.Name='Austin Railroad Commission of Texas1';
        ven1.EEM_Street_Address1__c='4044 Promontory Point';
        ven1.EEM_City__c='Austin';
        ven1.EEM_State__c='TX';
        ven1.EEM_Zip_Code__c='78744';
        ven1.EEM_Total_Capacity__c=40;
        insert ven1;
        ven.EEM_Total_Capacity__c=50;
        update ven;
        
        
        List<EEM_Event__c> eventList=new List<EEM_Event__c>();
        EEM_Event__c testValue=new EEM_Event__c();
        testValue.EEM_Event_Title__c='Test';
        //testValue.EEM_Class_Level__c='Continuing Education';
        testValue.EEM_Exam_Level__c='Employee';
        testValue.EEM_Event_Type__c='Online';
        testValue.EEM_Fuel_Type__c='LPG';
        testValue.EEM_Description__c='Test Description';
        testValue.EEM_Event_Start_Date_And_Time__c=datetime.newInstance(2022, 9, 11, 12, 30, 0);
        testValue.EEM_Event_End_Date_And_Time__c=datetime.newInstance(2022, 9, 16, 12, 30, 0);
        testValue.EEM_Venue__c=ven.Id;
        testValue.EEM_Event_Status__c='Open';
        //testValue.EEM_Class_Duration__c='8-hour';
       // testValue.Close_Registration_Date__c=
        testValue.EEM_Total_Capacity__c=0;
        insert testValue;
        Test.startTest();
        testValue.EEM_Event_Title__c='Test1';
        testValue.EEM_Total_Capacity__c=1;
        update testValue;
        Test.stopTest();
        
        EEM_Event__c testValue1=new EEM_Event__c();
        testValue1.EEM_Event_Title__c='Test';
        testValue1.EEM_Class_Level__c='Continuing Education';
        testValue1.EEM_Event_Type__c='In Person';
        testValue1.EEM_Fuel_Type__c='LPG';
        testValue1.EEM_Description__c='Test Description';
        testValue1.EEM_Event_Start_Date_And_Time__c=datetime.newInstance(2022, 9, 11, 12, 30, 0);
        testValue1.EEM_Event_End_Date_And_Time__c=datetime.newInstance(2022, 9, 16, 12, 30, 0);
        testValue1.EEM_Venue__c=ven.Id;
        testValue1.EEM_Event_Status__c='Open';
        testValue1.EEM_Class_Duration__c='8-hour';
        //testValue.EEM_Total_Capacity__c=50;
        
        insert testValue1;
        
        EEM_Registrant__c emr= new EEM_Registrant__c();
        emr.EEM_Zip_Code__c='45623';
        emr.EEM_No_license_number_or_license_is__c=true;
        insert emr;
        
        EEM_Event_Registration__c er =new EEM_Event_Registration__c();
        er.EEM_Registration_Type__c='Complimentary';
        er.EEM_Event__c=testValue.id;
        er.EEM_Registrant_Email__c='abc@gmail.com';
        er.EEM_Registrant__c=emr.id;
        insert er;
        
        //update testValue;
        // testValue.Close_Registration_Date__c=Date.newInstance(testValue.EEM_Event_Start_Date_And_Time__c.year(), testValue.EEM_Event_Start_Date_And_Time__c.month(), testValue.EEM_Event_Start_Date_And_Time__c.day())-testValue.Number_of_Days__c);
        //ven.EEM_Total_Capacity__c=35;
        //update ven;
        //testValue.EEM_Total_Capacity__c=35;  
        //ven.EEM_Total_Capacity__c=45; 
        // update ven;
        
        EEM_Event_Registration__c erg =new EEM_Event_Registration__c();
        erg.EEM_Registration_Type__c='Complimentary';
        erg.EEM_Event__c=testValue.id;
        erg.EEM_Registrant_Email__c='abcg@gmail.com';
        erg.EEM_Registrant__c=emr.id;
        insert erg;
        
    }
    
}