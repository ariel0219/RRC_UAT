@isTest
public with sharing class AFSExemptionTriggerHandlerTest {
    
    public static AFS_Exemption__c initialSetup() {

        AFS_Exemption__c exemp = new AFS_Exemption__c();
        exemp.AFS_First_Name__c = 'Gwen';
        exemp.AFS_Middle_Name__c = 'Elizabeth';
        exemp.AFS_Last_Name__c = 'Stacy';
        exemp.AFS_Social_Security_Number__c = '867530999';
        insert exemp;

        exemp = [SELECT Id, Name, AFS_First_Name__c, AFS_Middle_Name__c, AFS_Last_Name__c
                 FROM AFS_Exemption__c
                 WHERE AFS_First_Name__c = 'Gwen' AND AFS_Last_Name__c = 'Stacy'][0];
        System.debug('Exemption Found =  ' + exemp);
        
        return exemp;
    }

    static testMethod void ssnFilledOut() {
        AFS_Exemption__c ssnPopulated = AFSExemptionTriggerHandlerTest.initialSetup();
        System.debug('Populated SSN Test Exemption =  ' + ssnPopulated);
        ssnPopulated.AFS_Last_4_SSN__c = '0999';
        update ssnPopulated;

        ssnPopulated = [SELECT Id, Name, AFS_First_Name__c, AFS_Last_Name__c, AFS_Social_Security_Number__c, AFS_Last_4_SSN__c
                        FROM AFS_Exemption__c
                        WHERE AFS_First_Name__c = 'Gwen' AND AFS_Last_Name__c = 'Stacy'][0];
        System.debug('Updated Populated SSN Test Exemption =  ' + ssnPopulated);
        
        System.assert(ssnPopulated.AFS_Last_4_SSN__c == '0999', 'The Last 4 SSN are the same!');
    }
    
    static testMethod void ssnUpdatedTest() {
        AFS_Exemption__c testExemption = AFSExemptionTriggerHandlerTest.initialSetup();
        System.debug('Test Exemption =  ' + testExemption);
        testExemption.AFS_Social_Security_Number__c = '867530991';
        update testExemption;

        testExemption = [SELECT Id, Name, AFS_First_Name__c, AFS_Last_Name__c, AFS_Social_Security_Number__c, AFS_Last_4_SSN__c
                         FROM AFS_Exemption__c
                         WHERE AFS_First_Name__c = 'Gwen' AND AFS_Last_Name__c = 'Stacy'][0];
        System.debug('Updated Test Exemption =  ' + testExemption);
        
        System.assert(testExemption.AFS_Social_Security_Number__c == '867530991', 'The Social Security Numbers are the same!');
        System.assert(testExemption.AFS_Last_4_SSN__c == '0991', 'The Last 4 SSN are the same!');
    }

    static testMethod void clearSSNTest() {
        AFS_Exemption__c clearSSN = AFSExemptionTriggerHandlerTest.initialSetup();
        System.debug('Clear SSN Test Exemption =  ' + clearSSN);
        clearSSN.AFS_Last_4_SSN__c = '0999';
        clearSSN.AFS_Person_ID__c = '0987654321';
        update clearSSN;

        clearSSN = [SELECT Id, Name, AFS_First_Name__c, AFS_Last_Name__c, AFS_Social_Security_Number__c, AFS_Person_ID__c, AFS_Last_4_SSN__c
                    FROM AFS_Exemption__c
                    WHERE AFS_First_Name__c = 'Gwen' AND AFS_Last_Name__c = 'Stacy'][0];
        System.debug('Exemption to have Social Security Number cleared:  ' + clearSSN);
        
        System.assert(clearSSN.AFS_Person_ID__c == '0987654321', 'The Person IDs are the same');
        System.assert(clearSSN.AFS_Social_Security_Number__c == null, 'The Social Security Number field has been cleared!');
    }

}