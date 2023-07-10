/*
-----------------------------------------------------------------------------------------------------
INSTRUCTIONS:
As anonymous apex copy and paste the following text into the Developer console window:

IETRS_ViolationRemark_Batch violationRemarkBatch = new IETRS_ViolationRemark_Batch();
ID jobID = Database.executeBatch(violationRemarkBatch, 1000);
system.debug(jobID);

Then click execute.

To monitor use the folling SOQL:
SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID = <jobID>
-----------------------------------------------------------------------------------------------------
*/

global class IETRS_ViolationRemark_Batch implements Database.Batchable<SObject>{
    global String errors;
    
    public IETRS_ViolationRemark_Batch() {
        system.debug('IETRS_ViolationRemark_Batch Constructor');
        errors = '';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strViolationQuery =	'SELECT Id, (SELECT IETRS_Comment_Type__c, IETRS_Comment_Type_Other__c, IETRS_Violation_Location__c, IETRS_Remark_Content__c FROM Remarks_Violation__r), ' +
            					   	'IETRS_Comment_Type_Other__c, IETRS_Violation_Location__c, IETRS_Comments__c '+
            					   	'FROM IETRS_Violation__c ' +
            					   	'WHERE Id IN (SELECT IETRS_Violation__c FROM IETRS_Remark__c) ' +
            						'AND IETRS_Comment_Type__c = null';
        return Database.getQueryLocator(strViolationQuery);
    }

    global void execute(Database.BatchableContext bc, List<SObject> records) {

        List<IETRS_Violation__c> lstViolations = records;
        
        try {
            for (IETRS_Violation__c v : lstViolations){
                String strCommentTypeOther = '';
                String strViolLocation = '';
                String strContent = '';
                String strCommentType = '';
                for (IETRS_Remark__c r : v.Remarks_Violation__r){
                    //Build aggregate strings for violation from remark iterations.
                    strCommentTypeOther = strCommentTypeOther == '' || strCommentTypeOther == r.IETRS_Comment_Type_Other__c ? r.IETRS_Comment_Type_Other__c : strCommentTypeOther + ' | ' + r.IETRS_Comment_Type_Other__c;
                    strViolLocation = (strViolLocation == '') || (strViolLocation == v.IETRS_Violation_Location__c) || (strViolLocation == r.IETRS_Violation_Location__c) ? r.IETRS_Violation_Location__c : strViolLocation + ' | ' + r.IETRS_Violation_Location__c;
                    strContent = strContent == '' ? r.IETRS_Remark_Content__c : strContent + ' | ' + r.IETRS_Remark_Content__c;
                    strCommentType = strCommentType == '' || (strCommentType == 'Other' && r.IETRS_Comment_Type__c != 'Other') ? r.IETRS_Comment_Type__c : strCommentType;
                }
            
                v.IETRS_Comment_Type_Other__c = strCommentTypeOther;
                v.IETRS_Violation_Location__c = strViolLocation;
                v.IETRS_Comments__c = strContent;
                v.IETRS_Comment_Type__c = strCommentType;
            }
            update lstViolations;

        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage() + ' @ ' + ex.getLineNumber());
            errors += 'Error: ' + ex.getMessage() + '\n';
        }
    }

    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];
        System.debug(job);
        System.debug(errors);
    }

}