/**
 * @File Name          : IETRS_PaymentControllerTest.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 4/8/2020, 3:22:55 PM
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      4/8/2020        Kevin Lu                Initial Version
**/
@IsTest
private class IETRS_PaymentControllerTest {
    private static final String OAUTH_TOKEN_BODY = '{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6WyJ0cnVzdGVkRXh0ZXJuYWwiXSwiZXhwIjoxNTg0MDQwMzgxLCJqdGkiOiI2NjdiMTg5Ny1jN2VhLTRhMDctYTRlZi01MDBmN2M2NzI0YzEiLCJjbGllbnRfaWQiOiJwYXltZW50UG9ydGFsRXh0ZXJuYWxDbGllbnQifQ.4SPw1u6LsbsNmvOuqtbs3obU93UEnRA3_KgOqmJENJU","token_type":"bearer","expires_in":1799,"scope":"trustedExternal","jti":"667b1897-c7ea-4a07-a4ef-500f7c6724c1"}';
    private static final String PAYMENT_RESULT_BODY = '{"clientApplicationId":"1","failureCode":"N","failureMessage":null,"feeCode":"LG-OPP","recordFailCode":null,"recordId":"12345","remitDisplayName":"12345","remitId":"786257","remitStatus":"IN FINANCE","token":"TEST_TOKEN","traceNumber":"455RM004ACR23KN"}';
    private static final String REMITTANCE_RESULT_BODY = '<?xml version="1.0" encoding="UTF-8"?><remitInfo><allocation><adjustmentTotal>0</adjustmentTotal><allocatedAmount>5000.0</allocatedAmount><allocationId>1180392</allocationId><allocationStatusCode>3</allocationStatusCode><benefactor>DEBORAH BAKER,9835 LIC RENEW</benefactor><createdBy>rmsEPay</createdBy><createdDate>2019-10-03T07:50:48.861-05:00</createdDate><feeCode>LP-CAT-P-REN</feeCode><feeId>886</feeId><modifiedBy>rmsEPay</modifiedBy><modifiedDate>2019-10-03T07:50:48.861-05:00</modifiedDate></allocation><allocation><adjustmentTotal>0</adjustmentTotal><allocatedAmount>138.0</allocatedAmount><allocationId>1180393</allocationId><allocationStatusCode>3</allocationStatusCode><benefactor>DEBORAH BAKER,9835 LIC RENEW</benefactor><createdBy>rmsEPay</createdBy><createdDate>2019-10-03T07:50:48.861-05:00</createdDate><feeCode>PP-CONV-FEE</feeCode><feeId>1006</feeId><modifiedBy>rmsEPay</modifiedBy><modifiedDate>2019-10-03T07:50:48.861-05:00</modifiedDate></allocation><amountAllocated>5138.0</amountAllocated><authCode>098383</authCode><controlGroupId>28050</controlGroupId><createdBy>rmsEPay</createdBy><createdDate>2019-10-03T07:50:48.861-05:00</createdDate><creditCardCode>1</creditCardCode><merchantIdCode>1</merchantIdCode><modifiedBy>rmsEPay</modifiedBy><modifiedDate>2019-10-03T07:51:27.251-05:00</modifiedDate><paymentMethodCode>4</paymentMethodCode><receiptAmount>5138.0</receiptAmount><receiptId>786259</receiptId><receivedDate>2019-10-03T07:51:25-05:00</receivedDate><registerNumber>200043</registerNumber><remitId>786257</remitId><remitStatusCode>4</remitStatusCode><remitterId>161595</remitterId><traceNumber>455RM004ACR23KN</traceNumber></remitInfo>';

