@isTest
public class IETRS_InspectionPkgTrigTest {
	@testSetup
    static void prepareData(){
        
        IETRS_Inspection_Package__c objInspPkg = new IETRS_Inspection_Package__c();
        objInspPkg.IETRS_Inspection_Type__c = 'Standard';
        insert objInspPkg;
    }
    
    static testmethod void testDeleteInspPkg(){
        delete [SELECT Id FROM IETRS_Inspection_Package__c];
    }
}