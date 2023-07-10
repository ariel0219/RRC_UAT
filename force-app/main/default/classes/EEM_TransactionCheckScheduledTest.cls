@isTest
public class EEM_TransactionCheckScheduledTest {
    static testmethod void myTest(){
        test.startTest();
            EEM_TransactionCheckScheduled myTest = new EEM_TransactionCheckScheduled ();   
            String chron = '0 0 23 * * ?';        
            system.schedule('Test EEM Trans Sched', chron, myTest);
        test.stopTest();
        //System.assertEquals(1,1);
    }
}