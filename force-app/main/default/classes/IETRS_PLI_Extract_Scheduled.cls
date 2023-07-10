/**
 * @description       : Scheduled class to execute PLI batches
 * @author            : Kevin Lu
 * @group             : 
 * @last modified on  : 2020-09-01
 * @last modified by  : Kevin Lu
 * Modifications Log 
 * Ver   Date         Author     Modification
 * 1.0   2020-07-06   Kevin Lu   Initial Version
 * 2.0   2020-09-01   Kevin Lu   Changed to run new truncate batch jobs first
**/
/*
 * Schedule this with execute anonymous:
IETRS_PLI_Extract_Scheduled pliExtract = new IETRS_PLI_Extract_Scheduled();
String sch = '0 30 17 ? * 2-6';
String jobID = system.schedule('PLI Extract', sch, pliExtract);
*/

public class IETRS_PLI_Extract_Scheduled implements Schedulable {
    public void execute(SchedulableContext context) {
        Database.executeBatch(new IETRS_PLI_Company_Extract_Delete());
        Database.executeBatch(new IETRS_PLI_TDR_Extract_Delete());
        Database.executeBatch(new IETRS_PLI_Unit_Extract_Delete());
        Database.executeBatch(new IETRS_PLI_System_Extract_Delete());
    }
}