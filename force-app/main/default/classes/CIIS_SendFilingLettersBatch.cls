/**
* @File Name          : CIIS_SendFilingLettersBatch.cls
* @Description        : Create CID Filing Letters (F&C) records
* @Author             : Vishwanath Kodgire
* @Test Class		  : CIIS_SendFilingLettersBatch_Test
* @Group              :
* @Last Modified By   : Vishwanath Kodgire
* @Last Modified On   : 08/11/2023
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0   	08/11/2023  	 		Vishwanath Kodgire    		Initial Version
**/

public class CIIS_SendFilingLettersBatch implements Database.Batchable<Sobject>{
    String errorOccured = '';
    CIDX_Filing_Period__c currentCFPrecord = new CIDX_Filing_Period__c();
    ID CTNotFiled = [SELECT id, APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'CID Not Filed']?.ID;
    ID CTPartial = [SELECT id, APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'CID Partial Filer']?.ID;    
    public CIIS_SendFilingLettersBatch(CIDX_Filing_Period__c cfp){
        currentCFPrecord = cfp;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator([ SELECT ID,
                                         Name,
                                         (SELECT CIDX_Organization__c, CIDX_Filing_Status__c FROM CIDX_Filings1__r),
                                         CIIS_Reg_Entity_MCF_day__c,
                                         BillingStreet,
                                         BillingCity,
                                         BillingState,
                                         BillingPostalCode,
                                         CIIS_Meets_CID__c,
                                         IETRS_Representative__c, 
                                         IETRS_Representative_Email__c
                                         FROM Account 
                                         WHERE ID IN (SELECT CIDX_Organization__c FROM CIDX_Filing__c WHERE CIDX_Filing_Period__c =: currentCFPrecord.ID )]);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope){
        try{
            Map<IETRS_Insp_Correspondence_Mailing_List__c, IETRS_Files_Correspondence__c> emailFCMap = new MAP<IETRS_Insp_Correspondence_Mailing_List__c, IETRS_Files_Correspondence__c>();
            List<CIDX_Filing__c> filings = [SELECT ID, CIDX_Organization__c, CIDX_Filing_Status__c FROM CIDX_Filing__c WHERE CIDX_Organization__c IN: scope];
            Map<ID, List<CIDX_Filing__c>> allFile = new Map<ID,List<CIDX_Filing__c>>();
            Map<ID, List<CIDX_Filing__c>> partialFile = new Map<ID,List<CIDX_Filing__c>>();
            for(CIDX_Filing__c file : filings){
                if(file.CIDX_Filing_Status__c == 'Process Hearing' || file.CIDX_Filing_Status__c == 'Admin Approved/Complete' ){
                    if(partialFile.containsKey(file.CIDX_Organization__c))
                        partialFile.get(file.CIDX_Organization__c).add(file);
                    else
                        partialFile.put(file.CIDX_Organization__c, new List<CIDX_Filing__c>{file});
                }
                if(allFile.containsKey(file.CIDX_Organization__c))
                    allFile.get(file.CIDX_Organization__c).add(file);
                else
                    allFile.put(file.CIDX_Organization__c, new List<CIDX_Filing__c>{file});
            }
            for(Account acc: scope){
                Integer count1 = partialFile.get(acc.ID)?.size() != NULL ? partialFile.get(acc.ID).size() : 0;
                Integer count2 = allFile.get(acc.ID)?.size() != NULL ? allFile.get(acc.ID).size() : 0;
                system.debug('acc ' + acc.Name);
                system.debug('count1 ' + count1);
                system.debug('count2 ' + count2);
                String billingStreet = acc.BillingStreet;
                String addressLine1 = '';
                String addressLine2 = '';
                if (billingStreet != null && billingStreet.contains(';')) {
                    Integer semicolonIndex = billingStreet.indexOf(';');
                    addressLine1 = billingStreet.substring(0, semicolonIndex);
                } else {
                    addressLine1 = billingStreet;
                }
                if (billingStreet != null && billingStreet.contains(';')) {
                    Integer semicolonIndex = billingStreet.indexOf(';');
                    addressLine2 = billingStreet.substring(semicolonIndex + 1).trim().replace(';', '');
                } else {
                    addressLine2 = '';
                }
                Boolean createFC = false;
                IETRS_Files_Correspondence__c newFC = new IETRS_Files_Correspondence__c();
                newFC.IETRS_Business_Area_Division__c = 'Critical Infrastructure';
                newFC.CIDX_Filing_Period__c = currentCFPrecord.ID;
                newFC.CIIS_Public_Organization_Document__c = true;
                newFC.IETRS_File_Format__c = 'PDF';
                newFC.IETRS_Organization__c = acc.ID;
                newFC.rrc_Parent_Object__c = 'Organization';
                
                if(count1 > 0 && count2 > count1){
                    createFC = true;
                    newFC.IETRS_Conga_Template_ID__c = CTPartial;
                    newFC.IETRS_Description__c = 'CID Partial Filed Letter to Organization Mailing Address and Representative Email.';
                    newFC.IETRS_Email_Body__c = 'See the attached regarding your CID filing.';
                    newFC.CIIS_QMode__c = 'Attachments';
                    newFC.IETRS_Document_Type__c = 'CID Partial Filer Letter';
                    newFC.IETRS_Email_Subject__c = 'Critical Infrastructure – CID Partial Filer';
                }
                else if(count1 == 0){
                    createFC = true;
                    system.debug('Here  ');
                    newFC.IETRS_Conga_Template_ID__c = CTNotFiled;
                    newFC.IETRS_Description__c = 'CID Not Filed Letter to Organization Mailing Address and Representative Email';
                    newFC.CIIS_QMode__c = 'Attachments';
                    newFC.IETRS_Document_Type__c = 'CID Not Filed Letter';
                    newFC.IETRS_Email_Body__c = 'See the attached regarding CID not filed by the submission due date.';
                    newFC.IETRS_Email_Subject__c = 'Critical Infrastructure – CID Not Filed by Deadline';
                    
                }
                if(createFC){
                    if(acc.IETRS_Representative_Email__c != NULL && acc.IETRS_Representative_Email__c != ''){
                        newFC.CIIS_QMode__c = 'SendEmail';
                        newFC.IETRS_Delivery_Method__c = 'Email + Certified';
                        newFC.IETRS_Organization_Representative__c = acc.IETRS_Representative__c;
                    }
                    else{
                        newFC.IETRS_Comments__c = 'No IETRS Representative Email on Organization Account';
                        newFC.IETRS_Delivery_Method__c = 'Certified';
                    }
                    IETRS_Insp_Correspondence_Mailing_List__c newML = new IETRS_Insp_Correspondence_Mailing_List__c(IETRS_Address_Line_1__c = addressLine1, IETRS_Address_Line_2__c = addressLine2, IETRS_Address_Origination__c = 'Organization Mailing Address',
                                                                                                                    IETRS_City__c = acc.BillingCity, IETRS_Contact__c = acc.IETRS_Representative__c, IETRS_Country_Code__c = 'US',
                                                                                                                    IETRS_Email__c = acc.IETRS_Representative_Email__c, IETRS_Organization_Name__c = acc.Name, IETRS_State__c = acc.BillingState,
                                                                                                                    IETRS_Zip__c = acc.BillingPostalCode, IETRS_To_or_CC__c = 'To');
                    emailFCMap.put(newML, newFC);
                }
            }
            Insert emailFCMap.values();
            for(IETRS_Insp_Correspondence_Mailing_List__c mailList : emailFCMap.keySet() ){
                mailList.IETRS_Files_and_Correspondence__c = emailFCMap.get(mailList).ID;
            }
            
            Insert new List<IETRS_Insp_Correspondence_Mailing_List__c>(emailFCMap.keySet());
            
        }
        catch(exception e){
            errorOccured = e.getMessage() +'  ' + e.getCause();
            System.debug('Exception Occured in Critical Indication creation batch: ' + e.getMessage());
        }
    }
    public void finish(Database.BatchableContext bc){   
        if(errorOccured != ''){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Error occured in CID Filing Letter Generation Batch');
            email.setHtmlBody(errorOccured);
            email.setToAddresses(new List<String>{'nicholas.levingston@cgi.com'});
            email.setSaveAsActivity(false);
            // Send the email
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        }
    }
}