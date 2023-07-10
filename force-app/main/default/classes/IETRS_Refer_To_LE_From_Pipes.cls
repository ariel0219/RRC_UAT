public with sharing class IETRS_Refer_To_LE_From_Pipes {
    //Invocable Method allowing a flow in the PIPES system to automate the Pipeline Safety Refer to Legal Enforcement process.
    //This method accepts a list of Case Ids as a parameter and uses the Apex already written for the Assign Case to Hearings and Refer Case to Legal Enforcement LWCs.
    //When this method is called from the Flow in PIPES, it is expecting a Case of the Record Type "Pipeline Safety" to already be created and have F&C records associated.
    @InvocableMethod(Label='Refer to Legal From Pipes')
    public static void IETRS_Refer_To_LE_From_Pipes(List<String> lstCaseIds) {
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
                'IETRS_Privileged__c'
            );
        }
    }
}