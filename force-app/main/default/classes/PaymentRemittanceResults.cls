public class PaymentRemittanceResults {
    public String registerNumber;
    public String remittanceId;
    public String remitterId;
    public String remittanceStatus;
    public Decimal receiptAmount;
    public String traceNumber;
    public String paymentMethod;
    public DateTime createdDate;
    public String createdBy;
    public DateTime lastModifiedDate;
    public String lastModifiedBy;
    public DateTime receivedDate;
	public String checkNumber;

    public PaymentRemittanceResults(Dom.Document xmlDocument) {
        Dom.XmlNode remitInfoNode = xmlDocument.getRootElement();
        for(Dom.XmlNode childNode : remitInfoNode.getChildElements()) {
            switch on childNode.getName() {
                when 'registerNumber' {
                    this.registerNumber = childNode.getText();
                }
                when 'remitId' {
                    this.remittanceId = childNode.getText();
                }
                when 'remitterId' {
                    this.remitterId = childNode.getText();
                }
                when 'remitStatusCode' {
                    this.remittanceStatus = getRemittanceStatus(childNode.getText());
                }
                when 'receiptAmount' {
                    //Amounts come in with an implied decimal, so divide by 100 to take into account
                    this.receiptAmount = Decimal.valueOf(childNode.getText()) / 100;
                }
                when 'traceNumber' {
                    this.traceNumber = childNode.getText();
                }
                when 'paymentMethodCode' {
                    this.paymentMethod = getPaymentMethod(childNode.getText());
                }
                when 'createdDate' {
                    this.createdDate = parseDatetime(childNode.getText());
                }
                when 'createdBy' {
                    this.createdBy = childNode.getText();
                }
                when 'modifiedDate' {
                    this.lastModifiedDate = parseDatetime(childNode.getText());
                }
                when 'modifiedBy' {
                    this.lastModifiedBy = childNode.getText();
                }
                when 'receivedDate' {
                    this.receivedDate = parseDatetime(childNode.getText());
                }
				when 'checkNumber' {
                    this.checkNumber = childNode.getText();
                }
                when else {
                    System.debug('Ignore child element: ' + childNode.getName());
                }
            }
        }
    }

    private String getRemittanceStatus(String remittanceStatusCode) {
        switch on remittanceStatusCode {
            when '1' {
                return 'Pending';
            }
            when '2' {
                return 'Deleted';
            }
            when '3' {
                return 'Authorized';
            }
            when '4' {
                return 'In Finance';
            }
            when '5' {
                return 'Pending Adjustment';
            }
            when '6' {
                return 'Processing';
            }
            when '7' {
                return 'Error';
            }
            when '8' {
                return 'Void';
            }
            when '9' {
                return 'Canceled';
            }
            when '10' {
                return 'Denied';
            }
            when else {
                return '';
            }
        }
    }

    /**
    * @description Mapping function for payment method codes from RMS
    * @author Kevin Lu | 3/10/2020 
    * @param paymentMethodCode The payment method code
    * @return String The payment method
    **/
    private String getPaymentMethod(String paymentMethodCode) {
        switch on paymentMethodCode {
            when '1' {
                return 'Check';
            }
            when '2' {
                return 'Cash';
            }
            when '3' {
                return 'Credit Card - POS';
            }
            when '4' {
                return 'Credit Card';
            }
            when '5' {
                return 'Cashier Check';
            }
            when '6' {
                return 'Money Order';
            }
            when '7' {
                return 'ACH';
            }
            when else {
                return '';
            }
        }
    }

   
    private Datetime parseDatetime(String strDatetime) {
        Integer year = Integer.valueOf(strDatetime.substringBefore('-'));
        strDatetime = strDatetime.substringAfter('-');

        Integer month = Integer.valueOf(strDatetime.substringBefore('-'));
        strDatetime = strDatetime.substringAfter('-');

        Integer day = Integer.valueOf(strDatetime.substringBefore('T'));
        strDatetime = strDatetime.substringAfter('T');

        Integer hour = Integer.valueOf(strDatetime.substringBefore(':'));
        strDatetime = strDatetime.substringAfter(':');

        Integer minute = Integer.valueOf(strDatetime.substringBefore(':'));
        strDatetime = strDatetime.substringAfter(':');

        String secondString = strDatetime.substringBefore('-');
        Integer second = secondString.indexOf('.') > -1 ? Integer.valueOf(secondString.substringBefore('.')) : Integer.valueOf(secondString);
    
        return Datetime.newInstance(year, month, day, hour, minute, second);
    }
}