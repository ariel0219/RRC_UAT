/**
 * @File Name          : IETRS_DeleteFilesCorrespondence.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 5/26/2020, 1:53:43 PM
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      05/26/2020      Kevin Lu                Initial Version
**/
public without sharing class IETRS_DeleteFilesCorrespondence {
    @InvocableMethod(label='Delete Files and Correspondence Record' description='Performs a delete of Files and Correspondence records while ignoring sharing rules and permissions')
    public static void deleteFilesCorrespondence(List<Id> lstRecordId) {
        List<IETRS_Files_Correspondence__c> lstFiles = [
            Select Id
            From IETRS_Files_Correspondence__c
            Where Id In :lstRecordId
        ];
        delete lstFiles;
    }
}