@isTest
public class IETRS_Insp_Event_TriggerTest {
    @TestSetup
    static void makeData() {
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        testUtils.createData(1, 1);
    }
    @isTest
    static void testEventDeleted() {
        //create event
        IETRS_InspSchedule__c is = [SELECT Id FROM IETRS_InspSchedule__c LIMIT 1];
        ID eventRecordTypeId = [SELECT ID FROM RecordType WHERE isActive = true AND Name = 'Inspection Event' AND sObjectType = 'Event']?.Id;
        Event evt = new Event(WhatId = is.Id, recordTypeId = eventRecordTypeId, ActivityDateTime = System.now(), DurationInMinutes = 30);
        insert evt;
        
        List<IETRS_Inspection__c> insp = [SELECT ID, IETRS_Inspection_Schedule__c, IETRS_Inspection_Package__r.IETRS_Lead_Inspector__c FROM IETRS_Inspection__c];
        for(IETRS_Inspection__c i: insp){
            i.IETRS_Inspection_Schedule__c = is.Id;
        }
        update insp;
        Event ev = new Event();
        ev.ActivityDate = System.today();
        ev.IsAllDayEvent = true;
        ev.whatId = insp[0].Id; 
        ev.recordTypeId = eventRecordTypeId;
        Insert ev;
        // Perform test
        Test.startTest();
        delete evt;
        Test.stopTest();
    }
}