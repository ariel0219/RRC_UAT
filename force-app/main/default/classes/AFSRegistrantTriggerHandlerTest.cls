@isTest
public with sharing class AFSRegistrantTriggerHandlerTest {
    
    public static EEM_Registrant__c initialSetup() {

        EEM_Registrant__c reg = new EEM_Registrant__c();
        reg.EEM_First_Name__c = 'Emmit';
        reg.EEM_Last_Name__c = 'Smith';
        reg.EEM_Email__c = 'emmit.smith@dallascowboysgasco.com';
        reg.EEM_Company_Name__c = 'Dallas Cowboys Gas Co.';
        reg.EEM_RRC_Company_License_Number__c = '58324';
        reg.AFS_Social_Security_Number__c = '867530999'; 
        reg.EEM_Zip_Code__c = '55346';
        
        insert reg;

        reg = [SELECT ID, Name, EEM_First_Name__c, EEM_Last_Name__c
               FROM EEM_Registrant__c
               WHERE EEM_First_Name__c = 'Emmit' AND EEM_Last_Name__c = 'Smith'][0];
        System.debug('Registrant Found =  ' + reg);
        
        return reg;
    }

    static testMethod void ssnFilledOutTest() {
        EEM_Registrant__c ssnPopulated = AFSRegistrantTriggerHandlerTest.initialSetup();
        System.debug('Populated SSN Test Registrant =  ' + ssnPopulated);
        ssnPopulated.AFS_Last_4_SSN__c = '0999';
        update ssnPopulated;

        ssnPopulated = [SELECT Id, Name, EEM_First_Name__c, EEM_Last_Name__c, AFS_Social_Security_Number__c, AFS_Last_4_SSN__c
                        FROM EEM_Registrant__c
                        WHERE EEM_First_Name__c = 'Emmit' AND EEM_Last_Name__c = 'Smith'][0];
        System.debug('Updated Populated SSN Test Registrant =  ' + ssnPopulated);
        
        System.assert(ssnPopulated.AFS_Last_4_SSN__c == '0999', 'The Last 4 SSN are the same!');
    }

    static testMethod void ssnUpdatedTest() {
        EEM_Registrant__c testRegistrant = AFSRegistrantTriggerHandlerTest.initialSetup();
        System.debug('Test Registrant =  ' + testRegistrant);
        testRegistrant.AFS_Social_Security_Number__c = '867530991';
        update testRegistrant;

        testRegistrant = [SELECT Id, Name, EEM_First_Name__c, EEM_Last_Name__c, AFS_Social_Security_Number__c, AFS_Last_4_SSN__c
                          FROM EEM_Registrant__c
                          WHERE EEM_First_Name__c = 'Emmit' AND EEM_Last_Name__c = 'Smith'][0];
        System.debug('Updated Test Registrant =  ' + testRegistrant);
        
        System.assert(testRegistrant.AFS_Social_Security_Number__c == '867530991', 'The Social Security Numbers are the same!');
        System.assert(testRegistrant.AFS_Last_4_SSN__c == '0991', 'The Last 4 SSN are the same!');
    }

    static testMethod void clearSSNTest() {
        EEM_Registrant__c clearSSN = AFSRegistrantTriggerHandlerTest.initialSetup();
        System.debug('Clear SSN Test Registrant =  ' + clearSSN);
        clearSSN.AFS_Last_4_SSN__c = '0999';
        clearSSN.AFS_Person_ID__c = '0987654321';
        update clearSSN;

        clearSSN = [SELECT Id, Name, EEM_First_Name__c, EEM_Last_Name__c, AFS_Social_Security_Number__c, AFS_Last_4_SSN__c, AFS_Person_ID__c
                    FROM EEM_Registrant__c
                    WHERE EEM_First_Name__c = 'Emmit' AND EEM_Last_Name__c = 'Smith'][0];
        System.debug('Registrant to have Social Security Number cleared: ' + clearSSN);
        
        System.assert(clearSSN.AFS_Person_ID__c == '0987654321', 'The Person IDs are the same!');
        System.assert(clearSSN.AFS_Social_Security_Number__c == null, 'The Social Security Number field has been cleared!');
    }

}