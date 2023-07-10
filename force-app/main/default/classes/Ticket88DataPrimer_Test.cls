@isTest 
private class Ticket88DataPrimer_Test {
    @TestSetup
    static void makeData(){
        RecordType orgRT = new RecordType();
        orgRT = [SELECT Id FROM RecordType WHERE Name = 'Organization' Limit 1][0];
        Account testAccount1 = new Account(name = 'testAccount1', RecordTypeId = orgRT.Id);
        insert testAccount1;
        
        RecordType unitRT = new RecordType();
        unitRT = [SELECT Id FROM RecordType WHERE Name = 'Unit' Limit 1][0];
        Account testAccount2 = new Account(name = 'testAccount2', RecordTypeId = unitRT.Id, ParentId = testAccount1.Id);
        insert testAccount2;
        
        RecordType reRT = new RecordType();
        reRT = [SELECT Id FROM RecordType WHERE Name = 'Regulated Entity - PS' Limit 1][0];
        Account testAccount3 = new Account(name = 'testAccount3', 
                                           RecordTypeId = reRT.Id,
                                           ParentId = testAccount1.Id,
                                          IETRS_Entity_Code__c = 'Y-Company System (Non-Physical)',
                                          IETRS_Install_Year__c = '2022',
                                          Type = 'Distribution',
                                          IETRS_Entity_Sub_Type__c = 'Private Main System',
                                          IETRS_Total_Miles__c = 0.001,
                                          IETRS_On_Offshore__c = 'Onshore',
                                          IETRS_Product_Class__c = 'Gas',
                                          IETRS_Product_Sub_Class__c = 'Hydrogen',
                                          IETRS_T4_Permit__c = '1234');
        insert testAccount3;
    }
    
    static testMethod void validateRecordsUpdated() {
        
        Test.startTest();
        
        Ticket88DataPrimer dataprimerTest = new Ticket88DataPrimer();
        ID jobID = Database.executeBatch(dataprimerTest, 100);

        Test.stopTest();

        Integer resultingAccount = [Select COUNT() FROM Account Where IETRS_Entity_Code__c = 'Y-Company System (Non-Physical)' AND IETRS_Install_Year__c = '2022'];
        System.assertEquals(0, resultingAccount);
    }

}