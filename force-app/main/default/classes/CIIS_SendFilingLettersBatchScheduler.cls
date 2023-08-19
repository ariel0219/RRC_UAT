/**
* @File Name          : CIIS_SendFilingLettersBatchScheduler.cls
* @Description        : Schedules batch for Creating CID Filing Letters (F&C) records
* @Author             : Vishwanath Kodgire
* @Test Class		  : CIIS_SendFilingLettersBatch_Test
* @Group              :
* @Last Modified By   : Vishwanath Kodgire
* @Last Modified On   : 08/11/2023
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0   	08/11/2023  	 		Vishwanath Kodgire    		Initial Version
**/
public class CIIS_SendFilingLettersBatchScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        CIDX_Filing_Period__c currentCFP;
        List<CIDX_Filing_Period__c> lstCFP = [ SELECT Id,
                                                      Name, 
                                                      CIDX_Filing_Year__c, 
                                                      CIDX_Filing_Session__c, 
                                                      CIDX_Due_Date__c, 
                                                      CIDX_Apex_Start_Date__c, 
                                                      CIDX_Active_Filing_Period__c, 
                                                      CIDX_Session_Open_Date__c 
                                                      FROM CIDX_Filing_Period__c WHERE CIDX_Due_Date__c = TODAY];
        if(lstCFP.size() > 0){
            Database.executeBatch(new CIIS_SendFilingLettersBatch(lstCFP[0]),200);
        }
    }
}