/*
@Class Name         : IETRS_Account_Merge
@Description        : Split Regulated Entities on Account Object
@Author             : Srilu Mamillapalli
@Group              : 
@Last Modified By   : Srilu Mamillapalli
@Last Modified On   : 4/23/2020
@Modification Log   : 
==============================================================================
Ver         Date                     Author                 Modification
==============================================================================
1.0    4/08/2020,    Srilu Mamillapalli     Initial Version
*/
public class IETRS_Account_Split {
    
    public IETRS_Account_Split()
    {
        
    }
    
    @AuraEnabled
    public static LoadRespWrapper getAccount(string accountId) {
        LoadRespWrapper objResp = new LoadRespWrapper();
        objResp.hasSplitPermission = FeatureManagement.checkPermission('IETRS_Regulated_Entity_Split_Access');
        if(!objResp.hasSplitPermission){
            return objResp;
        }
        else{
            try{                
                objResp.objAcc = [SELECT Name,Id,IETRS_County__c,IETRS_Entity_Code__c,IETRS_Product_Class__c,
                                  IETRS_Product_Sub_Class__c,IETRS_Status__c,IETRS_Jurisdiction__c,IETRS_Region__r.Name,
                                  IETRS_T4_Permit__c,IETRS_Total_Miles__c,IETRS_Intra_Interstate__c,  
                                  IETRS_Install_Year__c,IETRS_Region__c,IETRS_On_Offshore__c,
                                  Type,IETRS_Entity_Sub_Type__c,Parent.Name,IETRS_Unit_Parent__c,IETRS_Unit_Parent__r.IETRS_Unit_ID__c,IETRS_Unit_ID__c,IETRS_Unit_Parent__r.Name,
                                  (Select Id,Name,IETRS_Miles__c,IETRS_Regulated_Entity__c,IETRS_Regulated_Entity__r.Name,IETRS_County__c,IETRS_County__r.Name From Miles_by_County__r)
                                  FROM Account WHERE Id =: accountId];
                objResp.statusValues = new List<String>{'Active','Idle','Abandoned','Construction','Revoked'}; //getPickListValuesIntoList(Account.IETRS_Status__c.getDescribe());
                    objResp.judValues = getPickListValuesIntoList(Account.IETRS_Jurisdiction__c.getDescribe());
                objResp.intStateValues =  getPickListValuesIntoList(Account.IETRS_Intra_Interstate__c.getDescribe());
                objResp.entCodeValues = getPickListValuesIntoList(Account.IETRS_Entity_Code__c.getDescribe());
                
                return objResp;
                
            }
            catch(exception e) {
                return null;
            }
        }
    }    
    
