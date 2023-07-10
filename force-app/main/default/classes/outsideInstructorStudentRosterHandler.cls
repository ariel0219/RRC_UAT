public with sharing class outsideInstructorStudentRosterHandler {
    public outsideInstructorStudentRosterHandler() {

    }
    @AuraEnabled (cacheable=false)
    public static void createsEventRegistration(List<Id> registrantId,Id eventId){
        List<EEM_Registrant__c> addingRegistrants = [SELECT Id, EEM_First_Name__c, EEM_Last_Name__c, EEM_Email__c, EEM_RRC_Company_License_Number__c FROM EEM_Registrant__c WHERE Id IN :registrantId];
        List<EEM_Event_Registration__c> registrations = new List<EEM_Event_Registration__c>();
        System.debug('grok ' + addingRegistrants);
        for(EEM_Registrant__c em : addingRegistrants){
            EEM_Event_Registration__c newRegis = new EEM_Event_Registration__c();
            newRegis.EEM_Event__c = eventId;
            newRegis.EEM_Registration_Type__c = 'Payment Portal';
            newRegis.EEM_Registrant__c = em.Id;
            newRegis.EEM_Registrant_Email__c = em.EEM_Email__c;
            newRegis.AFS_Class_Credit__c = 'Yes';
            registrations.add(newRegis);
        }
        System.debug('grok ' + registrations);
        insert registrations;
        System.debug('grok after insert ' + registrations);
        
    }
    @AuraEnabled (cacheable=false)
    public static Boolean registrantEventTotal(Id eventRecordId){
        EEM_Event__c evt = [SELECT EEM_Remaining_Space__c, EEM_Total_Capacity__c FROM EEM_Event__c WHERE Id=:eventRecordId ];
        if(evt.EEM_Remaining_Space__c > 0){
            return true;
        }
        return false;
        
    }
    @AuraEnabled (cacheable=true)
    public static Id registrantRecordType(){
        Id registrantRecordTypeId = Schema.SObjectType.EEM_Registrant__c.getRecordTypeInfosByName().get('Exam/Class').getRecordTypeId();
        return registrantRecordTypeId;
    }

    @AuraEnabled (cacheable=true)
    public static Boolean isEventOpen(Id eventId){

        System.debug('eventId ::: ' + eventId);
        EEM_Event__c evt = [SELECT EEM_Event_Status__c FROM EEM_Event__c WHERE Id=:eventId ];
        
        //evt.EEM_Event_Status__c == 'Open' ? return true : return false;
        System.debug('evt.EEM_Event_Status__c ::: ' + evt.EEM_Event_Status__c);
         if(evt.EEM_Event_Status__c == 'Open'){

            return true;
        }

        return false;
    }

    @AuraEnabled (cacheable=true)
    public static Boolean isOwnedByLoggedinUser(Id eventId){

        System.debug('eventId ::: ' + eventId);
        EEM_Event__c evt = [SELECT CreatedById FROM EEM_Event__c WHERE Id=:eventId ];
        
        //evt.EEM_Event_Status__c == 'Open' ? return true : return false;
        System.debug('Createdby Id:' + evt.CreatedById + 'loggedin userid:' + UserInfo.getUserId());
         if(evt.CreatedById == UserInfo.getUserId()){

            return true;
        }

        return false;
    }

}