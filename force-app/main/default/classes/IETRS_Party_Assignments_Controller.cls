/**
 * @File Name          : IETRS_Party_Assignments_Controller.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 6/10/2020, 10:39:46 AM
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      03/23/2020      Kevin Lu                Initial Version
 * 1.1      05/14/2020      Kevin Lu                Updated logic to always consider the input case to cover the scenario where the case has no Entities and Individuals
                                                    Changed to account for agents as well
 * 1.2      06/10/2020      Kevin Lu                Changed deletion logic to only delete records that have been imported
**/
public class IETRS_Party_Assignments_Controller {
    @InvocableMethod(label='Update Entities and Individuals' description='Updates officer, agent, and organization of the given case and its related Entities and Individuals' category='Case')
    public static List<String> updatePartyAssignments(List<Id> listCaseIds) {
        List<IETRS_Party_Assignment__c> lstAddAssignments = new List<IETRS_Party_Assignment__c>();
        List<IETRS_Party_Assignment__c> lstRemoveAssignments = new List<IETRS_Party_Assignment__c>();
        Set<Id> setOfficerIds = new Set<Id>();
        Set<Id> setAffectedCases = new Set<Id>();
        Map<Id,Set<Id>> mapOfficerMap = new Map<Id,Set<Id>>();

        IETRS_Web_Services webServiceController = new IETRS_Web_Services();
        IETRS_P5_Controller p5Controller = new IETRS_P5_Controller();

        //Get P5 Number from the input Case
        Case caseRecord = [Select Id, IETRS_Primary_Account_Assignment__c, IETRS_Primary_Account_Assignment__r.IETRS_P5_Number__c From Case Where Id = :listCaseIds.get(0) Limit 1];
        
        //Get operator and officer info
        Operators mfOperators = webServiceController.getP5OperatorsByNumber(caseRecord.IETRS_Primary_Account_Assignment__r.IETRS_P5_Number__c);
        Officers mfOfficers = webServiceController.getP5Officers(caseRecord.IETRS_Primary_Account_Assignment__r.IETRS_P5_Number__c);

        //Perform updates and save results to lists/sets
        Account acctOperator = p5Controller.addOperator(mfOperators).get(0);
        List<Contact> lstOfficers = p5Controller.addOfficer(mfOfficers);
        for(Contact c : lstOfficers) {
            setOfficerIds.add(c.Id);
        }

        setAffectedCases.add(caseRecord.Id);
        //Populate the set of Ids, as well as populate the map of contact Ids and which Cases they belong to
        for(IETRS_Party_Assignment__c pa : [
            Select Id, IETRS_Contact__c, IETRS_Case__r.IETRS_Primary_Account_Assignment__c
            From IETRS_Party_Assignment__c
            Where IETRS_Case__r.IETRS_Primary_Account_Assignment__c = :acctOperator.Id
            //Where IETRS_Case__c = :caseId
            And IETRS_Case__r.Status = 'Active'
            And IETRS_Contact__c != ''
            //And IETRS_Type_of_Party__c = 'Officer'
        ]) {
            setAffectedCases.add(pa.IETRS_Case__c);

            Set<Id> setCaseIds;
            if(mapOfficerMap.containsKey(pa.IETRS_Contact__c)) {
                setCaseIds = mapOfficerMap.get(pa.IETRS_Contact__c);
            } else {
                setCaseIds = new Set<Id>();
            }
            setCaseIds.add(pa.IETRS_Case__c);
            mapOfficerMap.put(pa.IETRS_Contact__c, setCaseIds);
            //System.debug('Looped through party assignments');
        }
        //System.debug(mapOfficerMap);

        //Loop through updated officers to see if any need to be added
        for(Contact officer : lstOfficers) {
            Set<Id> setCaseIdCopy = new Set<Id>(setAffectedCases); //copy of affected cases set
            //Create records for cases that aren't in the map
            setCaseIdCopy.removeAll(mapOfficerMap.containsKey(officer.Id) ? mapOfficerMap.get(officer.Id) : new Set<Id>()); 
            for(Id cid : setCaseIdCopy) {
                IETRS_Party_Assignment__c partyAssignment = new IETRS_Party_Assignment__c(
                    IETRS_Case__c = cid,
                    IETRS_Organization__c = acctOperator.Id,
                    IETRS_Contact__c = officer.Id
                );
                if(officer.IETRS_Contact_Type__c == 'Agent' && officer.Title == 'RESIDENT TEXAS AGENT') {
                    partyAssignment.IETRS_Type_of_Party__c = 'Texas Resident Agent';
                } else if(officer.IETRS_Contact_Type__c == 'Agent' && officer.Title == 'FILING AGENT') {
                    partyAssignment.IETRS_Type_of_Party__c = 'Filing Agent';
                } else {
                    partyAssignment.IETRS_Type_of_Party__c = 'Officer';
                }
                lstAddAssignments.add(partyAssignment);
            } 
        }
        //Loop through existing assignemnts to see if any need to be removed
        for(IETRS_Party_Assignment__c partyAssignment : [
            Select Id, IETRS_Contact__c, IETRS_Contact__r.IETRS_Last_Change__c, IETRS_Case__r.IETRS_Primary_Account_Assignment__c
            From IETRS_Party_Assignment__c
            Where IETRS_Case__r.IETRS_Primary_Account_Assignment__c = :acctOperator.Id
            And IETRS_Case__r.Status = 'Active'
            And IETRS_Contact__c Not In :setOfficerIds
            And IETRS_Type_of_Party__c In ('Officer', 'Filing Agent', 'Texas Resident Agent')
            And IETRS_Contact__r.IETRS_Last_Change__c != Null
        ]) {
            lstRemoveAssignments.add(partyAssignment);
        }

        try {
            insert lstAddAssignments;
            delete lstRemoveAssignments;
            return new List<String> {'Success'};
        } catch (Exception e) {
            return new List<String> {e.getMessage() + ' ' + e.getLineNumber()};
        }
        
    }
}