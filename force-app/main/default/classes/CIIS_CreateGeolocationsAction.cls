/**
 * @description This class is used to create geolocations and account geolocations.
 * @author CGI
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
/**
 * Explanation for suppressing PMD.ApexCRUDViolation
 * This class grants specific privileged access to read and create Geolocation and Account geolocation records.
 * There are previous steps in the flow where this is invoked that check if the user is allowed temporary
 * access to query geolocation records and create new ones.
 */
public without sharing class CIIS_CreateGeolocationsAction {
    /**
     * @description This method creates geolocations for accounts based on the given requests.
     * @param requests A list of Request objects that contains the necessary data for creating geolocations.
     * @return void
     */
    @InvocableMethod(label='Create Geolocations')
    public static void execute(List<Request> requests) {
        Map<String, String> geoTypeByFacilityType = new Map<String, String>();
        Map<String, CIIS_Geolocations__c> newGeolocationByKey = new Map<String, CIIS_Geolocations__c>();
        for (CIIS_Supply_Chain_Facility_Type_Setting__mdt fts : [
            SELECT MasterLabel, CIIS_Primary_Geolocation_Type__c
            FROM CIIS_Supply_Chain_Facility_Type_Setting__mdt
        ]) {
            geoTypeByFacilityType.put(
                fts.MasterLabel,
                fts.CIIS_Primary_Geolocation_Type__c
            );
        }
        List<CIIS_Account_Geolocation__c> newAccountGeolocations = new List<CIIS_Account_Geolocation__c>();
        for (Request request : requests) {
            for (
                CIIS_FacilityGeolocation geolocation : request.facilityGeolocations
            ) {
                String geoType = 'Facility Location';
                if (
                    geoTypeByFacilityType.containsKey(geolocation.facilityType)
                ) {
                    geoType = geoTypeByFacilityType.get(
                        geolocation.facilityType
                    );
                }
                String key =
                    geolocation.accountId +
                    ':' +
                    geolocation.facilityType +
                    ':' +
                    geolocation.latitude +
                    ':' +
                    geolocation.longitude;
                newGeolocationByKey.put(
                    key,
                    new CIIS_Geolocations__c(
                        CIIS_Primary_Geolocation_Type__c = geoType,
                        CIIS_Geolocation__Latitude__s = geolocation.latitude,
                        CIIS_Geolocation__Longitude__s = geolocation.longitude,
                        CIIS_Geolocation_Name__c = 'Facility'
                    )
                );
            }
        }
        insert newGeolocationByKey.values();

        for (Request request : requests) {
            for (
                CIIS_FacilityGeolocation geolocation : request.facilityGeolocations
            ) {
                String key =
                    geolocation.accountId +
                    ':' +
                    geolocation.facilityType +
                    ':' +
                    geolocation.latitude +
                    ':' +
                    geolocation.longitude;
                newAccountGeolocations.add(
                    new CIIS_Account_Geolocation__c(
                        CIIS_Account__c = geolocation.accountId,
                        CIIS_Geolocations__c = newGeolocationByKey.get(key).Id,
                        CIIS_Is_Primary_Supply_Chain_Geolocation__c = true,
                        CIIS_Status__c = 'Pending Approval'
                    )
                );
            }
        }
        insert newAccountGeolocations;
        return;
    }

    /**
     * @description This inner class represents a request object, containing a list of facility geolocations.
     */
    public class Request {
        /**
         * @description A list of CIIS_FacilityGeolocation objects containing information about the facility geolocations.
         */
        @InvocableVariable(required=true)
        public List<CIIS_FacilityGeolocation> facilityGeolocations;
    }
}