@isTest
public class IETRS_Contact_Detail_Controller_Test {
    @TestSetup
    static void makeData(){
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Account actOrg = new Account(Name='IETRS Org Account',
                                RecordTypeId = accOrgRecordTypeId
                               );
        insert actOrg;
        
        Id accUnitRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId();
        Account actUnit = new Account(Name='IETRS Unit Account',
                                	RecordTypeId = accUnitRecordTypeId,
                                    parentId = actOrg.Id  
                               		);
        insert actUnit;
        
        Id accRERecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Regulated_Entity_PS').getRecordTypeId();
        Account actRE = new Account(Name='IETRS RE Account',
                                    RecordTypeId = accRERecordTypeId,
                                    parentId = actUnit.Id
                                   );
        insert actRE;
        
    }
    
  @isTest 
    static void getContactsByParentIdOrganizationTest(){
        
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Account actOrg = [SELECT Id FROM Account WHERE RecordTypeId = :accOrgRecordTypeId LIMIT 1];
        
        Id accUnitRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId();
        Account actUnit = [SELECT Id FROM Account WHERE RecordTypeId = :accUnitRecordTypeId LIMIT 1];
        
        Id accRERecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Regulated_Entity_PS').getRecordTypeId();
        Account actRE = [SELECT Id FROM Account WHERE RecordTypeId = :accRERecordTypeId LIMIT 1];
        
        IETRS_Inspection_Package__c insp = new IETRS_Inspection_Package__c(IETRS_Inspection_Type__c = 'Standard',
                                                                           IETRS_Uncorrected_Status__c = 'Waiting for POC',
                                                                           IETRS_Organization__c = actOrg.Id,
                                                                           IETRS_Unit_Name__c = actUnit.Id
                                                                           );
        
        insert insp;
   
        Id inspRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName().get('PS_Inspection_Distribution_Systems').getRecordTypeId();
        IETRS_Inspection__c ins = new IETRS_Inspection__c(IETRS_Inspection_Package__c = insp.Id,
                                                          IETRS_Inspection_Status__c = 'Incomplete',
                                                          IETRS_Regulated_Entity__c = actRE.Id,
                                                          RecordTypeId = inspRecordTypeId
                                                         );
                
        insert ins;
        
        IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c(IETRS_File_Name__c = 'FILECORR-002989.txt',
                                                                             IETRS_Inspection_Package__c = insp.Id,
                                                                             IETRS_Inspection__c = ins.Id);
       
        insert fc;
        
        
        IETRS_Inspection_Package__c inspackage = new IETRS_Inspection_Package__c(IETRS_Inspection_Type__c = 'Standard',
                                                                                 IETRS_Uncorrected_Status__c = 'Waiting for POC',
                                                                                 IETRS_Unit_Name__c = actUnit.Id,
                                                                                 IETRS_Organization__c = actOrg.Id
                                                                                );
        
        insert inspackage;
   
        Id inspectionRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName().get('PS_Inspection_Distribution_Systems').getRecordTypeId();
        IETRS_Inspection__c inspection = new IETRS_Inspection__c(IETRS_Inspection_Package__c = inspackage.Id,
                                                                 IETRS_Inspection_Status__c = 'Incomplete',
                                                                 IETRS_Regulated_Entity__c = actRE.Id,
                                                                 RecordTypeId = inspectionRecordTypeId
                                                                );
                
        insert inspection;
        
        IETRS_Files_Correspondence__c fcc = new IETRS_Files_Correspondence__c(IETRS_File_Name__c = 'FILECORR-002990.txt',
                                                                              IETRS_Inspection_Package__c = inspackage.Id
                                                                             );
       
        insert fcc;
        Test.startTest();
        IETRS_Contact_Detail_Controller.getContactsByParentId_Organization(fc.Id);
        IETRS_Contact_Detail_Controller.getContactsByParentId_Unit(fcc.Id);
        IETRS_Contact_Detail_Controller.getContactsByParentId_InspectionPackage(fcc.Id);            
        Test.stopTest();
    } 
    
