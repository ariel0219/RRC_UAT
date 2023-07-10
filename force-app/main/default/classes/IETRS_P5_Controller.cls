/**
 * @File Name          : IETRS_P5_Controller.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 2020-07-17
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    06/19/2019, 11:01:59 AM   Chris McKee     Initial Version
 * 1.1    07/19/2019                Mark Frizzell   Update return types for operator and officer methods
 * 1.2    08/05/2019                Kevin Lu        Added IETRS_Last_Change__c mappings
 * 1.3    08/22/2019                Kevin Lu        Added IETRS_TNR_91114 mapping
 * 1.4    03/18/2020                Kevin Lu        Added owner mapping to "Integrations User"
 * 1.5    04/27/2020                Kevin Lu        Updated to include agent load
 * 1.6    05/05/2020                Kevin Lu        Updated to include new operator fields for phase 2
 * 1.7    07/08/2020                Kevin Lu        Accounted for null values
 * 1.8    07/16/2020                Kevin Lu        Added 639 Hold functionality
**/
public with sharing class IETRS_P5_Controller {
    private List<Account> lstOperators;
    private List<Contact> lstOfficer;
    private RecordType recordTypeOp;
    private RecordType recordTypeOfficer;
    private RecordType recordType639Hold;
    private User integrationsUser;
    
    public IETRS_P5_Controller() {
		lstOperators = new List<Account>();
        lstOfficer = new List<Contact>();
        recordTypeOp = [Select Id From RecordType Where SObjectType = 'Account' And Name = 'Organization'].get(0);
        recordTypeOfficer = [Select Id From RecordType Where SObjectType = 'Contact' And Name = 'Read Only Contact'].get(0);
        recordType639Hold = [Select Id From RecordType Where SObjectType = 'IETRS_Hold__c' And Name = '639 Hold'].get(0);
        integrationsUser = [Select Id, Name From User Where Name = 'Integrations User' Limit 1];
    }

    /**
    * @description Parses and maps Operators to a List to be upserted
    * @author Kevin Lu | 6/19/2019
    * @param Operators mfOperator The deserialized JSON response that contains a list of Operators
    * @return void
    */
    public List<Account> addOperator(Operators mfOperator) {
        Boolean boolHas639Hold = false;
        for(Operators.Operator currentOperator : mfOperator.operators) {
            //New Account
            Account acctOperator = new Account();
            
            //Internal Fields
            acctOperator.IETRS_P5_Number__c = currentOperator.operatorNumber;
            acctOperator.Name = currentOperator.operatorName;
            acctOperator.IETRS_Status__c = currentOperator.operatorStatus;
            
            if(currentOperator.operatorType == 'LIMITED LIAB COMPANY'){
                acctOperator.IETRS_Organization_Type__c = 'LLC';
            }
            else{
                acctOperator.IETRS_Organization_Type__c = currentOperator.operatorType;
            }

            acctOperator.ShippingStreet = currentOperator.locationAddress;
            acctOperator.ShippingCity = currentOperator.locationCity;
            acctOperator.ShippingState = currentOperator.locationState;
            acctOperator.ShippingPostalCode = currentOperator.locationZip;
            acctOperator.BillingStreet = currentOperator.billingAddress;
            acctOperator.BillingCity = currentOperator.billingCity;
			acctOperator.BillingState = currentOperator.billingState;
			acctOperator.BillingPostalCode = currentOperator.billingZip;    
            acctOperator.Phone = currentOperator.operatorPhone;
            acctOperator.IETRS_TNR_91114__c = currentOperator.tnr91_114 == 'Yes';
            acctOperator.IETRS_P5_Renewal_Month__c = currentOperator.p5_renewal_month;
            acctOperator.IETRS_Initial_P5_File_Date__c = currentOperator.initial_p5_file_date != null ? Date.parse(currentOperator.initial_p5_file_date.replaceAll('-', '/')) : null;
            acctOperator.IETRS_Last_P5_File_Date__c = currentOperator.last_P5_file_date != null ? Date.parse(currentOperator.last_P5_file_date.replaceAll('-', '/')) : null;
            acctOperator.IETRS_Last_Change__c = Date.today();
            acctOperator.OwnerId = integrationsUser.Id;
				
            //Record Type
            acctOperator.RecordTypeId = recordTypeOp.Id;
            //Add Well to Wells List for upsert
            lstOperators.add(acctOperator);

            if(currentOperator.holdReason639 != null && currentOperator.holdReason639.size() > 0) {
                boolHas639Hold = true;
            }
        }

        try {
            if(lstOperators.size() > 0) {
                upsert lstOperators IETRS_P5_Number__c;
                if(boolHas639Hold) {
                    add639HoldReason(mfOperator);
                }
                return lstOperators;
            }
            else {
                System.debug('Operators list is empty');
                return null;
            }
        }
        catch (DmlException e) {
            System.debug(e.getMessage());
            return null;
        }
    }
    
    /**
    * @description Parses and maps Officers to a List to be upserted
    * @author Kevin Lu | 6/19/2019
    * @param Officers mfOfficer The deserialized JSON response that contains a list of Officers
    * @return void
    */
    public List<Contact> addOfficer(Officers mfOfficer) {
        
        ///////////////////////////////////////////////////////////////
        /*                     P5 Number Lookup                     */    
        Map<String, Id> mapOperators = new Map<String, Id>();
        Set<String> setOperatorNumbers = new Set<String>();
        Set<String> setOfficerExternalIds = new Set<String>();

        //Get the distinct list of Operator Numbers
        for(Officers.Officer singleOfficer : mfOfficer.officers){
            setOperatorNumbers.add(singleOfficer.operatorNumber);
        }

        //Build the map of Operator Numbers and Salesforce IDs
        for(Account acctOperator : [Select Id, IETRS_P5_Number__c From Account Where IETRS_P5_Number__c In :setOperatorNumbers]){
            mapOperators.put(acctOperator.IETRS_P5_Number__c, acctOperator.Id);
        }
        ///////////////////////////////////////////////////////////////

        boolean isFirst = true;
        for(Officers.Officer currentOfficer : mfOfficer.officers) {
            //Split Officer full name in to First and Last name
            String strFirstName = currentOfficer.officerName.substringAfter(',').Trim();
            String strLastName = currentOfficer.officerName.substringBefore(',').Trim();
            //New Contact
            Contact tempContact = new Contact();
            //Internal Fields
            tempContact.FirstName = strFirstName;
            tempContact.LastName = strLastName;
            tempContact.Title = currentOfficer.officerTitle;
            tempContact.OtherStreet = currentOfficer.locationAddress;
            tempContact.OtherCity = currentOfficer.locationCity;
            tempContact.OtherState = currentOfficer.locationState;
            tempContact.OtherPostalCode = currentOfficer.locationZip;
            tempContact.MailingStreet = currentOfficer.billingAddress;
            tempContact.MailingCity = currentOfficer.billingCity;
			tempContact.MailingState = currentOfficer.billingState;
			tempContact.MailingPostalCode = currentOfficer.billingZip;
            tempContact.IETRS_Last_Change__c = Date.today();
            tempContact.OwnerId = integrationsUser.Id;
            tempContact.IETRS_Contact_Type__c = currentOfficer.type_Z == 'OFFICER' ? 'Officer' : 'Agent';
            tempContact.IETRS_Active__c = true;
            
            if(isFirst && currentOfficer.type_Z == 'OFFICER') {
                tempContact.IETRS_Primary_Officer__c = true;
                isFirst = false;
            } else {
                tempContact.IETRS_Primary_Officer__c = false;
            }

            //Lookup Fields
            tempContact.AccountId = mapOperators.get(currentOfficer.operatorNumber);
            
            //External Fields
            tempContact.IETRS_P5_Officer_ID__c = strFirstName + '|'+ strLastName + '|' + currentOfficer.officerTitle + '|' + currentOfficer.operatorNumber;
            						
            //Record Type
            tempContact.RecordTypeId = recordTypeOfficer.Id;
            //Add Officer to Officers List for upsert
            lstOfficer.add(tempContact);
            setOfficerExternalIds.add(tempContact.IETRS_P5_Officer_ID__c);
        }

        /*
        //Find officers with relevant P5 numbers, but are no longer valid/current
        List<Contact> lstRemovedContacts = [Select Id, LastName From Contact 
                                            Where IETRS_P5_Officer_ID__c != '' 
                                            And Account.IETRS_P5_Number__c In :setOperatorNumbers
                                            And IETRS_P5_Officer_ID__c Not In :setOfficerExternalIds];
                                            //And Status = 'Current'

        for(Contact c : lstRemovedContacts){
            //Update status and dates
        }

        update lstRemovedContacts;
        */

        try {
            if(lstOfficer.size() > 0) {
                upsert lstOfficer IETRS_P5_Officer_ID__c;
                Set<Id> setContactId = new Set<Id>();
                for(Contact c : lstOfficer) {
                    setContactId.add(c.Id);
                }
                deactivateContacts(setContactId);
                return lstOfficer;
            }
            else {
                System.debug('Officer list is empty');
                return null;
            }
        }
        catch (DmlException e) {
            System.debug(e.getMessage());
            return null;
        }
    }
    
    public void upsertP5() { 
        Account newAcct = new Account();
        try {
            if(lstOperators.size() > 0)
            	upsert lstOperators IETRS_P5_Number__c;
            else
                 System.debug('Operators list is empty');
            if(lstOfficer.size() > 0)
            	upsert lstOfficer IETRS_P5_Officer_ID__c;
            else
                System.debug('Officer list is empty');
        }
        catch (DmlException e) {
            System.debug(e.getMessage());
        }
    }

    /**
    * @description Adds 639 Hold Reasons
    * @author Kevin Lu | 2020-07-16 
    * @param mfOperator The information from mainframe
    **/
    public void add639HoldReason(Operators mfOperator) {
        List<IETRS_Hold__c> lstHoldsToUpsert = new List<IETRS_Hold__c>();
        Set<String> setP5Numbers = new Set<String>();
        Map<String,Id> mapP5Numbers = new Map<String,Id>();

        //Build the map of P5 numbers to Account Ids
        for(Operators.Operator op : mfOperator.operators) {
            if(op.holdReason639 != null && op.holdReason639.size() > 0) {
                setP5Numbers.add(op.operatorNumber);
            }
        }
        for(Account acctOperator : [
            Select Id, IETRS_P5_Number__c
            From Account
            Where IETRS_P5_Number__c In :setP5Numbers
        ]) {
            mapP5Numbers.put(acctOperator.IETRS_P5_Number__c, acctOperator.Id);
        }

        //Populate list of holds to upsert
        for(Operators.Operator op : mfOperator.operators) {
            for(Operators.HoldReason639 hold639 : op.holdReason639) {
                IETRS_Hold__c holdToUpsert = new IETRS_Hold__c (
                    IETRS_639_Docket_Number__c = hold639.docketNumber,
                    IETRS_639_Flag_Reason__c = hold639.flagReason,
                    IETRS_639_Taint_Type__c = hold639.taintType == 'D' ? 'Direct' : 'Indirect',
                    IETRS_639_Violation_Date__c = hold639.violationDate == null ? null : Date.parse(hold639.violationDate.replaceAll('-', '/')),
                    IETRS_639_External_Id__c = hold639.docketNumber + '|' + op.operatorNumber,
                    IETRS_Regulated_Entity__c = mapP5Numbers.get(op.operatorNumber),
                    OwnerId = integrationsUser.Id,
                    RecordTypeId = recordType639Hold.Id
                );
                lstHoldsToUpsert.add(holdToUpsert);
            }
        }

        upsert lstHoldsToUpsert IETRS_639_External_Id__c;
        //Deactivate any 639 holds that are related to the operator but not in this list
        IETRS_P5_Controller.deactivate639Holds((new Map<Id,SObject>(lstHoldsToUpsert)).keySet());
    }

    /**
    * @description Asynchronous call to "deactivate" old officer and agent records
    * @author Kevin Lu | 3/24/2020 
    * @param activeContacts A set of Contact Id's representing the latest set of contacts
    * @return void 
    **/
    @future
    public static void deactivateContacts(Set<Id> activeContacts) {
        List<Contact> contactsToUpdate = new List<Contact>();
        Set<String> setP5Numbers = new Set<String>();
        for(Contact c : [
            Select Id, Account.IETRS_P5_Number__c
            From Contact
            Where Id In :activeContacts
        ]) {
            setP5Numbers.add(c.Account.IETRS_P5_Number__c);
        }

        for(Contact c : [
            Select Id
            From Contact
            Where Account.IETRS_P5_Number__c In :setP5Numbers
            And Id Not In :activeContacts
            And RecordType.Name = 'Read Only Contact'
            And IETRS_Active__c = True
        ]) {
            c.IETRS_Active__c = false;
            contactsToUpdate.add(c);
        }
        update contactsToUpdate;
    }

    /**
    * @description Deactivates 639 holds that were not brought in from the mainframe
    * @author Kevin Lu | 2020-07-16 
    * @param setActiveHolds Set of 639 Hold IDs that were recently added from mainframe
    **/
    @future
    public static void deactivate639Holds(Set<Id> setActiveHoldIDs) {
        Id recordTypeId639Hold = [Select Id From RecordType Where SObjectType = 'IETRS_Hold__c' And Name = '639 Hold'].get(0).Id;
        List<IETRS_Hold__c> lstHoldsToDeactivate = new List<IETRS_Hold__c>();

        Set<String> setHoldExternalIDs = new Set<String>();
        Set<Id> setAccountIDs = new Set<Id>();

        for(IETRS_Hold__c activeHold : [
            Select Id, IETRS_639_External_Id__c, IETRS_Regulated_Entity__c
            From IETRS_Hold__c
            Where Id In :setActiveHoldIDs
        ]) {
            setHoldExternalIDs.add(activeHold.IETRS_639_External_Id__c);
            setAccountIDs.add(activeHold.IETRS_Regulated_Entity__c);
        }

        for(IETRS_Hold__c holdToDeactive : [
            Select Id, IETRS_Active__c
            From IETRS_Hold__c
            Where RecordTypeId = :recordTypeId639Hold
            And IETRS_Regulated_Entity__c In :setAccountIDs
            And IETRS_639_External_Id__c Not In :setHoldExternalIDs
            And IETRS_Active__c = true
        ]) {
            holdToDeactive.IETRS_Active__c = false;
            lstHoldsToDeactivate.add(holdToDeactive);
        }
        
        update lstHoldsToDeactivate;
    }
}