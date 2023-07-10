public class IETRS_Conga_Doc_Gen_Controller {
    
    @AuraEnabled
    public static String generateURL(String recordID, String strObjectType) {
        String strURL;
        String strTemplateId;
        String strTemplateName;
        String strAddtlParams;
        List<APXTConga4__Conga_Merge_Query__c> lstCongaQueries;
        Map<String, Id> mapCongaQueries = new Map<String,Id>();
        Map<String,Object> mapDynamic;
        String objectDevName = strObjectType.left((strObjectType.length()-3));
        //Get Object Type Id for dynamic query field selection
        Id idObjectType;
        idObjectType = [
            SELECT DurableId
            FROM EntityDefinition
            WHERE DeveloperName = :objectDevName
            LIMIT 1][0].DurableId;
        //Dynamically fetch the pv Values
        Set<String> pvSet = new Set<String>();
        for(IETRS_Conga_Template_Mapping__mdt ct : [
            SELECT pv0__c, pv1__c, pv2__c 
            FROM IETRS_Conga_Template_Mapping__mdt
            WHERE Object_Type__c = :idObjectType
        ]) {
            pvSet.add(ct.pv0__c);
            pvSet.add(ct.pv1__c);
            pvSet.add(ct.pv2__c);
        }
        //pvSet.remove('Id ');
        System.debug('pvSet: '+pvSet);
        String cleanPVSet = pvset != null ? pvSet.toString().mid(1,(pvSet.toString().length()-7)) : '';
        System.debug('cleanPVSet: '+cleanPVSet);
        //System.debug('cleanPVSet: '+cleanPVSet);
        cleanPVSet = cleanPVSet.contains('null') ? cleanPVSet.remove('null,') : cleanPVSet;
        cleanPVSet = cleanPVSet.contains('...') ? cleanPVSet.remove('...') : cleanPVSet;
        cleanPVSet = cleanPVSet.contains('Id') ? cleanPVSet.remove('Id') : cleanPVSet;
        System.debug('cleanPVSet: '+cleanPVSet);
        String query;
        query = pvset != null ? 'SELECT Id, IETRS_Conga_Template_ID__c, IETRS_Conga_Document_Name__c, ' + cleanPVSet : 'SELECT Id, IETRS_Conga_Template_ID__c, IETRS_Conga_Document_Name__c ';
        System.debug('Partial Query:' + query);
        query = query.contains(' ,') ? query.remove(' ,') : query;
        query = query.contains('  ,') ? query.remove('  ,') : query;
        if(
            query.endsWith(',')
        ) {
            query = query.left(query.length()-1);
        }
        //Switch to allow the mapDynamic to work for whatever object calls the button
        Switch on strObjectType{
            when 'IETRS_Files_Correspondence__c'{
                //Get the Conga Template ID, Conga Document Name, and any other needed fields on the F&C record.
                //TO DO: Make this a string query that can have the fields from the pv0 field on the custom metadata object dynamically added without code changes.
                //       Will need to query F&C for template ID, then query Custom Metadata for list of pv0 fields, then query F&C again.
                query += ' FROM IETRS_Files_Correspondence__c WHERE Id = :recordID';
                System.debug('Query: '+query.left(250));
                System.debug('Query: '+query.mid(250, 250));
                mapDynamic = Database.query(query)[0].getPopulatedFieldsAsMap();
            }
        }
        
        //Convert the stored Object value to String for use in Query
        //strTemplateId = (String) mapDynamic.get('IETRS_Conga_Template_ID__c').toString(); //Old code
    //Enhanced code with if conditions below
    if(mapDynamic.ContainsKey('IETRS_Conga_Template_ID__c'))
        if(mapDynamic.get('IETRS_Conga_Template_ID__c')!=null)
            strTemplateId = (String) mapDynamic.get('IETRS_Conga_Template_ID__c');

    if(strTemplateId!=null)
        strTemplateName = [SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE Id = :strTemplateId LIMIT 1].APXTConga4__Name__c;
        // Not a god way to use the Query with any Condition 
        lstCongaQueries = [SELECT Id, IETRS_Query_Alias__c FROM APXTConga4__Conga_Merge_Query__c];
        
        for (APXTConga4__Conga_Merge_Query__c q : lstCongaQueries){
            mapCongaQueries.put(q.IETRS_Query_Alias__c, q.Id);
        }

        //Return list of Custom Metadata records corresponding to the Template ID on the record
        List<IETRS_Conga_Template_Mapping__mdt> listMetaCongaMappings=new List<IETRS_Conga_Template_Mapping__mdt>();
        //Added the below if for number check
        if(strTemplateName!=null) 
            listMetaCongaMappings = [SELECT IETRS_Template_Name__c, IETRS_Query_Alias__c, pv0__c, pv1__c, pv2__c, IETRS_Additional_Parameters__c
                                                                        FROM IETRS_Conga_Template_Mapping__mdt 
                                                                        WHERE IETRS_Template_Name__c = :strTemplateName];
        system.debug(listMetaCongaMappings);

        //Build Generic URL base
        strURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/APXTConga4__Conga_Composer?serverUrl=' + URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/37.0/' + UserInfo.getOrganizationId() +
            '&id=' + recordID +
            '&TemplateiD=' + strTemplateId +
            '&OFN=' + mapDynamic.get('IETRS_Conga_Document_Name__c').toString() +
            '&DS7=1' + //changed from 11 to allow for attachment generation instead of CD/files
            '&DefaultPDF=1'
            ;

        //Add Template specific parameters to the URL
        if(listMetaCongaMappings.size()>0) //added condition to avoid index out of bounds
        strAddtlParams = listMetaCongaMappings[0].IETRS_Additional_Parameters__c;
        strURL = strAddtlParams != null ? strURL + strAddtlParams : strURL;  
        strURL = strURL + '&QueryID=';

        //Loop through returned list of Custom Metadata Records to build the &QueryID parameter for the URL
        for (IETRS_Conga_Template_Mapping__mdt metaIterator : listMetaCongaMappings){
            //TO DO: Need to plan for ?pv0s to be functions or literals not fields, e.g. YEAR(TODAY()) or 1995
            strURL = strURL + metaIterator.IETRS_Query_Alias__c + mapCongaQueries.get(metaIterator.IETRS_Query_Alias__c);
            //Integer strLength =strURL.length();
            strURL = mapDynamic.get(metaIterator.pv0__c) != null ? strURL + '?pv0=' + mapDynamic.get(metaIterator.pv0__c) : strURL;
            System.debug('PV0:'+mapDynamic.get(metaIterator.pv0__c));
            strURL = mapDynamic.get(metaIterator.pv1__c) != null ? strURL + '?pv1=' + mapDynamic.get(metaIterator.pv1__c) : strURL; 
            System.debug('PV1:'+mapDynamic.get(metaIterator.pv1__c));
            strURL = mapDynamic.get(metaIterator.pv2__c) != null ? strURL + '?pv2=' + mapDynamic.get(metaIterator.pv2__c) : strURL; 
            System.debug('PV2:'+mapDynamic.get(metaIterator.pv2__c));
            //if (strLength<strURL.length()) {
                strURL += ',';
                System.debug('URL String:'+strURL.right(200));
            //}
        }
        //Remove trailing comma from last line.
        strURL = strURL.removeEnd(',');
        System.debug('Final URL String:'+strURL);

        //Return completed string URL to Lightning Component to navigate to URL.
        return strURL;
    }

    @AuraEnabled
    public static boolean checkisIETRSCorrespondenceDatebalnk(String recordID){
        //Enhancement
       List<IETRS_Insp_Correspondence_Date__c> listOfIETRSInspCorrespondenceDate = [SELECT ID	
                                                                                    ,IETRS_Correspondence_Date__c
                                                                                    ,IETRS_Date_Description__c
                                                                                    ,IETRS_Date_Type__c
                                                                                    ,IETRS_Files_Correspondence__c
                                                                                    ,IETRS_Files_Correspondence__r.IETRS_Business_Area_Division__c
                                                                                    ,IETRS_Files_Correspondence__r.IETRS_Document_Type__c
                                                                                    
        FROM IETRS_Insp_Correspondence_Date__c WHERE IETRS_Files_Correspondence__c = :recordID AND IETRS_Date_Type__c='Operator Letter' AND IETRS_Files_Correspondence__r.IETRS_Business_Area_Division__c = 'Pipeline Safety' AND IETRS_Files_Correspondence__r.IETRS_Document_Type__c = 'POC Approved - Completion Date Assigned'  ];
        
        boolean isIETRSCorrespondenceDatebalnk=null;
        //System.debug(listOfIETRSInspCorrespondenceDate.get(0).IETRS_Correspondence_Date__c);
        if(listOfIETRSInspCorrespondenceDate.size()>0){
            for(IETRS_Insp_Correspondence_Date__c IETRSInspCorrespondenceDateInstance:listOfIETRSInspCorrespondenceDate){
                System.debug('*******'+isIETRSCorrespondenceDatebalnk+''+IETRSInspCorrespondenceDateInstance.IETRS_Correspondence_Date__c);
                if(IETRSInspCorrespondenceDateInstance.IETRS_Correspondence_Date__c==null){
                        isIETRSCorrespondenceDatebalnk=true;
                        System.debug('ooooo'+isIETRSCorrespondenceDatebalnk);
                }else{
                    isIETRSCorrespondenceDatebalnk=false;
                }

            }
            System.debug('sdfjnj'+isIETRSCorrespondenceDatebalnk);
        
        }else{
            isIETRSCorrespondenceDatebalnk=false;
        }
        
    return isIETRSCorrespondenceDatebalnk;
}

@AuraEnabled
public static boolean isFilesAndCorrespondingOfPS_PACDA(String recordID){

        boolean isFandC_PS_PACDA;

        List<IETRS_Files_Correspondence__c> listOfIETRS_Files_CorrespondenceInstance=new List<IETRS_Files_Correspondence__c>();
        listOfIETRS_Files_CorrespondenceInstance=[SELECT id,IETRS_Conga_Template_ID__c
        ,IETRS_Inspection_Package__c
        ,IETRS_Conga_Document_Name__c
        ,IETRS_Incident__c
        ,IETRS_Complaint__c 
        ,IETRS_Document_Type__c
        ,IETRS_Business_Area_Division__c
        FROM IETRS_Files_Correspondence__c Where Id =: recordID and IETRS_Document_Type__c = 'POC Approved - Completion Date Assigned' and IETRS_Business_Area_Division__c = 'Pipeline Safety' limit 1];

        if(listOfIETRS_Files_CorrespondenceInstance.size()>0){
            if(listOfIETRS_Files_CorrespondenceInstance.get(0).IETRS_Document_Type__c == 'POC Approved - Completion Date Assigned' && 
            listOfIETRS_Files_CorrespondenceInstance.get(0).IETRS_Business_Area_Division__c == 'Pipeline Safety'){
                isFandC_PS_PACDA=true;
            }
            else{
                isFandC_PS_PACDA=false;
            }
        }else{
            isFandC_PS_PACDA=false;
        }
        return isFandC_PS_PACDA;
}

}