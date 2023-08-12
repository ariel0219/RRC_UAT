/**
 * @File Name          : CIIS_InspScheduleServices.cls
 * @Description        : Generates Inspection schedules (workplan)
 * @Author             : Sebastian Wittenstein
 * @Group              : CIIS WO8 WS1
 * @Last Modified By   : Sebastian Wittenstein
 * @Last Modified On   : 02/09/2023
 * @Modification Log   :
 *==============================================================================
 * Ver      Date            Author                  Modification
 *==============================================================================
 * 1.0      02/09/2023      Sebastian Wittenstein   Initial Version
 **/

 public with sharing class CIIS_InspScheduleServices {

    private static final String OP_GREATER_THAN = 'Greater Than';
    private static final String OP_LESS_THAN = 'Less Than';
    private static final String OP_BETWEEN = 'Between';
    private static final String OP_NONE = 'None';
    private static final Decimal emptyDecimal;

    /**
     * @description - Check risk factor logic against this account
     * @author Sebastian Wittenstein | 02/09/2023
     * @param IETRS_Insp_InspSchedConfig__c risk - Risk factor details
     * @param Account re - Regulated Entity account to check
     * @param IETRS_Inspection__c insp - Related inspection records for the Regulated Entity
     * @param IETRS_InspSchedConfig__c frequency - The Frequency Config record related to the business area and RE Type
     * @return Boolean - Was risk factor applied?
     */
    public static Boolean checkRiskFactor(RiskFactorRequest rFR) {
        String code = rFR.risk.IETRS_Priority_Code__c,
               operator = rFR.risk.IETRS_Condition_Operator__c;
        System.debug('checkingRiskFactor the priority code is: ' + code);
        Decimal value1 = rFR.risk.IETRS_Value_One__c, 
                value2 = rFR.risk.IETRS_Value_Two__c;
        if(!Test.isRunningTest()){
        switch on code {
            when 'Gas Processing Plants' {
                if (
                    rFR.risk.IETRS_Priority__c == '1' &&
                    rFR.regEntity.Type == 'Gas Processing Facility'

                ) {
                    return true;
                }
            }
            when 'Control Center'{
                    if(rFR.regEntity.CIIS_Direct_Serve__c != null &&
                       rFR.regEntity.CIIS_Direct_Serve__c && 
                       rfr.risk.IETRS_Priority__c == '1'&&
                       rFR.regEntity.Type =='Control Center'){
                        
                        return true;
                    }
                  
                }
            when 'Meter Station'{
                
                    if(rFR.regEntity.CIIS_Direct_Serve__c != null &&
                       rFR.regEntity.CIIS_Direct_Serve__c &&
                       rfr.risk.IETRS_Priority__c == '1'&&
                       rFR.regEntity.Type =='Meter Station'){
                        return true;
                    }
                  
                    
                }
            when 'Regulator Station'{
                    if(rFR.regEntity.CIIS_Direct_Serve__c != null &&
                       rFR.regEntity.CIIS_Direct_Serve__c && 
                       rfr.risk.IETRS_Priority__c == '1' &&
                       rFR.regEntity.Type =='Regulator Station'){
                        return true;
                    }
             
                }
            when 'Natural Gas Liquid Storage'{
                    if(rfr.risk.IETRS_Priority__c == '2'&&
                       rFR.regEntity.Type =='Natural Gas Liquid Storage'){
                           
                        return true;
                    }   
                }
            when 'Storage' {
                if (
                    rFR.risk.IETRS_Priority__c == '1' &&
                    rFR.regEntity.Type == 'Storage') {
                    return true;
                }
            }
            when 'Direct Transmission' {
                if (
                    rFR.regEntity.CIIS_Direct_Serve__c != null &&
                    rFR.regEntity.CIIS_Direct_Serve__c && 
                    rFR.risk.IETRS_Priority__c == '1' &&
                    rFR.regEntity.Type == 'Transmission') {
                    
                    return true;
                }
            }
            when 'Lease > 5000 mcf/day' {
                if (
                    rFR.regEntity.CIIS_Reg_Entity_MCF_day__c != null &&
                    operator == OP_GREATER_THAN &&
                    rFR.risk.IETRS_Priority__c == '1' &&
                    (
                        rFR.regEntity.Type == 'Lease' ||
                        rFR.regEntity.Type == 'Well' 
           
                    )
                ) {
                    return rFR.regEntity.CIIS_Reg_Entity_MCF_day__c > value1;
                }
            }
            when 'Indirect Compressor' {
                if( rFR.regEntity.CIIS_Direct_Serve__c != null &&
                    rFR.risk.IETRS_Priority__c == '2' &&
                    (rFR.regEntity.CIIS_Direct_Serve__c ||!rFR.regEntity.CIIS_Direct_Serve__c) &&
                    rFR.regEntity.Type == 'Compressor Station'
                ) {
                    return true;
                }
            }
            when 'Indirect Transmission' { 
                if(
                    rFR.regEntity.CIIS_Direct_Serve__c != null &&
                    !rFR.regEntity.CIIS_Direct_Serve__c  && 
                    rFR.risk.IETRS_Priority__c == '2' &&
                    (
                        rFR.regEntity.Type == 'Transmission' ||
                        rFR.regEntity.Type == 'Distribution'
                    )
                ) {
                    return true;
                }
            }
            when 'Lease > 1000 mcf/day' {
                if (
                    rFR.regEntity.CIIS_Reg_Entity_MCF_day__c != null &&
                    operator == OP_BETWEEN &&
                    rFR.risk.IETRS_Priority__c == '2' &&
                    (rFR.regEntity.Type == 'Lease' || rFR.regEntity.Type == 'Well')
                ) {
                    return 
                        rFR.regEntity.CIIS_Reg_Entity_MCF_day__c >= value1 && 
                        rFR.regEntity.CIIS_Reg_Entity_MCF_day__c <= value2;
                }
            }
            when 'Lease > 500 mcf/day' {
                if (
                    rFR.regEntity.CIIS_Reg_Entity_MCF_day__c != null &&
                    operator == OP_GREATER_THAN &&
                    rFR.risk.IETRS_Priority__c == '3' &&
                    (
                        rFR.regEntity.Type == 'Lease' 
                    )
                ) {
                    return rFR.regEntity.CIIS_Reg_Entity_MCF_day__c > value1;
                }
            }
            when 'Lease > 250 mcf/day' {
                if (
                    rFR.regEntity.CIIS_Reg_Entity_MCF_day__c != null &&
                    operator == OP_GREATER_THAN &&
                    rFR.risk.IETRS_Priority__c == '3' &&
                    (
                        rFR.regEntity.Type == 'Well' 
                    )
                ) {
                    return rFR.regEntity.CIIS_Reg_Entity_MCF_day__c > value1;
                }
            }
            when 'UIC Commercial' {
                if (
                    rFR.regEntity.CIIS_Commercial_Disposal__c != null &&
                    rFR.regEntity.CIIS_Commercial_Disposal__c &&
                    rFR.risk.IETRS_Priority__c == '2' &&
                    rFR.regEntity.Type == 'UIC Permit'
                ) {
                    return true;
                } else if (
                    rFR.regEntity.CIIS_Commercial_Disposal__c != null &&
                    !rFR.regEntity.CIIS_Commercial_Disposal__c &&
                    rFR.risk.IETRS_Priority__c == '3' &&
                    rFR.regEntity.Type == 'UIC Permit'
                ) {
                    return true;
                }
            }
            when 'Non-Priority' {
                if (
                    (
                        rFR.regEntity.CIIS_Reg_Entity_MCF_day__c == null ||
                        rFR.regEntity.CIIS_Reg_Entity_MCF_day__c <= value1
                    ) &&
                    rFR.risk.IETRS_Priority__c == '3' &&
                    rFR.regEntity.CIIS_Meets_CID__c == true
                ) {
                    //System.debug('Catch all as Non-Priority');
                    return true;
                }
            }
        }
        }
        return false;
    }
    public class RiskFactorRequest{
        public IETRS_InspSchedConfig__c risk;
        public Account regEntity;
    }
}