public class CIIS_SupplierTypeMappingForReceiver {
    
	@AuraEnabled(cacheable=true)
    public static List<String> getSupplerType(String receiverType) {
        List<CIIS_Supply_Chain_Facility_Type_Setting__mdt> result = [
            SELECT
            MasterLabel,
            Supplier_Type_Mapped_To_Receiver__c
            FROM CIIS_Supply_Chain_Facility_Type_Setting__mdt
            WHERE MasterLabel = :receiverType
            LIMIT 1
        ];
        
        if (result.size()==0) {
            throw new CIIS_SupplierTypeSearchException(
                'Supply Chain Type record in custom metadata[' + receiverType + '] not found.'
            );
        }
        CIIS_Supply_Chain_Facility_Type_Setting__mdt supplyChainTypeSetting = result[0];
        String SupplierTypeMapped=supplyChainTypeSetting.Supplier_Type_Mapped_To_Receiver__c;
        if(String.isEmpty(SupplierTypeMapped)){
            throw new CIIS_SupplierTypeSearchException(
                'Supplier type mapping not provided for receiver type[' + receiverType + '] in custom metadata.'
            );            
        }
        List<String> returnList=new List<String>();
        List<String> listTypplierType=SupplierTypeMapped.split(',');
        for(String sType:listTypplierType){
            String value=sType.trim();
            if(!String.isEmpty(value)){
                returnList.add(value);
            }
        }
    	return returnList;    
    }
    
    public class CIIS_SupplierTypeSearchException extends Exception {
    }
}