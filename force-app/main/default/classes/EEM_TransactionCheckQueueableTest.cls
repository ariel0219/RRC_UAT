@isTest
public class EEM_TransactionCheckQueueableTest 
{
     @isTest static void TestList()
     {
        List<Id> listIds = new List<Id>(new Map<Id, EEM_Transaction__c>([
            Select Id
            From EEM_Transaction__c
            Where EEM_Remittance_Status__c = 'Pending' and EEM_Register_Number__c = null order by Id LIMIT 1
        ]).keySet());
	  
         EEM_TransactionCheckQueueable testque = new EEM_TransactionCheckQueueable(listIDs);
         
         
          Test.startTest();
            System.enqueueJob(testque);
          Test.stopTest();
      }
 }