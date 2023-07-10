/**
* @description       : IETRS_PS95_StatsuControllerTest 
* @author            : Ayesha Sana
* @group             : 
* @last modified on  : 
* @last modified by  : Ayesha Sana
* Modifications Log 
* Ver   Date         Author             Modification
* 1.0  2021-01-28  Ayesha Sana    Initial Version
**/
@isTest
public class IETRS_PS95_StatsuControllerTest {
    
    @testSetup
    public static void testDataSetup(){
        List<Account> listOfAccounts=new List<Account>();
        List<Account> listChildAccounts=new List<Account>();
        List<IETRS_Insp_Notification__c> listOfNotifications=new List<IETRS_Insp_Notification__c>();
        
        for(Integer i=0;i<5;i++){
            Account parentAccount=new Account();
            parentAccount.Name='DistributionTestParentAccount'+i;
            parentAccount.recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
            insert parentAccount;
            Contact contactInstance=new Contact();
            contactInstance.LastName='test'+i;
            contactInstance.Phone='191292100120000'+i;
            contactInstance.IETRS_24_Hour_Phone__c='1912821001000'+i;
            contactInstance.FAX='12121212'+i;
            contactInstance.Email='test'+i+'@gmail.com';
            contactInstance.Title='test Rep';
            contactInstance.AccountId=parentAccount.Id;
            insert contactInstance;
            Account accountInstance=new Account();
            accountInstance.recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
            accountInstance.ParentId=parentAccount.Id;
            accountInstance.Type='Distribution';
            accountInstance.IETRS_Representative__c=contactInstance.Id;
            accountInstance.Name='DistributionTestAccount'+i;
            listChildAccounts.add(accountInstance);
        }
        
        if(listChildAccounts.size()>0){
            insert listChildAccounts;
            for(Account accountInstane:listChildAccounts){
                String reportPeriod = '';
                Date dt = System.today(); 
                Integer year = dt.Year();
                if(dt.month()==12){
                    year+=1;
                    reportPeriod = String.valueOf(year)+' '+'Jan-Jun';
                }else{
                    reportPeriod = String.valueOf(year)+' '+'Jul-Dec';
                }
                IETRS_Insp_Notification__c notificationRecord=new IETRS_Insp_Notification__c();
                notificationRecord.IETRS_PS95_Organization__c=accountInstane.Id;
                notificationRecord.RecordTypeId=Schema.SObjectType.IETRS_Insp_Notification__c.getRecordTypeInfosByName().get('PS-95').getRecordTypeId();              
                notificationRecord.IETRS_Submitted__c='No';
                notificationRecord.IETRS_Report_Period__c=reportPeriod;
                listOfNotifications.add(notificationRecord);
            }
        }
        
        if(listOfNotifications.size()>0){
            insert listOfNotifications;
        }
        
    }
    @isTest
    public static void  testmethodTCP1(){
        IETRS_Insp_Notification__c notifications=new IETRS_Insp_Notification__c();
        notifications=[SELECT id,Name,IETRS_PS95_Organization__c from IETRS_Insp_Notification__c limit 1];
        Test.startTest();
        IETRS_PS95_StatsuController.getPS95AccessCheckForProfile();
        IETRS_PS95_StatsuController.onSubmitPS95UpdateStatusYes(notifications.Id);
        IETRS_PS95_StatsuController.getSubmittedValueByNotificationId(notifications.Id);
        IETRS_PS95_StatsuController.isCurrentUserPortalUser();
        try{
            IETRS_PS95_StatsuController.identifyPortalUserAcessOrganization(notifications.IETRS_PS95_Organization__c);
        }catch(Exception e){
            System.debug('Exception'+e.getMessage());
        }
        IETRS_PS95_StatsuController.getAccountIdByNotificationIdForPS95(notifications.Id);
        
        
        Test.stopTest();
    }
    
    
    
}