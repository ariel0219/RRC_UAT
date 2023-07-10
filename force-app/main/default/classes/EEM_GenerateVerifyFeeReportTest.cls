@IsTest
private class EEM_GenerateVerifyFeeReportTest {
    @TestSetup
    static void makeData(){
        RecordType eventRecordType = [Select Id From RecordType Where SObjectType = 'EEM_Event__c' and Name='Class' Limit 1];        
        
        EEM_Event__c t = new EEM_Event__c(
		     EEM_Event_Title__c = 'Event Test',
            EEM_Fee_Code__c = '06AF-8HOURCLS',
			RecordTypeId = eventRecordType.Id
        );
        insert t;  
    }

    @IsTest
    static void testEEM_GenerateVerifyFeeReportTest(){
	   List<String> lstID = new List<String>();
        EEM_Event__c e = [Select Id From EEM_Event__c where eem_fee_code__c !=null order by Id desc Limit 1];
        lstID.add(e.Id);
		EEM_GenerateVerifyFeeReport.Requests curRequest = new EEM_GenerateVerifyFeeReport.Requests();
		curRequest.inputIds = lstID;
        List<EEM_GenerateVerifyFeeReport.Requests> curRequests = new List<EEM_GenerateVerifyFeeReport.Requests>();
        curRequests.add(curRequest);
        List<EEM_GenerateVerifyFeeReport.Results> curResponses = EEM_GenerateVerifyFeeReport.generateEEMReportVerify(curRequests);
        String strResponse = curResponses.get(0).reportString;
        System.debug('curResponses is:' + curResponses);
        System.assertNotEquals('Error', strResponse, 'Unexpected Error');


    }
}