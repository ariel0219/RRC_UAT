global class SCRIPT_SubtypeMigrationGetPkgBatch implements Database.Batchable<SObject>{
  
  List<Account> accountList;
  Boolean autoId;
  List<String> unitIds;
  List<String> autoUnitIds;
  
  //ctor
  global SCRIPT_SubtypeMigrationGetPkgBatch (List<Account> accountList, Boolean autoId) {
    this.accountList = accountList;
    this.autoId = autoId;
    unitIds = new List<String>();
    autoUnitIds = new List<String>();

    for(Account acc : accountList) {
      if(acc.IETRS_Unit_ID__c != null) {
        unitIds.add(acc.IETRS_Unit_ID__c);
      }
      else {
        autoUnitIds.add(acc.IETRS_Unit_Auto_ID__c);
      }
    }
    System.debug('untIds size: ' + unitIds.size());
    System.debug('autoId size: ' + autoUnitIds.size());

  }

  //batch start method
  global Database.QueryLocator start(Database.BatchableContext BC){
    String query = 'SELECT Id, IETRS_Inspection_Sub_Type__c, IETRS_Unit_ID__c ' +
                   'FROM IETRS_Inspection_Package__c ' +
                   'WHERE IETRS_Unit_ID__c IN ';
    if(autoId == false) {
      query += ':unitIds';
    }
    else {
      query += ':autoUnitIds';
    }

    return Database.getQueryLocator(query);
    
  }   

  //batch execute method
  global void execute(Database.BatchableContext BC, List<IETRS_Inspection_Package__c> records){

    Map<String, Set<String>> pkgmap = new Map<String, Set<String>>(); //<unitId, subtypes>
    for(IETRS_Inspection_Package__c p : records) {
      if(p != null) {
        String unitId = p.IETRS_Unit_ID__c;
       if(!pkgmap.containsKey(p.IETRS_Unit_ID__c))
       {

        Set<String> subtype = new Set<String>();
        subtype.add(p.IETRS_Inspection_Sub_Type__c);
        pkgmap.put(unitId, subtype);
       }
       else {
        Set<String> subtypeSet = pkgmap.get(unitId);
        subtypeSet.add(p.IETRS_Inspection_Sub_Type__c);
        pkgmap.put(unitId, subtypeSet);
       }
      }
      
    }

    for(Account acc : accountList) {
      if(acc.IETRS_Unit_ID__c != null && autoId == false) { //for those already have unit Id
        if(pkgmap.get(acc.IETRS_Unit_ID__c) != null) {
        Set<String> subtypes = pkgmap.get(acc.IETRS_Unit_ID__c);
        String res = '';
        for(String s : subtypes) {
          res += s;
          res += ';';
        }
        res = res.substring(0, res.length() - 1);
        System.debug(res);
        //acc.IETRS_Open_Inspection_SubTypes__c = res;
        //update acc;
        }
        else {
          String res ='';
          //acc.IETRS_Open_Inspection_SubTypes__c = res;
          //update acc;
        }

        
      }
      else if(acc.IETRS_Unit_ID__c == null && autoId == true) {
        if(pkgmap.get(acc.IETRS_Unit_Auto_ID__c) != null) {
          Set<String> subtypes = pkgmap.get(acc.IETRS_Unit_Auto_ID__c);
        String res = '';
        for(String s : subtypes) {
          res += s;
          res += ';';
        }
        res = res.substring(0, res.length() - 1);
        System.debug(res);
        //acc.IETRS_Open_Inspection_SubTypes__c = res;
        //update acc;
        }
        else {
          String res ='';
          //acc.IETRS_Open_Inspection_SubTypes__c = res;
          //update acc;
        }
        
      }
    }
  }
    
  

  //batch finish method
  global void finish(Database.BatchableContext BC) {

  }
}