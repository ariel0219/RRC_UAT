/**
 * @File Name          : IETRS_InspectionPkgTrigHelper.cls
 * @Description        : Trigger Helper for IETRS_InspectionPkgTrigger
 * @Author             : Sandhya Belur
 * @Group              :
 * @Last Modified By   : Sandhya Belur
 * @Last Modified On   : 04/23/2020
 * @Modification Log   :
 * Ver      Date            Author          	Modification
 * 1.0      04/23/2020      Sandhya Belur       Initial Version
 **/
public class IETRS_InspectionPkgTrigHelper {
    /**
     * @description Handle the before insert trigger
     */
    public static void handleBeforeInsert() {
        setDefaultValues();
    }

    /**
     * @description Handle the after insert trigger
     */
    public static void handleAfterInsert() {
        updateInspectorList(Trigger.new);
    }

    /**
     * @description Handle the after insert trigger
     */
    public static void handleAfterUpdate() {
        updateInspectorList(Trigger.new);
    }

    /**
     * @description Create Activity record if any record deleted from Inspection Package object.
     * @author Sandhya Belur | 04/23/2020
     * @param mapOldInspPkg A map of Id and Inspection Package records which are going to be deleted.
     * @return void
     **/
    public static void createActivityForDeletedInspPkg(map<Id, IETRS_Inspection_Package__c> mapOldInspPkg) {
        List<Task> lstTask = new List<Task>();

        for (IETRS_Inspection_Package__c objInspPkg : mapOldInspPkg.values()) {
            Id WhatId = objInspPkg.IETRS_Organization__c;
            String note =
                'Inspection package Deleted with Name ' +
                objInspPkg.Name +
                ' , Business Area : ' +
                objInspPkg.IETRS_Business_Area__c +
                ' , Inspection Type : ' +
                objInspPkg.IETRS_Inspection_Type__c +
                ' and Inspection Sub-Type : ' +
                objInspPkg.IETRS_Inspection_Sub_Type__c;
            Task objTask = IETRS_Utility.createActivityHistoryRecord(WhatId, note);
            objTask.Subject = 'Inspection Package Deleted';
            objTask.Description = note;
            lstTask.add(objTask);
        }

        if (!lstTask.isEmpty()) {
            insert lstTask;
        }
    }

    /**
     * @description Update the inspector list field on the IPs in scope
     */
    private static void updateInspectorList(List<IETRS_Inspection_Package__c> inspectionPackages) {
        Set<Id> inspectionPackageIds = new Set<Id>();

        for (IETRS_Inspection_Package__c ip : inspectionPackages) {
            if (Trigger.isUpdate) {
                // include if lead inspector or region lead has changed
                IETRS_Inspection_Package__c oldIP = (IETRS_Inspection_Package__c) Trigger.oldMap.get(ip.Id);
                if (
                    ip.IETRS_Lead_Inspector__c != oldIp.IETRS_Lead_Inspector__c || // lead inspector changed
                    ip.IETRS_Region_Lead__c != oldIp.IETRS_Region_Lead__c // region lead changed
                ) {
                    inspectionPackageIds.add(ip.Id);
                }
            } else if (Trigger.isInsert) {
                // include if the new record has a lead inspector or region lead
                if (ip.IETRS_Lead_Inspector__c != null || ip.IETRS_Region_Lead__c != null) {
                    inspectionPackageIds.add(ip.Id);
                }
            }
        }

        if (!inspectionPackageIds.isEmpty()) {
            IETRS_I_InspectionsService.updateInspectorListOnInspectionPackages(inspectionPackageIds);
        }
    }

    /**
     * @description Set default values on the inspection package records
     */
    private static void setDefaultValues() {
        Map<Schema.SObjectField, Schema.SObjectField> ipFieldsByScheduleField = new Map<Schema.SObjectField, Schema.SObjectField>{
            IETRS_InspSchedule__c.IETRS_Assigned_Inspector__c => IETRS_Inspection_Package__c.IETRS_Lead_Inspector__c
        };

        Map<Id, List<IETRS_Inspection_Package__c>> ipsByScheduleId = new Map<Id, List<IETRS_Inspection_Package__c>>();
        // Determine if the new ip has a related schedule
        for (IETRS_Inspection_Package__c ip : (List<IETRS_Inspection_Package__c>) Trigger.new) {
            if (ip.IETRS_Created_from_Inspection_Schedule__c != null) {
                if (!ipsByScheduleId.containsKey(ip.IETRS_Created_from_Inspection_Schedule__c)) {
                    ipsByScheduleId.put(
                        ip.IETRS_Created_from_Inspection_Schedule__c,
                        new List<IETRS_Inspection_Package__c>()
                    );
                }
                ipsByScheduleId.get(ip.IETRS_Created_from_Inspection_Schedule__c).add(ip);
            }
        }

        // exit early if there are no related schedules
        if (ipsByScheduleId.isEmpty()) {
            return;
        }

        // Query inspection schedules associated with the ips and populate default values
        Set<Id> scheduleIds = ipsByScheduleId.keySet();
        String scheduleQuery =
            'SELECT ' +
            ipFieldsByScheduleField.keySet().toString().removeStart('{').removeEnd('}') +
            ' FROM IETRS_InspSchedule__c WHERE Id IN :scheduleIds';
        for (IETRS_InspSchedule__c schedule : Database.query(scheduleQuery)) {
            for (IETRS_Inspection_Package__c ip : ipsByScheduleId.get(schedule.Id)) {
                copyValuesToSObject(schedule, ip, ipFieldsByScheduleField);
            }
        }
    }

    /**
     * @description Copy values from a source sobject to target sobject using a field map
     */
    private static void copyValuesToSObject(
        SObject source,
        SObject target,
        Map<Schema.SObjectField, Schema.SObjectField> fieldMap
    ) {
        for (Schema.SObjectField sourceField : fieldMap.keySet()) {
            Schema.SObjectField targetField = fieldMap.get(sourceField);
            Object val = source.get(sourceField);
            if (val != null) {
                target.put(targetField, val);
            }
        }
    }
}