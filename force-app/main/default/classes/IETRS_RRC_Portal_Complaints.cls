Public with sharing class IETRS_RRC_Portal_Complaints {
    
    @AuraEnabled(cacheable=true)
    public static String getComplaintsList(
    Integer pageNumber,
    Integer pageSize,
    String sortingField,
    String sortDirection
    ){
        try{
            //handle sorting field being one of the fields created in JS, or sorting field being null
            if(sortingField==null||sortingField=='nameUrl'){
                sortingField='Name';
            }else if(sortingField=='orgName'){
                sortingField='IETRS_Organization__r.Name';
            }
            //handles sort direction being null
            if(sortDirection==null){
                sortDirection='ASC';
            }
            //handles pagesize being null
            if(pageSize==null){
                pageSize = 10;
            }
            //handles pageNumber being null
            if(pageNumber==null){
                pageNumber = 1;
            }

            //boolean to check if running user is a guest or interal user, in which case they should get all incident records
            String uID = UserInfo.getUserId();
            User runningUser = [SELECT Id, contactId, accountId FROM User WHERE Id = :uID LIMIT 1][0];
            Boolean guestOrInternalUser = (Auth.CommunitiesUtil.isGuestUser()||runningUser.AccountId==null);
            //list of accounts Ids for use in query, if non-guest community user 
            List<Id> setAccts = new List<Id>();
            //get the accounts for non-guest community users. 
            if(!guestOrInternalUser){
                setAccts = getAccounts();
            }

            //get Total rows/records
            Integer totalRows = countRecords(setAccts);

            //calculate total pages
            Integer totalPages = Math.round(Math.ceil(totalRows/pageSize))+1;

            //offset for query
            Integer offset = (pageNumber - 1) * pageSize;

            //boolean and check to avoid query limit of 2k
            Boolean queryMore = false;
            List<IETRS_Incident__c> queryMoreComplaints = new List<IETRS_Incident__c>();
            if(offset>2000){
                queryMore = true;
            }
            //handle sorting direction under query more
            String queryMoreDirection;
            if(queryMore&&sortDirection=='ASC'){
                queryMoreDirection = '>';
            }else if(queryMore&&sortDirection=='DEC'){
                queryMoreDirection = '<';
            }

            //calcualte last record of current page, assuming not last page
            Integer recordEnd = pageSize * pageNumber;

            //declare wrapper object for response to LWC
            ComplaintWrapper returnData = new ComplaintWrapper();
            
            //get records if guest or internal user, else get records related to community user's account.
            if (guestOrInternalUser) {
                        
                String query = 'SELECT Name, IETRS_Complaint_Reported_Date_Time__c, ITRES_Complaint_Received__c, ';
                query+='IETRS_Complaint_Resolution_Status__c, IETRS_City__c, IETRS_I_Regulated_Entity_Name_for_Search__c, ';
                query+='IETRS_Organization__r.Name, IETRS_Business_Area__c, IETRS_Complaint_Description__c ';
                query+='FROM IETRS_Complaint__c ';
                //handle less than 2k total records
                if(!queryMore){
                    query+='ORDER BY '+sortingField +' '+ sortDirection;
                    query+=' LIMIT '+pageSize +' OFFSET '+offSet;
                    //set record list value of wrapper class
                    returnData.complaints = Database.query(query);
                }else{
                    //handle more than 2k total records
                    queryMoreComplaints = Database.query(query);
                    String offsetValue = (String)queryMoreComplaints[offset].get(sortingField);
                    query+='WHERE '+sortingField+' '+queryMoreDirection+' :offsetValue';
                    query+=' ORDER BY '+sortingField +' '+ sortDirection;
                    query+=' LIMIT '+pageSize;
                    //System.debug(query);
                    returnData.complaints = Database.query(query);
                }
            }else {
                String query = 'SELECT Name, IETRS_Complaint_Reported_Date_Time__c, ITRES_Complaint_Received__c, ';
                query+='IETRS_Complaint_Resolution_Status__c, IETRS_City__c, IETRS_I_Regulated_Entity_Name_for_Search__c, ';
                query+='IETRS_Organization__r.Name, IETRS_Business_Area__c, IETRS_Complaint_Description__c ';
                query+='FROM IETRS_Complaint__c ';
                query+='WHERE IETRS_Organization__c IN :setAccts ';
                //handle less than 2k total records
                if(!queryMore){
                    query+='ORDER BY '+sortingField +' '+ sortDirection;
                    query+=' LIMIT '+pageSize +' OFFSET '+offSet;
                    //set record list value of wrapper class
                    returnData.complaints = Database.query(query);
                }else{
                    //handle more than 2k total records
                    queryMoreComplaints = Database.query(query);
                    String offsetValue = (String)queryMoreComplaints[offset].get(sortingField);
                    query+='AND '+sortingField+' '+queryMoreDirection+' :offsetValue';
                    query+=' ORDER BY '+sortingField +' '+ sortDirection;
                    query+=' LIMIT '+pageSize;
                    //System.debug(query);
                    returnData.complaints = Database.query(query);
                }
            }

            //set values of wrapper class
            returnData.pageSize = pageSize;
            returnData.pageNumber = pageNumber;
            returnData.totalPages = totalPages;
            returnData.recordStart = offset + 1;
            returnData.recordEnd = totalRows >= recordEnd ? recordEnd : totalRows;
            returnData.totalRows = totalRows;

            //string for JSON serialized wrapped data, plus serialization. 
            String jsonReturnData = JSON.serialize(returnData);
            return jsonReturnData;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Integer countRecords(List<Id> setAccts){
        Integer totalRows;
        if(!setAccts.isEmpty()){
            totalRows = [SELECT count() FROM IETRS_Complaint__c WHERE IETRS_Organization__c IN : setAccts];
        }else{
            totalRows = [SELECT count() FROM IETRS_Complaint__c];
        }
        return totalRows;
    }

    private static List<Id> getAccounts(){
        Set<Id> setAccts = new Set<Id>();

        String strContactID = [SELECT ContactID FROM User WHERE Id = :UserInfo.getUserID() LIMIT 1].ContactId;      

        List<AccountContactRelation> lstRel = [SELECT AccountId FROM AccountContactRelation WHERE ContactId = :strContactID];
        for (AccountContactRelation rel : lstRel){
            setAccts.add(rel.AccountId);
        }
    List<Id> results = new List<Id>(setAccts);
        return results;

    }

    public class ComplaintWrapper {
        public Integer pageSize {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalPages {get;set;}
        public Integer totalRows {get;set;}
        public Integer recordStart {get;set;}
        public Integer recordEnd {get;set;}
        public List<IETRS_Complaint__c> complaints {get;set;}
    }

}