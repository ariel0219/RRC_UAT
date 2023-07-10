@isTest
public class IETRS_MilesOfPipeBySizeHelper_Test {  
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
 
        System.runAs(uTest) {
            IETRS_Inspection_Package__c objInspPkg = new IETRS_Inspection_Package__c();
            objInspPkg.IETRS_Inspection_Type__c = 'Standard';
            insert objInspPkg;

            IETRS_County_Group__c objCounty = new IETRS_County_Group__c();
            objCounty.Name = 'Test County';
            objCounty.IETRS_Group_Type__c = 'Region';
            objCounty.IETRS_Business_Area__c = 'Pipeline Safety';
            insert objCounty;

            String strRecordType = [SELECT Id FROM RecordType WHERE Name='Regulated Entity - PS' Limit 1].Id;
            Account objRegulatedEnt = new Account();
            objRegulatedEnt.Name = 'Test RE';
            objRegulatedEnt.RecordTypeId = strRecordType;
            objRegulatedEnt.IETRS_Region__c = objCounty.Id;

            insert objRegulatedEnt;

            IETRS_Inspection__c objInspection = new IETRS_Inspection__c();
            objInspection.IETRS_Inspection_Package__c = objInspPkg.Id;
            objInspection.IETRS_Inspection_Status__c = 'Incomplete';
            objInspection.IETRS_Regulated_Entity__c = objRegulatedEnt.Id;
            insert objInspection;            

            IETRS_Miles_of_Pipe_by_Size__c objMilePipeSize = new IETRS_Miles_of_Pipe_by_Size__c();
            objMilePipeSize.IETRS_Inspection__c = objInspection.Id;
            insert objMilePipeSize;

            IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c objMilePipeSizeGL = new IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c();
            objMilePipeSizeGL.IETRS_Inspection__c = objInspection.Id;
            insert objMilePipeSizeGL;

            IETRS_Miles_of_Pipe_by_Size_MM__c objMilePipeSizeMM = new IETRS_Miles_of_Pipe_by_Size_MM__c();
            objMilePipeSizeMM.IETRS_Inspection__c = objInspection.Id;
            insert objMilePipeSizeMM;

            try{
                delete [SELECT Id FROM IETRS_Miles_of_Pipe_by_Size__c];
            }
            catch(DMLException excp){
                System.assert(excp.getMessage().contains('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.'));
            }

            try{
                delete [SELECT Id FROM IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c];
            }
            catch(DMLException excp){
                System.assert(excp.getMessage().contains('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.'));
            }

            try{
                delete [SELECT Id FROM IETRS_Miles_of_Pipe_by_Size_MM__c];
            }
            catch(DMLException excp){
                System.assert(excp.getMessage().contains('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.'));
            }
              
          }
        
    }
}