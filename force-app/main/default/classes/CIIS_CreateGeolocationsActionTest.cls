@isTest
/**
 * @description Test class for CIIS_CreateGeolocationsAction.
 */
private class CIIS_CreateGeolocationsActionTest {
    @isTest
    /**
     * @description Test that geolocations are created correctly based on the given requests.
     */
    static void itShouldCreateGeolocations() {
        // Given... Prepare test data
        String orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Organization')
            .getRecordTypeId();
        Account testAccount = new Account(
            Name = 'Test Geo Account',
            IETRS_Status__c = 'Active',
            RecordTypeId = orgRecordTypeId
        );

        insert testAccount;

        List<CIIS_FacilityGeolocation> facilityGeolocations = new List<CIIS_FacilityGeolocation>();
        CIIS_FacilityGeolocation facilityGeolocation = new CIIS_FacilityGeolocation();
        facilityGeolocation.accountId = testAccount.Id;
        facilityGeolocation.facilityType = 'Test Facility Type';
        facilityGeolocation.latitude = 37.7749;
        facilityGeolocation.longitude = -122.4194;
        facilityGeolocations.add(facilityGeolocation);

        List<CIIS_CreateGeolocationsAction.Request> requests = new List<CIIS_CreateGeolocationsAction.Request>();

        CIIS_CreateGeolocationsAction.Request request = new CIIS_CreateGeolocationsAction.Request();
        request.facilityGeolocations = facilityGeolocations;
        requests.add(request);

        // When... Create geolocations based on requests
        Test.startTest();
        CIIS_CreateGeolocationsAction.execute(requests);
        Test.stopTest();

        // Then... Verify the geolocations are created correctly
        List<CIIS_Geolocations__c> geolocations = [
            SELECT
                Id,
                CIIS_Geolocation__Latitude__s,
                CIIS_Geolocation__Longitude__s
            FROM CIIS_Geolocations__c
        ];
        List<CIIS_Account_Geolocation__c> accountGeolocations = [
            SELECT Id, CIIS_Account__c, CIIS_Geolocations__c, CIIS_Status__c
            FROM CIIS_Account_Geolocation__c
        ];

        System.assertEquals(
            1,
            geolocations.size(),
            'Geolocation should be created'
        );
        System.assertEquals(
            1,
            accountGeolocations.size(),
            'Account Geolocation should be created'
        );
    }
}