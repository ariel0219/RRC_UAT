public with sharing class AFSCertificationTriggerHandler {
    
    public static void beforeInsertLogic(List<AFS_Certification__c> newCertificationList) {
        List<AFS_Certification__c> newCertificationCollection = new List<AFS_Certification__c>();
        for (AFS_Certification__c newCert : newCertificationList) {
            if (newCert.AFS_Social_Security_Number__c != null && newCert.AFS_Social_Security_Number__c.length() >= 4) {
                newCert.AFS_Last_4_SSN__c = string.ValueOf(newCert.AFS_Social_Security_Number__c.right(4));
            }
        }
    }
    
    public static void updateCertificationFields(List<AFS_Certification__c> certificationList, Map<Id, AFS_Certification__c> oldMap) {
        for (AFS_Certification__c cert : certificationList) {
            if (oldMap != null && cert.AFS_Social_Security_Number__c != oldMap.get(cert.Id).AFS_Social_Security_Number__c && cert.AFS_Social_Security_Number__c.length() >= 4) {
                cert.AFS_Last_4_SSN__c = string.ValueOf(cert.AFS_Social_Security_Number__c.right(4));
                System.debug('Last 4 SSN =  ' + string.ValueOf(cert.AFS_Social_Security_Number__c.right(4)));
                System.debug('Record Last 4 SSN =  ' + cert.AFS_Last_4_SSN__c);
            } else if (oldMap != null && cert.AFS_Person_ID__c != oldMap.get(cert.Id).AFS_Person_ID__c) {
                cert.AFS_Social_Security_Number__c = null;
            }
        }
    }

}