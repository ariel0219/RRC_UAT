trigger EEM_PreventDuplicateRegistrations on EEM_Event_Registration__c (before insert) {
    
    Set<String>registrantFullName= new Set<String>();
    Set<String>email=new Set<String>();
    Set<String>event=new Set<String>();
    
    
    for(EEM_Event_Registration__c rgnt:trigger.new){
        
        registrantFullName.add(rgnt.Registrant_Name__c);
        email.add(rgnt.EEM_Registrant_Email__c);
        event.add(rgnt.EEM_Event__c);
        
    }
    
    List<EEM_Event_Registration__c>eventRegistrationList=[Select Registrant_Name__c,EEM_Event__c,EEM_Registrant_Email__c From EEM_Event_Registration__c where EEM_Event__c IN :event];
    
    for(EEM_Event_Registration__c rgnt:trigger.new){
        
        for(EEM_Event_Registration__c er:eventRegistrationList){
            if((rgnt.Registrant_Name__c==er.Registrant_Name__c)&&(rgnt.EEM_Registrant_Email__c==er.EEM_Registrant_Email__c)){
                rgnt.adderror('This is Duplicate Registrant Record');
            }
        }
    }
    
}