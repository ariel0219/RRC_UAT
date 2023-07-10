/**
 * @author Greg Lovelidge - Sense Corp
 * @date 6/1/2020
 *
 * @description Etension class for the IETRS_I_InspSchedule_To_IandIP VF Page
 */
public with sharing class IETRS_I_CreateInspScheduleExtension {
    /**
     * @description Standard Set Controller for the VF page
     */
    private ApexPages.StandardSetController ssController;

    /**
     * @description The selected schedule records with the necessary fields
     */
    public List<IETRS_InspSchedule__c> selectedRecords {
        get {
            if (this.selectedRecords == null) {
                try {
                    this.selectedRecords = [
                        SELECT
                            Id,
                            IETRS_Organization__c,
                            Unit__c,
                            IETRS_Type__c,
                        	IETRS_Inspection_Package__c,
                        	IETRS_Inspection_Date__c,
                        	IETRS_Regulated_Entity__c,
                        	IETRS_Calendar_Event_ID__c,
                        	IETRS_Inspection_End_Date__c,
                        	CIIS_CID_Region__c,
                            IETRS_Inspection_Sub_Type__c,
                            IETRS_Inspection_Business_Area__c,
                            IETRS_Regulated_Entity__r.IETRS_Unit_Parent__c,
                            IETRS_Reg_Entity_Allowed_Inspection_Type__c,
                        	Inspection_Package_Populated_Hidden__c
                        FROM IETRS_InspSchedule__c
                        WHERE Id IN :ssController.getSelected()
                    ];
                } catch (Exception e) {
                    this.selectedRecords = new List<IETRS_InspSchedule__c>();
                }
            }
            system.debug('this.selectedRecords ' + this.selectedRecords);
            return this.selectedRecords;
        }
        set;
    }

    /**
     * @description Default Controller Extension Constructor
     * @param ssController The ApexPages.StandardSetController instance
     */
    public IETRS_I_CreateInspScheduleExtension(ApexPages.StandardSetController ssController) {
        this.ssController = ssController;
    }

    /**
     * @description Get a boolean value indicating if there are selected records in state
     * @return True if there are no selected records
     */
    public Boolean getIsEmpty() {
        return ssController.getSelected() == null || ssController.getSelected().isEmpty();
    }

    /**
     * @description Get the selected inspection records as json. Used in javascript in the VF page
     * @return The selected records as a JSON strin
     */
    public String getInspectionsJson() {
        return JSON.serialize(selectedRecords);
    }

    /**
     * @description Get a boolean value indicating if the selected records are valid for creating an
     *  an inspection package
     * @return True if the records are valid.
     */
    public Boolean getIsValidSelection() {
        String combinedString;
        Boolean result = true;
        for (IETRS_InspSchedule__c is : selectedRecords) {
            if (result) {
                if (combinedString == null) {
                    // construct a string of all field values that must be the same
                    combinedString = getCombinedString(is);
                    continue;
                }
                // check for each record that all values are the same
                result = combinedString == getCombinedString(is);
            }
        }
        return result;
    }
    
    /**
     * @description Get a boolean value indicating if the selected records are valid for creating an
     *  an inspection package
     * @return True if the records are valid.
     */
    public Boolean getInspectionAlreadyExists() {
        Boolean result = false;
        for (IETRS_InspSchedule__c is : selectedRecords) {
            if (is.Inspection_Package_Populated_Hidden__c) {
                result = true;
                break;
            }
        }
        return result;
    }

    /**
     * @description Gets a concatenated string with the values from the provided Inspection Schedule record
     * @param is An Inspection Schedule record
     * @return A concatenated string
     */
    private String getCombinedString(IETRS_InspSchedule__c is) {
        return is.IETRS_Organization__c +
            is.Unit__c +
            is.IETRS_Type__c +
            is.IETRS_Inspection_Sub_Type__c +
            is.IETRS_Inspection_Business_Area__c +
            is.IETRS_Reg_Entity_Allowed_Inspection_Type__c;
    }
}