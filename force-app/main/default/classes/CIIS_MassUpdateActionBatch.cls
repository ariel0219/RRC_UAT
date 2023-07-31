/**
* @File Name          : CIIS_MassUpdateActionBatch.cls
* @Description        :
* @Author             : Vishwanath Kodgire
* @Group              :
* @Test Class		  : CIIS_MassSubmitUpdateAction_Test
* @Last Modified By   : Vishwanath Kodgire
* @Last Modified On   : 07/10/2023
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0   	07/10/2023  	 		Vishwanath Kodgire    		Initial Version
**/

global class CIIS_MassUpdateActionBatch implements Database.Batchable<Sobject>{
    global CIIS_MassUpdateAction.massUpdateRequest batchParameters;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String filingQuery;
        if(batchParameters.updateAll){
            filingQuery = 'SELECT ID, CIDX_Onsite_Contact_Phone_Number__c, CIDX_Onsite_Contact_Email__c, CIDX_Emergency_Contact_First_Name__c, CIDX_Emergency_Contact_Phone_Number__c, CIDX_Emergency_Contact_Email__c, CIDX_Onsite_Contact_First_Name__c, CIDX_Emergency_Contact_Last_Name__c, CIDX_Onsite_Contact_Last_Name__c, CIDX_Backup_Battery_KW_Hours__c, CIDX_Backup_Generation_KW_Hours__c, CIDX_Backup_Power_Duration_Hrs__c, CIDX_Backup_Startup_Time_Hrs__c, CIDX_Regulated_Entity_Backup_Power__c, CIDX_Utility_Dual_Feed__c, CIDX_Retail_Electric_Utility_Name__c, CIDX_Dispatch_Asset_Code__c, CIDX_ESI_Utility_Customer_Name__c, CIDX_Electric_Utility_Customer_Name__c FROM CIDX_Filing__c WHERE ' +
                'CIDX_Filing_Year__c =' +  batchParameters.filingYear + 
                ' AND CIDX_Filing_Session__c =\'' +  batchParameters.filingSession+ '\'' +
                ' AND CIDX_Organization__c =\'' +  batchParameters.Organization+ '\'';
            if(batchParameters.BackupPower != 'All')
                filingQuery += ' AND CIDX_Regulated_Entity_Backup_Power__c =\'' +  batchParameters.BackupPower+ '\'';
            if(batchParameters.electricityReliance != 'All')
                filingQuery += ' AND CIDX_Reliant_on_Electricity_to_Operate__c =\'' +  batchParameters.electricityReliance+ '\'';
            if(batchParameters.filingStatus != 'All of the Above')
                filingQuery += ' AND CIDX_Filing_Status__c =\'' + batchParameters.filingStatus + '\''; 
            return Database.getQueryLocator(filingQuery);
        }
        else{
            return Database.getQueryLocator([SELECT ID,
                                             CIDX_Onsite_Contact_Phone_Number__c, 
                                             CIDX_Onsite_Contact_Email__c,
                                             CIDX_Emergency_Contact_First_Name__c, 
                                             CIDX_Emergency_Contact_Phone_Number__c, 
                                             CIDX_Emergency_Contact_Email__c, 
                                             CIDX_Onsite_Contact_First_Name__c, 
                                             CIDX_Emergency_Contact_Last_Name__c, 
                                             CIDX_Onsite_Contact_Last_Name__c, 
                                             CIDX_Backup_Battery_KW_Hours__c, 
                                             CIDX_Backup_Generation_KW_Hours__c, 
                                             CIDX_Backup_Power_Duration_Hrs__c, 
                                             CIDX_Backup_Startup_Time_Hrs__c, 
                                             CIDX_Regulated_Entity_Backup_Power__c, 
                                             CIDX_Utility_Dual_Feed__c, 
                                             CIDX_Retail_Electric_Utility_Name__c, 
                                             CIDX_Dispatch_Asset_Code__c, 
                                             CIDX_ESI_Utility_Customer_Name__c, 
                                             CIDX_Electric_Utility_Customer_Name__c 
                                             FROM CIDX_Filing__c WHERE ID IN: batchParameters.selectedFilteredFilings]);
        }
    }
    
    global void execute(Database.BatchableContext bc, List<CIDX_Filing__c> filings){
        List<CIDX_Filing__c> filingsToUpdate = new List<CIDX_Filing__c>();
        CIDX_Filing__c newFilingData = batchParameters.filingRecordUpdatedValues;
        String fieldChoices = batchParameters.fieldChoices;
        try{
            for(CIDX_Filing__c cf: filings){
                if(fieldChoices.contains('Emergency Contact')){
                    cf.CIDX_Emergency_Contact_First_Name__c = newFilingData.CIDX_Emergency_Contact_First_Name__c;
                    cf.CIDX_Emergency_Contact_Phone_Number__c = newFilingData.CIDX_Emergency_Contact_Phone_Number__c;
                    cf.CIDX_Emergency_Contact_Email__c = newFilingData.CIDX_Emergency_Contact_Email__c;
                    cf.CIDX_Emergency_Contact_Last_Name__c = newFilingData.CIDX_Emergency_Contact_Last_Name__c; 
                }
                if(fieldChoices.contains('Onsite Contact')){
                    cf.CIDX_Onsite_Contact_Phone_Number__c = newFilingData.CIDX_Onsite_Contact_Phone_Number__c;
                    cf.CIDX_Onsite_Contact_Email__c = newFilingData.CIDX_Onsite_Contact_Email__c;
                    cf.CIDX_Onsite_Contact_First_Name__c = newFilingData.CIDX_Onsite_Contact_First_Name__c; 
                    cf.CIDX_Onsite_Contact_Last_Name__c = newFilingData.CIDX_Onsite_Contact_Last_Name__c; 
                }
                if(fieldChoices.contains('Backup Power')){                    
                    cf.CIDX_Backup_Battery_KW_Hours__c = newFilingData.CIDX_Backup_Battery_KW_Hours__c; 
                    cf.CIDX_Backup_Generation_KW_Hours__c = newFilingData.CIDX_Backup_Generation_KW_Hours__c; 
                    cf.CIDX_Backup_Power_Duration_Hrs__c = newFilingData.CIDX_Backup_Power_Duration_Hrs__c; 
                    cf.CIDX_Backup_Startup_Time_Hrs__c = newFilingData.CIDX_Backup_Startup_Time_Hrs__c;
                    cf.CIDX_Regulated_Entity_Backup_Power__c = newFilingData.CIDX_Regulated_Entity_Backup_Power__c; 
                    cf.CIDX_Utility_Dual_Feed__c = newFilingData.CIDX_Utility_Dual_Feed__c;
                }
                if(fieldChoices.contains('Comp Utility Information')){
                    cf.CIDX_Retail_Electric_Utility_Name__c = newFilingData.CIDX_Retail_Electric_Utility_Name__c; 
                    cf.CIDX_Dispatch_Asset_Code__c = newFilingData.CIDX_Dispatch_Asset_Code__c;
                    cf.CIDX_ESI_Utility_Customer_Name__c = newFilingData.CIDX_ESI_Utility_Customer_Name__c; 
                }
                if(fieldChoices.contains('Non Comp Utility Information'))
                    cf.CIDX_Electric_Utility_Customer_Name__c = newFilingData.CIDX_Electric_Utility_Customer_Name__c; 
                
                filingsToUpdate.add(cf);
            }
            system.debug('filingsToUpdate ' + filingsToUpdate);
            Update filingsToUpdate;
        }
        catch(exception e){
            System.debug(' Exception occured while performing Mass Update of CIDX records: ' + e);
        }
    }    
    global void finish(Database.BatchableContext bc){   } 
    
}