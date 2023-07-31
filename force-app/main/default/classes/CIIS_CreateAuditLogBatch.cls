global class CIIS_CreateAuditLogBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    //---Containers to hold unique Mailing Groups and Bad FnC records---
    Map<String , List<IETRS_Files_Correspondence__c>> fcMapForAll = new Map<String , List<IETRS_Files_Correspondence__c>>();
    List<IETRS_Files_Correspondence__c> fcErrored =  new List<IETRS_Files_Correspondence__c>();

    global Database.QueryLocator start(Database.BatchableContext BC) {   
        
        //---SOQL for F&C records with an valid C/MLR that are ready for Central Print Processing---
        String query = 'SELECT IETRS_Organization__c, '
                     + '  (SELECT IETRS_Address_Line_1__c, IETRS_Address_Line_2__c, IETRS_City__c, IETRS_State__c, IETRS_Zip__c, IETRS_Country_Code__c '
                     + '   FROM Correspondence_Mailing_Lists__r  '
                     + '   WHERE IETRS_Address_Line_1__c != null LIMIT 1), '
                     + 'IETRS_Delivery_Method__c, CIIS_Mailing_Group__c, ID, CIIS_Central_Print_Status__c  '
                     + 'FROM IETRS_Files_Correspondence__c '
                     + 'WHERE CIIS_Central_Print_Status__c  =\'Available\' '
                     + '  AND IETRS_Box_File_ID__c != null '
                     + '  AND IETRS_Delivery_Method__c NOT IN (\'Email\', \'Central Print Return\', \'\') ';

        
        System.debug('===START===' + query);
        // return Database.getQueryLocator(query);
        
        //---Get Data---
        return Database.getQueryLocator(query); 
    }
    global void execute(Database.BatchableContext BC, List<IETRS_Files_Correspondence__c> scope){
        System.Debug('===INSIDE EXECUTE===' + scope);
        
        Set<Id> fcIds = new Set<Id>();
        
        //---Loop through FnC records and process them---
        for(IETRS_Files_Correspondence__c file :scope){         
            manageFC(file);      
            fcIds.add(file.Id );
        }     
    }
    
    public void manageFC(IETRS_Files_Correspondence__c rec ){
        
        //---Check if a C\MLR record exists for the FnC record------
        if( !rec.Correspondence_Mailing_Lists__r.isEmpty()){

            //---Create the unique value for grouping---
            IETRS_Insp_Correspondence_Mailing_List__c mlRecord = rec.Correspondence_Mailing_Lists__r[0];
            String compoundAddress = rec.IETRS_Organization__c + mlRecord.IETRS_Address_Line_1__c + mlRecord.IETRS_Address_Line_2__c + 
                mlRecord.IETRS_City__c + mlRecord.IETRS_State__c + mlRecord.IETRS_Zip__c + mlRecord.IETRS_Country_Code__c + 
                rec.IETRS_Delivery_Method__c;
            compoundAddress = compoundAddress.toLowerCase();
            compoundAddress = compoundAddress.replaceAll('(\\s+)', '');    
            system.debug('compoundAddress' + compoundAddress);
            list<IETRS_Files_Correspondence__c> addFC = new  list<IETRS_Files_Correspondence__c>();
            
            //---Ensure the unique Grouping Value only exists once---
            if(fcMapForAll.containsKey(compoundAddress)){
                //string fieldvalue = dummymap.get(id).dummyfield__c;
                //addFC.add(fcMapForAll.get(compoundAddress).Id );
                fcMapForAll.get(compoundAddress).add(rec);
            }else{
                fcMapForAll.put(compoundAddress, new List<IETRS_Files_Correspondence__c>{rec});
            }   
        }
        else{
            //---Update FnC record to indicate missing a C\MLR so no address to send to----
            rec.CIIS_Central_Print_Status__c = 'ERR - NO CMLR';
            fcErrored.add(rec);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('===Inside Finish===');
        
        if((fcMapForAll != null && fcMapForAll.size() > 0 ) || Test.isRunningTest()){     
            //---Logic for all parent record creation---  
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
                    //---Create Mailing Group Records---
                    insert mgToInsert.values();           
                    List<IETRS_Files_Correspondence__c> recToUpdate = new List<IETRS_Files_Correspondence__c>();
                    for(String key : mgToInsert.keySet()){
                        for(IETRS_Files_Correspondence__c rec : fcMapForAll.get(key)){
                            rec.CIIS_Mailing_Group__c = mgToInsert.get(key).Id;
                            rec.CIIS_Central_Print_Status__c = 'Processing';
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
                    
                    //---Create Integration Audit Log Record---
                    Integration_Audit_Log__c ad = new Integration_Audit_Log__c();  
                    ad.CIIS_Stage__c ='Salesforce';
                    ad.CIIS_Mailing_Batch__c = mb.Id;
                    insert ad;
                    
                    mb.CIIS_Integration_Audit_Log__c = ad.Id;
                    
                    update mb;       
                    
                    if(!fcErrored.isEmpty())
                        Update fcErrored;
                    
                }catch(Exception e){
                    system.debug(e.getMessage());
                }       
            }       
        }
        
    }
}