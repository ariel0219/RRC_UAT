@isTest
public class IETRS_Delinquent_Letters_RepTest {
    
    @isTest
    public static void testMethod_Negative_Case(){
        List<IETRS_Delinquent_Letters_Rep.IETRSInspCorrespondenceDateWrapper> listtestWrapper=new List<IETRS_Delinquent_Letters_Rep.IETRSInspCorrespondenceDateWrapper>();
        Test.startTest();
        try{
            listtestWrapper = IETRS_Delinquent_Letters_Rep.getIPCorrespondenceDatesWrapper();
        }catch(Exception e){
            system.debug('Exception'+e.getMessage());
        }
        Test.stopTest();
        System.assertNotEquals(null, listtestWrapper);
    }
    
    
    
    @isTest
    public static void testMethod_Positive_Case(){
        //get the record type id for regulated entity on the account object
        String reRecordType = [SELECT Id FROM RecordType WHERE Name='Regulated Entity - PS' Limit 1].Id;
        //get the record type id for organziation on the account object
        String orgRecordType = [SELECT Id FROM RecordType WHERE Name='Organization' Limit 1].Id;
        //records to test for distribution inspection
        //create a organziation account record for distribution
        Account accDisOrg = new Account(
            Name = 'Test Org',
            RecordTypeId = orgRecordType,
            IETRS_Company_ID__c = '00001'
        );
        insert accDisOrg;
        
        IETRS_Inspection_Package__c disInspPkg = new IETRS_Inspection_Package__c(
            IETRS_Inspection_Type__c = 'Standard',
            IETRS_Organization__c = accDisOrg.Id,
            IETRS_Uncorrected_Status__c= 'Waiting for POC',
            IETRS_Status__c='Initial'
            
        );
        insert disInspPkg;
        
        IETRS_Files_Correspondence__c corr=new IETRS_Files_Correspondence__c();
        corr.IETRS_Inspection_Package__c= disInspPkg.Id;
        insert corr;
        IETRS_Insp_Correspondence_Date__c corrDate=new IETRS_Insp_Correspondence_Date__c();
        corrDate.IETRS_Date_Type__c='POC Due';
        Date datefieldt1=System.today();
        datefieldt1.addDays(-5);
        corrDate.IETRS_Correspondence_Date__c=datefieldt1;
        corrDate.IETRS_Files_Correspondence__c=corr.id;
        insert corrDate;
        IETRS_Insp_Correspondence_Date__c corrDate1=new IETRS_Insp_Correspondence_Date__c();
        corrDate1.IETRS_Date_Type__c='POC Due';
        Date datefieldt4=System.today();
        datefieldt4.addDays(-4);
        corrDate1.IETRS_Correspondence_Date__c=datefieldt4;
        corrDate1.IETRS_Files_Correspondence__c=corr.id;
        insert corrDate1;
        IETRS_Insp_Correspondence_Date__c corrDate2=new IETRS_Insp_Correspondence_Date__c();
        corrDate2.IETRS_Date_Type__c='POC Due';
        Date datefieldt3=System.today();
        datefieldt3.addDays(-3);
        corrDate2.IETRS_Correspondence_Date__c=datefieldt3;
        corrDate2.IETRS_Files_Correspondence__c=corr.id;
        insert corrDate2;
        IETRS_Insp_Correspondence_Date__c corrDate3=new IETRS_Insp_Correspondence_Date__c();
        corrDate3.IETRS_Date_Type__c='POC Due';
        Date datefieldt2=System.today();
        datefieldt2.addDays(-2);
        corrDate3.IETRS_Correspondence_Date__c=datefieldt2;
        corrDate3.IETRS_Files_Correspondence__c=corr.id;
        insert corrDate3;
        
        
        List<IETRS_Delinquent_Letters_Rep.IETRSInspCorrespondenceDateWrapper> listtestWrapper=new List<IETRS_Delinquent_Letters_Rep.IETRSInspCorrespondenceDateWrapper>();
        Test.startTest();
        try{
            listtestWrapper = IETRS_Delinquent_Letters_Rep.getIPCorrespondenceDatesWrapper();
        }catch(Exception e){
            system.debug('Exception'+e.getMessage());
        }
        Test.stopTest();
        System.assertNotEquals(null, listtestWrapper);
    }
    
}