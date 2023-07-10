@isTest 
private class Ticket61DatePrimer_Test {
    
    @TestSetup
    static void makeData(){
        RecordType unitRT = new RecordType();
        unitRT = [SELECT Id FROM RecordType WHERE Name = 'Unit' Limit 1][0];
        Account testAccount1 = new Account(name = 'testAccount1', RecordTypeId = unitRT.Id);
        insert testAccount1;

        list<IETRS_Inspection_Package__c> ipList = new List <IETRS_Inspection_Package__c>();
        IETRS_Inspection_Package__c testIP1 = new IETRS_Inspection_Package__c(
            IETRS_Unit_Name__c = testAccount1.Id, 
            IETRS_Inspection_Type__c = 'Specialized', 
            IETRS_Inspection_Sub_Type__c = 'DIMP'
        );
        ipList.add(testIP1);

        IETRS_Inspection_Package__c testIP2 = new IETRS_Inspection_Package__c(
            IETRS_Unit_Name__c = testAccount1.Id, 
            IETRS_Inspection_Type__c = 'Specialized', 
            IETRS_Inspection_Sub_Type__c = 'Gas Control Room'
        );
        ipList.add(testIP2);

        IETRS_Inspection_Package__c testIP3 = new IETRS_Inspection_Package__c(
            IETRS_Unit_Name__c = testAccount1.Id, 
            IETRS_Inspection_Type__c = 'Specialized', 
            IETRS_Inspection_Sub_Type__c = 'Gas Damage Prevention Activities'
        );
        ipList.add(testIP3);

        insert ipList;
    }
    static testMethod void validateUnitOpenSubtypesUpdated() {
        
        String initialUnitOpenSubtypes = [SELECT IETRS_Open_Inspection_SubTypes__c FROM Account LIMIT 1][0].IETRS_Open_Inspection_SubTypes__c;
        System.assertEquals(null, initialUnitOpenSubtypes);
        
        Test.startTest();

        Ticket61DataPrimer dataprimerTest = new Ticket61DataPrimer();
        ID jobID = Database.executeBatch(dataprimerTest, 200);

        Test.stopTest();

        String resultingUnitOpenSubtypes = [SELECT IETRS_Open_Inspection_SubTypes__c FROM Account LIMIT 1][0].IETRS_Open_Inspection_SubTypes__c;
        System.assertNotEquals(resultingUnitOpenSubtypes, initialUnitOpenSubtypes);
        System.assertEquals('DIMP;Gas Control Room;Gas Damage Prevention Activities', resultingUnitOpenSubtypes);
    }
}