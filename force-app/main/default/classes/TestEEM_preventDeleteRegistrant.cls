@isTest
public class TestEEM_preventDeleteRegistrant {
    @isTest
    public static void test_preventdeleteregistrant(){
    Id eventCLassRecordId = Schema.SObjectType.EEM_Event__c.getRecordTypeInfosByName().get('Class').getRecordTypeId();
        
        EEM_Venue__c ven = new EEM_Venue__c();
        ven.Name = 'Test Venue';
        ven.EEM_Street_Address1__c = 'test Address1';
        ven.EEM_City__c = 'New York';
        ven.EEM_Total_Capacity__c = 100;
        ven.EEM_Zip_Code__c = '12345';
        insert ven;
        
        EEM_Event__c ev = new EEM_Event__c();
        ev.RecordTypeId = eventCLassRecordId;
        ev.EEM_Event_Title__c = 'Test Event';
        ev.EEM_Class_Level__c = 'Initial Course of Instruction';
        ev.EEM_Event_Type__c = 'In Person';
        ev.EEM_Fuel_Type__c='LPG';
        ev.EEM_Hours__c='8';
        ev.EEM_ICI_Type__c='2.1 dispenser operations course';
        ev.EEM_Description__c = 'Test EEM_Description__c';
        ev.EEM_Event_Start_Date_And_Time__c = System.today()+1;
        ev.EEM_Event_End_Date_And_Time__c = System.today() + 2;
        ev.EEM_Event_Status__c = 'Open';
        ev.EEM_Class_Fee__c = 100;
        ev.EEM_Total_Capacity__c=50;
        ev.EEM_Venue__c = ven.Id;
        
        insert ev;
        
        EEM_Registrant__c emr= new EEM_Registrant__c();
        emr.EEM_Zip_Code__c='45623';
        emr.EEM_No_license_number_or_license_is__c=true;
        insert emr;
        
         EEM_Event_Registration__c erg =new EEM_Event_Registration__c();
        erg.EEM_Registration_Type__c='Complimentary';
        erg.EEM_Event__c=ev.id;
        erg.EEM_Registrant_Email__c='abcg@gmail.com';
        erg.EEM_Registrant__c=emr.id;
        insert erg;
        try{
        delete emr;
        
        }
        catch(Exception e) {}
    }
}