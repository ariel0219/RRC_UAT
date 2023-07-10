/**
 * @File Name          : IETRS_InspApprovalActions.cls
 * @Description        : 
 * @Author             : Mark Frizzell
 * @Group              : 
 * @Last Modified By   : Mark Frizzell
 * @Last Modified On   : 9/12/2019, 12:18:35 PM
 * @Modification Log   : 
*==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0      9/12/2019               Mark Frizzell               Initial Version
**/
public class IETRS_InspApprovalActionsController {
    
    @AuraEnabled
    public static void approve(Id recordId) {
        Database.executeBatch(new IETRS_InspApprovalsBatch(recordId, 'Approve'), 100);
    }

    @AuraEnabled
    public static void unapprove(Id recordId) {
        Database.executeBatch(new IETRS_InspApprovalsBatch(recordId, 'Unapprove'), 100);
    }
    
}