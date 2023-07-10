/**
 * @author Greg Lovelidge
 * @date 7/23/2020
 *
 * @description Service class for Inspections
 */
public inherited sharing class IETRS_I_InspectionsService {
    /*******************************************************************************************************
     * Class Methods
     */

    /**
     * @description Update the inspector list field on the Inspection Package
     * @param Ids of the inspection packages to update
     * @return List of updated IPs
     */
    public static List<IETRS_Inspection_Package__c> updateInspectorListOnInspectionPackages(
        Set<Id> inspectionPackageIds
    ) {
        Map<Id, List<String>> inspectorNamesByIPId = new Map<Id, List<String>>();
        // add IETRS_Regional_Manager__c and IETRS_Lead_Inspector__c from IP
        for (IETRS_Inspection_Package__c ip : [
            SELECT Id, IETRS_Region_Lead__r.Name, IETRS_Lead_Inspector__r.Name
            FROM IETRS_Inspection_Package__c
            WHERE Id IN :inspectionPackageIds
        ]) {
            List<String> inspectorNames = new List<String>();
            if (!inspectorNamesByIPId.containsKey(ip.Id)) {
                inspectorNamesByIPId.put(ip.Id, inspectorNames);
            }
            if (ip.IETRS_Lead_Inspector__r != null) {
                inspectorNames.add(ip.IETRS_Lead_Inspector__r.Name);
            }
            if (ip.IETRS_Region_Lead__r != null) {
                inspectorNames.add(ip.IETRS_Region_Lead__r.Name);
            }
        }
        // get current list of ip inspectors
        for (IETRS_Insp_Inspection_Package_Inspector__c inspector : [
            SELECT Id, IETRS_Inspection_Package__c, IETRS_Inspector__r.Name
            FROM IETRS_Insp_Inspection_Package_Inspector__c
            WHERE IETRS_Inspection_Package__c IN :inspectorNamesByIPId.keySet()
        ]) {
            if (inspector.IETRS_Inspector__r != null) {
                List<String> inspectorNames = inspectorNamesByIPId.get(inspector.IETRS_Inspection_Package__c);
                inspectorNames.add(inspector.IETRS_Inspector__r.Name);
            }
        }

        List<IETRS_Inspection_Package__c> updateIPs = new List<IETRS_Inspection_Package__c>();
        for (Id ipId : inspectorNamesByIPId.keySet()) {
            updateIPs.add(
                new IETRS_Inspection_Package__c(
                    Id = ipId,
                    IETRS_Assigned_Inspector_List__c = String.join(inspectorNamesByIPId.get(ipId), ';')
                )
            );
			
        }
        update updateIPs;
        return updateIPs;
    }

    /**
     * @description Update the county list field on inspections
     * @param Ids of the inspection to update
     * @return List of updated Inspections
     */
    public static List<IETRS_Inspection__c> updateCountyListOnInspections(Set<Id> inspectionIds) {
        Map<Id, Set<String>> countyNamesByEntityId = new Map<Id, Set<String>>();

        // get current list of counties
        for (IETRS_Insp_Inspection_Counties_at_Eval__c record : [
            SELECT Id, IETRS_Inspection__c, IETRS_County__r.Name
            FROM IETRS_Insp_Inspection_Counties_at_Eval__c
            WHERE IETRS_Inspection__c IN :inspectionIds AND IETRS_County__c != null
        ]) {
            if (!countyNamesByEntityId.containsKey(record.IETRS_Inspection__c)) {
                countyNamesByEntityId.put(record.IETRS_Inspection__c, new Set<String>());
            }
            countyNamesByEntityId.get(record.IETRS_Inspection__c).add(record.IETRS_County__r.Name);
        }

        // query the records and update the county list field
        List<IETRS_Inspection__c> updateInspections = new List<IETRS_Inspection__c>();
        for (Id inspectionId : countyNamesByEntityId.keySet()) {
            Set<String> countyList = countyNamesByEntityId.get(inspectionId);
            List<String> sortedCounties = new List<String>(countyList);
            sortedCounties.sort();
            updateInspections.add(
                new IETRS_Inspection__c(
                    Id = inspectionId,
                    IETRS_Inspection_Counties__c = String.join(sortedCounties, ';')
                )
            );
        }
        // update the inspections
        if (!updateInspections.isEmpty()) {
            update updateInspections;
        }
        return updateInspections;
    }

    /**
     * @description Update the county list field on entities
     * @param Ids of the entities to update
     * @return List of Entities
     */
    public static List<Account> updateCountyListOnEntities(Set<Id> entityIds) {
        Map<Id, Set<String>> countyNamesByEntityId = new Map<Id, Set<String>>();

        // get current list of counties
        for (IETRS_Insp_Miles_by_County__c record : [
            SELECT Id, IETRS_Regulated_Entity__c, IETRS_County_Name__c
            FROM IETRS_Insp_Miles_by_County__c
            WHERE IETRS_Regulated_Entity__c IN :entityIds AND IETRS_County__c != null
        ]) {
            if (!countyNamesByEntityId.containsKey(record.IETRS_Regulated_Entity__c)) {
                countyNamesByEntityId.put(record.IETRS_Regulated_Entity__c, new Set<String>());
            }
            countyNamesByEntityId.get(record.IETRS_Regulated_Entity__c).add(record.IETRS_County_Name__c);
        }

        // query the records and update the county list field
        List<Account> updateEntities = new List<Account>();
        for (Id entityId : countyNamesByEntityId.keySet()) {
            Set<String> countyList = countyNamesByEntityId.get(entityId);
            List<String> sortedCounties = new List<String>(countyList);
            sortedCounties.sort();
            updateEntities.add(new Account(Id = entityId, IETRS_Counties_List__c = String.join(sortedCounties, ';')));
        }
        // update the inspections
        if (!updateEntities.isEmpty()) {
            update updateEntities;
        }
        return updateEntities;
    }

    /**
     * @description Asynchronously set the new miles totals on orgs. Handled in future context so
     *  that the summarized rollup summary fields reflect the change.
     * @param The account ids of the orgs to update
     */
    /*
    Depricated, as the total miles is now a rollup summary field, and tracked on a junction object.
    @future
    public static void updateTotalMilesOnOrgs(Set<Id> orgIds) {
        Map<Id, Account> orgsToUpdateByOrgId = new Map<Id, Account>();
        Id psEntityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Regulated_Entity_PS')
            .getRecordTypeId();
        Set<String> validStatuses = new Set<String>{ 'Active', 'Idle', 'Construction' };
        Map<String, String> totalFieldByProductClass = new Map<String, String>{
            'Gas' => 'IETRS_Gas_Pipe_Total_Miles__c',
            'Liquid' => 'IETRS_Liquid_Pipes_Total_Miles__c'
        };
        // get the sum total miles of liquid and gas entities for child orgs
        for (AggregateResult ag : [
            SELECT IETRS_OrganizationofRegEntity__c, IETRS_Product_Class__c, SUM(IETRS_Total_Miles__c) totalMiles
            FROM Account
            WHERE
                IETRS_OrganizationofRegEntity__c IN :orgIds
                AND RecordTypeId = :psEntityRecordTypeId
                AND IETRS_Status__c IN :validStatuses
                AND IETRS_Product_Class__c IN :totalFieldByProductClass.keySet()
            GROUP BY ROLLUP(IETRS_OrganizationofRegEntity__c, IETRS_Product_Class__c)
        ]) {
            String productClass = (String) ag.get('IETRS_Product_Class__c');
            if (productClass != null) {
                Id orgId = (Id) ag.get('IETRS_OrganizationofRegEntity__c');
                Decimal totalMiles = (Decimal) ag.get('totalMiles');
                if (!orgsToUpdateByOrgId.containsKey(orgId)) {
                    orgsToUpdateByOrgId.put(
                        orgId,
                        new Account(
                            Id = orgId,
                            IETRS_Gas_Pipe_Total_Miles__c = 0.0,
                            IETRS_Liquid_Pipe_Total_Miles__c = 0.0
                        )
                    );
                }
                orgsToUpdateByOrgId.get(orgId).put(totalFieldByProductClass.get(productClass), totalMiles);
            }
        }
        update orgsToUpdateByOrgId.values();
    }
    */

    public static List<Account> updateMilesOfHighConsequenceGasOnOrgs(Set<Id> orgIds) {
        return updateMilesOfHighConsequenceOnOrgs(orgIds, true, false);
    }

    public static List<Account> updateMilesOfHighConsequenceLiquidOnOrgs(Set<Id> orgIds) {
        return updateMilesOfHighConsequenceOnOrgs(orgIds, false, true);
    }
    /**
     * Sum up the values in the field IETRS_Miles_of_HCA__c on all records of
     * IETRS_Pipes_by_Class__c where IETRS_Inspection__c  is IN (select IETRS_Latest_Inspection__c
     * from account where recordtype.name = "Regulated Entity - PS" and IETRS_OrganizationofRegEntity__c
     * = '{ORG/account}' )
     */
    public static List<Account> updateMilesOfHighConsequenceOnOrgs(
        Set<Id> orgIds,
        Boolean updateGas,
        Boolean updateLiquid
    ) {
        Map<Id, Id> orgIdByLatestInspectionId = new Map<Id, Id>();
        Id entityRecordTypeId = getRegulatedEntityPSRecordTypeId();
        Map<Id, Account> updateOrgById = new Map<Id, Account>();
        // get latest inspection ids from entities related to the orgIds
        for (Account entity : [
            SELECT IETRS_Latest_Inspection__c, IETRS_OrganizationofRegEntity__c
            FROM Account
            WHERE
                RecordTypeId = :entityRecordTypeId
                AND IETRS_OrganizationofRegEntity__c IN :orgIds
                AND IETRS_Latest_Inspection__c != null
        ]) {
            orgIdByLatestInspectionId.put(entity.IETRS_Latest_Inspection__c, entity.IETRS_OrganizationofRegEntity__c);
        }

        // summarize total gas miles on the org
        if (updateGas) {
            for (IETRS_Pipes_by_Class__c record : [
                SELECT IETRS_Miles_of_HCA__c, IETRS_Inspection__c
                FROM IETRS_Pipes_by_Class__c
                WHERE IETRS_Inspection__c IN :orgIdByLatestInspectionId.keySet()
            ]) {
                Id orgId = orgIdByLatestInspectionId.get(record.IETRS_Inspection__c);
                incrementTotalMiles(
                    orgId,
                    record.IETRS_Miles_of_HCA__c,
                    updateOrgById,
                    Account.Total_Miles_of_High_Consequence_Gas__c
                );
            }
        }

        // summarize total liquid miles
        if (updateLiquid) {
            for (IETRS_Pipes_by_Class_Haz_Liq__c record : [
                SELECT IETRS_Miles_of_HCA__c, IETRS_Inspection__c
                FROM IETRS_Pipes_by_Class_Haz_Liq__c
                WHERE IETRS_Inspection__c IN :orgIdByLatestInspectionId.keySet()
            ]) {
                Id orgId = orgIdByLatestInspectionId.get(record.IETRS_Inspection__c);
                incrementTotalMiles(
                    orgId,
                    record.IETRS_Miles_of_HCA__c,
                    updateOrgById,
                    Account.Total_Miles_of_High_Consequence_Liq__c
                );
            }
        }

        // update and return orgs
        update updateOrgById.values();
        return updateOrgById.values();
    }

    private static void incrementTotalMiles(
        Id orgId,
        Decimal miles,
        Map<Id, Account> updateOrgById,
        Schema.SObjectField totalMilesField
    ) {
        if (miles == null || miles == -1) {
            miles = 0;
        }
        if (!updateOrgById.containsKey(orgId)) {
            Account org = new Account(Id = orgId);
            org.put(totalMilesField, 0);
            updateOrgById.put(orgId, org);
        }
        if (updateOrgById.get(orgId).get(totalMilesField) == null) {
            updateOrgById.get(orgId).put(totalMilesField, 0);
        }
        Decimal newMiles = miles + (Decimal) updateOrgById.get(orgId).get(totalMilesField);
        updateOrgById.get(orgId).put(totalMilesField, newMiles);
    }

    public static Id getRegulatedEntityPSRecordTypeId() {
        try {
            return Schema.SObjectType.Account
                .getRecordTypeInfosByDeveloperName()
                .get('Regulated_Entity_PS')
                .getRecordTypeId();
        } catch (Exception e) {
            return null;
        }
    }
}