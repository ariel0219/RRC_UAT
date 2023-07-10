trigger IETRS_Insp_Event_Trigger on Event (before insert, after insert, after update, after delete) {
    //Create an Apex trigger on the Event object  when a record is deleted. 
    //If  the Related To was an Inspection Schedule record, 
    //	then update the Inspection Schedule record and clear the Inspection Begin and End Date  fields.  
    List<String> MyTriggerIds = new List<String>();
    List<String> MyInspTriggerIds = new List<String>();
    Map<Id, Event> inspScMap = new Map<Id, Event>();
    if(trigger.isDelete){
        for(Event MyEvent:trigger.old){
            if(MyEvent?.WhatId?.getSObjectType() == IETRS_InspSchedule__c.sObjectType){
                MyTriggerIds.add(MyEvent.WhatId);
            }
        }
    }
    if(trigger.isUpdate){
        for(Event MyEvent:trigger.new){
            if(MyEvent?.WhatId?.getSObjectType() == IETRS_InspSchedule__c.sObjectType){
                inspScMap.put(MyEvent.WhatId, MyEvent);
                MyTriggerIds.add(MyEvent.WhatId);
            }
        }
    }
    if(trigger.isAfter && trigger.isInsert){
        for(Event MyEvent:trigger.new){
            if(MyEvent?.WhatId?.getSObjectType() == IETRS_Inspection__c.sObjectType){
                inspScMap.put(MyEvent.WhatId, MyEvent);
                MyInspTriggerIds.add(MyEvent.WhatId);
            }
        }
    }
    
    if(trigger.isBefore && trigger.isInsert){
        for(Event MyEvent:trigger.new){
            if(MyEvent?.WhatId?.getSObjectType() == IETRS_InspSchedule__c.sObjectType){
                MyTriggerIds.add(MyEvent.WhatId);
            }
            else if(MyEvent?.WhatId?.getSObjectType() == IETRS_Inspection__c.sObjectType)
                MyInspTriggerIds.add(MyEvent.WhatId);
        }
    }
    
    if(MyTriggerIds.size() > 0){
        List<IETRS_InspSchedule__c> MyInspScheds = [select Id, IETRS_Inspection_Date__c, IETRS_Calendar_Event_ID__c, IETRS_Inspection_End_Date__c  from IETRS_InspSchedule__c WHERE Id  in :MyTriggerIds];
        Set<Id> setInspSchedIds = new Set<Id>();
        if(trigger.isDelete){
            for(IETRS_InspSchedule__c MIS:MyInspScheds){
                MIS.IETRS_Inspection_Date__c=null;
                MIS.IETRS_Inspection_End_Date__c=null;
                MIS.IETRS_Calendar_Event_ID__c=null;
                setInspSchedIds.add(MIS.Id);
            }
            List<Event> regionEvent = new List<Event>();
            regionEvent = [SELECT Id FROM Event WHERE WhatId IN :setInspSchedIds];
            if (regionEvent.size() > 0){
                delete regionEvent;
            }
        }
        else if(trigger.isUpdate){
            for(IETRS_InspSchedule__c MIS:MyInspScheds){
                if(MIS.IETRS_Calendar_Event_ID__c == inspScMap.get(MIS.ID).Id){
                    MIS.IETRS_Inspection_Date__c= inspScMap.get(MIS.ID).ActivityDate;
                    MIS.IETRS_Inspection_End_Date__c= inspScMap.get(MIS.ID).EndDateTime != NULL? Date.ValueOf(inspScMap.get(MIS.ID).EndDateTime) : NULL;
                }
            }
        }
        else if(trigger.isInsert && trigger.isBefore){
            for(Event MyEvent:trigger.new){
                for(IETRS_InspSchedule__c MIS:MyInspScheds){
                    if(myEvent.whatId == MIS.ID){
                        if(MIS.IETRS_Calendar_Event_ID__c != NULL && MIS.IETRS_Calendar_Event_ID__c != '')
                            MyEvent.addError('An event already exists for this inspection or inspection schedule');
                    }
                }
            }
        }
        update MyInspScheds;
    }
    else if(MyInspTriggerIds.size() > 0){
        List<IETRS_Inspection__c> MyInsps = [select Id, IETRS_Inspection_Schedule__c , IETRS_CalEventID_for_Inspection__c from IETRS_Inspection__c WHERE Id  in :MyInspTriggerIds];
        Map<Id, Id> eventInschMap = new Map<Id, Id>();
        if(trigger.isInsert && trigger.isAfter){
            for(IETRS_Inspection__c IS :MyInsps){
                if(IS.ID == inspScMap.get(IS.ID).whatId)
                    IS.IETRS_CalEventID_for_Inspection__c = inspScMap.get(IS.ID).Id;
                eventInschMap.put(IS.IETRS_Inspection_Schedule__c, inspScMap.get(IS.ID).Id);
            }
            List<IETRS_InspSchedule__c> insScheds = [select Id, IETRS_Calendar_Event_ID__c from IETRS_InspSchedule__c WHERE Id  in :eventInschMap.keySet()];
            for(IETRS_InspSchedule__c isc: insScheds)
                isc.IETRS_Calendar_Event_ID__c = eventInschMap.get(isc.ID);
            Update insScheds;
            //Update MyInsps;
        }
        
        if(trigger.isInsert && trigger.isBefore){
            List<Event> eventInsp = [SELECT ID, OwnerId, whatId FROM EVENT WHERE WhatID IN: MyInsps];
            Map<Id, Integer> personalEventsPerWhatId = new Map<Id, Integer>();
            Map<Id, Integer> publicEventsPerWhatId = new Map<Id, Integer>();
            for (Event e : eventInsp) {
                // Check if this event already has a whatId assigned
                if (e.WhatId != null) {
                    // Check if this event is a personal or public event
                    if (String.valueof(e.OwnerId).startsWith('005')) {
                        // Increment the count of personal events for this whatId
                        personalEventsPerWhatId.put(e.whatId, personalEventsPerWhatId.containsKey(e.WhatId) ? personalEventsPerWhatId.get(e.WhatId) + 1 : 1);
                    } else {
                        // Increment the count of public events for this whatId
                        publicEventsPerWhatId.put(e.whatId, publicEventsPerWhatId.containsKey(e.WhatId) ? publicEventsPerWhatId.get(e.WhatId) + 1 : 1);
                    }
                }
            }
            system.debug('personalEventsPerWhatId ' + personalEventsPerWhatId);
            system.debug('publicEventsPerWhatId ' + publicEventsPerWhatId);
            for(Event MyEvent:trigger.new){
                system.debug('MyEvent ' + MyEvent.OwnerId);
                // Check if there is more than one personal event for this whatId
                if (String.valueof(MyEvent.OwnerId).startsWith('005') && personalEventsPerWhatId.get(MyEvent.whatId) >= 1) {
                    MyEvent.addError('An event already exists for this inspection or inspection schedule.');
                }
                // Check if there is more than one public event for this whatId
                if (String.valueof(MyEvent.OwnerId).startsWith('02') && publicEventsPerWhatId.get(MyEvent.whatId) >= 1) {
                    MyEvent.addError('An event already exists for this inspection or inspection schedule');
                }
            }
        }
    }
}