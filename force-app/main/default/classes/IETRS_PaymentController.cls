/**
 * @File Name          : IETRS_PaymentController.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 2020-08-23
 * @Modification Log   : 
 * Ver      Date            Author                  Modification
 * 1.0      04/01/2020      Kevin Lu                Initial Version
 * 2.0      04/13/2020      Kevin Lu                Built payment confirmation URL
 * 3.0      05/20/2020      Kevin Lu                Updated confirmation URL to be a community page
 * 4.0      06/08/2020      Kevin Lu                Updated to include regulated fee unique identifier
 * 5.0      08/10/2020      Kevin Lu                Changed to use encrypted payment amount
 * 5.1      08/19/2020      Kevin Lu                Removed PIPES/Regulated Fee lines for migration
 * 6.0      12/28/2022      Alex Ezhilarasan        Updated to include AFS record type related values.
**/
public class IETRS_PaymentController {
    private RRCPaymentPortal paymentPortal;
    private IETRS_Transaction__c transactionRecord;
    public static final String AFS_CLIENT_ID = 'AFS';
    private static final String DEFAULT_IV = '00000000000000000000000000000000'; //32 hex zeroes

    private static final Set<String> VALID_STATUSES = New Set<String> {'Pending', 'Authorized', 'Pending Adjustment', 'Processing'};
    private static final String TIMEOUT_MESSAGE = 'A record of this transaction is not present.';
    private static final String PAYMENT_CONFIRMATION_URL = '{0}/s/payment-confirmation?recordId={1}';
    private static final String AFS_PAYMENT_CONFIRMATION_URL = '{0}/s/afs-payment-confirmation1';
    
    /**
    * @description Checks the status of a transaction and populates updates
    * @author Kevin Lu | 4/8/2020 
    * @param lstIDs The Id of the transaction record
    * @return void 
    **/
    @InvocableMethod(label='Check Online Payment Status' description='Checks for status updates of online transactions in the Payment Portal and RMS' category='Transaction')
    public static void checkPaymentStatusInvoc(List<Id> lstIDs) {
        System.debug('lstIDs :::: ' + lstIDs);
        if(!lstIDs.isEmpty()) {
            IETRS_PaymentController ctrl = new IETRS_PaymentController(lstIDs.get(0));
            if(ctrl.isValidCheck()) {
                ctrl.checkPaymentStatus();
            }
        }
    }

    public IETRS_PaymentController(Id recordId) {
        System.debug('recordId :::: ' + recordId);
        this.paymentPortal = new RRCPaymentPortal();
        this.transactionRecord = [
            Select 
                Id
                ,Name
                ,CreatedDate
                ,IETRS_Fee_Code__c
                ,RRC_Fee_Codes__c
                ,IETRS_Remittance_Status__c
                ,IETRS_Case__r.CaseNumber
                ,IETRS_Transaction_Amount__c
                ,IETRS_Regulated_Fee__r.Name
                ,Quantity__c
            From IETRS_Transaction__c
            Where Id = :recordId
            Limit 1
        ];
    }

    /**
    * @description Checks statuses of the transaction, and updates record accordingly
    * @author Kevin Lu | 4/1/2020 
    * @return void 
    **/
    public void checkPaymentStatus() {
        String clientId = transactionRecord.RRC_Fee_Codes__c != NULL ? AFS_CLIENT_ID : transactionRecord.IETRS_Fee_Code__c == 'LG-OPP' ? RRCPaymentPortal.CASES_CLIENT_ID : RRCPaymentPortal.PIPES_CLIENT_ID;
        system.debug('clientId ::: ' + clientId);
        system.debug('getApplicationId(transactionRecord.Name) ::: ' + getApplicationId(transactionRecord.Name));
        PaymentResults payResults = paymentPortal.getPaymentResults(getApplicationId(transactionRecord.Name), clientId);
        if(payResults != null){
            transactionRecord.IETRS_Record_ID__c = payResults.recordId;
            transactionRecord.IETRS_Remittance_ID__c = payResults.remitId;
            transactionRecord.IETRS_Texas_gov_Token__c = payResults.token;
            transactionRecord.IETRS_Trace_Number__c = payResults.traceNumber;
            if(payResults.failureCode == 'Y') {
                transactionRecord.IETRS_Failure_Message__c = payResults.failureMessage;
            }

            if(payResults.remitId != null) {
                RMSRemittanceResults remitResults = paymentPortal.getRemittanceResults(payResults.remitId);
                transactionRecord.IETRS_Register_Number__c = remitResults.registerNumber;
                transactionRecord.IETRS_Remittance_Status__c = remitResults.remittanceStatus;
                transactionRecord.IETRS_Total_Transaction_Amount__c = remitResults.receiptAmount;
                transactionRecord.IETRS_Trace_Number__c = remitResults.traceNumber;
                transactionRecord.IETRS_Payment_Method__c = remitResults.paymentMethod;
                transactionRecord.IETRS_RMS_Create_Date__c = remitResults.createdDate;
                transactionRecord.IETRS_Received_Date__c = remitResults.receivedDate;
            }
            
            //If 7 days later and still no record, fail it and set a message
            if(!isValidCheck() && transactionRecord.CreatedDate.addDays(7) < Datetime.now()) {
                transactionRecord.IETRS_Failure_Message__c = TIMEOUT_MESSAGE;
                transactionRecord.IETRS_Remittance_Status__c = 'Error';
            }
        } else if(transactionRecord.CreatedDate.addDays(7) < Datetime.now()) { //If error in the web service call, check for 7 days anyways
            transactionRecord.IETRS_Failure_Message__c = TIMEOUT_MESSAGE;
            transactionRecord.IETRS_Remittance_Status__c = 'Error';
        }
        update transactionRecord;
    }

