@isTest
public class CIIS_PrepareMassUploadConfirmListTest {

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
        gscObject.CIIS_Supplier_Type__c='Pipeline Segment';
        gscObject.CIIS_Status__c='Pending';
        gscObject.CIIS_Named_Supplier_Organization__c = orgAcc.Id;
        Insert gscObject;
    }
    
    static testMethod void testConvertCSVToSupplyChain(){
        List<Account> listAccount=new List<Account>();
        String jsonString='{"CIIS_Supply_Chain_Facility_Type__c":"Pipeline","IETRS_P5_Number__c":"345678","IETRS_Account_ID__c":"567892"}';
        Account acc = (Account) JSON.deserialize(jsonString, Account.class);
        listAccount.add(acc);
		List<List<Account>> listOfListAccount = new List<List<Account>>();
        listOfListAccount.add(listAccount);
        CIIS_PrepareMassUploadConfirmList.convertCSVToSupplyChain(listOfListAccount);

    }
}