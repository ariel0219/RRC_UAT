/**
* @author Vishwanath Kodgire
* @date 01/19/2023
*
* @description Service class for Inspection Package Approval Validation
*/
public class CIIS_InspPkgReadinessValidation {
    @InvocableMethod(
        label='CIIS Inspection Package Readiness Validation'
        description='Given an inspection package Id finds all inspections and grandchild records and ensures they are complete'
    )
    public static List<String> CIIS_InspPkgReadinessValidation(List<Id> inspectionPackageId) {
        Set<String> errorMessage = new Set<String>();
        List<IETRS_Inspection__c> inspList = new LIST<IETRS_Inspection__c>();
        inspList = [SELECT
                    ID,
                    CIIS_Inspection_Type__c,
                    IETRS_Inspection_Package__r.IETRS_Status__c,
                    (SELECT ID FROM Inspection_Geolocations_Visited__r),
                    (SELECT ID FROM Facility_Observations__r),
                    (SELECT ID, IETRS_Status__c, IETRS_State__c FROM Violations__r)
                    FROM IETRS_Inspection__c WHERE IETRS_Inspection_Package__c IN: inspectionPackageId];
        errorMessage.clear();
        for(IETRS_Inspection__c insp: inspList){
            if((insp.Inspection_Geolocations_Visited__r.size() > 0 && insp.Facility_Observations__r.size() > 0) ){
                    for(IETRS_Violation__c vio: insp.Violations__r ){
                        if(vio.IETRS_Status__c != 'Complete' && vio.IETRS_State__c != 'Corrected')
                            errorMessage.add('Related Violations status is not Complete and state is not Corrected.' );
                    }
            }
            else{
                errorMessage.add('One Geolocation and one Facility Observation record required on at least one Inspection.' );
            }
        }
        List<String> returnList = new List<String>();
        if(!errorMessage.isEmpty()){
            String errorString = '';
            for(String str: errorMessage){
                errorString = errorString + str + '\n';
            }
            returnList.add(errorString);
        }
        system.debug('returnList ' + returnList);
        return returnList;
    }
}