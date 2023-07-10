@isTest
public class CustomReportControllerTest {
    @TestSetup
    static void makeData() {
        IETRS_Coutries__c countys=new IETRS_Coutries__c();
        countys.Country_Names__c='Test1;Test2';
            insert countys;
         IETRS_County__c county=new IETRS_County__c();
        county.Name='Test1';
            insert county;
        IETRS_SystemType__c sysTypeNames=new IETRS_SystemType__c();
        sysTypeNames.SystemType_Name__c='Test1;Test2';
            insert sysTypeNames;
    }

    @isTest
    private static void getRegion_County_SystemType_Names() {
        List<String> regionNames=CustomReportController.getRegionNames();
        List<String> countyNames=CustomReportController.getCountyNames();
        List<String> systemTypeNames=CustomReportController.getSystemTypes();
    }
}