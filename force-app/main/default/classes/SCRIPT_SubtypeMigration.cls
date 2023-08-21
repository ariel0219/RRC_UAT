/**
 * @File Name          : SCRIPT_SubtypeMigration
 * @Description        : 
 * @Author             : Ariel Zhang
 * @Group              : 
 * @Last Modified By   : Ariel Zhang
 * @Last Modified On   : 08/20/2022
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0        08/20/2022               Ariel Zhang             Initial Version
**/
public with sharing class SCRIPT_SubtypeMigration {


  public static void test(){
    Set<String> mySet = new Set<String>();
    mySet.add('A');
    mySet.add('B');
    mySet.add('C');
    mySet.add('D');

    String res = '';
    for(String s : mySet) {
      res += s;
      res += ';';
    }
    System.debug('result: ' + res);
    System.debug('substring ' + res.substring(0, res.length() - 1));
    

  }

  public static void migrateUnCompleteClosedSubtypeFromPkgToAcc() {
    
    
    List<Account> accountsList = [SELECT Id, IETRS_Unit_Auto_ID__c , IETRS_Unit_ID__c,IETRS_Open_Inspection_SubTypes__c 
                                  FROM Account WHERE 
                                  IETRS_Account_Record_Type__c='Unit'];

    System.debug('raw unitId size: '+ accountsList.size());
    Database.executeBatch(new SCRIPT_SubtypeMigrationGetPkgBatch(accountsList, true), 2000);
    Database.executeBatch(new SCRIPT_SubtypeMigrationGetPkgBatch(accountsList, false), 2000);

    
    }
}