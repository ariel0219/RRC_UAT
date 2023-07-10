@isTest
public class CIIS_CreateCalendarEvents_Test {
    @TestSetup
    static void makeData() {
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        testUtils.createData(2, 1);
          
    }
    
     @isTest
    private static void createCalEvents() {
        Test.startTest();
        CIIS_CreateCalendarEvents.eventParameters epam = new CIIS_CreateCalendarEvents.eventParameters();
        List<IETRS_Inspection_Package__c> ipList = [SELECT Id FROM IETRS_Inspection_Package__c];
        ipList[0].IETRS_Lead_Inspector__c = UserInfo.getUserId();
        update ipList;
        epam.ipId = ipList[0].Id;
         // create statewide region
        IETRS_County_Group__c objRegion = new IETRS_County_Group__c(
            Name = 'North',
            IETRS_Group_Type__c = 'Region',
            IETRS_Business_Area__c = 'Critical Infrastructure'
        );
        insert objRegion;
        List<IETRS_InspSchedule__c> schedules = [SELECT Id, IETRS_Regulated_Entity__c, IETRS_Inspection_Package__c FROM IETRS_InspSchedule__c Limit 1];
        schedules[0].IETRS_Inspection_Package__c = epam.ipId;
        List<Account> acc = [SELECT Id,CIIS_CID_Region__c FROM Account WHERE ID=: schedules[0].IETRS_Regulated_Entity__c ];
        acc[0].CIIS_CID_Region__c = objRegion.Id;
        update acc;
        update schedules;
       
        List<IETRS_Inspection__c> insp = [SELECT ID, IETRS_Inspection_Schedule__c, IETRS_Inspection_Package__r.IETRS_Lead_Inspector__c FROM IETRS_Inspection__c WHERE IETRS_Inspection_Package__c =: epam.ipId];
        for(IETRS_Inspection__c i: insp){
            i.IETRS_Inspection_Schedule__c = schedules[0].Id;
        }
        update insp;
        epam.addInspectorEvents = true;
        Event ev = new Event();
        ev.ActivityDate = System.today();
        ev.IsAllDayEvent = true;
        ev.whatId = schedules[0].Id;        
        epam.preparedEvents = new List<event>{ev};
        List<CIIS_CreateCalendarEvents.eventParameters> elist = new List<CIIS_CreateCalendarEvents.eventParameters>{epam};
        CIIS_CreateCalendarEvents.ciisCreateEvents(elist);
        Test.stopTest();
    }
}