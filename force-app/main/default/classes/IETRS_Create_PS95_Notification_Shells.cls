public class IETRS_Create_PS95_Notification_Shells implements System.Schedulable, DataBase.Batchable<Sobject>, Database.Stateful {
    public Set<Id> parId = new Set<Id>();
    public Map<Id, IETRS_Insp_Notification__c> mapOfNotifications = new Map<Id, IETRS_Insp_Notification__c>();

    public Boolean lastPeriod = false;

    public void execute(SchedulableContext sctxt) {
        IETRS_Create_PS95_Notification_Shells instance = new IETRS_Create_PS95_Notification_Shells();
        instance.lastPeriod = lastPeriod;
        DataBase.executeBatch(instance, 200);
    }

    public DataBase.QueryLocator start(DataBase.BatchableContext batch) {
        String query =
            'SELECT Id, ParentId ' +
            'FROM Account ' +
            'WHERE Type =\'Distribution\' AND RecordType.Name= \'Unit\' AND ParentId!=null AND Parent.RecordType.Name != \'Archived Account\'';
        return dataBase.getQueryLocator(query);
    }

    public void execute(
        DataBase.BatchableContext batch,
        List<Account> listOfAccountRecords
    ) {
        Integer monthOffset = lastPeriod ? -6 : 6;
        String reportPeriod = IETRS_PS95Helper.getReportPeriod(
            System.today().addMonths(monthOffset)
        );
        Id devRecordTypeId = Schema.SObjectType.IETRS_Insp_Notification__c.getRecordTypeInfosByName()
            .get('PS-95')
            .getRecordTypeId();

        // get all orgs that already have a notification for this report period
        Set<Id> orgIds = new Set<Id>();
        for (Account acc : listOfAccountRecords) {
            orgIds.add(acc.ParentId);
        }

        for (IETRS_Insp_Notification__c notification : [
            SELECT IETRS_PS95_Organization__c
            FROM IETRS_Insp_Notification__c
            WHERE
                IETRS_Report_Period__c = :reportPeriod
                AND IETRS_PS95_Organization__c IN :orgIds
        ]) {
            parId.add(notification.IETRS_PS95_Organization__c);
        }

        if (listOfAccountRecords.size() > 0) {
            Map<Id, Integer> activeEntityCountByOrgId = IETRS_PS95Helper.getActiveEntityCountyByOrgId(
                listOfAccountRecords
            );
            for (Account accountInstance : listOfAccountRecords) {
                Integer activeEntities = activeEntityCountByOrgId.get(
                    accountInstance.ParentId
                );
                // skip if we already set up a notification for this org
                if (parId.contains(accountInstance.ParentId)) {
                    continue;
                }
                // skip if this org has no active distribution entities
                if (activeEntities == null || activeEntities == 0) {
                    continue;
                }
                IETRS_Insp_Notification__c notificationInstance = new IETRS_Insp_Notification__c();
                notificationInstance.IETRS_Report_Period__c = reportPeriod;
                notificationInstance.IETRS_PS95_Organization__c = accountInstance.ParentId;
                notificationInstance.RecordTypeId = devRecordTypeId;
                notificationInstance.IETRS_Submitted__c = 'No';
                mapOfNotifications.put(
                    accountInstance.ParentId,
                    notificationInstance
                );
                parId.add(accountInstance.ParentId);
            }
        }
    }

    public void finish(DataBase.BatchableContext batch) {
        System.debug('mapOfNotifications' + mapOfNotifications);
        if (!mapOfNotifications.isEmpty()) {
            insert mapOfNotifications.values();
        }
        System.debug('mapOfNotificationsafterInsret' + mapOfNotifications);
    }
}