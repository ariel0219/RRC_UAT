public with sharing class IETRS_CommActionCasesController {
  
   @AuraEnabled(cacheable=false)
    public static list<case> getCaseList(boolean searchKey1, string searchKey2, date searchKey3, string strCommissionActionId) {
      boolean sTempSearchKey1 = searchKey1;
      string sTempSearchKey2 = searchKey2 != null ? + searchKey2 : '';
      date sTempSearchKey3 = null;
      date keyDate = null;
      if(searchKey3 != null){
        sTempSearchKey3 = searchKey3;
        keyDate = date.newinstance(sTempSearchKey3.year(), sTempSearchKey3.month(), sTempSearchKey3.day());
      } else{
        keyDate = null;
      }
        
      // create contact list to store search result 
      list<case> lstCase = new list<case>();

      //Build the base of the query string
      String strDynamicQuery = 'SELECT id, CaseNumber, IETRS_Primary_Account_Assignment__c, IETRS_Primary_Account_Assignment__r.Name, IETRS_Ready_for_Conference__c, IETRS_Agenda_Section__c, IETRS_Conference_Date__c FROM Case WHERE Id NOT in (Select IETRS_Case__c From IETRS_Commission_Action_Assignment__c WHERE IETRS_Commission_Action__c = :strCommissionActionId) AND IETRS_Ready_for_Conference__c = :sTempSearchKey1';
     
      //If a value was passed for Conference Date then append the AND statement to the WHERE clause
      strDynamicQuery = keyDate != null ? strDynamicQuery + ' AND IETRS_Conference_Date__c = :keyDate' : strDynamicQuery;

      //If a value was passed for Agenda Section then append the AND statement to the WHERE clause
      strDynamicQuery = sTempSearchKey2 != '' ? strDynamicQuery + ' AND IETRS_Agenda_Section__c LIKE :sTempSearchKey2' : strDynamicQuery;

      //Limit results to 100 at a time
      strDynamicQuery = strDynamicQuery + ' LIMIT 100';

      //Protect against SOQL injection
      strDynamicQuery = String.escapeSingleQuotes(strDynamicQuery);

      //Return the result of the list of cases
      lstCase = Database.query(strDynamicQuery);

      //If there are no records found with searchKey then, throw aura exception with a message
      if(lstCase.size() == 0){
        throw new AuraHandledException('No Record Found'); 
      }

      return lstCase;      
    }
}