    @isTest 
    static void createCorrespondence_Mailing_OrgTest(){
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Account actOrg = [SELECT Id FROM Account WHERE RecordTypeId = :accOrgRecordTypeId LIMIT 1];
        
        List<Contact> contList = new List<Contact>(); 
        Contact con = new Contact(FirstName = 'John',
                                    LastName = 'Test',
                                    Email = 'Johntest@example.com',
                                    AccountId = actOrg.Id);
            
        contList.add(con);
        
        Contact c = new Contact(FirstName = 'Emily',
                                    LastName = 'Test',
                                    Email = 'Emilytest@example.com',
                                    AccountId = actOrg.Id);
            
        contList.add(c); 
            
        
        
        insert contList;
      
        IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c(IETRS_File_Name__c = 'FILECORR-002989.txt');
      
        insert fc; 
      
        List<IETRS_Contact_Detail_Controller.DataWrapperOUIP_To> dwOUIP_To = new List<IETRS_Contact_Detail_Controller.DataWrapperOUIP_To>();
        List<IETRS_Contact_Detail_Controller.DataWrapperOUIP_CC> dwOUIP_CC = new List<IETRS_Contact_Detail_Controller.DataWrapperOUIP_CC>();
        IETRS_Contact_Detail_Controller.DataWrapperOUIP_To item = new IETRS_Contact_Detail_Controller.DataWrapperOUIP_To();
        item.recordId = c.Id;
        item.To = true;
        dwOUIP_To.add(item);
        
        IETRS_Contact_Detail_Controller.DataWrapperOUIP_CC item2 = new IETRS_Contact_Detail_Controller.DataWrapperOUIP_CC();
        item2.CC = true;
        item2.recordId = con.Id;
        dwOUIP_CC.add(item2);
        
        Test.startTest();
        IETRS_Contact_Detail_Controller.createCorrespondence_Mailing_Org(contList, fc.Id, dwOUIP_To, dwOUIP_CC);
        Test.stopTest();
    }
    
    @isTest 
    static void createCorrespondence_Mailing_UnitTest(){
        Id accUnitRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId();
        Account actUnit = [SELECT Id FROM Account WHERE RecordTypeId = :accUnitRecordTypeId LIMIT 1];
        
        List<Contact> contList = new List<Contact>(); 
        Contact con = new Contact(FirstName = 'TestFirstName',
                                    LastName = 'Test',
                                    Email = 'TestFirstName123@example.com',
                                    AccountId = actUnit.Id);
            
        contList.add(con);
        
        Contact c = new Contact(FirstName = 'Mike',
                                    LastName = 'Test',
                                    Email = 'Miketest@example.com',
                                    AccountId = actUnit.Id);
            
        contList.add(c);    
        
        
        insert contList;
        
        IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c(IETRS_File_Name__c = 'FILECORR-002988.txt');
      
        insert fc; 
        
        List<IETRS_Contact_Detail_Controller.DataWrapperOUIP_To> dwOUIP_To = new List<IETRS_Contact_Detail_Controller.DataWrapperOUIP_To>();
        List<IETRS_Contact_Detail_Controller.DataWrapperOUIP_CC> dwOUIP_CC = new List<IETRS_Contact_Detail_Controller.DataWrapperOUIP_CC>();
        IETRS_Contact_Detail_Controller.DataWrapperOUIP_To item = new IETRS_Contact_Detail_Controller.DataWrapperOUIP_To();
        item.recordId = c.Id;
        item.To = true;
        dwOUIP_To.add(item);
        
        IETRS_Contact_Detail_Controller.DataWrapperOUIP_CC item2 = new IETRS_Contact_Detail_Controller.DataWrapperOUIP_CC();
        item2.CC = true;
        item2.recordId = con.Id;
        dwOUIP_CC.add(item2);
        
        Test.startTest();
        IETRS_Contact_Detail_Controller.createCorrespondence_Mailing_Unit(contList, fc.Id, dwOUIP_To, dwOUIP_CC);
        Test.stopTest();
    }
   
