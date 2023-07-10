/*Use the following code to execut this anonymously
Ticket18DataPrimer batchJob = Ticket18DataPrimer();
ID jobID = Database.executeBatch(batchJob,100);
*/
public without sharing class Ticket18DataPrimer implements Database.Batchable<sObject>{

    public final string query;

    public Ticket18DataPrimer(){
        query = 'SELECT id, IETRS_Case__c, (SELECT Id, IETRS_CASE__c FROM IETRS_Related_Tracking_Dates__r) FROM IETRS_Tracking_Date__c WHERE IETRS_CASE__c != Null';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        List<IETRS_Tracking_Date__c> trackingDates = new List<IETRS_Tracking_Date__c>();
        List<IETRS_Related_Tracking_Date__c> relatedTrackingDateList = new List<IETRS_Related_Tracking_Date__c>();
        
        trackingDates = records;

        for (IETRS_Tracking_Date__c td : trackingDates){
            boolean isFound = False;
            for(IETRS_Related_Tracking_Date__c relatedTrackingDate : td.IETRS_Related_Tracking_Dates__r){
                if(td.IETRS_Case__c == relatedTrackingDate.IETRS_Case__c){
                    isFound = True;
                    break;
                }
            }

            if(!isFound){
                IETRS_Related_Tracking_Date__c rtd = new IETRS_Related_Tracking_Date__c();
                rtd.IETRS_Case__c = td.IETRS_Case__c;
                rtd.IETRS_Tracking_Date_Name__c = td.id;
                relatedTrackingDateList.add(rtd);
            }
        }

        try {
            insert relatedTrackingDateList;
        } catch (Exception e) {
            System.debug(e);
        }
    }

    public void finish(Database.BatchableContext bc){

        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob WHERE Id =
        :BC.getJobId()];
        System.debug(a);        
        
        // Send an email to the Apex job's submitter notifying of job completion.
        /*
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Generated Releated Tracking Dates ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        */
    }
}