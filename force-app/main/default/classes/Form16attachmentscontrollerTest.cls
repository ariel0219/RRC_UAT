@istest(SeeAllData=false)
public class Form16attachmentscontrollerTest {
    static testmethod void validateForm(){
        
        EEM_Venue__c ven = new EEM_Venue__c();
        ven.Name='Austin Railroad Commission of Texas';
        ven.EEM_Street_Address1__c='4044 Promontory Point';
        ven.EEM_City__c='Austin';
        ven.EEM_State__c='TX';
        ven.EEM_Zip_Code__c='78744';
        ven.EEM_Total_Capacity__c=50;
        insert ven;
        
        ven.EEM_Total_Capacity__c=60;
        update ven;
        
        
        EEM_Event__c em= new EEM_Event__c();
        em.EEM_Event_Title__c='Test Class 972021';
        em.EEM_Class_Level__c='Continuing Education';
        em.EEM_Class_Duration__c='8-hour';
        em.EEM_Event_Type__c='In Person';
        em.EEM_Fuel_Type__c='LPG';
        em.EEM_Description__c='test';
        em.EEM_Event_Start_Date_And_Time__c=datetime.newInstance(2022, 9, 15, 12, 30, 0);
        em.EEM_Event_End_Date_And_Time__c=datetime.newInstance(2022, 9, 16, 12, 30, 0);
        
        em.EEM_Event_Status__c='Open';
        em.EEM_Venue__c=ven.id;
        em.EEM_Class_Fee__c=5500;
        em.EEM_Total_Capacity__c=70;
        insert em;
        
        EEM_Registrant__c reg = new EEM_Registrant__c();
        reg.EEM_First_Name__c='ABC';
        reg.EEM_Last_Name__c='XYZ';
        reg.EEM_Email__c='dummy@gmail.com';
        reg.EEM_Street_Address_1__c='QWE';
        reg.EEM_Street_Address_2__c='DFG';
        reg.EEM_Phone_Number__c='8826938860';
        reg.EEM_City__c='JHG';
        reg.EEM_State__c='TX';
        reg.EEM_Zip_Code__c='23456';
        reg.EEM_Company_Contact_Phone_Number__c='9044818760';
        reg.EEM_Company_Name__c='MS';
        reg.EEM_Company_Contact_Email__c='df@gmail.com';
        reg.EEM_Company_Contact_Person__c='poi';
        reg.EEM_No_license_number_or_license_is__c=true;
        insert reg;
        
        EEM_Event_Registration__c eventReg = new EEM_Event_Registration__c();
        eventReg.EEM_Registrant_Email__c='dummy@gmail.com';
        eventReg.EEM_Registrant__c=reg.Id;
        eventReg.EEM_Event__c=em.id;
        eventReg.EEM_Registration_Type__c='Complimentary';
        insert eventReg;
        
        PageReference pref = Page.EEM_LPG;       
		pref.getParameters().put('id',eventReg.id);
		Test.setCurrentPage(pref);
		Test.startTest();
		
		ApexPages.StandardController con = new ApexPages.StandardController(eventReg);
		Form16attachmentscontroller fc = new Form16attachmentscontroller();
        fc.UpdateContents(eventReg.Id);
		//mycon.cancel1();
		Test.stopTest();
        
       
    }
}