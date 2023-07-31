/**
* @File Name          : CIIS_MassUpdateAction.cls
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

global with sharing class CIIS_MassUpdateAction {
    @InvocableMethod(label='CIIS Mass Update Action' description='')
    global static void CIIS_PerformMassUpdate(List<massUpdateRequest> requests){
        CIIS_MassUpdateActionBatch MUAB = new CIIS_MassUpdateActionBatch();
        MUAB.batchParameters = requests[0];
        Database.executeBatch(MUAB, 200);
    }
    
    global class massUpdateRequest{
        @invocableVariable(required=true)
        global CIDX_Filing__c filingRecordUpdatedValues;
        
        @invocableVariable
        global List<String> selectedFilteredFilings;
        
        @invocableVariable(required=true)
        global string fieldChoices;
        
        @invocableVariable(required=true)
        global double filingYear;
        
        @invocableVariable(required=true)
        global String filingSession;
        
        @invocableVariable(required=true)
        global String filingStatus;
        
        @invocableVariable(required=true)
        global Id Organization;
        
        @invocableVariable(required=true)
        global String electricityReliance;
        
        @invocableVariable(required=true)
        global String BackupPower;
        
        @invocableVariable(required=true)
        global Boolean updateAll;
        
        
    }
    
}