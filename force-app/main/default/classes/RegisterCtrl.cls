public with sharing class RegisterCtrl {
    @AuraEnabled
    public static String getEventStatus(String recdId){       
       String status = [SELECT Id, EEM_Event_Status__c FROM EEM_Event__c where Id =: recdId].EEM_Event_Status__c;
        return status;
    }
   @AuraEnabled
    public static String getPermissionSetName(){
        //String permissionSet=[SELECT Id,Assignee.Name,PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() ].PermissionSet.Name;
         String permissionSet=[SELECT Id,Assignee.Name,PermissionSet.Name,AssigneeId, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND ((PermissionSet.Name='EEM_RRC_Event_Management_AFS_Admin') OR (PermissionSet.Name='EEM_RRC_Events_Management_COP_Admin'))].PermissionSet.Name;

        System.debug('permissionSet'+permissionSet);
        return permissionSet;
    }
    
     @AuraEnabled
    public static String getProfileName(){
        //String permissionSet=[SELECT Id,Assignee.Name,PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() ].PermissionSet.Name;
         String profileName=[SELECT Id,Name,Profile.Name FROM User where Id=:UserInfo.getUserId()].Profile.Name;

        System.debug('profile'+profileName);
        return profileName;
    }
}