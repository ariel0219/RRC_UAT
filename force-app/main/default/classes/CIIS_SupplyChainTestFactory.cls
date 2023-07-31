@IsTest
public class CIIS_SupplyChainTestFactory {
    private Map<String, String> controlStation {
        get {
            return new Map<String, String>{
                'CIIS_PL_Facility_Id__c' => 'PL_CC_999_{NNNNN}'
            };
        }
    }

    private Map<String, String> regulatorStation {
        get {
            return new Map<String, String>{
                'CIIS_PL_Facility_Id__c' => 'PL_REG_999_{NNNNN}'
            };
        }
    }

    private Map<String, String> meterStation {
        get {
            return new Map<String, String>{
                'CIIS_PL_Facility_Id__c' => 'MS_999_{NNNNN}'
            };
        }
    }

    private Map<String, String> gasProcessingFacility {
        get {
            return new Map<String, String>{
                'CIIS_RRC_Serial_Number__c' => '08-{NNNN}'
            };
        }
    }

    private Map<String, String> offLeaseCompressor {
        get {
            return new Map<String, String>{
                'CIIS_RRC_COMPRESSOR_ID__c' => 'OL_999_{NNNNN}'
            };
        }
    }

    private Map<String, String> plCompressor {
        get {
            return new Map<String, String>{
                'CIIS_RRC_COMPRESSOR_ID__c' => 'PL_999_{NNNNN}'
            };
        }
    }

    private Map<String, String> powerPlant {
        get {
            return new Map<String, String>{
                'CIIS_SubStation_ID__c' => '{NNNNNN}'
            };
        }
    }

    private Map<String, String> undergroundStorage {
        get {
            return new Map<String, String>{ 'IETRS_T4_Permit__c' => '{NNNNN}' };
        }
    }

    private Map<String, String> pipeline {
        get {
            return new Map<String, String>{
                'IETRS_System_ID__c' => '{NNNNNN}',
                'CIIS_PL_Facility_Id__c' => '{NNNNNNN}'
            };
        }
    }
    private Map<String, String> lease {
        get {
            return new Map<String, String>{
                'CIIS_RRC_Serial_Number__c' => '08-{NNNN}',
                'IETRS_Lease_Number__c' => '{NNNNN}'
            };
        }
    }

    private Map<String, String> swd {
        get {
            return new Map<String, String>{
                'IETRS_Lease_Number__c' => '{NNNNN}',
                'IETRS_API__c' => '{NNNNNNNN}',
                'IETRS_UIC_Number__c' => '{NNNNNN}'
            };
        }
    }

    /**
     * The setting for this supply chain type.
     */
    public Map<String, CIIS_Supply_Chain_Facility_Type_Setting__mdt> settingByLabel {
        get {
            if (settingByLabel == null) {
                Map<String, CIIS_Supply_Chain_Facility_Type_Setting__mdt> result = new Map<String, CIIS_Supply_Chain_Facility_Type_Setting__mdt>();
                for (CIIS_Supply_Chain_Facility_Type_Setting__mdt scSetting : [
                    SELECT
                        MasterLabel,
                        CIIS_External_Source_of_Truth__c,
                        CIIS_Fields_to_Show__c,
                        CIIS_Input_Fields__c,
                        CIIS_SOQL_Where_Clause__c,
                        CIIS_Unique_Id_Field_Name__c,
                        CIIS_Unique_Id_Label__c,
                        CIIS_Operator_Relationship_Field_Name__c,
                        CIIS_Default_Field_Values__c,
                        CIIS_Record_Type_API_Name__c
                    FROM CIIS_Supply_Chain_Facility_Type_Setting__mdt
                ]) {
                    result.put(scSetting.MasterLabel, scSetting);
                }
                settingByLabel = result;
            }
            return settingByLabel;
        }
        set;
    }

    public Map<String, Id> recordTypeIdBySupplyChainType {
        get {
            if (recordTypeIdBySupplyChainType == null) {
                Map<String, Schema.RecordTypeInfo> recordTypeIdByApiName = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
                Map<String, Id> result = new Map<String, Id>();
                for (
                    CIIS_Supply_Chain_Facility_Type_Setting__mdt scSetting : settingByLabel.values()
                ) {
                    result.put(
                        scSetting.MasterLabel,
                        recordTypeIdByApiName.get(
                                scSetting.CIIS_Record_Type_API_Name__c
                            )
                            .getRecordTypeId()
                    );
                }
                recordTypeIdBySupplyChainType = result;
            }
            return recordTypeIdBySupplyChainType;
        }
        set;
    }

