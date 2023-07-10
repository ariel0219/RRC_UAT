public without sharing class IETRS_PS95_StatsuController {
  

    @AuraEnabled
    public static boolean onSubmitPS95UpdateStatusYes(Id notificationId){
        boolean issubmitted=false;
        try {
            List<IETRS_Insp_Notification__c> listofnotificationRecordUpdate=new List<IETRS_Insp_Notification__c>();
            
            listofnotificationRecordUpdate = [SELECT id,IETRS_Submitted__c,IETRS_Submitted_Date__c,IETRS_Report_Period__c,IETRS_PS95_Organization__c
                                            FROM  IETRS_Insp_Notification__c WHERE Id =: notificationId limit 1];
            IETRS_Insp_Notification__c notificationRecordUpdate=listofnotificationRecordUpdate[0];
            //notificationRecordUpdate.id=notificationId;
            notificationRecordUpdate.IETRS_Submitted__c = 'Yes';
            notificationRecordUpdate.IETRS_Submitted_Date__c=System.now();
            Date dtDueDate=null;
            switch on notificationRecordUpdate.IETRS_Report_Period__c.right(3){
                when 'Jun'{
                    dtDueDate = date.NewInstance(integer.valueof(notificationRecordUpdate.IETRS_Report_Period__c.left(4)), 7, 16);
                }
                when 'Dec'{
                    dtDueDate = date.NewInstance(integer.valueof(notificationRecordUpdate.IETRS_Report_Period__c.left(4)) + 1, 1, 16);
                }
            }
            
            notificationRecordUpdate.IETRS_Filing_Status__c = notificationRecordUpdate.IETRS_Submitted_Date__c >= dtDueDate ? 'Late' : 'On Time';
            boolean isportalUser= isCurrentUserPortalUser();
            if(isportalUser){
               // String orgId =getAccountIdByNotificationIdForPS95(notificationRecordUpdate.id);
                boolean orgaccesstoCurrentUser=identifyPortalUserAcessOrganization(notificationRecordUpdate.IETRS_PS95_Organization__c);
                if(orgaccesstoCurrentUser){
                    update notificationRecordUpdate;
                    issubmitted=true;
                }else{

                }
            }else{
                update notificationRecordUpdate;
                issubmitted=true;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return issubmitted;
    }


    @AuraEnabled
    public static boolean getSubmittedValueByNotificationId(Id notificationId){
        boolean submitted=false;
        try {
            String submittedValue=[SELECT id,IETRS_Submitted__c FROM IETRS_Insp_Notification__c WHERE id=: notificationId].IETRS_Submitted__c;
            if(submittedValue=='Yes'){
                submitted=true;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return submitted;
    }

    @AuraEnabled
    public static boolean getPS95AccessCheckForProfile(){
       boolean isUserAccessToPS95_Status=false;
        try {
        if(featureManagement.checkPermission('Create_Edit_PS95_Reports')){
            isUserAccessToPS95_Status=true;
        }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return isUserAccessToPS95_Status;
    }

@AuraEnabled
public static boolean isCurrentUserPortalUser(){
    boolean isPortalUser=false;
    try {
         isPortalUser= IETRS_PLI_LWCQuery.isCurrentUserPortalUser();
        
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return isPortalUser;
}


@AuraEnabled
public static boolean identifyPortalUserAcessOrganization(Id organizationId){
   boolean access=false;
    try {
        access= IETRS_PLI_LWCQuery.identifyPortalUserAcessOrganization(organizationId);
        
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return access;
}



@AuraEnabled
public static String getAccountIdByNotificationIdForPS95(String notificationId){
String ps95OrgId='';
    try {
        
        ps95OrgId=IETRS_PLI_LWCQuery.getAccountIdByNotificationIdForPS95(notificationId);
        
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return ps95OrgId;
}

}