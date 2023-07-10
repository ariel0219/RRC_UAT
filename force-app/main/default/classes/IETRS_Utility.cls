/**
* @File Name          : IETRS_Utility.cls
* @Description        : Common Utility Class created for common tasks.
* @Author             : Sandhya Belur
* @Group              : 
* @Last Modified By   : Sandhya Belur
* @Last Modified On   : 04/28/2020
* @Modification Log   : 
* Ver      Date            Author          		Modification
* 1.0      04/28/2020      Sandhya Belur        Initial Version 
**/
public class IETRS_Utility {
    
    /**
* @description Common method to create Task instance for Activity History records
* @author Sandhya Belur | 04/27/2020
* @param mapOldInspWeeklyRpt A map of Id and Weekly Report object records which are going to be deleted.
* @return void 
**/
    public static Task createActivityHistoryRecord(Id whatId, string notes){
        Id taskInspEventHisRecId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Inspection_Event_History').getRecordTypeId();
        Task objT = new Task();
        objT.ActivityDate = System.today();
        objT.IETRS_Inspections_Event_History__c = true;
        objT.OwnerId = UserInfo.getUserId();
        objT.WhatId = whatId;
        objT.Type = 'Record Deleted';
        objT.RecordTypeId = taskInspEventHisRecId;
        objT.IETRS_Event_Date_Time__c = System.now();
        objT.Status = 'Completed';
        objT.IETRS_Note__c = notes.left(255);
        objT.Subject = 'Record Deleted';
        return objT;
        
    }
    
}