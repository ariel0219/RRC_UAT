@isTest 

private class Ticket18DataPrimer_Test {
    

    @TestSetup
    static void makeData(){
        //Case, 2x Tracking Date, 1 Related Tracking Date
        Account testAccount1 = new Account(name = 'testAccount1');
        insert testAccount1;
        
        Case testCase = new Case(AccountId = testAccount1.id, status = 'Active');
        insert testCase;

        IETRS_Tracking_Date__c td1 = new IETRS_Tracking_Date__c(IETRS_Date_Value__c = Date.today(), IETRS_Type_of_Date__c = 'Document Signed', IETRS_Case__c = testCase.id );
        IETRS_Tracking_Date__c td2 = new IETRS_Tracking_Date__c(IETRS_Date_Value__c = Date.today(), IETRS_Type_of_Date__c = 'Document Signed', IETRS_Case__c = testCase.id );
        insert td1;
        insert td2;
        
        List<IETRS_Related_Tracking_Date__c> autoCreatedRTD = new List<IETRS_Related_Tracking_Date__c>();
        autocreatedRTD = [SELECT Id FROM IETRS_Related_Tracking_Date__c];
        delete autoCreatedRTD;
        
        IETRS_Related_Tracking_Date__c rtd = new IETRS_Related_Tracking_Date__c(IETRS_Case__c = testCase.id, IETRS_Tracking_Date_Name__c = td1.id);
        insert rtd;
    }

    static testMethod void validateTrackingDateFound() {
        
        Integer count = Database.countQuery('SELECT Count() FROM IETRS_Related_Tracking_Date__c');
        System.assertEquals(1, count);

        // Greg said that Test.startTest and Test.stopTest breaks the traditional async flow to specifically test async functions in a sync way
        // https://developer.salesforce.com/docs/atlas.en-us.224.0.apexcode.meta/apexcode/apex_testing_tools_start_stop_test.htm
        
        Test.startTest();

        Ticket18DataPrimer dataprimerTest = new Ticket18DataPrimer();
        ID jobID = Database.executeBatch(dataprimerTest, 200);

        Test.stopTest();

        count = Database.countQuery('SELECT Count() FROM IETRS_Related_Tracking_Date__c');
        System.assertEquals(2, count);
    }

}