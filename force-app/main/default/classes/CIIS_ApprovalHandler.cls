global with sharing class CIIS_ApprovalHandler {
    @InvocableMethod(label='CIIS Apex Approval' description='Given an approval reuqest ID, a comment string and a approve string (Approve, Reject, or Removed), update the approval reuqest of the passed in Record Id' category='Other')
    global static List<approvalResult> CIIS_ApexApproval(List<approvalRequest> requests){
        List<approvalResult> results= new List<approvalResult>();
        System.debug('requests: '+requests);
        for(approvalRequest request : requests){
            results.add(approveRecord(request));
        }
        return results;
    }
    
    public static approvalResult approveRecord(approvalRequest request){
        System.debug('request: '+request);
        User currUser = [SELECT ID, CIIS_Bypass_Validation__c FROM USER WHERE ID=: UserInfo.getUserId()];
        currUser.CIIS_Bypass_Validation__c = true;
        Update currUser;
        List<Id> recordIds = new List<Id>();
        recordIds.add(request.recordId);
        Approval.ProcessWorkitemRequest[] approvalList = new Approval.ProcessWorkitemRequest[]{};
            approvalResult result = new approvalResult();
        for(ProcessInstanceWorkitem workitem :[
            SELECT Id, ActorId, ProcessInstance.TargetObjectId, ProcessInstance.Status
            FROM ProcessInstanceWorkitem 
            WHERE Id IN :recordIds 
            AND ActorId = :request.assignedApproverId
            AND ProcessInstance.Status = 'Pending']
           ){
               if(request.approved=='Approve'){
                   Approval.ProcessWorkitemRequest approval = new Approval.ProcessWorkitemRequest();
                   approval.setWorkItemID(workitem.Id);
                   approval.setComments(request.comments);
                   approval.setAction('Approve');
                   approvalList.add(approval);
                   System.debug('approval: '+approval);
               }else if(request.approved=='Reject'){
                   Approval.ProcessWorkitemRequest approval = new Approval.ProcessWorkitemRequest();
                   approval.setWorkItemID(workitem.Id);
                   approval.setComments(request.comments);
                   approval.setAction('Reject');
                   approvalList.add(approval);
                   System.debug('approval: '+approval);
               }else{
                   Approval.ProcessWorkitemRequest approval = new Approval.ProcessWorkitemRequest();
                   approval.setWorkItemID(workitem.Id);
                   approval.setComments(request.comments);
                   approval.setAction('Removed');
                   approvalList.add(approval);
                   System.debug('approval: '+approval);
               }
           }
        
        System.debug('approvalList: '+approvalList);
        if(!approvalList.isEmpty()){
            try{
                result.resultString  = 'The approvals have been successfully processed';
                Approval.ProcessResult[] appResult = Approval.process(approvalList);
            }catch(exception e){
                System.debug('error: '+e);
                result.resultString  = 'Error: While processing your approvals, this error was encountered: '+e.getMessage();
            }
        }
        currUser.CIIS_Bypass_Validation__c = false;
        Update currUser;
        
        System.debug('result: '+result);
        return result;
    }
  
    global class approvalRequest{
        @invocableVariable(required=true)
        global Id recordId;
        
        @invocableVariable(required=true)
        global String comments;
        
        @invocableVariable(required=true)
        global String approved;
        
        @invocableVariable(required=true)
        global Id assignedApproverId;
    }
    
    global class approvalResult{
        @InvocableVariable
        global String resultString;
    }
    
}