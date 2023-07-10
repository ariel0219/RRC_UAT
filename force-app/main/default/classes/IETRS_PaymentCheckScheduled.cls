/**
 * @File Name          : IETRS_PaymentCheckScheduled.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 4/8/2020, 3:15:09 PM
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      4/1/2020        Kevin Lu                Initial Version
**/
public class IETRS_PaymentCheckScheduled implements Schedulable {
    //Run every weekday at 6AM and 12PM 
    public static String CRON_EXP = '0 0 6,12 ? * MON,TUE,WED,THU,FRI *';
    private static final Set<String> VALID_STATUSES = New Set<String> {'Pending', 'Authorized', 'Pending Adjustment', 'Processing'};

    public void execute(SchedulableContext context) {
        System.debug('Schedule Started');
        List<Id> listIds = new List<Id>(new Map<Id, IETRS_Transaction__c>([
            Select Id
            From IETRS_Transaction__c
            Where IETRS_Remittance_Status__c In :VALID_STATUSES
        ]).keySet());
        System.enqueueJob(new IETRS_PaymentCheckQueueable(listIDs));
    }
}

/* Anonymous execution to set the schedule
System.schedule('Twice-daily RRC Payment Portal Transaction Status Check', IETRS_PaymentCheckScheduled.CRON_EXP, new IETRS_PaymentCheckScheduled());
*/