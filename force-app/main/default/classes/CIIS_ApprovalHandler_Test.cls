@IsTest
public class CIIS_ApprovalHandler_Test {
    @TestSetup
    static void makeData() {
        User runningUser = [
            SELECT
                Id,
                TimeZoneSidKey,
                LocaleSidKey,
                EmailEncodingKey,
                LanguageLocaleKey,
                ProfileId
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
        //get a inspection package record type
        RecordType ipRT = new RecordType();
        ipRT = [
            SELECT Id
            FROM RecordType
            WHERE
                SobjectType = 'IETRS_Inspection_Package__c'
                AND DeveloperName = 'CIIS_Inspection_Package_Critical_Infrastructure'
            LIMIT 1
        ][0];

        //get the account record types for Org, Unit, and RE
        RecordType accOrgRT = new RecordType();
        accOrgRT = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Account' AND DeveloperName = 'Organization'
            LIMIT 1
        ][0];
        RecordType accUnitRT = new RecordType();
        accUnitRT = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Account' AND DeveloperName = 'Unit'
            LIMIT 1
        ][0];
        RecordType accRERT = new RecordType();
        accRERT = [
            SELECT Id
            FROM RecordType
            WHERE
                SobjectType = 'Account'
                AND DeveloperName = 'Regulated_Entity_AFS'
            LIMIT 1
        ][0];

