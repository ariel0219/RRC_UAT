/**
 * @File Name          : IETRS_PaymentControllerExt.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 5/20/2020, 1:46:43 PM
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      4/2/2020        Kevin Lu                Initial Version
 * 2.0      4/9/2020        Kevin Lu                Moved DML out of constructor
**/
public class IETRS_PaymentControllerExt {
    private String applicationId;
    private String texasGovResponse;
    private IETRS_PaymentController paymentController;

    public IETRS_PaymentControllerExt(ApexPages.StandardController stdController) {
        System.debug('Controller Start');
        Map<String, String> mapParameters = ApexPages.currentPage().getParameters();
        this.applicationId = mapParameters.containsKey('applicationId') ? mapParameters.get('applicationId') : null;
        this.texasGovResponse = mapParameters.containsKey('texasGovResponse') ? mapParameters.get('texasGovResponse') : null;
        if(stdController.getId() != null) {
            paymentController = new IETRS_PaymentController(stdController.getId());
        }
    }

    public void checkStatus() {
        System.debug('Status Check Start');
        if(paymentController != null) {
            paymentController.checkPaymentStatus();
        }
    }

    public String getApplicationId() {
        return applicationId;
    }

    public String getTexasGovResponse() {
        return texasGovResponse;
    }
}