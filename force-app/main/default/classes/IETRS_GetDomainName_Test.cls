@isTest
public inherited sharing class IETRS_GetDomainName_Test {
@IsTest
static void getDomainTest(){
    
    Test.startTest();
    String urlInstance=String.valueof(System.URL.getSalesforceBaseURL().gethost());
    String strExpected =urlInstance.removeEndIgnoreCase('.my.salesforce.com');
    String strResult = IETRS_GetDomainName.getDomainName();
    Test.stopTest();
    system.assert(strResult == strExpected);
    
}
}