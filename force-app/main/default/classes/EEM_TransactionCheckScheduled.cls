public class EEM_TransactionCheckScheduled implements Schedulable {
    //Run every weekday at 7AM and 7PM (10 12 2 4 for testing)
    public static String CRON_EXP = '0 0 7,19 ? * MON,TUE,WED,THU,FRI *';
    
public void execute(SchedulableContext context) {
        System.debug('Schedule Started');
        List<Id> listIds = new List<Id>(new Map<Id, EEM_Transaction__c>([
            Select Id
            From EEM_Transaction__c
            Where EEM_Remittance_Status__c = 'Pending' and EEM_Register_Number__c = null order by Name desc
        ]).keySet());
        System.enqueueJob(new EEM_TransactionCheckQueueable(listIDs));
    }
}

/* Anonymous execution to set the schedule
System.schedule('Twice-daily 7am and 7pm EEM Transactions Status Check', EEM_TransactionCheckScheduled.CRON_EXP, new EEM_TransactionCheckScheduled());
*/