    public String getPaymentURL() {

        /* 
        String clientId = transactionRecord.RRC_Fee_Codes__c != NULL ? getClientId('AFS') : getClientId(transactionRecord.IETRS_Fee_Code__c) ;
        //String clientId = transactionRecord.IETRS_Fee_Code__c == 'LG-OPP' ? RRCPaymentPortal.CASES_CLIENT_ID : RRCPaymentPortal.PIPES_CLIENT_ID;
        String encryptedAmount = paymentPortal.getEncryptedPaymentAmount(transactionRecord.IETRS_Transaction_Amount__c);
        String externalURL = EncodingUtil.urlEncode(String.format(PAYMENT_CONFIRMATION_URL, new String[] {URL.getSalesforceBaseUrl().toExternalForm(), transactionRecord.Id}), 'UTF-8');
        String uniqueId = transactionRecord.RRC_Fee_Codes__c != NULL ? getUniqueId('AFS', transactionRecord) : getUniqueId(transactionRecord.IETRS_Fee_Code__c, transactionRecord) ;
        //String uniqueId = transactionRecord.IETRS_Fee_Code__c == 'LG-OPP' ? transactionRecord.IETRS_Case__r.CaseNumber.replaceFirst('^0+', '') : transactionRecord.IETRS_Regulated_Fee__r.Name.replace('REGFEE-', '').replaceFirst('^0+', '');
        //String uniqueId = transactionRecord.IETRS_Case__r.CaseNumber.replaceFirst('^0+', '');

        return paymentPortal.getPaymentURL(getApplicationId(transactionRecord.Name), clientId, transactionRecord.IETRS_Fee_Code__c, externalURL, encryptedAmount, uniqueId);
        */

        String clientId             = '';
        String feeCode              = '';
        String externalURL          = '';
        String encryptedAmount      = '';
        String encryptedquantity    = '';
        String uniqueId             = '';
        String retURL               = '';

        system.debug('transactionRecord ::: ' +transactionRecord);

        if( transactionRecord.RRC_Fee_Codes__c == NULL ){
            
            clientId        = transactionRecord.IETRS_Fee_Code__c == 'LG-OPP' ? RRCPaymentPortal.CASES_CLIENT_ID : RRCPaymentPortal.PIPES_CLIENT_ID;
            feeCode         = transactionRecord.IETRS_Fee_Code__c;
            externalURL     = EncodingUtil.urlEncode(String.format(PAYMENT_CONFIRMATION_URL, new String[] {URL.getSalesforceBaseUrl().toExternalForm(), transactionRecord.Id}), 'UTF-8');
            encryptedAmount = paymentPortal.getEncryptedPaymentAmount(transactionRecord.IETRS_Transaction_Amount__c);
            uniqueId        = transactionRecord.IETRS_Fee_Code__c == 'LG-OPP' ? transactionRecord.IETRS_Case__r.CaseNumber.replaceFirst('^0+', '') : transactionRecord.IETRS_Regulated_Fee__r.Name.replace('REGFEE-', '').replaceFirst('^0+', '');

            retURL          = paymentPortal.getPaymentURL(getApplicationId(transactionRecord.Name), clientId, feeCode, externalURL, encryptedAmount, uniqueId);
        } else{
            clientId            = AFS_CLIENT_ID;
            feeCode             = transactionRecord.RRC_Fee_Codes__c;
            externalURL         = EncodingUtil.urlEncode(String.format(AFS_PAYMENT_CONFIRMATION_URL, new String[] {URL.getSalesforceBaseUrl().toExternalForm()}), 'UTF-8');
            encryptedAmount   = paymentPortal.getEncryptedPaymentAmount(transactionRecord.IETRS_Transaction_Amount__c);
            encryptedquantity   = getEncryptedCommaSeperatedQuantity(transactionRecord.Quantity__c);
            //uniqueId            = transactionRecord.Name.replaceFirst('^0+', '');
            system.debug('uniqueId::: ' +  uniqueId);
            system.debug('externalURL::: ' +  externalURL);

            retURL              = paymentPortal.getPaymentURL(getApplicationId(transactionRecord.Name), clientId, feeCode, externalURL, encryptedAmount, encryptedquantity);
        }    

        //return paymentPortal.getPaymentURL(getApplicationId(transactionRecord.Name), clientId, feeCode, externalURL, encryptedAmount, uniqueId);
        return retURL;
    }

