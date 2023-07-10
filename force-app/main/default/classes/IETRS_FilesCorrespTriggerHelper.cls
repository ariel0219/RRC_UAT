/**
* @File Name          : IETRS_FilesCorrespTriggerHelper.cls
* @Description        : Trigger Helper for IETRS_FilesCorrespTrigger
* @Author             : Sandhya Belur
* @Group              : 
* @Last Modified By   : Sandhya Belur
* @Last Modified On   : 04/24/2020
* @Modification Log   : 
* Ver      Date            Author           Modification
* 1.0      04/24/2020      Sandhya Belur       Initial Version 
**/
public class IETRS_FilesCorrespTriggerHelper {
    
    /**
* @description Create Activity record if any record deleted from Files Files & Correspondence object.
* @author Sandhya Belur | 04/24/2020
* @param mapOldFilesCorresp A map of Id and Files Correspondance records which are going to be deleted.
* @return void 
**/
    public static void createActivityForDeletedFilesCorresp(map<Id,IETRS_Files_Correspondence__c> mapOldFilesCorresp){
        List<Task> lstTask = new List<Task>();        
        
        for(IETRS_Files_Correspondence__c objFilesCorres : mapOldFilesCorresp.values()){
            if(objFilesCorres.IETRS_Inspection_Package__c != null){
                Id WhatId = objFilesCorres.IETRS_Inspection_Package__c;
                String note = 'Record Deleted with File Name ' + objFilesCorres.IETRS_File_Name__c + ' , Document Type : ' + objFilesCorres.IETRS_Document_Type__c + ' and Business Area or Division : ' + objFilesCorres.IETRS_Business_Area_Division__c ;            
                Task objTask = IETRS_Utility.createActivityHistoryRecord(WhatId,note); 
                objTask.Subject = 'Files & Correspondence Deleted';
                objTask.Description = note;
                lstTask.add(objTask);
            }
        }
        
        if(!lstTask.isEmpty()){
            insert lstTask;
        }
    }

    public static Boolean stopNonWorkInProgressIPDeletes(Map<Id,IETRS_Files_Correspondence__c> mapTriggerFCs){
        Boolean blnDeleteBlocked = false;
        String strProfileName = '';
        
        if(UserInfo.getUserType() != 'AutomatedProcess'){
            strProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
            if (strProfileName == 'IETRS Inspections - Inspector' || strProfileName == 'IETRS Inspections - Inspection Manager'){
                List<IETRS_Files_Correspondence__c> lstTriggerFCs = [SELECT Id, IETRS_Inspection_Package__r.IETRS_Status__c FROM IETRS_Files_Correspondence__c WHERE ID IN :mapTriggerFCs.keySet()];
                for(Integer i=0; i<lstTriggerFCs.size(); i++){
                    if(lstTriggerFCs[i].IETRS_Inspection_Package__c != null){
                        if(lstTriggerFCs[i].IETRS_Inspection_Package__r.IETRS_Status__c != 'Work in Progress' &&
                          lstTriggerFCs[i].IETRS_Inspection_Package__r.IETRS_Status__c != 'WIP/Rejected'){
                            mapTriggerFCs.get(lstTriggerFCs[i].Id).addError('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.');
                            blnDeleteBlocked = true;
                        }
                    }
                }
            }
        }
        return blnDeleteBlocked;
    }
    
}