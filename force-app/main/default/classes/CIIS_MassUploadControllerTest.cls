@isTest
public class CIIS_MassUploadControllerTest {
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
        gscObject.CIIS_Supplier_Type__c='Pipeline';
        gscObject.CIIS_Status__c='Pending';
        Insert gscObject;
    }
    
    static testMethod void testGetRecord(){
        Account operator = [Select Id From Account Where Name='Org' LIMIT 1];
        String operatorId=operator.Id;
        List<Account> listAccount=new List<Account>();
        String jsonString='{"CIIS_Supply_Chain_Facility_Type__c":"Pipeline","IETRS_P5_Number__c":"345678","IETRS_Account_ID__c":"567892"}';
        Account acc = (Account) JSON.deserialize(jsonString, Account.class);
		/*
        Account acc=new Account();
        acc.CIIS_Supply_Chain_Facility_Type__c='Pipeline';
        acc.IETRS_Account_ID__c='567892';
        acc.IETRS_P5_Number__c='345678';
		*/
        listAccount.add(acc);
        List<Account> listAccountRecords=CIIS_MassUploadController.validateMassUploadData(operatorId, listAccount);
        System.debug('listAccountRecords:'+listAccountRecords);
		List<List<Account>> listOfListAccount = new List<List<Account>>();
        listOfListAccount.add(listAccount);
        CIIS_PrepareMassUploadConfirmList.convertCSVToSupplyChain(listOfListAccount);

    }
    
    static testMethod void testGetSupplyChainConnections(){
        List<Account> listAccount = [Select Id From Account];
        CIIS_Supply_Chain_Connection__c gscObject=new CIIS_Supply_Chain_Connection__c();
        if(listAccount.size()>1){
            Account acc1=listAccount.get(0);
            Account acc2=listAccount.get(1);
            gscObject.CIIS_Receiver__c=acc1.Id;
            gscObject.CIIS_Supplier__c=acc2.Id;
        }
        List<CIIS_Supply_Chain_Connection__c> listGsc=new List<CIIS_Supply_Chain_Connection__c>();
        listGsc.add(gscObject);
        List<CIIS_SupplyChainConnectionWrapper> listGscWrapper=CIIS_MassUploadController.getSupplyChainConnections(listGsc);
        System.debug('listGscWrapper:'+listGscWrapper);
    }

}