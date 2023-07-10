/**
 * @author Greg Lovelidge
 * @date 7/22/2020
 *
 * @description Trigger handler for the Inspection Counties at Eval Trigger
 */
public with sharing class IETRS_InspCountiesAtEvalTriggerHandler {
    /*******************************************************************************************************
     * Class Methods
     */
    public static void handleAfterUpdate() {
        updateCountyListOnInspections(Trigger.new);
    }

    public static void handleAfterInsert() {
        updateCountyListOnInspections(Trigger.new);
    }

    public static void handleAfterDelete() {
        updateCountyListOnInspections(Trigger.old);
    }

    public static void handleAfterUndelete() {
        updateCountyListOnInspections(Trigger.new);
    }

    /**
     * @description Get the eligible inspections and update the county list field
     * @param The records in scope
     */
    private static void updateCountyListOnInspections(List<IETRS_Insp_Inspection_Counties_at_Eval__c> records) {
        Set<Id> inspectionIds = new Set<Id>();
        for (IETRS_Insp_Inspection_Counties_at_Eval__c record : records) {
            if (Trigger.isUpdate) {
                // if updated, check if county has changed
                IETRS_Insp_Inspection_Counties_at_Eval__c oldRecord = (IETRS_Insp_Inspection_Counties_at_Eval__c) Trigger.oldMap
                    .get(record.Id);
                if (record.IETRS_County__c != oldRecord.IETRS_County__c) {
                    inspectionIds.add(record.IETRS_Inspection__c);
                }
            } else {
                // delete, inserted or undeleted
                if (record.IETRS_County__c != null) {
                    inspectionIds.add(record.IETRS_Inspection__c);
                }
            }
        }

        if (inspectionIds.isEmpty()) {
            return;
        }

        IETRS_I_InspectionsService.updateCountyListOnInspections(inspectionIds);
    }
}