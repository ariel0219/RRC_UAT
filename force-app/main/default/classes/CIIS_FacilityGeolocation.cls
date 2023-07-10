public with sharing class CIIS_FacilityGeolocation {
    @AuraEnabled
    public Decimal latitude { get; set; }

    @AuraEnabled
    public Decimal longitude { get; set; }

    @AuraEnabled
    public Id accountId { get; set; }

    @AuraEnabled
    public String accountName { get; set; }

    @AuraEnabled
    public String facilityType { get; set; }

    @AuraEnabled
    public String nameAndCoordinates {
        get {
            return accountName + ' (' + latitude + ', ' + longitude + ')';
        }
    }
}