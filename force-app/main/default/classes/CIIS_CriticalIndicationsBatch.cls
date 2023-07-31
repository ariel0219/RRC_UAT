/**
* @File Name          : CIIS_CriticalIndicationsBatch.cls
* @Description        : Create Critical Indication records
* @Author             : Vishwanath Kodgire
* @Test Class		  : CIIS_CIBatchScheduler_Test
* @Group              :
* @Last Modified By   : Vishwanath Kodgire
* @Last Modified On   : 07/21/2023
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0   	07/21/2023  	 		Vishwanath Kodgire    		Initial Version
**/

public class CIIS_CriticalIndicationsBatch implements Database.Batchable<Sobject> {
    List<Account> accountsToUpdate = new List<Account>();
    String errorOccured = '';
    CIDX_Filing_Period__c currentCFPrecord = new CIDX_Filing_Period__c();
    List<String> PLClassifications = new List<String>{'Oil Lease', 'Gas Lease', 'GPF', 'UGI EOR', 'SWD - Well', 'SWD – NGP', 'UGS – Salt Cavern', 'UGS - Reservoir', 'LDC Compressor Station', 'PL Compressor Station', 'PL Regulator - LDC','PL Regulator - NGP', 'NGLS', 'PL Control Center - LDC', 'PL Control Center - NGP', 'PL Meter - LDC', 'PL Meter - NGP' };
        public CIIS_CriticalIndicationsBatch(CIDX_Filing_Period__c cfp){
            currentCFPrecord = cfp;
        }
    public Database.QueryLocator start(Database.BatchableContext bc) {
            
            return Database.getQueryLocator([ SELECT ID,
                                             CIIS_PL_Classification__c,
                                             CIIS_Reg_Entity_MCF_day__c,
                                             CIIS_Meets_CID__c
                                             FROM Account 
                                             WHERE RecordType.Name LIKE '%Regulated Entity%' AND IETRS_OrganizationofRegEntity__c != NULL]);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope){
        List<CIDX_Critical_Indication__c> newCIs = new List<CIDX_Critical_Indication__c>();
        try{
            for(Account acc: scope){
                if((acc.CIIS_PL_Classification__c == 'Oil Lease' && acc.CIIS_Reg_Entity_MCF_day__c >= 500) || (acc.CIIS_PL_Classification__c == 'Gas Lease' && acc.CIIS_Reg_Entity_MCF_day__c >= 250)){
                    acc.CIIS_Meets_CID__c = true;
                    accountsToUpdate.add(acc);
                    system.debug('HEre 1 ->>');
                }
                else if(acc.CIIS_PL_Classification__c == 'Oil Lease' || acc.CIIS_PL_Classification__c == 'Gas Lease'){
                    acc.CIIS_Meets_CID__c = false;
                    accountsToUpdate.add(acc);
                    system.debug('HEre 2 ->>');
                }
                
                if(acc.CIIS_Meets_CID__c && PLClassifications.contains(acc.CIIS_PL_Classification__c)){
                    system.debug('HEre 3 ->>');
                    CIDX_Critical_Indication__c CI = new CIDX_Critical_Indication__c();
                    CI.CIDX_Filing_Period__c = currentCFPrecord.ID;
                    CI.Name = currentCFPrecord.CIDX_Filing_Session__c + ' ' + currentCFPrecord.CIDX_Filing_Year__c + ' ' + 'Critical Indication';
                    CI.CIDX_Regulated_Entity__c = acc.ID;
                    CI.CIDX_Meets_Critical__c = 'Yes';
                    newCIs.add(CI);
                }
            }
            if(!newCIs.isEmpty())
                Insert newCIs;
            if(!accountsToUpdate.isEmpty())
                Update accountsToUpdate;
            
            system.debug('newCIs ->> ' + newCIs);
        }
        
        catch(exception e){
            errorOccured = e.getMessage() +'  ' + e.getCause();
            System.debug('Exception Occured in Critical Indication creation batch: ' + e.getMessage());
        }
    }    
    public void finish(Database.BatchableContext bc){   
        if(errorOccured != ''){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Error occured in Critical Indication Batch');
            email.setHtmlBody(errorOccured);
            email.setToAddresses(new List<String>{ 'vishwanathdilip.kodgire@cgi.com' , 'nicholas.levingston@cgi.com'});
            email.setSaveAsActivity(false);
            // Send the email
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        }
    } 
}