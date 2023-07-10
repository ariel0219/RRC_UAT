global with sharing class CIIS_GeoCounty_WebService {
    
    @invocableMethod(Label='CIIS Geolocation County Service' description='Please provide County, Latitude, Longitude to get back if geolocation resides within the county.')
    public static List<requestResponse> CIIS_CallGeolocationCountyService(List<requestParameters> parameters){
        List<requestResponse> response = new List<requestResponse>();
        requestResponse resp = new requestResponse();
        resp.response = make_GeoCounty_GetRequest(parameters[0].county, parameters[0].latitude, parameters[0].longitude);
        response.add(resp);
        return response;
    }
    public static String make_GeoCounty_GetRequest(String county, Double latitude, Double longitude) {
        CIIS_Supply_Chain_Settings__mdt supplyChainSeeting = [SELECT Label, CIIS_Staging_GeoCounty_WS_Endpoint__c, CIIS_Production_GeoCounty_WS_Endpoint__c FROM CIIS_Supply_Chain_Settings__mdt Where Label='Default'];
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1]?.IsSandbox;
        String endpointUrl = '';
        if(isSandbox)
            endpointUrl = supplyChainSeeting?.CIIS_Staging_GeoCounty_WS_Endpoint__c  + longitude + ',' +latitude + '/' + county + '/GAU' ;
        else
            endpointUrl = supplyChainSeeting?.CIIS_Production_GeoCounty_WS_Endpoint__c + longitude + ',' +latitude + '/' + county + '/GAU' ;
        String returnResp = '';
        try{
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointUrl);
            request.setMethod('GET');
            HttpResponse response = new Http().send(request);
            
            if (response.getStatusCode() == 200) {
                // Parse the response JSON
                String responseData = response.getBody();
                
                // Check if the "True" key exists and its value is "True"
                if (responseData.contains('true,true')) {
                    returnResp = 'true';
                } 
                else if(!responseData.contains('true,true') ){	
                    returnResp = 'false';
                }
            } 
            else {
                System.debug('HTTP request failed with status code: ' + response.getStatusCode());
                returnResp = 'error';
            }
        }
        catch(exception e){
            returnResp = 'error';
        }
        return returnResp;
    }
    
    global class requestParameters{
        @invocableVariable(required=true)
        global String county;
        
        @invocableVariable(required=true)
        global Double latitude;
        
        @invocableVariable(required=true)
        global Double longitude;
    }
    global class requestResponse{
        @invocableVariable(required=true)
        global String response;
    }
}