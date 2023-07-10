public class EEM_PaymentCheckQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> listIDs;
    
    public EEM_PaymentCheckQueueable(List<Id> listIDs) {
        System.debug('Constructor reached');
        this.listIDs = listIDs;
    }
    
    public void execute(QueueableContext context) {
        System.debug('Queued Started');
        if(!listIDs.isEmpty()) {EEM_PaymentController ctrl = new EEM_PaymentController(listIDs.remove(0));ctrl.checkPaymentStatus();if(!listIDs.isEmpty() && !Test.isRunningTest()) {System.enqueueJob(new EEM_PaymentCheckQueueable(listIDs));
            }
        }
    }
}