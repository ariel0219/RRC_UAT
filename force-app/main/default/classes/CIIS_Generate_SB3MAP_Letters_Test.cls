@isTest

public class CIIS_Generate_SB3MAP_Letters_Test {
    
    @isTest
    public static void testMyBatchClass() {
    List<CIIS_Supply_Chain_Connection__c> testRecords = new List<CIIS_Supply_Chain_Connection__c>();
        for(Integer i = 0; i < 10; i++) {
        testRecords.add(new CIIS_Supply_Chain_Connection__c(CIIS_Named_Supplier_Organization__c = '001BZ00000B2BX7YAN', CIIS_Receiver__c = '001BZ00000BYj6ZYAT', CIIS_Supplier_Type__c = 'Gas Transmission Pipeline'));
        }
        insert testRecords;
        Test.StartTest();
        CIIS_Generate_SB3MAP_Letters batch = new CIIS_Generate_SB3MAP_Letters();
        Database.executeBatch(batch);
        Test.stopTest();
    }

}