    public static List<String> getPickListValuesIntoList(Schema.DescribeFieldResult fieldResult)
    {
        List<String> options = new List<String>();        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){            
            options.add(f.getValue());
        }     
        return options;
    }
    
    @AuraEnabled
    public static string splitRecord(string sourceAccId, string targetAccId,string note,List<IETRS_Insp_Miles_by_County__c> countiesToBeDeleted,List<IETRS_Insp_Miles_by_County__c> updatedCounties,string accName, Account accDetails)
    {
        
        try{
            System.debug('Acc details' + accDetails);
            if(accName != '')
            {
                List<Account> accontListExist = new  List<Account>();
                accontListExist = [Select Id from Account where Name =: accName];
                
                if(!accontListExist.isEmpty())
                {
                    return 'isExist';
                }
            }
            List<IETRS_Insp_Miles_by_County__c> currentCounties  = new List<IETRS_Insp_Miles_by_County__c>();
            List<IETRS_Insp_Miles_by_County__c> deleteCountiesLst  = new List<IETRS_Insp_Miles_by_County__c>();
            List<IETRS_Insp_Miles_by_County__c> insertCountiesLst  = new List<IETRS_Insp_Miles_by_County__c>();
            List<IETRS_Insp_Miles_by_County__c> updateCountiesLst  = new List<IETRS_Insp_Miles_by_County__c>();
            string  message = '';
            
            Account accObjTobeSplit = new Account();
            Map<string,decimal> countinameToMile = new  Map<string,decimal>();
            IETRS_Insp_Miles_by_County__c counti = new IETRS_Insp_Miles_by_County__c();
            
            
            
            //Query the source account field
            Account accObj =    [SELECT Name,Id,IETRS_County__c,IETRS_Entity_Code__c,IETRS_Product_Class__c,RecordTypeId,
                                 IETRS_Product_Sub_Class__c,IETRS_Status__c,IETRS_Jurisdiction__c,IETRS_Region__r.Name,IETRS_County__r.Name,
                                 IETRS_T4_Permit__c,IETRS_Total_Miles__c,IETRS_Intra_Interstate__c,  
                                 IETRS_Install_Year__c,IETRS_Region__c,IETRS_On_Offshore__c,
                                 Type,IETRS_Entity_Sub_Type__c,ParentId,Parent.Name,parent.IETRS_Unit_ID__c,IETRS_Unit_ID__c,
                                 (Select Id,Name,IETRS_Miles__c,IETRS_Regulated_Entity__c,IETRS_Regulated_Entity__r.Name From Miles_by_County__r)
                                 FROM Account WHERE Id =: sourceAccId];
            
            //Get all the original miles be county
            if(!accObj.Miles_by_County__r.isEmpty())
            {  
                
                for(IETRS_Insp_Miles_by_County__c insMile : accObj.Miles_by_County__r)
                {
                    countinameToMile.put(insMile.Name,insMile.IETRS_Miles__c); 
                }
                
                
            }
            
            system.debug('==countinameToMile-===='+countinameToMile);
            
            //Iterate over the counties rceived from client
            
            for(integer i=0; i < updatedCounties.size(); i++)
            {
                //Ifit is a counti from source account
                if(countinameToMile.containsKey(updatedCounties[i].Name))
                {
                    if(updatedCounties[i].IETRS_Miles__c != countinameToMile.get(updatedCounties[i].Name))
                    {
                        
                        
                        //If county miles has reduced then only create
                        if(countinameToMile.get(updatedCounties[i].Name) > updatedCounties[i].IETRS_Miles__c)
                        {
                            if(updatedCounties[i].Id == null){
                            counti = new IETRS_Insp_Miles_by_County__c();
                            counti.IETRS_County__c =  updatedCounties[i].IETRS_County__c;
                            counti.IETRS_Miles__c = countinameToMile.get(updatedCounties[i].Name) - updatedCounties[i].IETRS_Miles__c;
                            currentCounties.add(counti);
                            }
                            updateCountiesLst.add( updatedCounties[i]);
                        }
                    }
                    
                }
                else
                {
                    //If it is a new counti from another entity
                    if(updatedCounties[i].IETRS_Regulated_Entity__c != accObj.Id)
                    {
                        
                        system.debug('--here--inside new counti---');
                        counti = new IETRS_Insp_Miles_by_County__c();
                        counti.IETRS_Miles__c = updatedCounties[i].IETRS_Miles__c;
                        counti.IETRS_County__c =  updatedCounties[i].IETRS_County__c;
                        currentCounties.add(counti);
                    }
                    
                }
                
            }
            
            system.debug('=currentCounties=='+currentCounties);
            //If only county value changed to smaller
            if(!updateCountiesLst.isEmpty())
            {
                update updateCountiesLst;
            }
            
            system.debug('=countiesToBeDeleted=='+countiesToBeDeleted);
            if(!countiesToBeDeleted.isEmpty())
            {
                for(IETRS_Insp_Miles_by_County__c cn  :countiesToBeDeleted)
                {
                    if(cn.IETRS_Regulated_Entity__c == accObj.Id)
                    {
                        deleteCountiesLst.add(cn);
                    }
                }
                
                system.debug('=countiesToBeDeleted=='+deleteCountiesLst);
                if(!deleteCountiesLst.isEmpty())
                {
                    delete deleteCountiesLst;
                    message = 'Counties has been deleted successfully';
                }
            }
            
            if( currentCounties.isEmpty() && (!updateCountiesLst.isEmpty()))
            {
                message = 'Counties has been updated successfully';
            }
            system.debug('--after updation---');
            if(!currentCounties.isEmpty())
            {
                
                accObjTobeSplit.Name = accName;     
                accObjTobeSplit.IETRS_County__c = accDetails.IETRS_County__c;
                accObjTobeSplit.IETRS_Entity_Code__c = accDetails.IETRS_Entity_Code__c;
                accObjTobeSplit.IETRS_Product_Class__c = accObj.IETRS_Product_Class__c;
                accObjTobeSplit.IETRS_Status__c = accDetails.IETRS_Status__c;
                accObjTobeSplit.IETRS_Product_Sub_Class__c = accObj.IETRS_Product_Sub_Class__c;
                accObjTobeSplit.IETRS_Region__c = accDetails.IETRS_Region__c;
                accObjTobeSplit.IETRS_On_Offshore__c = accObj.IETRS_On_Offshore__c;
                accObjTobeSplit.Type = accObj.Type;
                accObjTobeSplit.IETRS_Entity_Sub_Type__c = accObj.IETRS_Entity_Sub_Type__c;
                accObjTobeSplit.IETRS_Unit_ID__c = accObj.IETRS_Unit_ID__c;
                accObjTobeSplit.ParentId = accObj.ParentId;
                accObjTobeSplit.RecordTypeId = accObj.RecordTypeId;
                accObjTobeSplit.IETRS_Intra_Interstate__c = accDetails.IETRS_Intra_Interstate__c;
                accObjTobeSplit.IETRS_Jurisdiction__c = accDetails.IETRS_Jurisdiction__c;
                accObjTobeSplit.IETRS_Install_Year__c = accDetails.IETRS_Install_Year__c;
                accObjTobeSplit.IETRS_T4_Permit__c = accDetails.IETRS_T4_Permit__c;
                accObjTobeSplit.IETRS_OrganizationofRegEntity__c=accDetails.IETRS_OrganizationofRegEntity__c;
                insert accObjTobeSplit;
                system.debug('=accObjTobeSplit===='+accObjTobeSplit.Id);
                for(integer i=0; i < currentCounties.size(); i++)
                {
                    currentCounties[i].IETRS_Regulated_Entity__c = accObjTobeSplit.Id;
                    
                }
                
                
                
                system.debug('==accObjTobeSplit-=111==='+accObjTobeSplit);
                
                
                system.debug('=updatedCounties==111=='+updatedCounties);
                
                
                system.debug('=currentCounties=11111='+currentCounties);
                /*
            Depricated, total miles is now calculated via a junction object which is auto-created/updated when account record of type RE is saved
                Map<String,String> mapInputs = new Map<String,String>();
                mapInputs.put('varOrganization', accObjTobeSplit.IETRS_OrganizationofRegEntity__c );
                mapInputs.put('varRERecordTypeId', accObjTobeSplit.RecordTypeId);
                Flow.Interview summingTotal = new Flow.Interview.IETRS_I_Summing_Total_Miles_for_Account(mapInputs);     
                summingTotal.start();
                */
                /*
Id recordTypeIdIns = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Inspection_Event').getRecordTypeId();


Event E = new Event();

E.Type = 'Event notes';
E.Description = note ;
E.WhatId = accObjTobeSplit.Id;
E.StartDateTime = system.now();
E.EndDateTime = system.now();
E.Subject ='Other';
E.RecordTypeId = recordTypeIdIns;
E.Transferred_From__c = accObj.Name.left(40);
E.Transferred_To__c= accName.left(40);


insert E;*/
                //system.debug('=E===='+E.Id);
                
                
                
                Task objT = IETRS_Utility.createActivityHistoryRecord(accObjTobeSplit.Id, note);
                objT.Description = 'Split account ['+ accObjTobeSplit.Name +']  has been created. \n Comments:  ' + note;
                objT.Subject = 'Account Split';
                objT.Type = 'Records Split';
                insert objT;
                
                try{
                    IETRS_SpecializedInspScheduleServices.sendEmail('Records Split',objT.Description);
                }
                catch(Exception ex){
                    System.debug(' Send Email failed with error : ' + ex.getMessage());
                }
                
                
                if(!currentCounties.isEmpty())
                {
                    insert currentCounties;
                }
                message = 'Split account has been created successfully..';
                
                
                
            }
            
            if(message == '')
            {
                message = 'noaction';
            }
            
            
            return message;
            
        }
        catch(Exception e)
        {
            system.debug('The exception is '+ e.getmessage());
            return 'error';
            
        }
        
        
    }
    
    @auraEnabled
    public static String splitRecord(string sourceAccId, string targetAccId,string note,List<IETRS_Insp_Miles_by_County__c> countiesToBeDeleted,List<IETRS_Insp_Miles_by_County__c> updatedCounties,string accName, Account accDetails,String oldInputMiles,String newInputMiles)
    { 
        String message ='';
        try{
            System.debug('Acc details' + accDetails);
            if(accName != '')
            {
                List<Account> accontListExist = new  List<Account>();
                accontListExist = [Select Id from Account where Name =: accName];
                
                if(!accontListExist.isEmpty())
                {
                    return 'isExist';
                }
            }
            List<IETRS_Insp_Miles_by_County__c> currentCounties  = new List<IETRS_Insp_Miles_by_County__c>();
            //List<IETRS_Insp_Miles_by_County__c> deleteCountiesLst  = new List<IETRS_Insp_Miles_by_County__c>();
            List<IETRS_Insp_Miles_by_County__c> insertCountiesLst  = new List<IETRS_Insp_Miles_by_County__c>();
            //List<IETRS_Insp_Miles_by_County__c> updateCountiesLst  = new List<IETRS_Insp_Miles_by_County__c>();
            //string  message = '';
            
            Account accObjTobeSplit = new Account();
            Map<string,decimal> countinameToMile = new  Map<string,decimal>();
            IETRS_Insp_Miles_by_County__c counti = new IETRS_Insp_Miles_by_County__c();
            
            
            
            //Query the source account field
            Account accObj =    [SELECT Name,Id,IETRS_County__c,IETRS_Entity_Code__c,IETRS_Product_Class__c,RecordTypeId,
                                 IETRS_Product_Sub_Class__c,IETRS_Status__c,IETRS_Jurisdiction__c,IETRS_Region__r.Name,IETRS_County__r.Name,
                                 IETRS_T4_Permit__c,IETRS_Total_Miles__c,IETRS_Intra_Interstate__c,  
                                 IETRS_Install_Year__c,IETRS_Region__c,IETRS_On_Offshore__c,IETRS_OrganizationofRegEntity__c,
                                 Type,IETRS_Entity_Sub_Type__c,ParentId,Parent.Name,parent.IETRS_Unit_ID__c,IETRS_Unit_ID__c,
                                 (Select Id,Name,IETRS_Miles__c,IETRS_Regulated_Entity__c,IETRS_Regulated_Entity__r.Name,
                                  IETRS_County__c /*Murty Chennubhotla*/
                                  From Miles_by_County__r)
                                 FROM Account WHERE Id =: sourceAccId];
            
            //Get all the original miles be county
            if(!accObj.Miles_by_County__r.isEmpty())
            {  
                
                currentCounties=accObj?.Miles_by_County__r?.clone(); // added as a part 16432 story
            }
            System.debug('<=====Debug Start====>');
            system.debug(accObj);
            System.debug(currentCounties);
            //added by as a part of 12643 start updating the total miles to existing Regulated entity - start 
            if(accObj!=null){
                accObj.IETRS_Total_Miles__c= Decimal.valueOf(oldInputMiles);
                update accObj;
            }
            //added by as a part of 12643 start updating the total miles to existing Regulated entity - end
            
            
            
            
            accObjTobeSplit.Name = accName;     
            accObjTobeSplit.IETRS_County__c = accDetails.IETRS_County__c;
            accObjTobeSplit.IETRS_Entity_Code__c = accDetails.IETRS_Entity_Code__c;
            accObjTobeSplit.IETRS_Product_Class__c = accObj.IETRS_Product_Class__c;
            accObjTobeSplit.IETRS_Status__c = accDetails.IETRS_Status__c;
            accObjTobeSplit.IETRS_Product_Sub_Class__c = accObj.IETRS_Product_Sub_Class__c;
            accObjTobeSplit.IETRS_Region__c = accDetails.IETRS_Region__c;
            accObjTobeSplit.IETRS_On_Offshore__c = accObj.IETRS_On_Offshore__c;
            accObjTobeSplit.Type = accObj.Type;
            accObjTobeSplit.IETRS_Entity_Sub_Type__c = accObj.IETRS_Entity_Sub_Type__c;
            accObjTobeSplit.IETRS_Unit_ID__c = accObj.IETRS_Unit_ID__c;
            accObjTobeSplit.ParentId = accObj.ParentId;
            accObjTobeSplit.RecordTypeId = accObj.RecordTypeId;
            accObjTobeSplit.IETRS_Intra_Interstate__c = accDetails.IETRS_Intra_Interstate__c;
            accObjTobeSplit.IETRS_Jurisdiction__c = accDetails.IETRS_Jurisdiction__c;
            accObjTobeSplit.IETRS_Install_Year__c = accDetails.IETRS_Install_Year__c;
            accObjTobeSplit.IETRS_T4_Permit__c = accDetails.IETRS_T4_Permit__c;
            accObjTobeSplit.IETRS_OrganizationofRegEntity__c=accObj.IETRS_OrganizationofRegEntity__c;
            //added by as a part of 12643 start updating the new total miles to existing Regulated entity - start
            accObjTobeSplit.IETRS_Total_Miles__c = Decimal.valueOf(newInputMiles); //added by   new total miles
            //added by as a part of 12643 start updating the new total miles to existing Regulated entity - start
            insert accObjTobeSplit;
            system.debug('=accObjTobeSplit===='+accObjTobeSplit.Id);
            if(!currentCounties.isEmpty())
            {
                for(integer i=0; i < currentCounties.size(); i++)
                {
                    IETRS_Insp_Miles_by_County__c counti1 = new IETRS_Insp_Miles_by_County__c();
                    counti1=currentCounties[i].clone(false, true, false, false);
                    counti1.IETRS_Regulated_Entity__c = accObjTobeSplit.Id;
                    counti1.id=null;
                    //counti1.IETRS_County__c=currentCounties[i].IETRS_County__c;
                    System.debug(counti1.IETRS_County__c);
                    insertCountiesLst.add(counti1);
                }
            }
            
            
            system.debug('==accObjTobeSplit-=111==='+accObjTobeSplit);
            
            
            system.debug('=updatedCounties==111=='+updatedCounties);
            
            
            system.debug('=currentCounties=11111='+currentCounties);
            
            /*
        Depricated, total miles is now calculated via a junction object which is auto-created/updated when account record of type RE is saved
            Map<String,String> mapInputs = new Map<String,String>();
            mapInputs.put('varOrganization', accObjTobeSplit.IETRS_OrganizationofRegEntity__c );
            mapInputs.put('varRERecordTypeId', accObjTobeSplit.RecordTypeId);
            Flow.Interview summingTotal = new Flow.Interview.IETRS_I_Summing_Total_Miles_for_Account(mapInputs);     
            summingTotal.start();            
            */
            
            Task objT = IETRS_Utility.createActivityHistoryRecord(accObjTobeSplit.Id, note);
            objT.Description = 'Split account ['+ accObjTobeSplit.Name +']  has been created. \n Comments:  ' + note;
            objT.Subject = 'Account Split';
            objT.Type = 'Records Split';
            insert objT;
            
            try{
                IETRS_SpecializedInspScheduleServices.sendEmail('Records Split',objT.Description);
            }
            catch(Exception ex){
                System.debug(' Send Email failed with error : ' + ex.getMessage());
            }
            
            
            if(!insertCountiesLst.isEmpty())
            {
                insert insertCountiesLst;
            }
            
            message = 'Split account has been created successfully..';
        }
        catch(Exception e)
        {
            system.debug('The exception is '+ e.getmessage());
            return message='error';
        }
        return message;
    }
    
    public class LoadRespWrapper{
        @AuraEnabled
        public Account objAcc {get;set;}
        @AuraEnabled
        public List<String> statusValues {get;set;}
        @AuraEnabled
        public List<String> judValues {get;set;}
        @AuraEnabled
        public List<String> intStateValues {get;set;}
        @AuraEnabled
        public List<String> entCodeValues {get;set;} 
        @AuraEnabled
        public Boolean hasSplitPermission {get;set;}     
    }
    
}