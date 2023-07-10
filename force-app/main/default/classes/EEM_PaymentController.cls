public class EEM_PaymentController {
    private RRCPaymentPortal paymentPortal;
    private EEM_Transaction__c transactionRecord;
    private EEM_RegisterNumberController registerNumberController;
    private static final Set<String> VALID_STATUSES = New Set<String> {'Pending', 'Authorized', 'Pending Adjustment', 'Processing','Canceled'};
    private static final String TIMEOUT_MESSAGE = 'A record of this transaction is not present.';
    private static final String PAYMENT_CONFIRMATION_URL = '{0}/events/s/eem-payment-confirmation';
    private static final String EEM_CLIENT_ID = 'EEM';
    private static final String NORECORD_MESSAGE = 'No Payment Record exists for the application ID';
    /**
    * @description Checks the status of a transaction and populates updates
    * @param lstIDs The Id of the transaction record
    * @return void 
    **/
    @InvocableMethod(label='Check Online Payment Status' description='Checks for status updates of online transactions in the Payment Portal and RMS' category='Transaction')
    public static void checkPaymentStatusInvoc(List<Id> lstIDs) {
        if(!lstIDs.isEmpty()) {
            EEM_PaymentController ctrl = new EEM_PaymentController(lstIDs.get(0));
            if(ctrl.isValidCheck()) {
                ctrl.checkPaymentStatus();
            }
        }
    }

    public EEM_PaymentController(Id recordId) {
        this.paymentPortal = new RRCPaymentPortal();
        this.registerNumberController = new EEM_RegisterNumberController();
        this.transactionRecord = [
            Select 
                Id
                ,Name
                ,CreatedDate
                ,EEM_Fee_Codes__c
                ,EEM_Remittance_Status__c
                ,EEM_Transaction_Amount__c                
            From EEM_Transaction__c
            Where Id = :recordId
            Limit 1
        ];
    }

    /**
    * @description Checks statuses of the transaction, and updates record accordingly
    * @return void 
    **/
    public void checkPaymentStatus() {
        String clientId = EEM_CLIENT_ID;
        String vremitId;
        PaymentResults payResults = paymentPortal.getPaymentResults(getApplicationId(transactionRecord.Name), clientId);
        
        if(payResults == null){
                transactionRecord.EEM_Failure_Message__c = NORECORD_MESSAGE +': '+ getApplicationId(transactionRecord.Name);
                transactionRecord.EEM_Remittance_Status__c = 'Pending';
        }
        if(payResults != null){
            transactionRecord.EEM_Record_ID__c = payResults.recordId;
            transactionRecord.EEM_Remittance_ID__c = payResults.remitId;
            transactionRecord.EEM_Texas_gov_Token__c = payResults.token;
            transactionRecord.EEM_Trace_Number__c = payResults.traceNumber;
            
            
            if(payResults.failureCode == 'Y') {
                transactionRecord.EEM_Failure_Message__c = NORECORD_MESSAGE +': '+ getApplicationId(transactionRecord.Name);
            }
            if(payResults.remitId == '0'){
              transactionRecord.EEM_Failure_Message__c ='Payment was started but not completed';  
            }
            
            if(payResults.remitId != null) {
                
                if(payResults.remitId != '0'){
                System.debug('checkPaymentStatus remitStatus : ' + payResults.remitStatus );
                    if(payResults.remitStatus == '1'){
                    transactionRecord.EEM_Failure_Message__c ='Payment was started but not completed';    
                    }    
                System.debug('checkPaymentStatus remitID : ' + payResults.remitId );
                RMSRemittanceResults remitResults = paymentPortal.getRemittanceResults(payResults.remitId);
                if(remitResults !=  null){
                transactionRecord.EEM_Register_Number__c = remitResults.registerNumber;
                transactionRecord.EEM_Remittance_Status__c = remitResults.remittanceStatus;
                transactionRecord.EEM_Total_Transaction_Amount__c = remitResults.receiptAmount;
                transactionRecord.EEM_Trace_Number__c = remitResults.traceNumber;
                transactionRecord.EEM_Payment_Method__c = remitResults.paymentMethod;
                transactionRecord.EEM_RMS_Create_Date__c = remitResults.createdDate;
                transactionRecord.EEM_Received_Date__c = remitResults.receivedDate;
                }
                }else{
                    
                    System.debug('checkPaymentStatus remitID equals to : ' + payResults.remitId );
                }
            }
             /// commented below line SS Remedy#91659/////
            //If 7 days later and still no record, fail it and set a message
           // if(!isValidCheck() && transactionRecord.CreatedDate.addDays(7) < Datetime.now()) {
           //     transactionRecord.EEM_Failure_Message__c = TIMEOUT_MESSAGE;
           //     transactionRecord.EEM_Remittance_Status__c = 'Error';
           // }
        } 
        ///else if(transactionRecord.CreatedDate.addDays(7) < Datetime.now()) { //If error in the web service call, check for 7 days anyways
        ///    transactionRecord.EEM_Failure_Message__c = TIMEOUT_MESSAGE;
        ///    transactionRecord.EEM_Remittance_Status__c = 'Error';
        /// }
        update transactionRecord;
    }

    public String getPaymentURL() {
        String clientId = EEM_CLIENT_ID;
		String feeCodes = transactionRecord.EEM_Fee_Codes__c.replace(';',',');
        String encryptedAmount = paymentPortal.getEncryptedPaymentAmount(transactionRecord.EEM_Transaction_Amount__c);
        String externalURL = EncodingUtil.urlEncode(String.format(PAYMENT_CONFIRMATION_URL, new String[] {URL.getSalesforceBaseUrl().toExternalForm(), transactionRecord.Id}), 'UTF-8');
        String uniqueId = transactionRecord.Name.replaceFirst('^0+', '');
        return paymentPortal.getPaymentURL(getApplicationId(transactionRecord.Name), clientId, feeCodes, externalURL, encryptedAmount, uniqueId);
    }

    /**
    * @description Checks to see if a check on this transaction should be checked
    * @return boolean True if transaction needs checking, false otherwise
    **/
    private boolean isValidCheck() {
        return VALID_STATUSES.contains(transactionRecord.EEM_Remittance_Status__c);
    }

    /**
    * @description Takes a record name and strips all leading characters and zeroes
    * @param recordName The name of the record
    * @return String The stripped record name to be used as the application Id
    **/
    private String getApplicationId(String recordName) {
        recordName = recordName.substringAfter('-');
        return String.valueOf(Integer.valueOf(recordName));
    }
}