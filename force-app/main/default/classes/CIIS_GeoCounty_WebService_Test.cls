@isTest
public class CIIS_GeoCounty_WebService_Test {
    
    @isTest
    static void testMethod1(){
        Test.setMock(HttpCalloutMock.class, new CIIS_GeoCounty_WebService_Mock());
        CIIS_GeoCounty_WebService.requestParameters rp = new CIIS_GeoCounty_WebService.requestParameters();
        rp.county = 'Test';
        rp.latitude = 45.99999;
        rp.longitude = -65.99999;
        List<CIIS_GeoCounty_WebService.requestParameters> rpList = new List<CIIS_GeoCounty_WebService.requestParameters>{rp};
            CIIS_GeoCounty_WebService.CIIS_CallGeolocationCountyService(rpList);
    }
}