@isTest

public class CIIS_Generate_SB3MAP_Letters_Test {
    
    @isTest
    public static void testMyBatchClass() {
    List<CIIS_Supply_Chain_Connection__c> testRecords = new List<CIIS_Supply_Chain_Connection__c>();
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Account orgAcc = new Account(Name = 'Org', RecordTypeId = accOrgRecordTypeId, Type = 'Distribution');
        insert orgAcc;

        Id accRegulatedEntityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Account RegulatedEntity = new Account(Name = 'TG-400, 12" HIGH BTU RETURN GAS', RecordTypeId = accRegulatedEntityRecordTypeId, Type = 'Gas Transmission Pipeline');
        insert RegulatedEntity;
        
        for(Integer i = 0; i < 10; i++) {
        testRecords.add(new CIIS_Supply_Chain_Connection__c(CIIS_Named_Supplier_Organization__c = orgAcc.Id, CIIS_Receiver__c = orgAcc.Id, CIIS_Supplier_Type__c = 'Gas Transmission Pipeline', CIIS_Supplier__c = orgAcc.Id));
        }
        insert testRecords;
        Test.StartTest();
        CIIS_Generate_SB3MAP_Letters c = new CIIS_Generate_SB3MAP_Letters();
        Database.executeBatch(c);
        Test.stopTest();
    }

}