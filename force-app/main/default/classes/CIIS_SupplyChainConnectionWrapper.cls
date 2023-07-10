public class CIIS_SupplyChainConnectionWrapper {
	
    @AuraEnabled
    public String receiverId{get;set;}
    
    @AuraEnabled
    public String receiverName{get;set;}
    
    @AuraEnabled
    public String receiverP5Number{get;set;}
    
    @AuraEnabled
    public String receiverSystemId{get;set;}
    
    @AuraEnabled
    public String receiverType{get;set;}
    
	@AuraEnabled
    public String supplierName{get;set;}
    
    @AuraEnabled
    public String supplierP5Number{get;set;}
    
    @AuraEnabled
    public String supplierType{get;set;}
	
    @AuraEnabled
    public String supplierId{get;set;}
    
	@AuraEnabled
    public String id{get;set;}
    
}