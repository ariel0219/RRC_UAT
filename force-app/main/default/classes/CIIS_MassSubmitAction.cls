/**
 * @File Name          : CIIS_MassSubmitAction.cls
 * @Description        :
 * @Author             : Vishwanath Kodgire
 * @Group   
 * @Test Class		   : CIIS_MassSubmitUpdateAction_Test           :
 * @Last Modified By   : Vishwanath Kodgire
 * @Last Modified On   : 07/10/2023
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0   	07/10/2023  	 		Vishwanath Kodgire    		Initial Version
 **/

global with sharing class CIIS_MassSubmitAction {
    @InvocableMethod(label='CIIS Mass Submit Action' description='' category='Other')
    global static void CIIS_PerformMassSubmit(List<massSubmitRequest> requests){
        CIIS_MassSubmitActionBatch MSAB = new CIIS_MassSubmitActionBatch();
        MSAB.batchParameters = requests[0];
        Database.executeBatch(MSAB, 200);
    }
    
    global class massSubmitRequest{
        @invocableVariable(required=true)
        global double filingYear;
        
        @invocableVariable(required=true)
        global String filingSession;
        
        @invocableVariable(required=true)
        global String filingStatus;
        
        @invocableVariable(required=true)
        global Id Organization;
        
        @invocableVariable(required=true)
        global Datetime Submitted_Date;
    }
    
}