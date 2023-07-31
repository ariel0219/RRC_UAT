/* Use the following code to execute this anonymously
CIIS_Generate_SB3MAP_Letters batchJob = new CIIS_Generate_SB3MAP_Letters();
Id batchJobId = Database.executeBatch(batchJob, 100);
*/
public with sharing class CIIS_Generate_SB3MAP_Letters implements Database.Batchable <sObject> {
    @InvocableMethod(label = 'Run My Batch')
    public static void runMyBatch(List<String> lst) {
        Database.executeBatch(new CIIS_Generate_SB3MAP_Letters(), 5);
    }
    
    public final String query = 'SELECT Id FROM CIIS_Supply_Chain_Connection__c WHERE Id NOT IN (Select CIIS_Supply_Chain_Connection__c from CIIS_Supply_Chain_Letter__c WHERE CIIS_Document_Name__c = \'MAP Letter\') AND CIIS_Status__c IN (\'Confirmed\', \'Pending\', \'Delinquent\')';
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> records){
            for(sObject record : records) {
            if(record != null){
            String documentName = 'MAP Letter';
            Flow.Interview myFlow = new Flow.Interview.CIIS_Files_Correspondence_Creation_for_Letter_Generation(new Map<String,Object>{
                    'SCLDocumentName' => documentName,
                    'SupplyChainConnectionID' => record.Id
            });
                myFlow.start();
            } else {
                return;
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}