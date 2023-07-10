public with sharing class IETRS_InspResultsTriggerHelper {
    public static void stopNonWorkInProgressIPDeletes(MAp<Id, IETRS_Insp_Inspection_Result__c> mapInspResult) {
        String strProfileName;

        strProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        if (strProfileName == 'IETRS Inspections - Inspector' || strProfileName == 'IETRS Inspections - Inspection Manager'){
            List<IETRS_Insp_Inspection_Result__c> lstInspResult = [SELECT Id, IETRS_Inspection_Package__r.IETRS_Status__c FROM IETRS_Insp_Inspection_Result__c WHERE ID IN :mapInspResult.keySet()];
            for(Integer i=0; i<lstInspResult.size(); i++){
                if(lstInspResult[i].IETRS_Inspection_Package__c != null){
                    if(lstInspResult[i].IETRS_Inspection_Package__r.IETRS_Status__c != 'Work in Progress' &&
                     lstInspResult[i].IETRS_Inspection_Package__r.IETRS_Status__c != 'WIP/Rejected'){
                        mapInspResult.get(lstInspResult[i].Id).addError('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.');
                    }
                }
            }
        }
    }
}