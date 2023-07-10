/*
@Class Name         : IETRS_Account_Merge
@Description        : Merge Regulated Entities on Account Object
@Author             : Srilu Mamillapalli
@Group              : 
@Last Modified By   : Srilu Mamillapalli
@Last Modified On   : 4/08/2020
@Modification Log   : 
==============================================================================
Ver         Date                     Author                 Modification
==============================================================================
1.0    4/08/2020,    Srilu Mamillapalli     Initial Version
*/

public class IETRS_Account_Merge {
    public static final string UNIT = 'Unit';
    public static final string ORGANIZATION = 'Organization';
    public static final string REGULATED_ENTITY = 'Regulated Entity';

    @AuraEnabled
    public static AccountTypes getAccountRecord(string accountId) {
        AccountTypes accounts = new AccountTypes();
        Map<id, Account> accountUnitsMap = new Map<Id, Account>();
        account accountSO = getAccount(accountId);
        if (accountSO != null) {
            string recordTypeName = accountSO.RecordType.Name;
            if (recordTypeName.equals(ORGANIZATION)) {
                accountUnitsMap = getAccountsMap(new Set<Id>{ accountId }, UNIT);
                accounts.unitAccounts = accountUnitsMap.values();
                accounts.regulatedAccounts = getAccountsMap(accountUnitsMap.keySet(), REGULATED_ENTITY).values();
                system.debug('==accounts.regulatedAccounts==' + accounts.regulatedAccounts);
                system.debug('Regulated' + accounts.regulatedAccounts);
            } else if (recordTypeName.equals(UNIT)) {
                accounts.regulatedAccounts = getAccountsMap(new Set<Id>{ accountId }, REGULATED_ENTITY).values();
                system.debug('Regulated2ts' + accounts.regulatedAccounts);
            }
            accounts.paramTypes = new SearchParams();
        }
        return accounts;
    }

    public static Account getAccount(string accountId) {
        try {
            return [SELECT Id, Name, RecordType.Name FROM Account WHERE Id = :accountId];
        } catch (exception e) {
            return null;
        }
    }

