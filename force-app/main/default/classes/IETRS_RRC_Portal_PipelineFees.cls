public with sharing class IETRS_RRC_Portal_PipelineFees {
    
    @AuraEnabled(cacheable=true)
      
    public static List<	IETRS_Insp_Regulated_Fee__c> getPipelineFeesList() {
      String strContactID = [SELECT ContactID FROM User WHERE Id = :UserInfo.getUserID() LIMIT 1].ContactId;      

      List<AccountContactRelation> lstRel = [SELECT AccountId FROM AccountContactRelation WHERE ContactId = :strContactID];
      Set<Id> setAccts = new Set<Id>();
      for (AccountContactRelation rel : lstRel){
        setAccts.add(rel.AccountId);
      }

      return [SELECT Name, IETRS_Fee_Date__c, IETRS_Fee_Type__c, IETRS_Total_Regulated_Fee_Amount_Due__c, IETRS_Status__c 
            FROM IETRS_Insp_Regulated_Fee__c
            WHERE IETRS_Organization__c in :setAccts
             LIMIT 100];
           
      }
  }