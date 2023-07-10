/**
 * @author Sebastian Wittenstein
 * @date 6/17/2021
 *
 * @description Service class for Inspections
 */
public with sharing class IETRS_InspPkgReadinessValidation {
    /**
     * Class Properties
     */

    /**
     * Template string used to generate dynamic error messages
     */
    final public static String ERROR_TMPL = 'Inspection doesn\'t have required {0} record(s)\n';

    /**
     * Map of the relationship api names of required related records grouped by inspection record type name
     */
    final public static Map<String, List<String>> REQUIRED_RELATED_RECORDS_BY_TYPE = new Map<String, List<String>>{
        'PS Inspection - Distribution Systems' => new List<String>{
            'Miles_of_Pipe_by_Size__r',
            'Lost_and_Unaccountable_Gas__r',
            'MAOP__r',
            'Number_of_Services_by_Size__r',
            'OPP_Codes__r',
            'Repaired_Leaks__r',
            'Suppliers__r'
        },
        'PS Inspection - Gas Transmission Systems' => new List<String>{
            'Miles_of_Pipe_by_Size_Gas_Liq__r',
            'MAOP__r',
            'Pipes_by_Class__r',
            'OPP_Codes__r'
        },
        'PS Inspection - LNG Systems' => new List<String>{
            'Miles_of_Pipe_by_Size_Gas_Liq__r',
            'MAOP__r',
            'Pipes_by_Class__r',
            'OPP_Codes__r'
        },
        'PS Inspection - Hazardous Liquid Systems' => new List<String>{
            'Miles_of_Pipe_by_Size_Gas_Liq__r',
            'MAOP__r',
            'Pipes_by_Class_Haz_Liq__r',
            'OPP_Codes__r'
        },
        'PS Inspection - Master Meter Systems' => new List<String>{
            'Miles_of_Pipe_by_Size_MM__r',
            'MAOP__r',
            'OPP_Codes__r',
            'Suppliers__r'
        },
        'PS Inspection - UNGS Systems' => new List<String>{
            'Reservoirs_and_Wells__r'
        }
    };

    /**
     * Class Methods
     */

    /**
     * @description Reviews an inspection package for readiness to be submitted
     * @param List<Id> of the inspection package(s) to review
     * @return List<String> of all inspection names & related regulated entities that are incomplete, along with what the inspection is missing
     */
    @InvocableMethod(
        label='Inspection Package Readiness Validation'
        description='Given an inspection package Id finds all inspections and grandchild records and ensures they are complete'
    )
    public static List<String> IETRS_InspPkgReadinessValidation(
        List<Id> inspectionPackageId
    ) {
        //map to hold repsonses for each package
        Map<Id, String> responseMap = new Map<Id, String>();
        //list to hold all child inspection records
        List<IETRS_Inspection__c> isnpList = new List<IETRS_Inspection__c>();
        List<IETRS_Inspection_Package__c> iplist = new List<IETRS_Inspection_Package__c>();
        //populate inspection record list, inclulding with child records
        isnpList = [
            SELECT
                Id,
                Name,
                IETRS_Regulated_Entity_Name__c,
                RecordType.Name,
                IETRS_Inspection_Package__c,
                IETRS_Inspection_Package__r.Name,
                (SELECT Id FROM MAOP__r LIMIT 1),
                (SELECT Id FROM OPP_Codes__r LIMIT 1),
                (SELECT Id FROM Lost_and_Unaccountable_Gas__r LIMIT 1),
                (SELECT Id FROM Number_of_Services_by_Size__r LIMIT 1),
                (SELECT Id FROM Repaired_Leaks__r LIMIT 1),
                (SELECT Id FROM Repaired_Leaks_Gas_Liq__r LIMIT 1),
                (SELECT Id FROM Suppliers__r LIMIT 1),
                (SELECT Id FROM Miles_of_Pipe_by_Size__r LIMIT 1),
                (SELECT Id FROM Miles_of_Pipe_by_Size_Gas_Liq__r LIMIT 1),
                (SELECT Id FROM Miles_of_Pipe_by_Size_MM__r LIMIT 1),
                (SELECT Id FROM Pipes_by_Class__r LIMIT 1),
                (SELECT Id FROM Pipes_by_Class_Haz_Liq__r LIMIT 1),
                (SELECT Id FROM Reservoirs_and_Wells__r LIMIT 1),
                (SELECT Id, IETRS_Violation_Type__c, Name FROM Violations__r)
            FROM IETRS_Inspection__c
            WHERE IETRS_Inspection_Package__c IN :inspectionPackageId
        ];

        iplist = [
            SELECT Id, Name, IETRS_Num_Inspections__c
            FROM IETRS_Inspection_Package__c
            WHERE Id IN :inspectionPackageId
        ];

        //check if inspections empty
        for (IETRS_Inspection_Package__c ip : iplist) {
            if (ip.IETRS_Num_Inspections__c == 0) {
                String errormessage;
                errormessage = 'No inspections found for inspection package';
                responseMap.put(ip.Id, errormessage);
            }
        }

        //cycle through each inspection
        for (IETRS_Inspection__c i : isnpList) {
            // collect errors
            String errors = ViolationHelper(i);
            errors += getValidationErrors(i);
            // continue to next item if no errors were found
            if (String.isBlank(errors)) {
                continue;
            }
            // add errors to the response map
            if (!responseMap.containsKey(i.IETRS_Inspection_Package__c)) {
                responseMap.put(
                    i.IETRS_Inspection_Package__c,
                    i.Name +
                    ' - ' +
                    i.IETRS_Regulated_Entity_Name__c +
                    ': ' +
                    i.RecordType.Name +
                    '\n'
                );
            }
            responseMap.put(
                i.IETRS_Inspection_Package__c,
                responseMap.get(i.IETRS_Inspection_Package__c) + errors
            );
        }
        return responseMap.values();
    }

    /**
     * Get validation errors from the inspection given the record type and require records
     * @param IETRS_Inspection__c Inspection record to validate
     * @return String of concatenated errors associated with the inspection
     */
    private static String getValidationErrors(IETRS_Inspection__c inspection) {
        String result = '';
        // exit early if the record type isn't mapped
        if (
            !REQUIRED_RELATED_RECORDS_BY_TYPE.containsKey(
                inspection.RecordType.Name
            )
        ) {
            return result;
        }

        // check each required related list
        for (
            String relatedRecordsName : REQUIRED_RELATED_RECORDS_BY_TYPE.get(
                inspection.RecordType.Name
            )
        ) {
            List<SObject> relatedRecords = (List<SObject>) inspection.getSObjects(
                relatedRecordsName
            );
            if (relatedRecords == null || relatedRecords.isEmpty()) {
                String recordsLabel = relatedRecordsName.remove('__r')
                    .replace('_', ' ');
                result += String.format(
                    ERROR_TMPL,
                    new List<Object>{ recordsLabel }
                );
            }
        }
        return result;
    }

    /**
     * Check if the related violation records on the inspection are valid
     * @param IETRS_Inspection__c Inspection record to validate
     * @return String of concatenated errors associated with the inspection
     */
    public static String ViolationHelper(IETRS_Inspection__c i) {
        String insLacks = '';

        for (IETRS_Violation__c v : i.Violations__r) {
            if (
                v.IETRS_Violation_Type__c == 'Federal - Gas vs Liquid Unknown'
            ) {
                insLacks +=
                    'Violation ' +
                    v.Name +
                    ' is of Type \'Federal - Gas vs Liquid Unkown\'. Please specify the Violation Type as Gas or Liquid before resubmitting.\n';
            }
        }
        return insLacks;
    }
}