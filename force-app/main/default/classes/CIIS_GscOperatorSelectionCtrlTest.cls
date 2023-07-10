@isTest 
public class CIIS_GscOperatorSelectionCtrlTest {
    @testSetup
    static void prepareData(){
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Account orgAcc = new Account(Name = 'Org', RecordTypeId = accOrgRecordTypeId, Type = 'Distribution');
        insert orgAcc;

        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IETRS_RRC_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName='Contact',LastName='Last', AccountId =orgAcc.Id ,RecordTypeId = conRecordTypeId);
        insert con;
    }
    static testMethod void testOperatorList(){
        List<Account> operatorList = CIIS_GscOperatorSelectionCtrl.getOperatorList();
        System.debug('operatorList:'+operatorList);
    }

}