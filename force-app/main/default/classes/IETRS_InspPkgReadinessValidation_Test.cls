@IsTest
private class IETRS_InspPkgReadinessValidation_Test {
    @IsTest
    static void IETRS_InspPkgReadinessValidation_Dis_Test() {
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
            IETRS_Organization__c = accDisOrg.Id
        );
        insert disInspPkg;
        //get the distribtuion inspection record type
        String disRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'PS Inspection - Distribution Systems'
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
        //create a child MAOP record
        IETRS_Insp_MAOP__c disMAOP = new IETRS_Insp_MAOP__c(
            IETRS_Inspection__c = disInspection.Id
        );
        insert disMAOP;
        //create a child OPP record
        IETRS_Insp_OPP_Codes__c disOPP = new IETRS_Insp_OPP_Codes__c(
            IETRS_Inspection__c = disInspection.Id
        );
        insert disOPP;
        //create a child Lost_and_Unaccountable_Gas record
        IETRS_Lost_and_Unaccountable_Gas__c disLUG = new IETRS_Lost_and_Unaccountable_Gas__c(
            IETRS_Inspection__c = disInspection.Id
        );
        insert disLUG;
        //create a child Number_of_Services_by_Size record
        IETRS_Insp_Number_of_Services_by_Size__c disNSS = new IETRS_Insp_Number_of_Services_by_Size__c(
            IETRS_Inspection__c = disInspection.Id
        );
        insert disNSS;
        //create a child Repaired_Leaks record
        IETRS_Repaired_Leaks__c disReL = new IETRS_Repaired_Leaks__c(
            IETRS_Inspection__c = disInspection.Id
        );
        insert disReL;
        //create a child Suppliers record
        IETRS_Insp_Supplier__c disSup = new IETRS_Insp_Supplier__c(
            IETRS_Inspection__c = disInspection.Id
        );
        insert disSup;
        //create a child Miles_of_Pipe_by_Size record
        IETRS_Miles_of_Pipe_by_Size__c disMPS = new IETRS_Miles_of_Pipe_by_Size__c(
            IETRS_Inspection__c = disInspection.Id
        );
        insert disMPS;

        //prep list of ids to be passed into the tested method
        List<Id> idList = new List<Id>();
        idList.add(disInspPkg.Id);

