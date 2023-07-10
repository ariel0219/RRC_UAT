/*
Authors: 
V1 - Forrest C.
V2 - Connor R.
Versioning:
V1 - Assign to Hearings button created 
V2 - Refer to Legal button created

*/

public without sharing class IETRS_Assign_Case_to_Hearings_Controller {

    //Method called by the iETRS_Assign_Case_to_Hearings LWC and the iETRS_Refer_Case_to_Legal LWC
    //Returns all Files and Correspondence Records associated with the Case
    @AuraEnabled(cacheable=true)
    public static List<IETRS_Files_Correspondence__c> getRelatedFCs(string caseId) {

        Id idUserProfile = UserInfo.getProfileId();   
        String strProfileName = [SELECT Id,Name FROM Profile WHERE Id=:idUserProfile].Name;
        //get user id for public group check.
       // String strUserId = userinfo.getUserId();
//--------------------------------down
        //create boolean value for check below
        //Boolean BoolLegalGroup = false;
        //check if user is a part of legal enforecement group
        //List<GroupMember> lstgroupmember = [Select UserOrGroupId, Group.Type, GroupId From GroupMember g where Group.type = 'Regular' AND Group.Name = 'IETRS_Legal_Enforcement'  LIMIT 1];
        //if(lstgroupmember.size()>0){
          //  BoolLegalGroup = true;
          //}
          //AND UserOrGroupId= 'strUserId'
//---------------------------------------------------up
        //String strQuery = 'SELECT Id, Name, IETRS_Original_File_Name__c, IETRS_Shared_With_Hearings__c, IETRS_Privileged__c FROM IETRS_Files_Correspondence__c WHERE Id in (SELECT IETRS_File_and_Correspondence__c FROM IETRS_File_Correspondence_Assignment__c WHERE IETRS_Case__c = :caseId) ';
        //String strQuery = 'SELECT Id, Name, IETRS_Original_File_Name__c, IETRS_Shared_With_Hearings__c, IETRS_Privileged__c FROM IETRS_Files_Correspondence__c  WHERE';

        //If the runnning user's profile is Hearings or Docket Services, then return only FCs that have been shared with them by the Business Areas.
        //strQuery = (strProfileName == 'IETRS Case - Hearings' || strProfileName == 'IETRS Case - Docket Services') ? strQuery + ' AND IETRS_Shared_With_Hearings__c = true' : strQuery;
        
        //If the running user's profile is Legal Enforcement, then return only FCs that have been shared with them by the Business Areas.
        //strQuery = (strProfileName == 'IETRS Case - Legal Enforcement') ? strQuery + ' AND IETRS_Privileged__c = true' : strQuery;
//------------------------------------------down
        // strQuery = (strProfileName == 'IETRS Case - Legal Enforcement') ? strQuery + 
        // ' AND (IETRS_Privileged__c = true OR OwnerId in (SELECT Id FROM Group WHERE DeveloperName = \'IETRS_Legal_Enforcement\')) ' : strQuery;

//-------------------------------------------------------------------------------
//FC Code:
        List<IETRS_Files_Correspondence__c> lstReturnFCs = new List<IETRS_Files_Correspondence__c>();
        if(strProfileName == 'IETRS Case - Legal Enforcement'){
            List<IETRS_Files_Correspondence__c> lstLegalOwnedFCs = [SELECT Id, Name, IETRS_Original_File_Name__c, IETRS_Shared_With_Hearings__c, IETRS_Privileged__c  FROM IETRS_Files_Correspondence__c WHERE OwnerId in (SELECT Id FROM Group WHERE DeveloperName = 'IETRS_Legal_Enforcement_Case_Queue') AND Id in (SELECT IETRS_File_and_Correspondence__c FROM IETRS_File_Correspondence_Assignment__c WHERE IETRS_Case__c = :caseId)];
            List<IETRS_Files_Correspondence__c> lstPrivilegedFCs = [SELECT Id, Name, IETRS_Original_File_Name__c, IETRS_Shared_With_Hearings__c, IETRS_Privileged__c FROM IETRS_Files_Correspondence__c WHERE IETRS_Privileged__c = true AND Id in (SELECT IETRS_File_and_Correspondence__c FROM IETRS_File_Correspondence_Assignment__c WHERE IETRS_Case__c = :caseId)];
            Set<IETRS_Files_Correspondence__c> setLegalVisibleFCs = new Set<IETRS_Files_Correspondence__c>();
            setLegalVisibleFCs.addAll(lstLegalOwnedFCs);
            setLegalVisibleFCs.addAll(lstPrivilegedFCs);
            lstReturnFCs.addAll(setLegalVisibleFCs);
        }
        else{
            lstReturnFCs = [SELECT Id, Name, IETRS_Original_File_Name__c, IETRS_Shared_With_Hearings__c, IETRS_Privileged__c FROM IETRS_Files_Correspondence__c WHERE Id in (SELECT IETRS_File_and_Correspondence__c FROM IETRS_File_Correspondence_Assignment__c WHERE IETRS_Case__c = :caseId)];
        }

        return lstReturnFCs;
//--------------------------------------------------------------------------------

        
        //Not Working: -----strUserId in [SELECT Group.Name FROM GroupMember WHERE UserOrGroupId = strUserId AND Group.Type = Regular AND Group.Name = IETRS_Legal_Enforcement' : strQuery;
        //Not working----- strUserID in listgroupmember
//--------------------------------------------------------up
        // strQuery = String.escapeSingleQuotes(strQuery);
        
        // return Database.query(strQuery);

        // return List<IETRS_Files_Correspondence__c> lstFCs = [SELECT Id, Name, IETRS_Original_File_Name__c, IETRS_Shared_With_Hearings__c, IETRS_Privileged__c
        //                                                 FROM IETRS_Files_Correspondence__c 
        //                                                 WHERE Id in (SELECT IETRS_File_and_Correspondence__c 
        //                                                             FROM IETRS_File_Correspondence_Assignment__c 
        //                                                             WHERE IETRS_Case__c = :caseId)
        //                                                 ];

    }

    //Method Called by the iETRS_Assign_Case_to_Hearings LWC and iETRS_Refer_Case_to_Legal LWC
    //Handles the logic for updating the FC records and the Case record when it is assigned to Hearings or Legal
    //assignToHearings
    @AuraEnabled
    public static void assignToHearingOrLE(List<String> lstFCIds, String caseId, List<String> lstUnshareFCIds, String strShareWithFieldName){
        //Get all Files and Correspondence objects from the list of selected IDs
        List<IETRS_Files_Correspondence__c> lstFCsShare = [SELECT Id FROM IETRS_Files_Correspondence__c WHERE Id IN :lstFCIds];
        List<IETRS_Files_Correspondence__c> lstFCsUnshare = [SELECT Id FROM IETRS_Files_Correspondence__c WHERE Id IN :lstUnshareFCIds];
        //We may need to remove or update this list below from Kevin's suggestion. 
        List<IETRS_Files_Correspondence__c> lstFCsUpdate = new List<IETRS_Files_Correspondence__c>();

        //Get the Case object from the Case record Id of the page
        Case caseUpdate = [SELECT Id, IETRS_Original_Record_Type__c FROM Case WHERE Id = :caseId][0];
               
        //For all the Files and Correspondence records in the returned list, set Shared with Hearings or Legal to TRUE
        for(IETRS_Files_Correspondence__c fc : lstFCsShare){
            fc.put(strShareWithFieldName, True);
        }
        for(IETRS_Files_Correspondence__c fcUnshare : lstFCsUnshare){
            fcUnshare.put(strShareWithFieldName, False);
        }
        lstFCsUpdate.addAll(lstFCsShare);
        lstFCsUpdate.addAll(lstFCsUnshare);

        update lstFCsUpdate;
        
        //switch to call Assign to Hearings or Refer to Legal method below. 
        switch on strShareWithFieldName {
            when 'IETRS_Shared_With_Hearings__c' {
                statusUpdateHearings(caseUpdate, caseId);
            }
            
            when 'IETRS_Privileged__c' {
                statusUpdateLegal(caseUpdate, caseId);
            }
        }
        
    }
     //Method Called by the iETRS_Assign_Case_to_Hearings LWC by switch
    @AuraEnabled
    public static void statusUpdateHearings(Case caseUpdate, String caseId){
        //Get the Case object from the Case record Id of the page
        //Case caseUpdate = [SELECT Id, IETRS_Original_Record_Type__c FROM Case WHERE Id = :caseId][0];
        //Get the API name of the Business Area field that corresponds to the original record type of the Case record
        IETRS_Record_Type_Business_Area_Mapping__mdt metaMapping = [SELECT IETRS_Business_Area_Status__c, IETRS_Record_Type__c, IETRS_Docket_Group__c FROM IETRS_Record_Type_Business_Area_Mapping__mdt WHERE IETRS_Record_Type__c = :caseUpdate.IETRS_Original_Record_Type__c][0]; 
        //Automatically assigne the Docket Group field based on the mapping returned from custom metadata
        caseUpdate.IETRS_Docket_Group__c = metaMapping.IETRS_Docket_Group__c;
        caseUpdate.IETRS_Refer_to_Hearings__c = true;
        //Using a standardized custom label set the Hearings Status to "Open (Needs Assignment)" No code change needed if the picklist value changes, but the Custom Label needs to be updated
        //TODO: Tello asked to remove this open hearing status requirements.
        //caseUpdate.IETRS_Hearings_Status__c = System.Label.IETRS_Hearings_Status_Open_Needs_Assignment;
        //Pending Hearings Acceptance field set to true, the places the record in a pending state between being accepted and docketed by hearings and residing in the business area
        caseUpdate.IETRS_Pending_Hearings_Acceptance__c = true;
        //Update the Business Area status field returned from custom metadata with the standardized picklist value "Assigned to Hearings" (This value is unified across all Business Area statuses)
        caseUpdate.put(metaMapping.IETRS_Business_Area_Status__c, System.Label.IETRS_Assigned_To_Hearings_Pick_Val);
        //Change the Case Record Type to Hearings to make it accessible to the Hearings users
        caseUpdate.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('Hearings').getRecordTypeId();

        update caseUpdate;

    }
     //Method Called by the iETRS_Refer_Case_to_Legal LWC by switch
    @AuraEnabled
    public static void statusUpdateLegal(Case caseUpdate, String caseId){
        //Get the Case object from the Case record Id of the page
        //Case caseUpdate = [SELECT Id, IETRS_Original_Record_Type__c FROM Case WHERE Id = :caseId][0];
        //Get the API name of the Business Area field that corresponds to the original record type of the Case record
        IETRS_Record_Type_Business_Area_Mapping__mdt metaMapping = [SELECT IETRS_Business_Area_Status__c, IETRS_Record_Type__c FROM IETRS_Record_Type_Business_Area_Mapping__mdt WHERE IETRS_Record_Type__c = :caseUpdate.IETRS_Original_Record_Type__c][0]; 

        //Automatically assigne the Docket Group field based on the mapping returned from custom metadata
        //------caseUpdate.IETRS_Docket_Group__c = metaMapping.IETRS_Docket_Group__c;
        caseUpdate.IETRS_Refer_to_Legal_Enforcement__c = true;
        //Pending Legal Acceptance field set to true, the places the record in a pending state between being accepted and docketed by hearings and residing in the business area
        caseUpdate.IETRS_Pending_Legal_Acceptance__c = true;
        //Set LE Case Status independent of accepting or rejecting case from business areas. This was adjusted based on team conversation from setting the LE Case Status in the Case Acceptance Management Flow. 
        caseUpdate.IETRS_Legal_Enforcement_Status__c = System.Label.IETRS_Legal_Status_Open_Needs_Assignment;
        //Update the Business Area status field returned from custom metadata with the standardized picklist value "Referred to Legal Enforcement" (This value is unified across all Business Area statuses except for SMRD)
        //Condition to check if business area is SMRD. A different label is used as the SMRD business area case picklist status values are different than all other business area case status values.
        if (metaMapping.IETRS_Record_Type__c == 'SMRD') {
            caseUpdate.put(metaMapping.IETRS_Business_Area_Status__c, System.Label.IETRS_Assigned_to_Legal_SMRD_Pick_Val);
        }
        else {
            caseUpdate.put(metaMapping.IETRS_Business_Area_Status__c, System.Label.IETRS_Assigned_to_Legal_Pick_Val);
        }
        //Change the Case Record Type to Hearings to make it accessible to the Hearings users
        caseUpdate.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('IETRS_Legal_Enforcement').getRecordTypeId();
        
        update caseUpdate;
    }

    //Invocable method called by the Case Acceptance Management Flow
    //Handles the logic for updating the Case record when it is returned to the Business Area from Hearings or Legal
    @InvocableMethod(Label='Return Case to Business Area')
    public static void returnToHearings(List<String> lstCaseId){

        Case caseUpdate = IETRS_Return_Case_To_Business_Area.helperReturnCaseUpdater(lstCaseId[0]);
        //added condition check for whether this was called from a Assgined to Hearings or Assgined to Legal.
        if (caseUpdate.IETRS_Refer_to_Hearings__c == true) {
            caseUpdate.IETRS_Refer_to_Hearings__c = false;
            caseUpdate.IETRS_Pending_Hearings_Acceptance__c = false;
            //Using a standardized custom label set the Hearings Status to "Returned to Business Area" No code change needed if the picklist value changes, but the Custom Label needs to be updated
            caseUpdate.IETRS_Hearings_Status__c = System.Label.IETRS_Returned_to_Business_Area;
        }
        //created new field "Pending Legal Acceptance"
        else {
            caseUpdate.IETRS_Refer_to_Legal_Enforcement__c = false;
            caseUpdate.IETRS_Pending_Legal_Acceptance__c = false;
            //Using a standardized custom label set the Hearings Status to "Returned to Business Area" No code change needed if the picklist value changes, but the Custom Label needs to be updated
            //TODO: add this back below
            caseUpdate.IETRS_Legal_Enforcement_Status__c = System.Label.IETRS_Returned_to_Business_Area;
        }
        
        

        update caseUpdate;

    }
}