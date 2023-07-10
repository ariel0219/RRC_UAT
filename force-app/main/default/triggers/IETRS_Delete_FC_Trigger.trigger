/**
 * @File Name          : IETRS_Delete_FC_Trigger.trigger
 * @Description        : Deletes Related Files and Correspondence, Case Document, and Inspection Document records associated with a deleted File
 *                     : and Correspondence Record.
 * @Author             : Forrest Chang
 * @Group              : 
 * @Last Modified By   : Forrest Chang
 * @Last Modified On   : 01/17/2020
 * @Modification Log   : 
 * Ver          Date            Author          Modification
 * 1.0          01/17/2020      Forrest Chang   Initial Version
**/
trigger IETRS_Delete_FC_Trigger on IETRS_Files_Correspondence__c (before delete) {

    Set<ID> setFC = new Set<ID>();

    for (IETRS_Files_Correspondence__c fcRec : Trigger.old){
         setFC.add(fcRec.Id);
    }
    Map<ID, IETRS_File_Correspondence_Assignment__c> mapRelatedFC = new Map<ID, IETRS_File_Correspondence_Assignment__c>(
                                                                        [SELECT ID 
                                                                        FROM IETRS_File_Correspondence_Assignment__c 
                                                                        WHERE IETRS_File_and_Correspondence__c IN :setFC]
                                                                    );
                                                    
    List<IETRS_Public_File_Correspondence__c> lstPubFC = [SELECT ID 
                                                         FROM IETRS_Public_File_Correspondence__c 
                                                         WHERE IETRS_Related_File_Correspondence__c IN :mapRelatedFC.keyset()];
    
    List<IETRS_Inspection_Public_FC_Document__c> lstInspDoc= [SELECT ID 
                                                         	  FROM IETRS_Inspection_Public_FC_Document__c 
                                                         	  WHERE IETRS_Related_File_Correspondence__c IN :setFC];

    if(lstPubFC.size()>0){
        delete lstPubFC;
    }
    if(lstInspDoc.size()>0){
        delete lstInspDoc;
    }
    if(mapRelatedFC.size()>0){
        delete mapRelatedFC.values();
    }


}