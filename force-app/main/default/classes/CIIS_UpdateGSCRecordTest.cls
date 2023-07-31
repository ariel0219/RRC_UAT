@isTest
public class CIIS_UpdateGSCRecordTest {

    @testSetup
    static void prepareData(){
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Account orgAcc = new Account(IETRS_P5_Number__c='345678',Name = 'Org', RecordTypeId = accOrgRecordTypeId, Type = 'Distribution');
        insert orgAcc;

        Id accRegulatedEntityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Account RegulatedEntity = new Account(IETRS_P5_Number__c='123456',Name = 'TG-400, 12" HIGH BTU RETURN GAS', RecordTypeId = accRegulatedEntityRecordTypeId, Type = 'Transmission');
        insert RegulatedEntity;
        
        
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IETRS_RRC_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName='Contact',LastName='Last', AccountId =orgAcc.Id ,RecordTypeId = conRecordTypeId);
        insert con;
        
        CIIS_Supply_Chain_Connection__c gscObject=new CIIS_Supply_Chain_Connection__c();            
        gscObject.CIIS_Receiver__c=orgAcc.Id;
        gscObject.CIIS_Supplier__c=RegulatedEntity.Id;
        gscObject.CIIS_Supplier_Type__c='Gas Transmission Pipeline';
        gscObject.CIIS_Status__c='Pending';
        gscObject.CIIS_Named_Supplier_Organization__c = orgAcc.Id;
        Insert gscObject;
    }
    
    static testMethod void testGetRecord(){
        CIIS_Supply_Chain_Connection__c gscObject=[
            Select Id,CIIS_Status__c From CIIS_Supply_Chain_Connection__c LIMIT 1 
        ];
        List<CIIS_UpdateGSCRecord.FlowInputs> flowInputList=new List<CIIS_UpdateGSCRecord.FlowInputs>();
        CIIS_UpdateGSCRecord.FlowInputs flowInput=new CIIS_UpdateGSCRecord.FlowInputs();
        flowInput.status='Pending';
        flowInput.recordId=gscObject.Id;
        flowInputList.add(flowInput);
        CIIS_UpdateGSCRecord.getRecord(flowInputList);
    }
    
    static testMethod void testGetRecord2(){
        try{
            List<CIIS_UpdateGSCRecord.FlowInputs> flowInputList=new List<CIIS_UpdateGSCRecord.FlowInputs>();
            CIIS_UpdateGSCRecord.FlowInputs flowInput=new CIIS_UpdateGSCRecord.FlowInputs();
            flowInput.status='ABC';
            flowInput.recordId='5466626262';
            flowInputList.add(flowInput);
            CIIS_UpdateGSCRecord.getRecord(flowInputList);
        }catch(Exception e){
        }
    }
    static testMethod void testGetRecord3(){
        try{
            CIIS_UpdateGSCRecord.getRecord(NULL);
        }catch(Exception e){
        }
    }
    
    
}