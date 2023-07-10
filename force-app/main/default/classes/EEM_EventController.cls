public without sharing class EEM_EventController {
    @AuraEnabled(cacheable = true)
    public static List<EEM_Event__c> getAssociatedExamsFromEvent(String eventId, String recordType){
        List<EEM_Event__c> associatedExams = new List<EEM_Event__c>();
        
        try {
            if(recordType=='Class'){
                associatedExams = [SELECT id, EEM_Event_Title__c, EEM_Class_Fee__c,EEM_Fee_Code__c,EEM_Exam_Fee__c, EEM_Fuel_Type__c, EEM_Exam_Level__c, RecordType.Name FROM EEM_Event__c WHERE EEM_Class_Event__c =: eventId]; 
               
            }else{
                
                associatedExams = [SELECT id, EEM_Event_Title__c, EEM_Class_Fee__c,EEM_Exam_Fee__c,EEM_Fee_Code__c, EEM_Fuel_Type__c, EEM_Exam_Level__c, RecordType.Name FROM EEM_Event__c WHERE EEM_Exam_Event__c =: eventId]; 
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return associatedExams;
    }
    @AuraEnabled(cacheable=true)
    public static List<EEM_Event__c> getClassFee(String eventId)
    {
        System.debug('check eventId'+eventId);
       List<EEM_Event__c> getEventClassFee=[SELECT id, EEM_Event_Title__c, EEM_Class_Fee__c,EEM_Exam_Fee__c,EEM_Event_Type__c,EEM_ICI_Type__c,EEM_Fee_Code__c, EEM_Fuel_Type__c, EEM_Exam_Level__c, RecordType.Name FROM EEM_Event__c WHERE Id=:eventId];
       // System.debug('check associated exams'+selectedAssociatedExams);
        return getEventClassFee;
    }
}