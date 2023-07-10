/**
 * @author Greg Lovelidge
 * @date 7/16/2020
 *
 * @description Violation object trigger handler
 */
public with sharing class IETRS_ViolationTriggerHandler {
    /*******************************************************************************************************
     * Class Methods
     */

    /**
     * @description Handle violation before insert event
     */
    public static void handleBeforeInsert() {
        setViolationNumber(Trigger.new);
    }

    /**
     * @description Handle violation before delete event
     */
    public static void handleBeforeDelete() {
        /* FC NOTE: COMMENTING OUT PER AZURE BUG 15920
        validateDelete(Trigger.old);
		FC NOTE: END COMMENT*/
    }

    /**
     * @description Handle violation after delete event
     */
    public static void handleAfterDelete() {
        reorderViolationNumbers(Trigger.old);
        createActivityHistory();
    }

    /**
     * @description Handle violation after undelete event
     */
    public static void handleAfterUndelete() {
        reorderViolationNumbers(Trigger.new);
    }

    private static void createActivityHistory() {
        set<Id> listInspectionIds = new Set<Id>();
        List<Task> lstTask = new List<Task>();

        for (IETRS_Violation__c childItem : (List<IETRS_Violation__c>) Trigger.old) {
            if (childItem.IETRS_Inspection__c != null) {
                listInspectionIds.add(childItem.IETRS_Inspection__c);
                system.debug('Inspection to Reorder ' + childItem.IETRS_Inspection__c + '\n');

                Id WhatId = childItem.IETRS_Inspection__c;
                String note =
                    'Violation record deleted with Name ' +
                    childItem.Name +
                    ' , State : ' +
                    childItem.IETRS_State__c +
                    ' , Status : ' +
                    childItem.IETRS_Status__c +
                    ' , Violation Number : ' +
                    childItem.IETRS_Violation_Num__c;
                Task objTask = IETRS_Utility.createActivityHistoryRecord(WhatId, note);
                objTask.Description = note;
                objTask.Subject = 'Violation Deleted';
                lstTask.add(objTask);
            }

            if (childItem.IETRS_Inspection_Package__c != null) {
                // code for Event History
                Id WhatId = childItem.IETRS_Inspection_Package__c;
                String note =
                    'Violation record Deleted with Name ' +
                    childItem.Name +
                    ' , State : ' +
                    childItem.IETRS_State__c +
                    ' , Status : ' +
                    childItem.IETRS_Status__c +
                    ' , Violation Number : ' +
                    childItem.IETRS_Violation_Num__c;
                Task objTask = IETRS_Utility.createActivityHistoryRecord(WhatId, note);
                objTask.Description = note;
                objTask.Subject = 'Violation Deleted';
                lstTask.add(objTask);
            }
        }

        if (!lstTask.isEmpty()) {
            insert lstTask;
        }
    }

    /**
     * @description Set violation number on new violation records
     * @param violations list of new violations to set the violation number on
     */
    private static void setViolationNumber(List<IETRS_Violation__c> violations) {
        Map<Id, Integer> violationCountByInspectionId = new Map<Id, Integer>();
        Map<Id, List<ViolationWrapper>> violationsByInspectionId = getViolationsByInspectionIdMap(violations);
        // get the current count of violations for each inspection
        for (AggregateResult ag : [
            SELECT COUNT(Id) violationCount, IETRS_Inspection__c
            FROM IETRS_Violation__c
            WHERE IETRS_Inspection__c IN :violationsByInspectionId.keySet()
            GROUP BY IETRS_Inspection__c
        ]) {
            Id inspectionId = (Id) ag.get('IETRS_Inspection__c');
            Integer violationCount = (Integer) ag.get('violationCount');
            violationCountByInspectionId.put(inspectionId, violationCount);
        }

        // sort and set new violation number on new violations
        for (Id inspectionId : violationsByInspectionId.keySet()) {
            List<ViolationWrapper> sortedViolations = violationsByInspectionId.get(inspectionId);
            Integer violationCount = 0;
            sortedViolations.sort();
            if (violationCountByInspectionId.containsKey(inspectionId)) {
                violationCount = violationCountByInspectionId.get(inspectionId);
            }
            for (ViolationWrapper vw : sortedViolations) {
                ++violationCount;
                vw.violation.IETRS_Violation_Num__c = violationCount;
            }
        }
    }

    /**
     * @description Logic to prevent violation records that should not be deleted
     * @param violations List of violation records
     */
    /*FC NOTE: COMMENTING OUT PER AZURE BUG 15920
    private static void validateDelete(List<IETRS_Violation__c> violations) {
        // ensure the related inspection package doesn't have F&C records with a sent date
        final String letterSentErrorMsg = 'This violation record cannot be deleted because letter correspondence has already been sent.';
        Map<Id, List<IETRS_Violation__c>> violationsByIPId = new Map<Id, List<IETRS_Violation__c>>();
        for (IETRS_Violation__c violation : violations) {
            if (!violationsByIPId.containsKey(violation.IETRS_Inspection_Package__c)) {
                violationsByIPId.put(violation.IETRS_Inspection_Package__c, new List<IETRS_Violation__c>());
            }
            violationsByIPId.get(violation.IETRS_Inspection_Package__c).add(violation);
        }
        // Find related F&C records with sent dates
        List<IETRS_Violation__c> invalidViolations = new List<IETRS_Violation__c>();
        for (IETRS_Files_Correspondence__c fc : [
            SELECT Id, IETRS_Sent_Date_Time__c, IETRS_Inspection_Package__c
            FROM IETRS_Files_Correspondence__c
            WHERE IETRS_Inspection_Package__c IN :violationsByIPId.keySet() AND IETRS_Sent_Date_Time__c != null
        ]) {
            if(fc?.IETRS_Inspection_Package__c != null){
                invalidViolations.addAll(violationsByIPId.remove(fc.IETRS_Inspection_Package__c));
            }
        }

        // throw an error if any invalid violations
        if (!invalidViolations.isEmpty()) {
            for (IETRS_Violation__c violation : invalidViolations) {
                violation.addError(letterSentErrorMsg);
            }
        }

    }
FC NOTE: END COMMENT
*/

    public static void stopNonWorkInProgressIPDeletes(Map<Id,IETRS_Violation__c> mapViolations){
        String strProfileName;
        boolean blnDeleteBlocked = false;
        //Block violation deletion if related Inspection package is not in Work In Progress
        strProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;

        if (strProfileName == 'IETRS Inspections - Inspector' || strProfileName == 'IETRS Inspections - Inspection Manager'){
            List<IETRS_Violation__c> lstTriggerViolations = [SELECT Id, IETRS_Inspection_Package__c, IETRS_Inspection_Package__r.IETRS_Status__c, IETRS_Inspection__c FROM IETRS_Violation__c WHERE ID IN :mapViolations.keySet()];

            for(Integer i=0; i<lstTriggerViolations.size(); i++){
                blnDeleteBlocked = false;
                if(lstTriggerViolations[i]?.IETRS_Inspection_Package__c != null){
                    if(lstTriggerViolations[i].IETRS_Inspection_Package__r.IETRS_Status__c != 'Work in Progress' &&
                      lstTriggerViolations[i].IETRS_Inspection_Package__r.IETRS_Status__c != 'WIP/Rejected'){
                        mapViolations.get(lstTriggerViolations[i].Id).addError('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.');
                        blnDeleteBlocked = true;
                    }
                }
            }
        }
    }

    public static void triggerViolationCountRecalculations(List<IETRS_Violation__c> lstViolations){
        for(Integer i=0; i<lstViolations.size(); i++){
            Map<String,String> mapInputs = new Map<String,String>();
            if(lstViolations[i]?.IETRS_Inspection__c != null){
                mapInputs.put('varInspectionId', lstViolations[i]?.IETRS_Inspection__c);
                mapInputs.put('varInspectionPackageID', lstViolations[i]?.IETRS_Inspection_Package__c);
                Flow.Interview flowViolationCalc = new Flow.Interview.IETRS_I_Violation_Counter(mapInputs);     
                flowViolationCalc.start();
            }

            mapInputs.clear();
            if(lstViolations[i]?.IETRS_Inspection_Package__c != null){
                mapInputs.put('varInspPackageID', lstViolations[i]?.IETRS_Inspection_Package__c);
                Flow.Interview flowSumPenaltyAmt = new Flow.Interview.IETRS_I_Sum_Penalty_Amount_from_Insp_Package_Violations(mapInputs);     
                flowSumPenaltyAmt.start();
            }

        }
    }
            

    /**
     * @description Reorder the violation number values after a record is deleted
     * @param violations List of violations belonging to inspections whose related
     *  vioaltions should be reordered
     */
    private static void reorderViolationNumbers(List<IETRS_Violation__c> violations) {
        Set<Id> inspectionIds = new Set<Id>();
        List<IETRS_Violation__c> updateViolations = new List<IETRS_Violation__c>();
        List<IETRS_Violation__c> allRelatedViolations = new List<IETRS_Violation__c>();

        // get all inspection ids associated with the records in scope
        for (IETRS_Violation__c violation : violations) {
            if (violation.IETRS_Inspection__c != null) {
                inspectionIds.add(violation.IETRS_Inspection__c);
            }
        }

        // exit if there are no related inspection ids
        if (inspectionIds.isEmpty()) {
            return;
        }

        // get all violations related to the inspections in scope
        for (IETRS_Violation__c violation : [
            SELECT Id, Name, CreatedDate, IETRS_Violation_Num__c, IETRS_Inspection__c
            FROM IETRS_Violation__c
            WHERE IETRS_Inspection__c IN :inspectionIds
            ORDER BY CreatedDate, Name
        ]) {
            allRelatedViolations.add(violation);
        }

        // get violations grouped by inspection id, sort and update
        Map<Id, List<ViolationWrapper>> violationsByInspectionId = getViolationsByInspectionIdMap(allRelatedViolations);
        for (Id inspectionId : violationsByInspectionId.keySet()) {
            Integer violationNumber = 1;
            List<ViolationWrapper> sortedViolations = violationsByInspectionId.get(inspectionId);
            sortedViolations.sort();
            for (ViolationWrapper vw : sortedViolations) {
                if (vw.violation.IETRS_Violation_Num__c != violationNumber) {
                    vw.violation.IETRS_Violation_Num__c = violationNumber;
                    updateViolations.add(vw.violation);
                }
                ++violationNumber;
            }
        }

        // update violations with new violation number values
        if (!updateViolations.isEmpty()) {
            update updateViolations;
        }
    }

    /**
     * @description Construct a map of ViolationWrappers (for custom sorting) grouped by inpection Id
     * @param violations List of violations used to construct the result
     * @return A map of ViolationWrappers grouped by inspection id
     */
    private static Map<Id, List<ViolationWrapper>> getViolationsByInspectionIdMap(List<IETRS_Violation__c> violations) {
        Map<Id, List<ViolationWrapper>> violationsByInspectionId = new Map<Id, List<ViolationWrapper>>();
        // construct a map of violations in scope grouped by inspection id
        for (IETRS_Violation__c violation : violations) {
            if (!violationsByInspectionId.containsKey(violation.IETRS_Inspection__c)) {
                violationsByInspectionId.put(violation.IETRS_Inspection__c, new List<ViolationWrapper>());
            }
            violationsByInspectionId.get(violation.IETRS_Inspection__c).add(new ViolationWrapper(violation));
        }
        return violationsByInspectionId;
    }

    /**
     * @description Wrapper class that implements Comparable for sorting the list
     *   of violations by CreatedDate then by Name if the CreatedDate is the same.
     */
    private class ViolationWrapper implements Comparable {
        public IETRS_Violation__c violation;
        public ViolationWrapper(IETRS_Violation__c violation) {
            this.violation = violation;
        }
        public Integer compareTo(Object compareTo) {
            ViolationWrapper compareViolation = (ViolationWrapper) compareTo;
            Integer returnValue = 0;
            // sort by created date
            if (violation.CreatedDate > compareViolation.violation.CreatedDate) {
                returnValue = 1;
            } else if (violation.CreatedDate < compareViolation.violation.CreatedDate) {
                returnValue = -1;
            }
            // if the same, use the id
            if (returnValue == 0) {
                List<String> names = new List<String>{ violation.Name, compareViolation.violation.Name };
                names.sort();
                if (names[0] == violation.Name) {
                    returnValue = -1;
                } else {
                    returnValue = 1;
                }
            }
            return returnValue;
        }
    }
}