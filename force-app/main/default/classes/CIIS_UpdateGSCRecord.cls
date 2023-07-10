public without sharing class CIIS_UpdateGSCRecord { 
	@InvocableMethod (label = 'Update Supply Chain Record' description = 'Update GSC record yy Id under the admin context')
    public static List<CIIS_Supply_Chain_Connection__c> getRecord(List<FlowInputs> flowInputList){
        List<CIIS_Supply_Chain_Connection__c> returnList;
        String soqlQuery='SELECT ';
        if(flowInputList!=null && flowInputList.size()>0){
            try{
                FlowInputs flowInput= flowInputList.get(0);
                String status = flowInput.status;
                String recordId = flowInput.recordId;
                CIIS_Supply_Chain_Connection__c gscRecord = new CIIS_Supply_Chain_Connection__c();
                gscRecord.Id=recordId;
                gscRecord.CIIS_Status__c=status;
                update gscRecord;
            }catch(CIIS_UpdateGSCRecordException e){
                throw new CIIS_UpdateGSCRecordException('error while updating record '+e);
            }
        }else{
            throw new CIIS_UpdateGSCRecordException('Input parameter(records id & column) are missing ');
        }
        return returnList;
    }
    
    public class FlowInputs {
        @InvocableVariable
        public String recordId;

        @InvocableVariable
        public String status;
    } 
    
    public class CIIS_UpdateGSCRecordException extends Exception{
        
    }
    

}