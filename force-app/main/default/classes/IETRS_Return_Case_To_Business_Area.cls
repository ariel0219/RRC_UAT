/**
 * @File Name          : IETRS_Return_Case_To_Business_Area.cls
 * @Description        : Controller used to get Staff Assignments related to a Case ID and sort by an Administrator defined sequence
 * @Author             : ???
 * @Group              : 
 * @Last Modified By   : Ronald Stewart
 * @Last Modified On   : 02/04/2021
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0       ????????                  ???????                  Initial Version
 * 1.1       02/04/2021              Ronald Stewart             Add logic to return case to business area who referred the case to Hearings previously
**/
public without sharing class IETRS_Return_Case_To_Business_Area {
    
    //Invocable method called by the Hearings Return to Business Area Flow
    @InvocableMethod(Label='Return to Business Area (not reject)')
    public static void returnToBusinessArea(List<String> lstCaseId) {

       List<Case> lstCases = new List<Case>();
       for (String strCaseId : lstCaseId){
           Case caseUpdate = helperReturnCaseUpdater(strCaseId);
           if (caseUpdate.IETRS_Refer_to_Hearings__c == true) {
               caseUpdate.IETRS_Refer_to_Hearings__c = false;
           }
           else if (caseUpdate.IETRS_Refer_to_Legal_Enforcement__c == true) {
               caseUpdate.IETRS_Refer_to_Legal_Enforcement__c = false;
           }
           //caseUpdate.IETRS_Refer_to_Hearings__c = false;
           if (caseUpdate.IETRS_Original_Record_Type__c == 'SMRD' || caseUpdate.IETRS_Hearings_Status__c == 'HD Docket Complete'){
               caseUpdate.IETRS_SMRD_Compliance_Status__c = 'Final Action';
           }
           if (caseUpdate.IETRS_Original_Record_Type__c == 'SSE' || caseUpdate.IETRS_Hearings_Status__c == 'HD Docket Complete'){
            caseUpdate.IETRS_SSE_Case_Status__c = 'Application Complete';
         
        }
           lstCases.add(caseUpdate);


       }
        update lstCases;
    }

    //Helper method that holds common logic for invocable methods in other classes
    public static Case helperReturnCaseUpdater(Id caseId){
        //Get the Case object from the Case record Id of the page
        //Chnage the read only record type to the real ID. Then update the if check to copy how line 46 get record.  
        Case caseUpdate = [SELECT Id, IETRS_Original_Record_Type__c, IETRS_Refer_to_Hearings__c, IETRS_Refer_to_Legal_Enforcement__c, RecordTypeId, IETRS_Hearings_Status__c FROM Case WHERE Id = :caseId][0];
        //Get the API name of the Business Area field that corresponds to the original record type of the Case record
        IETRS_Record_Type_Business_Area_Mapping__mdt metaMapping = [SELECT IETRS_Business_Area_Status__c, IETRS_Record_Type__c FROM IETRS_Record_Type_Business_Area_Mapping__mdt WHERE IETRS_Record_Type__c = :caseUpdate.IETRS_Original_Record_Type__c][0];

        Id hearingsRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Hearings').getRecordTypeId();
        Id legalERT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Legal Enforcement').getRecordTypeId();
       //Update the Business Area status field returned from custom metadata with the standardized picklist value "Returned from Hearings" or "Returned form Legal" (This value is unified across all Business Area statuses)
       if (hearingsRT == caseUpdate.RecordTypeId) {
           caseUpdate.put(metaMapping.IETRS_Business_Area_Status__c, System.Label.IETRS_Returned_From_Hearings_Pick_Val);
       }
       else if (legalERT == caseUpdate.RecordTypeId) {
           caseUpdate.put(metaMapping.IETRS_Business_Area_Status__c, System.Label.IETRS_Returned_from_Legal_Pick_Val);
       } 
        //Change the Case Record Type to the Record Type to make it accessible to the Business Area    
        if(hearingsRT == caseUpdate.RecordTypeId && caseUpdate.IETRS_Refer_to_Legal_Enforcement__c == TRUE){
            caseUpdate.RecordTypeId = LegalERT;        
        }else{
        	caseUpdate.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(caseUpdate.IETRS_Original_Record_Type__c).getRecordTypeId();        
        }
        
        

        return caseUpdate;
        
    }

}