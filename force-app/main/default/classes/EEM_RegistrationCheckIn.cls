public with sharing class EEM_RegistrationCheckIn {
   
    @AuraEnabled(cacheable=true)
    public static List<EEM_Event_Registration__c> getRegistrationCheckInList(String eventId) {
        
		List<EEM_Event_Registration__c> registrationCheckIn = new List<EEM_Event_Registration__c>();
		try {
           registrationCheckIn = [SELECT ID, Name, EEM_Registrant__r.name, EEM_Event_Title__c,Registrant_Name__c,EEM_Registrant__r.EEM_Company_Name__c,EEM_Registrant_Email__c,EEM_Registration_Date__c,EEM_Status__c,EEM_Checked_In__c FROM EEM_Event_Registration__c where EEM_Event__c =:eventId order by Registrant_Name__c]; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
		return registrationCheckIn;
    }

    @AuraEnabled(cacheable=false)
    public static List<EEM_Event_Registration__c> findRegistrationCheckIn(String searchKey,String eventId) {
        String key = '%' + searchKey + '%';
        List<EEM_Event_Registration__c> findregistration = new List<EEM_Event_Registration__c>();
		System.debug('findregistration searchKey >>'+ key); 
        System.debug('findregistration eventId >>'+ eventId);
        try {
           findregistration = [SELECT ID, Name, EEM_Registrant__r.name, EEM_Event_Title__c,Registrant_Name__c,EEM_Registrant__r.EEM_Company_Name__c,EEM_Registrant_Email__c,EEM_Registration_Date__c,EEM_Status__c,EEM_Checked_In__c FROM EEM_Event_Registration__c
            WHERE EEM_Event__c =:eventId and (Registrant_Name__c LIKE :key or EEM_Registrant_Email__c LIKE :key or EEM_Registrant__r.EEM_Company_Name__c LIKE :key ) order by Registrant_Name__c];
            System.debug('findregistration >>'+ findregistration.size());         
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
		return findregistration;
        
    }
   @AuraEnabled(cacheable=true)
   public static Integer getTotalCount(String eventId) {
        return [select count() from EEM_Event_Registration__c where EEM_Event__c =:eventId];
    } 
   @AuraEnabled(cacheable=true)
    public static Integer getCheckInCount(String eventId) {
        return [select count() from EEM_Event_Registration__c where EEM_Checked_In__c = true and EEM_Event__c =:eventId];
    }
    
   @AuraEnabled(cacheable=true)
    public static Integer getNotCheckedInCount(String eventId) {
        return [select count() from EEM_Event_Registration__c where EEM_Checked_In__c = false and EEM_Status__c ='Registered' and EEM_Event__c =:eventId];
    }
  
    @AuraEnabled(cacheable=true)
    public static Integer getOnholdCount(String eventId) {
        return [select count() from EEM_Event_Registration__c where EEM_Checked_In__c = false and EEM_Status__c ='OnHold' and EEM_Event__c =:eventId];
    }
    
     @AuraEnabled(cacheable=true)
    public static Integer getRegisteredCount(String eventId) {
        return [select count() from EEM_Event_Registration__c where EEM_Status__c ='Registered' and EEM_Event__c =:eventId];
    }
    
     @AuraEnabled(cacheable=true)
    public static String getEventTitle(String eventId) {
        List<EEM_Event__c> eemeventTitleList = new List<EEM_Event__c>();
        String eventTitle ='';
        eemeventTitleList  = [select EEM_Event_Title__c  from EEM_Event__c where Id =:eventId limit 1];
        for(EEM_Event__c recordEventTitle : eemeventTitleList )
        { eventTitle = String.valueOf(recordEventTitle.get('EEM_Event_Title__c'));}
        
        return eventTitle;
    }
}