    /**
    * @description Checks to see if a check on this transaction should be checked
    * @author Kevin Lu | 4/1/2020 
    * @return boolean True if transaction needs checking, false otherwise
    **/
    private boolean isValidCheck() {
        return VALID_STATUSES.contains(transactionRecord.IETRS_Remittance_Status__c);
    }

    /**
    * @description Takes a record name and strips all leading characters and zeroes
    * @author Kevin Lu | 4/1/2020 
    * @param recordName The name of the record
    * @return String The stripped record name to be used as the application Id
    **/
    private String getApplicationId(String recordName) {
        recordName = recordName.substringAfter('-');
        return String.valueOf(Integer.valueOf(recordName));
    }

    /**
    * @description Based on IERTS Fee code return the Client ID
    * @author Alex Ezhilarasan | 12/28/2022
    * @return String clientId values
    **/
  /*  private String getClientId( String feeCode) {

        String retClientID = feeCode == 'AFS' ? AFS_CLIENT_ID : feeCode == 'LG-OPP' ? RRCPaymentPortal.CASES_CLIENT_ID : RRCPaymentPortal.PIPES_CLIENT_ID;
        return retClientID;
    } */

    /**
    * @description Based on IERTS Fee code return the Unique ID
    * @author Alex Ezhilarasan | 12/28/2022
    * @return String UniqueId values
    **/
   /* private String getUniqueId( String feeCode, IETRS_Transaction__c transactionRec ) {

        String retClientID = feeCode == 'AFS' ? transactionRec.Name.replaceFirst('^0+', '') : feeCode == 'LG-OPP' ? transactionRec.IETRS_Case__r.CaseNumber.replaceFirst('^0+', '') : transactionRec.IETRS_Regulated_Fee__r.Name.replace('REGFEE-', '').replaceFirst('^0+', '');
        return retClientID;
    }*/

    
    /**
    * @description Encrypts multiple quantity to send to the Payment Portal
    * @author Alex Ezhilarasan | 1/23/2023 
    * @param inputAmount The quantity value
    * @return String The encrypted multiple quantity value
    **/
    public String getEncryptedCommaSeperatedQuantity(String inputQuantity) {

        string strEncryptionKey;
        Boolean isSandbox = [Select IsSandbox From Organization Limit 1].IsSandbox;
        String configLabel = isSandbox ? 'Dev' : 'Prod';
        List<Payment_Portal_Configuration__mdt> paymentPortalConfigurations = [
            Select Label, Base_URL__c, Client_Id__c, Client_Secret__c, Encryption_Key__c
            From Payment_Portal_Configuration__mdt 
            Where Label = :configLabel Limit 1
        ];
        if(paymentPortalConfigurations.size() > 0){
            Payment_Portal_Configuration__mdt paymentPortalConfiguration = paymentPortalConfigurations.get(0);
            strEncryptionKey = paymentPortalConfiguration.Encryption_Key__c;
        }

        Blob quantity = Blob.valueOf(inputQuantity);

        //SHA1 Digest of Provided Key Value
        Blob key = Blob.valueOf(strEncryptionKey);
        Blob digestKey = Crypto.generateDigest('SHA1', key);

        //Get first 32 chars of Hex version of digest for the key
        String hexDigestKey = EncodingUtil.convertToHex(digestKey);
        String hexDigestKey128 = hexDigestKey.substring(0, 32);
        Blob privateKey = EncodingUtil.convertFromHex(hexDigestKey128);

        //IV of 0, which is the default IV in Java if unspecified
        Blob iv = EncodingUtil.convertFromHex(DEFAULT_IV);

        //Encrypt the value and return the encrypted value as a hex string
        Blob encryptedText = Crypto.encrypt('AES128', privateKey, iv, quantity);
        String result = EncodingUtil.convertToHex(encryptedText);
        return result;
    }
}