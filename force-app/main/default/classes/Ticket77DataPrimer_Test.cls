@isTest 
private class Ticket77DataPrimer_Test {
    @TestSetup
    static void makeData(){
        RecordType orgRT = new RecordType();
        orgRT = [SELECT Id FROM RecordType WHERE Name = 'Organization' Limit 1][0];
        Account testAccount1 = new Account(name = 'testAccount1', RecordTypeId = orgRT.Id);
        insert testAccount1;
        
        RecordType hearingsRT = new RecordType();
        hearingsRT = [SELECT Id FROM RecordType WHERE Name = 'Hearings' Limit 1][0];
        Case testCase1 = new Case( 
            RecordTypeId = hearingsRT.Id, 
        	IETRS_Primary_Account_Assignment__c = testAccount1.Id,
        	Type = 'GFC',
            Status = 'Active',
            IETRS_Business_Area__c = 'Oil and Gas'
        );
        insert testCase1;
        
        Case testCase2 = new Case( 
            RecordTypeId = hearingsRT.Id, 
        	IETRS_Primary_Account_Assignment__c = testAccount1.Id,
        	Type = 'GFC',
            Status = 'Active',
            IETRS_Business_Area__c = 'Oil and Gas',
            ParentId = testCase1.Id
        );
        insert testCase2;
    }
    static testMethod void validateRecordsUpdated() {
		
        Integer initialCase = [Select COUNT() FROM Case Where ParentId <> null AND Parent.IETRS_Is_Parent_Case__c = true];
        
        Test.startTest();
        
        //revert data from RT flow
        If(initialCase == 1){
            Case updateCase = [Select Id, IETRS_Is_Parent_Case__c FROM Case WHERE IETRS_Is_Parent_Case__c = true LIMIT 1][0];
            updateCase.IETRS_Is_Parent_Case__c = false;
            Update updateCase;
        }
        
        Ticket77DataPrimer dataprimerTest = new Ticket77DataPrimer();
        ID jobID = Database.executeBatch(dataprimerTest, 100);

        Test.stopTest();

        Integer resultingCase = [Select COUNT() FROM Case Where ParentId <> null AND Parent.IETRS_Is_Parent_Case__c = true];
        System.assertEquals(1, resultingCase);
    }

}