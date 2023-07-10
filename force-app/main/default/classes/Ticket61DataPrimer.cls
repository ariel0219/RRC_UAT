/*Use the following code to execut this anonymously
Ticket61DataPrimer batchJob = new Ticket61DataPrimer();
ID jobID = Database.executeBatch(batchJob,100);
*/
public with sharing class Ticket61DataPrimer implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, IETRS_Open_Inspection_SubTypes__c, ('
                        + 'SELECT IETRS_Inspection_Sub_Type__c '
                        + 'FROM Inspection_Packages__r '
                        + 'WHERE IETRS_Status__c NOT IN (\'Closed\', \'Complete\')' 
                        + 'AND IETRS_Inspection_Sub_Type__c IN (\'DIMP\', \'Gas Control Room\', \'Gas Damage Prevention Activities\', \'Gas Drug and Alcohol\', '
                        + '\'Gas Integrity Mgmt\', \'Gas Operator Qual\', \'Gas Public Awareness\', \'Liquid Control Room\', '
                        + '\'Liquid Damage Prevention Activities\', \'Liquid Drug and Alcohol\', \'Liquid Integrity Mgmt\', \'Liquid Operator Qual\', '
                        + '\'Liquid Public Awareness\', \'Liquid O and M Proc\', \'Gas O and M Proc\'))'
                    + 'FROM Account '
                    + 'WHERE RecordType.Name = \'Unit\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        List<Account> accounts = new List<Account>();
        accounts = records;
        List<Account> updateAccounts = new List<Account>();
        for(Account a : accounts){
            for(IETRS_Inspection_Package__c ip :a.Inspection_Packages__r){
                if(a.IETRS_Open_Inspection_SubTypes__c==''||a.IETRS_Open_Inspection_SubTypes__c==null){
                    a.IETRS_Open_Inspection_SubTypes__c=ip.IETRS_Inspection_Sub_Type__c;
                    System.debug(a.IETRS_Open_Inspection_SubTypes__c);
                }else if(!a.IETRS_Open_Inspection_SubTypes__c.Contains(ip.IETRS_Inspection_Sub_Type__c)){
                    a.IETRS_Open_Inspection_SubTypes__c+=';'+ip.IETRS_Inspection_Sub_Type__c;
                    System.debug(a.IETRS_Open_Inspection_SubTypes__c);
                }
            }
            updateAccounts.add(a);
        }
        update updateAccounts;
    }

    public void finish(Database.BatchableContext bc) {
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
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
            mail.setSubject('Updated Accounts with open inspection packages ' + a.Status);
            mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(exception e){
            System.debug(e);
        }
    }
}