        User regionalManager = getApprover();
        User submitterUser = getApprovalSubmitter();
        insert regionalManager;
        submitterUser.ManagerId = regionalManager.Id;
        System.runAs(runningUser) {
            //create set of parent accounts
            Account org = new Account(
                Name = 'Test Org',
                RecordTypeId = accOrgRT.Id
            );
            insert org;
            Account unit = new Account(
                Name = 'Test Unit',
                RecordTypeId = accUnitRT.Id,
                ParentId = org.Id,
                IETRS_Organization_Parent__c = org.Id
            );
            insert unit;

            //create an inspection package record
            IETRS_Inspection_Package__c ip = new IETRS_Inspection_Package__c(
                IETRS_Status__c = 'Work in Progress',
                IETRS_Organization__c = org.Id,
                IETRS_Unit_Name__c = unit.Id,
                RecordTypeId = ipRT.Id,
                IETRS_Region_Lead__c = regionalManager.Id,
                IETRS_Regional_Manager__c = regionalManager.Id,
                IETRS_Business_Area__c = 'Critical Infrastructure'
            );
            insert ip;

            System.debug(submitterUser.Name);
            //submit the record to the approval process
            Approval.ProcessSubmitRequest reqIP = new Approval.ProcessSubmitRequest();
            reqIP.setComments('Submitting request for approval.');
            reqIP.setObjectId(ip.id);
            reqIP.setSubmitterId(submitterUser.Id);
            reqIP.setSkipEntryCriteria(true);
            reqIP.setNextApproverIds(new List<Id>{ regionalManager.Id });

            System.runAs(regionalManager) {
                Approval.ProcessResult result = Approval.process(reqIP);
                System.debug(result);
            }

            //reasign the approval record to the running user
            List<ProcessInstanceWorkitem> piWorkItemsUpdate = new List<ProcessInstanceWorkitem>();
            List<ProcessInstanceWorkitem> piWorkItems = [
                SELECT
                    Id,
                    ActorId,
                    OriginalActorId,
                    ProcessInstance.TargetObjectId
                FROM ProcessInstanceWorkitem
            ];
            for (ProcessInstanceWorkitem piWorkItem : piWorkItems) {
                piWorkItem.ActorId = runningUser.Id;
                piWorkItem.OriginalActorId = runningUser.Id;
                piWorkItemsUpdate.add(piWorkItem);
            }
            if (!piWorkItemsUpdate.isEmpty()) {
                Database.SaveResult[] updateResults = Database.update(
                    piWorkItemsUpdate,
                    false
                );
            }
        }
    }

    @IsTest
    static void itshouldapprove() {
        Test.startTest();
        //get running user
        User runningUser = [
            SELECT Id
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
        System.debug('runningUser: ' + runningUser);

        //get pending approval
        ProcessInstanceWorkitem pawi = new ProcessInstanceWorkitem();
        pawi = [
            SELECT
                Id,
                ActorId,
                ProcessInstance.TargetObjectId,
                ProcessInstance.Status
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.Status = 'Pending'
            LIMIT 1
        ][0];
        System.debug('ProcessInstanceWorkitem: ' + pawi);

        //generate the approval process requests wrapper
        List<CIIS_ApprovalHandler.approvalRequest> paRequestList = new List<CIIS_ApprovalHandler.approvalRequest>();
        CIIS_ApprovalHandler.approvalRequest paRequest = new CIIS_ApprovalHandler.approvalRequest();
        Id recordId = pawi.Id;
        paRequest.recordId = recordId;
        String comments = 'test';
        paRequest.comments = comments;
        Id assignedApproverId = runningUser.Id;
        paRequest.assignedApproverId = assignedApproverId;
        string approved = 'Approve';
        paRequest.approved = approved;
        System.debug('paRequest: ' + paRequest);
        paRequestList.add(paRequest);

        //generate the wrappers to hold responses
        List<CIIS_ApprovalHandler.approvalResult> paResultList = new List<CIIS_ApprovalHandler.approvalResult>();

        //submit the approval record
        paResultList = CIIS_ApprovalHandler.CIIS_ApexApproval(paRequestList);

        Test.stopTest();
    }
    
  	@isTest static void getApprovalHistoryTest(){
        List<IETRS_Inspection_Package__c> ip = [SELECT Id FROM IETRS_Inspection_Package__c LIMIT 1];
        ApprovalHistoryController.getApprovalHistory(ip.get(0).Id, '6');
    }
   
    @IsTest
    static void itshouldreject() {
        Test.startTest();
        //get running user
        User runningUser = [
            SELECT Id
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
        System.debug('runningUser: ' + runningUser);

        //get pending approval
        ProcessInstanceWorkitem pawi = new ProcessInstanceWorkitem();
        pawi = [
            SELECT
                Id,
                ActorId,
                ProcessInstance.TargetObjectId,
                ProcessInstance.Status
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.Status = 'Pending'
            LIMIT 1
        ][0];
        System.debug('ProcessInstanceWorkitem: ' + pawi);

        //generate the approval process requests wrapper
        List<CIIS_ApprovalHandler.approvalRequest> paRequestList = new List<CIIS_ApprovalHandler.approvalRequest>();
        CIIS_ApprovalHandler.approvalRequest paRequest = new CIIS_ApprovalHandler.approvalRequest();
        Id recordId = pawi.Id;
        paRequest.recordId = recordId;
        String comments = 'test';
        paRequest.comments = comments;
        Id assignedApproverId = runningUser.Id;
        paRequest.assignedApproverId = assignedApproverId;
        string approved = 'Reject';
        paRequest.approved = approved;
        System.debug('paRequest: ' + paRequest);
        paRequestList.add(paRequest);

        //generate the wrappers to hold responses
        List<CIIS_ApprovalHandler.approvalResult> paResultList = new List<CIIS_ApprovalHandler.approvalResult>();

        //submit the approval record
        paResultList = CIIS_ApprovalHandler.CIIS_ApexApproval(paRequestList);

        Test.stopTest();
    }

    @IsTest
    static void itshouldrecall() {
        Test.startTest();
        //get running user
        User runningUser = [
            SELECT Id
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
        System.debug('runningUser: ' + runningUser);

        //get pending approval
        ProcessInstanceWorkitem pawi = new ProcessInstanceWorkitem();
        pawi = [
            SELECT
                Id,
                ActorId,
                ProcessInstance.TargetObjectId,
                ProcessInstance.Status
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.Status = 'Pending'
            LIMIT 1
        ][0];
        System.debug('ProcessInstanceWorkitem: ' + pawi);

        //generate the approval process requests wrapper
        List<CIIS_ApprovalHandler.approvalRequest> paRequestList = new List<CIIS_ApprovalHandler.approvalRequest>();
        CIIS_ApprovalHandler.approvalRequest paRequest = new CIIS_ApprovalHandler.approvalRequest();
        Id recordId = pawi.Id;
        paRequest.recordId = recordId;
        String comments = 'test';
        paRequest.comments = comments;
        Id assignedApproverId = runningUser.Id;
        paRequest.assignedApproverId = assignedApproverId;
        string approved = 'Removed';
        paRequest.approved = approved;
        System.debug('paRequest: ' + paRequest);
        paRequestList.add(paRequest);

        //generate the wrappers to hold responses
        List<CIIS_ApprovalHandler.approvalResult> paResultList = new List<CIIS_ApprovalHandler.approvalResult>();

        //submit the approval record
        paResultList = CIIS_ApprovalHandler.CIIS_ApexApproval(paRequestList);

        Test.stopTest();
    }

    private static User getApprovalSubmitter() {
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'CIIS - Inspector'
            LIMIT 1
        ];
         UserRole r = [
            SELECT Id
            FROM UserRole
            WHERE
                DeveloperName = 'CIIS_Inspection_Inspector'
            LIMIT 1
        ];
        User u = getGenericUser();
        u.ProfileId = p.Id;
        return u;
    }

    private static User getApprover() {
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'CIIS - Lead Inspector_Engineering Specialist'
            LIMIT 1
        ];
        UserRole r = [
            SELECT Id
            FROM UserRole
            WHERE
                DeveloperName = 'CIIS_Inspection_Lead_Inspector_Engineering_Specialist'
            LIMIT 1
        ];
        User u = getGenericUser();
        u.ProfileId = p.Id;
        u.UserRoleId = r.Id;
        return u;
    }

    private static User getGenericUser() {
        String uniqueUserName =
            'uniqueuser' +
            DateTime.now().getTime() +
            '@rrc.gov';
        return new User(
            Alias = 'standt',
            Email = uniqueUserName,
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago',
            UserName = uniqueUserName
        );
    }
}