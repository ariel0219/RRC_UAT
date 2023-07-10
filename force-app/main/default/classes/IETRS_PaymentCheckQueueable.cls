/**
 * @File Name          : IETRS_PaymentCheckQueueable.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 4/8/2020, 3:17:46 PM
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      4/1/2020        Kevin Lu                Initial Version
**/
public class IETRS_PaymentCheckQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> listIDs;
    
    public IETRS_PaymentCheckQueueable(List<Id> listIDs) {
        System.debug('Constructor reached');
        this.listIDs = listIDs;
    }
    
    public void execute(QueueableContext context) {
        System.debug('Queued Started');
        if(!listIDs.isEmpty()) {
            IETRS_PaymentController ctrl = new IETRS_PaymentController(listIDs.remove(0));
            ctrl.checkPaymentStatus();
            if(!listIDs.isEmpty() && !Test.isRunningTest()) {
                System.enqueueJob(new IETRS_PaymentCheckQueueable(listIDs));
            }
        }
    }
}