public with sharing class RRC_BoxAccess_AuraEnabled {

    @AuraEnabled
    public static BoxConnectionWrapper initiateBoxConnection(){
        IETRSBox box = new IETRSBox();
        BoxConnectionWrapper wrapper = new BoxConnectionWrapper();
        wrapper.clientId = box.api.clientId;
        wrapper.clientSecret = box.api.clientSecret;
        wrapper.downscopeToken = box.downscopeToken;
        return wrapper;
    }
    
    public class BoxConnectionWrapper{
        String clientId;
        String clientSecret;
        String downscopeToken;
        BoxConnectionWrapper(){
        }
        
        BoxConnectionWrapper(String clientId, String clientSecret, String downscopeToken){
            this.clientId = clientId;
            this.clientSecret = clientSecret;
            this.downscopeToken = downscopeToken;
    }}

}