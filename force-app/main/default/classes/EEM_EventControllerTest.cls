@isTest
public class EEM_EventControllerTest {
    @testSetup static void setupMethod(){
        Id classRecordTypeId = Schema.SObjectType.EEM_Event__c.getRecordTypeInfosByName().get('Class').getRecordTypeId();
        Id examRecordTypeId = Schema.SObjectType.EEM_Event__c.getRecordTypeInfosByName().get('Exam').getRecordTypeId();
        
        //Create Class Event (8 hour and 2.1 dispenser operations course - ICI) - 2 exams
        EEM_Event__c classEvent = new EEM_Event__c();
        classEvent.EEM_Class_Level__c = 'Initial Course of Instruction';
        classEvent.EEM_Hours__c = '8';
        classEvent.EEM_ICI_Type__c = '2.1 dispenser operations course';
        classEvent.RecordTypeId = classRecordTypeId;
        insert classEvent;
        //Create Exam Event (In person, Management and Employee, and CNG,LNG,LPG) - 57 exams
        EEM_Event__c examEvent = new EEM_Event__c();
        examEvent.EEM_Exam_Level__c = 'Management and Employee';
        examEvent.EEM_Event_Type__c = 'In Person';
        examEvent.EEM_Fuel_Type__c = 'CNG,LNG,LPG';
        examEvent.RecordTypeId = examRecordTypeId;
        insert examEvent;
        
    }
    
    @isTest static void testGetAssociatedExamsFromEvent(){
        Id classRecordTypeId = Schema.SObjectType.EEM_Event__c.getRecordTypeInfosByName().get('Class').getRecordTypeId();
        Id examRecordTypeId = Schema.SObjectType.EEM_Event__c.getRecordTypeInfosByName().get('Exam').getRecordTypeId();
        List<EEM_Event__c> classEvents = [select id, RecordType.Name from eem_event__c where recordtypeid =: classRecordTypeid];
        List<EEM_Event__c> examEvents = [select id, RecordType.Name from eem_event__c where recordtypeid =: examRecordTypeId];
        List<EEM_Event__c> getfee = [select id, RecordType.Name from eem_event__c ];
        System.debug('Number of Class Events in Test: '+classEvents.size());
        System.debug('Class Id: '+classEvents[0].id+' and Record Type: '+classEvents[0].recordtype.name);
        System.debug('Number of Exam Events in Test: '+classEvents.size());
        System.debug('Class Id: '+examEvents[0].id+' and Record Type: '+examEvents[0].recordtype.name);
        Test.startTest();
        List<EEM_Event__c> listExamsForClass = EEM_EventController.getAssociatedExamsFromEvent(classEvents[0].id, classEvents[0].recordtype.name);
        List<EEM_Event__c> listExamsForExam =  EEM_EventController.getAssociatedExamsFromEvent(examEvents[0].id, examEvents[0].recordtype.name);
         List<EEM_Event__c> getclassfee =  EEM_EventController.getClassFee(getfee[0].id);
        Test.stopTest();
       // System.assertEquals(2, listExamsForClass.size());
       // System.assertEquals(57, listExamsForExam.size());
    }
}