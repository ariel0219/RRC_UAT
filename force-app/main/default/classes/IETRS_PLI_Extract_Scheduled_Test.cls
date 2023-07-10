@isTest
public class IETRS_PLI_Extract_Scheduled_Test {
    static testmethod void myTest(){
        test.startTest();
            IETRS_PLI_Extract_Scheduled myTest = new IETRS_PLI_Extract_Scheduled ();   
            String chron = '0 0 23 * * ?';        
            system.schedule('Test Sched', chron, myTest);
        test.stopTest();
        //System.assertEquals(1,1);
    }
}