/**
* @File Name          : CIIS_CriticalIndicationsBatchScheduler.cls
* @Description        : Schedules batch for Creating Critical Indication records and Updates Active Filing Period 
* @Author             : Vishwanath Kodgire
* @Test Class		  : CIIS_CIBatchScheduler_Test
* @Group              :
* @Last Modified By   : Vishwanath Kodgire
* @Last Modified On   : 07/21/2023
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0   	07/21/2023  	 		Vishwanath Kodgire    		Initial Version
**/
public class CIIS_CriticalIndicationsBatchScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        Boolean executeBatch = false;
        CIDX_Filing_Period__c currentCFP;
        List<CIDX_Filing_Period__c> lstCFP = [ SELECT Id,
                                                      Name, 
                                                      CIDX_Filing_Year__c, 
                                                      CIDX_Filing_Session__c, 
                                                      CIDX_Due_Date__c, 
                                                      CIDX_Apex_Start_Date__c, 
                                                      CIDX_Active_Filing_Period__c, 
                                                      CIDX_Session_Open_Date__c 
                                                      FROM CIDX_Filing_Period__c ];
        if(lstCFP.size() > 0){
            for(CIDX_Filing_Period__c cfp: lstCFP){
                if(String.valueOf(cfp.CIDX_Apex_Start_Date__c) == System.now().format('yyyy-MM-dd')){
                    cfp.CIDX_Active_Filing_Period__c = true;
                    executeBatch = true;
                    currentCFP = cfp;
                }
                else
                	cfp.CIDX_Active_Filing_Period__c = false;
            }
            
            if(executeBatch){
                Update lstCFP;
                Database.executeBatch(new CIIS_CriticalIndicationsBatch(currentCFP), 200);
            }
        }
    }
}