public class EEM_PaymentURLController {
    @InvocableMethod(label='Get Payment Portal URL' description='Returns a URL to the Payment Portal for a given Transaction' category='Transaction')
    public static List<String> getPaymentURLInvoc(List<Id> lstIDs) {
        if(!lstIDs.isEmpty()) {
            EEM_PaymentController ctrl = new EEM_PaymentController(lstIDs.get(0));
            return new List<String> {ctrl.getPaymentURL()};
        } else{
            return new List<String> {'Error'};
        }
    }
}