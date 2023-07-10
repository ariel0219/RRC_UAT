/**
 * @File Name          : IETRS_MassSecActAssgnmtController.cls
 * @Description        :
 * @Author             : Kevin Lu
 * @Group              :
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 4/9/2020, 9:53:55 AM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    4/7/2020   Kevin Lu     Initial Version
   
 * @bray : 10 Nov 2022 : RRC-1980 : WO 04 | Mass add Secondary Accounts District Search for Leases
 * @bray : 10 Nov 2022 : RRC-1981 : WO 05 | Add search type for lease number or Permit number 
 **/
public with sharing class IETRS_MassSecActAssgnmtController {
    
    
    @AuraEnabled
    public static list<account> getAccountListNew(string searchBy,
                                                  string leaseNumber,
                                                  String district,
                                                  String permitNumber,
                                                  string caseId) {
        
                                                      
        List<Account> lstAccount = new List<Account>();
        String soqlQuery='SELECT Id,Name,IETRS_Lease_Number__c,IETRS_Well_Number__c,Type,'+
            'IETRS_Drilling_Permit_Number__c,Parent.Name,Parent.IETRS_Drilling_Permit_Number__c,IETRS_District__c,IETRS_District__r.Name ,Parent.Id,'+
            'Parent.Parent.Id,Parent.Parent.Parent.Id,Parent.Parent.Parent.Parent.Id,'+
            'Parent.Parent.Parent.Parent.Parent.Id FROM Account ';                                                      
                                                      
        String leaseSearchKey='';
        String discrictSearchKey='';
        String permitSearchKey='';
        // create account list to store search result
        // query account records
        //FC: Note -- For the Parent.Lease_Number do we need to add an additional condition that we only do that for
        //type = well?

        
        soqlQuery = soqlQuery + ' WHERE Id NOT IN (SELECT IETRS_Account__c FROM '+
            'IETRS_Case_Secondary_Account_Assignment__c WHERE IETRS_Case__c = :caseId)';
        
        if(!String.isEmpty(searchBy) && searchBy.equals('Lease')){
            leaseSearchKey = '%' + leaseNumber.trim() + '%';
			soqlQuery = soqlQuery + ' AND (IETRS_Lease_Number__c LIKE :leaseSearchKey OR Parent.IETRS_Lease_Number__c LIKE :leaseSearchKey) '; 
            if(!String.isEmpty(district)){
                //discrictSearchKey = '%' + district.trim() + '%';
                discrictSearchKey = district.trim();
                soqlQuery = soqlQuery + ' AND IETRS_District__c = :discrictSearchKey ' ;
            }
        }else if(!String.isEmpty(searchBy) && searchBy.equals('Permit')){
            permitSearchKey = '%' + permitNumber.trim() + '%';
            soqlQuery = soqlQuery + ' AND (IETRS_Drilling_Permit_Number__c LIKE :permitSearchKey OR Parent.IETRS_Drilling_Permit_Number__c LIKE :permitSearchKey ) ' ;
        }
        
        try {
            lstAccount = Database.query(soqlQuery);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return lstAccount;
    }    
    
    
    
    
    
    @AuraEnabled
    public static list<account> getAccountList(
        string searchKey,
        string caseId
    ) {
        String sTempSearchKey = '%' + searchKey.trim() + '%';

        // create account list to store search result
        // query account records
        //FC: Note -- For the Parent.Lease_Number do we need to add an additional condition that we only do that for
        //type = well?
        List<Account> lstAccount = new List<Account>();
        try {
            lstAccount = [
                SELECT
                    Id,
                    Name,
                    IETRS_Lease_Number__c,
                    IETRS_Well_Number__c,
                    Type,
                    Parent.Id,
                    Parent.Parent.Id,
                    Parent.Parent.Parent.Id,
                    Parent.Parent.Parent.Parent.Id,
                    Parent.Parent.Parent.Parent.Parent.Id
                FROM Account
                WHERE
                    (IETRS_Lease_Number__c LIKE :sTempSearchKey
                    OR Parent.IETRS_Lease_Number__c LIKE :sTempSearchKey)
                    AND Id NOT IN (
                        SELECT IETRS_Account__c
                        FROM IETRS_Case_Secondary_Account_Assignment__c
                        WHERE IETRS_Case__c = :caseId
                    )
                //ADD: sort by Lease_Number__c
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return lstAccount;
    }

    @AuraEnabled
    public static List<String> createSecondaryAccountList(
        List<String> lstSaaAcctIds,
        String strCaseId
    ) {
        List<IETRS_Case_Secondary_Account_Assignment__c> lstSaas = new List<IETRS_Case_Secondary_Account_Assignment__c>();
        for (String strAcctId : lstSaaAcctIds) {
            lstSaas.add(
                new IETRS_Case_Secondary_Account_Assignment__c(
                    IETRS_Account__c = strAcctId,
                    IETRS_Case__c = strCaseId,
                    IETRS_Mass_Add__c = true
                )
            );
        }
        insert lstSaas;
        List<String> lstSaaIds = new List<String>();
        for (IETRS_Case_Secondary_Account_Assignment__c saa : lstSaas) {
            lstSaaIds.add(saa.Id);
        }
        return lstSaaIds;
    }

    @AuraEnabled
    public static void updateCaseMassSAADetails(
        List<String> lstParamSaas,
        String strCaseId
    ) {
        List<IETRS_Case_Secondary_Account_Assignment__c> lstSaas = [
            SELECT
                Id,
                IETRS_Account__r.Type,
                IETRS_Account__r.IETRS_Lease_Name__c,
                IETRS_Account__r.IETRS_Lease_Number__c,
                IETRS_Account__r.IETRS_Field__c,
                IETRS_Account__r.IETRS_Field__r.Name,
                IETRS_Account__r.IETRS_District__c,
                IETRS_Account__r.IETRS_District__r.IETRS_County_Group_District__c,
                IETRS_Account__r.IETRS_Well_Number__c,
                IETRS_Account__r.IETRS_Drilling_Permit_Number__c,
            	IETRS_Account__r.IETRS_Field_Name__c,
            	IETRS_Account__r.IETRS_Field_Number__c,
                IETRS_Case__r.CaseNumber
            FROM IETRS_Case_Secondary_Account_Assignment__c
            WHERE Id IN :lstParamSaas
        ];

        //Build the string of all Secondary Account Assignment details to write all at once to the Case Secondary Account Details field.
        //This is to work around the bulkified action of the Process on SAA that populates these values on one off added SAAs.
        //The bulkified action evaluate all the new uploads and then wait until all are complete to execute the Case update.
        //This means that only the last evaluated SAA will have its details populated on the Case.
        String strSAADetails = '';
        for (IETRS_Case_Secondary_Account_Assignment__c saa : lstSaas) {
            system.debug(saa.IETRS_Account__r.Type);
            if (saa.IETRS_Account__r.Type == 'Lease') {
                system.debug(strSAADetails);
                strSAADetails =
                    strSAADetails +
                    ' ' +
                    (!String.isBlank(saa.IETRS_Account__r.IETRS_Lease_Name__c)
                        ? saa.IETRS_Account__r.IETRS_Lease_Name__c
                        : '<LEASE NAME>') +
                    ', ' +
                    (!String.isBlank(saa.IETRS_Account__r.IETRS_Lease_Number__c)
                        ? saa.IETRS_Account__r.IETRS_Lease_Number__c
                        : '<LEASE NUMBER>') +
                    ', ' +
                    (!String.isBlank(saa.IETRS_Account__r.IETRS_Field__c)
                        ? saa.IETRS_Account__r.IETRS_Field__r.Name
                        : '<FIELD NAME>') +
                    ', ' +
                    (!String.isBlank(saa.IETRS_Account__r.IETRS_District__c)
                        ? saa.IETRS_Account__r.IETRS_District__r.IETRS_County_Group_District__c
                        : '<DISTRICT-XX>') +
                    ',';
            } else if (saa.IETRS_Account__r.Type == 'Well') {
                system.debug(strSAADetails);
                strSAADetails =
                    strSAADetails +
                    ' ' +
                    (!String.isBlank(saa.IETRS_Account__r.IETRS_Well_Number__c)
                        ? saa.IETRS_Account__r.IETRS_Well_Number__c
                        : '<WELL NO>') +
                    ',';
            } else if (saa.IETRS_Account__r.Type == 'Drilling Permit') {
                system.debug(strSAADetails);
                strSAADetails =
                    strSAADetails +
                    ' ' +
                    (!String.isBlank(
                            saa.IETRS_Account__r.IETRS_Drilling_Permit_Number__c
                        )
                        ? saa.IETRS_Account__r.IETRS_Drilling_Permit_Number__c
                        : '<PERMIT NUMBER>') +
                    ', ' +
                    (!String.isBlank(saa.IETRS_Account__r.IETRS_Lease_Name__c)
                        ? saa.IETRS_Account__r.IETRS_Lease_Name__c
                        : '<LEASE NAME>') +
                    ', ' +
                    (!String.isBlank(saa.IETRS_Account__r.IETRS_District__c)
                        ? saa.IETRS_Account__r.IETRS_District__r.IETRS_County_Group_District__c
                        : '<DISTRICT-XX>') +
                    ',' ;
                    /*+
                    (!String.isBlank(saa.IETRS_Case__r.CaseNumber)
                        ? saa.IETRS_Case__r.CaseNumber
                        : '<CASE NUMBER>') +
                    ',';
					*/
            }else if (saa.IETRS_Account__r.Type == 'Permitted Field') {
                system.debug(strSAADetails);
                strSAADetails =
                    strSAADetails +
                    ' ' +
                    (!String.isBlank(
                            saa.IETRS_Account__r.IETRS_Field_Name__c
                        )
                        ? saa.IETRS_Account__r.IETRS_Field_Name__c
                        : '<FIELD NAME>') +
                    ', ' +
                    (!String.isBlank(saa.IETRS_Account__r.IETRS_Field_Number__c)
                        ? saa.IETRS_Account__r.IETRS_Field_Number__c
                        : '<FIELD NUMBER>') +
                    ', ' +
                    (!String.isBlank(saa.IETRS_Account__r.IETRS_District__c)
                        ? saa.IETRS_Account__r.IETRS_District__r.IETRS_County_Group_District__c
                        : '<DISTRICT-XX>') +
                    ',' ;
            }
        }
        Case caseToUpdate = [
            SELECT Id, IETRS_Secondary_Account_Details__c
            FROM Case
            WHERE Id = :strCaseId
        ];

        caseToUpdate.IETRS_Secondary_Account_Details__c = !String.isBlank(
                caseToUpdate.IETRS_Secondary_Account_Details__c
            )
            ? caseToUpdate.IETRS_Secondary_Account_Details__c + strSAADetails
            : strSAADetails;

        update caseToUpdate;
    }
}