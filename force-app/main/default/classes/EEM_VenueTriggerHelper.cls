public class EEM_VenueTriggerHelper {
    
    public static void preventDuplicate(List<EEM_Venue__c>newVenue){
        
        String link;
        Set<String>name=new Set<String>();
        Set<String>address= new Set<String>();
        Set<String>city = new Set<String>();
        Set<String>state =new Set<String>();
        
        for(EEM_Venue__c ven :newVenue ){
            
            name.add(ven.Name);
            address.add(ven.EEM_Street_Address1__c);
            city.add(ven.EEM_City__c);
            state.add(ven.EEM_State__c);
            
        }
        
        List<EEM_Venue__c>venueList= [Select Id,Name,EEM_Street_Address1__c,EEM_City__c,EEM_State__c From EEM_Venue__c where Name IN:name AND EEM_Street_Address1__c IN:address AND EEM_City__c IN:city AND EEM_State__c IN:state];
        
        for(EEM_Venue__c ven:venueList){
          
            //link='<a href=\'https://rrctx--eemdev.lightning.force.com/' + ven.Id + '\'>Record Name:' + ven.Name + '</a>';
          link=ven.Name;
        }
        
        for(EEM_Venue__c ven : newVenue){
            if(venueList.size()>0){
                ven.adderror('This is Duplicate Venue Record Name:'+link,FALSE);
            }
        }
    }
    
    public static void validateTotalCapacityField(Map<Id, EEM_Venue__c> newVenues , Map<Id, EEM_Venue__c> oldVanues){
        Set<Id> venuesWithUpdatedCapacity = new Set<Id>();
        EEM_Venue__c venueValue;
        for(EEM_Venue__c venue : newVenues.values()){
            venueValue = oldVanues.get(venue.Id);
            if(venue.EEM_Total_Capacity__c != venueValue.EEM_Total_Capacity__c){
                venuesWithUpdatedCapacity.add(venue.Id);
            }
            System.debug('@@@venuesWithUpdatedCapacity'+venuesWithUpdatedCapacity);
            System.debug('@@@venue.EEM_Total_Capacity__c'+venue.EEM_Total_Capacity__c);
            System.debug('@@@venueValue.EEM_Total_Capacity__c'+venueValue.EEM_Total_Capacity__c);
        }
        if(!venuesWithUpdatedCapacity.isEmpty()){ 
            List<EEM_Event__c> events = Database.query('SELECT Id, Name, EEM_Venue__c,EEM_Total_Registrant__c, EEM_Total_Capacity__c,EEM_Event_Type__c,EEM_Fuel_Type__c ,EEM_Exam_Level__c FROM EEM_Event__c WHERE (EEM_Event_Status__c = \'Open\'' +' OR EEM_Event_Status__c = \'Pending\'' +') AND EEM_Venue__c IN :venuesWithUpdatedCapacity');
            
            for(EEM_Event__c event : events){
                venueValue = newVenues.get(event.EEM_Venue__c);
                
                if(venueValue.EEM_Total_Capacity__c < event.EEM_Total_Registrant__c){
                    venueValue.addError('There is already an event \'' + event.Name + '\' exist with more registration then the new capacity you are trying to set');
                }
            }
            
            for(EEM_Event__c event : events){
                event.EEM_Total_Capacity__c=newVenues.values().EEM_Total_Capacity__c;
                System.debug('@@@event.EEM_Total_Capacity__c'+event.EEM_Total_Capacity__c);
            }
            
            system.debug('@@@events'+events);
            update events;
            
        }
    }
    
}