/**
 * @File Name          : CIIS_MassSubmitActionBatch.cls
 * @Description        :
 * @Author             : Vishwanath Kodgire
 * @Group              :
 * @Test Class		   : CIIS_MassSubmitUpdateAction_Test
 * @Last Modified By   : Vishwanath Kodgire
 * @Last Modified On   : 07/10/2023
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0   	07/10/2023  	 		Vishwanath Kodgire    		Initial Version
 **/

global class CIIS_MassSubmitActionBatch implements Database.Batchable<Sobject>{
    global CIIS_MassSubmitAction.massSubmitRequest batchParameters;
    ID filingRepContact = [SELECT ID, contactId FROM User WHERE Id =: userInfo.getUserId()]?.contactId;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('batchParameters ' + batchParameters);
        String filingQuery = 'SELECT ID, CIDX_Filing_Status__c, CIDX_Filing_Representative__c, CIDX_Filing_Year__c,CIDX_Filing_Session__c, CIDX_Organization__c, CIDX_Filing_Representative_Contact__c, CIDX_Regulated_Entity__r.IETRS_Status__c,CIDX_RE_Status_at_Submission__c FROM CIDX_Filing__c WHERE ' +
            'CIDX_Filing_Year__c =' +  batchParameters.filingYear + 
            ' AND CIDX_Filing_Session__c =\'' +  batchParameters.filingSession+ '\'' +
            ' AND CIDX_Organization__c =\'' +  batchParameters.Organization+ '\'';
        if(batchParameters.filingStatus != 'All of the Above')
            filingQuery += ' AND CIDX_Filing_Status__c =\'' + batchParameters.filingStatus + '\''; 
        return Database.getQueryLocator(filingQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<CIDX_Filing__c> scope){
        List<CIDX_Filing__c> filingsToUpdate = new List<CIDX_Filing__c>();
        try{
            for(CIDX_Filing__c cf: scope){
                cf.CIDX_Filing_Status__c = 'Pending Validation';
                cf.CIDX_Filing_Representative__c = UserInfo.getUserId();
                cf.CIDX_RE_Status_at_Submission__c = cf.CIDX_Regulated_Entity__r.IETRS_Status__c;
                cf.CIDX_Filing_Representative_Contact__c = filingRepContact;
                cf.CIDX_Submitted_Date__c = batchParameters.Submitted_Date;
                filingsToUpdate.add(cf);
            }
            system.debug('filingsToUpdate ' + filingsToUpdate);
            Update filingsToUpdate;
        }
        catch(exception e){
            System.debug(' Exception occured while performing Mass Submission of CIDX records: ' + e);
        }
    }    
    global void finish(Database.BatchableContext bc){   } 
    
}