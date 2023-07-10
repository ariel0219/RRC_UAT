/**
 * @File Name          : IETRS_ClassTriggerHandlerTest.class
 * @Description        : 
 * @Author             : Ronald Stewart
 * @Group              : 
 * @Last Modified By   : Ronald Stewart
 * @Last Modified On   : 10/15/2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0        10/15/2020               Ronald Stewart             Initial Version
**/
@isTest
public class IETRS_ClassTriggerHandlerTest {
    @testSetup static void setup(){
        //Record type ids for Oraginazation and Hearings
        Id orgRTid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        Id hearingsRTid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Hearings').getRecordTypeId();
        
        //Create Primary Account Assignment
        Account acc = new Account();
        acc.RecordTypeId = orgRTid;
        acc.name = 'Test Account';
        insert acc;
        //Create Case records (1 child, 1 parent)
        Case parentCS = new Case();
        parentCS.SuppliedName = 'Test Parent';
        parentCS.IETRS_Primary_Account_Assignment__c = acc.Id;
        insert parentCS;
        
        Case childCS = new Case();
        childCS.SuppliedName = 'Test Child';
        childCS.IETRS_Primary_Account_Assignment__c = acc.Id;
        childCS.ParentId = parentCS.Id;
        insert childCS;
        
        System.debug('Child name: '+childCS.SuppliedName);
        System.debug('Parent name: '+parentCS.SuppliedName);
    }
    @isTest static void checkIfIsParentCase(){
        List<Case> caseList = [select IETRS_Is_Parent_Case__c,SuppliedName 
                               from case where SuppliedName in: new List<String>{'Test Parent','Test Child'}];
        Case updateChild = new Case();
        for(Case item:caseList){
            if(item.SuppliedName == 'Test Child'){
                updateChild = item;
                break;
            }
        }
        Test.startTest();
        updateChild.ParentId = null;
        update updateChild;
        Test.stopTest();
    }
}