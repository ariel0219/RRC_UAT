public class EEM_GenerateVerifyFeeReport {
    private static String tableStyleString;
    private static String headerStyleString;
    private static String rowStyleString;
    private static String reportStr;
    private static String feeCode;
    private static String label;
    private static String eventTitle;
    private static String feeAmount;
    private static String tableHTML;
    private static String queryEventIds;
    private static String queryFeeCode;
    private static String varQ3ICIANDCE ='false';
    private static String varEemExamFee;
    private static String varFeeAmount = '$0.00';
    private Static Date currentDate = System.today();
    private Static Date lateBirdBeginDate;
    
   @InvocableMethod(label='EEM Generate Verify payment details' description='Given a collection of Event Ids, hydrate them into records' category='Util')
        public static List <Results> generateEEMReportVerify (List<Requests> requestList) {
            
         List <Results> responseWrapper = new List<Results>();   
		headerStyleString =  'background-color: #D3D3D3; color: black;';
		tableStyleString = 'width:500px; margin-left:10px';
		rowStyleString = 'background-color: #F5F5F5';
		reportStr = '';
        feeCode='';	  
        label='';
        eventTitle='';
        //feeAmount=''; 
         
        List<String> varReportFeeCodes = new List<String>();
            currentDate = System.today();
		   tableHTML = '<table style="' + tableStyleString + '">' ;
		   tableHTML += '<tr>';
		   tableHTML += '<th style="' + headerStyleString + '">' + 'Event Title' + '</th>';
		   tableHTML += '<th style="' + headerStyleString + '">' + 'Fee Description' + '</th>';
		   tableHTML += '<th style="' + headerStyleString + '">' + 'Fee Amount' + '</th>';
		   tableHTML += '</tr>';
		
      try{ 
        for (Requests curRequest : requestList) {
            String ids ='(';
                for(Integer i=0; i<curRequest.inputIds.size(); i++) {
                    ids = ids + '\'' + curRequest.inputIds[i] + '\'' + ',';
                }
                ids = ids.removeend(',') + ')';
              varQ3ICIANDCE = curRequest.inputQ3ICIANDCE; 
              varFeeAmount = curRequest.inputFeeAmount;
			 queryEventIds = 'SELECT EEM_Event_Title__c,EEM_Fee_Code__c,EEM_Class_Fee__c,EEM_Exam_Fee__C,EEM_Late_Bird_Fee_Code__c,EEM_Late_Bird_Fee_Begin_Date__c FROM EEM_Event__c WHERE id IN' + ids ;
			
            System.debug('hydrated varQ3ICIANDCE are: ' + varQ3ICIANDCE);
			System.debug('hydrated varFeeAmount are: ' + varFeeAmount);
            
            if(queryEventIds != null) {
           List<SObject> recordListEvent = Database.query(queryEventIds);
           		   
		   for(SObject recordEvent: recordListEvent){
            
            lateBirdBeginDate = null;
            lateBirdBeginDate = Date.valueOf(recordEvent.get('EEM_Late_Bird_Fee_Begin_Date__c'));
               
		   eventTitle=String.valueOf(recordEvent.get('EEM_Event_Title__c'));
		   feeCode = String.valueOf(recordEvent.get('EEM_Fee_Code__c'));
               if (lateBirdBeginDate !=null){
               if (lateBirdBeginDate <= currentDate) {
                  //System.debug('hydrated recordEvent EEM_Late_Bird_Fee_Begin_Date__c value are: ' + recordEvent.get('EEM_Late_Bird_Fee_Begin_Date__c')); 
                 //System.debug('hydrated recordEvent EEM_Late_Bird_Fee_Code__c value are: ' + recordEvent.get('EEM_Late_Bird_Fee_Code__c')); 
                  //System.debug('hydrated : '+ currentDate);
             feeCode = String.valueOf(recordEvent.get('EEM_Late_Bird_Fee_Code__c'));
             
               } 
           }
          /////////////////Fee code details /////////////////
          queryFeeCode = 'SELECT MasterLabel,Fee_Amount__c FROM EEM_Fee_Codes_Mapping__mdt WHERE Fee_Code__c ='+'\'' + feeCode+ '\'' ;
           
		   List<SObject> recordListFeeCode = Database.query(queryFeeCode);		 
		 for(SObject recordFeeCode: recordListFeeCode){
		  label = String.valueOf(recordFeeCode.get('MasterLabel'));
		  feeAmount = String.valueOf(recordFeeCode.get('Fee_Amount__c'));
		   
		   }  
               if(feeAmount!= null ){
                 feeAmount = '$'+ feeAmount; 
               }else{
                  feeAmount = '$0.00'; 
                  label = 'No Charge'; 
               }
               if(varQ3ICIANDCE !=null){
                   if(varQ3ICIANDCE == 'true'){
                    varEemExamFee = String.valueOf(recordEvent.get('EEM_Exam_Fee__C')); 
                        if(varEemExamFee == '0.00'){
                          System.debug('hydrated recordEvent eventTitle value are: ' + eventTitle);
                           System.debug('hydrated recordEvent Exam_Fee value are: ' + varEemExamFee);  
                          feeAmount = '$0.00'; 
                          label = 'No Charge'; 
                           
                        }else{
                          varReportFeeCodes.add(feeCode);  
                        } 
                   }   
               } 
               
             if(varFeeAmount!=null ){
                  feeAmount =  varFeeAmount;
                 varReportFeeCodes.add(feeCode);  
                 System.debug('hydrated set feeAmount to varFeeAmount : ' + feeAmount);
               }
               
           tableHTML += '<tr>';
		   tableHTML += '<td style="' + rowStyleString + '">' + eventTitle + '</td>';
		   tableHTML += '<td style="' + rowStyleString + '">' + label + '</td>';
		   tableHTML += '<td style="' + rowStyleString + '">' + feeAmount + '</td>';
		   tableHTML += '</tr>';    
               
           System.debug('Record: ' + eventTitle + ' - '+ label + ' - '+  feeAmount); 
                
		   }
           tableHTML += '</table>';     
           reportStr =   tableHTML;   
		   	System.debug('reportStr :'+ reportStr);	   
                } else {
                   System.debug('hydrated records are: null' );
              }
			
            
            
           Results response = new Results();
            response.reportString = reportStr;
            response.reportFeeCodes = varReportFeeCodes;
            responseWrapper.add(response);
            return responseWrapper;
        }
          
          
        return responseWrapper;
         }catch(System.NullPointerException e){
            //Handle exception
            System.debug('EEM generate Verify Fee Report >>>> ' + e.getMessage());
             return responseWrapper;
         }
                 
        }
    
    
    
        public class Requests {
		@InvocableVariable(description='Collection of Event Ids' required=true)
          public List<String> inputIds;
        
        @InvocableVariable
          public String inputQ3ICIANDCE;    
        
         @InvocableVariable
          public String inputFeeAmount;       
               
    }

    public class Results {

        @InvocableVariable
        public String reportString;
        
        @InvocableVariable
        public List<String> reportFeeCodes;

    }
    
    
}