@isTest
private class AFSContactTriggerHandlerTest {
    
    static testMethod void ssnFilledOutTest() {
        Contact ssnPopulated = AFSContactAccountTestHelper.getContactWithAccount();
        System.debug('Populated SSN Test Contact =  ' + ssnPopulated);
        ssnPopulated.AFS_Last_4_SSN__c = '0999';
        update ssnPopulated;

        ssnPopulated = [SELECT Id, Name, AFS_Social_Security_Number__c, AFS_Last_4_SSN__c
                        FROM Contact
                        WHERE Name = 'Peter Parker'][0];
        System.debug('Updated Populated SSN Test Contact =  ' + ssnPopulated);
        
        System.assert(ssnPopulated.AFS_Last_4_SSN__c == '0999', 'The Last 4 SSN are the same!');
    }
    
    static testMethod void ssnUpdatedTest() {
       Contact testContact = AFSContactAccountTestHelper.getContactWithAccount();
       System.debug('Test Contact =  ' + testContact);
       testContact.AFS_Social_Security_Number__c = '867530991';
       update testContact;

       testContact = [SELECT Id, Name, AFS_Social_Security_Number__c, AFS_Last_4_SSN__c
                      FROM Contact
                      WHERE Name = 'Peter Parker'][0];
        System.debug('Updated Test Contact =  ' + testContact);

        System.assert(testContact.AFS_Social_Security_Number__c == '867530991', 'The Social Security Numbers are the same!');
        System.assert(testContact.AFS_Last_4_SSN__c == '0991', 'The Last 4 SSN are the same!');
    }

    static testMethod void clearSSNTest() {
        Contact clearSSN = AFSContactAccountTestHelper.getContactWithAccount();
        System.debug('Clear SSN Test Contact =  ' + clearSSN);
        clearSSN.AFS_LIS_Person_ID__c = '0987654321';
        update clearSSN;

        clearSSN = [SELECT Id, Name, AFS_Social_Security_Number__c, AFS_LIS_Person_ID__c
                    FROM Contact
                    WHERE Name = 'Peter Parker'][0];
        System.debug('Contact to have Social Security Number cleared: ' + clearSSN);
        
        System.assert(clearSSN.AFS_LIS_Person_ID__c == '0987654321', 'The LIS Person IDs are the same!');
        System.assert(clearSSN.AFS_Social_Security_Number__c == null, 'The Social Security Number field has been cleared!');
    }
    
    static testMethod void updateRegistrantInfoTest() {
        Contact testContact = AFSContactAccountTestHelper.getContactWithAccount();
        EEM_Registrant__c reg = new EEM_Registrant__c(EEM_First_Name__c = 'Test',
                                                      EEM_Last_Name__c = 'Test',
                                                      EEM_Email__c = 'test@example.com',
                                                      EEM_Phone_Number__c = '2345678900',
                                                      AFS_Social_Security_Number__c = '234984786',
                                                      EEM_RRC_Company_License_Number__c = '23456',
                                                      AFS_Related_Contact__c = testContact.Id);
        insert reg;
        testContact.Email = 'test@example.com';
        Update testContact;
    }

}