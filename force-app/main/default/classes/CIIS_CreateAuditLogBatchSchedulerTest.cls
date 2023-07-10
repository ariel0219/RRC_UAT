@isTest
public class CIIS_CreateAuditLogBatchSchedulerTest {
    public static testMethod void testschedule() {
        
        Test.StartTest();
        CIIS_CreateAuditLogBatchScheduler sh1 = new CIIS_CreateAuditLogBatchScheduler();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Audit Creation Check', sch, sh1); 
        Test.stopTest(); 
    }
}