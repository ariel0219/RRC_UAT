global class CIIS_CreateCalendarEvents {
    
    @invocableMethod
    public static void ciisCreateEvents(List<eventParameters> eventParam){
        
        List<IETRS_Inspection__c> ipList = [SELECT ID, IETRS_Inspection_Schedule__c, IETRS_Inspection_Package__r.IETRS_Lead_Inspector__c FROM IETRS_Inspection__c WHERE IETRS_Inspection_Package__c =: eventParam[0].ipId];
        Map<Id, IETRS_InspSchedule__c> iscList = new Map<Id,IETRS_InspSchedule__c>([SELECT ID, IETRS_Calendar_Event_ID__c, CIIS_CID_Region__c FROM IETRS_InspSchedule__c WHERE IETRS_Inspection_Package__c =: eventParam[0].ipId]);
        
        String regionName = iscList.values()[0]?.CIIS_CID_Region__c;
        String newSearchText = '%CIIS '+regionName+'%';
        ID pubCalendarId = [SELECT ID FROM Calendar WHERE Type='Public' AND Name LIKE: newSearchText]?.ID;
        ID eventRecordTypeId = [SELECT ID FROM RecordType WHERE isActive = true AND Name = 'Inspection Event' AND sObjectType = 'Event']?.Id;
        List<Event> newEvents = new List<Event>();
        ID leadInspector;
        for(IETRS_Inspection__c insp : ipList){
            for(event ev : eventParam[0].preparedEvents){
                if(ev.whatId == insp.IETRS_Inspection_Schedule__c){
                    ev.whatId = insp.Id;
                    ev.RecordTypeId = eventRecordTypeId;
                    ev.OwnerId = pubCalendarId;
                    leadInspector = insp.IETRS_Inspection_Package__r.IETRS_Lead_Inspector__c;
                    newEvents.add(ev);
                }
            }
        }
        if(!newEvents.isEmpty()){
            system.debug('newEvents ' + newEvents);
            insert newEvents;
        }
        if(eventParam[0].addInspectorEvents){
            List<Event> newInspectorEvents = new List<Event>();
            for(Event ev: newEvents){
                Event inspEvent = ev.clone(false, false, false, false);
                inspEvent.OwnerId = leadInspector;
                newInspectorEvents.add(inspEvent);
            }
            Insert newInspectorEvents;
        }
    }
    global class eventParameters {
        @InvocableVariable
        global Id ipId;
        
        @InvocableVariable
        global List<Event> preparedEvents;
        
        @InvocableVariable
        global Boolean addInspectorEvents;
        
    }
}