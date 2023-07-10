@IsTest
public class PaymentRemittanceResultsTest {
    @IsTest
    public static void testParse(){
        String xml = '<?xml version="1.0" encoding="UTF-8"?><remitInfo><allocation><adjustmentTotal>0</adjustmentTotal><allocatedAmount>138.0</allocatedAmount><allocationId>1180393</allocationId><allocationStatusCode>3</allocationStatusCode><benefactor>DEBORAH BAKER,9835 LIC RENEW</benefactor><createdBy>rmsEPay</createdBy><createdDate>2019-10-03T07:50:48.861-05:00</createdDate><feeCode>PP-CONV-FEE</feeCode><feeId>1006</feeId><modifiedBy>rmsEPay</modifiedBy><modifiedDate>2019-10-03T07:50:48.861-05:00</modifiedDate></allocation><allocation><adjustmentTotal>0</adjustmentTotal><allocatedAmount>5000.0</allocatedAmount><allocationId>1180392</allocationId><allocationStatusCode>3</allocationStatusCode><benefactor>DEBORAH BAKER,9835 LIC RENEW</benefactor><createdBy>rmsEPay</createdBy><createdDate>2019-10-03T07:50:48.861-05:00</createdDate><feeCode>LP-CAT-P-REN</feeCode><feeId>886</feeId><modifiedBy>rmsEPay</modifiedBy><modifiedDate>2019-10-03T07:50:48.861-05:00</modifiedDate></allocation><amountAllocated>5138.0</amountAllocated><authCode>098383</authCode><controlGroupId>28050</controlGroupId><createdBy>rmsEPay</createdBy><createdDate>2019-10-03T07:50:48.861-05:00</createdDate><creditCardCode>1</creditCardCode><merchantIdCode>1</merchantIdCode><modifiedBy>rmsEPay</modifiedBy><modifiedDate>2019-10-03T07:51:27.251-05:00</modifiedDate><paymentMethodCode>4</paymentMethodCode><receiptAmount>5138.0</receiptAmount><receiptId>786259</receiptId><receivedDate>2019-10-03T07:51:25-05:00</receivedDate><registerNumber>200043</registerNumber><remitId>786257</remitId><remitStatusCode>4</remitStatusCode><remitterId>161595</remitterId><traceNumber>455RM004ACR23KN</traceNumber></remitInfo>';
        String xml_c ='<?xml version="1.0" encoding="UTF-8"?><remitInfo><allocation><adjustmentTotal>0</adjustmentTotal><allocatedAmount>30000.0</allocatedAmount><allocationId>1203</allocationId><allocationStatusCode>3</allocationStatusCode><benefactor>OWL CREEK PRODUCTION COMPANY., LLC</benefactor><createdBy>moralest</createdBy><createdDate>2006-09-05T09:57:25.095-05:00</createdDate><feeCode>P502</feeCode><feeId>194</feeId><modifiedBy>rmsbatch</modifiedBy><modifiedDate>2006-09-05T09:57:25.095-05:00</modifiedDate></allocation><amountAllocated>30000.0</amountAllocated><amountUnallocated>0.0</amountUnallocated><checkNumber>101379</checkNumber><controlGroupId>1023</controlGroupId><createdBy>nietor</createdBy><createdDate>2006-09-05T09:06:26.219-05:00</createdDate><isReplacementPayment>N</isReplacementPayment><modifiedBy>rmsbatch</modifiedBy><modifiedDate>2006-09-05T20:04:48.062-05:00</modifiedDate><paymentMethodCode>1</paymentMethodCode><receiptAmount>30000.0</receiptAmount><receiptId>1230</receiptId><receivedDate>2006-09-05T09:06:26.219-05:000</receivedDate><registerNumber>1000225</registerNumber><remitId>1230</remitId><remitStatusCode>4</remitStatusCode><remitterId>1206</remitterId></remitInfo>';
        String xml_cc ='<?xml version="1.0" encoding="UTF-8"?><remitInfo><allocation><adjustmentTotal>0</adjustmentTotal><allocatedAmount>30000.0</allocatedAmount><allocationId>1203</allocationId><allocationStatusCode>3</allocationStatusCode><benefactor>OWL CREEK PRODUCTION COMPANY., LLC</benefactor><createdBy>moralest</createdBy><createdDate>2006-09-05T09:57:25.095-05:00</createdDate><feeCode>P502</feeCode><feeId>194</feeId><modifiedBy>rmsbatch</modifiedBy><modifiedDate>2006-09-05T09:57:25.095-05:00</modifiedDate></allocation><amountAllocated>30000.0</amountAllocated><amountUnallocated>0.0</amountUnallocated><checkNumber>101379</checkNumber><controlGroupId>1023</controlGroupId><createdBy>nietor</createdBy><createdDate>2006-09-05T09:06:26.219-05:00</createdDate><isReplacementPayment>N</isReplacementPayment><modifiedBy>rmsbatch</modifiedBy><modifiedDate>2006-09-05T20:04:48.062-05:00</modifiedDate><paymentMethodCode>2</paymentMethodCode><receiptAmount>30000.0</receiptAmount><receiptId>1230</receiptId><receivedDate>2006-09-05T09:06:26.219-05:000</receivedDate><registerNumber>1000225</registerNumber><remitId>1230</remitId><remitStatusCode>3</remitStatusCode><remitterId>1206</remitterId></remitInfo>';
        String xml_p ='<?xml version="1.0" encoding="UTF-8"?><remitInfo><allocation><adjustmentTotal>0</adjustmentTotal><allocatedAmount>30000.0</allocatedAmount><allocationId>1203</allocationId><allocationStatusCode>3</allocationStatusCode><benefactor>OWL CREEK PRODUCTION COMPANY., LLC</benefactor><createdBy>moralest</createdBy><createdDate>2006-09-05T09:57:25.095-05:00</createdDate><feeCode>P502</feeCode><feeId>194</feeId><modifiedBy>rmsbatch</modifiedBy><modifiedDate>2006-09-05T09:57:25.095-05:00</modifiedDate></allocation><amountAllocated>30000.0</amountAllocated><amountUnallocated>0.0</amountUnallocated><checkNumber>101379</checkNumber><controlGroupId>1023</controlGroupId><createdBy>nietor</createdBy><createdDate>2006-09-05T09:06:26.219-05:00</createdDate><isReplacementPayment>N</isReplacementPayment><modifiedBy>rmsbatch</modifiedBy><modifiedDate>2006-09-05T20:04:48.062-05:00</modifiedDate><paymentMethodCode>3</paymentMethodCode><receiptAmount>30000.0</receiptAmount><receiptId>1230</receiptId><receivedDate>2006-09-05T09:06:26.219-05:000</receivedDate><registerNumber>1000225</registerNumber><remitId>1230</remitId><remitStatusCode>5</remitStatusCode><remitterId>1206</remitterId></remitInfo>';
        Dom.Document doc = new Dom.Document();
        doc.load(xml);
        Dom.Document docC = new Dom.Document();
        docC.load(xml_c); 
        Dom.Document docCc = new Dom.Document();
        docCc.load(xml_cc); 
        Dom.Document docp = new Dom.Document();
        docp.load(xml_p); 
        
        
        PaymentRemittanceResults result = new PaymentRemittanceResults(doc);

        System.assertEquals('200043', result.registerNumber, 'Register Number does not match');
        System.assertEquals('786257', result.remittanceId, 'Remittance Id does not match');
        System.assertEquals('161595', result.remitterId, 'Remitted Id does not match');
        System.assertEquals('In Finance', result.remittanceStatus, 'Remittance Status does not match');
        System.assertEquals(51.38, result.receiptAmount, 'Receipt Amount does not match');
        System.assertEquals('455RM004ACR23KN', result.traceNumber, 'Trace Number does not match');
        System.assertEquals('Credit Card', result.paymentMethod, 'Payment Method does not match');
        System.assertEquals(Datetime.newInstance(2019, 10, 3, 7, 50, 48), result.createdDate, 'Created Date does not match');
        System.assertEquals('rmsEPay', result.createdBy, 'Created By does not match');
        System.assertEquals(Datetime.newInstance(2019, 10, 3, 7, 51, 27), result.lastModifiedDate, 'Modified Date does not match');
        System.assertEquals('rmsEPay', result.lastModifiedBy, 'Modified By does not match');
        System.assertEquals(Datetime.newInstance(2019, 10, 3, 7, 51, 25), result.receivedDate, 'Received Date does not match');
    
        PaymentRemittanceResults resultC = new PaymentRemittanceResults(docC);
        System.assertEquals('1000225', resultC.registerNumber, 'Register Number does not match');
        System.assertEquals('1230', resultC.remittanceId, 'Remittance Id does not match');
        System.assertEquals('1206', resultC.remitterId, 'Remitted Id does not match');
        System.assertEquals('In Finance', resultC.remittanceStatus, 'Remittance Status does not match');
        System.assertEquals(300.00, resultC.receiptAmount, 'Receipt Amount does not match');
        System.assertEquals('101379', resultC.checkNumber, 'Check Number does not match');
        System.assertEquals('Check', resultC.paymentMethod, 'Payment Method does not match');
        System.assertEquals(Datetime.newInstance(2006, 9, 5, 9, 6, 26), resultC.createdDate, 'Created Date does not match');
        System.assertEquals('nietor', resultC.createdBy, 'Created By does not match');
        System.assertEquals(Datetime.newInstance(2006, 9, 5, 20, 4, 48), resultC.lastModifiedDate, 'Modified Date does not match');
        System.assertEquals('rmsbatch', resultC.lastModifiedBy, 'Modified By does not match');
        System.assertEquals(Datetime.newInstance(2006, 9, 5, 9, 6, 26), resultC.receivedDate, 'Received Date does not match');

        PaymentRemittanceResults resultCc = new PaymentRemittanceResults(docCc);
        System.assertEquals('1000225', resultCc.registerNumber, 'Register Number does not match');
        System.assertEquals('1230', resultCc.remittanceId, 'Remittance Id does not match');
        System.assertEquals('1206', resultCc.remitterId, 'Remitted Id does not match');
        System.assertEquals('Authorized', resultCc.remittanceStatus, 'Remittance Status does not match');
        System.assertEquals(300.00, resultCc.receiptAmount, 'Receipt Amount does not match');
        System.assertEquals('101379', resultCc.checkNumber, 'Check Number does not match');
        System.assertEquals('Cash', resultCc.paymentMethod, 'Payment Method does not match');
        System.assertEquals(Datetime.newInstance(2006, 9, 5, 9, 6, 26), resultCc.createdDate, 'Created Date does not match');
        System.assertEquals('nietor', resultCc.createdBy, 'Created By does not match');
        System.assertEquals(Datetime.newInstance(2006, 9, 5, 20, 4, 48), resultCc.lastModifiedDate, 'Modified Date does not match');
        System.assertEquals('rmsbatch', resultCc.lastModifiedBy, 'Modified By does not match');
        System.assertEquals(Datetime.newInstance(2006, 9, 5, 9, 6, 26), resultCc.receivedDate, 'Received Date does not match');

        PaymentRemittanceResults resultCcc = new PaymentRemittanceResults(docp);
        System.assertEquals('1000225', resultCcc.registerNumber, 'Register Number does not match');
        System.assertEquals('1230', resultCcc.remittanceId, 'Remittance Id does not match');
        System.assertEquals('1206', resultCcc.remitterId, 'Remitted Id does not match');
        System.assertEquals('Pending Adjustment', resultCcc.remittanceStatus, 'Remittance Status does not match');
        System.assertEquals(300.00, resultCcc.receiptAmount, 'Receipt Amount does not match');
        System.assertEquals('101379', resultCcc.checkNumber, 'Check Number does not match');
        System.assertEquals('Credit Card - POS', resultCcc.paymentMethod, 'Payment Method does not match');
        System.assertEquals(Datetime.newInstance(2006, 9, 5, 9, 6, 26), resultCcc.createdDate, 'Created Date does not match');
        System.assertEquals('nietor', resultCcc.createdBy, 'Created By does not match');
        System.assertEquals(Datetime.newInstance(2006, 9, 5, 20, 4, 48), resultCc.lastModifiedDate, 'Modified Date does not match');
        System.assertEquals('rmsbatch', resultCcc.lastModifiedBy, 'Modified By does not match');
        System.assertEquals(Datetime.newInstance(2006, 9, 5, 9, 6, 26), resultCcc.receivedDate, 'Received Date does not match');

        
    }
}