    public static Map<id, Account> getAccountsMap(set<id> accountIds, string recordTypeName) {
        try {
            return new Map<Id, Account>(
                [
                    SELECT Id, Name, IETRS_Region_ID__c, ParentId, Parent.Name, parent.IETRS_Unit_ID__c
                    FROM Account
                    WHERE ParentId IN :accountIds AND RecordType.Name LIKE :recordTypeName + '%'
                ]
            );
        } catch (exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static string mergeRecord(Account sourceAcc, Account targetAcc, string note) {
        try {
            System.debug(sourceAcc?.IETRS_Total_Miles__c);
            System.debug(targetAcc?.IETRS_Total_Miles__c);
            
            Account masterAcct = [
                SELECT Id, ParentId, IETRS_OrganizationofRegEntity__c, Name,RecordTypeId
                FROM Account
                WHERE Id = :targetAcc.Id
            ];
            
            targetAcc.IETRS_Total_Miles__c+=sourceAcc?.IETRS_Total_Miles__c;
            update targetAcc;
            
            List<Account> sourceAccount=new List<Account>([SELECT Id, Name, IETRS_Regulated_Entity_ID__c FROM Account WHERE Id = :sourceAcc.Id]);
            Account accTobeMerged;
            if(sourceAccount.size()>0){
                accTobeMerged = sourceAccount[0];
            }
            
            //  Account mergeAcct = [SELECT Id, Name,(Select Id,Name,IETRS_Entity__c From Remarks__r),(Select Id,Name,IETRS_Regulated_Entity__c From Inspections__r) FROM Account  Where Id =: sourceAcc.Id ];

            List<IETRS_Remark__c> remarksTobeUpdated = new List<IETRS_Remark__c>();
            List<IETRS_Inspection__c> inspecTobeUpdated = new List<IETRS_Inspection__c>();
            Map<Id, Id> mapCountyIdWithMilesCountyId = new Map<Id, Id>();
            Map<Id, decimal> mapMilesCountyIdWithMiles = new Map<Id, decimal>();

            if (accTobeMerged != null && masterAcct != null) {
                for (Account mergeAcct : [
                    SELECT
                        Id,
                        Name,RecordTypeId,
                        (SELECT Id, Name, IETRS_Entity__c FROM Remarks__r),
                        (
                            SELECT Id, Name, IETRS_Regulated_Entity__c
                            FROM Inspections__r
                            WHERE
                                IETRS_Inspection_Package__r.IETRS_Status__c != 'Initial'
                                AND IETRS_Inspection_Package__r.IETRS_Status__c != 'System Changes'
                        )
                    FROM Account
                    WHERE Id = :sourceAcc.Id
                ]) {
                    for (IETRS_Remark__c rmk : mergeAcct.Remarks__r) {
                        rmk.IETRS_Entity__c = masterAcct.Id;
                        remarksTobeUpdated.add(rmk);
                    }

                    for (IETRS_Inspection__c ins : mergeAcct.Inspections__r) {
                        ins.IETRS_Regulated_Entity__c = masterAcct.Id;
                        inspecTobeUpdated.add(ins);
                    }
                }

                if (!remarksTobeUpdated.isEmpty())
                    update remarksTobeUpdated;

                if (!inspecTobeUpdated.isEmpty()) {
                    update inspecTobeUpdated;
                }
            }

            string accountNameToBeMerged = accTobeMerged.Name;
            string accountIdToBeMerged = accTobeMerged.IETRS_Regulated_Entity_ID__c;
            string accountIdMaster = targetAcc.IETRS_Regulated_Entity_ID__c;
            masterAcct.Name = targetAcc.Name;
            masterAcct.IETRS_Install_Year__c = targetAcc.IETRS_Install_Year__c;
            masterAcct.IETRS_Entity_Code__c = targetAcc.IETRS_Entity_Code__c;
            masterAcct.IETRS_Status__c = targetAcc.IETRS_Status__c;
            masterAcct.IETRS_Jurisdiction__c = targetAcc.IETRS_Jurisdiction__c;
            masterAcct.IETRS_T4_Permit__c = targetAcc.IETRS_T4_Permit__c;
            masterAcct.IETRS_Intra_Interstate__c = targetAcc.IETRS_Intra_Interstate__c;
            masterAcct.IETRS_On_Offshore__c = targetAcc.IETRS_On_Offshore__c;
            masterAcct.IETRS_Entity_Sub_Type__c = targetAcc.IETRS_Entity_Sub_Type__c;
            if(accTobeMerged!=null &&masterAcct!=null ){
                merge masterAcct accTobeMerged;
            }
            /*
        Depricated, total miles is now calculated via a junction object which is auto-created/updated when account record of type RE is saved
            Map<String,String> mapInputs = new Map<String,String>();
            mapInputs.put('varOrganization', masterAcct.IETRS_OrganizationofRegEntity__c );
            mapInputs.put('varRERecordTypeId', masterAcct.RecordTypeId);
            Flow.Interview summingTotal = new Flow.Interview.IETRS_I_Summing_Total_Miles_for_Account(mapInputs);     
            summingTotal.start();
            */
            List<Task> taskHistory = new List<Task>();
            String description =
                'Account [' +
                accountNameToBeMerged +
                '] [' + accountIdToBeMerged +
                '] Merged Into [' +
                masterAcct.Name +
                '] [' + accountIdMaster + 
                ']. \n Comments:  ' +
                note;
            taskHistory.add(createActivityHistory(masterAcct.Id, description));
            if (masterAcct.ParentId != null) {
                taskHistory.add(createActivityHistory(masterAcct.ParentId, description));
            }
            if (masterAcct.IETRS_OrganizationofRegEntity__c != null) {
                taskHistory.add(createActivityHistory(masterAcct.IETRS_OrganizationofRegEntity__c, description));
            }
            insert taskHistory;

            List<IETRS_Insp_Miles_by_County__c> lstMilesCountiesToDelete = new List<IETRS_Insp_Miles_by_County__c>();
            for (IETRS_Insp_Miles_by_County__c objMilesByCounty : [
                SELECT Id, IETRS_Miles__c, IETRS_County__c
                FROM IETRS_Insp_Miles_by_County__c
                WHERE IETRS_Regulated_Entity__c = :masterAcct.Id
                ORDER BY LastModifiedDate ASC
            ]) {
                if (!mapCountyIdWithMilesCountyId.containsKey(objMilesByCounty.IETRS_County__c)) {
                    mapCountyIdWithMilesCountyId.put(objMilesByCounty.IETRS_County__c, objMilesByCounty.Id);
                    mapMilesCountyIdWithMiles.put(objMilesByCounty.Id, objMilesByCounty.IETRS_Miles__c);
                } else {
                    
                    Decimal miles = mapMilesCountyIdWithMiles.containsKey(objMilesByCounty.IETRS_County__c) ?
                        mapMilesCountyIdWithMiles.get(mapCountyIdWithMilesCountyId.get(objMilesByCounty.IETRS_County__c)) + objMilesByCounty?.IETRS_Miles__c : 0;
                    mapMilesCountyIdWithMiles.put(mapCountyIdWithMilesCountyId.get(objMilesByCounty.IETRS_County__c),miles);
                    lstMilesCountiesToDelete.add(objMilesByCounty);
                }
            }

            if (!mapMilesCountyIdWithMiles.isEmpty()) {
                List<IETRS_Insp_Miles_by_County__c> lstMilesCountiesToUpdate = new List<IETRS_Insp_Miles_by_County__c>();
                for (Id mileCountyId : mapMilesCountyIdWithMiles.keySet()) {
                    IETRS_Insp_Miles_by_County__c objMilesByCounty = new IETRS_Insp_Miles_by_County__c(
                        Id = mileCountyId,
                        IETRS_Miles__c = mapMilesCountyIdWithMiles.get(mileCountyId)
                    );
                    lstMilesCountiesToUpdate.add(objMilesByCounty);
                }
                update lstMilesCountiesToUpdate;

                delete lstMilesCountiesToDelete;

            }

            IETRS_SpecializedInspScheduleServices.sendEmail('Records Merged', description);

            return 'success';
        } catch (Exception ex) {
            return ex.getMessage()+ex.getLineNumber();
        }
    }
    
    private static Task createActivityHistory(Id accountId, String description) {
        Task objT = IETRS_Utility.createActivityHistoryRecord(accountId, description);
        objT.Description = description;
        objT.Subject = 'Account Merged';
        objT.Type = 'Records Merged';
        return objT;
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
}