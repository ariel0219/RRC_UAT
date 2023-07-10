public without sharing class EEM_RegisterNumberController {
private static final String PAYMENT_PORTAL_REMITTANCE_URL = 'https://{0}/Payment/oauth/rest/remitInfo';
private static final String PAYMENT_PORTAL_OAUTH_URL = 'https://{0}/Payment/oauth/token';
private static final String HTTP_GET = 'GET';
private static final String HTTP_POST = 'POST';
private String strBaseURL;
private String strClientId;
private String strClientSecret;
private STring strEncryptionKey;
private String strAccessToken;
private static String tableHTML;    

    private static String tableStyleString;
    private static String headerStyleString;
    private static String rowStyleString;
    private static String reportStr;

/**
    * @description Retrieves remittance information from RMS
    * @param registerNumber The register Number of the payment
    * @return RMSRemittanceResults The remittance results from RMS
**/
    @AuraEnabled(cacheable = true)
    public static String checkRegisterNumber(String checkRegisterNbr){
        
       
        headerStyleString =  'background-color: #D3D3D3; color: black;';
		tableStyleString = 'width:500px; margin-left:10px';
		rowStyleString = 'background-color: #F5F5F5';
		reportStr = '';
         
        System.debug( ' TEST  checkRegisterNbr :  ' + checkRegisterNbr);
        
           tableHTML = '<table style=\"' + tableStyleString + '\">' ;
		   tableHTML += '<tr>';
		   tableHTML += '<th style=\"' + headerStyleString + '\">' + 'Register Number' + '</th>';
		   tableHTML += '<th style=\"' + headerStyleString + '\">' + 'Remittance Status' + '</th>';
		   tableHTML += '<th style=\"' + headerStyleString + '\">' + 'Transaction Amount' + '</th>';
           tableHTML += '<th style=\"' + headerStyleString + '\">' + 'Received Date' + '</th>';
           tableHTML += '<th style=\"' + headerStyleString + '\">' + 'Payment Method' + '</th>';
		  
       
        EEM_RegisterNumberController ctrl = new EEM_RegisterNumberController();
        PaymentRemittanceResults dispResult = ctrl.getRemittanceResults(checkRegisterNbr);
        
        if(dispResult != null){
       
            if(dispResult.checkNumber != null){
           tableHTML += '<th style=\"' + headerStyleString + '\">' + 'Check Number' + '</th>';
           tableHTML += '</tr>';
           tableHTML += '<tr>';
		   tableHTML += '<td style=\"' + rowStyleString + '\">' + dispResult.registerNumber + '</td>';
		   tableHTML += '<td style=\"' + rowStyleString + '\">' + dispResult.remittanceStatus + '</td>';
		   tableHTML += '<td style=\"' + rowStyleString + '\">' + dispResult.receiptAmount.setScale(2) + '</td>';
           tableHTML += '<td style=\"' + rowStyleString + '\">' + dispResult.receivedDate.format('MM/dd/yyyy') + '</td>'; 
           tableHTML += '<td style=\"' + rowStyleString + '\">' + dispResult.paymentMethod + '</td>';      
		   tableHTML += '<td style=\"' + rowStyleString + '\">' + dispResult.checkNumber + '</td>'; 
           tableHTML += '</tr>'; 
          
            } else{  
           tableHTML += '<th style=\"' + headerStyleString + '\">' + 'Trace Number' + '</th>';
           tableHTML += '<tr>';
		   tableHTML += '<td style=\"' + rowStyleString + '\">' + dispResult.registerNumber + '</td>';
		   tableHTML += '<td style=\"' + rowStyleString + '\">' + dispResult.remittanceStatus + '</td>';
		   tableHTML += '<td style=\"' + rowStyleString + '\">' + dispResult.receiptAmount.setScale(2) + '</td>';
           tableHTML += '<td style=\"' + rowStyleString + '\">' + dispResult.receivedDate.format('MM/dd/yyyy') + '</td>'; 
           tableHTML += '<td style=\"' + rowStyleString + '\">' + dispResult.paymentMethod + '</td>'; 
		   tableHTML += '<td style=\"' + rowStyleString + '\">' + dispResult.traceNumber + '</td>'; 
           tableHTML += '</tr>';
        }
      System.debug( ' TEST  Register_Number :  ' + dispResult.registerNumber);
      System.debug( ' TEST  Remittance_Status :  ' + dispResult.remittanceStatus);
                
            
                }else{
                    
                   System.debug('TEST Register Number : Not found');
                   
           tableHTML = '<table style=\"' + tableStyleString + '\">' ;
		   tableHTML += '<tr>';
		   tableHTML += '<th style=\"' + headerStyleString + '">' + 'Register Number Not found.' + '</th>';
		   tableHTML += '</tr>';
		   
                }
          tableHTML += '</table>';     
           reportStr =   tableHTML;
     
        return  reportStr;
    }
    public EEM_RegisterNumberController(){
        Boolean isSandbox = [Select IsSandbox From Organization Limit 1].IsSandbox;
        String configLabel = isSandbox ? 'Dev' : 'Prod';
        List<Payment_Portal_Configuration__mdt> paymentPortalConfigurations = [
            Select Label, Base_URL__c, Client_Id__c, Client_Secret__c, Encryption_Key__c
            From Payment_Portal_Configuration__mdt 
            Where Label = :configLabel Limit 1
        ];
        if(paymentPortalConfigurations.size() > 0){
            Payment_Portal_Configuration__mdt paymentPortalConfiguration = paymentPortalConfigurations.get(0);
            this.strBaseURL = paymentPortalConfiguration.Base_URL__c;
            this.strClientId = paymentPortalConfiguration.Client_Id__c;
            this.strClientSecret = paymentPortalConfiguration.Client_Secret__c;
            this.strEncryptionKey = paymentPortalConfiguration.Encryption_Key__c;
        }
        
    }
    
    public PaymentRemittanceResults getRemittanceResults(String registerNbr) {
        

        
        //Build the endpoint
       
        List<Object> lstParameters = new List<Object> {strBaseURL };
        String strEndpoint = String.format(PAYMENT_PORTAL_REMITTANCE_URL, lstParameters);
        
        //Build the JSON body
        String strBody = '{"registerNumber": "' + registerNbr + '"}';
        if(registerNbr.compareTo('0') == 0){
         System.debug('PaymentRemittanceResults Error: registerNumber : ' + registerNbr);  
            return null;
        }
        //Get the access token
        String strTokenResult = getToken(strClientId, strClientSecret);
        if(strTokenResult == null) {
            return null;
        }
        
        //Make the call
        HttpResponse response = sendBearerAuthenticationRequest(strEndpoint, HTTP_POST, strBody);
        if(response == null) {
            return null;
        }

        //Return the results
        try{
          
        PaymentRemittanceResults results = new PaymentRemittanceResults(response.getBodyDocument());
            if(results == null){
                return null;
            }
            
        return results;
            
        }catch(Exception e) {
            System.debug('PaymentRemittanceResults Callout Error:' + e.getMessage());
            return null;
        }
    }


  private String getToken(String clientId, String clientSecret) {
        List<Object> lstParameters = new List<Object> {strBaseURL};
        String strEndpoint = String.format(PAYMENT_PORTAL_OAUTH_URL, lstParameters);

        //Rest Call
        Http h = new Http();
		HttpRequest request = new HttpRequest();

        //Set Verb Type
		request.setMethod(HTTP_POST);
        //Set End Point
        request.setEndpoint(strEndpoint);
        //Set Header
        request.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueof(clientId + ':' + clientSecret)));
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Accept', 'application/json');
        request.setBody('grant_type=client_credentials');

        HttpResponse response;
		try {
			response = h.send(request);
		} catch (Exception e) {
			return 'Callout Error:' + e.getMessage();
		}

        if(response.getStatusCode() < 400) {
            System.debug(response.getBody());
            Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            this.strAccessToken = (String)mapResponse.get('access_token');
            return (String)mapResponse.get('access_token');
        }
        else {
            System.debug(response.getBody());
            return 'Response Code: ' + response.getStatusCode() + ' Response Message: ' + response.getStatus();
        }
    }
  
       private HttpResponse sendBearerAuthenticationRequest(String strEndpoint, String strHTTPMethod, String strBody) {
        //Rest Call
        Http h = new Http();
		HttpRequest request = new HttpRequest();

        //Set Verb Type
		request.setMethod(strHTTPMethod);
        //Set End Point
        request.setEndpoint(strEndpoint);
        //Set Header
        request.setHeader('Authorization', 'Bearer '+ this.strAccessToken);
        //request.setHeader('Accept', 'application/json');
        //Set the JSON body if suppplied
        if(strBody != ''){
            request.setHeader('Content-Type', 'application/json');
            request.setBody(strBody);
        }

        //Make Rest Call
        HttpResponse response;
		try {
			response = h.send(request);
		} catch (Exception e) {
			System.debug('Callout Error:' + e.getMessage());
            return null;
		}
        if( response.getStatusCode() < 400) {
            return response;
        }
        else {
            System.debug('Response Code: ' + response.getStatusCode());
            System.debug('Response Message: ' + response.getStatus());
            System.debug('Response Body: ' + response.getBody());
            return null;
        }
    }
 
    

}