    @isTest
    static void createCorrespondence_Mailing_InspectionPackageTest(){
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Account actOrg = [SELECT Id FROM Account WHERE RecordTypeId = :accOrgRecordTypeId LIMIT 1];

        Id accUnitRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId();
        Account actUnit = [SELECT Id FROM Account WHERE RecordTypeId = :accUnitRecordTypeId LIMIT 1];
        
        List<Contact> contList = new List<Contact>(); 
        Contact con = new Contact(FirstName = 'TestFirstName',
                                    LastName = 'Test',
                                    Email = 'TestFirstName123@example.com',
                                    AccountId = actOrg.Id);
            
        contList.add(con);
        
        
         Contact c = new Contact(FirstName = 'Mike',
                                    LastName = 'Test',
                                    Email = 'Mike123test@example.com',
                                    AccountId = actOrg.Id);
            
        contList.add(c);
        insert contList;
        
        IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c(IETRS_File_Name__c = 'FILECORR-002987.txt');
      
        insert fc; 
        
        IETRS_Inspection_Package__c insp = new IETRS_Inspection_Package__c(IETRS_Inspection_Type__c = 'Standard',
                                                                           IETRS_Uncorrected_Status__c = 'Waiting for POC',
                                                                           IETRS_Organization__c = actOrg.Id,
                                                                           IETRS_Unit_Name__c = actUnit.Id
                                                                           );
        
        insert insp;
        
        List<IETRS_Insp_Inspection_Package_Contact__c> listiipc = new List<IETRS_Insp_Inspection_Package_Contact__c>();
        IETRS_Insp_Inspection_Package_Contact__c iipc = new IETRS_Insp_Inspection_Package_Contact__c(IETRS_Contact__c = c.Id,
                                                                                                     IETRS_Inspection_Package__c = insp.Id
                                                                                                     );
        listiipc.add(iipc);
        
        IETRS_Insp_Inspection_Package_Contact__c iip = new IETRS_Insp_Inspection_Package_Contact__c(IETRS_Contact__c = con.Id,
                                                                                                    IETRS_Inspection_Package__c = insp.Id
                                                                                                     );
        listiipc.add(iip);
        
        insert listiipc;
        
        IETRS_Insp_Correspondence_Mailing_List__c icml = new IETRS_Insp_Correspondence_Mailing_List__c(IETRS_Files_and_Correspondence__c = fc.Id,
                                                                                                       IETRS_Contact__c = c.Id
                                                                                                      );
        insert icml;
        
        IETRS_Contact_Detail_Controller.DataWrapperForToAndCC ietrsData = new IETRS_Contact_Detail_Controller.DataWrapperForToAndCC();
        ietrsData.CC = 'CC';
        ietrsData.To = 'To';
        ietrsData.recordId = con.Id;
        ietrsData.iPContactInstance = iip;
        ietrsData.contactRecord = con;
        
        
        
        List<IETRS_Contact_Detail_Controller.DataWrapperOUIP_To> dwOUIP_To = new List<IETRS_Contact_Detail_Controller.DataWrapperOUIP_To>();
        List<IETRS_Contact_Detail_Controller.DataWrapperOUIP_CC> dwOUIP_CC = new List<IETRS_Contact_Detail_Controller.DataWrapperOUIP_CC>();
        IETRS_Contact_Detail_Controller.DataWrapperOUIP_To item = new IETRS_Contact_Detail_Controller.DataWrapperOUIP_To();
        item.recordId = c.Id;
        item.To = true;
        dwOUIP_To.add(item);
        
        IETRS_Contact_Detail_Controller.DataWrapperOUIP_CC item2 = new IETRS_Contact_Detail_Controller.DataWrapperOUIP_CC();
        item2.CC = true;
        item2.recordId = con.Id;
        dwOUIP_CC.add(item2);
        
        Test.startTest();
        IETRS_Contact_Detail_Controller.createCorrespondence_Mailing_InspectionPackage(listiipc, fc.Id, dwOUIP_To, dwOUIP_CC);
        Test.stopTest();
    }

}