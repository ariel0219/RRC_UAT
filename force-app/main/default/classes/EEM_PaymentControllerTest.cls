@IsTest
private class EEM_PaymentControllerTest {
    private static final String OAUTH_TOKEN_BODY = '{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6WyJ0cnVzdGVkRXh0ZXJuYWwiXSwiZXhwIjoxNjQyNTExNzcwLCJqdGkiOiIxYWM4ODIwMi1lODVkLTQxNzAtYmZiOC03YTcyYTJlMzA0Y2UiLCJjbGllbnRfaWQiOiJjYW5vblB5bXRwRXh0ZXJuYWxDbGllbnQifQ.YeAKvpBf6ClCuzZPFvFXL5QWf9ILVMPLo6SJP_4gQxU","token_type":"bearer","expires_in":1799,"scope":"trustedExternal","jti":"667b1897-c7ea-4a07-a4ef-500f7c6724c1"}';
    private static final String PAYMENT_RESULT_BODY = '{"clientApplicationId":"1","failureCode":"N","failureMessage":null,"feeCode":"07AF-CAT-FGIJ","recordFailCode":null,"recordId":"12345","remitDisplayName":"12345","remitId":"906704","remitStatus":"IN FINANCE","token":"TEST_TOKEN","traceNumber":"455RM006N9H5T70"}';
    private static final String REMITTANCE_RESULT_BODY = '<?xml version="1.0" encoding="UTF-8"?><remitInfo><allocation><adjustmentTotal>0</adjustmentTotal><allocatedAmount>7000.0</allocatedAmount><allocationId>1403483</allocationId><allocationStatusCode>3</allocationStatusCode><benefactor>KEVIN TAYLOR,JKT GROUP LLC</benefactor><createdBy>rmsEPay</createdBy><createdDate>2021-09-27T13:21:43.111-05:00</createdDate><feeCode>10AF-LPG-EX-MGR</feeCode><feeId>1211</feeId><modifiedBy>rmsEPay</modifiedBy><modifiedDate>2021-09-27T13:21:43.111-05:00</modifiedDate></allocation><allocation><adjustmentTotal>0</adjustmentTotal><allocatedAmount>15000.0</allocatedAmount><allocationId>1403482</allocationId><allocationStatusCode>3</allocationStatusCode><benefactor>KEVIN TAYLOR,JKT GROUP LLC</benefactor><createdBy>rmsEPay</createdBy><createdDate>2021-09-27T13:21:43.111-05:00</createdDate><feeCode>07AF-CAT-FGIJ</feeCode><feeId>1209</feeId><modifiedBy>rmsEPay</modifiedBy><modifiedDate>2021-09-27T13:21:43.111-05:00</modifiedDate></allocation><allocation><adjustmentTotal>0</adjustmentTotal><allocatedAmount>521.0</allocatedAmount><allocationId>1403481</allocationId><allocationStatusCode>3</allocationStatusCode><benefactor>KEVIN TAYLOR,JKT GROUP LLC</benefactor><createdBy>rmsEPay</createdBy><createdDate>2021-09-27T13:21:43.111-05:00</createdDate><feeCode>PP-CONV-FEE</feeCode><feeId>1006</feeId><modifiedBy>rmsEPay</modifiedBy><modifiedDate>2021-09-27T13:21:43.111-05:00</modifiedDate></allocation><amountAllocated>22521.0</amountAllocated><authCode>027092</authCode><controlGroupId>30781</controlGroupId><createdBy>rmsEPay</createdBy><createdDate>2021-09-27T13:21:43.111-05:00</createdDate><creditCardCode>1</creditCardCode><merchantIdCode>1</merchantIdCode><modifiedBy>rmsEPay</modifiedBy><modifiedDate>2021-09-27T13:26:30.935-05:00</modifiedDate><paymentMethodCode>4</paymentMethodCode><receiptAmount>22521.0</receiptAmount><receiptId>906707</receiptId><receivedDate>2021-09-27T13:26:29-05:00</receivedDate><registerNumber>310085</registerNumber><remitId>906704</remitId><remitStatusCode>4</remitStatusCode><remitterId>245350</remitterId><traceNumber>455RM006N9H5T70</traceNumber></remitInfo>';

    @TestSetup
    static void makeData() {
       
        EEM_Transaction__c t = new EEM_Transaction__c(
            EEM_Transaction_Amount__c = 225.21,
            EEM_Fee_Codes__c = '07AF-CAT-FGIJ;10AF-LPG-EX-MGR'
            
        );
        insert t;
    }

