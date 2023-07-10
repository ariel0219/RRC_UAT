/**
 * @author Greg Lovelidge
 * @date 7/22/2020
 *
 * @description Trigger handler for the Inspection Package Inspector Trigger
 */
public with sharing class IETRS_IPInspectorTriggerHandler {
    /*******************************************************************************************************
     * Class Methods
     */
    public static void handleAfterUpdate() {
        updateInspectorListOnInspectionPackages(Trigger.new);
    }

    public static void handleAfterInsert() {
        updateInspectorListOnInspectionPackages(Trigger.new);
    }

    public static void handleAfterDelete() {
        updateInspectorListOnInspectionPackages(Trigger.old);
    }

    public static void handleAfterUndelete() {
        updateInspectorListOnInspectionPackages(Trigger.new);
    }

    private static void updateInspectorListOnInspectionPackages(
        List<IETRS_Insp_Inspection_Package_Inspector__c> inspectors
    ) {
        // get the relevant IP ids from the records in scope
        Set<Id> inspectionPackageIds = new Set<Id>();
        for (IETRS_Insp_Inspection_Package_Inspector__c inspector : inspectors) {
            if (Trigger.isUpdate) {
                // if updated, check if inspector has changed
                IETRS_Insp_Inspection_Package_Inspector__c oldInspector = (IETRS_Insp_Inspection_Package_Inspector__c) Trigger.oldMap
                    .get(inspector.Id);
                if (inspector.IETRS_Inspector__c != oldInspector.IETRS_Inspector__c) {
                    inspectionPackageIds.add(inspector.IETRS_Inspection_Package__c);
                }
            } else {
                // delete, inserted or undeleted
                if (inspector.IETRS_Inspector__c != null) {
                    inspectionPackageIds.add(inspector.IETRS_Inspection_Package__c);
                }
            }
        }

        if (inspectionPackageIds.isEmpty()) {
            return;
        }

        IETRS_I_InspectionsService.updateInspectorListOnInspectionPackages(inspectionPackageIds);
    }
}