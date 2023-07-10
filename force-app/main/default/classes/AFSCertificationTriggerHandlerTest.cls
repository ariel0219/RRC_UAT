@isTest
public with sharing class AFSCertificationTriggerHandlerTest {
    
    public static AFS_Certification__c initialSetup() {

        AFS_Certification__c cert = new AFS_Certification__c();
        cert.AFS_First_Name__c = 'Marc';
        cert.AFS_Last_Name__c = 'Benioff';
        cert.AFS_Social_Security_Number__c = '867530999';
        insert cert;

        cert = [SELECT Id, AFS_First_Name__c, AFS_Last_Name__c
                FROM AFS_Certification__c
                WHERE AFS_First_Name__c = 'Marc' AND AFS_Last_Name__c = 'Benioff'][0];
        System.debug('Certificatiion Found =  ' + cert);
        
        return cert;
    }

    static testMethod void ssnFilledOutTest() {
        AFS_Certification__c ssnPopulated = AFSCertificationTriggerHandlerTest.initialSetup();
        System.debug('Populated SSN Test Certification =  ' + ssnPopulated);
        ssnPopulated.AFS_Last_4_SSN__c = '0999';
        update ssnPopulated;

        ssnPopulated = [SELECT Id, Name, AFS_First_Name__c, AFS_Last_Name__c, AFS_Social_Security_Number__c, AFS_Last_4_SSN__c
                        FROM AFS_Certification__c
                        WHERE AFS_First_Name__c = 'Marc' AND AFS_Last_Name__c = 'Benioff'][0];
        System.debug('Updated Populated SSN Test Contact =  ' + ssnPopulated);
        
        System.assert(ssnPopulated.AFS_Last_4_SSN__c == '0999', 'The Last 4 SSN are the same!');
    }
    
    static testMethod void ssnUpdatedTest() {
        AFS_Certification__c testCertification = AFSCertificationTriggerHandlerTest.initialSetup();
        System.debug('Test Certification =  ' + testCertification);
        testCertification.AFS_Social_Security_Number__c = '867530991';
        update testCertification;

        testCertification = [SELECT Id, Name, AFS_First_Name__c, AFS_Last_Name__c, AFS_Social_Security_Number__c, AFS_Last_4_SSN__c
                             FROM AFS_Certification__c
                             WHERE AFS_First_Name__c = 'Marc' AND AFS_Last_Name__c = 'Benioff'][0];
        System.debug('Updated Test Certification =  ' + testCertification);
        
        System.assert(testCertification.AFS_Social_Security_Number__c == '867530991', 'The Social Security Numbers are the same!');
        System.assert(testCertification.AFS_Last_4_SSN__c == '0991', 'The Last 4 SSN are the same!');
    }

    static testMethod void clearSSNTest() {
        AFS_Certification__c clearSSN = AFSCertificationTriggerHandlerTest.initialSetup();
        System.debug('Clear SSN Test Certification =  ' + clearSSN);
        clearSSN.AFS_Person_ID__c = '0987654321';
        update clearSSN;

        clearSSN = [SELECT Id, Name, AFS_First_Name__c, AFS_Last_4_SSN__c, AFS_Social_Security_Number__c, AFS_Person_ID__c
                    FROM AFS_Certification__c
                    WHERE AFS_First_Name__c = 'Marc' AND AFS_Last_Name__c = 'Benioff'][0];
        System.debug('Certification to have Social Security Number cleared:  ' + clearSSN);
        
        System.assert(clearSSN.AFS_Person_ID__c == '0987654321', 'The Person IDs are the same!');
        System.assert(clearSSN.AFS_Social_Security_Number__c == null, 'The Social Security Number field has been cleared!');
    }
    
}