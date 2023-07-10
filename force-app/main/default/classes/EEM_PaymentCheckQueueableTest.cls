@istest
public class EEM_PaymentCheckQueueableTest {
    static testmethod void testPayment()
    {   List<Id> listids=new List<Id>();
     EEM_PaymentCheckQueueable ePQ= new EEM_PaymentCheckQueueable(listIDs);
     Test.startTest();
     System.enqueueJob(epq);
     Test.stopTest();
    } 
}