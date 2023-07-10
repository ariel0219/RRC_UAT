@isTest
public class IETRS_CreateFCInspectionDocumentTest {
    
    @TestSetup
    public static void createData(){
        RecordType accOrgRT = new RecordType();
        accOrgRT = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Account' AND DeveloperName = 'Organization'
            LIMIT 1
        ][0];
        RecordType accUnitRT = new RecordType();
        accUnitRT = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Account' AND DeveloperName = 'Unit'
            LIMIT 1
        ][0];
        RecordType accRERT = new RecordType();
        accRERT = [
            SELECT Id
            FROM RecordType
            WHERE
            SobjectType = 'Account'
            AND DeveloperName = 'Regulated_Entity_AFS'
            LIMIT 1
        ][0];
        RecordType ipRT = new RecordType();
        ipRT = [
            SELECT Id
            FROM RecordType
            WHERE
            SobjectType = 'IETRS_Inspection_Package__c'
            AND DeveloperName = 'CIIS_Inspection_Package_Critical_Infrastructure'
            LIMIT 1
        ][0];
        //create set of parent accounts
        Account org = new Account(
            Name = 'Test Org',
            RecordTypeId = accOrgRT.Id
        );
        insert org;
        Account unit = new Account(
            Name = 'Test Unit',
            RecordTypeId = accUnitRT.Id,
            ParentId = org.Id,
            IETRS_Organization_Parent__c = org.Id
        );
        insert unit;
        
        //create an inspection package record
        IETRS_Inspection_Package__c ip = new IETRS_Inspection_Package__c(
            IETRS_Status__c = 'Work in Progress',
            IETRS_Organization__c = org.Id,
            IETRS_Unit_Name__c = unit.Id,
            RecordTypeId = ipRT.Id,
            IETRS_Business_Area__c = 'Critical Infrastructure'
        );
        insert ip;
        
        IETRS_Incident__c fcIncident = new IETRS_Incident__c();
        Insert fcIncident;
        IETRS_Files_Correspondence__c notifRecord = new IETRS_Files_Correspondence__c();
        Insert notifRecord;
        
        IETRS_Files_Correspondence__c fcTestRecord = new IETRS_Files_Correspondence__c();
        fcTestRecord.IETRS_Public_Inspection_Document_Created__c = false;
        fcTestRecord.IETRS_Incident__c = fcIncident.Id;
        fcTestRecord.IETRS_Inspection_Package__c = ip.Id;
        fcTestRecord.IETRS_Original_File_Name__c = 'Test';
        fcTestRecord.IETRS_Box_File_ID__c = '462262211131';
        Insert fcTestRecord;
    }
    
    @IsTest
    public static void testMethod1() {
        IETRS_CreateFCInspectionDocument.createFCInspDocuemtns();
    }
}