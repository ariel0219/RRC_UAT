/**
 * @File Name          : IETRS_PLI_Company_Extract.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 2020-09-01
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      06/4/2020       Kevin Lu                Initial Version
 * 2.0      08/06/2020      Kevin Lu                Changed phone number parsing logic
 *                                                  Added 24 hour phone
 * 3.0      08/24/2020      Kevin Lu                Added Address Line 2
 * 4.0      09/01/2020      Kevin Lu                Removed truncation logic
 * 5.0      09/23/2022      Sarabpreet Singh        Increased length to 6 for IETRS_Company_ID__c and added order by clause
**/
global class IETRS_PLI_Company_Extract implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Truncate the object before beginning the new load
        /*List<IETRS_PLI_Extract_Company__c> lstDelete = [Select Id From IETRS_PLI_Extract_Company__c Where RecordType.Name = 'Company Extract'];
        delete lstDelete;*/

        /* 
        Formatted Query
        Select 
                Id
                ,Account.IETRS_P5_Number__c
                ,Account.IETRS_Company_Id__c
                ,Name
                ,Salutation
                ,Title
                ,MailingStreet
                ,MailingCity
                ,MailingState
                ,MailingPostalCode
                ,Phone
                ,IETRS_24_Hour_Phone__c
                ,Fax
            From 
                Contact
            Where
                AccountId != Null
                And Account.RecordType.Name = 'Organization' 
                And Account.IETRS_Company_Id__c != Null 
                And Account.IETRS_P5_Number__c != Null 
                And Account.IETRS_P5_Number__c != '000000'
                And IETRS_Contact_Type__c = 'Company Representative'
        */

        String strQuery = 'Select Id, Account.IETRS_P5_Number__c, Account.IETRS_Company_Id__c, Name, Salutation, Title, MailingStreet, MailingCity, MailingState, MailingPostalCode, Phone, IETRS_24_Hour_Phone__c, Fax From Contact Where AccountId != Null And Account.RecordType.Name = \'Organization\' And Account.IETRS_Company_Id__c != Null And Account.IETRS_P5_Number__c != Null And Account.IETRS_P5_Number__c != \'000000\' And IETRS_Contact_Type__c = \'Company Representative\' ORDER BY Account.IETRS_Company_Id__c';
        return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        List<IETRS_PLI_Extract_Company__c> lstExtract = new List<IETRS_PLI_Extract_Company__c>();
        RecordType recCompanyExtract = [
            Select Id, Name, SobjectType 
            From RecordType
            Where Name = 'Company Extract'
            And SObjectType = 'IETRS_PLI_Extract_Company__c'
            Limit 1];
        for(Contact c : scope) {
            IETRS_PLI_Extract_Company__c extract = new IETRS_PLI_Extract_Company__c(
                IETRS_P5_Number__c = c.Account.IETRS_P5_Number__c.leftPad(6, '0'),
                IETRS_Company_ID__c = c.Account.IETRS_Company_ID__c.leftPad(6, '0'),
                IETRS_Representative_Title__c = c.Title,
                IETRS_City__c = c.MailingCity,
                IETRS_State__c = c.MailingState,
                IETRS_Postal_Code__c = c.MailingPostalCode != null ? c.MailingPostalCode.substringBefore('-').leftPad(5, '0') : null,
                IETRS_Postal_Code_Extension__c = c.MailingPostalCode != null ? c.MailingPostalCode.substringAfter('-').leftPad(4, '0') : '0000',
                IETRS_Phone_Area_Code__c = c.Phone != null && c.Phone.length() > 2 ? c.Phone.substring(0, 3) : '000',
                IETRS_Phone_Exchange__c = c.Phone != null && c.Phone.length() > 5 ? c.Phone.substring(3, 6) : '000',
                IETRS_Phone_Line__c = c.Phone != null && c.Phone.length() > 9 ? c.Phone.substring(6, 10) : '0000',
                IETRS_24_Hour_Phone_Area_Code__c = c.IETRS_24_Hour_Phone__c != null && c.IETRS_24_Hour_Phone__c.length() > 2 ? c.IETRS_24_Hour_Phone__c.substring(0, 3) : '000',
                IETRS_24_Hour_Phone_Exchange__c = c.IETRS_24_Hour_Phone__c != null && c.IETRS_24_Hour_Phone__c.length() > 5 ? c.IETRS_24_Hour_Phone__c.substring(3, 6) : '000',
                IETRS_24_Hour_Phone_Line__c = c.IETRS_24_Hour_Phone__c != null && c.IETRS_24_Hour_Phone__c.length() > 9 ? c.IETRS_24_Hour_Phone__c.substring(6, 10) : '0000',
                IETRS_Fax_Area_Code__c = c.Fax != null && c.Fax.length() > 2 ? c.Fax.substring(0, 3) : '000',
                IETRS_Fax_Exchange__c = c.Fax != null && c.Fax.length() > 5 ? c.Fax.substring(3, 6) : '000',
                IETRS_Fax_Line__c = c.Fax != null && c.Fax.length() > 9 ? c.Fax.substring(6, 10) : '0000',
                RecordTypeId = recCompanyExtract.Id
            );
            //Address mapping
            if(c.MailingStreet != null && c.MailingStreet != '') {
                //split the address on the first newline
                String[] arrMailingStreet = c.MailingStreet.split('\n', 2);
                extract.IETRS_Address_Line_1__c = arrMailingStreet[0];
                if(arrMailingStreet.size() > 1) {
                    extract.IETRS_Address_Line_2__c = arrMailingStreet[1];
                }
            }
            //Name mapping
            if(c.Salutation == null || c.Salutation == '') {
                extract.IETRS_Representative_Name__c = c.Name;
            } else {
                extract.IETRS_Representative_Name__c = c.Salutation + ' ' + c.Name;
            }

            lstExtract.add(extract);
        }
        
        insert lstExtract;
    }

    global void finish(Database.BatchableContext bc) {
        IETRS_GoAnywhere websvc = new IETRS_GoAnywhere();
        websvc.runGoAnywhereJob(null, 'PLI Extracts - Company', 'PIPES PLI Extract');
    }
}