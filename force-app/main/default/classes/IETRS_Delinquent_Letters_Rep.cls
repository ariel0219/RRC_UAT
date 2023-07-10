public with sharing class IETRS_Delinquent_Letters_Rep {
    //Aura method to send the data 
    @AuraEnabled(cacheable=true)
    public static List<IETRSInspCorrespondenceDateWrapper>   getIPCorrespondenceDatesWrapper(){
        List<IETRSInspCorrespondenceDateWrapper> listOfIETRSInspCorrespondenceDateWrapper=new List<IETRSInspCorrespondenceDateWrapper>();
        try {
            
            List<AggregateResult> listOfAggregateResults=
                [SELECT   
                 IETRS_Files_Correspondence__r.IETRS_Inspection_Package__c inspackId ,
                 Min(IETRS_Days_Old__c)
                 FROM IETRS_Insp_Correspondence_Date__c 
                 WHERE (IETRS_Date_Type__c IN ('POC Due','Verify Completion') OR Name IN ('POC Due','Verify Completion'))
                 AND IETRS_Files_Correspondence__r.IETRS_Inspection_Package__r.IETRS_Uncorrected_Status__c IN ('Waiting for POC', 'Waiting for Completion')  
                 AND IETRS_Files_Correspondence__r.IETRS_Inspection_Package__r.IETRS_Status__c NOT IN ('Closed','Complete','Pending Close')
                 GROUP BY IETRS_Files_Correspondence__r.IETRS_Inspection_Package__c
                 ORDER BY MIN(IETRS_Days_Old__c) DESC 
                ];
            
            System.debug(listOfAggregateResults[0].get('expr0'));
            System.debug(listOfAggregateResults[0].get('inspackid'));
            Map<Id,Decimal> mapOfAggregateResult=new Map<Id,Decimal>();
            for(AggregateResult aggresult:listOfAggregateResults){
                if( !mapOfAggregateResult.containsKey((Id)aggresult.get('inspackId'))){
                    try{
                        mapOfAggregateResult.put((Id)aggresult.get('inspackId'),(Decimal)aggresult.get('expr0'));
                        
                    }catch(Exception e){
                        System.debug('UnExcepted Exception =>'+e.getMessage());
                    }
                }
            }
            
            Integer rs=(Limits.getLimitQueryRows() - Limits.getQueryRows());
            List<IETRS_Insp_Correspondence_Date__c> listOfIETRSInspCorrespondence_Dates=
                [SELECT   Id,  Name, IETRS_Files_Correspondence__c,
                 IETRS_Files_Correspondence__r.Name ,
                 IETRS_Files_Correspondence__r.IETRS_Inspection_Package__c,
                 IETRS_Files_Correspondence__r.IETRS_Inspection_Package__r.Name ,
                 IETRS_Files_Correspondence__r.IETRS_Inspection_Package__r.IETRS_Organization__c, 
                 IETRS_Files_Correspondence__r.IETRS_Inspection_Package__r.IETRS_Organization__r.Name , 
                 IETRS_Files_Correspondence__r.IETRS_Inspection_Package__r.IETRS_Unit_Name__r.Name ,
                 IETRS_Files_Correspondence__r.IETRS_Insp_POC_Due_Dates__c,
                 IETRS_Correspondence_Date__c,
                 IETRS_Date_Type__c
                 FROM IETRS_Insp_Correspondence_Date__c 
                 WHERE (IETRS_Date_Type__c IN ('POC Due','Verify Completion') OR Name IN ('POC Due','Verify Completion'))
                 AND IETRS_Files_Correspondence__r.IETRS_Inspection_Package__r.IETRS_Uncorrected_Status__c IN ('Waiting for POC', 'Waiting for Completion')
                 AND IETRS_Files_Correspondence__r.IETRS_Inspection_Package__r.IETRS_Status__c NOT IN ('Closed','Complete','Pending Close')
                 AND  IETRS_Files_Correspondence__r.IETRS_Inspection_Package__c IN : mapOfAggregateResult.keySet()
                 order by IETRS_Correspondence_Date__c desc
                 Limit : rs
                 
                ];
            
            Map<Id,IETRSInspCorrespondenceDateWrapper> mapOfIETRSInspCorrespondenceDateWrappers=new Map<Id,IETRSInspCorrespondenceDateWrapper>();
            for(IETRS_Insp_Correspondence_Date__c iETRSInspCorrespondenceDate:listOfIETRSInspCorrespondence_Dates){
                IETRSInspCorrespondenceDateWrapper iETRSInspCorrespondenceDateWrapperInstance=new IETRSInspCorrespondenceDateWrapper();
                try{
                    if(!mapOfIETRSInspCorrespondenceDateWrappers.containsKey(iETRSInspCorrespondenceDate.IETRS_Files_Correspondence__r.IETRS_Inspection_Package__c)){
                        iETRSInspCorrespondenceDateWrapperInstance.InspectionPackageID='/'+iETRSInspCorrespondenceDate.IETRS_Files_Correspondence__r.IETRS_Inspection_Package__c;
                        iETRSInspCorrespondenceDateWrapperInstance.Name=iETRSInspCorrespondenceDate.IETRS_Files_Correspondence__r.IETRS_Inspection_Package__r.Name;
                        iETRSInspCorrespondenceDateWrapperInstance.POCDueDate= iETRSInspCorrespondenceDate.IETRS_Correspondence_Date__c;
                        iETRSInspCorrespondenceDateWrapperInstance.DaysOld=(Decimal)mapOfAggregateResult.get(iETRSInspCorrespondenceDate.IETRS_Files_Correspondence__r.IETRS_Inspection_Package__c);
                        iETRSInspCorrespondenceDateWrapperInstance.Organization= iETRSInspCorrespondenceDate.IETRS_Files_Correspondence__r.IETRS_Inspection_Package__r.IETRS_Organization__r.Name;
                        iETRSInspCorrespondenceDateWrapperInstance.Unit= iETRSInspCorrespondenceDate.IETRS_Files_Correspondence__r.IETRS_Inspection_Package__r.IETRS_Unit_Name__r.Name;
                        mapOfIETRSInspCorrespondenceDateWrappers.put(iETRSInspCorrespondenceDate.IETRS_Files_Correspondence__r.IETRS_Inspection_Package__c,iETRSInspCorrespondenceDateWrapperInstance);
                    }else{
                        //need to think out following field in else scenario or ignor
                        // iETRSInspCorrespondenceDateWrapperInstance.POCDueDate= iETRSInspCorrespondenceDate.IETRS_Files_Correspondence__r.IETRS_Insp_POC_Due_Dates__c;
                    }
                }catch(Exception ex){
                    System.debug('Unexpected Exception -> '+ex.getMessage());
                }
            }
            if(!mapOfIETRSInspCorrespondenceDateWrappers.isEmpty())
                listOfIETRSInspCorrespondenceDateWrapper.addAll(mapOfIETRSInspCorrespondenceDateWrappers.Values());
            
            System.debug('listOfIETRSInspCorrespondenceDateWrapper =>'+listOfIETRSInspCorrespondenceDateWrapper);
            System.debug(listOfIETRSInspCorrespondence_Dates[0].get('IETRS_Files_Correspondence__c'));
            
        } catch (Exception e) {
            listOfIETRSInspCorrespondenceDateWrapper=null;
            throw new AuraHandledException(e.getMessage());
        }
        
        return listOfIETRSInspCorrespondenceDateWrapper;
    }

    //Wrapper Class to Store the Data and Transfer to Component.
    public class IETRSInspCorrespondenceDateWrapper{
        @AuraEnabled
        public String InspectionPackageID;
        @AuraEnabled
        public Date POCDueDate;
        @AuraEnabled
        public Decimal DaysOld;
        @AuraEnabled
        public String Organization;
        @AuraEnabled
        public String Unit;
        @AuraEnabled
        public String Name;
    }
}