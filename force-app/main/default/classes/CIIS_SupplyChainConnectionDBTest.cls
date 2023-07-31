@isTest
public class CIIS_SupplyChainConnectionDBTest {
    @testSetup
    static void prepareData(){
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Account orgAcc = new Account(Name = 'Org', RecordTypeId = accOrgRecordTypeId, Type = 'Gas Transmission Pipeline');
        insert orgAcc;

        Id accRegulatedEntityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Account RegulatedEntity = new Account(Name = 'TG-400, 12" HIGH BTU RETURN GAS', RecordTypeId = accRegulatedEntityRecordTypeId, Type = 'Transmission');
        insert RegulatedEntity;
        
        
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IETRS_RRC_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName='Contact',LastName='Last', AccountId =orgAcc.Id ,RecordTypeId = conRecordTypeId);
        insert con;
        
        CIIS_Supply_Chain_Connection__c gscObject=new CIIS_Supply_Chain_Connection__c();            
        gscObject.CIIS_Receiver__c=orgAcc.Id;
        gscObject.CIIS_Supplier__c=RegulatedEntity.Id;
        gscObject.CIIS_Supplier_Type__c='Gas Transmission Pipeline';
        gscObject.CIIS_Status__c='Pending';
        gscObject.CIIS_Named_Supplier_Organization__c = orgAcc.ID;
        Insert gscObject;
        
    }
    
    static testMethod void testGetRecord(){
        CIIS_Supply_Chain_Connection__c gscObject = [Select Id From CIIS_Supply_Chain_Connection__c Limit 1];
        CIIS_SupplyChainConnectionDB.FlowInputs flowInput=new CIIS_SupplyChainConnectionDB.FlowInputs();
        flowInput.recordId=gscObject.Id;
        flowInput.columns='Id,CIIS_Receiver__c,CIIS_Supplier__c,CIIS_Supplier_Type__c,CIIS_Status__c';
        
        List<CIIS_SupplyChainConnectionDB.FlowInputs> listFlowInput=new List<CIIS_SupplyChainConnectionDB.FlowInputs>();
        listFlowInput.add(flowInput);
            
        List<CIIS_Supply_Chain_Connection__c> returnList = CIIS_SupplyChainConnectionDB.getRecord(listFlowInput);
        System.debug('returnList:'+returnList);
        //System.assertNotEquals(returnList.size(),1);
    }
    
    static testMethod void testGetRecordWithoutArgument(){
        try{
            List<CIIS_Supply_Chain_Connection__c> returnList = CIIS_SupplyChainConnectionDB.getRecord(null);
            System.debug('returnList:'+returnList);
        }catch(Exception e){
            System.debug('Exception:'+e);
        }
    }
    

}