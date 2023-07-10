public with sharing class IETRS_RRC_Portal_InspectionPackages {
    @AuraEnabled(cacheable=true)
    public static List<IETRS_Inspection_Package__c> getInspectionPackageList() {
        List<IETRS_Inspection_Package__c> result = new List<IETRS_Inspection_Package__c>();
        Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();
        if (isGuestUser) {

            // guest users see the full list
            result = [
                SELECT
                    Name,
                    IETRS_Inspection_Type__c,
                    IETRS_Begin_Date__c,
                    IETRS_End_Date__c,
                    IETRS_Business_Area__c,
                    IETRS_Organization__r.Name
                FROM IETRS_Inspection_Package__c
                WHERE IETRS_Public_Portal_Record_Visible__c = true
                ORDER BY CreatedDate DESC
                LIMIT 100
            ];
        } else {
            // community users see records filtered by org
            String strContactID = [SELECT ContactID FROM User WHERE Id = :UserInfo.getUserID() LIMIT 1].ContactId;      

            List<AccountContactRelation> lstRel = [SELECT AccountId FROM AccountContactRelation WHERE ContactId = :strContactID];
            Set<Id> setAccts = new Set<Id>();
            for (AccountContactRelation rel : lstRel){
              setAccts.add(rel.AccountId);
            }

            if (!setAccts.isEmpty()) {
                result = [
                    SELECT
                        Name,
                        IETRS_Inspection_Type__c,
                        IETRS_Begin_Date__c,
                        IETRS_End_Date__c,
                        IETRS_Business_Area__c,
                        IETRS_Organization__r.Name
                    FROM IETRS_Inspection_Package__c
                    WHERE IETRS_Organization__c IN :setAccts
                    AND IETRS_Status__c IN ('Waiting for Response')
                    AND IETRS_Public_Portal_Record_Visible__c = true
                    LIMIT 100
                ];
            }
        }
        return result;
    }
}