public class IETRS_CustomLookupController {
        @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName,String fieldAPIName, string Usingphoneticsearch,String FilerCondition) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        string querystring ='' ;
        List < sObject > returnList = new List < sObject > ();
      /*string theSearchParam = Soundex.toSoundex(searchKeyWord );
      if(Usingphoneticsearch == 'True'){
      querystring  = 'or FirstNameSoundexKey__c =:theSearchParam or LastNameSoundexKey__c=:theSearchParam order by createdDate DESC limit 5';
      }else{
      querystring  = 'order by createdDate DESC limit 5' ;
      }*/
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5           
       // or FirstNameSoundexKey__c =:theSearchParam or LastNameSoundexKey__c=:theSearchParam order by createdDate DESC limit 5';
     
       List < sObject > lstOfRecords = new List < sObject >();
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}