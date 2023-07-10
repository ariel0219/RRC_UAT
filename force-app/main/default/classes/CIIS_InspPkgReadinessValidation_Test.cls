@IsTest
public class CIIS_InspPkgReadinessValidation_Test {
    @IsTest
    static void CIIS_InspPkgReadinessValidation_Dis_Test() {
        //get the record type id for organziation on the account object
        String orgRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Organization'
            LIMIT 1
        ]
            .Id;
        
        //create a county group to pass triggered flows
        IETRS_County_Group__c countyGroup = new IETRS_County_Group__c(
            Name = 'test county',
            IETRS_Group_Type__c = 'Region',
            IETRS_Business_Area__c = 'Pipeline Safety'
        );
        insert countyGroup;
        
        //get the record type id for regulated entity on the account object
        String reRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Regulated Entity - PS'
            LIMIT 1
        ]
            .Id;
        
        //records to test for distribution inspection
        //create a organziation account record for distribution
        Account accDisOrg = new Account(
            Name = 'Test Org',
            RecordTypeId = orgRecordType,
            IETRS_Company_ID__c = '00001'
        );
        insert accDisOrg;
        //create a regulated entity account record for distribution
        Account accDisRE = new Account(
            Name = 'Test Org',
            ParentId = accDisOrg.Id,
            Type = 'Distribution',
            RecordTypeId = reRecordType,
            IETRS_Product_Class__c = 'Gas',
            IETRS_Jurisdiction__c = 'Jurisdictional',
            IETRS_Intra_Interstate__c = 'Intrastate',
            IETRS_Entity_Sub_Type__c = 'Private Main System',
            IETRS_Total_Miles__c = 1,
            IETRS_On_Offshore__c = 'Onshore',
            IETRS_Product_Sub_Class__c = 'Natural',
            IETRS_Install_Year__c = '2000',
            IETRS_T4_Permit__c = '12345'
        );
        insert accDisRE;
        //create a miles by county record to pass triggered flows
        IETRS_Insp_Miles_by_County__c disCountyMiles = new IETRS_Insp_Miles_by_County__c(
            IETRS_Regulated_Entity__c = accDisRE.Id,
            IETRS_Miles__c = 10
        );
        insert disCountyMiles;
        //create an inspection package for a distribution inspection package
        IETRS_Inspection_Package__c disInspPkg = new IETRS_Inspection_Package__c(
            IETRS_Inspection_Type__c = 'Standard',
            IETRS_Organization__c = accDisOrg.Id,
            recordTypeId = Schema.SObjectType.IETRS_Inspection_Package__c.getRecordTypeInfosByName().get('Inspection Package - Critical Infrastructure').getRecordTypeId()
        );
        insert disInspPkg;
        //get the distribtuion inspection record type
        String disRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'CIIS Inspection'
            LIMIT 1
        ]
            .Id;
        //create a distribtuion inspection record that will fail the validation
        IETRS_Inspection__c disInspectionF = new IETRS_Inspection__c(
            IETRS_Inspection_Package__c = disInspPkg.Id,
            IETRS_Regulated_Entity__c = accDisRE.id,
            RecordTypeId = disRecordType
        );
        insert disInspectionF;
        //create a distribtuion inspection record that will pass the validation
        IETRS_Inspection__c disInspection = new IETRS_Inspection__c(
            IETRS_Inspection_Package__c = disInspPkg.Id,
            IETRS_Regulated_Entity__c = accDisRE.id,
            RecordTypeId = disRecordType
        );
        insert disInspection;
        
        //Create Geolocation child record
        CIIS_Geolocations__c geoRecord = new CIIS_Geolocations__c(
        	CIIS_Geolocation_Name__c = 'Test',
            CIIS_Inspection__c = disInspection.Id
        );
		Insert geoRecord;  
        
        //Create Facility Observation child record
        CIIS_Facility_Observations__c foRecord= new CIIS_Facility_Observations__c(
        	CIIS_Inspection_ID__c = disInspection.Id,
            CIIS_Inspection_Method__c = 'Temporary Windbreaks'
        );
        Insert foRecord;
        
        //prep list of ids to be passed into the tested method
        List<Id> idList = new List<Id>();
        idList.add(disInspPkg.Id);
        
        //now run each record through the tested class
        Test.startTest();
        CIIS_InspPkgReadinessValidation.CIIS_InspPkgReadinessValidation(
            idList
        );
        Test.stopTest();
    }
}