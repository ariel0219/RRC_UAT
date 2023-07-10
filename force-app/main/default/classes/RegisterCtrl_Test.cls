@isTest(seeAllData=false)
public class RegisterCtrl_Test {
    @isTest
    public static void test_getEventStatus(){
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
        ev.EEM_Hours__c='8';
        ev.EEM_ICI_Type__c ='3.2 residential system installation course';
        ev.EEM_Event_Type__c = 'In Person';
        ev.EEM_Description__c = 'Test EEM_Description__c';
        ev.EEM_Event_Start_Date_And_Time__c = System.today()+1;
        ev.EEM_Event_End_Date_And_Time__c = System.today() + 2;
        ev.EEM_Event_Status__c = 'Open';
        ev.EEM_Class_Fee__c = 100;
        ev.EEM_Venue__c = ven.Id;
        insert ev;
        
     
        User usr = [SELECT Id FROM User WHERE Name='Gretchen Almind'];
        System.runAs(usr){
             String permissionSetName = RegisterCtrl.getPermissionSetName();
             String profileName = RegisterCtrl.getProfileName();
        }
        Test.startTest();
        String status = RegisterCtrl.getEventStatus(ev.Id);
        Test.stopTest();
        System.assertEquals('Open', status, 'Status Should be Open!');
        
        
    }
}