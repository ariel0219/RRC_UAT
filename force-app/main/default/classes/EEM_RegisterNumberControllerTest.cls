@IsTest
public class EEM_RegisterNumberControllerTest {
    private static final String OAUTH_TOKEN_BODY = '{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6WyJ0cnVzdGVkRXh0ZXJuYWwiXSwiZXhwIjoxNTg0MDQwMzgxLCJqdGkiOiI2NjdiMTg5Ny1jN2VhLTRhMDctYTRlZi01MDBmN2M2NzI0YzEiLCJjbGllbnRfaWQiOiJwYXltZW50UG9ydGFsRXh0ZXJuYWxDbGllbnQifQ.4SPw1u6LsbsNmvOuqtbs3obU93UEnRA3_KgOqmJENJU","token_type":"bearer","expires_in":1799,"scope":"trustedExternal","jti":"667b1897-c7ea-4a07-a4ef-500f7c6724c1"}';
    private static final String REMITTANCE_RESULT_BODY = '<?xml version="1.0" encoding="UTF-8"?><remitInfo><allocation><adjustmentTotal>0</adjustmentTotal><allocatedAmount>1000.0</allocatedAmount><allocationId>732887</allocationId><allocationStatusCode>3</allocationStatusCode><benefactor>Joshua Brian,Red Hawk Midstream,</benefactor><createdBy>rmsEPay</createdBy><createdDate>2015-10-26T09:51:44.523-05:00</createdDate><feeCode>AF-LPG-TRANS</feeCode><feeId>993</feeId><modifiedBy>rmsEPay</modifiedBy><modifiedDate>2015-10-26T09:51:44.523-05:00</modifiedDate></allocation><allocation><adjustmentTotal>0</adjustmentTotal><allocatedAmount>48.0</allocatedAmount><allocationId>732886</allocationId><allocationStatusCode>3</allocationStatusCode><benefactor>Joshua Brian,Red Hawk Midstream,</benefactor><createdBy>rmsEPay</createdBy><createdDate>2015-10-26T09:51:44.523-05:00</createdDate><feeCode>PP-CONV-FEE</feeCode><feeId>1006</feeId><modifiedBy>rmsEPay</modifiedBy><modifiedDate>2015-10-26T09:51:44.523-05:00</modifiedDate></allocation><amountAllocated>1048.0</amountAllocated><authCode>067274</authCode><controlGroupId>20428</controlGroupId><createdBy>rmsEPay</createdBy><createdDate>2015-10-26T09:51:44.523-05:00</createdDate><creditCardCode>2</creditCardCode><merchantIdCode>1</merchantIdCode><modifiedBy>rmsEPay</modifiedBy><modifiedDate>2015-10-26T09:52:26.423-05:00</modifiedDate><paymentMethodCode>4</paymentMethodCode><receiptAmount>1048.0</receiptAmount><receiptId>520803</receiptId><receivedDate>2015-10-26T09:52:24-05:00</receivedDate><registerNumber>22116</registerNumber><remitId>520802</remitId><remitStatusCode>4</remitStatusCode><remitterId>134209</remitterId><traceNumber>455RM000H2C1OFH</traceNumber></remitInfo>';
    
    @TestSetup
    static void makeData(){
    }

    @IsTest
    static void testEEM_RegisterNumberControllerTest(){
		String strResponse = EEM_RegisterNumberController.checkRegisterNumber('221162');
        System.assertNotEquals('Error', strResponse, 'Unexpected Error');
    }
	
  @IsTest
    public static void testRemittanceResults() {
        List<PaymentPortalMockCallout.MockResponse> lstMockReponses = new List<PaymentPortalMockCallout.MockResponse>();
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(OAUTH_TOKEN_BODY, 'OK', 200));
        lstMockReponses.add(new PaymentPortalMockCallout.MockResponse(REMITTANCE_RESULT_BODY, 'OK', 200));
        
        System.Test.setMock(HttpCalloutMock.class, new PaymentPortalMockCallout(lstMockReponses));

        System.Test.startTest();
        EEM_RegisterNumberController registContrl = new EEM_RegisterNumberController();
        PaymentRemittanceResults results = registContrl.getRemittanceResults('22116');
        System.Test.stopTest();

        System.assertEquals(10.48, results.receiptAmount, 'Amount mismatch');
        System.assertEquals('520802', results.remittanceId, 'Remittance Id mismatch');
        System.assertEquals('134209', results.remitterId, 'Remitter Id mismatch');
        System.assertEquals(Datetime.newInstance(2015, 10, 26, 9, 51, 44), results.createdDate, 'Created Date mismatch');
    }  
  
}