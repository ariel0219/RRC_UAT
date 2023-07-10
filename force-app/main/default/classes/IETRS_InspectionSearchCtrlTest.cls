@isTest
public class IETRS_InspectionSearchCtrlTest {
    
    @testSetup
    static void createData(){
        
        IETRS_County_Group__c objCountyGrp = new IETRS_County_Group__c();
        objCountyGrp.Name = '00-Statewide';
        objCountyGrp.IETRS_Group_Type__c = 'Region';
        objCountyGrp.IETRS_Business_Area__c = 'Pipeline Safety';
        insert objCountyGrp;
        
        
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();      
        
        Account objAcc1 = new Account(Name = 'Regulated Entity PS Parent',RecordTypeId = accOrgRecordTypeId, IETRS_Company_ID__c = '12345', BillingStreet = 'River Side', BillingCity = 'IRVING', BillingState = 'TX', BillingCountry='USA' );   
        insert objAcc1;
        
          IETRS_Inspection_Package__c objInspPkg = new IETRS_Inspection_Package__c();
        objInspPkg.IETRS_Inspection_Type__c = 'Standard';
        objInspPkg.IETRS_Organization__c = objAcc1.Id;
        insert objInspPkg;
        
        IETRS_Incident__c objIncident = new IETRS_Incident__c();
        objIncident.IETRS_Incident_Date__c = System.today();
        insert objIncident;
    }
    
    @isTest
    static void testInspSearchCtrl(){
        IETRS_InspectionSearchCtrl.getsObjects();
        IETRS_InspectionSearchCtrl.getFieldSetMember('IETRS_Incident__c');
        Map<String, Object> filterMap = new Map<String, Object>();
        Date sDate = Date.today();
        Date eDate = Date.today().addDays(13);
        filterMap.put('IETRS_Incident_Date__c',sDate);
        filterMap.put('IETRS_Incident_Date__c_E',eDate );
        filterMAp.put('Name','*INCI');
        
        String filterJSON = JSON.serialize(filterMap);
        IETRS_InspectionSearchCtrl.displayObjResults('IETRS_Incident__c',filterJSON);
        filterMap.remove('IETRS_Incident_Date__c_E');
        filterJSON = JSON.serialize(filterMap);
        IETRS_InspectionSearchCtrl.displayObjResults('IETRS_Incident__c',filterJSON);
        
        filterMap = new Map<String,Object>();
        Map<String,Object> filterNestMap = new Map<String,Object>();
        filterNestMap.put('IETRS_Account_ID__c','12345');
        filterMap.put('IETRS_Organization__r',filterNestMap);
        filterJSON = JSON.serialize(filterMap);
        IETRS_InspectionSearchCtrl.displayObjResults('IETRS_Inspection_Package__c',filterJSON);
        
        
    }

}