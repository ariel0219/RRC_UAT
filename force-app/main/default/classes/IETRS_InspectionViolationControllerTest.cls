@isTest(seeAllData=false)
public class IETRS_InspectionViolationControllerTest {
    public static testmethod void testgetviolations(){
        Account a = new Account(name='test account');
        insert a;
        IETRS_Inspection_Package__c objInspPkg = new IETRS_Inspection_Package__c();
        objInspPkg.IETRS_Inspection_Type__c = 'Standard';
        objInspPkg.IETRS_Uncorrected_Status__c = 'Waiting for POC' ;
        insert objInspPkg;

        Id inspRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName()
            .get('PS_Inspection_Distribution_Systems')
            .getRecordTypeId();
        IETRS_Inspection__c objInsp = new IETRS_Inspection__c();
        objInsp.IETRS_Inspection_Package__c = objInspPkg.Id;
        objInsp.IETRS_Inspection_Status__c = 'Incomplete';
        objInsp.IETRS_Regulated_Entity__c = a.Id;
        objInsp.RecordTypeId = inspRecordTypeId;
        insert objInsp;
        Test.startTest();
        IETRS_InspectionViolationController.getViolations(objInsp.id);
        IETRS_InspectionViolationController.getstatus(objInspPkg.id);
        Test.stopTest();
    }
    
    static testMethod void testcreatePOCs(){
        Account a = new Account(name='test account');
        insert a;
        
        IETRS_Inspection_Package__c inspPkg = new IETRS_Inspection_Package__c();
        inspPkg.IETRS_Inspection_Type__c = 'Standard';
        inspPkg.IETRS_Uncorrected_Status__c = 'Waiting for POC' ;
        inspPkg.IETRS_Status__c = 'Waiting for Response';
        insert inspPkg;
        
        Id inspRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName().get('PS_Inspection_Distribution_Systems').getRecordTypeId();
        Date estimatedcompletiondate = system.today().addDays(10);
        Date completiondate = system.today();
        IETRS_Inspection__c objInsp = new IETRS_Inspection__c();
        objInsp.IETRS_Inspection_Package__c = inspPkg.Id;
        objInsp.IETRS_Inspection_Status__c = 'Approved';
        objInsp.IETRS_Regulated_Entity__c = a.Id;
        objInsp.RecordTypeId = inspRecordTypeId;
        insert objInsp;
        
        IETRS_Violation__c vio = new IETRS_Violation__c();
        vio.IETRS_Regulated_Entity__c = a.Id;
        vio.IETRS_Inspection_Package__c = inspPkg.Id;
        vio.IETRS_Inspection__c = objInsp.Id;
        vio.IETRS_POC_Exists__c = false;
        insert vio;
        
        List<Id> vioIdList = new List<Id>();
        for(IETRS_Violation__c violation : [select Id from IETRS_Violation__c where Id = :vio.Id]){
            vioIdList.add(violation.Id);
        }
        
        IETRS_Insp_Plan_of_Correction__c poc = new IETRS_Insp_Plan_of_Correction__c();
        poc.IETRS_Violation__c = vio.Id;
        poc.IETRS_Related_Inspection_Package__c = inspPkg.Id;
        poc.IETRS_Inspection__c = objInsp.Id;
        poc.IETRS_POC_Status__c = 'Pending Approval';
      //  insert poc;
        
        test.startTest();
         IETRS_InspectionViolationController.createPOCs(vioIdList, estimatedcompletiondate, completiondate, inspPkg.Id);
         IETRS_InspectionViolationController.getpocrecordsperviolation(poc.Id);
         IETRS_InspectionViolationController.updatePOCs(vioIdList, estimatedcompletiondate, completiondate);
         IETRS_InspectionViolationController.checkPOCValidation(vioIdList);
        test.stopTest();
        
    }

}