    @TestSetup
    static void makeData() {
        Case c = new Case();
        insert c;
        List<IETRS_Transaction__c> transList = New List<IETRS_Transaction__c>();
        IETRS_Transaction__c t = new IETRS_Transaction__c(
            IETRS_Transaction_Amount__c = 51.38,
            IETRS_Fee_Code__c = 'LG-OPP',
            IETRS_Case__c = c.Id
        );
        transList.add(t);
        IETRS_Transaction__c t1 = new IETRS_Transaction__c(
            IETRS_Transaction_Amount__c = 51.38,
            IETRS_Fee_Code__c = 'SF-ANN-RPT',
            RRC_Fee_Codes__c = 'LG-OPP',
            Quantity__c = '10',
            IETRS_Case__c = c.Id
        );
        transList.add(t1);
        insert transList;
        System.debug('inserted Trans list: ' + transList);
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
        IETRS_Transaction__c transactionRecord = [SELECT Id FROM IETRS_Transaction__c WHERE IETRS_Fee_Code__c != null LIMIT 1];
        IETRS_PaymentController controller = new IETRS_PaymentController(transactionRecord.Id);
        String strURL = controller.getPaymentURL();
        controller.checkPaymentStatus();
        Test.stopTest();

        transactionRecord = [
            SELECT 
                Id
                ,IETRS_Record_ID__c
                ,IETRS_Remittance_ID__c
                ,IETRS_Texas_gov_Token__c
                ,IETRS_Trace_Number__c
                ,IETRS_Register_Number__c
                ,IETRS_Remittance_Status__c
                ,IETRS_Transaction_Amount__c
                ,IETRS_Payment_Method__c
                ,IETRS_RMS_Create_Date__c
                ,IETRS_Received_Date__c  
            FROM 
                IETRS_Transaction__c
            WHERE
                Id = :transactionRecord.Id
            LIMIT 1];
        System.assertEquals('12345', transactionRecord.IETRS_Record_ID__c, 'Record ID not updated');
        System.assertEquals('786257', transactionRecord.IETRS_Remittance_ID__c, 'Remittance ID not updated');
        System.assertEquals('TEST_TOKEN', transactionRecord.IETRS_Texas_gov_Token__c, 'Texas.gov Token not updated');
        System.assertEquals('455RM004ACR23KN', transactionRecord.IETRS_Trace_Number__c, 'Trace Number not updated');
        System.assertEquals('200043', transactionRecord.IETRS_Register_Number__c, 'Register Number not updated');
        System.assertEquals('In Finance', transactionRecord.IETRS_Remittance_Status__c, 'Status not updated');
        System.assertEquals(51.38, transactionRecord.IETRS_Transaction_Amount__c, 'Amount incorrect');
        System.assertEquals('Credit Card', transactionRecord.IETRS_Payment_Method__c, 'Payment Method not updated');
    }
    
