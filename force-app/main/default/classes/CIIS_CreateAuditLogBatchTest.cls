@isTest(SeeAllData = false)
public class CIIS_CreateAuditLogBatchTest {
    
    
    static testmethod void testInvoice(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        List<Account> accList = new  List<Account>();
        
        Account acc = new Account();
        acc.Name = 'Test ABC Rogue123';
        acc.RecordTypeId=RecordTypeIdAccount;
        acc.BillingStreet = 'Brandon Drive 321';
        acc.BillingCity='Dallas';
        acc.BillingCountry='US';
        acc.BillingPostalCode= '78654';
        insert acc;
        accList.add(acc);
         Account acc1 = new Account();
        acc1.Name = 'Test CBA Rogue123';
        acc1.RecordTypeId=RecordTypeIdAccount;
        acc1.BillingStreet = 'Brandon Drive 321';
        acc1.BillingCity='Dallas';
        acc1.BillingCountry='US';
        acc1.BillingPostalCode= '78654';
        insert acc1;
         accList.add(acc1);
        
        List<IETRS_Files_Correspondence__c> newFCList = new  List<IETRS_Files_Correspondence__c>();
        
        IETRS_Files_Correspondence__c newFC;
        newFC = new  IETRS_Files_Correspondence__c (IETRS_Organization__c = acc.Id,IETRS_Business_Area_Division__c ='Alternate Fuels',IETRS_Delivery_Method__c ='Certified', CIIS_Central_Print_Status__c='Available', IETRS_Box_File_ID__c ='123456789' );
        newFCList.add(newFC);
        newFC = new  IETRS_Files_Correspondence__c (IETRS_Organization__c = acc.Id,IETRS_Business_Area_Division__c ='Alternate Fuels',IETRS_Delivery_Method__c ='Certified',  CIIS_Central_Print_Status__c='Available', IETRS_Box_File_ID__c ='123456789');
        newFCList.add(newFC);
        insert newFCList;
        
         List<IETRS_Insp_Correspondence_Mailing_List__c> newCMLList = new  List<IETRS_Insp_Correspondence_Mailing_List__c>();
                IETRS_Insp_Correspondence_Mailing_List__c newCML;
         newCML =  new IETRS_Insp_Correspondence_Mailing_List__c (IETRS_To_or_CC__c = 'To' ,IETRS_Files_and_Correspondence__c = newFCList [0].Id,IETRS_Address_Line_1__c ='Test123' ,
                                                                  IETRS_Address_Line_2__c='123',IETRS_City__c = 'Austin', IETRS_State__c ='TX',IETRS_Zip__c ='78454',IETRS_Country_Code__c = 'USA');
         newCML =  new IETRS_Insp_Correspondence_Mailing_List__c (IETRS_To_or_CC__c = 'To' ,IETRS_Files_and_Correspondence__c = newFCList [1].Id,IETRS_Address_Line_1__c ='Test123' ,
                                                                  IETRS_Address_Line_2__c='123',IETRS_City__c = 'Austin', IETRS_State__c ='TX',IETRS_Zip__c ='78454',IETRS_Country_Code__c = 'USA');
         newCMLList.add(newCML);
        insert newCMLList;
        
        Test.startTest();
        CIIS_CreateAuditLogBatch c = new CIIS_CreateAuditLogBatch();
        Database.executeBatch(c);
  List<IETRS_Files_Correspondence__c> filesList = [SELECT IETRS_Organization__c, (SELECT IETRS_Address_Line_1__c, IETRS_Address_Line_2__c, IETRS_City__c, IETRS_State__c, IETRS_Zip__c, IETRS_Country_Code__c FROM Correspondence_Mailing_Lists__r  WHERE IETRS_Address_Line_1__c != null LIMIT 1), IETRS_Delivery_Method__c, CIIS_Mailing_Group__c, ID, CIIS_Central_Print_Status__c  FROM IETRS_Files_Correspondence__c WHERE CIIS_Central_Print_Status__c  ='Available' AND IETRS_Box_File_ID__c != null AND IETRS_Delivery_Method__c NOT IN ('Email', 'Central Print Return', '')];
        Test.stopTest();
    } 
    
}