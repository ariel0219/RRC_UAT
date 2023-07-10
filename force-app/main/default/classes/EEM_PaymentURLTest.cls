@IsTest
private class EEM_PaymentURLTest {
    @TestSetup
    static void makeData(){
        RecordType transactionRecordType = [Select Id From RecordType Where SObjectType = 'EEM_Transaction__c' And Name = 'RRC Events' Limit 1];        
        
        EEM_Transaction__c t = new EEM_Transaction__c(
            EEM_Fee_Codes__c = '06AF-8HOURCLS',
			EEM_Transaction_Amount__c = 75.00,
            RecordTypeId = transactionRecordType.Id
        );
        insert t;
    }

    @IsTest
    static void testPaymentURL(){
        List<Id> lstID = new List<Id>();
        EEM_Transaction__c t = [Select Id From EEM_Transaction__c Limit 1];
        lstID.add(t.Id);
        String strURL = EEM_PaymentURLController.getPaymentURLInvoc(lstID).get(0);
        System.debug(strURL);
        System.assertNotEquals('Error', strURL, 'Unexpected Error');
    }
}