/**
 * @File Name          : IETRS_PLI_System_Extract.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 2020-09-09
 * @Modification Log   : 
 * Ver      Date            Author                  Modification
 * 1.0      06/16/2020      Kevin Lu                Initial Version
 * 2.0      09/01/2020      Kevin Lu                Removed truncation logic
 * 3.0      09/09/2020      Kevin Lu                Removed padding from System Id
 * 3.1      06/14/2021      Sebastian Wittenstein   Added null handling for acct.IETRS_Total_Miles__c
 * 3.2		07/14/2021		Forrest Chang			Added TAC Regulated Gathering Gathering
**/
global class IETRS_PLI_System_Extract implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Truncate the object before beginning the new load
        /*List<IETRS_PLI_Extract_System__c> lstDelete = [Select Id From IETRS_PLI_Extract_System__c];
        delete lstDelete;*/

        /* 
        Formatted Query
        Select
            IETRS_Account_ID__c
            ,IETRS_OrganizationofRegEntity__r.IETRS_P5_Number__c
            ,Parent.IETRS_Account_ID__c
            ,Name
            ,IETRS_Entity_Code__c
            ,IETRS_Jurisdiction__c 
                --Jurisdictional = J
                --Non-jurisdictional = N
                --Interstate = I
                --Odorization = O
				--TAC Regulated Gathering = G
            ,IETRS_Intra_Interstate__c
            ,IETRS_Status__c
            ,IETRS_T4_Permit__c
            ,IETRS_Total_Miles__c
            From
            Account
        Where
            RecordType.Name = 'Regulated Entity - PS'
            And IETRS_Status__c In ('Active', 'Idle', 'Abandoned')
            And IETRS_Jurisdiction__c != Null
            And IETRS_Entity_Code__c In (
                'A-Off Shore - Liquid'
                ,'B-Apartments'
                ,'C-Anhydrous Ammonia'
                ,'D-Distribution'
                ,'F-Non Jurisdictional Gathering, Production'
                ,'G-Gas Gathering'
                ,'H-Housing Authority'
                ,'I-LPG Distribution'
                ,'K-Carbon Dioxide'
                ,'L-Condensate, Crude Oil (Gathering)'
                ,'M-Municipal Distribution'
                ,'O-Crude Transmission'
                ,'P-Hazardous Liquid Products (Gasoline, Diesel, etc.)'
                ,'Q-Highly Volatile Liquids (Propane, Ethane, etc.)'
                ,'R-Rural Extension (Distribution)'
                ,'S-Gas Transmission for Municipal Supply'
                ,'T-Gas Transmission'
                ,'U-Underground Storage (Liquid)'
                ,'V-Underground Storage (Gas)'
                ,'W-Mobile Home Park'
                ,'X-Liquified Natural Gas'
                ,'Z-Off Shore - Gas'
            )
            And IETRS_Product_Sub_Class__c In (
                'Natural'
                ,'LPG'
                ,'Hydrogen'
                ,'LNG'
                ,'Others'
                ,'Crude'
                ,'Non-HVL'
                ,'HVL'
                ,'Carbon Dioxide'
                ,'Anhydrous Ammonia'
            )
            And IETRS_Entity_Sub_Type__c In (
                'Private Main System'
                ,'Private Rural Extension'
                ,'Municipal'
                ,'LPG'
                ,'Apartment'
                ,'Housing Authority'
                ,'Mobile Home Park'
                ,'State Facilities'
                ,'Transmission'
                ,'Direct Sale'
                ,'Municipal Supply'
                ,'Regulated'
                ,'Non-Regulated'
                ,'Aboveground'
                ,'Belowground'
            )
            And IETRS_OrganizationofRegEntity__r.IETRS_P5_Number__c != Null
            And IETRS_OrganizationofRegEntity__r.IETRS_P5_Number__c != '000000'
            And IETRS_OrganizationofRegEntity__r.IETRS_Company_Id__c != Null
            And IETRS_OrganizationofRegEntity__c In (
                Select AccountId
                From Contact
                Where IETRS_Contact_Type__c In ('Company Representative', 'TPD Representative')
            )
        */

        String strQuery = 'Select IETRS_Account_ID__c ,IETRS_OrganizationofRegEntity__r.IETRS_P5_Number__c,IETRS_Total_Miles__c,Parent.IETRS_Account_ID__c ,Name ,IETRS_Entity_Code__c ,IETRS_Jurisdiction__c  ,IETRS_Intra_Interstate__c ,IETRS_Status__c ,IETRS_T4_Permit__c  From Account Where RecordType.Name = \'Regulated Entity - PS\' And IETRS_Status__c In (\'Active\', \'Idle\', \'Abandoned\') And IETRS_Jurisdiction__c != Null And IETRS_Entity_Code__c In ( \'A-Off Shore - Liquid\' ,\'B-Apartments\' ,\'C-Anhydrous Ammonia\' ,\'D-Distribution\' ,\'F-Non Jurisdictional Gathering, Production\' ,\'G-Gas Gathering\' ,\'H-Housing Authority\' ,\'I-LPG Distribution\' ,\'K-Carbon Dioxide\' ,\'L-Condensate, Crude Oil (Gathering)\' ,\'M-Municipal Distribution\' ,\'O-Crude Transmission\' ,\'P-Hazardous Liquid Products (Gasoline, Diesel, etc.)\' ,\'Q-Highly Volatile Liquids (Propane, Ethane, etc.)\' ,\'R-Rural Extension (Distribution)\' ,\'S-Gas Transmission for Municipal Supply\' ,\'T-Gas Transmission\' ,\'U-Underground Storage (Liquid)\' ,\'V-Underground Storage (Gas)\' ,\'W-Mobile Home Park\' ,\'X-Liquified Natural Gas\' ,\'Z-Off Shore - Gas\' ) And IETRS_Product_Sub_Class__c In ( \'Natural\' ,\'LPG\' ,\'Hydrogen\' ,\'LNG\' ,\'Others\' ,\'Crude\' ,\'Non-HVL\' ,\'HVL\' ,\'Carbon Dioxide\' ,\'Anhydrous Ammonia\' ) And IETRS_Entity_Sub_Type__c In ( \'Private Main System\' ,\'Private Rural Extension\' ,\'Municipal\' ,\'LPG\' ,\'Apartment\' ,\'Housing Authority\' ,\'Mobile Home Park\' ,\'State Facilities\' ,\'Transmission\' ,\'Direct Sale\' ,\'Municipal Supply\' ,\'Regulated\' ,\'Non-Regulated\' ,\'Aboveground\' ,\'Belowground\' ) And IETRS_OrganizationofRegEntity__r.IETRS_P5_Number__c != Null And IETRS_OrganizationofRegEntity__r.IETRS_P5_Number__c != \'000000\' And IETRS_OrganizationofRegEntity__r.IETRS_Company_Id__c != Null And IETRS_OrganizationofRegEntity__c In ( Select AccountId From Contact Where IETRS_Contact_Type__c In (\'Company Representative\', \'TPD Representative\') )';
        return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        List<IETRS_PLI_Extract_System__c> lstExtract = new List<IETRS_PLI_Extract_System__c>();
        for(Account acct : scope) {
            IETRS_PLI_Extract_System__c extract = new IETRS_PLI_Extract_System__c(
                IETRS_LDR_System_Id__c = acct.IETRS_Account_ID__c,
                IETRS_LDR_Operator_Number__c = acct.IETRS_OrganizationofRegEntity__r.IETRS_P5_Number__c.leftPad(6, '0'),
                IETRS_LDR_Unit_Reps_Number__c = acct.Parent.IETRS_Account_ID__c.leftPad(5, '0'),
                IETRS_System_Name__c = acct.Name.left(50).rightPad(50, ' '),
                IETRS_T4_Permit_Number__c = acct.IETRS_T4_Permit__c == '' || acct.IETRS_T4_Permit__c == Null ? '000000' : acct.IETRS_T4_Permit__c.leftPad(6, '0')
            );
            if(acct.IETRS_Total_Miles__c != null && acct.IETRS_Total_Miles__c >=0){
                extract.IETRS_System_Miles__c = String.valueOf(Math.roundToLong(acct.IETRS_Total_Miles__c * 10)).leftPad(7, '0');
            }else{
                extract.IETRS_System_Miles__c = '0000000';
            }
            switch on acct.IETRS_Jurisdiction__c {
                when 'Jurisdictional' {
                    extract.IETRS_Jurisdiction__c = 'J';
                }
                when 'Non-jurisdictional' {
                    extract.IETRS_Jurisdiction__c = 'N';
                }
                when 'Interstate' {
                    extract.IETRS_Jurisdiction__c = 'I';
                }
                when 'Odorization' {
                    extract.IETRS_Jurisdiction__c = 'O';
                }
				when 'TAC Regulated Gathering' {
					extract.IETRS_Jurisdiction__c = 'G';
				}
                when else {
                    extract.IETRS_Jurisdiction__c = ' ';
                }
            }
            switch on acct.IETRS_Intra_Interstate__c {
                when 'Intrastate' {
                    extract.IETRS_LDR_System_Type_Code__c = ' ' + acct.IETRS_Entity_Code__c.substring(0, 1) + ' ';
                }
                when 'Interstate', 'Interstate Agent' {
                    extract.IETRS_LDR_System_Type_Code__c = 'E' + acct.IETRS_Entity_Code__c.substring(0, 1) + ' ';
                }
                when else {
                    extract.IETRS_LDR_System_Type_Code__c = ' ' + acct.IETRS_Entity_Code__c.substring(0, 1) + ' ';
                }
            }
            switch on acct.IETRS_Status__c {
                when 'Active' {
                    extract.IETRS_System_Status_Code__c = 'A';
                }
                when 'Idle' {
                    extract.IETRS_System_Status_Code__c = 'I';
                }
                when 'Abandoned' {
                    extract.IETRS_System_Status_Code__c = 'B';
                }
                when else {
                    extract.IETRS_System_Status_Code__c = ' ';
                }
            }

            lstExtract.add(extract);
        }
        
        insert lstExtract;
        System.debug('Processed ' + lstExtract.size() + ' systems');
    }

    global void finish(Database.BatchableContext bc) {
        IETRS_GoAnywhere websvc = new IETRS_GoAnywhere();
        websvc.runGoAnywhereJob(null, 'PLI Extracts - System', 'PIPES PLI Extract');
    }
}