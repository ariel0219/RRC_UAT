public with sharing class AFSRegistrantTriggerHandler {
    
    public static void beforeInsertLogic(List<EEM_Registrant__c> newRegistrantList) {
        List<EEM_Registrant__c> newRegistrantCollection = new List<EEM_Registrant__c>();
        for (EEM_Registrant__c newReg : newRegistrantList) {
            if (newReg.AFS_Social_Security_Number__c != null && newReg.AFS_Social_Security_Number__c.length() >= 4) {
                newReg.AFS_Last_4_SSN__c = string.ValueOf(newReg.AFS_Social_Security_Number__c.right(4));
            }
        }
    }

    public static void updateRegistrantFields(List<EEM_Registrant__c> registrantList, Map<Id, EEM_Registrant__c> oldMap) {
        for (EEM_Registrant__c reg : registrantList) {
            if (reg.AFS_Social_Security_Number__c != null && oldMap != null && reg.AFS_Social_Security_Number__c != oldMap.get(reg.Id).AFS_Social_Security_Number__c && reg.AFS_Social_Security_Number__c.length() >= 4) {
                reg.AFS_Last_4_SSN__c = string.ValueOf(reg.AFS_Social_Security_Number__c.right(4));
                System.debug('Last 4 SSN =  ' + string.ValueOf(reg.AFS_Social_Security_Number__c.right(4)));
                System.debug('Record Last 4 SSN =  ' + reg.AFS_Last_4_SSN__c);
            } else if (oldMap != null && reg.AFS_Person_ID__c != oldMap.get(reg.Id).AFS_Person_ID__c) {
                reg.AFS_Social_Security_Number__c = null;
            }
        }
    }

}