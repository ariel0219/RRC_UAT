public without sharing class CIIS_SupplyChainConnectionDB { 
	@InvocableMethod (label = 'Get Supply Chain Connection Record By Id' description = 'Get Supply Chain Connection Record By Id')
    public static List<CIIS_Supply_Chain_Connection__c> getRecord(List<FlowInputs> flowInputList){
        List<CIIS_Supply_Chain_Connection__c> returnList;
        String soqlQuery='SELECT ';
        if(flowInputList!=null && flowInputList.size()>0){
            FlowInputs flowInput= flowInputList.get(0);
            String columns = flowInput.columns;
            String recordId = flowInput.recordId; 
            soqlQuery= soqlQuery + columns;
            soqlQuery= soqlQuery + ' FROM CIIS_Supply_Chain_Connection__c ';
            soqlQuery= soqlQuery + ' WHERE  Id=:recordId';
            System.debug('soqlQuery:'+soqlQuery);
            returnList=Database.query(soqlQuery);
        }else{
            throw new CIIS_SupplyChainConnectionDBException('Input parameter(records id & column) are missing ');
        }
        return returnList;
    }
    
    public class FlowInputs {
        @InvocableVariable
        public String recordId;

        @InvocableVariable
        public String columns;
    } 
    
    public class CIIS_SupplyChainConnectionDBException extends Exception{
        
    }
    

}