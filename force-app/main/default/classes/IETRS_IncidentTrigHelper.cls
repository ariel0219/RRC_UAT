/**
* @File Name          : IETRS_IncidentTrigHelper.cls
* @Description        : Trigger Helper for IETRS_IncidentTrigger
* @Author             : Sandhya Belur
* @Group              : 
* @Last Modified By   : Sandhya Belur
* @Last Modified On   : 04/27/2020
* @Modification Log   : 
* Ver      Date            Author               Modification
* 1.0      04/27/2020      Sandhya Belur        Initial Version 
**/

public class IETRS_IncidentTrigHelper {
    
    /**
* @description Create Activity record if any record deleted from Incident object.
* @author Sandhya Belur | 04/27/2020
* @param mapOldIncident A map of Id and Incident records which are going to be deleted.
* @return void 
**/
    public static void createActivityForDeletedIncident(map<Id,IETRS_Incident__c> mapOldIncident){
        List<Task> lstTask = new List<Task>();
        
        for(IETRS_Incident__c objIncident : mapOldIncident.values()){
            if(objIncident.IETRS_Regulated_Entity__c != null || objIncident.IETRS_Organization__c != null){
                Id WhatId = objIncident.IETRS_Regulated_Entity__c != null ? objIncident.IETRS_Regulated_Entity__c : objIncident.IETRS_Organization__c;                
                String note = 'Incident Record Deleted Name: ' + objIncident.Name + ' , Business Area : ' + objIncident.IETRS_Business_Area__c + ' , Regulated Entity Id: ' + objIncident.IETRS_Regulated_Entity_ID__c;
                Task objTask = IETRS_Utility.createActivityHistoryRecord(WhatId,note);
                objTask.Subject = 'Incident Deleted';
                objTask.Description = note;
                lstTask.add(objTask);
            }
            
        }
        if(!lstTask.isEmpty()){
            insert lstTask;
        }
        
    }
}