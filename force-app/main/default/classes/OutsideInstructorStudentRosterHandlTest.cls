/**
 * @File Name          : OutsideInstructorStudentRosterHandlTest.cls
 * @Description        : Test class for outsideInstructorStudentRosterHandler.cls
 * @Author             : Alex Ezhilarsan
 * @Group              : Slalom
 * @Last Modified By   : Alex Ezhilarsan
 * @Last Modified On   : 2/17/2023 
 * @Modification Log   : 
 *==============================================================================
 * Ver      Date            Author                  Modification
 *==============================================================================
 * 1.0      2/17/2023       Alex Ezhilarsan         Initial Version
**/
@isTest
public class OutsideInstructorStudentRosterHandlTest{

    static testMethod void test_eventRegistrationCreation(){    
        
        List<Id> registrantId = new List<Id>();
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
        emr.EEM_Email__c = 'john.doe@test.com';
        insert emr;
        registrantId.add(emr.Id);

        outsideInstructorStudentRosterHandler oisrh = new outsideInstructorStudentRosterHandler();
        outsideInstructorStudentRosterHandler.createsEventRegistration(registrantId, ev.Id);
        outsideInstructorStudentRosterHandler.registrantEventTotal(ev.Id);
        outsideInstructorStudentRosterHandler.registrantRecordType();
        outsideInstructorStudentRosterHandler.isEventOpen(ev.Id);

    }
}