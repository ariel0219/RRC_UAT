/**
 * @File Name          : IETRS_InspApprovalsBatch.cls
 * @Description        : Used by the Approve/Unapprove actions on the schedule config object
 * @Author             : Mark Frizzell
 * @Group              : 
 * @Last Modified By   : Mark Frizzell
 * @Last Modified On   : 9/16/2019, 12:37:14 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0      9/9/2019                  Mark Frizzell             Initial Version
**/
global class IETRS_InspApprovalsBatch implements Database.Batchable<SObject> {
    
    private final String configRecordId;
    private final String approvalAction;
    private final List<IETRS_InspSchedule__c> inspSchedule;

    global IETRS_InspApprovalsBatch(Id configId, String action) {
        configRecordId = configId;
        approvalAction = action;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query =  'SELECT Id, IETRS_Inspection_Schedule_Config__c ' +
                        'FROM IETRS_InspSchedule__c ' +
                        'WHERE IETRS_Inspection_Schedule_Config__c = :configRecordId ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<IETRS_InspSchedule__c> records) {
        // Update approval on each schedule record
        List<IETRS_InspSchedule__c> updates = new List<IETRS_InspSchedule__c>();
        if(approvalAction == 'Unapprove'){
            for(IETRS_InspSchedule__c rec : records) {
                delete rec;
            }

            return;
        }
        for(IETRS_InspSchedule__c rec : records) {  
            switch on approvalAction {
                when 'Approve' {
                    rec.IETRS_Approved__c = true;
                }
                //when 'Unapprove' {
                //    rec.IETRS_Approved__c = false;
                //}
                when else {
                    
                }
            }
            updates.add(rec);
        }
        update updates;
    }

    global void finish(Database.BatchableContext bc) {
        try{
            IETRS_InspSchedConfig__c configRec = 
            [SELECT Id, IETRS_Status__c 
            FROM IETRS_InspSchedConfig__c 
            WHERE Id = :configRecordId LIMIT 1];
            
            delete configRec;
        } catch(Exception e) {

        }
       
        // Update IETRS_Status__c on config record
        try {
            IETRS_InspSchedConfig__c configRec = 
                [SELECT Id, IETRS_Status__c 
                FROM IETRS_InspSchedConfig__c 
                WHERE Id = :configRecordId LIMIT 1];
            
            switch on approvalAction {
                when 'Approve' {
                    configRec.IETRS_Status__c = 'Approved';
                }
                when else {
                    configRec.IETRS_Status__c = '';
                }
            }
            update configRec;
        } catch(Exception ex) {
            System.debug('Error updating config record: ' + ex.getMessage() + ' @ ' + ex.getLineNumber());
        }
    }

}