    @IsTest
    static void testPaymentStatusWithRRCcode() {
        List<PaymentPortalMockCallout.MockResponse> lstMockReponses = new List<PaymentPortalMockCallout.MockResponse>();
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(OAUTH_TOKEN_BODY, 'OK', 200));
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(PAYMENT_RESULT_BODY, 'OK', 200));
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(OAUTH_TOKEN_BODY, 'OK', 200));
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(REMITTANCE_RESULT_BODY, 'OK', 200));
        Test.setMock(HttpCalloutMock.class, new PaymentPortalMockCallout(lstMockReponses));

        Test.startTest();
        IETRS_Transaction__c transactionRecord = [SELECT Id FROM IETRS_Transaction__c WHERE IETRS_Fee_Code__c != 'LG-OPP' LIMIT 1];
        IETRS_PaymentController controller = new IETRS_PaymentController(transactionRecord.Id);
        String strURL = controller.getPaymentURL();
        controller.checkPaymentStatus();
        Test.stopTest();

        transactionRecord = [
            SELECT 
                Id
                ,IETRS_Record_ID__c
                ,IETRS_Remittance_ID__c
                ,IETRS_Texas_gov_Token__c
                ,IETRS_Trace_Number__c
                ,IETRS_Register_Number__c
                ,IETRS_Remittance_Status__c
                ,IETRS_Transaction_Amount__c
                ,IETRS_Payment_Method__c
                ,IETRS_RMS_Create_Date__c
                ,IETRS_Received_Date__c  
            FROM 
                IETRS_Transaction__c
            WHERE
                Id = :transactionRecord.Id
            LIMIT 1];
        System.assertEquals('12345', transactionRecord.IETRS_Record_ID__c, 'Record ID not updated');
        System.assertEquals('786257', transactionRecord.IETRS_Remittance_ID__c, 'Remittance ID not updated');
        System.assertEquals('TEST_TOKEN', transactionRecord.IETRS_Texas_gov_Token__c, 'Texas.gov Token not updated');
        System.assertEquals('455RM004ACR23KN', transactionRecord.IETRS_Trace_Number__c, 'Trace Number not updated');
        System.assertEquals('200043', transactionRecord.IETRS_Register_Number__c, 'Register Number not updated');
        System.assertEquals('In Finance', transactionRecord.IETRS_Remittance_Status__c, 'Status not updated');
        System.assertEquals(51.38, transactionRecord.IETRS_Transaction_Amount__c, 'Amount incorrect');
        System.assertEquals('Credit Card', transactionRecord.IETRS_Payment_Method__c, 'Payment Method not updated');
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
        IETRS_Transaction__c transactionRecord = [SELECT Id FROM IETRS_Transaction__c LIMIT 1];
        List<Id> lstID = new List<Id>();
        lstID.add(transactionRecord.Id);
        IETRS_PaymentController.checkPaymentStatusInvoc(lstId);
        Test.stopTest();

        transactionRecord = [
            SELECT 
                Id
                ,IETRS_Record_ID__c
                ,IETRS_Remittance_ID__c
                ,IETRS_Texas_gov_Token__c
                ,IETRS_Trace_Number__c
                ,IETRS_Register_Number__c
                ,IETRS_Remittance_Status__c
                ,IETRS_Transaction_Amount__c
                ,IETRS_Payment_Method__c
                ,IETRS_RMS_Create_Date__c
                ,IETRS_Received_Date__c  
            FROM 
                IETRS_Transaction__c
            WHERE
                Id = :transactionRecord.Id
            LIMIT 1];
        System.assertEquals('12345', transactionRecord.IETRS_Record_ID__c, 'Record ID not updated');
        System.assertEquals('786257', transactionRecord.IETRS_Remittance_ID__c, 'Remittance ID not updated');
        System.assertEquals('TEST_TOKEN', transactionRecord.IETRS_Texas_gov_Token__c, 'Texas.gov Token not updated');
        System.assertEquals('455RM004ACR23KN', transactionRecord.IETRS_Trace_Number__c, 'Trace Number not updated');
        System.assertEquals('200043', transactionRecord.IETRS_Register_Number__c, 'Register Number not updated');
        System.assertEquals('In Finance', transactionRecord.IETRS_Remittance_Status__c, 'Status not updated');
        System.assertEquals(51.38, transactionRecord.IETRS_Transaction_Amount__c, 'Amount incorrect');
        System.assertEquals('Credit Card', transactionRecord.IETRS_Payment_Method__c, 'Payment Method not updated');
    }

    @IsTest
    static void testPaymentCheckSchedule(){
        List<PaymentPortalMockCallout.MockResponse> lstMockReponses = new List<PaymentPortalMockCallout.MockResponse>();
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(OAUTH_TOKEN_BODY, 'OK', 200));
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(PAYMENT_RESULT_BODY, 'OK', 200));
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(OAUTH_TOKEN_BODY, 'OK', 200));
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(REMITTANCE_RESULT_BODY, 'OK', 200));
        Test.setMock(HttpCalloutMock.class, new PaymentPortalMockCallout(lstMockReponses));

        Test.startTest();
        IETRS_PaymentCheckScheduled s = new IETRS_PaymentCheckScheduled();
        System.schedule('Twice-daily RRC Payment Portal Transaction Status Check', IETRS_PaymentCheckScheduled.CRON_EXP, s);
        s.execute(null);
        Test.stopTest();
        
        IETRS_Transaction__c transactionRecord = [
            SELECT 
                Id
                ,IETRS_Record_ID__c
                ,IETRS_Remittance_ID__c
                ,IETRS_Texas_gov_Token__c
                ,IETRS_Trace_Number__c
                ,IETRS_Register_Number__c
                ,IETRS_Remittance_Status__c
                ,IETRS_Transaction_Amount__c
                ,IETRS_Payment_Method__c
                ,IETRS_RMS_Create_Date__c
                ,IETRS_Received_Date__c  
            FROM 
                IETRS_Transaction__c
            LIMIT 1];
        System.assertEquals('12345', transactionRecord.IETRS_Record_ID__c, 'Record ID not updated');
        System.assertEquals('786257', transactionRecord.IETRS_Remittance_ID__c, 'Remittance ID not updated');
        System.assertEquals('TEST_TOKEN', transactionRecord.IETRS_Texas_gov_Token__c, 'Texas.gov Token not updated');
        System.assertEquals('455RM004ACR23KN', transactionRecord.IETRS_Trace_Number__c, 'Trace Number not updated');
        System.assertEquals('200043', transactionRecord.IETRS_Register_Number__c, 'Register Number not updated');
        System.assertEquals('In Finance', transactionRecord.IETRS_Remittance_Status__c, 'Status not updated');
        System.assertEquals(51.38, transactionRecord.IETRS_Transaction_Amount__c, 'Amount incorrect');
        System.assertEquals('Credit Card', transactionRecord.IETRS_Payment_Method__c, 'Payment Method not updated');
    }
}