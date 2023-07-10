public class LwcLookupController {  
   
  
  @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(String searchKey, String objectName) {  
      string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
      string query = 'SELECT Id, Name,IETRS_Company_ID__c FROM ' +objectName+ ' WHERE IETRS_Company_ID__c LIKE '+searchText+' LIMIT 6';  
      return Database.query('SELECT Id, Name,IETRS_Company_ID__c FROM ' +objectName+ ' WHERE IETRS_Company_ID__c LIKE '+searchText+' LIMIT 6');  
    }  


    @AuraEnabled(cacheable=true)  
    public static List<sobject> findaccRecords(String searchKey, String objectName) {  
      string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
      string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 6';  
      return Database.query('SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 6');  
    }  
	
	@AuraEnabled(cacheable=true)  
	public static List<sobject> fetchP5NumberBasenontheRecordTypes(String searchKey, String objectName, String Recordtypename){
	string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\''; 
	String psRecordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Recordtypename).getRecordTypeId();	
	return Database.query('SELECT Id, Name,IETRS_P5_Number__c FROM ' +objectName+ ' WHERE RecordtypeId =:psRecordtypeID AND IETRS_P5_Number__c LIKE '+searchText+' LIMIT 6');  
	}
	
	@AuraEnabled(cacheable = true)
	public static List<Sobject> fetchAccountRecordBasedOntheRecordType(String searchKey, String objectName, String Recordtypename){
	string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
	String psRecordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Recordtypename).getRecordTypeId();
	return Database.query('SELECT Id, Name FROM ' +objectName+ ' WHERE RecordtypeId =:psRecordtypeID AND Name LIKE '+searchText+' LIMIT 6');  

  }
    //Added by Ayesha on 15th DEC 2020
    //Purpose: To get the records based on the Operator name or P5 number
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findaccRecordsBasedOnOperatorName(String searchKey, String objectName, String operatorid, String p5numberid) {  
      string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';
      string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText;
      List<string> conditions = new List<String>();
            
      if(String.isNotBlank(operatorid))
          conditions.add('Parent.ParentID =:operatorid');

      if(String.isNotBlank(p5numberid))
        conditions.add('Parent.ParentID =:p5numberid');

      if(conditions.size() > 0) {
          for(Integer i = 0; i < conditions.size(); i++){
            query += '  AND ' + conditions[i];
          }
      }
        //query+=' AND (ParentID=\''+operatorid+'\' OR ParentId=\''+p5numberid+'\')';
      
      query += ' LIMIT 6';  
      System.debug('findaccRecordsBasedOnOperatorName=>'+query);
      return Database.query(query);  
    } 
  }