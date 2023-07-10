/**
 * Controller class for the Notification Details Download VF page used to download data in CSV format.
 * @author CGI
 */
public with sharing class IETRS_RepairedLeaksCsvController {
    /******************************************
     * Props
     ******************************************/

    /**
     * Field api names in the order they will be rendered in the csv file.
     */
    final public static List<String> CSV_COLUMNS = new List<String>{
        'IETRS_Pipelines_System_ID__c',
        'IETRS_Regulated_Entity_Id__c',
        'IETRS_Leak_Cause__c',
        'IETRS_Repair_Date__c',
        'IETRS_Leak_Repair_Method__c',
        'IETRS_Leak_Location__c',
        'IETRS_Pipe_Size__c',
        'IETRS_Pipe_Type__c',
        'IETRS_Leak_Classification__c'
    };

    /**
     * The notification detail record in scope.
     */
    public IETRS_Insp_Notification__c notificationDetail { get; private set; }

    /******************************************
     * Methods
     ******************************************/

    /**
     * Constructor for the controller class.
     */
    public IETRS_RepairedLeaksCsvController() {
        Id notificationId = ApexPages.currentPage().getParameters().get('id');
        if (notificationId == null) {
            throw new IETRS_RepairedLeaksCsvControllerException(
                'The "id" query string parameter is missing on this page.'
            );
        }
        notificationDetail = [
            SELECT Id, IETRS_P5_Number_Formula__c, IETRS_Report_Period__c
            FROM IETRS_Insp_Notification__c
            WHERE Id = :notificationId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    /**
     * Get the filename for the csv download (p5 number-reportperiod.csv).
     * @return  `String`
     */
    public String getFileName() {
        String result = '';
        if (String.isNotBlank(notificationDetail?.IETRS_P5_Number_Formula__c)) {
            result += notificationDetail.IETRS_P5_Number_Formula__c + ' ';
        }
        if (String.isNotBlank(notificationDetail?.IETRS_Report_Period__c)) {
            result += notificationDetail.IETRS_Report_Period__c;
        }
        result = result.trim().replace(' ', '-');
        return result;
    }

    /**
     * Get csv columns config for the browser to set the correct header labels and column order.
     * @return  `List<Map<String, String>>`
     */
    @RemoteAction
    public static List<Map<String, String>> getCsvColumns() {
        List<Map<String, String>> result = new List<Map<String, String>>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.IETRS_Insp_Notification_Detail__c.fields.getMap();
        for (String fieldName : CSV_COLUMNS) {
            String fieldLabel;
            try {
                fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            } catch (Exception e) {
                // fall back to the api name if there's an issue
                fieldLabel = fieldName;
            }
            result.add(
                new Map<String, String>{
                    'apiName' => fieldName,
                    'label' => fieldLabel
                }
            );
        }
        return result;
    }

    /**
     * Get IETRS_Insp_Notification_Detail__c associated with the provided notification id.
     * @param notificationId Id of IETRS_Insp_Notification__c object.
     * @return  `List<Map<Integer, String>>`
     */
    @ReadOnly
    @RemoteAction
    public static List<Map<Integer, String>> getJsonData(Id notificationId) {
        List<Map<Integer, String>> result = new List<Map<Integer, String>>();
        for (IETRS_Insp_Notification_Detail__c ind : [
            SELECT
                Id,
                IETRS_Pipelines_System_ID__c,
                IETRS_Regulated_Entity_Id__c,
                IETRS_Leak_Cause__c,
                IETRS_Repair_Date__c,
                IETRS_Leak_Repair_Method__c,
                IETRS_Leak_Location__c,
                IETRS_Pipe_Size__c,
                IETRS_Pipe_Type__c,
                IETRS_Leak_Classification__c
            FROM IETRS_Insp_Notification_Detail__c
            WHERE IETRS_Notification__c = :notificationId
            WITH SECURITY_ENFORCED
        ]) {
            result.add(convertToJsonObj(ind));
        }
        return result;
    }

    /**
     * Query and return Accounts as map where account is key.
     * @param accountIds The account ids of the regulated entities to query.
     * @return  `Map<Id, Account>`
     */
    @ReadOnly
    @RemoteAction
    public static Map<Id, Account> getRegEntities(List<Id> accountIds) {
        return new Map<Id, Account>(
            [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
        );
    }

    /**
     * Convert IETRS_Insp_Notification_Detail__c object to a Map, which
     *  the browser will interpret as JSON.
     * @param record The IETRS_Insp_Notification_Detail__c record to convert.
     * @return  `Map<Integer, String>`
     */
    private static Map<Integer, String> convertToJsonObj(
        IETRS_Insp_Notification_Detail__c record
    ) {
        Map<Integer, String> result = new Map<Integer, String>();
        for (Integer i = 0; i < CSV_COLUMNS.size(); i++) {
            String fieldName = CSV_COLUMNS[i];
            result.put(i, ' ');
            if (!record.isSet(fieldName)) {
                continue;
            }
            String fieldValue = String.valueOf(record.get(fieldName));
            if (fieldValue == null) {
                fieldValue = '';
            }
            result.put(i, fieldValue);
        }
        return result;
    }

    /******************************************
     * Inner Classes
     ******************************************/

    /**
     * Exception class for the controller.
     */
    public class IETRS_RepairedLeaksCsvControllerException extends Exception {
    }
}