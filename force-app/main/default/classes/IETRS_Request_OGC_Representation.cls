public without sharing class IETRS_Request_OGC_Representation {
    
    @InvocableMethod(Label='Request OGC Representations in Hearings')
    public static void IETRS_Request_OGC_Representation(List<String> lstCaseIds) {
        List<Case> lstCases = [SELECT Id FROM Case WHERE Id in :lstCaseIds];

        for(Case c : lstCases)
        {
            c.IETRS_OGC_Representation_Requested__c = true;
        }
        update lstCases;

    }
}