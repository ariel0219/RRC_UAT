public with sharing class IETRS_I_SObjectLookupController {
    /**
     * @description Search records based on sobject lookup inputs
     * @param objectName SObject name
     * @param fields Fields to select
     * @param searchTerm Search term
     * @return List of found records
     * @example
     * List<Object> records =
     *   SObjectLookupController.searchRecords(
     *       'User',
     *       new List<String> {'FirstName', 'LastName'},
     *       'Char'
     *   );
     */
    @AuraEnabled
    public static List<Object> searchRecords(String objectName, String searchTerm) {
        Map<String, List<String>> fieldsByAllowedObject = new Map<String, List<String>>{
            'IETRS_Regulatory_Codes__c' => new List<String>{ 'Id', 'Name', 'IETRS_Violation_Type__c' }
        };
        Map<String, String> whereClauseByAllowedObject = new Map<String, String>{
            'IETRS_Regulatory_Codes__c' => ' AND IETRS_Active__c = TRUE'
        };
        if (!fieldsByAllowedObject.containsKey(objectName))
            return new List<Object>();

        if (searchTerm == null || searchTerm.length() < 2) {
            return new List<Object>(); // require 2 characters to search
        }

        String fields = String.join(fieldsByAllowedObject.get(objectName), ',');

        searchTerm = '%' + searchTerm + '%';
        String whereClause = 'NAME LIKE :searchTerm';
        if (whereClauseByAllowedObject.containsKey(objectName)) {
            whereClause += whereClauseByAllowedObject.get(objectName);
        }

        String limitStr = '5';

        String queryTemplate = 'SELECT {0} FROM {1} WHERE {2} LIMIT {3}';
        String soql = String.format(queryTemplate, new List<String>{ fields, objectName, whereClause, limitStr });

        return Database.query(soql);
    }
}