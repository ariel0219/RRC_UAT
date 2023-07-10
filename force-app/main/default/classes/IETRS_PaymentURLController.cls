/**
 * @File Name          : IETRS_PaymentURLController.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 4/13/2020, 1:44:15 PM
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      04/13/2020      Kevin Lu                Initial Version
**/
public class IETRS_PaymentURLController {
    @InvocableMethod(label='Get Payment Portal URL' description='Returns a URL to the Payment Portal for a given Transaction' category='Transaction')
    public static List<String> getPaymentURLInvoc(List<Id> lstIDs) {
        if(!lstIDs.isEmpty()) {
            IETRS_PaymentController ctrl = new IETRS_PaymentController(lstIDs.get(0));
            return new List<String> {ctrl.getPaymentURL()};
        } else{
            return new List<String> {'Error'};
        }
    }
}