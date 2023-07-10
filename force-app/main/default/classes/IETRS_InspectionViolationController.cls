public class IETRS_InspectionViolationController {

    @AuraEnabled
    public static List<IETRS_Violation__c> getViolations(Id recordId){
         return [SELECT Id, Name, IETRS_Status__c,IETRS_State__c, IETRS_EnforcementRequested__c,IETRS_Regulated_Entity__r.Name, IETRS_Inspection__c FROM IETRS_Violation__c WHERE IETRS_Inspection_Package__c = :recordId AND IETRS_Status__c in ('Pending','Rejected')];
    }
    
    @AuraEnabled(cacheable=true)
    public static String getstatus(Id recordId){
     String status = [SELECT Id,IETRS_Uncorrected_Status__c from IETRS_Inspection_Package__c WHERE Id = :recordId].IETRS_Uncorrected_Status__c;   
      return status;
    }
    
    @AuraEnabled
    public static void createPOCs(List<Id> records,Date estimatedcompletiondate,Date completiondate,Id InspectionPackageId){
      system.debug('records :'+records+' estimatedcompletiondate :'+estimatedcompletiondate+' completiondate :'+completiondate);
        Map<Id,Boolean> maprecords = new Map<Id,Boolean>();
        for(Id i : records){
          IETRS_Insp_Plan_of_Correction__c[] rejpoc = [SELECT Id,IETRS_POC_Status__c FROM IETRS_Insp_Plan_of_Correction__c WHERE IETRS_POC_Status__c='Rejected' AND IETRS_Violation__c=:i];
            if(rejpoc.isEmpty()){
                maprecords.put(i,true);
            }
            else{
                integer recordcount = [SELECT count() FROM IETRS_Insp_Plan_of_Correction__c WHERE id!='']; 
                if(recordcount==0){
              maprecords.put(i,true); 
                    }
                else{
              maprecords.put(i,false);
                    }
            }
        } 
      List<IETRS_Insp_Plan_of_Correction__c> lstpoc = new List<IETRS_Insp_Plan_of_Correction__c>();
        for(Id i : records){
            if(maprecords.get(i)){
            IETRS_Insp_Plan_of_Correction__c poc = new IETRS_Insp_Plan_of_Correction__c();
            poc.IETRS_Violation__c = i ;
            poc.IETRS_Est_Completion_Date__c = estimatedcompletiondate ; 
            poc.IETRS_Completion_Date__c = completiondate ; 
            poc.IETRS_Related_Inspection_Package__c=InspectionPackageId;
            poc.IETRS_POC_Status__c = 'Approved';
            lstpoc.add(poc);
                }
        }
        Insert lstpoc;
    }
    
    @AuraEnabled
    public static List<IETRS_Insp_Plan_of_Correction__c> getpocrecordsperviolation(Id recordId){
         return [SELECT Id, Name , IETRS_Violation__c, IETRS_POC_Status__c, IETRS_Inspector_Comments__c, IETRS_Est_Completion_Date__c, IETRS_Completion_Date__c FROM IETRS_Insp_Plan_of_Correction__c WHERE IETRS_Violation__c = :recordId];
    }
    
    @AuraEnabled
    public static void updatePOCs(List<Id> records,Date estimatedcompletiondate,Date completiondate){
        system.debug('records :'+records+' estimatedcompletiondate :'+estimatedcompletiondate+' completiondate :'+completiondate);
      List<IETRS_Insp_Plan_of_Correction__c> lstpoc = new List<IETRS_Insp_Plan_of_Correction__c>();
        for(IETRS_Insp_Plan_of_Correction__c poc : [SELECT Id,IETRS_Est_Completion_Date__c,IETRS_Completion_Date__c,IETRS_Violation__c,IETRS_POC_Status__c  FROM IETRS_Insp_Plan_of_Correction__c WHERE IETRS_Violation__c IN :records AND IETRS_POC_Status__c!='Rejected']){
            poc.IETRS_Est_Completion_Date__c = estimatedcompletiondate ; 
            poc.IETRS_Completion_Date__c = completiondate ;
            poc.IETRS_POC_Status__c = 'Approved';
            lstpoc.add(poc);
        }
        Update lstpoc;
    }
    
    @AuraEnabled
    public static boolean checkPOCValidation(List<Id> records){
        List<IETRS_Insp_Plan_of_Correction__c> listPOC = new List<IETRS_Insp_Plan_of_Correction__c>([select Id from IETRS_Insp_Plan_of_Correction__c where (IETRS_POC_Status__c = 'Approved' or IETRS_POC_Status__c = 'Pending Approval') 
                                                                                                     and IETRS_Violation__c in :records]);
        
        if(listPOC.size()>0)return true;
        else return false;
    }
}