/**
 * Helper class for generating PS-95 shell records and delinquent email notifications.
 * @author CGI
 */
public with sharing class IETRS_PS95Helper {
    /******************************************
     * Props
     ******************************************/

    /**
     * Distribution entity code.
     */
    public final static String DISTRIBUTION_CODE = 'D-Distribution';

    /**
     * Municipal entity code.
     */
    public final static String MUNICIPAL_CODE = 'M-Municipal Distribution';

    /**
     * Rural Extension entity code.
     */
    public final static String RURAL_CODE = 'R-Rural Extension (Distribution)';

    /**
     * Rural Extension entity code.
     */
    public final static String LPG_CODE = 'I-LPG Distribution';

    /**
     * Active status value.
     */
    public final static String ACTIVE_STATUS = 'Active';

    /**
     * Record type id for archived accounts.
     */
    public static Id archivedRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('IETRS_Archived_Account')
        .getRecordTypeId();

    /**
     * Jurisdictional option value.
     */
    final static String JURISDICTIONAL_OPTION = 'Jurisdictional';

    /******************************************
     * Methods
     ******************************************/

    /**
     * Determine the number of active entities per org using the provided PS-95 Notification record.
     * @param notifications PS-95 Notification records.
     * @return  `Map<Id, Integer>`
     */
    public static Map<Id, Integer> getActiveEntityCountyByOrgId(
        List<IETRS_Insp_Notification__c> notifications
    ) {
        Set<Id> orgIds = getOrgIdsFromObjects(
            notifications,
            Schema.IETRS_Insp_Notification__c.IETRS_PS95_Organization__c
        );
        return getActiveEntityCountyByOrgId(orgIds);
    }

    /**
     * Determine the number of active entities per org using the provided Unit Accounts.
     * @param unitAccounts Unit Accounts associated with an Organization.
     * @return  `Map<Id, Integer>`
     */
    public static Map<Id, Integer> getActiveEntityCountyByOrgId(
        List<Account> unitAccounts
    ) {
        Set<Id> orgIds = getOrgIdsFromObjects(
            unitAccounts,
            Schema.Account.ParentId
        );
        return getActiveEntityCountyByOrgId(orgIds);
    }

    /**
     * Determine the number of active regulated entities associated with each provided org id.
     * @param orgIds Collection of Organization Account ids.
     * @return  `Map<Id, Integer>`
     */
    public static Map<Id, Integer> getActiveEntityCountyByOrgId(
        Set<Id> orgIds
    ) {
        Map<Id, Integer> result = new Map<Id, Integer>();

        // exit early if empty
        if (orgIds.isEmpty()) {
            return result;
        }

        // find count of active REs associated with the orgs
        for (AggregateResult groupedResult : [
            SELECT COUNT(Id) cnt, IETRS_OrganizationofRegEntity__c
            FROM Account
            WHERE
                IETRS_Status__c = :ACTIVE_STATUS
                AND IETRS_Jurisdiction__c = :JURISDICTIONAL_OPTION
                AND IETRS_OrganizationofRegEntity__c IN :orgIds
                AND IETRS_Entity_Code__c IN (
                    :DISTRIBUTION_CODE,
                    :MUNICIPAL_CODE,
                    :RURAL_CODE,
                    :LPG_CODE
                )
                AND RecordTypeId != :archivedRecTypeId
            GROUP BY IETRS_OrganizationofRegEntity__c
        ]) {
            result.put(
                (Id) groupedResult.get('IETRS_OrganizationofRegEntity__c'),
                (Integer) groupedResult.get('cnt')
            );
        }

        return result;
    }

    /**
     * Helper method to get all fields from an object and build a query string. Essentially creates a SELECT * statement.
     * @param objectName - String - Name of the object whose fields the calling method wants.
     * @return  `String`
     */
    public static String getQueryString(String objectName) {
        Map<String, Schema.SObjectType> objMap = new Map<String, Schema.SObjectType>();
        objMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = objMap.get(objectName)
            .getDescribe()
            .fields.getMap();
        string queryString = 'SELECT ';
        for (Schema.SObjectField field : fieldMap.values()) {
            queryString = queryString + field.getDescribe().getName() + ', ';
        }
        queryString = queryString.substring(0, queryString.length() - 2);
        return queryString;
    }

    /**
     * Get the formatted report period value given the provided date.
     * @param dt Date used to determine the report period.
     * @return  `String`
     */
    public static String getReportPeriod(Date dt) {
        String result = '';
        Integer year = dt.Year();
        if (dt.month() <= 6) {
            result = String.valueOf(year) + ' ' + 'Jan-Jun';
        } else {
            result = String.valueOf(year) + ' ' + 'Jul-Dec';
        }
        return result;
    }

    /**
     * Return a unique collection of Organization Account ids given the provided sobjects and field.
     * @param sobjects Collection of salesforce objects.
     * @param field Schema.sObjectField that represents an Account reference to an Organization.
     * @return  `Set<Id>`
     */
    private static Set<Id> getOrgIdsFromObjects(
        List<SObject> sobjects,
        Schema.sObjectField field
    ) {
        Set<Id> result = new Set<Id>();
        for (SObject record : sobjects) {
            Id orgId = (Id) record.get(field);
            if (orgId != null) {
                result.add(orgId);
            }
        }
        return result;
    }
}