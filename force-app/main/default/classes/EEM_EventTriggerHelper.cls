public class EEM_EventTriggerHelper {
    public static void updateRemainingCapacityAndSetStatusAsFullWhenNoSeatRemaning(Map<Id, EEM_Event__c> newMapEvents, Map<Id, EEM_Event__c> oldMapEvents){
        System.debug('In update Remaining Capacity');
        EEM_Event__c oldEventValues;
        List<EEM_Event__c> eventsToUpdate = new List<EEM_Event__c>();
        EEM_Event__c newEventValuesToBeUpdated;
        System.debug('@@@newMapEvents.values()'+oldMapEvents.values());
        for(EEM_Event__c evnt : newMapEvents.values()){
            oldEventValues = oldMapEvents.get(evnt.Id);
            if(evnt.EEM_Total_Registrant__c != oldEventValues.EEM_Total_Registrant__c || evnt.EEM_Total_Capacity__c  != oldEventValues.EEM_Total_Capacity__c ){
                newEventValuesToBeUpdated = new EEM_Event__c(Id = evnt.Id);
                newEventValuesToBeUpdated.EEM_Remaining_Space__c = evnt.EEM_Total_Capacity__c - evnt.EEM_Total_Registrant__c;
                if(evnt.EEM_Total_Capacity__c == evnt.EEM_Total_Registrant__c){
                    newEventValuesToBeUpdated.EEM_Event_Status__c = 'Full';
                }
                eventsToUpdate.add(newEventValuesToBeUpdated);
            }
            
        }
        if(!eventsToUpdate.isEmpty()){
            update eventsToUpdate;
        }
    }
    
    
    public static void updateRegistrationCloseDate(List<EEM_Event__c> newEvents, Map<Id, EEM_Event__c> oldMapEvents){
            for(EEM_Event__c event : newEvents){
             if(event.EEM_Event_Start_Date_And_Time__c != null && event.EEM_Number_of_Days__c  != null){
                    event.EEM_Close_Registration_Date__c    = Date.newInstance(event.EEM_Event_Start_Date_And_Time__c.year() , event.EEM_Event_Start_Date_And_Time__c.month() , (Integer)(event.EEM_Event_Start_Date_And_Time__c.day()-event.EEM_Number_of_Days__c) );
                }   
            }
        }
    public static void updateTotalCapacity(List<EEM_Event__c> newEvents, Map<Id, EEM_Event__c> oldMapEvents){
            for(EEM_Event__c event : newEvents){
             event.EEM_Total_Capacity__c=event.Total_Venue_Capacity__c  ; 
                System.debug('@@total capacity'+event.EEM_Total_Capacity__c);
            }
        }
    
    public static void preventDuplicate(List<EEM_Event__c>newEvents){
        
        String link;
        Set<String>eventName= new Set<String>();
        Set<DateTime>eventStartDateTime=new Set<DateTime>();
        Set<String>location=new Set<String>();
        
        for(EEM_Event__c evnt:newEvents){
            
            eventName.add(evnt.EEM_Event_Title__c);
            eventStartDateTime.add(evnt.EEM_Event_Start_Date_And_Time__c);
            location.add(evnt.EEM_Location__c);
        }
        
        List<EEM_Event__c>eventList=[Select Id,Name,EEM_Event_Title__c,EEM_Event_Start_Date_And_Time__c,EEM_Location__c From EEM_Event__c where EEM_Event_Title__c IN:eventName AND EEM_Event_Start_Date_And_Time__c IN:eventStartDateTime AND EEM_Location__c IN:location ];
        
         for(EEM_Event__c evnt:eventList){
          
           // link='<a href=\'https://rrctx--eemdev.lightning.force.com/' + evnt.Id + '\'>Record Name:' + evnt.Name + '</a>';
          link=evnt.EEM_Event_Title__c;
        }
        
        
        for(EEM_Event__c evnt:newEvents){
            
            if(eventList.size()>0){
                evnt.adderror('This is Duplicate Event Record Name:'+link,FALSE);
            }
        }
    }
    }