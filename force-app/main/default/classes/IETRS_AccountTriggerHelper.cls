/**
 * @File Name          : IETRS_AccountTriggerHelper.cls
 * @Description        :
 * @Author             : Kevin Lu
 * @Group              :
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 6/19/2020, 9:00:32 AM
 * @Modification Log   :
 * Ver      Date            Author          Modification
 * 1.0      10/31/2019      Kevin Lu        Initial Version
 * 2.0      12/09/2019      Kevin Lu        Updated processUpdate logic to update outside of loop
 * 3.0      01/06/2020      Kevin Lu        Changed updates to be future Apex to prevent CPU timeouts
 * 4.0      06/19/2020      Kevin Lu        Added new method for Event History when Account of Unit Record Type Deleted
 *                                          Merged changes for UAT deployment
 * 5.0      07/02/2020      Greg Lovelidge  Handle setting the permit and region values on orgs in after update, delete
 *                                          and undelete
 **/
public inherited sharing class IETRS_AccountTriggerHelper {
    private static final RecordType RECORD_TYPE_FIELD = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Account' AND Name = 'Field'
        ]
        .get(0);

    public static void handleAfterDelete() {
        updateSummaryFieldsOnOrg(Trigger.old);
        createActivityForDeletedUnit((Map<Id, Account>) Trigger.oldMap);
    }

    public static void handleAfterUndelete() {
        updateSummaryFieldsOnOrg(Trigger.new);
    }

    public static void handleAfterInsert() {
        updateSummaryFieldsOnOrg(Trigger.new);
    }

    public static void handleAfterUpdate() {
        updateOrgTotalMiles(Trigger.new);
        updateSummaryFieldsOnOrg(Trigger.new);
        processUpdates((List<Account>) Trigger.new, (Map<Id, Account>) Trigger.oldMap);
    }

    private static void processUpdates(List<Account> newAccounts, Map<Id, Account> oldAccounts) {
        //If updated accounts are permitted fields and the field exception checkbox has changed, see if parent accounts need to be updated as well
        //Set<Id> setAccounts = new Set<Id>();
        List<Account> lstNewAccUnitTrans = new List<Account>();
        Map<Id, Account> mpOldAccUnitTrans = new Map<Id, Account>();
        Id accUnitRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Unit')
            .getRecordTypeId();
        Id fieldRecordTypeId = RECORD_TYPE_FIELD.Id;
        for (Account newAccount : newAccounts) {
            /* Old drilling permit logic that is not performed in the trigger anymore
            //Check for account updates only if either the field exception is different or the parent id changes
            if (
                newAccount.RecordTypeId == fieldRecordTypeId &&
                newAccount.Type == 'Permitted Field' &&
                (newAccount.IETRS_Field_Exception__c != oldAccounts.get(newAccount.Id).IETRS_Field_Exception__c ||
                newAccount.parentId != oldAccounts.get(newAccount.Id).parentId)
            ) {
                setAccounts.add(newAccount.ParentId);
                setAccounts.add(oldAccounts.get(newAccount.Id).ParentId);
            }
            */

            // check if Unit has transferred
            if (
                newAccount.RecordTypeId == accUnitRecordTypeId &&
                newAccount.parentId != oldAccounts.get(newAccount.Id).parentId &&
                newAccount.parentId != null
            ) {
                lstNewAccUnitTrans.add(newAccount);
                mpOldAccUnitTrans.put(newAccount.Id, oldAccounts.get(newAccount.Id));
            }
        }
        if (!lstNewAccUnitTrans.isEmpty()) {
            createActivityTransferredUnit(lstNewAccUnitTrans, mpOldAccUnitTrans);
        }
        //updateParentFields(setAccounts);
    }

    /**
     * @description Looks for permitted fields to check if parent permit needs updating
     * @author Kevin Lu | 1/13/2020
     * @param setAccountIds The IDs of the Accounts that have been updated
     * @return void
     **/
    @future
    public static void processAccounts(Set<Id> setAccountIds) {
        //If inserted accounts are permitted fields see if parent accounts need to be updated as well
        Set<Id> setAccounts = new Set<Id>();
        for (Account newAccount : [
            SELECT Id, RecordTypeId, Type, ParentId
            FROM Account
            WHERE Id IN :setAccountIds AND ParentId != null
        ]) {
            setAccounts.add(newAccount.ParentId);
        }
        if (!setAccounts.isEmpty()) {
            updateParentFields(setAccounts);
        }
    }

    /**
     * @description Checks parent/geographic field records for child permitted fields that have field exceptions
     * @author Kevin Lu | 10/31/2019
     * @param setIds A set of Id's representing parent/geographic field records that may need updating
     * @return void
     **/
    private static void updateParentFields(Set<Id> setIds) {
        List<Account> lstAccounts = new List<Account>();
        //Pull permits and child permitted fields
        for (Account field : [
            SELECT
                Id,
                Name,
                IETRS_Permit_Field_Exception__c,
                (
                    SELECT Id, Name, IETRS_Field_Exception__c, RecordType.Name, Type
                    FROM ChildAccounts
                    WHERE RecordType.Name = 'Field' AND Type = 'Permitted Field'
                )
            FROM Account
            WHERE Id IN :setIds AND Type = 'Drilling Permit' AND RecordType.Name = 'Regulated Entity - OG'
        ]) {
            boolean foundChildException = false;
            for (Account childDrillingPermit : field.ChildAccounts) {
                //If any drilling permit has an exception, set the "found" boolean to be true and break
                if (childDrillingPermit.IETRS_Field_Exception__c) {
                    foundChildException = true;
                    break;
                }
            }
            field.IETRS_Permit_Field_Exception__c = foundChildException;
            lstAccounts.add(field);
        }

        try {
            update lstAccounts;
        } catch (Exception e) {
            System.debug(e);
        }
    }

    /**
     * @description Create Activity record if any account of type 'Unit' get  deleted.
     * @author Sandhya Belur | 04/21/2020
     * @param mapOldAccounts A map of Id and Account of records which are going to be deleted.
     * @return void
     **/
    public static void createActivityForDeletedUnit(map<Id, Account> mapOldAccounts) {
        List<Task> lstTask = new List<Task>();
        Id accUnitRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Unit')
            .getRecordTypeId();
        Id accRegEntPSRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Regulated_Entity_PS')
            .getRecordTypeId();

        for (Account objAcc : mapOldAccounts.values()) {
            if (
                (objAcc.RecordTypeId == accUnitRecordTypeId || objAcc.RecordTypeId == accRegEntPSRecordTypeId) &&
                objAcc.MasterRecordId == null // not a merged record
            ) {
                Id WhatId = objAcc.ParentId;
                String note = 'Record Deleted ' + objAcc.Name;
                lstTask.add(IETRS_Utility.createActivityHistoryRecord(WhatId, note));

                if (objAcc.RecordTypeId == accRegEntPSRecordTypeId) {
                    WhatId = objAcc.IETRS_OrganizationofRegEntity__c;
                    note = 'Record Deleted ' + objAcc.Name;
                    lstTask.add(IETRS_Utility.createActivityHistoryRecord(WhatId, note));
                }
            }
        }

        if (!lstTask.isEmpty()) {
            insert lstTask;
        }
    }

    /**
     * @description Create Activity record if any account of type 'Unit' is transferred (Parent Account changed).
     * @author Sandhya Belur | 05/15/2020
     * @param newAccounts : List of new version of accounts where parent account has changed.
     * @param mapOldAccounts A map of Id,Account which is old version of accounts where parent account has changed.
     * @return void
     */

    public static void createActivityTransferredUnit(List<Account> newAccounts, map<Id, Account> mapOldAccounts) {
        /*Set<Id> setAccIdToSearchParent = new Set<Id>();
        List<Task> lstTask = new List<Task>();
        Map<Id,Account> mapParentAccounts;
        
        for(Account objAcc : newAccounts){
            setAccIdToSearchParent.add(objAcc.ParentId);
            setAccIdToSearchParent.add(mapOldAccounts.get(objAcc.Id).ParentId);
        }
        
        mapParentAccounts = new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN :setAccIdToSearchParent]);
        
        if(!mapParentAccounts.isEmpty()){
            for(Account objAcc : newAccounts){ 
                String note,description;                   
                note = description = mapOldAccounts.get(objAcc.Id).ParentId != null ? 'Unit transferred from ' + mapParentAccounts.get(mapOldAccounts.get(objAcc.Id).ParentId).Name  + ' To ' + mapParentAccounts.get(objAcc.ParentId).Name : 'Unit transferred To ' + mapParentAccounts.get(objAcc.ParentId).Name ;                    
                Task objT = IETRS_Utility.createActivityHistoryRecord(objAcc.Id,note);
                objT.Description = description;
                objT.Subject = 'Unit Transferred';
                objT.Type = 'Records Transferred';
                lstTask.add(objT);
                
                
                // create history for New Parent record // comment below 5 lines incase it is already working.               
                //objT = IETRS_Utility.createActivityHistoryRecord(objAcc.ParentId,note);
                //objT.Description = description;
                //objT.Subject = 'Unit Transferred In';
                //objT.Type = 'Records Transferred';
                //lstTask.add(objT);
                // comment above 5 lines incase it is already working. - END
                
                
                // create history for Old parent record
                if(mapOldAccounts.get(objAcc.Id).ParentId != null){                    
                    objT = IETRS_Utility.createActivityHistoryRecord(mapOldAccounts.get(objAcc.Id).ParentId,note);
                    objT.Description = description;
                    objT.Subject = 'Unit Transferred Out';
                    objT.Type = 'Records Transferred';
                    lstTask.add(objT);
                }
                
            }
            
            if(!lstTask.isEmpty()){
                insert lstTask;
            }
        }*/
    }

    private static void updateSummaryFieldsOnOrg(List<Account> entities) {
        Map<Schema.SObjectField, Set<Id>> eligibleOrgIdsByField = getEligibleOrgIdsByField(entities);
        Set<Id> highConsequenceGasOrLiquidOrgIds = eligibleOrgIdsByField.get(
            Account.Total_Miles_of_High_Consequence_Gas__c
        );
        Set<Id> eligibleRegionPermitOrgIds = eligibleOrgIdsByField.get(Account.IETRS_T4_Permit_List__c);
        eligibleRegionPermitOrgIds.addAll(eligibleOrgIdsByField.get(Account.IETRS_Region_List__c));
        // check if permit or region lists need to be updated
        if (!eligibleRegionPermitOrgIds.isEmpty()) {
            setPermitAndRegionListsOnOrg(eligibleRegionPermitOrgIds);
        }
        // check if Total_Miles_of_High_Consequence_Gas__c should be updated
        if (!highConsequenceGasOrLiquidOrgIds.isEmpty()) {
            IETRS_I_InspectionsService.updateMilesOfHighConsequenceOnOrgs(highConsequenceGasOrLiquidOrgIds, true, true);
        }
    }

    private static void setPermitAndRegionListsOnOrg(Set<Id> orgIds) {
        // Construct the new permit and region list values
        // { orgId => {permits => '123,456', regionIds => 'a,b,c'} }
        Map<Id, Map<String, Set<String>>> listsByOrgId = new Map<Id, Map<String, Set<String>>>();
        Map<Id, String> regionNameById = new Map<Id, String>();
        Set<Id> regionIds = new Set<Id>();
        Id psEntityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Regulated_Entity_PS')
            .getRecordTypeId();
        // copied date over from the old formula criteria in process builder
        DateTime eligibleDT = DateTime.newInstance(2019, 7, 30);
        for (Account entity : [
            SELECT Id, IETRS_OrganizationofRegEntity__c, IETRS_T4_Permit__c, IETRS_Region__c
            FROM Account
            WHERE
                RecordTypeId = :psEntityRecordTypeId
                AND IETRS_OrganizationofRegEntity__c IN :orgIds
                AND CreatedDate >= :eligibleDT
        ]) {
            if (!listsByOrgId.containsKey(entity.IETRS_OrganizationofRegEntity__c)) {
                listsByOrgId.put(
                    entity.IETRS_OrganizationofRegEntity__c,
                    new Map<String, Set<String>>{ 'permits' => new Set<String>(), 'regionIds' => new Set<String>() }
                );
            }
            Map<String, Set<String>> orgLists = listsByOrgId.get(entity.IETRS_OrganizationofRegEntity__c);
            // add the permit to the map
            if (entity.IETRS_T4_Permit__c != null) {
                orgLists.get('permits').add(entity.IETRS_T4_Permit__c);
            }
            // add the region id to the map
            if (entity.IETRS_Region__c != null) {
                orgLists.get('regionIds').add(entity.IETRS_Region__c);
                regionIds.add(entity.IETRS_Region__c);
            }
        }

        // if there are region ids, get those region names
        if (!regionIds.isEmpty()) {
            for (IETRS_County_Group__c region : [SELECT Id, Name FROM IETRS_County_Group__c WHERE Id IN :regionIds]) {
                regionNameById.put(region.Id, region.Name);
            }
        }

        // set the updated permit and region lists on the org
        List<Account> updateOrgs = new List<Account>();
        for (Id orgId : orgIds) {
            Account org = new Account(Id = orgId);
            Map<String, Set<String>> orgLists = listsByOrgId.get(orgId);
            Set<String> regionNames = new Set<String>();
            if (orgLists != null && regionIds != null && (!orgLists.get('regionIds').isEmpty())) {
                for (String regionId : orgLists.get('regionIds')) {
                    regionNames.add(regionNameById.get(regionId));
                }
            }
            org.IETRS_Region_List__c = String.join(new List<String>(regionNames), '; ');
            if(orgLists != null)
            org.IETRS_T4_Permit_List__c = String.join(new List<String>(orgLists.get('permits')), '; ');
            updateOrgs.add(org);
        }

        update updateOrgs;
    }

    private static Map<Schema.SObjectField, Set<Id>> getEligibleOrgIdsByField(List<Account> entities) {
        Map<Schema.SObjectField, Set<Id>> eligibleOrgIdsByField = new Map<Schema.SObjectField, Set<Id>>{
            Account.IETRS_Region_List__c => new Set<Id>(),
            Account.IETRS_T4_Permit_List__c => new Set<Id>(),
            Account.Total_Miles_of_High_Consequence_Gas__c => new Set<Id>()
        };
        Id psEntityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Regulated_Entity_PS')
            .getRecordTypeId();

        for (Account acc : entities) {
            if (Trigger.isUpdate) {
                Account oldAcc = (Account) Trigger.oldMap.get(acc.Id);
                if (acc.RecordTypeId != psEntityRecordTypeId || oldAcc.RecordTypeId != psEntityRecordTypeId) {
                    // skip if the record type is not ps entity
                    // or the created date is before the eligible dt
                    continue;
                }
                // if the org or record type changes, this makes the old org and new org eligible for all potential changes
                if (
                    oldAcc.IETRS_OrganizationofRegEntity__c != acc.IETRS_OrganizationofRegEntity__c ||
                    oldAcc.RecordTypeId != acc.RecordTypeId
                ) {
                    if (acc.IETRS_OrganizationofRegEntity__c != null) {
                        eligibleOrgIdsByField.get(Account.IETRS_T4_Permit_List__c)
                            .add(acc.IETRS_OrganizationofRegEntity__c);
                        eligibleOrgIdsByField.get(Account.IETRS_Region_List__c)
                            .add(acc.IETRS_OrganizationofRegEntity__c);
                        eligibleOrgIdsByField.get(Account.Total_Miles_of_High_Consequence_Gas__c)
                            .add(acc.IETRS_OrganizationofRegEntity__c);
                    }
                    if (oldAcc.IETRS_OrganizationofRegEntity__c != null) {
                        eligibleOrgIdsByField.get(Account.IETRS_T4_Permit_List__c)
                            .add(oldAcc.IETRS_OrganizationofRegEntity__c);
                        eligibleOrgIdsByField.get(Account.IETRS_Region_List__c)
                            .add(oldAcc.IETRS_OrganizationofRegEntity__c);
                        eligibleOrgIdsByField.get(Account.Total_Miles_of_High_Consequence_Gas__c)
                            .add(oldAcc.IETRS_OrganizationofRegEntity__c);
                    }
                }
                addOrgIdIfEligible(
                    Account.IETRS_T4_Permit__c,
                    oldAcc,
                    acc,
                    eligibleOrgIdsByField.get(Account.IETRS_T4_Permit_List__c)
                );
                addOrgIdIfEligible(
                    Account.IETRS_Region__c,
                    oldAcc,
                    acc,
                    eligibleOrgIdsByField.get(Account.IETRS_Region_List__c)
                );
                addOrgIdIfEligible(
                    Account.IETRS_Latest_Inspection__c,
                    oldAcc,
                    acc,
                    eligibleOrgIdsByField.get(Account.Total_Miles_of_High_Consequence_Gas__c)
                );
            } else {
                // insert, delete or undelete
                if (acc.RecordTypeId == psEntityRecordTypeId && acc.IETRS_OrganizationofRegEntity__c != null) {
                    // Include if org is not null, record type is ps entity
                    // and either permit or region are not null
                    addOrgIdIfEligible(
                        Account.IETRS_T4_Permit__c,
                        acc,
                        eligibleOrgIdsByField.get(Account.IETRS_T4_Permit_List__c)
                    );
                    addOrgIdIfEligible(
                        Account.IETRS_Region__c,
                        acc,
                        eligibleOrgIdsByField.get(Account.IETRS_Region_List__c)
                    );
                    addOrgIdIfEligible(
                        Account.IETRS_Latest_Inspection__c,
                        acc,
                        eligibleOrgIdsByField.get(Account.Total_Miles_of_High_Consequence_Gas__c)
                    );
                }
            }
        }
        return eligibleOrgIdsByField;
    }

    private static void addOrgIdIfEligible(
        Schema.SObjectField sobjectField,
        Account oldAcc,
        Account newAcc,
        Set<Id> eligibleOrgIds
    ) {
        if (oldAcc.get(sobjectField) != newAcc.get(sobjectField)) {
            eligibleOrgIds.add(newAcc.IETRS_OrganizationofRegEntity__c);
        }
    }

    private static void addOrgIdIfEligible(Schema.SObjectField sobjectField, Account acc, Set<Id> eligibleOrgIds) {
        if (acc.get(sobjectField) != null) {
            eligibleOrgIds.add(acc.IETRS_OrganizationofRegEntity__c);
        }
    }

    /**
     * @description Update the total miles on parent orgs if the entity status changed
     */
    private static void updateOrgTotalMiles(List<Account> accounts) {
        Id psEntityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Regulated_Entity_PS')
            .getRecordTypeId();
        Set<Id> eligibleOrgIds = new Set<Id>();
        for (Account acc : accounts) {
            Account oldAcc = (Account) Trigger.oldMap.get(acc.Id);
            if (
                acc.RecordTypeId == psEntityRecordTypeId &&
                acc.IETRS_Status__c != oldAcc.IETRS_Status__c &&
                acc.IETRS_OrganizationofRegEntity__c != null
            ) {
                eligibleOrgIds.add(acc.IETRS_OrganizationofRegEntity__c);
            }
        }
        /*
        Depricated, as the total miles is now a rollup summary field, and tracked on a junction object.
        if (!eligibleOrgIds.isEmpty()) {
            System.debug('update miles on org');
            IETRS_I_InspectionsService.updateTotalMilesOnOrgs(eligibleOrgIds);
        }
        */
    }
}