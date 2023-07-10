@istest(SeeAllData=false)
public class EEM_VenueTriggerHelperTest {
    static testmethod void validatecapacity(){
        
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
        
        
        
    }

}