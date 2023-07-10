public with sharing class IETRS_MilesOfPipeBySize_TriggerHelper {
    
    //Standard Miles of Pipe by Size
    public static void stopNonWorkInProgressIPDeletes(List<IETRS_Miles_of_Pipe_by_Size__c> lstMilesPipe) {
        String strProfileName;

        strProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        if (strProfileName == 'IETRS Inspections - Inspector' || strProfileName == 'IETRS Inspections - Inspection Manager'){
            for(Integer i=0; i<lstMilesPipe.size(); i++){
                IETRS_Inspection__c inspQueried = [SELECT IETRS_Inspection_Package__c, IETRS_Inspection_Package__r.IETRS_Status__c FROM IETRS_Inspection__c WHERE Id = :lstMilesPipe[i].IETRS_Inspection__c LIMIT 1];
                if(inspQueried.IETRS_Inspection_Package__c != null){
                    if(inspQueried.IETRS_Inspection_Package__r.IETRS_Status__c != 'Work in Progress' &&
                      inspQueried.IETRS_Inspection_Package__r.IETRS_Status__c != 'WIP/Rejected'){
                        lstMilesPipe[i].addError('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.');
                    }
                }
            }
        }
    }

    //Master Meter Miles of Pipe by Size
    public static void stopNonWorkInProgressIPDeletesMM(List<IETRS_Miles_of_Pipe_by_Size_MM__c> lstMilesPipe) {
        String strProfileName;

        strProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        if (strProfileName == 'IETRS Inspections - Inspector' || strProfileName == 'IETRS Inspections - Inspection Manager'){
            for(Integer i=0; i<lstMilesPipe.size(); i++){
                IETRS_Inspection__c inspQueried = [SELECT IETRS_Inspection_Package__c, IETRS_Inspection_Package__r.IETRS_Status__c FROM IETRS_Inspection__c WHERE Id = :lstMilesPipe[i].IETRS_Inspection__c LIMIT 1];
                if(inspQueried.IETRS_Inspection_Package__c != null){
                    if(inspQueried.IETRS_Inspection_Package__r.IETRS_Status__c != 'Work in Progress'&&
                      inspQueried.IETRS_Inspection_Package__r.IETRS_Status__c != 'WIP/Rejected'){
                        lstMilesPipe[i].addError('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.');
                    }
                }
            }
        }
    }

        //Gas Liquid Miles of Pipe by Size
        public static void stopNonWorkInProgressIPDeletesGL(List<IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c> lstMilesPipe) {
            String strProfileName;
    
            strProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
            if (strProfileName == 'IETRS Inspections - Inspector' || strProfileName == 'IETRS Inspections - Inspection Manager'){
                for(Integer i=0; i<lstMilesPipe.size(); i++){
                    IETRS_Inspection__c inspQueried = [SELECT IETRS_Inspection_Package__c, IETRS_Inspection_Package__r.IETRS_Status__c FROM IETRS_Inspection__c WHERE Id = :lstMilesPipe[i].IETRS_Inspection__c LIMIT 1];
                    if(inspQueried.IETRS_Inspection_Package__c != null){
                        if(inspQueried.IETRS_Inspection_Package__r.IETRS_Status__c != 'Work in Progress' &&
                          inspQueried.IETRS_Inspection_Package__r.IETRS_Status__c != 'WIP/Rejected'){
                            lstMilesPipe[i].addError('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.');
                        }
                    }
                }
            }
        }




}