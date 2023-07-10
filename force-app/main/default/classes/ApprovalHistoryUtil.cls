public with sharing class ApprovalHistoryUtil {
    public static final String STATUS_SUBMITTED = 'Submitted';
    public static final String STATUS_STARTED = 'Started';
    public static final String STATUS_PENDING = 'Pending';
    public static final String STATUS_RECALLED = 'Recalled';
    public static final String STATUS_REMOVED = 'Removed';
 
    public static final Id currentUserId = UserInfo.getUserId();

    public final static Integer MAX_RESULTS = 5;

    public static ApprovalHistoryController.ApprovalHistory populateApprovalHistorySteps(List<ProcessInstance> processInstances, String recordId, String noOfRecords){
        List<ApprovalHistoryController.ApprovalHistoryStep> steps = new List<ApprovalHistoryController.ApprovalHistoryStep>();
        
        //Iterating through processInstance records to build the approval history steps
        Integer currNumberOfSteps = 0;
        boolean isCurrentUserApprover = false;
        boolean isSubmitForApproval = true;
        boolean showRecall = false ;  
        boolean moreThan6Steps = false;

        ApprovalHistoryController.ApprovalHistory approvalHistoryToReturn = new ApprovalHistoryController.ApprovalHistory(steps,isCurrentUserApprover, isSubmitForApproval, showRecall);

        for(ProcessInstance pr :  processInstances){
            if(moreThan6Steps){
                break;
            }
            system.debug('noOfRecords ' + noOfRecords);
            for(ProcessInstanceHistory step : pr.StepsAndWorkitems){
                if(noOfRecords == '6'){
                    currNumberOfSteps ++;    
                    if(currNumberOfSteps > 6){
                        moreThan6Steps = true;
                        break;
                    }
                }

                steps.add(new ApprovalHistoryController.ApprovalHistoryStep( step.ProcessNode.Name == null ? pr.ProcessDefinition.Name  : step.ProcessNode.Name,step.Id, step.CreatedDate,  step.StepStatus, step.Actor.Name,step.Actor.Id, step.Comments));
            }
        } 

        approvalHistoryToReturn.approvalStepsSize = moreThan6Steps ? '6+' : string.valueOf(approvalHistoryToReturn.approvalSteps.size());
        return approvalHistoryToReturn;

    } 
}