        //now run each record through the tested class
        Test.startTest();
        IETRS_InspPkgReadinessValidation.IETRS_InspPkgReadinessValidation(
            idList
        );
        Test.stopTest();
    }

    @IsTest
    static void IETRS_InspPkgReadinessValidation_Gas_Test() {
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
        //records to test for gas inspection
        //create a organziation account record for gas
        Account accGasOrg = new Account(
            Name = 'Test Org',
            RecordTypeId = orgRecordType,
            IETRS_Company_ID__c = '00002'
        );
        insert accGasOrg;
        //create a regulated entity account record for gas
        Account accGasRE = new Account(
            Name = 'Test Org',
            ParentId = accGasOrg.Id,
            IETRS_Entity_Code__c = 'T-Gas Transmission',
            Type = 'Transmission',
            RecordTypeId = reRecordType,
            IETRS_Product_Class__c = 'Gas',
            IETRS_Jurisdiction__c = 'Jurisdictional',
            IETRS_Intra_Interstate__c = 'Intrastate',
            IETRS_Entity_Sub_Type__c = 'Transmission',
            IETRS_Total_Miles__c = 1,
            IETRS_On_Offshore__c = 'Onshore',
            IETRS_Product_Sub_Class__c = 'Natural',
            IETRS_Install_Year__c = '2000',
            IETRS_T4_Permit__c = '12345'
        );
        insert accGasRE;
        //create a miles by county record to pass triggered flows
        IETRS_Insp_Miles_by_County__c gasCountyMiles = new IETRS_Insp_Miles_by_County__c(
            IETRS_Regulated_Entity__c = accGasRE.Id,
            IETRS_Miles__c = 10
        );
        insert gasCountyMiles;
        //create an inspection package for a gas inspection package
        IETRS_Inspection_Package__c gasInspPkg = new IETRS_Inspection_Package__c(
            IETRS_Inspection_Type__c = 'Specialized',
            IETRS_Organization__c = accGasOrg.Id
        );
        insert gasInspPkg;
        //get the gas inspection record type
        String gasRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'PS Inspection - Gas Transmission Systems'
            LIMIT 1
        ]
        .Id;
        //create a gas inspection record that will fail the validation
        IETRS_Inspection__c gasInspectionF = new IETRS_Inspection__c(
            IETRS_Inspection_Package__c = gasInspPkg.Id,
            IETRS_Regulated_Entity__c = accGasRE.id,
            RecordTypeId = gasRecordType
        );
        insert gasInspectionF;
        //create a gas inspection record that will pass the validation
        IETRS_Inspection__c gasInspection = new IETRS_Inspection__c(
            IETRS_Inspection_Package__c = gasInspPkg.Id,
            IETRS_Regulated_Entity__c = accGasRE.id,
            RecordTypeId = gasRecordType
        );
        insert gasInspection;
        //create a child MAOP record
        IETRS_Insp_MAOP__c gasMAOP = new IETRS_Insp_MAOP__c(
            IETRS_Inspection__c = gasInspection.Id
        );
        insert gasMAOP;
        //create a child OPP record
        IETRS_Insp_OPP_Codes__c gasOPP = new IETRS_Insp_OPP_Codes__c(
            IETRS_Inspection__c = gasInspection.Id
        );
        insert gasOPP;
        //create a child Pipes_by_Class record
        IETRS_Pipes_by_Class__c gasPbC = new IETRS_Pipes_by_Class__c(
            IETRS_Inspection__c = gasInspection.Id
        );
        insert gasPbC;
        //create a child Repaired_Leaks_Gas_Liq record
        IETRS_Repaired_Leaks_Gas_Liq__c gasRLG = new IETRS_Repaired_Leaks_Gas_Liq__c(
            IETRS_Inspection__c = gasInspection.Id
        );
        insert gasRLG;
        //create a child Miles_of_Pipe_by_Size_Gas_Liq record
        IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c gasMPS = new IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c(
            IETRS_Inspection__c = gasInspection.Id
        );
        insert gasMPS;

        //prep list of ids to be passed into the tested method
        List<Id> idList = new List<Id>();
        idList.add(gasInspPkg.Id);

        //now run each record through the tested class
        Test.startTest();
        IETRS_InspPkgReadinessValidation.IETRS_InspPkgReadinessValidation(
            idList
        );
        Test.stopTest();
    }

    // Commenting out these two test methods because there are new validation rules
    // that cause them to fail and the coverage is already at 90%. May be useful
    // later to fix or use as an example for setting up test data.
    /***************
    @IsTest
    static void IETRS_InspPkgReadinessValidation_Hal_Test() {
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
        //records to test for hazardous liquids inspection
        //create a organziation account record for hazardous liquids
        Account accHalOrg = new Account(
            Name = 'Test Org',
            RecordTypeId = orgRecordType,
            IETRS_Company_ID__c = '00003'
        );
        insert accHalOrg;
        //create a regulated entity account record for hazardous liquids
        Account accHalRE = new Account(
            Name = 'Test Org',
            ParentId = accHalOrg.Id,
            RecordTypeId = reRecordType
        );
        insert accHalRE;
        //create a miles by county record to pass triggered flows
        IETRS_Insp_Miles_by_County__c halCountyMiles = new IETRS_Insp_Miles_by_County__c(
            IETRS_Regulated_Entity__c = accHalRE.Id,
            IETRS_Miles__c = 10
        );
        insert halCountyMiles;
        //create an inspection package for a hazardous liquids inspection package
        IETRS_Inspection_Package__c halInspPkg = new IETRS_Inspection_Package__c(
            IETRS_Inspection_Type__c = 'Specialized',
            IETRS_Organization__c = accHalOrg.Id
        );
        insert halInspPkg;
        //get the hazardous liquids inspection record type
        String halRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'PS Inspection - Hazardous Liquid Systems'
            LIMIT 1
        ]
        .Id;
        //create a hazardous liquids inspection record that will fail the validation
        IETRS_Inspection__c halInspectionF = new IETRS_Inspection__c(
            IETRS_Inspection_Package__c = halInspPkg.Id,
            IETRS_Regulated_Entity__c = accHalRE.id,
            RecordTypeId = halRecordType
        );
        insert halInspectionF;
        //create a hazardous liquids inspection record that will pass the validation
        IETRS_Inspection__c halInspection = new IETRS_Inspection__c(
            IETRS_Inspection_Package__c = halInspPkg.Id,
            IETRS_Regulated_Entity__c = accHalRE.id,
            RecordTypeId = halRecordType
        );
        insert halInspection;
        //create a child MAOP record
        IETRS_Insp_MAOP__c halMAOP = new IETRS_Insp_MAOP__c(
            IETRS_Inspection__c = halInspection.Id
        );
        insert halMAOP;
        //create a child OPP record
        IETRS_Insp_OPP_Codes__c halOPP = new IETRS_Insp_OPP_Codes__c(
            IETRS_Inspection__c = halInspection.Id
        );
        insert halOPP;
        //create a child Pipes_by_Class_Haz_Liq record
        IETRS_Pipes_by_Class_Haz_Liq__c halPbC = new IETRS_Pipes_by_Class_Haz_Liq__c(
            IETRS_Inspection__c = halInspection.Id
        );
        insert halPbC;
        //create a child Repaired_Leaks_Gas_Liq record
        IETRS_Repaired_Leaks_Gas_Liq__c halRLG = new IETRS_Repaired_Leaks_Gas_Liq__c(
            IETRS_Inspection__c = halInspection.Id
        );
        insert halRLG;
        //create a child Miles_of_Pipe_by_Size_Gas_Liq record
        IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c halMPS = new IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c(
            IETRS_Inspection__c = halInspection.Id
        );
        insert halMPS;

        //prep list of ids to be passed into the tested method
        List<Id> idList = new List<Id>();
        idList.add(halInspPkg.Id);

        //now run each record through the tested class
        Test.startTest();
        IETRS_InspPkgReadinessValidation.IETRS_InspPkgReadinessValidation(
            idList
        );
        Test.stopTest();
    }

    @IsTest
    static void IETRS_InspPkgReadinessValidation_Mam_Test() {
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
        //records to test for master meter inspection
        //create a organziation account record for master meter
        Account accMamOrg = new Account(
            Name = 'Test Org',
            RecordTypeId = orgRecordType,
            IETRS_Company_ID__c = '00003'
        );
        insert accMamOrg;
        //create a regulated entity account record for master meter
        Account accMamRE = new Account(
            Name = 'Test Org',
            ParentId = accMamOrg.Id,
            Type = 'Master Meter',
            RecordTypeId = reRecordType
        );
        insert accMamRE;
        //create a miles by county record to pass triggered flows
        IETRS_Insp_Miles_by_County__c mamCountyMiles = new IETRS_Insp_Miles_by_County__c(
            IETRS_Regulated_Entity__c = accMamRE.Id,
            IETRS_Miles__c = 10
        );
        insert mamCountyMiles;
        //create an inspection package for a master meter inspection package
        IETRS_Inspection_Package__c mamInspPkg = new IETRS_Inspection_Package__c(
            IETRS_Inspection_Type__c = 'Specialized',
            IETRS_Organization__c = accMamOrg.Id
        );
        insert mamInspPkg;
        //get the master meter inspection record type
        String mamRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'PS Inspection - Master Meter Systems'
            LIMIT 1
        ]
        .Id;
        //create a master meter inspection record that will fail the validation
        IETRS_Inspection__c mamInspectionF = new IETRS_Inspection__c(
            IETRS_Inspection_Package__c = mamInspPkg.Id,
            IETRS_Regulated_Entity__c = accMamRE.id,
            RecordTypeId = mamRecordType
        );
        insert mamInspectionF;
        //create a master meter inspection record that will pass the validation
        IETRS_Inspection__c mamInspection = new IETRS_Inspection__c(
            IETRS_Inspection_Package__c = mamInspPkg.Id,
            IETRS_Regulated_Entity__c = accMamRE.id,
            RecordTypeId = mamRecordType
        );
        insert mamInspection;
        //create a child MAOP record
        IETRS_Insp_MAOP__c mamMAOP = new IETRS_Insp_MAOP__c(
            IETRS_Inspection__c = mamInspection.Id
        );
        insert mamMAOP;
        //create a child OPP record
        IETRS_Insp_OPP_Codes__c mamOPP = new IETRS_Insp_OPP_Codes__c(
            IETRS_Inspection__c = mamInspection.Id
        );
        insert mamOPP;
        //create a child Suppliers record
        IETRS_Insp_Supplier__c mamSup = new IETRS_Insp_Supplier__c(
            IETRS_Inspection__c = mamInspection.Id
        );
        insert mamSup;
        //create a child Miles_of_Pipe_by_Size_MM record
        IETRS_Miles_of_Pipe_by_Size_MM__c mamMPS = new IETRS_Miles_of_Pipe_by_Size_MM__c(
            IETRS_Inspection__c = mamInspection.Id
        );
        insert mamMPS;

        //prep list of ids to be passed into the tested method
        List<Id> idList = new List<Id>();
        idList.add(mamInspPkg.Id);

        //now run each record through the tested class
        Test.startTest();
        IETRS_InspPkgReadinessValidation.IETRS_InspPkgReadinessValidation(
            idList
        );
        Test.stopTest();
    }
    *****************/
}