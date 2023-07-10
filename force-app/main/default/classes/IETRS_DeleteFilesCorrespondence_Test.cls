/**
 * @File Name          : IETRS_DeleteFilesCorrespondence_Test.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 5/26/2020, 2:07:28 PM
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      05/26/2020      Kevin Lu                Initial Version
**/
@IsTest
public class IETRS_DeleteFilesCorrespondence_Test {
    @TestSetup
    static void makeData(){
        Account a = new Account();
        a.Name = 'Test Organization';
        insert a;

        Case c = new Case();
        c.IETRS_Primary_Account_Assignment__c = a.Id;
        insert c;

        IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c();
        fc.IETRS_Case__c = c.Id;
        insert fc;
    }

    @IsTest
    static void testDeleteRecord(){
        List<Id> lstRecordId = new List<Id>();
        for(IETRS_Files_Correspondence__c record : [Select Id From IETRS_Files_Correspondence__c]) {
            lstRecordId.add(record.Id);
        }
        System.assertEquals(1, lstRecordId.size(), 'Initial FC record count is incorrect');
        IETRS_DeleteFilesCorrespondence.deleteFilesCorrespondence(lstRecordId);

        List<IETRS_Files_Correspondence__c> lstFiles = [Select Id From IETRS_Files_Correspondence__c];
        System.assertEquals(0, lstFiles.size(), 'Final FC record count is incorrect');
        
    }
}