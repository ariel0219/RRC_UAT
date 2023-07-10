/**
 * @File Name          : IETRS_CaseTriggerHandler.class
 * @Description        : 
 * @Author             : Ronald Stewart
 * @Group              : 
 * @Last Modified By   : Ronald Stewart
 * @Last Modified On   : 10/15/2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0        10/15/2020               Ronald Stewart             Initial Version
**/
public class IETRS_CaseTriggerHandler {
    public static void doesParentCaseHaveChildren(List<Case> newList, List<Case> oldList){
        // Create mapping of old case records and new case records
        Map<string,Case> newCaseMap = new Map<string,Case>();
        Map<string,Case> oldCaseMap = new Map<string,Case>();
        for(Case newCase: newList){
            newCaseMap.put(newCase.id,newCase);
        }
        for(Case oldCase: oldList){
            oldCaseMap.put(oldCase.id,oldCase);
        }
        //Use to store the parent ids on the case parent case field
        List<string> parentCaseIds = new List<string>();
        
        //Loop through the new case records
        for(Case item: newList){
            //Check if Parent Case field is empty and doesn't equal to old value
            if(newCaseMap.get(item.id).ParentId==Null 
              && newCaseMap.get(item.id).ParentId!=oldCaseMap.get(item.id).ParentId){
                parentCaseIds.add(oldCaseMap.get(item.id).ParentId);
            }
        }
        
        if(parentCaseIds.size()>0){
            List<Case> childCases = [Select id, parentid 
                                     from case where parentid =: parentCaseIds[0]];
            //There should be one remaining child record before saving the record
            if(childCases.size()==1){                
                Case parentCase = [select id, IETRS_Is_Parent_Case__c 
                                         from case where id =: parentCaseIds[0]];
                parentCase.IETRS_Is_Parent_Case__c = false;
                update parentCase;
            }
        }
        
    }
}