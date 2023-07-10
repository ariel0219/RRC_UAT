/**
 * @author Greg Lovelidge - Sense Corp
 * @date 6/1/2020
 *
 * @description Trigger handler class for the Inspection object.
 */
public with sharing class IETRS_I_Inspection_TriggerHandler {
    /*
     * @description Handle before insert.
     */
    public static void handleBeforeInsert() {
        validateInspection();
    }

    /*
     * @description Handle after delete.
     */
    public static void handleAfterDelete() {
        deleteInspectionGroup();
    }
    /*
     * @description: Only let Regional Dir, Assitant Dir, Dir to delete an Inspection when IP is in Initial Status
     */
    public static void handleBeforeDelete(List<IETRS_Inspection__c> lstInspections){
        List<Id> ipId = new List<Id>();
        for(IETRS_Inspection__c insp: lstInspections){
            ipId.add(insp.IETRS_Inspection_Package__c);
        }
        
        Map<Id, IETRS_Inspection_Package__c> mapIP = new Map<Id, IETRS_Inspection_Package__c>([SELECT Id, IETRS_Status__c FROM IETRS_Inspection_Package__c WHERE ID IN: ipId]);
        
        String roleName = [SELECT Name FROM userRole WHERE Id =: userInfo.getUserRoleId()]?.Name;
            for(IETRS_Inspection__c insp: lstInspections){
                if(roleName.contains('CIIS') && roleName.contains('Director')){
                    if(mapIP.get(insp.IETRS_Inspection_Package__c).IETRS_Status__c != 'Initial')
                        insp.addError('You can only delete an Inspection when Inspection Package is in Initial status.');
                }
                else{
                    insp.addError('You have insufficient access to delete an Inspection.');
                }
            }
    }

    /*
     * @description Ensure that new inspection records are valid before saving. This
     *   method ensures an entity only has only inspection related to a standard, comprehensive
     *   inspection package.
     */
    private static void validateInspection() {
        final List<String> closedStatuses = new List<String>{ 'Closed', 'Complete' };
        final String standardType = 'Standard';
        final String comprehensiveType = 'Comprehensive';
		final Id ciisRecordTypeId = Schema.SObjectType.IETRS_Inspection_Package__c.getRecordTypeInfosByName().get('Inspection Package - Critical Infrastructure').getRecordTypeId();
        Map<Id, List<IETRS_Inspection__c>> inspectionsByInspectionPackageId = new Map<Id, List<IETRS_Inspection__c>>();
        // Get package ids from records in scope
        for (IETRS_Inspection__c inspection : (List<IETRS_Inspection__c>) Trigger.new) {
            if (
                inspection.IETRS_Inspection_Package__c != null // has a related inspection package
            ) {
                if (!inspectionsByInspectionPackageId.containsKey(inspection.IETRS_Inspection_Package__c)) {
                    inspectionsByInspectionPackageId.put(
                        inspection.IETRS_Inspection_Package__c,
                        new List<IETRS_Inspection__c>()
                    );
                }
                inspectionsByInspectionPackageId.get(inspection.IETRS_Inspection_Package__c).add(inspection);
            }
        }

        // Construct a map of open inspections by entity id
        Map<Id, List<IETRS_Inspection__c>> openInspectionsByEntityId = new Map<Id, List<IETRS_Inspection__c>>();
        for (IETRS_Inspection_Package__c inspectionPackage : [
            SELECT Id
            FROM IETRS_Inspection_Package__c
            WHERE
                Id IN :inspectionsByInspectionPackageId.keySet()
                AND IETRS_Inspection_Type__c = :standardType
                AND IETRS_Inspection_Sub_Type__c = :comprehensiveType
                AND IETRS_Status__c NOT IN :closedStatuses
            	AND recordTypeId !=: ciisRecordTypeId
        ]) {
            for (IETRS_Inspection__c inspection : inspectionsByInspectionPackageId.get(inspectionPackage.Id)) {
                if (!openInspectionsByEntityId.containsKey(inspection.IETRS_Regulated_Entity__c)) {
                    openInspectionsByEntityId.put(
                        inspection.IETRS_Regulated_Entity__c,
                        new List<IETRS_Inspection__c>()
                    );
                }
                openInspectionsByEntityId.get(inspection.IETRS_Regulated_Entity__c).add(inspection);
            }
        }

        // Exit early if there are no open inspection packages
        if (openInspectionsByEntityId.isEmpty()) {
            return;
        }

        // Query other open inspections related to the entities in scope
        for (IETRS_Inspection__c inspection : [
            SELECT Id, IETRS_Regulated_Entity__c
            FROM IETRS_Inspection__c
            WHERE
                IETRS_Inspection_Package__r.IETRS_Status__c NOT IN :closedStatuses
                AND IETRS_Regulated_Entity__c IN :openInspectionsByEntityId.keySet()
                AND IETRS_Inspection_Package__r.IETRS_Inspection_Type__c = :standardType
                AND IETRS_Inspection_Package__r.IETRS_Inspection_Sub_Type__c = :comprehensiveType
            	AND IETRS_Inspection_Package__r.recordTypeId !=: ciisRecordTypeId
        ]) {
            if (inspection.IETRS_Regulated_Entity__c != null) {
                if (!openInspectionsByEntityId.containsKey(inspection.IETRS_Regulated_Entity__c)) {
                    openInspectionsByEntityId.put(
                        inspection.IETRS_Regulated_Entity__c,
                        new List<IETRS_Inspection__c>()
                    );
                }
                openInspectionsByEntityId.get(inspection.IETRS_Regulated_Entity__c).add(inspection);
            }
        }

        // Throw error on inspections where the entity has other open inspections
        if (!openInspectionsByEntityId.isEmpty()) {
            for (IETRS_Inspection__c inspection : (List<IETRS_Inspection__c>) Trigger.new) {
                if (
                    inspection.IETRS_Regulated_Entity__c != null && // has a related entity
                    openInspectionsByEntityId.containsKey(inspection.IETRS_Regulated_Entity__c) && // map contains the entity id
                    openInspectionsByEntityId.get(inspection.IETRS_Regulated_Entity__c).size() > 1 // has more than 1 open inspection, including records in scope
                ) {
                    inspection.addError(
                        'This regulated entity cannot be added to this package because it is associated with an on-going comprehensive inspection.  The other package must be closed first. '
                    );
                }
            }
        }
    }
    /**
     * @Description Delete the Inspection Gruop if no Inspection records exist. Unlink Inspection Pkg from
     *   Insp Schedule if Inspection is deleted.
     * @Author Srilu Mamillapalli
     */
    private static void deleteInspectionGroup() {
        Map<Id, List<IETRS_Inspection__c>> IncGropAIncList = new Map<Id, List<IETRS_Inspection__c>>();
        Set<Id> IncGroupIds = new Set<Id>();
        List<IETRS_Insp_Inspection_Group__c> InspecGroupList = new List<IETRS_Insp_Inspection_Group__c>();
        List<IETRS_Inspection__c> ConList = new List<IETRS_Inspection__c>();
        List<IETRS_Insp_Inspection_Group__c> UpdateInspecGroupList = new List<IETRS_Insp_Inspection_Group__c>();
        List<IETRS_Insp_Inspection_Group__c> deleteInspecGroupList = new List<IETRS_Insp_Inspection_Group__c>();
        Set<Id> setInspPackIds = new Set<Id>();
        List<Task> lstTask = new List<Task>();

        if (Trigger.isDelete) {
            system.debug('trigger.Old' + Trigger.Old);
            for (IETRS_Inspection__c Con : (List<IETRS_Inspection__c>) Trigger.Old) {
                IncGroupIds.add(Con.IETRS_Inspection_Group__c);
                //IncGroupIds.add(con.Id);
                if (!IncGropAIncList.containsKey(Con.IETRS_Inspection_Group__c)) {
                    IncGropAIncList.put(Con.IETRS_Inspection_Group__c, new List<IETRS_Inspection__c>());
                }
                IncGropAIncList.get(Con.IETRS_Inspection_Group__c).add(Con);

                if (string.isNotBlank(Con.IETRS_Inspection_Package__c)) {
                    setInspPackIds.add(Con.IETRS_Inspection_Package__c);
                }
                // code for Event History
                Id WhatId = Con.IETRS_Inspection_Package__c;
                String note =
                    'Inspection Deleted with Name ' +
                    Con.Name +
                    ' , Status : ' +
                    Con.IETRS_Inspection_Status__c +
                    ' , Entity Name at Eval : ' +
                    Con.IETRS_EntityNameAtEval__c;
                Task objDelTask = IETRS_Utility.createActivityHistoryRecord(WhatId, note);
                objDelTask.Subject = 'Inspection Deleted';
                lstTask.add(objDelTask);
            }
        }

        if (IncGroupIds.size() > 0) {
            system.debug('IncGropAIncList' + IncGropAIncList);
            InspecGroupList = [
                SELECT id, IETRS_Number_Inspections__c, (SELECT id FROM Inspections__r), Name
                FROM IETRS_Insp_Inspection_Group__c
                WHERE Id IN :IncGroupIds
            ];
            system.debug('InspecGroupList' + InspecGroupList);
            for (IETRS_Insp_Inspection_Group__c incegroup : InspecGroupList) {
                system.debug('size' + IncGropAIncList.get(incegroup.Id));
                List<IETRS_Inspection__c> IncpList = new List<IETRS_Inspection__c>();
                // IncpList = IncGropAIncList.get(incegroup.Id);
                IncpList = incegroup.Inspections__r;
                system.debug('IncpList' + IncpList.size());
                incegroup.IETRS_Number_Inspections__c = IncpList.size();
                if (incegroup.IETRS_Number_Inspections__c == 0) {
                    deleteInspecGroupList.add(incegroup);
                } else {
                    UpdateInspecGroupList.add(incegroup);
                }
            }
            if (UpdateInspecGroupList.size() > 0) {
                system.debug('inside update');
                // update InspecGroupList;
                update UpdateInspecGroupList;
            }

            if (deleteInspecGroupList.size() > 0) {
                system.debug('inside delete');

                // update InspecGroupList;
                delete deleteInspecGroupList;
            }
            //    deleteInspecGroupList
        }
        if (!setInspPackIds.isEmpty()) {
            List<IETRS_InspSchedule__c> lstInspScheduleToUnlink = new List<IETRS_InspSchedule__c>();
            for (IETRS_InspSchedule__c objInspSchedule : [
                SELECT Id, IETRS_Inspection_Package__c
                FROM IETRS_InspSchedule__c
                WHERE IETRS_Inspection_Package__c IN :setInspPackIds
            ]) {
                objInspSchedule.IETRS_Inspection_Package__c = null;
                lstInspScheduleToUnlink.add(objInspSchedule);
            }

            if (!lstInspScheduleToUnlink.isEmpty()) {
                update lstInspScheduleToUnlink;
            }
        }

        if (!lstTask.isEmpty()) {
            insert lstTask;
        }
    }
}