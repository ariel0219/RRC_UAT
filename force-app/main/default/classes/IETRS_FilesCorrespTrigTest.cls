@isTest
public class IETRS_FilesCorrespTrigTest {
    @testSetup
    static void prepareData(){
        
        IETRS_Inspection_Package__c objInspPkg = new IETRS_Inspection_Package__c();
        objInspPkg.IETRS_Inspection_Type__c = 'Standard';
        insert objInspPkg;
        
        IETRS_Files_Correspondence__c objFilesCorres = new IETRS_Files_Correspondence__c();
        objFilesCorres.IETRS_Inspection_Package__c = objInspPkg.Id;
        insert objFilesCorres;
    }
    
    static testmethod void testDeleteInsp(){

        String strUserName = 'inspector' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='IETRS Inspections - Inspector'];
        User uTest = new User(Alias = 'insptest', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName=strUserName
                              );
        delete [SELECT Id FROM IETRS_Files_Correspondence__c];
 
        System.runAs(uTest) {
            IETRS_Inspection_Package__c objInspPkg = new IETRS_Inspection_Package__c();
            objInspPkg.IETRS_Inspection_Type__c = 'Standard';
            insert objInspPkg;
            
            IETRS_Files_Correspondence__c objFilesCorres = new IETRS_Files_Correspondence__c();
            objFilesCorres.IETRS_Inspection_Package__c = objInspPkg.Id;
            insert objFilesCorres;
            try{
                delete [SELECT Id FROM IETRS_Files_Correspondence__c];
            }
            catch(DMLException excp){
                System.assert(excp.getMessage().contains('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.'));
            }
              
          }
        
    }
}