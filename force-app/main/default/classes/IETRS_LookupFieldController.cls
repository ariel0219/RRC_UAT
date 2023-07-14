/**
 * @File Name          : IETRS_LookupFieldController.cls
 * @Description        : 
 * @Author             : Mark Frizzell
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 2/27/2020, 4:44:20 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    7/8/2019              Mark Frizzell     Initial Version
 * 1.1    7/9/2019              Mark Frizzell     Allow user to select multiple records
 * 1.2    7/11/2019             Mark Frizzell     Add mainframe search methods
 * 1.3    7/19/2019             Mark Frizzell     Update mainframe searches
 * 1.4    8/21/2019             Kevin Lu          Updated district lookup to look for only O/G districts
 * 1.5    10/23/2019            Kevin Lu          Added drilling permit functions
 * 1.6    01/08/2020            Kevin Lu          Added check to drilling permit search function in case related organization does not exist
 * 1.7    02/14/2020            Kevin Lu          Modified sObject search for Accounts to return exact matches at the front of the list
 * 1.8    02/27/2020            Kevin Lu          Change exact match search query for sObjects to include record type filter
 * 1.9    06/11/2020            Forrest Chang     Added UIC Search and Import methods
**/
public with sharing class IETRS_LookupFieldController {
    

    /**
    * @description Load record details for the specified record ID
    * @author Mark Frizzell | 8/5/2019
    * @param String recordIds
    * @return List<SObject>
    */
    @AuraEnabled
    public static List<SObject> loadRecordDetails(String recordIds) {
        if(recordIds != null) {
            try {
                List<Id> recIdList = recordIds.split(',');
                String objectName = recIdList[0].getSobjectType().getDescribe().getName();
                List<SObject> results = new List<SObject>();

                if(objectName == 'Case') {
                    results = [SELECT Id, CaseNumber FROM Case WHERE Id IN :recIdList];
                } else {
                    results = Database.query('SELECT Id, Name FROM ' + objectName + ' WHERE Id IN :recIdList');
                }
                return results;
            } catch(Exception ex) {
                System.debug('ERROR: ' + ex.getMessage() + ' @ ' + ex.getLineNumber());
                return null;
            }
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static List<SelectOption> loadDistricts() {
        List<SelectOption> options = new List<SelectOption>();
        for(IETRS_County_Group__c district : [SELECT Name FROM IETRS_County_Group__c WHERE IETRS_Group_Type__c = 'District' And IETRS_Business_Area__c = 'Oil and Gas' ORDER BY Name ASC]) {
            options.add(new SelectOption(
                district.Name, 
                district.Name.split('-')[0]
            ));
        }
        return options;
    }

    /**
    * @description Searches for records in the specified SObject
    * @author Mark Frizzell | 7/26/2019
    * @param String searchString - Input text to search for
    * @param String objectName - Name of SObject to search
    * @param String recordType - Record Type API name to limit search results
    * @param List<SObject> excludeItems - List of items already selected that should be excluded from search results
    * @return List<SObject> - List of records that match search criteria
    */
    @AuraEnabled
    public static List<SObject> searchSObject(String searchString, String objectName, String recordType, List<SObject> excludeItems) {
        List<SObject> results = new List<SObject>();
        Set<Id> excludeIds = new Set<Id>();
        searchString = '%' + searchString + '%';
        String qry = ''; 
        System.debug('searchString: ' + searchString);

        // Get excluded Ids
        if(excludeItems != null) {
            for(SObject obj : excludeItems) {
                excludeIds.add(obj.Id);
            }
        }
        System.debug('excludeIds: ' + excludeIds);
        
        // Build query
        switch on objectName {
            when 'Case' {
                qry =  'SELECT Id, CaseNumber, Account.Name, RecordType.Name ' +
                       'FROM Case ' +
                       'WHERE CaseNumber LIKE :searchString';
            }
            when 'Account' {
                //Add exact matches to the front of the results
                String originalSearchString = searchString.replace('%', '');
                qry = 'Select Id, Name, Owner.Name, RecordType.Name ' + 
                        'From Account ' +  
                        'Where (Name = :originalSearchString ' + 
                        'OR IETRS_P5_Number__c = :originalSearchString ' + 
                        'OR IETRS_Company_ID__c = :originalSearchString ' + 
                        'OR IETRS_Lease_Number__c = :originalSearchString  ' + 
                        'OR IETRS_Well_External_Id__c = :originalSearchString)';
                if(recordType != null && recordType != '') {
                    qry += ' AND RecordType.DeveloperName = :recordType ';
                }
                qry += ' AND Id NOT IN :excludeIds ORDER BY CreatedDate DESC LIMIT 5';

                for(SObject res : Database.query(qry)) {
                    results.add(res);
                    excludeIds.add(res.Id);
                }
                
                //Run the search with LIKES
                qry =  'SELECT Id, Name, Owner.Name, RecordType.Name ' +
                       'FROM Account ' +
                       'WHERE (' +
                            'Name LIKE :searchString ' +
                            'OR IETRS_P5_Number__c LIKE :searchString ' +
                            'OR IETRS_Company_ID__c LIKE :searchString ' +
                            'OR IETRS_Lease_Number__c LIKE :searchString ' + 
                            'OR IETRS_Well_External_Id__c LIKE :searchString ' +
                            'OR Id = :searchString ' +
                        ')';
            }
            when else {
                qry =  'SELECT Id, Name, Owner.Name ' +
                       'FROM ' + objectName + ' ' +
                       'WHERE Name LIKE :searchString';
            }
        }
        if(recordType != null && recordType != '') {
            qry += ' AND RecordType.DeveloperName = :recordType ';
        }
        qry += ' AND Id NOT IN :excludeIds ORDER BY CreatedDate DESC LIMIT 5';
        System.debug('qry: ' + qry);

        // Get query results
        for(SObject obj : Database.query(qry)) {
            //Exact match query may result in more than 5 total records, so only add partial matches up to 5 total results
            if(results.size() >= 5){
                break;
            }
            results.add(obj);
        }
        System.debug('results: ' + results.size());
        return results;
    }

    /**
    * @description - Search for operators by number or name in RRC mainframe
    * @author Mark Frizzell | 7/26/2019
    * @param String searchString - Search text (operator name or P5 number)
    * @return Operators - Results from mainframe search
    */
    @AuraEnabled
    public static String searchOperators(String searchString) {
        Operators results = new Operators();
        Boolean validOperatorNumber = String.isBlank(searchString) ? false : IETRS_Input_Validation.validOperatorNumber(searchString);
        Boolean validOperatorNameSegment = String.isBlank(searchString) ? false : IETRS_Input_Validation.validOperatorNameSegment(searchString);
        System.debug('validOperatorNumber: ' + validOperatorNumber);
        System.debug('validOperatorNameSegment: ' + validOperatorNameSegment);

        if(validOperatorNumber) {
            System.debug('getP5OperatorsByNumber');
            IETRS_Web_Services wSvc = new IETRS_Web_Services();
            results = wSvc.getP5OperatorsByNumber(searchString);
        } else if(validOperatorNameSegment) {
            System.debug('getP5OperatorsByName');
            IETRS_Web_Services wSvc = new IETRS_Web_Services();
            results = wSvc.getP5OperatorsByName(searchString);
        }

        System.debug('results: ' + results);
        return JSON.serialize(results.operators);
    }

    /**
    * @description - Search for officers by operator number in RRC mainframe
    * @author Mark Frizzell | 7/26/2019
    * @param String operatorNumber - Operator number to search for
    * @return Leases - Results from mainframe search
    */
    @AuraEnabled
    public static String searchOfficers(String operatorNumber) {
        Officers results = new Officers();
        Boolean validOperatorNumber = String.isBlank(operatorNumber) ? false : IETRS_Input_Validation.validOperatorNumber(operatorNumber);
        System.debug('validOperatorNumber: ' + validOperatorNumber);

        if(validOperatorNumber) {
            System.debug('getP5OperatorsByNumber');
            IETRS_Web_Services wSvc = new IETRS_Web_Services();
            results = wSvc.getP5Officers(operatorNumber);
        }
        
        System.debug('results: ' + results);
        return JSON.serialize(results.officers);
    }

    /**
    * @description - Search for leases by number and district in RRC mainframe
    * @author Mark Frizzell | 7/26/2019
    * @param String leaseNumber - Search text (lease number)
    * @param String districtCode - 2 digit district code
    * @return Leases - Results from mainframe search
    */
    @AuraEnabled
    public static String searchLeases(String leaseNumber, String districtCode) {
        Leases results = new Leases();
        Boolean validLeaseNumber = String.isBlank(leaseNumber) ? false : IETRS_Input_Validation.validLeaseNumber(leaseNumber);
        Boolean validDistrictCode = String.isBlank(districtCode) ? false : IETRS_Input_Validation.validDistrictCode(districtCode);
        System.debug('validLeaseNumber: ' + validLeaseNumber);
        System.debug('validDistrictCode: ' + validDistrictCode);

        if(validLeaseNumber && validDistrictCode) {
            IETRS_Web_Services wSvc = new IETRS_Web_Services();
            results = wSvc.getLeases(districtCode, leaseNumber);            
        }
        
        System.debug('results: ' + results);
        return JSON.serialize(results.leases);
    }

    /**
    * @description - Search for wells by lease number and district in RRC mainframe
    * @author Mark Frizzell | 7/26/2019
    * @param String leaseNumber - Search text (lease number)
    * @param String districtCode - 2 digit district code
    * @return Leases - Results from mainframe search
    */
    @AuraEnabled
    public static String searchWells(String leaseNumber, String districtCode) {
        Wells results = new Wells();
        Boolean validLeaseNumber = String.isBlank(leaseNumber) ? false : IETRS_Input_Validation.validLeaseNumber(leaseNumber);
        Boolean validDistrictCode = String.isBlank(districtCode) ? false : IETRS_Input_Validation.validDistrictCode(districtCode);
        System.debug('validLeaseNumber: ' + validLeaseNumber);
        System.debug('validDistrictCode: ' + validDistrictCode);

        if(validLeaseNumber && validDistrictCode) {
            IETRS_Web_Services wSvc = new IETRS_Web_Services();
            results = wSvc.getWellsByLease(districtCode, leaseNumber);
        }
        
        System.debug('results: ' + results);
        return JSON.serialize(results.wells);
    }

    /**
    * @description - Search for drilling permits by permit number
    * @author Kevin Lu | 10/22/2019 
    * @param drillingPermitNumber - Search text (drilling permit number)
    * @return String - List of drilling permits from mainframe
    **/
    @AuraEnabled
    public static String searchDrillingPermits(String drillingPermitNumber) {
        IETRS_DrillingPermits results = null;
        Boolean validDrillingPermitNumber = String.isBlank(drillingPermitNumber) ? false : IETRS_Input_Validation.validOperatorNumber(drillingPermitNumber);

        if(validDrillingPermitNumber) {
            IETRS_Web_Services wSvc = new IETRS_Web_Services();
            results = wSvc.getDrillingPermitsByNumber(drillingPermitNumber);

            //Find and populate the operator name
            if(results != null) {
                List<Account> lstAcctOperator = [Select Id, Name, IETRS_P5_Number__c From Account Where IETRS_P5_Number__c = :results.operatorNumber Limit 1];
                if(lstAcctOperator.size() == 1) {
                    Account acctOperator = lstAcctOperator.get(0);
                    results.operatorName = acctOperator.Name;
                }
            }
        }
        
        System.debug('results: ' + results);
        return JSON.serialize(results);
    }

    /**
    * @description - Search for UICs by API number
    * @author Forrest Chang | 6/11/2020 
    * @param apiNumber - Search text (API number)
    * @return String - List of drilling permits from mainframe
    **/
    @AuraEnabled
    public static String searchUIC(String apiNumber) {
        UIC results = new UIC();
        Boolean validAPINumber = String.isBlank(apiNumber) ? false : IETRS_Input_Validation.validAPINumber(apiNumber);

        if(validAPINumber) {
            IETRS_Web_Services wSvc = new IETRS_Web_Services();
            results = wSvc.getUICByAPI(apiNumber);
        }
        
        System.debug('results: ' + results.uicinfo);
        return JSON.serialize(results.uicinfo);
    }

    /**
    * @description - Creates operator account and officer contact records with data from RRC
    * @author Mark Frizzell | 7/26/2019
    * @param String operatorsJSON - Operator JSON data
    * @return List<Account> - New operator accounts
    */
    @AuraEnabled
    public static List<Account> addOperators(String operatorsJSON) {
        Operators opsList = Operators.parse(operatorsJSON);
        Officers offList = new Officers();
        
        IETRS_Web_Services wSvc = new IETRS_Web_Services();
        for(Operators.Operator op : opsList.operators) {
            offList = wSvc.getP5Officers(op.operatorNumber);
        }

        IETRS_P5_Controller p5Ctrl = new IETRS_P5_Controller();
        List<Account> opAccounts = p5Ctrl.addOperator(opsList);
        List<Contact> offContacts = p5Ctrl.addOfficer(offList);

        return opAccounts;
    }

    @AuraEnabled
    public static List<Account> addSingleOperatorWithoutUpdatingOfficer(String operatorsJSON) {
        Operators opsList = Operators.parse(operatorsJSON);
        IETRS_P5_Controller p5Ctrl = new IETRS_P5_Controller();
        List<Account> opAccounts = p5Ctrl.addOperator(opsList);

        return opAccounts;
    }

    /**
    * @description - Creates officer contact records with data from RRC
    * @author Mark Frizzell | 7/26/2019
    * @param List<String> officersJSON - Officers JSON data
    * @return List<Contact> - New officer contacts
    */
    @AuraEnabled
    public static List<Contact> addOfficers(String officersJSON) {
        Officers officersObj = Officers.parse(officersJSON);        
        IETRS_P5_Controller p5Ctrl = new IETRS_P5_Controller();
        return p5Ctrl.addOfficer(officersObj);
    }

    /**
    * @description - Creates lease and well accounts with data from RRC
    * @author Mark Frizzell | 7/26/2019
    * @param String leasesJSON - Lease JSON data
    * @return List<Account> - New lease accounts
    */
    @AuraEnabled
    public static List<Account> addLeases(String leasesJSON) {
        Leases leaseList = Leases.parse(leasesJSON);
        Wells wellList = new Wells();
        IETRS_Web_Services wSvc = new IETRS_Web_Services();

        for(Leases.Lease ls : leaseList.leases) {
            wellList = wSvc.getWellsByLease(ls.districtCode, ls.leaseNumber);
        }

        IETRS_Oil_And_Gas_Controller ogCtrl = new IETRS_Oil_And_Gas_Controller();
        List<Account> leaseAccounts = ogCtrl.addLease(leaseList);
        List<Account> wellAccounts = ogCtrl.addWell(wellList);

        return leaseAccounts;
    }

    /**
    * @description - Creates well accounts with data from RRC
    * @author Mark Frizzell | 7/26/2019
    * @param String wellsJSON - Well JSON data
    * @return List<Account> - New well accounts
    */
    @AuraEnabled
    public static List<Account> addWells(String wellsJSON) {
        Wells wellsObj = Wells.parse(wellsJSON);        
        IETRS_Oil_And_Gas_Controller ogCtrl = new IETRS_Oil_And_Gas_Controller();
        return ogCtrl.addWell(wellsObj);
    }


    /**
    * @description - Creates drilling permit accounts with data from RRC
    * @author Kevin Lu | 10/22/2019 
    * @param drillingPermitsJSON - Drilling Permit JSON data
    * @return String - 'Success' or an error message
    **/
    @AuraEnabled
    public static String addDrillingPermits(String drillingPermitsJSON) {
        IETRS_DrillingPermits drillingPermitsObj = IETRS_DrillingPermits.parse(drillingPermitsJSON);        
        IETRS_Oil_And_Gas_Controller ogCtrl = new IETRS_Oil_And_Gas_Controller();
        return ogCtrl.addDrillingPermits(drillingPermitsObj);
    }

    /**
    * @description - Creates UIC accounts with data from RRC
    * @author Forrest Chang | 06/11/2020 
    * @param uicJSON - UIC JSON data
    * @return List<Account> - New UIC accounts
    **/
    @AuraEnabled
    public static List<Account> addUIC(String uicJSON) {
        UIC uicObj = UIC.parse(uicJSON);
        system.debug('uicObj');
        system.debug(uicObj);
        IETRS_Oil_And_Gas_Controller ogCtrl = new IETRS_Oil_And_Gas_Controller();
        return ogCtrl.addUIC(uicObj.Uicinfo, null);
    }




    // SelectOption type isn't AuraEnabled, so using our own
    public Class SelectOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }

        public SelectOption(String pLabel, String pValue) {
            label = pLabel;
            value = pValue;
        }
    }
    
}