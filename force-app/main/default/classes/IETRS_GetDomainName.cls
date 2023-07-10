public with sharing class IETRS_GetDomainName {
    @AuraEnabled
    public static string getDomainName(){
        String urlInstance=String.valueof(System.URL.getSalesforceBaseURL().gethost());
	    String strDomain=urlInstance.removeEndIgnoreCase('.my.salesforce.com');
	    return strDomain;
    }
}