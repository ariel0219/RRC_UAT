/**
 * @author Greg Lovelidge - Sense Corp
 * @date 5/29/2020
 *
 * @description Contains business logic for finding unpaid fees and adding late fees.
 */
public with sharing class IETRS_I_LateFees {
    /**
     * Class constants
     */
    final String distributionType = 'Distribution';
    final String mmType = 'Master Meter';
    final List<String> feeTypes = new List<String>{ distributionType, mmType };

    /**
     * @description Penalty fees stored in custom metadata
     */
    Map<String, Decimal> penaltyFeeByType {
        get {
            if (this.penaltyFeeByType == null) {
                try {
                    IETRS_Fees_by_Year__mdt penaltyFees = [
                        SELECT IETRS_MM_Payment_Penalty_Percent__c, IETRS_Dist_Payment_Penalty_Percent__c
                        FROM IETRS_Fees_by_Year__mdt
                        WHERE IETRS_Fee_Year__c = :String.valueOf(this.feeDate.year())
                        LIMIT 1
                    ];
                    this.penaltyFeeByType = new Map<String, Decimal>{
                        distributionType => penaltyFees.IETRS_Dist_Payment_Penalty_Percent__c * .01,
                        mmType => penaltyFees.IETRS_MM_Payment_Penalty_Percent__c * .01
                    };
                } catch (Exception e) {
                    this.penaltyFeeByType = new Map<String, Decimal>();
                }
            }
            return this.penaltyFeeByType;
        }
        set;
    }

    /**
     * @description Penalty dates stored in custom metadata
     */
    Map<String, Date> penaltyDatesByType {
        get {
            if (this.penaltyDatesByType == null) {
                try {
                    Conga_Components__mdt penaltyDates = [
                        SELECT IETRS_Distribution_Fees_Delinquency_Date__c, IETRS_Master_Meter_Fees_Delinquency_Date__c
                        FROM Conga_Components__mdt
                        LIMIT 1
                    ];
                    this.penaltyDatesByType = new Map<String, Date>{
                        distributionType => penaltyDates.IETRS_Distribution_Fees_Delinquency_Date__c,
                        mmType => penaltyDates.IETRS_Master_Meter_Fees_Delinquency_Date__c
                    };
                } catch (Exception e) {
                    this.penaltyDatesByType = new Map<String, Date>();
                }
            }
            return this.penaltyDatesByType;
        }
        set;
    }

    /**
     * @description List of fee types that should be calculated
     */
    List<String> lateFeeTypesToCalculate {
        get {
            if (this.lateFeeTypesToCalculate == null) {
                List<String> result = new List<String>();
                String feeMonthDay = String.valueOf(feeDate.month()) + String.valueOf(feeDate.day()); // 1025
                for (String feeType : feeTypes) {
                    Date delinquencyDate = penaltyDatesByType.get(feeType);
                    String delinquencyMonthDay =
                        String.valueOf(delinquencyDate.month()) + String.valueOf(delinquencyDate.day());
                    if (feeMonthDay == delinquencyMonthDay) {
                        result.add(feeType);
                    }
                }
                this.lateFeeTypesToCalculate = result;
            }
            return this.lateFeeTypesToCalculate;
        }
        set;
    }

    /**
     * @description The date used to compare against the fee dates stored in custom settings
     */
    private Date feeDate;

    /**
     * @description Class constructor
     */
    public IETRS_I_LateFees(Date feeDate) {
        this.feeDate = feeDate;
        calculateLateFees();
    }

    /**
     * @description Calculate and set late fees
     */
    private void calculateLateFees() {
        // if there are no fees, do nothing
        if (lateFeeTypesToCalculate.isEmpty()) {
            return;
        }

        // Query and set late fee on the unpaid fees
        List<IETRS_Insp_Regulated_Fee__c> updateFees = new List<IETRS_Insp_Regulated_Fee__c>();
        for (IETRS_Insp_Regulated_Fee__c fee : [
            SELECT Id, IETRS_Total_Regulated_Fees__c, IETRS_Late_Fee__c, IETRS_Fee_Type__c
            FROM IETRS_Insp_Regulated_Fee__c
            WHERE IETRS_Status__c = 'Not Paid' AND IETRS_Fee_Type__c IN :lateFeeTypesToCalculate
        ]) {
            Decimal feePercentage = penaltyFeeByType.get(fee.IETRS_Fee_Type__c);
            if (feePercentage != null) {
                fee.IETRS_Late_Fee__c = fee.IETRS_Total_Regulated_Fees__c * penaltyFeeByType.get(fee.IETRS_Fee_Type__c);
                updateFees.add(fee);
            }
        }

        // Update the fees
        update updateFees;
    }
}