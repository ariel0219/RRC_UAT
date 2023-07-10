/*
@Class Name         : IETRS_AccountTransfer
@Description        : Transfer Functionality on Account Object 
@Author             : Srilu Mamillapalli
@Group              : 
@Last Modified By   : Srilu Mamillapalli
@Last Modified On   : 3/24/2020
@Modification Log   : 
==============================================================================
Ver         Date                     Author                 Modification
==============================================================================
1.0    3/24/2020,    Srilu Mamillapalli     Initial Version
*/

public class IETRS_AccountTransfer {
    public static final string UNIT = 'Unit';
    public static final string ORGANIZATION = 'Organization';
    public static final string REGULATED_ENTITY = 'Regulated Entity';

    @AuraEnabled
    public static accountTypes getAccountRecord(string accountId) {
        accountTypes accounts = new accountTypes();
        Map<id, Account> accountUnitsMap = new Map<Id, Account>();
        account accountSO = getAccount(accountId);
        if (accountSO != null) {
            string recordTypeName = accountSO.RecordType.Name;
            if (recordTypeName.equals(ORGANIZATION)) {
                accountUnitsMap = getAccountsMap(
                    new Set<Id>{ accountId },
                    UNIT
                );
                accounts.unitAccounts = accountUnitsMap.values();
                accounts.regulatedAccounts = getAccountsMap(
                        accountUnitsMap.keySet(),
                        REGULATED_ENTITY
                    )
                    .values();
                system.debug('Regulated' + accounts.regulatedAccounts);
            } else if (recordTypeName.equals(UNIT)) {
                accounts.regulatedAccounts = getAccountsMap(
                        new Set<Id>{ accountId },
                        REGULATED_ENTITY
                    )
                    .values();
                system.debug('Regulated2ts' + accounts.regulatedAccounts);
            }
            accounts.paramTypes = new SearchParams();
        }
        system.debug('TestABC' + accounts);
        return accounts;
    }

    public class TransferResponse {
        @AuraEnabled
        public Boolean success { get; set; }
        @AuraEnabled
        public String error { get; set; }
        @AuraEnabled
        public List<IETRS_Inspection_Package__c> openInspectionPackages {
            get;
            set;
        }
        public TransferResponse(Boolean success) {
            this.success = success;
        }
    }

    public class AccountTypes {
        @AuraEnabled
        public list<Account> regulatedAccounts { get; set; }
        @AuraEnabled
        public list<Account> unitAccounts { get; set; }
        @AuraEnabled
        public SearchParams paramTypes { get; set; }
        public AccountTypes() {
        }
    }

    public class SearchParams {
        @AuraEnabled
        public String accountName { get; set; }
        @AuraEnabled
        public String p5Number { get; set; }
        @AuraEnabled
        public String oldOrgId { get; set; }
        @AuraEnabled
        public String transferToAccountId { get; set; }
        @AuraEnabled
        public String address { get; set; }
        @AuraEnabled
        public String city { get; set; }
        @AuraEnabled
        public String state { get; set; }
        @AuraEnabled
        public String zip { get; set; }
        public SearchParams() {
        }
    }

    public static Account getAccount(string accountId) {
        try {
            return [
                SELECT Id, Name, RecordType.Name
                FROM Account
                WHERE Id = :accountId
            ];
        } catch (exception e) {
            return null;
        }
    }

