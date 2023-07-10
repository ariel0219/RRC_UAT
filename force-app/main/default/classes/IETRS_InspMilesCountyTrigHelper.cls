/**
 * @File Name          : IETRS_InspMilesCountyTrigHelper.cls
 * @Description        : Trigger Helper for IETRS_InspMilesCountyTrigger
 * @Author             : Sandhya Belur
 * @Group              :
 * @Last Modified By   : Sandhya Belur
 * @Last Modified On   : 04/23/2020
 * @Modification Log   :
 * Ver      Date            Author           Modification
 * 1.0      04/23/2020      Sandhya Belur       Initial Version
 **/

public class IETRS_InspMilesCountyTrigHelper {
    public static void handleAfterUpdate() {
        updateSummaryValuesOnParentRecords(Trigger.new);
    }

    public static void handleAfterInsert() {
        updateSummaryValuesOnParentRecords(Trigger.new);
    }

    public static void handleAfterDelete() {
        updateSummaryValuesOnParentRecords(Trigger.old);
    }

    public static void handleAfterUndelete() {
        updateSummaryValuesOnParentRecords(Trigger.new);
    }

    /**
     * @description Get the eligible org ids and update the total miles
     */
    private static void updateSummaryValuesOnParentRecords(List<IETRS_Insp_Miles_by_County__c> miles) {
        List<Set<Id>> orgAndEntityIds = getOrgAndEntityIdsForSummaryUpdate(miles);
        // org ids of entities with changed miles
        Set<Id> orgIds = orgAndEntityIds.get(0);
        // entity id with changed counties
        Set<Id> entityIds = orgAndEntityIds.get(1);
        // if there are eligible orgs to update
        /*
        Depricated, as the total miles is now a rollup summary field, and tracked on a junction object.
        if (!orgIds.isEmpty()) {
            IETRS_I_InspectionsService.updateTotalMilesOnOrgs(orgIds);
        }
        */
        // if there are eligible entities to update
        if (!entityIds.isEmpty()) {
            IETRS_I_InspectionsService.updateCountyListOnEntities(entityIds);
        }
    }

    private static List<Set<Id>> getOrgAndEntityIdsForSummaryUpdate(List<IETRS_Insp_Miles_by_County__c> miles) {
        Set<Id> orgIds = new Set<Id>();
        Set<Id> entityIdsWithChangedMiles = new Set<Id>();
        Set<Id> entityIdsWithChangedCounties = new Set<Id>();
        List<Set<Id>> result = new List<Set<Id>>();
        // get the related account ids from the relevant mile records
        for (IETRS_Insp_Miles_by_County__c mile : miles) {
            if (Trigger.isUpdate) {
                // check if miles changed
                IETRS_Insp_Miles_by_County__c oldMile = (IETRS_Insp_Miles_by_County__c) Trigger.oldMap.get(mile.Id);
                if (oldMile.IETRS_Miles__c != mile.IETRS_Miles__c) {
                    entityIdsWithChangedMiles.add(mile.IETRS_Regulated_Entity__c);
                }
                if (oldMile.IETRS_County__c != mile.IETRS_County__c) {
                    entityIdsWithChangedCounties.add(mile.IETRS_Regulated_Entity__c);
                }
            } else {
                entityIdsWithChangedMiles.add(mile.IETRS_Regulated_Entity__c);
                entityIdsWithChangedCounties.add(mile.IETRS_Regulated_Entity__c);
            }
        }

        // get the org ids from the related entities
        for (Account entity : [
            SELECT Id, IETRS_OrganizationofRegEntity__c
            FROM Account
            WHERE Id IN :entityIdsWithChangedMiles
        ]) {
            orgIds.add(entity.IETRS_OrganizationofRegEntity__c);
        }
        result.add(orgIds);
        result.add(entityIdsWithChangedCounties);
        return result;
    }

    /**
     * @description Create Activity record if any record deleted from Inspection Miles By County object.
     * @author Sandhya Belur | 04/23/2020
     * @param mapOldInspMilesCounty A map of Id and InspMilesCounty of records which are going to be deleted.
     * @return void
     **/
    public static void createActivityForDeletedInspMile(map<Id, IETRS_Insp_Miles_by_County__c> mapOldInspMilesCounty) {
        List<Task> lstTask = new List<Task>();
        Set<Id> setCountyIds = new Set<Id>();

        for (IETRS_Insp_Miles_by_County__c objInspMiles : mapOldInspMilesCounty.values()) {
            setCountyIds.add(objInspMiles.IETRS_County__c);
        }

        for (IETRS_Insp_Miles_by_County__c objInspMiles : mapOldInspMilesCounty.values()) {
            Id WhatId = objInspMiles.IETRS_Regulated_Entity__c;
            String note = 'Record Deleted with Name ' + objInspMiles.Name + ' , Miles : ' + objInspMiles.IETRS_Miles__c;
            note = String.isBlank(objInspMiles.IETRS_County_Name__c)
                ? note
                : note + ' County :  ' + objInspMiles.IETRS_County_Name__c;
            Task objTask = IETRS_Utility.createActivityHistoryRecord(WhatId, note);
            objTask.Subject = 'County Deleted';
            objTask.Description = note;
            lstTask.add(objTask);
        }

        if (!lstTask.isEmpty()) {
            insert lstTask;
        }
    }
}