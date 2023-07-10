@isTest
public  class IETRS_Conga_Doc_Gen_Controller_Test {
    @TestSetup
    static void makeData() {

        IETRS_Conga_Template_Mapping__mdt metaCongaMapping = [SELECT IETRS_Template_Name__c, IETRS_Query_Alias__c, pv0__c, IETRS_Additional_Parameters__c
                                                              FROM IETRS_Conga_Template_Mapping__mdt WHERE DeveloperName = 'Test_Class_Record' LIMIT 1];

        APXTConga4__Conga_Merge_Query__c cqryTestRecord = new APXTConga4__Conga_Merge_Query__c(IETRS_Query_Alias__c = '[Query1]');
        insert cqryTestRecord;

        APXTConga4__Conga_Template__c ctmplTestTemplate = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'TestTemplateName');
        insert ctmplTestTemplate;

        IETRS_Files_Correspondence__c fcRecord = new IETRS_Files_Correspondence__c(
            IETRS_Conga_Template_ID__c = ctmplTestTemplate.Id,
            IETRS_Business_Area_Division__c = '	Pipeline Safety',
            IETRS_Document_Type__c = 'Application'
        );

        insert fcRecord;
    }
    
    @isTest
    public static void generateURL_Test() {

        IETRS_Files_Correspondence__c fcRecord = [SELECT Id, IETRS_Conga_Template_ID__c, IETRS_Conga_Document_Name__c 
                                                  FROM IETRS_Files_Correspondence__c LIMIT 1];
                                                  
        IETRS_Conga_Template_Mapping__mdt metaCongaMapping = [SELECT IETRS_Template_Name__c, IETRS_Query_Alias__c, pv0__c, IETRS_Additional_Parameters__c
                                                              FROM IETRS_Conga_Template_Mapping__mdt WHERE DeveloperName = 'Test_Class_Record'][0];           

        String strActualURL = IETRS_Conga_Doc_Gen_Controller.generateURL(fcRecord.Id, 'IETRS_Files_Correspondence__c');

        String strCongaQueryID = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c WHERE IETRS_Query_Alias__c = '[Query1]' LIMIT 1].Id;

        String strExpectedURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/APXTConga4__Conga_Composer?serverUrl=' + URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/37.0/' + UserInfo.getOrganizationId() +
        '&id=' + fcRecord.Id +
        '&TemplateiD=' + fcRecord.IETRS_Conga_Template_ID__c +
        '&OFN=' + fcRecord.IETRS_Conga_Document_Name__c +
        '&DS7=11' +
        '&DefaultPDF=1'+
        '&QueryID=' + metaCongaMapping.IETRS_Query_Alias__c + strCongaQueryID + '?pv0=' + fcRecord.Id;

        system.debug(strExpectedURL);
        system.debug(strActualURL);
        system.assertEquals(strExpectedURL, strActualURL);

    }
    
    @isTest
    public static void isFilesAndCorrespondingOfPS_PACDA_Test() {

        APXTConga4__Conga_Template__c ctmplTestTemplate2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'TestTemplateName2');
        insert ctmplTestTemplate2;

        IETRS_Files_Correspondence__c fcRecord = new IETRS_Files_Correspondence__c(
            IETRS_Conga_Template_ID__c = ctmplTestTemplate2.Id,
            IETRS_Business_Area_Division__c = '	Pipeline Safety',
            IETRS_Document_Type__c = 'POC Approved - Completion Date Assigned'
        );

        insert fcRecord;
        
        IETRS_Conga_Doc_Gen_Controller.isFilesAndCorrespondingOfPS_PACDA(fcRecord.Id);
        IETRS_Conga_Doc_Gen_Controller.checkisIETRSCorrespondenceDatebalnk(fcRecord.Id);

    }
    
}