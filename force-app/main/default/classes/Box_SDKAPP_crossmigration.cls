public without sharing class Box_SDKAPP_crossmigration {        
    public static void retrieveAndAttachFiles() {
        String fcQuery = 'SELECT ID, CIIS_Mailing_Group__r.CIIS_Mailing_Batch__c, CIIS_Mailing_Group__c, IETRS_Organization__c, IETRS_Delivery_Method__c, CIIS_Central_Print_Status__c,'+
            'IETRS_File_Name__c, IETRS_Original_File_Name__c, IETRS_Box_File_ID__c, IETRS_Box_File_Folder__c, IETRS_Box_Folder_Link__c, IETRS_Document_Type__c, '+
            'CIIS_Mailing_Group__r.Id, CIIS_Mailing_Group__r.CIIS_Certified_Number__c, CIIS_Mailing_Group__r.CIIS_Mailing_Batch__r.CIIS_Integration_Audit_Log__r.Id,'+
            'CIIS_Mailing_Group__r.CIIS_Mailing_Batch__r.CIIS_Certified_Mail__c,'+
            '(SELECT IETRS_Organization_Name__c, IETRS_Recipient_Full_Name__c, IETRS_Address_Line_1__c, IETRS_Address_Line_2__c, IETRS_City__c, IETRS_State__c, IETRS_Zip__c, IETRS_Country_Code__c '+
            'FROM Correspondence_Mailing_Lists__r WHERE IETRS_Address_Line_1__c != null LIMIT 1)'+
            'FROM IETRS_Files_Correspondence__c'+
            'WHERE CIIS_Mailing_Group__r.CIIS_Mailing_Batch__r.CIIS_Integration_Audit_Log__r.Id IN (\'a2EBZ000000VMGM2A4\', \'a2EBZ000000VMGP2A4\', \'a2EBZ000000VMGN2A4\', \'a2EBZ000000VMGO2A4\')';

        List<IETRS_Files_Correspondence__c> fcList = new List<IETRS_Files_Correspondence__c>();

        fcList = Database.query(fcQuery);

        List<Attachment> attachmentList = new List<Attachment>();

        for(IETRS_Files_Correspondence__c fc : fcList){
            if(fc.IETRS_Box_File_ID__c  != null && fc.IETRS_Box_File_ID__c  != '') {
                IETRSBox box = new IETRSBox();
                Blob filebody = box.downloadFile(fc.IETRS_Box_File_ID__c);
                Attachment a = new Attachment(
                    Body = filebody,
                    Name = fc.IETRS_File_Name__c,
                    ParentId = fc.Id
                );
                //String blobString = EncodingUtil.base64Encode(filebody);
                //a.Body(filebody.toString());
                //a.Name(fc.IETRS_File_Name__c);
                //a.ParentId = fc.Id;
                attachmentList.add(a);
            }
        }
        insert attachmentList;
    }
}