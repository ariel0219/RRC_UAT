public with sharing class IETRS_MassRelatedFCController {
    @AuraEnabled(cacheable=true)
    public static Map<String, list<Case>> getCaseList(
        boolean searchKey1,
        string searchKey2,
        date searchKey3,
        string searchKey4,
        string strFCRecordID
    ) {
        Map<String, list<Case>> result = new Map<String, list<Case>>();
        boolean sTempSearchKey1 = searchKey1;
        string sTempSearchKey2 = searchKey2 != null ? +searchKey2 : '';
        date sTempSearchKey3 = null;
        date keyDate = null;
        if (searchKey3 != null) {
            sTempSearchKey3 = searchKey3;
            keyDate = date.newinstance(
                sTempSearchKey3.year(),
                sTempSearchKey3.month(),
                sTempSearchKey3.day()
            );
        } else {
            keyDate = null;
        }
        string sTempSearchKey4 = searchKey4 != null
            ? '%' + searchKey4 + '%'
            : '';

        system.debug(sTempSearchKey1 + ' search key 1');
        system.debug(sTempSearchKey2 + ' search key 2');
        system.debug(sTempSearchKey3 + ' search key 3');
        system.debug(sTempSearchKey4 + ' search key 4');

        // find cases the file is already associated with
        Set<Id> existingCaseIds = new Set<Id>();
        List<Case> existingCases = new List<Case>();

        for (IETRS_File_Correspondence_Assignment__c fca : [
            SELECT IETRS_Case__c
            FROM IETRS_File_Correspondence_Assignment__c
            WHERE IETRS_File_and_Correspondence__c = :strFCRecordID
        ]) {
            existingCaseIds.add(fca.IETRS_Case__c);
        }

        if (!existingCaseIds.isEmpty()) {
            existingCases = [
                SELECT Id, CaseNumber, IETRS_Primary_Account_Assignment__r.Name
                FROM Case
                WHERE Id IN :existingCaseIds
            ];
        }
        list<case> lstCase = new List<case>();

        //Build the base of the query string
        String strDynamicQuery = 'SELECT id, CaseNumber, IETRS_Primary_Account_Assignment__c,  IETRS_Primary_Account_Assignment__r.Name, IETRS_Ready_for_Conference__c, IETRS_Agenda_Section__c, IETRS_Conference_Date__c FROM Case WHERE Id NOT in :existingCaseIds AND IETRS_Ready_for_Conference__c = :sTempSearchKey1';

        //If a value was passed for Agenda Section then append the AND statement to the WHERE clause
        strDynamicQuery = sTempSearchKey2 != ''
            ? strDynamicQuery +
              ' AND IETRS_Agenda_Section__c LIKE :sTempSearchKey2'
            : strDynamicQuery;
        //If a value was passed for Conference Date then append the AND statement to the WHERE clause
        strDynamicQuery = keyDate != null
            ? strDynamicQuery + ' AND IETRS_Conference_Date__c = :keyDate'
            : strDynamicQuery;
        //If a value was passed for the Parent Case Number then append the AND statement to the WHERE clause
        strDynamicQuery = sTempSearchKey4 != ''
            ? strDynamicQuery + ' AND Parent.CaseNumber LIKE :sTempSearchKey4'
            : strDynamicQuery;
        //Limit results to 100 at a time
        //strDynamicQuery = strDynamicQuery + 'LIMIT 100';
        strDynamicQuery =
            strDynamicQuery + ' ORDER BY CaseNumber ASC LIMIT 100';
        //Protect against SOQL injection
        strDynamicQuery = String.escapeSingleQuotes(strDynamicQuery);

        system.debug(strDynamicQuery);

        //Return the result of the list of cases
        lstCase = Database.query(strDynamicQuery);

        // for(case oCse : Database.query(strDynamicQuery)){
        //     lstCase.add(oCse);
        //   }
        system.debug(lstCase + ' :list of cases');

        result.put('cases', lstCase);
        result.put('existingCases', existingCases);
        return result;
    }

    @AuraEnabled
    public static void createRelatedFCs(List<String> lstCaseIds, Id strFCId) {
        Schema.SObjectType sObjType = strFCId.getSObjectType();
        if (sObjType == IETRS_Files_Correspondence__c.SObjectType) {
            createCaseDocuments(lstCaseIds, strFCId);
        } else if (sObjType == IETRS_Tracking_Date__c.SObjectType) {
            createRelatedTrackingDates(lstCaseIds, strFCId);
        }
    }

    private static void createRelatedTrackingDates(
        List<String> caseIds,
        Id trackingDateId
    ) {
        List<IETRS_Related_Tracking_Date__c> trackingDates = new List<IETRS_Related_Tracking_Date__c>();
        for (String caseId : caseIds) {
            trackingDates.add(
                new IETRS_Related_Tracking_Date__c(
                    IETRS_Case__c = caseId,
                    IETRS_Tracking_Date_Name__c = trackingDateId
                )
            );
        }
        insert trackingDates;
    }

    public static void createCaseDocuments(
        List<String> lstCaseIds,
        Id strFCId
    ) {
        List<IETRS_File_Correspondence_Assignment__c> lstRFCNew = new List<IETRS_File_Correspondence_Assignment__c>();
        for (String s : lstCaseIds) {
            IETRS_File_Correspondence_Assignment__c rfcNew = new IETRS_File_Correspondence_Assignment__c(
                IETRS_Case__c = s,
                IETRS_File_and_Correspondence__c = strFCId
            );
            lstRFCNew.add(rfcNew);
        }

        insert lstRFCNew;
        IETRS_Files_Correspondence__c fc = [
            SELECT Id, IETRS_Public__c, IETRS_Status_Detail__c
            FROM IETRS_Files_Correspondence__c
            WHERE Id = :strFCId
        ][0];
        system.debug(fc);

        if (fc.IETRS_Public__c) {
            List<IETRS_Public_File_Correspondence__c> lstNewCaseDocs = new List<IETRS_Public_File_Correspondence__c>();

            for (IETRS_File_Correspondence_Assignment__c rfc : lstRFCNew) {
                System.debug(fc.IETRS_Status_Detail__c);
                IETRS_Public_File_Correspondence__c cdocNew = new IETRS_Public_File_Correspondence__c(
                    IETRS_Case__c = rfc.IETRS_Case__c,
                    IETRS_Related_File_Correspondence__c = rfc.Id,
                    IETRS_Status_Detail__c = fc.IETRS_Status_Detail__c
                );
                system.debug(cdocNew);
                lstNewCaseDocs.add(cdocNew);
            }

            insert lstNewCaseDocs;
        }
    }
}