    @IsTest
    static void testPaymentStatus() {
        List<PaymentPortalMockCallout.MockResponse> lstMockReponses = new List<PaymentPortalMockCallout.MockResponse>();
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(OAUTH_TOKEN_BODY, 'OK', 200));
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(PAYMENT_RESULT_BODY, 'OK', 200));
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(OAUTH_TOKEN_BODY, 'OK', 200));
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(REMITTANCE_RESULT_BODY, 'OK', 200));
        Test.setMock(HttpCalloutMock.class, new PaymentPortalMockCallout(lstMockReponses));

        Test.startTest();
        EEM_Transaction__c transactionRecord = [SELECT Id FROM EEM_Transaction__c LIMIT 1];
        EEM_PaymentController controller = new EEM_PaymentController(transactionRecord.Id);
        String strURL = controller.getPaymentURL();
        controller.checkPaymentStatus();
        Test.stopTest();

        transactionRecord = [
            SELECT 
                Id
                ,EEM_Record_ID__c
                ,EEM_Remittance_ID__c
                ,EEM_Texas_gov_Token__c
                ,EEM_Trace_Number__c
                ,EEM_Register_Number__c
                ,EEM_Remittance_Status__c
                ,EEM_Transaction_Amount__c
                ,EEM_Payment_Method__c
                ,EEM_RMS_Create_Date__c
                ,EEM_Received_Date__c  
            FROM 
                EEM_Transaction__c
            WHERE
                Id = :transactionRecord.Id
            LIMIT 1];
        System.assertEquals('12345', transactionRecord.EEM_Record_ID__c, 'Record ID not updated');
        System.assertEquals('906704', transactionRecord.EEM_Remittance_ID__c, 'Remittance ID not updated');
        System.assertEquals('TEST_TOKEN', transactionRecord.EEM_Texas_gov_Token__c, 'Texas.gov Token not updated');
        System.assertEquals('455RM006N9H5T70', transactionRecord.EEM_Trace_Number__c, 'Trace Number not updated');
        System.assertEquals('310085', transactionRecord.EEM_Register_Number__c, 'Register Number not updated');
        System.assertEquals('In Finance', transactionRecord.EEM_Remittance_Status__c, 'Status not updated');
        System.assertEquals(225.21, transactionRecord.EEM_Transaction_Amount__c, 'Amount incorrect');
        System.assertEquals('Credit Card', transactionRecord.EEM_Payment_Method__c, 'Payment Method not updated');
    }

    @IsTest
    static void testPaymentStatusInvoc(){
        List<PaymentPortalMockCallout.MockResponse> lstMockReponses = new List<PaymentPortalMockCallout.MockResponse>();
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(OAUTH_TOKEN_BODY, 'OK', 200));
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(PAYMENT_RESULT_BODY, 'OK', 200));
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(OAUTH_TOKEN_BODY, 'OK', 200));
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(REMITTANCE_RESULT_BODY, 'OK', 200));
        Test.setMock(HttpCalloutMock.class, new PaymentPortalMockCallout(lstMockReponses));

        Test.startTest();
        EEM_Transaction__c transactionRecord = [SELECT Id FROM EEM_Transaction__c LIMIT 1];
        List<Id> lstID = new List<Id>();
        lstID.add(transactionRecord.Id);
        EEM_PaymentController.checkPaymentStatusInvoc(lstId);
        Test.stopTest();

        transactionRecord = [
            SELECT 
                Id
                ,EEM_Record_ID__c
                ,EEM_Remittance_ID__c
                ,EEM_Texas_gov_Token__c
                ,EEM_Trace_Number__c
                ,EEM_Register_Number__c
                ,EEM_Remittance_Status__c
                ,EEM_Transaction_Amount__c
                ,EEM_Payment_Method__c
                ,EEM_RMS_Create_Date__c
                ,EEM_Received_Date__c  
            FROM 
                EEM_Transaction__c
            WHERE
                Id = :transactionRecord.Id
            LIMIT 1];
        System.assertEquals('12345', transactionRecord.EEM_Record_ID__c, 'Record ID not updated');
        System.assertEquals('906704', transactionRecord.EEM_Remittance_ID__c, 'Remittance ID not updated');
        System.assertEquals('TEST_TOKEN', transactionRecord.EEM_Texas_gov_Token__c, 'Texas.gov Token not updated');
        System.assertEquals('455RM006N9H5T70', transactionRecord.EEM_Trace_Number__c, 'Trace Number not updated');
        System.assertEquals('310085', transactionRecord.EEM_Register_Number__c, 'Register Number not updated');
        System.assertEquals('In Finance', transactionRecord.EEM_Remittance_Status__c, 'Status not updated');
        System.assertEquals(225.21, transactionRecord.EEM_Transaction_Amount__c, 'Amount incorrect');
        System.assertEquals('Credit Card', transactionRecord.EEM_Payment_Method__c, 'Payment Method not updated');
    }

    
}