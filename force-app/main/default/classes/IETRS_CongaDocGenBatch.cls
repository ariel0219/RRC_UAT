/* 
Test Class : IETRS_CongaDocGenBatchTest

Use the following code to execut this anonymously
String context = 'Master Meter Invoice';
Integer year = 2022;
IETRS_CongaDocGenBatch batchJob = new IETRS_CongaDocGenBatch(context, year);
ID jobID = Database.executeBatch(batchJob,100);
*/

public without sharing class IETRS_CongaDocGenBatch implements Database.Batchable<sObject>, Database.Stateful{
    public final String CONTEXT;
    public final Integer YEAR;
    private String QUERY;

    public IETRS_CongaDocGenBatch(String c, Integer y) {
        CONTEXT = c;
        YEAR = y;
        Switch on CONTEXT{
            when 'Master Meter Invoice'{
                QUERY = IETRS_MMInvoiceGenerationService.setQuery(CONTEXT, YEAR);
            }
            //for future use cases of mass document generation
            when ''{
                QUERY = '';
            }
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        Switch on CONTEXT{
            when 'Master Meter Invoice'{
                List<IETRS_Insp_Regulated_Fee__c> regfeesList = new List<IETRS_Insp_Regulated_Fee__c>();
                regfeesList = records;
                IETRS_MMInvoiceGenerationService.createFiles(regfeesList, CONTEXT);
            }
            //future user case for additional mass document generation
            /*
            when ''{
                            
            }
            */
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

        //call the relevant post batch method
        Switch on CONTEXT{
            when 'Master Meter Invoice'{
                IETRS_MMInvoiceGenerationService.prepCongaBatch(CONTEXT);
            }
            //for future use cases of mass document generation
            when ''{
                QUERY = '';
            }
    }

        // Send an email to the Apex job's submitter notifying of job completion.
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject(context + ' for '+year+' is now '+a.Status);
            mail.setPlainTextBody
            ('The batch Apex job to generate '+context+' documents has processed '+a.TotalJobItems+
            ' batches with '+a.NumberOfErrors+' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            system.debug('Email send error: '+ e);
        }
    }
}