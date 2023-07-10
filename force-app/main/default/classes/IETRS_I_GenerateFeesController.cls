public with sharing class IETRS_I_GenerateFeesController {
    public string selectedYear { get; set; }
    public List<selectOption> years { get; set; }
    public Boolean hasGeneratedFees { get; set; }
    public Boolean success { get; set; }
    public String selectedFeeType { get; set; }
    public Boolean loading { get; set; }
    public Boolean fcsupported { get; set; }
    public Boolean fcsuccess { get; set; }

    private Set<Id> entitiesWithExistingFeeIds = new Set<Id>();
    private Set<Id> existingFeeIds = new Set<Id>();
    private Map<Id, IETRS_Insp_Regulated_Fee__c> existingFeeByOrgId = new Map<Id, IETRS_Insp_Regulated_Fee__c>();

    final String distributionType = 'Distribution';
    final String mmType = 'Master Meter';
    final String entityRecordTypeName = 'Regulated Entity - PS';
    final Set<String> allowedFeeTypes = new Set<String>{ distributionType, mmType };
    final Map<String, String> feeFieldByType = new Map<String, String>{
        distributionType => 'IETRS_Service_Fee_Distribution__c',
        mmType => 'IETRS_System_Fee_Master_Meter__c'
    };
    final List<String> distAccountFields = new List<String>{
        'IETRS_Entity_Code__c',
        'IETRS_T4_Permit__c',
        'IETRS_Intra_Interstate__c',
        'IETRS_Install_Year__c',
        'IETRS_Type_of_Regulated__c',
        'IETRS_Total_Miles__c',
        'IETRS_OrganizationofRegEntity__r.IETRS_24_Hour_Phone__c',
        'IETRS_OrganizationofRegEntity__r.IETRS_Representative_Phone__c',
        'IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName',
        'IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.FirstName',
        'IETRS_Account_ID__c',
        'IETRS_Unit_Parent__c',
        'Id',
        'Type',
        'Name',
        'ParentId',
        'IETRS_Business_Area__c',
        'IETRS_Entity_Sub_Type__c',
        'IETRS_Jurisdiction__c',
        'IETRS_Region__c',
        'IETRS_Status__c',
        'IETRS_OrganizationofRegEntity__c',
        'Parent.Name',
        'IETRS_Latest_Inspection__r.IETRS_Total_Services_by_Size__c'
    };

    public IETRS_I_GenerateFeesController() {
        system.debug('selectedFeeType ' + selectedFeeType);
        selectedFeeType = getSelectedType();
        if(selectedFeeType == 'Master Meter')
            fcsupported = true;
        else
            fcsupported = false;
        //date myDate = Date.today();
        Integer currentYear = System.Today().year();
        years = new List<selectOption>();
        for (Integer i = 0; i < 6; i++) {
            String tempYear = String.valueOf(currentYear + i);
            years.add(new selectOption(tempYear, tempYear));
        }
    }

    public void save() {
        // return early if invalid
        if (!validate()) {
            return;
        }
        loading = true;
        // Set selected year if null
        if (selectedYear == null) {
            selectedYear = String.valueOf(System.Today().year());
        }

        // Check if fees have been generated for this year already
        for (IETRS_Regulated_Fee_System__c childFee : [
            SELECT Id, IETRS_Regulated_Entity__c, IETRS_Regulated_Fee__c
            FROM IETRS_Regulated_Fee_System__c
            WHERE
                IETRS_Regulated_Fee__r.IETRS_Fee_Type__c = :selectedFeeType
                AND IETRS_Organization__r.RecordType.Name != 'Archived Account'
                AND CALENDAR_YEAR(IETRS_Regulated_Fee__r.IETRS_Fee_Date__c) = :Integer.valueOf(selectedYear)
        ]) {
            entitiesWithExistingFeeIds.add(childFee.IETRS_Regulated_Entity__c);
            existingFeeIds.add(childFee.IETRS_Regulated_Fee__c);
        }

        // If no fees, create them. Otherwise, user will see a message and have to confirm.
        if (entitiesWithExistingFeeIds.isEmpty()) {
            createFees();
        } else {
            hasGeneratedFees = true;
            ApexPages.Message msg = new ApexPages.Message(
                ApexPages.Severity.WARNING,
                ' ' +
                selectedFeeType +
                ' fees were already generated for ' +
                selectedYear +
                '.'
            );
            ApexPages.addMessage(msg);
            getExistingFees();
        }
        loading = false;
    }

    public void saveAndRemoveExisting() {
        loading = true;
        // delete existing fees and empty the existing id lists
        deleteExistingFees();
        // create fees
        createFees();
        loading = false;
    }

    public void saveAndKeepExisting() {
        loading = true;
        createFees();
        loading = false;
    }

    public List<SelectOption> getFeeTypeOptions() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '--Select a Fee Type--'));
        for (String s : allowedFeeTypes) {
            result.add(new SelectOption(s, s));
        }
        return result;
    }

    private String getSelectedType() {
        String urlParam = ApexPages.currentPage().getParameters().get('type');
        if (allowedFeeTypes.contains(urlParam)) {
            return urlParam;
        }
        return null;
    }

    private Boolean validate() {
        Boolean result = true;
        if (!allowedFeeTypes.contains(selectedFeeType)) {
            ApexPages.Message msg = new ApexPages.Message(
                ApexPages.Severity.Error,
                ' The selected fee type is not valid.'
            );
            ApexPages.addMessage(msg);
            result = false;
            return result;
        }
        if (String.isBlank(selectedFeeType)) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ' Fee Type is required.');
            ApexPages.addMessage(msg);
            return result;
        }
        return result;
    }

    private void getExistingFees() {
        for (IETRS_Insp_Regulated_Fee__c fee : [
            SELECT
                Id,
                IETRS_Organization__c,
                IETRS_Fee_Type__c,
                IETRS_Status__c,
                IETRS_Distribution_Fee_Per_Service__c,
                IETRS_Fee_Date__c
            FROM IETRS_Insp_Regulated_Fee__c
            WHERE Id IN :existingFeeIds
            AND IETRS_Organization__r.RecordType.Name = 'Organization'
        ]) {
            existingFeeByOrgId.put(fee.IETRS_Organization__c, fee);
        }
    }

    private void deleteExistingFees() {
        delete existingFeeByOrgId.values();
        existingFeeByOrgId = new Map<Id, IETRS_Insp_Regulated_Fee__c>();
        // empty the entities list
        entitiesWithExistingFeeIds = new Set<Id>();
    }

    private void createFees() {
        try {
            // Get Regulated Entity record type id
            String rtId = [SELECT Id FROM RecordType WHERE Name = :entityRecordTypeName LIMIT 1].Id;

            // Get distribution accounts
            String distAccountsQuery = getDistAccountsQuery();
            List<Account> distAccounts = Database.query(distAccountsQuery);

            // Get the fee amount from fees by year metadata
            String mlSY = selectedYear + ' Fees';
            Decimal feeAmount;
            Date feeDateMM;
            Date feeDateDist;
            for (IETRS_Fees_by_Year__mdt feesByYear : [
                SELECT IETRS_Service_Fee_Distribution__c, IETRS_System_Fee_Master_Meter__c, IETRS_Master_Meter_Fee_Date__c, IETRS_Distribution_Fee_Date__c
                FROM IETRS_Fees_by_Year__mdt
                WHERE masterlabel = :mlSY
                LIMIT 1
            ]) {
                feeAmount = (Decimal) feesByYear.get(feeFieldByType.get(selectedFeeType));
                feeDateMM = feesByYear.IETRS_Master_Meter_Fee_Date__c;
                feeDateDist = feesByYear.IETRS_Distribution_Fee_Date__c;
            }

            // Throw an error if there's no fee for this year
            if (feeAmount == null) {
                ApexPages.Message msg = new ApexPages.Message(
                    ApexPages.Severity.Error,
                    ' There are no fees configured for ' +
                    selectedYear +
                    '. Please create a "IETRS Fees by Year" custom metadata record with the label  "' +
                    mlSY +
                    '" and try again.'
                );
                ApexPages.addMessage(msg);
                return;
            }

            // Construct map of distribution accounts by parent Organization (account) id
            Map<String, List<Account>> orgToRegEntitiesMap = new Map<String, List<Account>>();
            if (!distAccounts.isEmpty()) {
                for (Account a : distAccounts) {
                    // ignore accounts that have fees already
                    Boolean include = entitiesWithExistingFeeIds.isEmpty()
                        ? true
                        : !entitiesWithExistingFeeIds.contains(a.Id);
                    if (include) {
                        if (orgToRegEntitiesMap.get(a.IETRS_OrganizationofRegEntity__c) == null)
                            orgToRegEntitiesMap.put(a.IETRS_OrganizationofRegEntity__c, new List<Account>());
                        orgToRegEntitiesMap.get(a.IETRS_OrganizationofRegEntity__c).add(a);
                    }
                }

                // Create regulated fee record for each Organization
                List<IETRS_Insp_Regulated_Fee__c> fees = new List<IETRS_Insp_Regulated_Fee__c>();
                for (String s : orgToRegEntitiesMap.keyset()) {
                    // don't create a new fee record for the org if one already exists
                    if (!existingFeeByOrgId.containsKey(s)) {
                        IETRS_Insp_Regulated_Fee__c newFee = new IETRS_Insp_Regulated_Fee__c();
                        newFee.IETRS_Organization__c = s;
                        newFee.IETRS_Fee_Type__c = selectedFeeType;
                        newFee.IETRS_Status__c = 'Not Paid';
                        newFee.IETRS_Distribution_Fee_Per_Service__c = feeAmount;
                        if(selectedFeeType == distributionType){                        
                            newFee.IETRS_Fee_Date__c = feeDateDist;
                        }else if(selectedFeeType == mmType){
                            newFee.IETRS_Fee_Date__c = feeDateMM;
                        }else{
                            newFee.IETRS_Fee_Date__c = System.today();
                        }
                        fees.add(newFee);
                    }
                }

                // insert fees if there are any
                if (!fees.isEmpty()) {
                    insert fees;
                }

                // add the existing fees to this list
                if (!existingFeeByOrgId.isEmpty()) {
                    fees.addAll(existingFeeByOrgId.values());
                }

                // if no new or existing fees, exit
                if (!fees.isEmpty()) {
                    // Construct map of fee id by organization (account) id
                    Map<Id, Id> orgToFeeMap = new Map<Id, Id>();
                    for (IETRS_Insp_Regulated_Fee__c f : fees) {
                        orgToFeeMap.put(f.IETRS_Organization__c, f.Id);
                    }

                    // Create child regulated fee records - each child fee is related to the Organization and the regulated entity
                    List<IETRS_Regulated_Fee_System__c> childFees = new List<IETRS_Regulated_Fee_System__c>();
                    for (String s : orgToRegEntitiesMap.keyset()) {
                        for (Account a : orgToRegEntitiesMap.get(s)) {
                            IETRS_Regulated_Fee_System__c newChildFee = new IETRS_Regulated_Fee_System__c();
                            newChildFee.IETRS_Regulated_Fee__c = orgToFeeMap.get(s);
                            newChildFee.IETRS_Regulated_Entity__c = a.Id;
                            newChildFee.IETRS_Organization__c = s;
                            newChildFee.IETRS_Jurisdiction__c = a.IETRS_Jurisdiction__c;
                            newChildFee.IETRS_Region__c = a.IETRS_Region__c;
                            newChildFee.IETRS_Total_Services_by_Size__c = a.IETRS_Latest_Inspection__r.IETRS_Total_Services_by_Size__c;
                            newChildFee.IETRS_Total_Miles__c = a.IETRS_Total_Miles__c;
                            newChildFee.IETRS_Unit__c = a.IETRS_Unit_Parent__c;
                            newChildFee.IETRS_Fee_System_ID__c = a.IETRS_Account_ID__c;
                            if (a.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName != null) {
                                newChildFee.IETRS_Representative_Name__c =
                                    a.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.FirstName +
                                    ' ' +
                                    a.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName;
                            }
                            newChildFee.IETRS_Phone__c = a.IETRS_OrganizationofRegEntity__r.IETRS_Representative_Phone__c;
                            newChildFee.IETRS_Phone_24__c = a.IETRS_OrganizationofRegEntity__r.IETRS_24_Hour_Phone__c;
                            newChildFee.Type__c = a.IETRS_Entity_Sub_Type__c;
                            newChildFee.IETRS_Total_Miles__c = a.IETRS_Total_Miles__c;
                            newChildFee.IETRS_Gathering__c = a.IETRS_Type_of_Regulated__c;
                            newChildFee.IETRS_Install_Year__c = a.IETRS_Install_Year__c;
                            newChildFee.IETRS_Intra_Interstate__c = a.IETRS_Intra_Interstate__c;
                            newChildFee.IETRS_T4_Permit__c = a.IETRS_T4_Permit__c;
                            newChildFee.IETRS_System_Type__c = a.IETRS_Entity_Code__c;
                            newChildFee.IETRS_From_Snapshot__c = true;
                            childFees.add(newChildFee);
                        }
                    }

                    // Create the child fees
                    if (!childFees.isEmpty()) {
                        insert childFees;
                    }
                }
            }
            success = true;
        } catch (Exception ex) {
            System.debug('The following exception has occurred: ' + ex.getMessage());
            ApexPages.Message msg = new ApexPages.Message(
                ApexPages.Severity.Error,
                ' There was an error creating the fees: ' + ex.getMessage()
            );
            ApexPages.addMessage(msg);
        }
    }

    private String getDistAccountsQuery() {
        String queryTemplate = 'SELECT {0} FROM Account WHERE {1} ORDER BY {2}';
        String fields = String.join(distAccountFields, ',');
        String whereClause = 'RecordTypeId = :rtId AND Type = :selectedFeeType AND IETRS_Status__c = \'Active\' AND IETRS_OrganizationofRegEntity__r.RecordType.Name = \'Organization\'';
        if (selectedFeeType == distributionType) {
            whereClause += ' AND IETRS_Latest_Inspection__r.IETRS_Total_Services_by_Size__c > 0';
        }
        String orderBy = 'IETRS_OrganizationofRegEntity__c';
        return String.format(queryTemplate, new List<String>{ fields, whereClause, orderBy });
    }
    
    public void generateFandC(){
        String context = 'Master Meter Invoice';
        Integer year = System.Today().year();
        IETRS_CongaDocGenBatch batchJob = new IETRS_CongaDocGenBatch(context, year);
        ID jobID = Database.executeBatch(batchJob,100);
        fcsuccess = true;
    }
}