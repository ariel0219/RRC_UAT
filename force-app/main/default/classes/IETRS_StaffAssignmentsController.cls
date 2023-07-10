/**
 * @File Name          : IETRS_StaffAssignmentsController.cls
 * @Description        : Controller used to get Staff Assignments related to a Case ID and sort by an Administrator defined sequence
 * @Author             : Forrest Chang
 * @Group              : 
 * @Last Modified By   : Forest Chang
 * @Last Modified On   : 10/28/2019
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    10/28/2019               Forrest Chang              Initial Version
**/
public with sharing class IETRS_StaffAssignmentsController {

    //Method called by component on Case record page to return sorted list of related Staff Assignements
    @AuraEnabled(Cacheable=true)
    public static IETRS_Case_Staff_Assignment__c[] getRelatedStaffAssignments(String caseId, String strSortOrder, Boolean blnHearings) {
        String strDynamicQuery = 'SELECT Id, Name,  IETRS_Staff_Name_form__c, IETRS_Staff_Id_form__c, IETRS_Assignment_Start_Date__c, IETRS_Role__c, IETRS_Lead__c, IETRS_First_Second_Chair__c FROM IETRS_Case_Staff_Assignment__c WHERE IETRS_Case__c = :caseId AND IETRS_Currently_Assigned__c = true';

        //If this method is being called by the Hearings version of this component, only return Hearings Record Type and vice versa
        String strHearingsRecTypeId = Schema.Sobjecttype.IETRS_Case_Staff_Assignment__c.getRecordTypeInfosByDeveloperName().get('Hearings').getRecordTypeId();
        strDynamicQuery = blnHearings ? strDynamicQuery + ' AND RecordTypeId =  :strHearingsRecTypeId' : strDynamicQuery + ' AND RecordTypeId != :strHearingsRecTypeId';
        
        strDynamicQuery = strDynamicQuery + ' ORDER BY IETRS_Role__c, IETRS_Lead__c DESC';
        system.debug(strDynamicQuery);
        strDynamicQuery = String.escapeSingleQuotes(strDynamicQuery);
        
        List<IETRS_Case_Staff_Assignment__c > lstStaffAssignments = Database.query(strDynamicQuery);
        
        List<String> lstSortOrder = strSortOrder.split(';');
        //If only one result is returned do not sort, else call bubble sort method        
        return lstStaffAssignments.size() <= 1 && lstSortOrder.size() <= 1 ? lstStaffAssignments : sortListByArray(lstStaffAssignments, lstSortOrder);
    }


    //Method used to reorder the returned list of Staff Assignments
    @AuraEnabled(Cacheable=true)
    public static List<IETRS_Case_Staff_Assignment__c> sortListByArray(List<IETRS_Case_Staff_Assignment__c> lstStaffAssignments, List<String> lstSortOrder){
        //List size used for iterators in the loops
        Integer intListSize = lstStaffAssignments.size();
        //List of boolean values assigning true to index 0 and false to 1. Used to order the IETRS_Lead__c field
        List<Boolean> lstBlnOrder = new List<Boolean>{true, false};

        //List of all possible Picklist values in case the Administrator misspelled or omitted a value from the sort order
        List<String> lstRolePickVals = getPickListValuesIntoList('IETRS_Role__c');
        //Check the Administrator defined Sort Order list for missing picklist values and apend them to the end
        //Without this missing values would be moved to the top of the final sort order
        for(String pickVal : lstRolePickVals){
            if(lstSortOrder.indexOf(pickVal) == -1){
                lstSortOrder.add(pickVal);
            }
        }
        
        //List of Picklist Values ordered as defined in the org
        List<String> lstChairPickVals = getPickListValuesIntoList('IETRS_First_Second_Chair__c');
        //Add null to the last position to ensure null values are last, not first
        lstChairPickVals.add(null);

        //Temporary swap variable
        IETRS_Case_Staff_Assignment__c tempStaffAssignment = new IETRS_Case_Staff_Assignment__c();

        //Bubble sort to reorder the list
        for(integer i=0; i < intListSize; i++){
            for(integer j=1; j < (intListSize-i); j++){
                // Bubble Sort ORDER BY: 1. Chair Order   2. Lead   3. Role Sort Order 
                //Swap the two elements if any of the following is true (OR):
                //1. The index of the Chair Order List for the current iterator is LOWER sequentially (higher in sort order) than the previous iterator's index
                //2. The index of the Chair Order List for the current iterator is EQUAL to the previous iterator's index 
                //      AND the index of the Boolean Order List for the current iterator is LOWER Sequentially (higher in sort order) than the previous iterator's index
                //3. The index of the Chair Order List for the current iterator is Equal to the previous iterator's index 
                //      AND the index of the Boolean Order List for the current iterator is EQUAL to the previous iterator's index
                //      AND the index of the Role Order List for the current iterator is LOWER sequentially (higher in sort order) than the previous iterator's index.
                if(
                    lstChairPickVals.indexOf(lstStaffAssignments[j-1].IETRS_First_Second_Chair__c) > lstChairPickVals.indexOf(lstStaffAssignments[j].IETRS_First_Second_Chair__c) 
                    ||
                    lstChairPickVals.indexOf(lstStaffAssignments[j-1].IETRS_First_Second_Chair__c) == lstChairPickVals.indexOf(lstStaffAssignments[j].IETRS_First_Second_Chair__c) 
                        && lstBlnOrder.indexOf(lstStaffAssignments[j-1].IETRS_Lead__c) > lstBlnOrder.indexOf(lstStaffAssignments[j].IETRS_Lead__c) 
                    ||
                    lstChairPickVals.indexOf(lstStaffAssignments[j-1].IETRS_First_Second_Chair__c) == lstChairPickVals.indexOf(lstStaffAssignments[j].IETRS_First_Second_Chair__c)
                        && lstBlnOrder.indexOf(lstStaffAssignments[j-1].IETRS_Lead__c) == lstBlnOrder.indexOf(lstStaffAssignments[j].IETRS_Lead__c)
                            && lstSortOrder.indexOf(lstStaffAssignments[j-1].IETRS_Role__c) > lstSortOrder.indexOf(lstStaffAssignments[j].IETRS_Role__c)
){
                    //     if((lstSortOrder.indexOf(lstStaffAssignments[j-1].IETRS_Role__c) > lstSortOrder.indexOf(lstStaffAssignments[j].IETRS_Role__c)) ||
                    //     (lstSortOrder.indexOf(lstStaffAssignments[j-1].IETRS_Role__c) == lstSortOrder.indexOf(lstStaffAssignments[j].IETRS_Role__c) 
                    //     && lstBlnOrder.indexOf(lstStaffAssignments[j-1].IETRS_Lead__c) > lstBlnOrder.indexOf(lstStaffAssignments[j].IETRS_Lead__c))){
                        //Swap the two compared records within the list
                        tempStaffAssignment = lstStaffAssignments[j-1];
                        lstStaffAssignments[j-1] = lstStaffAssignments[j];
                        lstStaffAssignments[j] = tempStaffAssignment;
                }
            }
        }
        return lstStaffAssignments;
    }


    //Utility Method to get the picklist values of IETRS_Role__c
    @AuraEnabled(Cacheable=true)
    public static List<String> getPickListValuesIntoList(String strField){
        List<String> lstPickValues= new List<String>();
        Schema.DescribeFieldResult fieldResult = IETRS_Case_Staff_Assignment__c.getSObjectType().getDescribe().fields.getMap().get(strField).getDescribe();
        //Schema.DescribeFieldResult fieldResult = IETRS_Case_Staff_Assignment__c.IETRS_Role__c.getDescribe();
        List<Schema.PicklistEntry> pickEntry = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pickEntry){
            lstPickValues.add(pickListVal.getLabel());
        }     
        return lstPickValues;
    }


}