    Map<String, Account> populatedAccountBySupplyChainType {
        get {
            if (populatedAccountBySupplyChainType == null) {
                Map<String, Account> result = new Map<String, Account>();
                for (
                    CIIS_Supply_Chain_Facility_Type_Setting__mdt scSetting : settingByLabel.values()
                ) {
                    if (
                        !accountTmplBySupplyChainType.containsKey(
                            scSetting.MasterLabel
                        )
                    ) {
                        continue;
                    }
                    Account acc = CIIS_SupplyChainUtils.jsonToAccount(
                        scSetting.CIIS_Default_Field_Values__c
                    );

                    // Account acc = accountTmplBySupplyChainType.get(
                    //         scSetting.MasterLabel
                    //     )
                    //     .clone(false, false, false, false);
                    acc.RecordTypeId = recordTypeIdBySupplyChainType.get(
                        scSetting.MasterLabel
                    );
                    // acc.IETRS_Business_Area__c = 'Critical Infrastructure';
                    // acc.IETRS_Status__c = 'Active';
                    result.put(scSetting.MasterLabel, acc);
                }
                populatedAccountBySupplyChainType = result;
            }
            return populatedAccountBySupplyChainType;
        }
        set;
    }

    Map<String, Map<String, String>> accountTmplBySupplyChainType = new Map<String, Map<String, String>>{
        'Control Station' => controlStation,
        'Regulator Station' => regulatorStation,
        'Meter Station' => meterStation,
        'Gas Processing Facility' => gasProcessingFacility,
        'Pipeline' => pipeline,
        'Underground Storage Facility' => undergroundStorage,
        'Power Plant' => powerPlant,
        'Off Lease Compressor' => offLeaseCompressor,
        'PL Compressor' => offLeaseCompressor,
        'Saltwater Disposal Well' => swd,
        'Producer/Lease' => lease
    };

    String orgRecordTypeId;

    /**
     * Test data factory for the supply chain functionality.
     */
    public CIIS_SupplyChainTestFactory() {
        orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Organization')
            .getRecordTypeId();
    }

    public Account getNewOrgInstance() {
        // Return instance of new org
        return new Account(
            Name = createTestName('Org'),
            IETRS_Status__c = 'Active',
            RecordTypeId = orgRecordTypeId,
            IETRS_P5_Number__c = createTestId('{NNNNNN}')
        );
    }

    public List<Account> getNewSupplyChainAccountInstances(
        String supplyChainType,
        Id orgId,
        Id recordTypeId,
        Integer count
    ) {
        List<Account> supplyChainAccs = new List<Account>();
        Account acc = populatedAccountBySupplyChainType.get(supplyChainType);
        String orgField = settingByLabel.get(supplyChainType)
            .CIIS_Operator_Relationship_Field_Name__c;
        for (Integer i = 0; i < count; i++) {
            Account supplyChainAcc = acc.clone(false, false, false, false);
            supplyChainAcc.Name = createTestName(supplyChainType);
            supplyChainAcc.CIIS_Facility_Name__c = supplyChainAcc.Name;
            if (orgField != null) {
                supplyChainAcc.put(orgField, orgId);
            }
            supplyChainAcc.ParentId = orgId;
            supplyChainAcc.recordTypeId = recordTypeId;
            // set test id values
            if (accountTmplBySupplyChainType.containsKey(supplyChainType)) {
                for (
                    String fieldName : accountTmplBySupplyChainType.get(
                            supplyChainType
                        )
                        .keySet()
                ) {
                    String fieldValueTmp = accountTmplBySupplyChainType.get(
                            supplyChainType
                        )
                        .get(fieldName);
                    acc.put(fieldName, createTestId(fieldValueTmp));
                }
            }
            supplyChainAccs.add(supplyChainAcc);
        }
        return supplyChainAccs;
    }

    private String createTestId(String idTemplate) {
        String result;
        try {
            // extract everything between curly braces and put in string var
            String replacePart = idTemplate.substring(
                idTemplate.indexOf('{') + 1,
                idTemplate.indexOf('}')
            );
            // get length of part to replace
            Integer replacePartLength = replacePart.length();
            // create random integer whose digit length is the same as replacePartLength
            Integer randomInt = Math.round(
                Math.random() * Math.pow(10, replacePartLength)
            );
            result = idTemplate.replace(
                '{' + replacePart + '}',
                String.valueOf(randomInt)
            );
        } catch (Exception e) {
            result = idTemplate;
        }
        return result;
    }

    private String createTestName(String namePrefix) {
        return namePrefix + ' ' + String.valueOf(Math.random());
    }
}