@isTest
public without sharing class IETRS_FC_Delete_Override_Test {
    @isTest
    public static void testSuccessDelete() {

        IETRS_Files_Correspondence__c fileCorrespondence = new IETRS_Files_Correspondence__c();
    	fileCorrespondence.IETRS_Box_File_ID__c = '462262211131';
        insert fileCorrespondence;
        
		Test.startTest();
        IETRS_FC_Delete_Override pageTest = new IETRS_FC_Delete_Override(new ApexPages.StandardController(fileCorrespondence));
        pageTest.deleteFC();
        Test.stopTest();
        

    }
    @IsTest
    static void testFailedDelete(){
        
        IETRS_Inspection_Package__c objInspPkg = new IETRS_Inspection_Package__c();
        objInspPkg.IETRS_Inspection_Type__c = 'Standard';
        insert objInspPkg;
        
        IETRS_Files_Correspondence__c objFilesCorres = new IETRS_Files_Correspondence__c();
        objFilesCorres.IETRS_Inspection_Package__c = objInspPkg.Id;
        insert objFilesCorres;

        String strUserName = 'inspector' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='IETRS Inspections - Inspector'];
        User uTest = new User(Alias = 'insptest', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName=strUserName
                              );
        try{
            Test.startTest();
            system.runAs(uTest){
                IETRS_FC_Delete_Override pageTest = new IETRS_FC_Delete_Override(new ApexPages.StandardController(objFilesCorres));
                pageTest.deleteFC();
            }
            Test.stopTest();
        }
        catch(DMLException excp){
            System.assert(excp.getMessage().contains('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.'));
        }
        
    }
}