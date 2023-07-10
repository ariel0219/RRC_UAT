@isTest
public class IETRS_PLI_LWCQuery_Test {
    
    @testSetup
    public static void testDataSetUp(){
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
    public static void testMethodTc1(){
        Account accountins=new Account();
        accountins.IETRS_P5_Number__c='123456';
        accountIns.Name='DistributionTestParentAccount';
        accountIns.BillingCity='123jhas';
        accountIns.BillingStreet='123jhas';
        accountIns.BillingState='123jhas';
        accountIns.BillingCity='123jhas';
        accountIns.BillingCountry='123jhas';
        accountIns.BillingPostalCode='123jhas';
        
        insert accountIns;
        
        List<Account> listOfAccount=[SELECT id from Account WHERE Name Like 'DistributionTestAccount%'];
        List<IETRS_Insp_Notification__c> listofNotificationDetails=new List<IETRS_Insp_Notification__c>();
        listofNotificationDetails=[SELECT id,IETRS_PS95_Organization__r.ParentId,IETRS_PS95_Organization__c from IETRS_Insp_Notification__c];
        Id listofContacts=[SELECT id from Contact limit 1].id;
        List<Id> listOfIds=new List<Id>();
        List<IETRS_Insp_Notification_Detail__c> listOfNotificationDetails1=new List<IETRS_Insp_Notification_Detail__c>();
        
        for(IETRS_Insp_Notification__c notification:listofNotificationDetails){
            accountIns.ParentId=notification.IETRS_PS95_Organization__c;
            update accountIns;
            listOfIds.add(notification.Id);
            IETRS_Insp_Notification_Detail__c notificationDetails=new IETRS_Insp_Notification_Detail__c();
            notificationDetails.IETRS_Notification__c=notification.Id;
            notificationDetails.IETRS_Operator_Leak_ID__c='1233';
            notificationDetails.IETRS_Pipelines_System_ID__c=accountIns.Id;
            notificationDetails.IETRS_Repair_Date__c=System.today();
            notificationDetails.IETRS_Leak_Cause__c='Static Electricity';
            notificationDetails.IETRS_Leak_Location__c='Above Ground Piping';
            listOfNotificationDetails1.add(notificationDetails);
        }
        
        try{
            insert listOfNotificationDetails1;
        }catch(Exception e){
            system.assertNotEquals(null, e.getMessage());
        }
        
        IETRS_PLI_LWCQuery.getAccountList();
        IETRS_PLI_LWCQuery.getAccountRecords('DistributionTestParentAccount', '123456');
        IETRS_PLI_LWCQuery.getNotificationRecordTypeId('SRC');
        IETRS_PLI_LWCQuery.fetchNotificationSRCRecods('DistributionTestParentAccount', '123456', 'test1', 'SRC');
        IETRS_PLI_LWCQuery.fetchNotificationSRCRecodsOnRefresh(listOfIds);
        IETRS_PLI_LWCQuery.fetchNotificationDetailRecs('DistributionTestParentAccount','123456' , '2020 Jan-jun');
        IETRS_PLI_LWCQuery.picklistValues('Account','Industry');
        IETRS_PLI_LWCQuery.getReportPeriodValues();
        IETRS_PLI_LWCQuery.getLeakCauseValues();
        IETRS_PLI_LWCQuery.getLeakClassificationValues();
        IETRS_PLI_LWCQuery.getLeakLocationValues();
        IETRS_PLI_LWCQuery.getLeakRepairMethodValues();
        IETRS_PLI_LWCQuery.getPipeTypeValues();
        IETRS_PLI_LWCQuery.getPipeSizeValues();
        IETRS_PLI_LWCQuery.getleaveLocaitonOn();
        IETRS_PLI_LWCQuery.getFacilityTypeValues();
        IETRS_PLI_LWCQuery.getallPicklistWrap();
        IETRS_PLI_LWCQuery.fetchNotificationDetailReccords(listOfIds[0]);
        IETRS_PLI_LWCQuery.fetchNotificationDetailReccords(listOfIds[0]);
        IETRS_PLI_LWCQuery.getSortFldApiByName();
        try{
            IETRS_PLI_LWCQuery.getAccountIdByNotificationIdForSRCAndImp(accountins.id);
        }catch(Exception e){
            System.debug('e'+e.getMessage());
        }
        try{
        IETRS_PLI_LWCQuery.getAccountIdByNotificationIdForPS95(listOfIds[0]+'1');
        }catch(Exception e){
             IETRS_PLI_LWCQuery.getAccountIdByNotificationIdForPS95(listOfIds[0]);
        }
        try{
            IETRS_PLI_LWCQuery.fetchNotificationDetailReccordsForRefresh(listOfIds[0], 'test', 'tsa', 'searchCountyKey', 'sortBy', 'ASC');
        }catch(Exception e){
            System.debug('Exception');
        }
        
       
        //IETRS_PLI_LWCQuery.fetchNotificationDetailReccordsForRefresh(listOfIds[0], 'searchRENKey', 'searchREIKey', 'searchCountyKey', 'sortby', 'ASC');
        try{
            IETRS_PLI_LWCQuery.deleteContacts(new List<Id>{listofContacts});
        }Catch(Exception e){
            System.debug('Exception');
        }
        IETRS_PLI_LWCQuery.updateNotificationRecord(listOfIds[0], '12', '1', '3');
        IETRS_PLI_LWCQuery.updatenotificationTonullRecords(listOfIds[0], '0', '0', '0');
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
        notificationRecord.IETRS_PS95_Organization__c=accountins.Id;
        notificationRecord.RecordTypeId=Schema.SObjectType.IETRS_Insp_Notification__c.getRecordTypeInfosByName().get('PS-95').getRecordTypeId();              
        notificationRecord.IETRS_Report_Period__c=reportPeriod;
        IETRS_PLI_LWCQuery.insertNewNotificationObject(notificationRecord);
        Account child=new Account();
        child.ParentId=accountins.Id;
        child.Name='Acoouantjad';
        insert child;
        IETRS_PLI_LWCQuery.fetchAddressUsingSystemName(child.Id);
        try{
            IETRS_PLI_LWCQuery.deleteNotificationRecordById(listOfIds[0]+'11');
        }Catch(Exception e){
            System.debug('Exception');
        }
        IETRS_PLI_LWCQuery.deleteNotificationRecordById(listOfIds[0]);
        IETRS_PLI_LWCQuery.deleteNotificationDetailRecordById(listOfIds[0]);
        IETRS_PLI_LWCQuery.deleteNotificationDetailsRecordById(listOfIds);
        User userInstance=new User(Id=UserInfo.getUserId());
        System.runAs(userInstance){
            IETRS_PLI_LWCQuery.getPS95AccessCheckForProfile();
        }
        
        
    }
    
    @isTest
    public static void testMethodTC3(){
        Account child=new Account();
        child.Name='Acoountjaad';
        insert child;
        IETRS_PLI_LWCQuery.fetchAddressUsingSystemName(child.Id);
        
    }
    
    @isTest
    public static void testMethdoTc4(){
        List<Account> listOfAccounts=new List<Account>();
        List<Account> listChildAccounts=new List<Account>();
        List<IETRS_Insp_Notification__c> listOfNotifications=new List<IETRS_Insp_Notification__c>();
        
        //for(Integer i=0;i<5;i++){
        Account parentAccount=new Account();
        parentAccount.Name='DistribkjutionTeastParentAccountTC3'+'i';
        parentAccount.recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        insert parentAccount;
        Contact contactInstance=new Contact();
        contactInstance.LastName='teshnatTC3';
        contactInstance.Phone='1914292100120000';
        contactInstance.IETRS_24_Hour_Phone__c='19127821001000';
        contactInstance.FAX='23343fdfg'+'i';
        contactInstance.Email='teskatTC3'+'i'+'@gmail.com';
        contactInstance.Title='test Rep';
        contactInstance.AccountId=parentAccount.Id;
        insert contactInstance;
        
        AccountContactRelation  AccountContactRelationInst=new AccountContactRelation();
        AccountContactRelationInst.AccountId=parentAccount.Id;
        AccountContactRelationInst.ContactId=contactInstance.Id;
        //insert AccountContactRelationInst;
        
        User userinstance=new User(id=UserInfo.getUserId());
        
        System.runAs(userInstance){            
            IETRS_PLI_LWCQuery.identifyPortalUserAcessOrganization(parentAccount.id);
            try{
            IETRS_PLI_LWCQuery.isCurrentUserPortalUser();
            }catch(Exception e){
                System.debug('e'+e.getMessage());
            }
        }
        Account accountInstance=new Account();
        accountInstance.recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        accountInstance.ParentId=parentAccount.Id;
        accountInstance.Type='Distribution';
        accountInstance.IETRS_Representative__c=contactInstance.Id;
        accountInstance.Name='DistributionhgvTaestAccousantTC3'+'i';
        listChildAccounts.add(accountInstance);
        //}
        Account accountInstane;
        
        if(listChildAccounts.size()>0){
            insert listChildAccounts;
            //for(
            accountInstane =listChildAccounts[0];
            String strOrgId = IETRS_PLI_LWCQuery.getOrgofRegEnt(accountInstane.Id);
            //){
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
            // }
        }
        
        if(listOfNotifications.size()>0){
            insert listOfNotifications;
        }
        
        List<IETRS_Insp_Notification_Detail__c> listOfNotificationDetails=new List<IETRS_Insp_Notification_Detail__c>();
        // for(
        IETRS_Insp_Notification__c notificationInstance=listOfNotifications[0];
        //){
        IETRS_Insp_Notification_Detail__c notificationDetails=new IETRS_Insp_Notification_Detail__c();
        notificationDetails.IETRS_Notification__c=notificationInstance.Id;
        notificationDetails.IETRS_Operator_Leak_ID__c='1233';
        notificationDetails.IETRS_Pipelines_System_ID__c=[SELECT id from Account  WHERE RecordType.Name='Unit' limit 1].Id;//parentAccount.Id;
        notificationDetails.IETRS_Repair_Date__c=System.today();
        notificationDetails.IETRS_Leak_Cause__c='Static Electricity';
        notificationDetails.IETRS_Leak_Location__c='Above Ground Piping';
        listOfNotificationDetails.add(notificationDetails);
        
        Decimal decRepairedLeaks =  IETRS_PLI_LWCQuery.getRepairedLeakCount(notificationInstance.Id);
        //}
        try{
            IETRS_PLI_LWCQuery.createnotificationDetailRecord(notificationDetails);
            insert listOfNotificationDetails;
        }catch(Exception e){
            System.debug('Exception');
        }
        
    }
    
    
    
}