public with sharing class AFSExemptionTriggerHandler {
    
    public static void beforeInsertLogic(List<AFS_Exemption__c> newExemptionList) {
        List<AFS_Exemption__c> newExemptionCollection = new List<AFS_Exemption__c>();
        for (AFS_Exemption__c newExemp : newExemptionList) {
            if (newExemp.AFS_Social_Security_Number__c != null && newExemp.AFS_Social_Security_Number__c.length() >= 4) {
                newExemp.AFS_Last_4_SSN__c = string.ValueOf(newExemp.AFS_Social_Security_Number__c.right(4));
            }
        }
    }
    
    public static void updateExemptionFields(List<AFS_Exemption__c> exemptionList, Map<Id, AFS_Exemption__c> oldMap) {
        for (AFS_Exemption__c exemp : exemptionList) {
            if (oldMap != null && exemp.AFS_Social_Security_Number__c != oldMap.get(exemp.Id).AFS_Social_Security_Number__c && exemp.AFS_Social_Security_Number__c.length() >= 4) {
                exemp.AFS_Last_4_SSN__c = string.ValueOf(exemp.AFS_Social_Security_Number__c.right(4));
                System.debug('Last 4 SSN = ' + string.ValueOf(exemp.AFS_Social_Security_Number__c.right(4)));
                System.debug('Record Last 4 SSN = ' + exemp.AFS_Last_4_SSN__c);
            } else if (oldMap != null && exemp.AFS_Person_ID__c != oldMap.get(exemp.Id).AFS_Person_ID__c) {
                exemp.AFS_Social_Security_Number__c = null;
            }
        }
    }

}