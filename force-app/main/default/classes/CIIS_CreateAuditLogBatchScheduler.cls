global class CIIS_CreateAuditLogBatchScheduler implements Schedulable {
    
  // Execute at regular intervals
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CIIS_CreateAuditLogBatch(), 200);
     }
}