trigger IETRS_IncidentTrigger on IETRS_Incident__c (before delete) {
    if(Trigger.isBefore){
        if(Trigger.isDelete){
            IETRS_IncidentTrigHelper.createActivityForDeletedIncident(trigger.oldMap);
        }
    }
}