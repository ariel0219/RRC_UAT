public with sharing class ApprovalHistoryController {


    @AuraEnabled (cacheable=true)
    public static ApprovalHistory getApprovalHistory(String recordId, String noOfRecords){  
                          
        List<ProcessInstance> processInstances = [SELECT Id,SubmittedById, ProcessDefinition.Name , (SELECT ID, ProcessNodeId,  
                                                            StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending  
                                                            ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name,  
                                                            OriginalActor.Name , ProcessNode.Name FROM StepsAndWorkitems order by IsPending DESC, CreatedDate DESC )   
                                                    FROM ProcessInstance where TargetObjectId =:recordId order by CreatedDate DESC];                                                                         
  
        return ApprovalHistoryUtil.populateApprovalHistorySteps(processInstances, recordId, noOfRecords);                                                 
                                                                            
    }  

    public class ApprovalHistoryStep{
        @AuraEnabled  
        public String stepName {get;set;}  
        @AuraEnabled  
        public String stepUrl {get;set;}
        @AuraEnabled  
        public DateTime createdDate {get;set;}   
        @AuraEnabled  
        public String stepStatus {get;set;}  
        @AuraEnabled  
        public String assignedTo {get;set;}   
        @AuraEnabled  
        public String assignedToUrl {get;set;}
        @AuraEnabled
        public String comments {get;set;}
        
        public ApprovalHistoryStep(
            String stepName,
            String stepId,
            DateTime createdDate, 
            String stepStatus,
            String assignedTo,
            String assignedToId,
            String comments )  
        { 
            this.stepName = stepName;
            this.stepUrl = '/' + stepId;
            this.createdDate = createdDate;
            this.assignedTo = assignedTo;  
            this.stepStatus = stepStatus;
            this.assignedToUrl = '/'+assignedToId;
            this.comments = comments;
        } 
    }

   public class ApprovalHistory{
        @AuraEnabled
        public List<ApprovalHistoryStep> approvalSteps;
        @AuraEnabled
        public String approvalStepsSize;
        @AuraEnabled 
        public boolean isCurrentUserApprover; 
        @AuraEnabled 
        public boolean showRecall;  //Modify All Data" permission or "Modify All" on the object level
                                    // system admin and submitter(if it says so on the approval process)
                                        //SELECT Name FROM Profile WHERE PermissionsModifyAllData = true
                                    //query permission sets with modify all or modify all for object and see if curr user has them

        @AuraEnabled 
        public boolean showSubmitForApproval; 
        public ApprovalHistory(List<ApprovalHistoryStep> approvalSteps, boolean isCurrentUserApprover, boolean isSubmitForApproval, boolean showRecall){
            this.approvalSteps = approvalSteps;
            this.isCurrentUserApprover = isCurrentUserApprover; 
            //this.approvalStepsSize = moreThan6Steps ? '6+' : string.valueOf(approvalSteps.size());
            this.showSubmitForApproval = isSubmitForApproval;
            this.showRecall = showRecall;
        }
    }


}