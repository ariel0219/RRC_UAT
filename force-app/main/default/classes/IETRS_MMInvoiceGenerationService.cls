// Test Class : IETRS_CongaDocGenBatchTest
public with sharing class IETRS_MMInvoiceGenerationService {
    public static string CONTEXT;
    public static integer YEAR;
    public static string MASTERMETERINVOICE_ID;

    public static string setQuery(
        String c,
        Integer y
    ) {
        CONTEXT = c;
        YEAR = y;
        String query;
        String feecontext;
        feecontext = 'Master Meter';
        query = 
        'SELECT Id, IETRS_Organization__c, IETRS_Fee_Type__c, '+
        'IETRS_Organization__r.IETRS_Representative__c, IETRS_Organization__r.IETRS_Representative__r.Email, '+
            '(SELECT Id, IETRS_Document_Type__c, CreatedDate, IETRS_Sent_Date_Time__c, IETRS_Box_File_ID__c, IETRS_File_Name__c '+
            'FROM Files_Correspondence__r ' +
            'WHERE IETRS_Document_Type__c = \''+CONTEXT+'\''+ //CONTEXT should be 'Master Meter Invoice'
            'AND CALENDAR_YEAR(CreatedDate) = '+YEAR+')'+
        'FROM IETRS_Insp_Regulated_Fee__c '+
        'WHERE IETRS_Fee_Type__c = \''+feecontext+'\''+ //feecontext should be 'Master Meter'
        'AND CALENDAR_YEAR(IETRS_Fee_Date__c) ='+YEAR;
        return query;
    }
    /**
     * @description 
     * @param regfeesList 
     */
    public static void createFiles(List<IETRS_Insp_Regulated_Fee__c> regfeesList, String c){
        //set the context (in theory this class is a reusable template for other automated document generation)
        CONTEXT = c;

        //get the Master Meter Invoice conga template record id
        List<APXTConga4__Conga_Template__c> mmiTemplate = new List<APXTConga4__Conga_Template__c>();
        mmiTemplate = ([SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = :CONTEXT]);
        if(!mmiTemplate.isEmpty()){
            MASTERMETERINVOICE_ID = mmiTemplate[0].Id;
        }

        //creat a list of F&C records to update or insert
        List<IETRS_Files_Correspondence__c> upsertFCList = new List<IETRS_Files_Correspondence__c>();

        //process the passed in records
        for(IETRS_Insp_Regulated_Fee__c rf : regfeesList){
            //if there isn't already a Master Meter Invoice File & Correspondence record for the year 
            if(rf.Files_Correspondence__r.isEmpty()){
                IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c();
                //call setFC method without a fc record to generate it and add it to the list of File & Correspondence records to upsert
                upsertFCList.add(setFC(rf, fc));
            }else{
                //if there already is a Master Meter Invoice File & Correspondence record for the year 
                for(IETRS_Files_Correspondence__c fc: rf.Files_Correspondence__r){
                    //check if it's been generated
                    if(fc.IETRS_Box_File_ID__c=='' && fc.IETRS_File_Name__c==''){
                        //if so, pass it to setFC method and add it to the list of File & Correspondence records to upsert
                        upsertFCList.add(setFC(rf,fc));
                        //then exit the loop
                        break;
                    }
                    /**emergent functionality: 
                     * if there is one or more Master Meter Invoice File & Correspondence record,
                     * and the file for the record(s) has been generated,
                     * don't add it to the list of records to be upserted, it's already been generated
                    */
                }
            }
        }
        try{
            upsert upsertFCList;
        }catch(exception e){
            //output the error to the debug
            system.debug('error from IETRS_MasterMeterInvoiceGenerationService on upsert: '+e);
            system.debug(regfeesList);
            system.debug(upsertFCList);
        }
    }

    /**
     * @description sets the values for a F&C record
     * @param fc -optional- file and Correspondence record to be passed in & back
     * @param rf -required- regulated fee record the fc is related
     * @return `IETRS_Files_Correspondence__c`
     */
    private static IETRS_Files_Correspondence__c setFC(IETRS_Insp_Regulated_Fee__c rf, IETRS_Files_Correspondence__c fc){
        //if the fc record wasn't supplied, generate it
        if(fc.Id==null){
            fc.IETRS_Business_Area_Division__c = 'Pipeline Safety';
            fc.IETRS_Document_Type__c = CONTEXT;
            fc.IETRS_Organization__c = rf.IETRS_Organization__c;
            fc.IETRS_Regulated_Fee__c = rf.id;
            fc.IETRS_Conga_Template_ID__c = MASTERMETERINVOICE_ID;
        }
        //then figure out how it should be delivered
        return fc;
    }

    public static void prepCongaBatch(String c){
        //makes sure the follow up conga batch and it's queries are preped  
        //the follow up query is needed to generate the conga batch record to be used in generating the merged documents 
        String followUpEmailQueryId;
        List<APXTConga4__Conga_Merge_Query__c> congaqueryList = new List<APXTConga4__Conga_Merge_Query__c>();
        congaqueryList = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c = 'Master Meter Invoice Generation General'];
        //if the query record doesn't exist for some reason
        if(congaqueryList.isEmpty()){
            //create it
            APXTConga4__Conga_Merge_Query__c congaQuery = new APXTConga4__Conga_Merge_Query__c(
                APXTConga4__Name__c = 'Master Meter Invoice Generation General',
                IETRS_Query_Alias__c = '[MasMetInvGenEmail]',
                APXTConga4__Query__c = 
                    'SELECT Id FROM IETRS_Files_Correspondence__c WHERE IETRS_Box_File_ID__c = \'\' '+
                    'WHERE IETRS_Document_Type__c = \'Master Meter Invoice\' '+
                    'AND IETRS_Sent_Date_Time__c = null'+
                    'ORDER BY IETRS_Organization__c LIMIT 200'
            );
            insert congaQuery;
            followUpEmailQueryId = congaQuery.id;
        }else{
            followUpEmailQueryId = congaqueryList[0].Id;
        }
        //reset congaQuery
        congaqueryList = null;
        //the mail query isn't used in the initial conga batch, it's used in the follow up flow
        String followUpMailQueryId;
        congaqueryList = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c = 'Master Meter Invoice Generation Mail'];
        //if the query record doesn't exist for some reason
        if(congaqueryList.isEmpty()){
            //create it
            APXTConga4__Conga_Merge_Query__c congaQuery = new APXTConga4__Conga_Merge_Query__c(
                APXTConga4__Name__c = 'Master Meter Invoice Generation Email',
                IETRS_Query_Alias__c = '[MasMetInvGenEmail]',
                APXTConga4__Query__c = 
                    'SELECT Id '+
                    'FROM IETRS_Files_Correspondence__c '+
                    'WHERE IETRS_Box_File_ID__c = \'\' '+
                    'AND IETRS_Document_Type__c = \'Master Meter Invoice\' '+
                    'AND (IETRS_Organization__r.IETRS_Representative__r.Email != null'+
                    'OR IETRS_Organization__r.IETRS_Representative__r.Email != \'\''+
                    'AND (IETRS_Organization__r.IETRS_Representative__r.EmailBouncedReason = null'+
                    'OR IETRS_Organization__r.IETRS_Representative__r.EmailBouncedReason = \'\')'+
                    'ORDER BY IETRS_Organization__c '+
                    'LIMIT 200'
            );
            insert congaQuery;
        } else{
            followUpMailQueryId = congaqueryList[0].Id;
        }
        //get the user's business area
        User runningUser = new User();
        runningUser.Id = UserInfo.getUserId(); 
        runningUser = [SELECT IETRS_Business_Area__c FROM User WHERE Id = :runningUser.Id LIMIT 1][0];

        String contentWorkspaceName = 'Forms and Documents - '+runningUser.IETRS_Business_Area__c;
        //get the content workspace for the user's business area
        ContentWorkspace contwork = new ContentWorkspace(
            Name = contentWorkspaceName,
            ShouldAddCreatorMembership = false
        );
        contwork.Id = [SELECT Id FROM ContentWorkspace WHERE Name = :contentWorkspaceName LIMIT 1]?.Id;
        //if the content workspace for CID doesn't exist, make it
        if(contwork.Id==null){
            //Insert contwork;
            Database.SaveResult result = Database.insert(contwork, false);
        }

        Datetime nowDateTime = Datetime.now();
        APXT_BPM__Conductor__c congaBatchEmail = new APXT_BPM__Conductor__c(
            APXT_BPM__Query_Id__c = followUpEmailQueryId,
            APXT_BPM__Title__c = 'MMI - Email: '+nowDateTime,
            APXT_BPM__Description__c = c+' Generation for delivery by email created on '+nowDateTime,
            APXT_BPM__URL_Field_Name__c = 'IETRS_Generate_Fee_Document__c',
            IETRS_Document_Type__c = c
        );
        insert congaBatchEmail;

        /**
         * To do, create RT flow: send notification to user/group? that batch record exists and is ready for processing
         * also in RT flow, when batch completed, (batch history), search for more records, if found, create new batch record, repeat
         */
    }
}