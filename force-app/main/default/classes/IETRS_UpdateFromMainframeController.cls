/**
 * @File Name          : IETRS_UpdateFromMainframeController.cls
 * @Description        : 
 * @Author             : Mark Frizzell
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 4/28/2020, 11:34:30 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/5/2019            Mark Frizzell     Initial Version
 * 1.1    8/9/2019            Mark Frizzell     Added loadOfficerData() and loadLeaseData()
 * 1.2    8/14/2019           Mark Frizzell     Added loadRecord(), removed lightning:recordForm from component
 *                                              Redesign of loadOfficer and loadLease methods
 *                                              Redesign of updateRecord()
 * 1.3    8/22/2019           Kevin Lu          Updated operator mapping
 * 1.4    9/03/2019           Kevin Lu          Updated trims in well updates
                                                Removed P5 number from well mapping
 * 1.5    10/15/2019          Kevin Lu          Added Drilling Permit processing functions
 * 1.6    11/15/2019          Kevin Lu          Modified well mapping to remove spaces from Name
 * 2.0    01/13/2020          Kevin Lu          Updated to utilize existing controllers for mapping upserts
 * 3.0    04/28/2020          Kevin Lu          Updated operator update to utilize P5 Controller
**/
public with sharing class IETRS_UpdateFromMainframeController {
    
    private class OperatorWrapper {
        @AuraEnabled public Operators.Operator operator { get; set; }
        @AuraEnabled public List<Officers.Officer> officers { get; set; }
    }

    private class LeaseWrapper {
        @AuraEnabled public Leases.Lease lease { get; set; }
        @AuraEnabled public List<Wells.Well> wells { get; set; }
    }

    /**
    * @description - Loads the current record details
    * @author Mark Frizzell | 8/14/2019
    * @param Id recordId - Current record Id
    * @param String objectName - Name of the SObject type to query
    * @return SObject - Results of query
    */
    @AuraEnabled
    public static SObject loadRecord(Id recordId, String objectName) {
        try {
            switch on objectName {
                when 'Account' {
                    return [SELECT Id, Name, ParentId, Parent.IETRS_P5_Number__c, Parent.Name, RecordType.Name, RecordType.DeveloperName, Type, BillingAddress, IETRS_Organization_Type__c, 
                                IETRS_P5_Number__c, IETRS_Lease_Number__c, IETRS_District__r.Name, IETRS_Field_Name__c, IETRS_Field_Number__c, IETRS_Drilling_Permit_Number__c, IETRS_Drilling_Permit_Version__c, IETRS_Lease_Name__c,
                                IETRS_API__c, IETRS_UIC_Number__c, IETRS_UIC_Permit_Number__c, IETRS_UIC_Project_Number__c,IETRS_OrganizationofRegEntity__r.Name, IETRS_OrganizationofRegEntity__r.IETRS_P5_Number__c,
                                (SELECT Id, FirstName, MiddleName, LastName, Title, Email, Phone FROM Contacts ORDER BY LastName ASC), 
                                (SELECT Id, Name, IETRS_Account_ID__c, IETRS_Well_Number__c, IETRS_P5_Number__c, IETRS_Lease_Number__c, 
                                        IETRS_API__c, IETRS_District__r.Name, IETRS_County__c, IETRS_County__r.Name, IETRS_Well_External_Id__c,
                                        IETRS_OrganizationofRegEntity__c
                                 FROM ChildAccounts
                                 ORDER BY IETRS_API__c ASC)
                            FROM Account 
                            WHERE Id = :recordId 
                            LIMIT 1];
                }
                when else {
                    return null;
                }
            }
        } catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            return new Account(Name = 'ERROR: ' + ex.getMessage());
        }
    }

    /**
    * @description - Loads mainframe data for the current operator account
    * @author Mark Frizzell | 8/5/2019
    * @param String p5Number - Record P5 number to search mainframe
    * @return String - JSON mainframe data
    */
    @AuraEnabled
    public static String loadOperatorData(String p5Number) {
        Operators mfOperators = new Operators();
        Officers mfOfficers = new Officers();
        String results = '';
        Boolean validOperatorNumber = String.isBlank(p5Number) ? false : IETRS_Input_Validation.validOperatorNumber(p5Number);

        if(validOperatorNumber) {
            IETRS_Web_Services wSvc = new IETRS_Web_Services();
            mfOperators = wSvc.getP5OperatorsByNumber(p5Number);
            mfOfficers = wSvc.getP5Officers(p5Number);
        }
        
        results = 
            '{' 
            + '"operator":' + JSON.serialize(mfOperators.operators[0])
            + ',' 
            + JSON.serialize(mfOfficers).removeStart('{').removeEnd('}')
            + '}';
        System.debug('results: ' + results);
        return results;
    }

    /**
    * @description - Loads mainframe data for the current lease account
    * @author Mark Frizzell | 8/5/2019
    * @param String p5Number - Record P5 number to search mainframe
    * @return String - JSON mainframe data
    */
    @AuraEnabled
    public static String loadLeaseData(String leaseNumber, String districtCode) {
        Leases mfLeases = new Leases();
        Wells mfWells = new Wells();
        String results = '';
        Boolean validLeaseNumber = String.isBlank(leaseNumber) ? false : IETRS_Input_Validation.validLeaseNumber(leaseNumber);

        if(validLeaseNumber) {
            IETRS_Web_Services wSvc = new IETRS_Web_Services();
            mfLeases = wSvc.getLeases(districtCode, leaseNumber);
            mfWells = wSvc.getWellsByLease(districtCode, leaseNumber);
        }

        results = 
            '{' 
            + '"lease":' + JSON.serialize(mfLeases.leases[0])
            + ',' 
            + JSON.serialize(mfWells).removeStart('{').removeEnd('}')
            + '}';
        System.debug('results: ' + results);
        return results;
    }

    /**
    * @description Loads mainframe data for the current drilling permit
    * @author Kevin Lu | 10/15/2019 
    * @param drillingPermitNumber The drilling permit number to search mainframe
    * @return String JSON mainframe data
    **/
    @AuraEnabled
    public static String loadDrillingPermitData(String drillingPermitNumber) {
        IETRS_Web_Services wSvc = new IETRS_Web_Services();
        IETRS_DrillingPermits permits = wSvc.getDrillingPermitsByNumber(drillingPermitNumber);

        //Find and populate the operator name
        if(permits != null) {
            Account acctOperator = [Select Id, Name, IETRS_P5_Number__c From Account Where IETRS_P5_Number__c = :permits.operatorNumber Limit 1];
            permits.operatorName = acctOperator.Name;
        }

        return JSON.serialize(permits);
    }

    /**
    * @description Loads mainframe data for the current UIC Permit
    * @author Forrest Chang | 07/08/2020 
    * @param apiNumber The API number to search mainframe. uicNumber - The UIC number to narrow the search
    * @return String JSON mainframe data
    **/
    @AuraEnabled
    public static String loadUICPermitData(String apiNumber, String uicNumber) {
        IETRS_Web_Services wSvc = new IETRS_Web_Services();
        UIC permits = wSvc.getUICByAPI(apiNumber);
        UIC singlePermit = new UIC();
        
        //Find and populate the operator name
        if(permits != null) {
            if(permits.uicinfo.size()>1){
                for (UIC.Uicinfo uicInfo : permits.uicinfo){                 
                    if(uicInfo.uicNumber == uicNumber){
                        singlePermit.uicinfo.add(uicInfo);
                        break;
                    }
                    else{
                        singlePermit.uicinfo.add( permits.uicinfo[0]);
                    }
                }
            }
            else{
                singlePermit.uicinfo = permits.uicinfo;
            }        

            List<Account> acctOperators = [Select Id, Name, IETRS_P5_Number__c From Account Where IETRS_P5_Number__c = :singlePermit.Uicinfo[0].operatorNumber Limit 1];
            if(acctOperators != null && acctOperators.size() > 0 ){
                singlePermit.Uicinfo[0].operatorName = acctOperators[0].Name;
            }
        }
        else{
            singlePermit = null;
        }

        return JSON.serialize(singlePermit);
    }

    /**
    * @description - Updates the operator account and related officer contacts with data from mainframe
    * @author Mark Frizzell | 8/9/2019
    * @param SObject sfData - Salesforce record data (no child records)
    * @param Object mfData - Mainframe data, including children
    * @return String - Result message
    */
    @AuraEnabled
    public static String updateOperator(SObject sfRecord, String mfJSON) {
        System.debug(sfRecord);
        System.debug(mfJSON);

        OperatorWrapper mfData = (OperatorWrapper) JSON.deserialize(mfJSON, OperatorWrapper.class);
        Operators convertedOperators = new Operators(new List<Operators.Operator> {mfData.operator});
        Officers convertedOfficers = new Officers();
        convertedOfficers.officers = mfData.officers;

        IETRS_P5_Controller ctrl = new IETRS_P5_Controller();
        try {
            ctrl.addOperator(convertedOperators);
            ctrl.addOfficer(convertedOfficers);
            return 'Success';
        } catch (Exception e) {
            return e.getTypeName() + ': ' + e.getMessage() + ': ' + e.getLineNumber();
        }
        
        /*List<SObject> updates = new List<SObject>();

        // Operator account
        updates.add(new Account(
            Id                   = sfRecord.Id,
            Name                 = mfData.operator.operatorName != null ? mfData.operator.operatorName : '',
            IETRS_Status__c      = mfData.operator.operatorStatus != null ? mfData.operator.operatorStatus : '',
            // Organization_Type__c = mfData.operator.operatorType == 'LIMITED LIAB COMPANY' ? 'LLC' : mfData.operator.operatorType,
            BillingStreet        = mfData.operator.billingAddress != null ? mfData.operator.billingAddress : '',
            BillingCity          = mfData.operator.billingCity != null ? mfData.operator.billingCity : '',
            BillingState         = mfData.operator.billingState != null ? mfData.operator.billingState : '',
            BillingPostalCode    = mfData.operator.billingZip != null ? mfData.operator.billingZip : '',
            ShippingStreet       = mfData.operator.locationAddress != null ? mfData.operator.locationAddress : '',
            ShippingCity         = mfData.operator.locationCity != null ? mfData.operator.locationCity : '',
            ShippingState        = mfData.operator.locationState != null ? mfData.operator.locationState : '',
            ShippingPostalCode   = mfData.operator.locationZip != null ? mfData.operator.locationZip : '',
            Phone                = mfData.operator.operatorPhone != null ? mfData.operator.operatorPhone : '',
            IETRS_TNR_91114__c   = mfData.operator.tnr91_114 == 'Yes',
            IETRS_Last_Change__c = Date.today()
        ));

        // Child records don't pass from lightning to apex
        List<Contact> contacts = [SELECT Id, Name, FirstName, LastName, Title, Email, Phone 
                                  FROM Contact 
                                  WHERE AccountId = :sfRecord.Id];

        // Officer contacts
        for(Officers.Officer off : mfData.officers) {
            Boolean found = false;
            List<String> nameParts = new List<String>();
            nameParts.addAll(off.officerName.split(', '));
            String mfFirstName = nameParts.size() == 2 ? nameParts[1] : '',
                   mfLastName  = nameParts.size() >= 1 ? nameParts[0] : '';
            
            Contact tempCont = new Contact(
                Title                   = off.officerTitle != null ? off.officerTitle : '',
                MailingStreet           = off.billingAddress != null ? off.billingAddress : '',
                MailingCity             = off.billingCity != null ? off.billingCity : '',
                MailingState            = off.billingState != null ? off.billingState : '',
                MailingPostalCode       = off.billingZip != null ? off.billingZip : '',
                OtherStreet             = off.locationAddress != null ? off.locationAddress : '',
                OtherCity               = off.locationCity != null ? off.locationCity : '',
                OtherState              = off.locationState != null ? off.locationState : '',
                OtherPostalCode         = off.locationZip != null ? off.locationZip : '',
                IETRS_Last_Change__c    = Date.today(),
                IETRS_Contact_Type__c   = off.type_Z == 'OFFICER' ? 'Officer' : 'Agent'
            );

            for(Contact cont : contacts) {
                String sfFirstName = cont.FirstName != null ? cont.FirstName : '';
                String sfLastName = cont.LastName != null ? cont.LastName : '';

                System.debug('sf: ' + sfFirstName + ' ' + sfLastName);
                System.debug('mf: ' + mfFirstName + ' ' + mfLastName);

                // Try to match first name and last name as they are in the systems
                if((mfFirstName + mfLastName).equalsIgnoreCase(sfFirstName + sfLastName)) {
                    tempCont.Id = cont.Id;
                    found = true;
                } 
                // Try again, removing any possible middle name or middle initial (TODO: use string.difference or compareIgnoreCase for this?)
                else {
                    sfFirstName = sfFirstName.containsAny(' ') ? sfFirstName.split(' ')[0] : sfFirstName;
                    mfFirstName = mfFirstName.containsAny(' ') ? mfFirstName.split(' ')[0] : mfFirstName;
                    if((mfFirstName + mfLastName).equalsIgnoreCase(sfFirstName + sfLastName)) {
                        tempCont.Id = cont.Id;
                        found = true;
                    }
                }
            }
            if(!found) {
                tempCont.AccountId = sfRecord.Id;
                tempCont.FirstName = mfFirstName;
                tempCont.LastName  = mfLastName;
            }
            updates.add(tempCont);
        }
        return upsertRecords(updates);
        */
    }


    /**
    * @description - Updates the lease account and related well accounts with data from mainframe
    * @author Mark Frizzell | 8/9/2019
    * @param SObject sfData - Salesforce record data (no child records)
    * @param Object mfData - Mainframe data, including children
    * @return String - Result message
    */
    @AuraEnabled
    public static String updateLease(SObject sfRecord, String mfJSON) {
        System.debug(sfRecord);
        System.debug(mfJSON);

        LeaseWrapper mfData = (LeaseWrapper) JSON.deserialize(mfJSON, LeaseWrapper.class);

        //Convert to Leases and Wells object to take advantage of exiting controller
        List<Leases.Lease> listLeases = new List<Leases.Lease>();
        listLeases.add(mfData.lease);
        
        Leases convertedLease = new Leases(listLeases);
        Wells convertedWells = new Wells(mfData.wells);

        IETRS_Oil_And_Gas_Controller ctrl = new IETRS_Oil_And_Gas_Controller();
        try{
            ctrl.addLease(convertedLease);
            ctrl.addWell(convertedWells);
            return 'Success';
        } catch(Exception ex){
            return ex.getMessage();
        }
    }

    /**
    * @description Updates drilling permits and permitted fields
    * @author Kevin Lu | 10/15/2019 
    * @param SObject sfData - Salesforce record data (no child records)
    * @param mfJSON JSON String representing the permit and fields
    * @return String "Success" if successful, error message otherwise
    **/
    @AuraEnabled
    public static String updateDrillingPermit(SObject sfRecord, String mfJSON) {
        IETRS_Oil_And_Gas_Controller ctrl = new IETRS_Oil_And_Gas_Controller();
        IETRS_DrillingPermits permits = IETRS_DrillingPermits.parse(mfJSON);

        return ctrl.addDrillingPermits(permits);
    }

        /**
    * @description Updates uic permits and permitted fields
    * @author Forrest Chang | 07/10/2020
    * @param SObject sfData - Salesforce record data (no child records)
    * @param mfJSON JSON String representing the permit and fields
    * @return String "Success" if successful, error message otherwise
    **/
    @AuraEnabled
    public static String updateUICPermit(SObject sfRecord, String mfJSON) {
        IETRS_Oil_And_Gas_Controller ctrl = new IETRS_Oil_And_Gas_Controller();
        UIC permits = UIC.parse(mfJSON);

        List<Account> lstUIC = ctrl.addUIC(permits.uicinfo, null);
        return lstUIC != null && lstUIC.size() > 0 ? 'Success' : 'Error';
    }

    /**
    * @description - Updates or inserts records
    * @author Mark Frizzell | 8/14/2019
    * @param List<SObject> records - List of records to upsert
    * @return String - Result
    */
    /*private static String upsertRecords(List<SObject> records) {

        // Split updates/inserts because upsert doesn't support List<SObject>
        List<SObject> updates = new List<SObject>();
        List<SObject> inserts = new List<SObject>();
        for(SObject obj : records) {
            if(obj.Id == null) {
                inserts.add(obj);
            } else {
                updates.add(obj);
            }
        }

        // Commit changes
        Savepoint sp = Database.setSavepoint();
        try {
            update updates;
            insert inserts;
            return 'Success';
        } catch(Exception ex) {
            Database.rollback(sp);
            System.debug('Error: ' + ex.getMessage() + ' @ ' + ex.getLineNumber());
            return ex.getMessage();
        }
    }*/
    
}