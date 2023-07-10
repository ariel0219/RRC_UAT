/*Use the following code to execute this anonymously
Ticket88DataPrimer batchJob = new Ticket88DataPrimer();
ID jobID = Database.executeBatch(batchJob,100);
*/
public with sharing class Ticket88DataPrimer implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id, IETRS_Intra_Interstate__c, Type, IETRS_Entity_Sub_Type__c, IETRS_Total_Miles__c, IETRS_On_Offshore__c, '
            		+ 'IETRS_Product_Sub_Class__c, IETRS_T4_Permit__c, IETRS_Install_Year__c, IETRS_Product_Class__c '
                    + 'FROM Account '
                    + 'Where IETRS_Entity_Code__c = \'Y-Company System (Non-Physical)\' '
            		+ 'AND RecordType.Name = \'Regulated Entity - PS\' '
            		+ 'AND IETRS_OrganizationofRegEntity__r.RecordType.Name <> \'Archived Account\' '
            		+ 'AND Parent.RecordType.Name <> \'Archived Account\' '
            		+ 'AND IETRS_OrganizationofRegEntity__c <> null '
            		+ 'AND (Type <> \'\' OR IETRS_Entity_Sub_Type__c <> \'\' OR IETRS_Total_Miles__c >=0.001 '
            		+ 'OR IETRS_On_Offshore__c <> \'\' OR IETRS_Product_Sub_Class__c <> \'\' OR IETRS_T4_Permit__c <> \'\' '
            		+ 'OR IETRS_Install_Year__c <> \'\' OR IETRS_Product_Class__c <> \'\')';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        List<Account> accounts = new List<Account>();
        accounts = records;
        List<Account> updateAccounts = new List<Account>();
        for(Account a : accounts){
            if(a.Type != ''){
            	a.Type = '';    
            }if(a.IETRS_Entity_Sub_Type__c != ''){
                a.IETRS_Entity_Sub_Type__c = '';
            }if(a.IETRS_Total_Miles__c >=0.001){
            	a.IETRS_Total_Miles__c = 0.000; 
            }if(a.IETRS_On_Offshore__c <> ''){
            	a.IETRS_On_Offshore__c = '';         
            }if(a.IETRS_Product_Sub_Class__c <> ''){
                a.IETRS_Product_Sub_Class__c = '';
            }if(a.IETRS_T4_Permit__c <> ''){
                a.IETRS_T4_Permit__c = '';
            }if(a.IETRS_Install_Year__c <> ''){
                a.IETRS_Install_Year__c = '';
            }if(a.IETRS_Product_Class__c <> ''){
                a.IETRS_Product_Class__c = '';    
            }if(a.IETRS_Intra_Interstate__c == ''){
                a.IETRS_Product_Class__c = 'Intrastate';    
            }
        
            updateAccounts.add(a);
        }
        
        update updateAccounts;
    }

    public void finish(Database.BatchableContext bc) {
        // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob WHERE Id =
        :BC.getJobId()];
        try{
            // Send an email to the Apex job's submitter notifying of job completion.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Updated Non-Physical Organizations ' + a.Status);
            mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(exception e){
            System.debug(e);
        }
    }
}