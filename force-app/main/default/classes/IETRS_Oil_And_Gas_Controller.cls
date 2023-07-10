/**
 * @File Name          : IETRS_Oil_And_Gas_Controller.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 2020-07-20
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    06/17/2019, 12:07:30 PM   Chris McKee     Initial Version
 * 1.1    07/19/2019                Mark Frizzell   Update return types for lease and well methods
 * 1.2    08/05/2019                Kevin Lu        Added mapping for IETRS_Last_Change__c
 * 1.3    08/06/2019                Kevin Lu        Updating well name mapping
 * 1.4    09/03/2019                Kevin Lu        Trimmed well number in Name so that users can search properly
 * 1.5    10/15/2019                Kevin Lu        Added Drilling Permit functionality
 * 1.6    10/31/2019                Kevin Lu        Mapped RRC Legacy Number
                                                    Added geographical/parent field creation
 * 1.7    11/15/2019                Kevin Lu        Modified well name mapping to remove spaces from well number
 * 1.8    12/11/2019                Kevin Lu        Modified permitted field name mapping to include sequence/version number
 * 1.9    12/19/2019				Kevin Lu		Changed county map setting for drilling permits to store all-uppercase county name as key
 * 2.0    01/15/2020                Kevin Lu        Changed lease name mapping to include lease number and district code
 * 2.1    01/27/2020                Kevin Lu        Added IETRS_Last_Change__c mapping for Drilling Permits
 * 2.2    02/17/2020                Kevin Lu        Changed addWell by reducing number of loops to improve performance
 * 2.3    03/18/2020                Kevin Lu        Updated mappings to use "Integrations User" as the owner
 * 2.4    03/19/2020                Kevin Lu        Modified Drilling Permit load to run future apex to set exception flags
 * 2.5    03/25/2020                Kevin Lu        Updated Physical Field Name mapping
 * 3.0    04/22/2020                Kevin Lu        Added mappings for Phase 2 Drilling Permit fields
 * 3.1    05/12/2020                Kevin Lu        Added UIC mapping/consumption
 * 3.2    06/11/2020                Kevin Lu        Updated UIC mapping to include more information
 * 3.3    07/01/2020                Kevin Lu        Added GFC mapping/consumption
 * 3.4    07/15/2020                Kevin Lu        Updated UIC mapping to populate Organization lookup based on operator number (if possible)
                                                    Added GFC method to deactivate holds that aren't in mainframe anymore
 * 3.5    07/20/2020                Kevin Lu        Changed UIC Parent Logic to avoid nulls
**/
public with sharing class IETRS_Oil_And_Gas_Controller {
   	private List<Account> acctsWells;
    private List<Account> acctsLeases;
    private RecordType recordTypeOG;
    private RecordType recordTypeField;
    private RecordType recordTypeGFCHold;
    private User integrationsUser;
        
    public IETRS_Oil_And_Gas_Controller() {
        acctsWells = new List<Account>();
        acctsLeases = new List<Account>();
        recordTypeOG = [Select Id From RecordType Where SObjectType = 'Account' And Name = 'Regulated Entity - OG'].get(0);
        recordTypeField = [Select Id From RecordType Where SObjectType = 'Account' And Name = 'Field'].get(0);
        recordTypeGFCHold = [Select Id From RecordType Where SObjectType = 'IETRS_Hold__c' And Name = 'Good Faith Claim Hold' Limit 1];
        integrationsUser = [Select Id, Name From User Where Name = 'Integrations User' Limit 1];
    }

    /**
    * @description Loads UIC records
    * @author Kevin Lu | 5/13/2020 
    * @param mfUIC A list of UIC information
    * @param mapUICWellExternalIds A map of UIC Number keys and corresponding well external ID values
    * @return List<Account> The list of UIC records that were added
    **/
    public List<Account> addUIC(List<UIC.Uicinfo> mfUIC, Map<String,String> mapUICWellExternalIds) {
        List<Account> lstUIC = new List<Account>();
        Set<String> setDistrictNumbers = new Set<String>();
        Set<String> setCountyNames = new Set<String>();
        Set<String> setOperatorNumbers = new Set<String>();
        Map<String,Id> mapDistrict = new Map<String,Id>();
        Map<String,Id> mapCounty = new Map<String,Id>();
        Map<String,Account> mapWellIds = new Map<String,Account>();
        Map<String,Id> mapOperatorNumbers = new Map<String,Id>();
        for(UIC.Uicinfo uic : mfUIC) {
            setDistrictNumbers.add(uic.districtCode + '|OG');
            setCountyNames.add(uic.county.toUpperCase());
            if(!String.isBlank(uic.operatorNumber)) {
                setOperatorNumbers.add(uic.operatorNumber);
            }
        }

        //Build map of well IDs
        if(mapUICWellExternalIds != null) {
            for(Account acctWell : [
                Select Id, IETRS_Well_External_Id__c, IETRS_OrganizationofRegEntity__c
                From Account
                Where IETRS_Well_External_Id__c In :mapUICWellExternalIds.values()
            ]) {
                mapWellIds.put(acctWell.IETRS_Well_External_Id__c, acctWell);
            }
        }

        //Build map of operator numbers
        if(!setOperatorNumbers.isEmpty()) {
            for(Account acctOperator : [
                Select Id, IETRS_P5_Number__c
                From Account
                Where IETRS_P5_Number__c In :setOperatorNumbers
            ]) {
                mapOperatorNumbers.put(acctOperator.IETRS_P5_Number__c, acctOperator.Id);
            }
        }

        //Build the map of districtCode and Salesforce IDs
        for(IETRS_County_Group__c district : [Select Id, IETRS_County_Group_External_ID__c From IETRS_County_Group__c Where IETRS_County_Group_External_ID__c In :setDistrictNumbers]){
            mapDistrict.put(district.IETRS_County_Group_External_ID__c, district.Id);
        }

        //Build the map of County codes and Salesforce IDs
        for(IETRS_County__c county : [Select Id, Name From IETRS_County__c Where Name In :setCountyNames]){
            mapCounty.put(county.Name.toUpperCase(), county.Id);
        }
        
        for(UIC.Uicinfo uic : mfUIC) {
            Account acctUIC = new Account(
                Name = 'UIC - ' + uic.uicNumber,
                IETRS_UIC_Number__c = uic.uicNumber,
                IETRS_UIC_Permit_Number__c = uic.uicPermitNumber,
                IETRS_UIC_Project_Number__c = uic.uicProjectNumber,
                IETRS_Well_Number__c = uic.wellNumber,
                IETRS_Lease_Number__c = uic.leaseNumber,
                IETRS_API__c = uic.apiNumber,
                IETRS_Field_Name__c = uic.fieldName,
                IETRS_Field_Number__c = uic.fieldNumber,
                RecordTypeId = recordTypeOG.Id,
                //ParentId = mapUICWellExternalIds == null ? null : mapWellIds.get(mapUICWellExternalIds.get(uic.uicNumber)).Id,
                IETRS_OrganizationofRegEntity__c = mapUICWellExternalIds == null ? mapOperatorNumbers.get(uic.operatorNumber) : mapWellIds.get(mapUICWellExternalIds.get(uic.uicNumber)).IETRS_OrganizationofRegEntity__c,
                IETRS_District__c = mapDistrict.get(uic.districtCode + '|OG'),
                IETRS_County__c = mapCounty.get(uic.county.toUpperCase()),
                Type = 'UIC Permit',
                IETRS_Last_Change__c = Date.today(),
                OwnerId = integrationsUser.Id
            );
            if(mapUICWellExternalIds != null) {
                acctUIC.ParentId = mapWellIds.get(mapUICWellExternalIds.get(uic.uicNumber)).Id;
            }
            lstUIC.add(acctUIC);
        }

        try {
            upsert lstUIC IETRS_UIC_Number__c;
            return lstUIC;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
    
    public List<Account> addWell(Wells mfWell) {
        //Sets and Maps for lookup field mappings
        //Operators - P5 Number
        Map<String,Id> mapOperators = new Map<String, Id>();
        Set<String> setOperatorNumbers = new Set<String>();
        //Districts
        Map<String,Id> mapDistrict = new Map<String, Id>();
        Set<String> setDistrictNumbers = new Set<String>();
        //Counties
        Map<String,Id> mapCounty = new Map<String, Id>();
        Set<String> setCountyCode = new Set<String>();
        //Leases
        Map<String,Id> mapLease = new Map<String, Id>();
        Set<String> setLeaseNumbers = new Set<String>();
        //UIC
        List<UIC.Uicinfo> listUIC = new List<UIC.Uicinfo>();
        Map<String,String> mapUICWellExternalIds = new Map<String,String>();

        //Populate Sets for Lookups
        for(Wells.Well currentWell : mfWell.wells){
            setOperatorNumbers.add(currentWell.operatorNumber);
            setDistrictNumbers.add(currentWell.districtCode + '|OG');
            setCountyCode.add(currentWell.county);
            setLeaseNumbers.add(currentWell.leaseNumber + '|' + currentWell.districtCode);
        }

        //Build the map of Operator Numbers and Salesforce IDs
        for(Account acctOperator : [Select Id, IETRS_P5_Number__c From Account Where IETRS_P5_Number__c In :setOperatorNumbers]){
            mapOperators.put(acctOperator.IETRS_P5_Number__c, acctOperator.Id);
        }

        //Build the map of districtCode and Salesforce IDs
        for(IETRS_County_Group__c district : [Select Id, IETRS_County_Group_External_ID__c From IETRS_County_Group__c Where IETRS_County_Group_External_ID__c In :setDistrictNumbers]){
            mapDistrict.put(district.IETRS_County_Group_External_ID__c, district.Id);
        }

        //Build the map of County codes and Salesforce IDs
        for(IETRS_County__c county : [Select Id, Name From IETRS_County__c Where Name In :setCountyCode]){
            mapCounty.put(county.Name.toUpperCase(), county.Id);
        }

        //Build the map of Lease Number and Salesforce IDs
        for(Account acctLease : [Select Id, IETRS_External_Lease_Id__c From Account Where IETRS_External_Lease_Id__c In :setLeaseNumbers]){
            mapLease.put(acctLease.IETRS_External_Lease_Id__c, acctLease.Id);
        }
        
        ///////////////////////////////////////////////////////////////

        //Create List of new Wells Records for Upsert
        for(Wells.Well currentWell : mfWell.wells)
        {
            Account temp = new Account(
                //Internal Fields
                IETRS_API__c = currentWell.apiNumber,
                IETRS_Well_Number__c = currentWell.wellNumber,
                Name = 'Well '+ currentWell.wellNumber.replaceAll(' ', '') + ' - Lease ' + currentWell.leaseNumber + ' - District ' + currentWell.districtCode,
                Type = 'Well',
                IETRS_Last_Change__c = Date.today(),
                OwnerId = integrationsUser.Id,
                //Lookups
                IETRS_OrganizationofRegEntity__c = mapOperators.get(currentWell.operatorNumber),
                IETRS_District__c = mapDistrict.get(currentWell.districtCode + '|OG'),
                IETRS_County__c = mapCounty.get(currentWell.county),
                ParentId = mapLease.get(currentWell.leaseNumber + '|' + currentWell.districtCode),
                //External Field
                IETRS_Well_External_Id__c = currentWell.leaseNumber + '|' + currentWell.districtCode + '|' + currentWell.apiNumber + '|' + currentWell.wellNumber,
                //Record Type
                RecordTypeId = recordTypeOG.Id
            );
            temp.IETRS_Well_External_Id__c = temp.IETRS_Well_External_Id__c.trim();
            
            //Add Well to Wells List for upsert
            acctsWells.add(temp);

            //If exists, process UIC information
            if(currentWell.uicList != null && currentWell.uicList.size() > 0) {
                for(UIC.Uicinfo uicPermit : currentWell.uicList) {
                    mapUICWellExternalIds.put(uicPermit.uicNumber, temp.IETRS_Well_External_Id__c);
                    uicPermit.wellNumber = currentWell.wellNumber;
                    uicPermit.leaseNumber = currentWell.leaseNumber;
                    uicPermit.apiNumber = currentWell.apiNumber;
                    uicPermit.fieldName = currentWell.fieldName;
                    uicPermit.fieldNumber = currentWell.fieldNumber;
                    uicPermit.districtCode = currentWell.districtCode;
                    uicPermit.county = currentWell.county;
                }
                listUIC.addAll(currentWell.uicList);
            }
        }

        try {
            if(acctsWells.size() > 0) {
                upsert acctsWells IETRS_Well_External_Id__c;
                if(listUIC.size() > 0) {
                    addUIC(listUIC, mapUICWellExternalIds);
                }
                return acctsWells;
            }
            else {
                System.debug('Accounts-Wells list is empty');
                return null;
            }
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
    
    public List<Account> addLease(Leases mfLease) {
        //Used to store distinct lookup values
        Set<String> setOperatorNumbers = new Set<String>();
        Set<String> setDistrictNumbers = new Set<String>();
        Set<String> setFields = new Set<String>();
        List<Leases.Gfc> lstGFCHolds = new List<Leases.Gfc>();
        Map<String, String> mapGFCHoldKey = new Map<String, String>();

        //Get distinct values
        for(Leases.Lease currentLease : mfLease.leases) {
            setOperatorNumbers.add(currentLease.operatorNumber);
            setDistrictNumbers.add(currentLease.districtCode + '|OG');
            if(currentLease.fieldName != null && currentLease.fieldNumber != null) {
                setFields.add(currentLease.fieldNumber + '|' + currentLease.fieldName);
            }
            if(currentLease.gfc != null && currentLease.gfc.size() > 0) {
                for(Leases.GFC gfcHold : currentLease.gfc) {
                    lstGFCHolds.add(gfcHold);
                    mapGFCHoldKey.put(gfcHold.setDate + '|' + gfcHold.finalOrderDocketNumber, currentLease.leaseNumber + '|' + currentLease.districtCode);
                }
            }
        }

        //Load and upsert Field records
        List<Account> lstFieldAccounts = new List<Account>();
        for(String strField : setFields) {
            Account tempFieldAccount = new Account(
                Name = strField.substringAfter('|') + ' (' + strField.substringBefore('|') + ')',
                IETRS_Field_Name__c = strField.substringAfter('|'),
                IETRS_Field_Number__c = strField.substringBefore('|'),
                IETRS_Field_External_Id__c = strField,
                RecordTypeId = recordTypeField.Id,
                Type = 'Field',
                IETRS_Last_Change__c = Date.today(),
                OwnerId = integrationsUser.Id
            );
            lstFieldAccounts.add(tempFieldAccount);
        }
        try{
            upsert lstFieldAccounts IETRS_Field_External_Id__c;
        } 
        catch(DmlException e){
            System.debug(e.getMessage());
        }

        /*                     P5 Number Lookup                     */       
        //Used to Map link SalesForces ID to P5 Number
        Map<String, Id> mapOperators = lookupConverter('IETRS_P5_Number__c','Account',setOperatorNumbers);

        /*                     District Lookup                     */
        //Used to Map link SalesForces ID to district code
        Map<String, Id> mapDistrict = lookupConverter('IETRS_County_Group_External_ID__c','IETRS_County_Group__c',setDistrictNumbers);

        /*                      Field Lookup and Creation           */
        //Used to Map link SalesForces ID to fields
        Map<String, Id> mapField = lookupConverter('IETRS_Field_External_Id__c','Account',setFields);

        //Create List of new Lease Records for Upsert
        for(Leases.Lease currentLease : mfLease.leases) {
            Account temp = new Account(
                //Internal Fields
                Name = currentLease.leaseName + ' (' + currentLease.districtCode + '-' + currentLease.leaseNumber + ')',
                IETRS_Lease_Number__c = currentLease.leaseNumber,
                IETRS_Lease_Name__c = currentLease.leaseName,
                IETRS_Field_Name__c = currentLease.fieldName,
                IETRS_Field_Number__c = currentLease.fieldNumber,
                Type = 'Lease',
                IETRS_Last_Change__c = Date.today(),
                OwnerId = integrationsUser.Id,

                //Lookup Fields
                ParentId = mapOperators.get(currentLease.operatorNumber),
                IETRS_OrganizationofRegEntity__c = mapOperators.get(currentLease.operatorNumber),
                IETRS_District__c = mapDistrict.get(currentLease.districtCode + '|OG'),
                IETRS_Field__c = mapField.get(currentLease.fieldNumber + '|' + currentLease.fieldName),
                //External Field
                IETRS_External_Lease_Id__c = currentLease.leaseNumber + '|' + currentLease.districtCode,

                //Record Type
                RecordTypeId = recordTypeOG.Id
            );
            
            //Add lease to Leases List for upsert
            acctsLeases.add(temp);
        }

        try {
            if(acctsLeases.size() > 0) {
                upsert acctsLeases IETRS_External_Lease_Id__c;
                if(lstGFCHolds.size() > 0) {
                    addGFCHolds(lstGFCHolds, mapGFCHoldKey);
                }
                return acctsLeases;
            }
            else {
                System.debug('Accounts-Leases list is empty');
                return null;
            }
        }
        catch (DmlException e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    /**
    * @description Adds GFC Hold records
    * @author Kevin Lu | 7/1/2020 
    * @param lstGFCHolds The list of GFC Holds to add
    * @param mapGFCHoldKey A map with a key of the GFC Hold external ID and values of the Lease external ID
    * @return List<IETRS_Hold__c> 
    **/
    public List<IETRS_Hold__c> addGFCHolds(List<Leases.Gfc> lstGFCHolds, Map<String,String> mapGFCHoldKey) {
        Id gfcRecordTypeId = [
            Select Id 
            From RecordType
            Where SObjectType = 'IETRS_Hold__c'
            And Name = 'Good Faith Claim Hold'
            Limit 1
        ].Id;
        List<IETRS_Hold__c> lstHoldsToAdd = new List<IETRS_Hold__c>();
        Map<String, Id> mapLeaseId = new Map<String, Id>();
        for(Account acctLease : [
            Select Id, IETRS_External_Lease_Id__c
            From Account
            Where IETRS_External_Lease_Id__c In :mapGFCHoldKey.values()
        ]) {
            mapLeaseId.put(acctLease.IETRS_External_Lease_Id__c, acctLease.Id);
        }

        for(Leases.Gfc gfcHold : lstGFCHolds) {
            IETRS_Hold__c holdToAdd = new IETRS_Hold__c (
                IETRS_Final_Order_Docket_Number__c = gfcHold.finalOrderDocketNumber,
                IETRS_Set_By__c = gfcHold.setBy,
                IETRS_Set_Date__c = Date.parse(gfcHold.setDate.replaceAll('-', '/')),
                IETRS_GFC_External_Id__c = gfcHold.setDate + '|' + gfcHold.finalOrderDocketNumber,
                IETRS_Regulated_Entity__c = mapGFCHoldKey == null ? null : mapLeaseId.get(mapGFCHoldKey.get(gfcHold.setDate + '|' + gfcHold.finalOrderDocketNumber)),
                RecordTypeId = gfcRecordTypeId,
                OwnerId = integrationsUser.Id
            );
            lstHoldsToAdd.add(holdToAdd);
        }

        try {
            upsert lstHoldsToAdd IETRS_GFC_External_Id__c;
            IETRS_Oil_And_Gas_Controller.deactivateGFCHolds((new Map<Id,SObject>(lstHoldsToAdd)).keySet());
            return lstHoldsToAdd;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    /**
    * @description Adds drilling permit and permitted field records
    * @author Kevin Lu | 10/21/2019 
    * @param mfDrillingPermits The parsed JSON response for drilling permits
    * @return String "Success" if successful upsert: otherwise returns the error message
    **/
    public String addDrillingPermits(IETRS_DrillingPermits mfDrillingPermits){
        //Lists for upserts
        List<Account> lstDrillingPermits = new List<Account>();
        List<Account> lstFields = new List<Account>();
        List<Account> lstPermittedFields = new List<Account>();

        //Sets and maps for lookup values
        Set<String> setDistrictCodes = new Set<String>();
        Set<String> setCounties = new Set<String>();
        Set<String> setOperatorNumbers = new Set<String>();
        Set<String> setDrillingPermits = new Set<String>();
        Set<String> setFields = new Set<String>();

        Map<String,Id> mapDistrictCodes = new Map<String,Id>();
        Map<String,Id> mapCounties = new Map<String,Id>();
        Map<String,Id> mapOperatorNumbers = new Map<String,Id>();
        Map<String,Id> mapDrillingPermits = new Map<String,Id>();
        Map<String,Id> mapFields = new Map<String,Id>();

        //Populate sets
        for(IETRS_DrillingPermits.DrillingPermits permit : mfDrillingPermits.drillingPermits){
            setDistrictCodes.add(permit.districtCode + '|OG');
            setCounties.add(permit.countyName);
            setOperatorNumbers.add(permit.operatorNumber);
            for(IETRS_DrillingPermits.PermittedFields permittedField : permit.permittedFields){
                setDistrictCodes.add(permittedField.districtCode + '|OG');
            }
        }

        //Populate maps
        for(IETRS_County_Group__c district : [Select Id, IETRS_County_Group_External_Id__c From IETRS_County_Group__c Where IETRS_County_Group_External_Id__c In :setDistrictCodes]){
            mapDistrictCodes.put(district.IETRS_County_Group_External_Id__c, district.Id);
        }
        for(IETRS_County__c county : [Select Id, Name From IETRS_County__c Where Name In :setCounties]){
            mapCounties.put(county.Name.toUpperCase(), county.Id);
        }
        for(Account operator : [Select Id, IETRS_P5_Number__c From Account Where IETRS_P5_Number__c In :setOperatorNumbers]){
            mapOperatorNumbers.put(operator.IETRS_P5_Number__c, operator.Id);
        }

        //Map drilling permits
        for(IETRS_DrillingPermits.DrillingPermits permit : mfDrillingPermits.drillingPermits){
            Account acctTempDrillingPermit = new Account(
                RecordTypeId = recordTypeOG.Id,
                Type = 'Drilling Permit',
                Name = permit.drillingPermitNumber + '-' + permit.drillingPermitSequence,
                IETRS_Last_Change__c = Date.today(),
                OwnerId = integrationsUser.Id,
                IETRS_Drilling_Permit_Number__c = permit.drillingPermitNumber,
                IETRS_Drilling_Permit_Version__c = permit.drillingPermitSequence,
                IETRS_Lease_Name__c = permit.leaseName,
                IETRS_Well_Number__c = permit.wellNumber.trim(), //Well numbers tend to have lots of extra whitespace that isn't needed here
                IETRS_Drilling_Permit_Total_Depth__c = Integer.valueOf(permit.totalDepth),
                IETRS_API__c = permit.wellApiNumber,
                IETRS_Status__c = permit.permitStatus,
                IETRS_Surface_Location_Type__c = permit.surfaceLocationType,
                IETRS_Datum__c = permit.datum,
                IETRS_State_Plane_X__c = permit.statePlaneX != null ? Decimal.valueOf(permit.statePlaneX) : null,
                IETRS_State_Plane_Y__c = permit.statePlaneY != null ? Decimal.valueOf(permit.statePlaneY) : null,
                IETRS_State_Plane_Zone__c = permit.statePlaneZone,
                IETRS_Survey__c = permit.survey,
                IETRS_Section__c = permit.section,
                IETRS_Block__c = permit.block,
                IETRS_Abstract_Number__c = permit.abstractNumber,
                IETRS_Wellbore_Profiles__c = permit.wellboreProfiles,
                IETRS_Mainframe_Case_Number__c = permit.mainframeCaseNumber,
                //External ID
                IETRS_Drilling_Permit_External_Id__c = permit.drillingPermitNumber + '|' + permit.drillingPermitSequence,
                ParentId = mapOperatorNumbers.get(permit.operatorNumber),
                IETRS_OrganizationofRegEntity__c = mapOperatorNumbers.get(permit.operatorNumber),
                IETRS_District__c = mapDistrictCodes.get(permit.districtCode + '|OG'),
                IETRS_County__c = mapCounties.get(permit.countyName)
            );           
            if(permit.submittedDate != null){
                acctTempDrillingPermit.IETRS_Drilling_Permit_Submitted_Date__c = Date.parse(permit.submittedDate.replace('-', '/'));
            }
            if(permit.approvedDate != null){
                acctTempDrillingPermit.IETRS_Drilling_Permit_Approved_Date__c = Date.parse(permit.approvedDate.replace('-', '/'));
            }
            if(permit.latitudeDegree != null && permit.latitudeMinute != null && permit.latitudeSecond != null) {
                acctTempDrillingPermit.IETRS_Drilling_Permit_Location__Latitude__s = convertToDecimal(permit.latitudeDegree, permit.latitudeMinute, permit.latitudeSecond);
            }
            if(permit.longitudeDegree != null && permit.longitudeMinute != null && permit.longitudeSecond != null) {
                acctTempDrillingPermit.IETRS_Drilling_Permit_Location__Longitude__s = convertToDecimal(permit.longitudeDegree, permit.longitudeMinute, permit.longitudeSecond);
            }
            setDrillingPermits.add(permit.drillingPermitNumber + '|' + permit.drillingPermitSequence);

            lstDrillingPermits.add(acctTempDrillingPermit);
        }

        //Load Drilling Permits
        try{
            upsert lstDrillingPermits IETRS_Drilling_Permit_External_Id__c;
        } 
        catch(DmlException e){
            System.debug(e.getMessage());
            return e.getMessage();
        }

        //Populate drilling permit map
        for(Account permit : lstDrillingPermits){
            mapDrillingPermits.put(permit.IETRS_Drilling_Permit_External_Id__c, permit.Id);
        }

        //Map parent/geographical field records
        for(IETRS_DrillingPermits.DrillingPermits permit : mfDrillingPermits.drillingPermits){
            for(IETRS_DrillingPermits.PermittedFields permittedField : permit.permittedFields){
                if(!setFields.contains(permittedField.fieldNumber + '|' + permittedField.fieldName)){
                    setFields.add(permittedField.fieldNumber + '|' + permittedField.fieldName);

                    Account tempField = new Account(
                        Name = permittedField.fieldName + ' (' + permittedField.fieldNumber + ')',
                        IETRS_Field_Name__c = permittedField.fieldName,
                        IETRS_Field_Number__c = permittedField.fieldNumber,
                        IETRS_Field_External_Id__c = permittedField.fieldNumber + '|' + permittedField.fieldName,
                        Type = 'Field',
                        RecordTypeId = recordTypeField.Id,
                        IETRS_Last_Change__c = Date.today(),
                        OwnerId = integrationsUser.Id
                    );
                    lstFields.add(tempField);
                }
            }
        }

        //Load Parent/Geographical Fields
        try{
            upsert lstFields IETRS_Field_External_Id__c;
        } 
        catch(DmlException e){
            System.debug(e.getMessage());
            return e.getMessage();
        }

        //Populate field map
        for(Account field : lstFields){
            mapFields.put(field.IETRS_Field_External_Id__c, field.Id);
        }

        //Map Permitted Fields
        for(IETRS_DrillingPermits.DrillingPermits permit : mfDrillingPermits.drillingPermits){
            for(IETRS_DrillingPermits.PermittedFields permittedField : permit.permittedFields){
                Account acctTempPermittedField = new Account();

                acctTempPermittedField.IETRS_Permitted_Field_Primary_Field__c = permittedField.primaryField == 'Y';
                acctTempPermittedField.IETRS_Field_Name__c = permittedField.fieldName;
                acctTempPermittedField.IETRS_Field_Number__c = permittedField.fieldNumber;
                acctTempPermittedField.Name = permittedField.fieldName + '-' + permit.drillingPermitSequence;
                if(permittedField.horizSevLowerDepth != null){
                    acctTempPermittedField.IETRS_Permitted_Field_Lower_Depth__c = Integer.valueOf(permittedField.horizSevLowerDepth);
                }
                if(permittedField.horizSevUpperDepth != null){
                    acctTempPermittedField.IETRS_Permitted_Field_Upper_Depth__c = Integer.ValueOf(permittedField.horizSevUpperDepth);
                }
                acctTempPermittedField.IETRS_Permitted_Field_SWR37B__c = permittedField.swr37bException == 'Y';
                acctTempPermittedField.IETRS_Permitted_Field_SWR37H__c = permittedField.swr37hException == 'Y';
                acctTempPermittedField.IETRS_Permitted_Field_SWR37I__c = permittedField.swr37iException == 'Y';
                acctTempPermittedField.IETRS_Permitted_Field_SWR37L__c = permittedField.swr37lException == 'Y';
                acctTempPermittedField.IETRS_Permitted_Field_SWR38D__c = permittedField.swr38dException == 'Y';
                acctTempPermittedField.IETRS_Permitted_Field_SWR38__c = permittedField.swr38Exception == 'Y';
                acctTempPermittedField.IETRS_Permitted_Field_SWR39__c = permittedField.swr39Exception == 'Y';
                //Only populate legacy number if an R37 exception exists
                if(acctTempPermittedField.IETRS_Permitted_Field_SWR37B__c || acctTempPermittedField.IETRS_Permitted_Field_SWR37H__c || acctTempPermittedField.IETRS_Permitted_Field_SWR37I__c || acctTempPermittedField.IETRS_Permitted_Field_SWR37L__c){
                    acctTempPermittedField.IETRS_RRC_Legacy_Number__c = permit.caseDocketNumber;
                }
                acctTempPermittedField.IETRS_Pooled_Unitized__c = permittedField.pooledUnitizedFlag == 'TRUE' ? true : false;
                acctTempPermittedField.IETRS_Completion_Depth__c = permittedField.completionDepth != null ? Integer.valueOf(permittedField.completionDepth) : 0;
                acctTempPermittedField.RecordTypeId = recordTypeField.Id;
                acctTempPermittedField.Type = 'Permitted Field';
                acctTempPermittedField.IETRS_Field_External_Id__c = permit.drillingPermitNumber + '|' + permit.drillingPermitSequence + '|' + permittedField.fieldNumber + '|' + permittedField.fieldName;
                acctTempPermittedField.IETRS_Last_Change__c = Date.today();
                acctTempPermittedField.OwnerId = integrationsUser.Id;

                acctTempPermittedField.ParentId = mapDrillingPermits.get(permit.drillingPermitNumber + '|' + permit.drillingPermitSequence);
                acctTempPermittedField.IETRS_OrganizationofRegEntity__c = mapOperatorNumbers.get(permit.operatorNumber);
                acctTempPermittedField.IETRS_District__c = mapDistrictCodes.get(permittedField.districtCode + '|OG');
                acctTempPermittedField.IETRS_Field__c = mapFields.get(permittedField.fieldNumber + '|' + permittedField.fieldName);

                lstPermittedFields.add(acctTempPermittedField);
            }
        }

        //Load Permitted Fields
        try{
            upsert lstPermittedFields IETRS_Field_External_Id__c;
            Set<Id> setAccountIds = new Set<Id>();
            for(Account permittedField : lstPermittedFields) {
                setAccountIds.add(permittedField.Id);
            }
            IETRS_AccountTriggerHelper.processAccounts(setAccountIds);
            return 'Success';
        } 
        catch(DmlException e){
            System.debug(e.getMessage());
            return e.getMessage();
        }

    }

    private Map<String, Id> lookupConverter(String externalID,String objectType,Set<String> setExternalID) {
        Map<String,Id> mapTemp = new Map<String,Id>();
        if (objectType == 'Account'){
            for(Account acc : Database.query('Select Id, '+externalID+ ' From Account Where '+externalID+' In :setExternalID')){
                mapTemp.put(acc.get(externalID).toString(), acc.Id);
                }
        }
        else if (objectType == 'IETRS_County_Group__c'){
            for(IETRS_County_Group__c county : Database.query('Select Id, '+externalID+ ' From IETRS_County_Group__c Where '+externalID+' In :setExternalID')){
                mapTemp.put(county.get(externalID).toString(), county.Id);
            }
        }
        return mapTemp;
    }

    /**
    * @description Converts a latitude or longitude value from degrees/minutes/seconds to decimal
    * @author Kevin Lu | 4/22/2020 
    * @param degrees 
    * @param minutes 
    * @param seconds 
    * @return Decimal 
    **/
    private static Decimal convertToDecimal(String degrees, String minutes, String seconds) {
        return Decimal.valueOf(degrees) + (Decimal.valueOf(minutes)/60) + (Decimal.valueOf(seconds)/3600);
    }

    /**
    * @description Deactivates GFC holds that are not in mainframe
    * @author Kevin Lu | 2020-07-15 
    * @param setHolds The Set of GFC hold IDs that were added/updated
    **/
    @future
    private static void deactivateGFCHolds(Set<Id> setHolds) {
        Set<Id> setAccountIDs = new Set<Id>();
        Set<String> setExternalIDs = new Set<String>();
        List<IETRS_Hold__c> lstHoldsToUpdate = new List<IETRS_Hold__c>();
        Id GFCHoldId = [Select Id From RecordType Where SObjectType = 'IETRS_Hold__c' And Name = 'Good Faith Claim Hold' Limit 1].Id;

        for(IETRS_Hold__c hold : [
            Select Id, IETRS_Regulated_Entity__c, IETRS_GFC_External_Id__c
            From IETRS_Hold__c
            Where Id In :setHolds
        ]) {
            setAccountIDs.add(hold.IETRS_Regulated_Entity__c);
            setExternalIDs.add(hold.IETRS_GFC_External_Id__c);
        }

        for(IETRS_Hold__c holdToUpdate : [
            Select Id, IETRS_Active__c
            From IETRS_Hold__c
            Where IETRS_Regulated_Entity__c In :setAccountIDs
            And IETRS_GFC_External_Id__c Not In :setExternalIDs
            And RecordTypeId = :GFCHoldId
        ]) {
            holdToUpdate.IETRS_Active__c = false;
            lstHoldsToUpdate.add(holdToUpdate);
        }

        update lstHoldsToUpdate;
    }
}