    public static Map<id, Account> getAccountsMap(
        set<id> accountIds,
        string recordTypeName
    ) {
        try {
            return new Map<Id, Account>(
                [
                    SELECT
                        Id,
                        Name,
                        Type,
                        IETRS_Entity_Code__c,
                        Org_P5_Number__c,
                        IETRS_OrganizationofRegEntity__r.Name,
                        IETRS_P5_Number__c,
                        IETRS_Region_ID__c,
                        ParentId,
                        Parent.Name
                    FROM Account
                    WHERE
                        ParentId IN :accountIds
                        AND RecordType.Name LIKE :recordTypeName + '%'
                ]
            );
        } catch (exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static TransferResponse transferRecord(
        string mainRecord,
        string parentRecord,
        List<string> childRecords,
        String Notes,
        String transType
    ) {
        List<Account> accountsList = new List<Account>();
        // if transType is Units, this is the org the units are being transfered to
        // if transType is Entities, this is the Unit the entities are being transfered to
        Account accountSO = [
            SELECT
                Id,
                name,
                IETRS_OrganizationofRegEntity__c,
                IETRS_Organization_Parent__c,
                IETRS_Unit_Parent__c,
                Type,
                IETRS_Entity_Code__c,
                parentId,
                recordType.Name
            FROM Account
            WHERE Id = :parentRecord
            LIMIT 1
        ];
        List<Account> childRecs = [
            SELECT Id, Name, Parent.Type
            FROM Account
            WHERE Id IN :childRecords
        ];
        // if you're transferring entities to units, the old unit and the new unit type need to be the same
        // if transType == 'Units', get regulated entities whose parent account is IN childRecords
        List<Account> unitChildEntities = new List<Account>();
        if (transType == 'Units') {
            for (Account entity : [
                SELECT Id, Name
                FROM Account
                WHERE ParentId IN :childRecords
            ]) {
                unitChildEntities.add(entity);
            }
        }

        if (UNIT.equals(accountSO.recordType.Name)) {
            // check that the new unit type matches the old unit type
            String oldUnitType = childRecs[0].Parent.Type;
            if (accountSO.Type != oldUnitType) {
                TransferResponse result = new TransferResponse(false);
                result.error =
                    'The new Unit Type (' +
                    accountSO.Type +
                    ') must match the old Unit Type (' +
                    oldUnitType +
                    ').';
                return result;
            }
            for (String accId : childRecords) {
                // list of reg entities to transfer
                account acc = new account();
                acc.Id = accId;
                acc.parentId = accountSO.Id;
                acc.IETRS_OrganizationofRegEntity__c = accountSO.parentId;
                //acc.IETRS_Organization_Parent__c = accountSO.IETRS_Organization_Parent__c;
                acc.IETRS_Unit_Parent__c = accountSO.IETRS_Unit_Parent__c;
                accountsList.add(acc);
            }
        } else {
            for (String accId : childRecords) {
                // list of units to transfer
                account acc = new account();
                acc.Id = accId;
                acc.parentId = accountSO.Id;
                acc.IETRS_Organization_Parent__c = accountSO.IETRS_Organization_Parent__c;
                accountsList.add(acc);
            }
            // Set the new org id on child regulated entities of the Units being transfered
            for (Account entity : unitChildEntities) {
                entity.IETRS_OrganizationofRegEntity__c = accountSO.Id;
                accountsList.add(entity);
            }
        }

        // Ensure there are no open inspection packages related to entities being transferred
        List<IETRS_Inspection_Package__c> openIPs = getOpenInspectionPackagesFromAccounts(
            accountsList
        );
        if (openIPs.isEmpty()) {
            system.debug('accountsList ###### ' + accountsList);
            update accountsList;

            //Regulated Fee reparent to Organization when Entities being Transferred.
            if (accountsList.size() > 0) {
                Map<Id, Account> mappedAccount = new Map<Id, Account>();
                list<IETRS_Insp_Regulated_Fee__c> listRegulatedFee = new List<IETRS_Insp_Regulated_Fee__c>();
                for (Account acct : accountsList) {
                    mappedAccount.put(acct.Id, acct);
                }

                if (mappedAccount.size() > 0) {
                    listRegulatedFee = [
                        SELECT
                            Id,
                            IETRS_Organization__c,
                            IETRS_Regulated_Entity__c,
                            IETRS_Unit__c
                        FROM IETRS_Insp_Regulated_Fee__c
                        WHERE
                            IETRS_Organization__c IN :mappedAccount.keySet()
                            OR IETRS_Regulated_Entity__c IN :mappedAccount.keySet()
                            OR IETRS_Unit__c IN :mappedAccount.keySet()
                    ];
                }

                system.debug('listRegulatedFee####' + listRegulatedFee);
                system.debug('###mappedAccount ' + mappedAccount);
                if (listRegulatedFee.size() > 0) {
                    for (
                        IETRS_Insp_Regulated_Fee__c regulatedFee : listRegulatedFee
                    ) {
                        if (regulatedFee.IETRS_Organization__c != null)
                            regulatedFee.IETRS_Organization__c = mappedAccount.get(
                                    regulatedFee.IETRS_Organization__c
                                ) != null
                                ? mappedAccount.get(
                                          regulatedFee.IETRS_Organization__c
                                      )
                                      .IETRS_OrganizationofRegEntity__c
                                : null;
                        else if (regulatedFee.IETRS_Regulated_Entity__c != null)
                            regulatedFee.IETRS_Organization__c = mappedAccount.get(
                                    regulatedFee.IETRS_Regulated_Entity__c
                                ) != null
                                ? mappedAccount.get(
                                          regulatedFee.IETRS_Regulated_Entity__c
                                      )
                                      .IETRS_OrganizationofRegEntity__c
                                : null;
                        else if (regulatedFee.IETRS_Unit__c != null)
                            regulatedFee.IETRS_Organization__c = mappedAccount.get(
                                    regulatedFee.IETRS_Unit__c
                                ) != null
                                ? mappedAccount.get(regulatedFee.IETRS_Unit__c)
                                      .IETRS_OrganizationofRegEntity__c
                                : null;
                    }

                    try {
                        system.debug(
                            'RegulatedFeeRecords ### ' + listRegulatedFee
                        );
                        update listRegulatedFee;
                    } catch (Exception ex) {
                        system.debug(
                            'The following exception occurred :' +
                            ex.getMessage() +
                            ' in Line ' +
                            ex.getLineNumber()
                        );
                    }
                }
            }

            // create events for transferred accounts
            List<Account> createEventAccounts = new List<Account>();
            createEventAccounts.addAll(childRecs);
            createEventAccounts.addAll(unitChildEntities);
            createEvents(
                createEventAccounts,
                Notes,
                mainRecord,
                accountSO,
                transType
            );
            return new TransferResponse(true);
        } else {
            TransferResponse result = new TransferResponse(false);
            result.error = 'Cannot transfer unit/regulated entity with an open inspection package:';
            result.openInspectionPackages = openIPs;
            return result;
        }
    }

    private static List<IETRS_Inspection_Package__c> getOpenInspectionPackagesFromAccounts(
        List<Account> accounts
    ) {
        Set<String> allowedStatuses = new Set<String>{
            'Closed',
            'Complete',
            'Database Changes'
        };
        List<IETRS_Inspection_Package__c> result = new List<IETRS_Inspection_Package__c>();
        for (IETRS_Inspection__c inspection : [
            SELECT
                IETRS_Inspection_Package__c,
                IETRS_Inspection_Package__r.Name,
                IETRS_Inspection_Package__r.IETRS_Status__c
            FROM IETRS_Inspection__c
            WHERE
                IETRS_Regulated_Entity__c IN :accounts
                AND IETRS_Inspection_Package__r.IETRS_Status__c NOT IN :allowedStatuses
        ]) {
            result.add(inspection.IETRS_Inspection_Package__r);
        }
        return result;
    }

    public static void createEvents(
        List<Account> childRecs,
        String Notes,
        Id transferredFromId,
        Account transferredTo,
        String transType
    ) {
        List<Task> lstTask = new List<Task>();
        Account transferredFromAcc = getAccount(transferredFromId);
        Account transferredToAcc = transferredTo;
        string fromName = transferredFromAcc != null
            ? transferredFromAcc.Name
            : null;
        string toName = transferredToAcc != null ? transferredToAcc.Name : null;
        transType = transType == 'Units' ? 'Unit' : 'Regulated Entity';
        for (Account objAcc : childRecs) {
            String note, description;
            note =
                transType +
                ' [' +
                objAcc.Name +
                ']' +
                (fromName != null
                    ? ' transferred from ' +
                      fromName +
                      ' To ' +
                      transferredToAcc.Name
                    : ' transferred To ' + transferredToAcc.Name);
            description = note + '\n Event Notes:  ' + Notes;
            Task objT = IETRS_Utility.createActivityHistoryRecord(
                objAcc.Id,
                note
            );
            objT.Description = description;
            objT.Subject = transType + ' Transferred';
            objT.Type = 'Records Transferred';
            lstTask.add(objT);
            System.debug(note);

            // create history for New Parent record // comment below 5 lines incase it is already working.
            objT = IETRS_Utility.createActivityHistoryRecord(
                transferredToAcc.Id,
                note
            );
            objT.Description = description;
            objT.Subject = transType + ' Transferred In';
            objT.Type = 'Records Transferred';
            lstTask.add(objT);
            // comment above 5 lines incase it is already working. - END

            objT = IETRS_Utility.createActivityHistoryRecord(
                transferredFromId,
                note
            );
            objT.Description = description;
            objT.Subject = transType + ' Transferred Out';
            objT.Type = 'Records Transferred';
            lstTask.add(objT);
        }

        if (!lstTask.isEmpty()) {
            insert lstTask;
            try {
                IETRS_SpecializedInspScheduleServices.sendEmail(
                    'Records Transferred',
                    lstTask[0].Description
                );
            } catch (Exception ex) {
                System.debug(
                    ' Send Email failed with error : ' + ex.getMessage()
                );
            }
        }
        /* existing code

for(account acc : [Select Id,name From Account Where Id =:accountIds]){
Event event = new Event(Transferred_From__c=fromName,Transferred_To__c=toName,OwnerId =  UserInfo.getUserId(),IETRS_Note__c = Notes,RecordTypeId=eventRecordTypeId,WhatId = acc.Id,Type = 'Other',Subject = 'Other',DurationInMinutes=30,ActivityDateTime=system.now());
eventList.add(event);
}
system.debug('eventList'+eventList);
if(!eventList.isEmpty()){  
insert eventList;
}
*Existing code END*/
    }

    @AuraEnabled
    public static list<Account> searchAccounts(
        SearchParams searchTypes,
        string recordTypeName
    ) {
        system.debug('@-- test = ' + searchTypes);
        system.debug('@-- recordTypeName = ' + recordTypeName);
        SearchParams params = searchTypes;
        try {
            String queryStr =
                'SELECT id,Name,Type,IETRS_Entity_Code__c,Org_P5_Number__c,Parent.Name,IETRS_OrganizationofRegEntity__r.Name,BillingCountry,BillingCity,BillingState,BillingPostalCode,IETRS_P5_Number__c ' +
                +'FROM Account WHERE recordType.Name = \'' +
                recordTypeName +
                '\'';
            if (!String.isBlank(params.accountName)) {
                queryStr += ' AND Name like \'%' + params.accountName + '%\'';
            }
            if (!String.isBlank(params.p5Number)) {
                if (recordTypeName.equalsIgnoreCase('Unit')) {
                    queryStr +=
                        ' AND Parent.IETRS_P5_Number__c like \'%' +
                        params.p5Number +
                        '%\'';
                } else {
                    queryStr +=
                        ' AND IETRS_P5_Number__c like \'%' +
                        params.p5Number +
                        '%\'';
                }
            }
            if (!String.isBlank(params.city)) {
                queryStr += ' AND BillingCity like \'%' + params.city + '%\'';
            }
            if (!String.isBlank(params.state)) {
                queryStr += ' AND BillingState like \'%' + params.state + '%\'';
            }
            if (!String.isBlank(params.zip)) {
                queryStr +=
                    ' AND BillingPostalCode like \'%' +
                    params.zip +
                    '%\'';
            }
            if (recordTypeName.equals(UNIT)) {
                queryStr +=
                    ' AND Id NOT IN (SELECT IETRS_Regulated_Entity__c FROM IETRS_Inspection__c ' +
                    'WHERE IETRS_Inspection_Status__c = \'closed\') LIMIT ' +
                    Limits.getLimitQueries();
            }
            system.debug('@-- Query = ' + queryStr);

            return Database.Query(queryStr);
        } catch (exception ex) {
            system.debug(
                'exception : ' +
                ex.getMessage() +
                ' at line no : ' +
                ex.getLineNumber()
            );
            return new List<Account>();
        }
    }

    //To filter Account by Name
    @AuraEnabled
    public static List<Account> findByName(
        String searchKey,
        List<Id> recordId
    ) {
        String name = +String.escapeSingleQuotes(searchKey) + '%';
        return [
            SELECT
                id,
                Name,
                Type,
                IETRS_Entity_Code__c,
                Parent.Name,
                IETRS_OrganizationofRegEntity__r.Name,
                IETRS_P5_Number__c,
                BillingCity,
                BillingState,
                BillingCountry,
                Org_P5_Number__c
            FROM Account
            WHERE Name LIKE :name AND Id IN :recordId
            LIMIT 1000
        ];
    }

    @AuraEnabled
    public static List<Account> findAccountByName(
        String searchKey,
        List<Id> recordIds
    ) {
        String name = +String.escapeSingleQuotes(searchKey) + '%';
        //String recordTypeName = recordType == 'Units' ? 'Unit' : 'Regulated Entity - PS';
        return [
            SELECT
                id,
                Name,
                Type,
                IETRS_Entity_Code__c,
                Parent.Name,
                IETRS_Region_ID__c,
                IETRS_OrganizationofRegEntity__r.Name,
                IETRS_P5_Number__c,
                Org_P5_Number__c
            FROM Account
            WHERE Name LIKE :name AND Id IN :recordIds
            LIMIT 1000
        ];
    }
}