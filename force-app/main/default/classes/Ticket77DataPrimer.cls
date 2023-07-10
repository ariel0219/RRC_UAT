/*Use the following code to execute this anonymously
Ticket77DataPrimer batchJob = new Ticket77DataPrimer();
ID jobID = Database.executeBatch(batchJob,100);
*/
public with sharing class Ticket77DataPrimer implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id, ParentId, Parent.Id, Parent.IETRS_Is_Parent_Case__c '
                    + 'FROM Case '
                    + 'Where ParentId <> null '
            		+ 'AND Parent.IETRS_Is_Parent_Case__c <> true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        List<Case> cases = new List<Case>();
        cases = records;
        map<Id,Case> caseMap = new map<Id,Case>();
        for(Case c : cases){
            c.Parent.IETRS_Is_Parent_Case__c = true;
            caseMap.put(c.ParentId, c.Parent);
        }
        
        update caseMap.values();
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
            mail.setSubject('Updated Cases with Parent Records ' + a.Status);
            mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(exception e){
            System.debug(e);
        }
    }
}