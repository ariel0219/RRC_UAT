public class CIIS_Refer_To_Hearings {
    //Test Class: IETRS_Refer_To_LE_From_Pipes_Test
  
    @InvocableMethod(Label='Refer to Hearings From CIIS')
    public static void CIIS_Refer_To_Hearings(List<String> lstCaseIds) {
        List<String> lstUnshareFCIds = new List<String>();

        for (String strCaseId : lstCaseIds) {
            List<IETRS_Files_Correspondence__c> lstRelatedFCs = IETRS_Assign_Case_to_Hearings_Controller.getRelatedFCs(
                strCaseId
            );
            List<String> lstFCIds = new List<String>();
            for (IETRS_Files_Correspondence__c fc : lstRelatedFCs) {
                lstFCIds.add(fc.Id);
            }
            IETRS_Assign_Case_to_Hearings_Controller.assignToHearingOrLE(
                lstFCIds,
                strCaseId,
                lstUnshareFCIds,
                'IETRS_Shared_With_Hearings__c'
            );
        }
    }
}