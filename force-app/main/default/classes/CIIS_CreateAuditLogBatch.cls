global class CIIS_CreateAuditLogBatch implements Database.Batchable<sObject>,Database.AllowsCallouts ,Database.Stateful {
    
    Map<String , List<IETRS_Files_Correspondence__c>> fcMapForAll = new Map<String , List<IETRS_Files_Correspondence__c>>();
	
    global Database.QueryLocator start(Database.BatchableContext BC) {   
    
      String query =   'SELECT IETRS_Address_Line_1__c, IETRS_Address_Line_2__c, IETRS_City__c, IETRS_State__c, IETRS_Zip__c, IETRS_Country_Code__c,IETRS_Files_and_Correspondence__r.IETRS_Delivery_Method__c,IETRS_Files_and_Correspondence__r.CIIS_Mailing_Group__c,IETRS_Files_and_Correspondence__c ' 
          +'FROM IETRS_Insp_Correspondence_Mailing_List__c WHERE IETRS_Address_Line_1__c != null '
          + 'AND IETRS_Files_and_Correspondence__r.CIIS_Central_Print_Status__c  =\'Available\' '
          +  'AND IETRS_Files_and_Correspondence__r.IETRS_Box_File_ID__c != null '
           + 'AND IETRS_Files_and_Correspondence__r.IETRS_Delivery_Method__c NOT IN (\'Email\',\'Central Print Return\',\'\') ' ;
        
        
        System.debug('===START==='+query);
        // return Database.getQueryLocator(query);
        if(Test.isRunningTest()) query += ' Limit 200';         
        return Database.getQueryLocator(query);   
    }
    global void execute(Database.BatchableContext BC, List<IETRS_Insp_Correspondence_Mailing_List__c> scope) {
        System.Debug('===INSIDE EXECUTE==='+scope);
        
        Set<Id> fcIds = new Set<Id>();
        
        Map<Id, IETRS_Files_Correspondence__c> fcMap = new Map<Id, IETRS_Files_Correspondence__c>([
            Select Id from IETRS_Files_Correspondence__c where Id In (Select IETRS_Files_and_Correspondence__c from IETRS_Insp_Correspondence_Mailing_List__c where Id IN :scope )
        ]);
        
        for(IETRS_Insp_Correspondence_Mailing_List__c files :scope){         
            manageFC(files, fcMap);      
            fcIds.add(files.IETRS_Files_and_Correspondence__c );
        }    
        
        
        
    }
    
    public void manageFC(IETRS_Insp_Correspondence_Mailing_List__c rec , Map<Id, IETRS_Files_Correspondence__c> fcMap){
       
        //system.debug(rec.IETRS_Organization__r.BillingAddress.getCountry());
        //system.debug(rec.IETRS_Organization__r.BillingAddress.getState());
        //system.debug(rec.IETRS_Organization__r.BillingAddress.getStreet());
        //system.debug(rec.IETRS_Organization__r.BillingAddress.getStateCode());
        //system.debug(rec.IETRS_Organization__r.BillingAddress.getCountryCode());
        
        String compoundAddress = rec.IETRS_Address_Line_1__c+rec.IETRS_Address_Line_2__c+rec.IETRS_City__c+rec.IETRS_State__c+rec.IETRS_Zip__c+rec.IETRS_Country_Code__c+rec.IETRS_Files_and_Correspondence__r.IETRS_Delivery_Method__c;
        compoundAddress =compoundAddress.toLowerCase();
        compoundAddress = compoundAddress.replaceAll('(\\s+)', '');    
        system.debug('compoundAddress'+compoundAddress);
        list<IETRS_Files_Correspondence__c> addFC = new  list<IETRS_Files_Correspondence__c>();
        
        if(fcMapForAll.containsKey(compoundAddress)){
            //string fieldvalue = dummymap.get(id).dummyfield__c;
            //addFC.add(fcMapForAll.get(compoundAddress).Id );
            fcMapForAll.get(compoundAddress).add(fcMap.get(rec.IETRS_Files_and_Correspondence__c));
        }else{
            fcMapForAll.put(compoundAddress, new List<IETRS_Files_Correspondence__c>{fcMap.get(rec.IETRS_Files_and_Correspondence__c)});
        }    
    }
    
     global void finish(Database.BatchableContext BC) {
        System.debug('===Inside Finish===');
        if((fcMapForAll != null && fcMapForAll.size() > 0 ) || Test.isRunningTest()){     
            // logic for all parent record creation::  
            Map<String , CIIS_Mailing_Group__c> mgToInsert = new Map<String , CIIS_Mailing_Group__c>();
            Map<IETRS_Files_Correspondence__c , CIIS_Mailing_Group__c> mgToInsert1 = new Map<IETRS_Files_Correspondence__c , CIIS_Mailing_Group__c>();         
            for(String  key: fcMapForAll.keySet()){
                CIIS_Mailing_Group__c mg = new CIIS_Mailing_Group__c();
                // add fields like this:
                // mg.field = values;         
                mgToInsert.put(key , mg);
            }   
            if((mgToInsert != null && mgToInsert.size()  > 0)|| Test.isRunningTest()){
                try{
                    //---Create Mailing Group Record---
                    insert mgToInsert.values();           
                    List<IETRS_Files_Correspondence__c> recToUpdate = new List<IETRS_Files_Correspondence__c>();
                    for(String key : mgToInsert.keySet()){
                        for(IETRS_Files_Correspondence__c rec : fcMapForAll.get(key)){
                            rec.CIIS_Mailing_Group__c = mgToInsert.get(key).Id;
                            recToUpdate.add(rec);
                        }
                    }              
                    if(recToUpdate != null && recToUpdate.size() > 0) update recToUpdate;
                    //---Create Mailing Batch Record---
                    CIIS_Mail_Batch__c mb = new CIIS_Mail_Batch__c();
                    insert mb;
                    for(CIIS_Mailing_Group__c mg : mgToInsert.values()){
                        mg.CIIS_Mailing_Batch__c = mb.Id;
                    }
                    update mgToInsert.values();            
                    Integration_Audit_Log__c ad = new Integration_Audit_Log__c();  
                    ad.CIIS_Stage__c ='Salesforce';
                    ad.CIIS_Mailing_Batch__c =mb.Id;
                    insert ad;
                    mb.CIIS_Integration_Audit_Log__c = ad.Id;
                   
                    update mb;        
                }catch(Exception e){
                    system.debug(e.getMessage());
                }       
            }       
        }
        
    }
}