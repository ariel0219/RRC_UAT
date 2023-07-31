/**
 * @description This class is used to manage supply chain accounts within the supply chain application.
 */
public with sharing class CIIS_SupplyChainAccountsController {
    /**
     * @description Retrieves the columns for the specified supply chain type.
     * @param supplyChainType The type of supply chain.
     * @return A list of CIIS_SupplyChainType.Column objects.
     */
    @AuraEnabled(cacheable=true)
    public static List<CIIS_SupplyChainType.Column> getColumns(
        String supplyChainType
    ) {
        try {
            CIIS_SupplyChainType supplyChain = new CIIS_SupplyChainType(
                supplyChainType
            );
            return supplyChain.getColumns();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Retrieves the input fields for the specified supply chain type.
     * @param supplyChainType The type of supply chain.
     * @return A list of CIIS_SupplyChainType.Column objects.
     */
    @AuraEnabled(cacheable=true)
    public static List<CIIS_SupplyChainType.Column> getInputFields(
        String supplyChainType
    ) {
        try {
            CIIS_SupplyChainType supplyChain = new CIIS_SupplyChainType(
                supplyChainType
            );
            return supplyChain.getInputFields();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Retrieves an Account with default values for the specified supply chain type.
     * @param supplyChainType The type of supply chain.
     * @param operatorId The ID of the operator.
     * @return An Account object with default values.
     */
    @AuraEnabled(cacheable=true)
    public static Account getEntityWithDefaultValues(
        String supplyChainType,
        Id operatorId
    ) {
        Account result;
        try {
            CIIS_SupplyChainType supplyChain = new CIIS_SupplyChainType(
                supplyChainType
            );
            result = supplyChain.getEntityWithDefaultValues(operatorId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    /**
     * @description Retrieves the geolocations associated with the given account IDs for the specified supply chain type.
     * @param supplyChainType The type of supply chain.
     * @param accountIds A list of Account IDs.
     * @return A map with Account IDs as keys and lists of CIIS_Account_Geolocation__c objects as values.
     */
    @AuraEnabled(cacheable=true)
    public static Map<Id, List<CIIS_Account_Geolocation__c>> getAccountGeolocations(
        String supplyChainType,
        List<Id> accountIds
    ) {
        Map<Id, List<CIIS_Account_Geolocation__c>> result = new Map<Id, List<CIIS_Account_Geolocation__c>>();
        try {
            CIIS_SupplyChainType supplyChain = new CIIS_SupplyChainType(
                supplyChainType
            );
            result = supplyChain.getAccountGeolocations(accountIds);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    /**
     * @description Retrieves a list of Account records for the specified supply chain type based on the provided parameters.
     * @param supplyChainType The type of supply chain.
     * @param operatorId The ID of the operator.
     * @param whereClauseSuffix Additional filters to apply to the query.
     * @return A list of Account objects.
     */
    @AuraEnabled
    public static List<Account> getRecords(
        String supplyChainType,
        String operatorId,
        String whereClauseSuffix
    ) {
        List<Account> result = new List<Account>();
        try {
            CIIS_SupplyChainType supplyChain = new CIIS_SupplyChainType(
                supplyChainType
            );
            String soql = supplyChain.getSOQLString(
                operatorId,
                whereClauseSuffix
            );
            result = Database.query(soql);
            system.debug('result ' + soql);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    /**
     * @description Retrieves a single Account record for the specified supply chain type based on the provided record ID.
     * @param supplyChainType The type of supply chain.
     * @param recordId The ID of the Account record.
     * @return An Account object.
     */
    @AuraEnabled(cacheable=true)
    public static Account getRecord(String supplyChainType, String recordId) {
        Account result = new Account();
        try {
            CIIS_SupplyChainType supplyChain = new CIIS_SupplyChainType(
                supplyChainType
            );
            String soql = supplyChain.getSOQLString(
                null,
                'Id = \'' + recordId + '\''
            );
            result = (Account) Database.query(soql)?.get(0);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
    
    /**
     * @description Retrieves Salesforce record ID of County using Oil and Gas County Code.
     * @param OGCode Oil and Gas County Code coming from Segment JSON.
     * @return Salesforce County Record ID.
     */
    @AuraEnabled(cacheable=true)
    public static IETRS_County__c getCounty(
        String OGCode
    ) {
        IETRS_County__c county;
        try {
           county = [SELECT ID, Name FROM IETRS_County__c WHERE IETRS_Oil_Gas_County_Code__c =: OGCode];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return county;
    }
}