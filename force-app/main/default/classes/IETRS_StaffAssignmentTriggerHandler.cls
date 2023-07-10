public class IETRS_StaffAssignmentTriggerHandler{
    public static void checkFirstChairAvailibilityforInsert(List<IETRS_Case_Staff_Assignment__c> newList, List<IETRS_Case_Staff_Assignment__c> oldList){
        String strFirstChair = 'First Chair';
        Set<Id> setCaseIds = new Set<Id>();
        for(IETRS_Case_Staff_Assignment__c objStaffAssign: newList){
            if(objStaffAssign.IETRS_First_Second_Chair__c == strFirstChair){
                setCaseIds.add(objStaffAssign.IETRS_Case__c);
            }
        }
      
        if(!setCaseIds.isEmpty()){
            checkAvailibilityofFirstStaff(setCaseIds,newList,strFirstChair);
        }
    }
    
    public static void checkFirstChairAvailibilityforUpdate(List<IETRS_Case_Staff_Assignment__c> newList, List<IETRS_Case_Staff_Assignment__c> oldList, Map<Id,IETRS_Case_Staff_Assignment__c> newMap, Map<Id,IETRS_Case_Staff_Assignment__c> oldMap){
        String strFirstChair = 'First Chair';
        Set<Id> setCaseIds = new Set<Id>();
        for(IETRS_Case_Staff_Assignment__c objStaffAssign: newList){
            if(objStaffAssign.IETRS_First_Second_Chair__c == strFirstChair && newMap.get(objStaffAssign.Id).IETRS_First_Second_Chair__c != oldMap.get(objStaffAssign.Id).IETRS_First_Second_Chair__c){
                setCaseIds.add(objStaffAssign.IETRS_Case__c);
            }
        }
      
        if(!setCaseIds.isEmpty()){
            checkAvailibilityofFirstStaff(setCaseIds,newList,strFirstChair);
        }
    }
    
    public static void checkAvailibilityofFirstStaff(Set<Id> setCaseIds, List<IETRS_Case_Staff_Assignment__c> newList, String strFirstChair){
        Set<Id> setCaseswithFirstChair = new Set<Id>();
        List<IETRS_Case_Staff_Assignment__c> lstStaffAssignments = new List<IETRS_Case_Staff_Assignment__c>([Select Id,IETRS_Case__c from IETRS_Case_Staff_Assignment__c where IETRS_Case__c IN: setCaseIds and IETRS_First_Second_Chair__c =: strFirstChair]);
        if(!lstStaffAssignments.isEmpty()){
            for(IETRS_Case_Staff_Assignment__c objStaffAssignment: lstStaffAssignments){
                setCaseswithFirstChair.add(objStaffAssignment.IETRS_Case__c);
            }
            for(IETRS_Case_Staff_Assignment__c objNewStaffAssign : newList){
                if(setCaseswithFirstChair.contains(objNewStaffAssign.IETRS_Case__c)){
                    objNewStaffAssign.addError('First chair already assigned');
                }
            }
        }
    }
}