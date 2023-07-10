public with sharing class IETRS_OppCodes_TriggerHelper {
    public static void stopNonWorkInProgressIPDeletes(List<IETRS_Insp_OPP_Codes__c> lstOppCodes) {
        
        String strProfileName;

        strProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        if (strProfileName == 'IETRS Inspections - Inspector' || strProfileName == 'IETRS Inspections - Inspection Manager'){
            for(Integer i=0; i<lstOppCodes.size(); i++){
                IETRS_Inspection__c inspQueried = [SELECT IETRS_Inspection_Package__c, IETRS_Inspection_Package__r.IETRS_Status__c FROM IETRS_Inspection__c WHERE Id = :lstOppCodes[i].IETRS_Inspection__c LIMIT 1];
                if(inspQueried.IETRS_Inspection_Package__c != null){
                    if(inspQueried.IETRS_Inspection_Package__r.IETRS_Status__c != 'Work in Progress' &&
                      inspQueried.IETRS_Inspection_Package__r.IETRS_Status__c != 'WIP/Rejected'){
                        lstOppCodes[i].addError('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.');
                    }
                }
            }
        }

    }
}