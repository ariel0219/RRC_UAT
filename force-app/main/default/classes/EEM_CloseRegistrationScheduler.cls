public class EEM_CloseRegistrationScheduler implements Schedulable {
   public void execute(SchedulableContext SC) {
      List<EEM_Event__c> eventsForRegistrationClose = [SELECT Id,EEM_Event_Status__c FROM EEM_Event__c WHERE EEM_Close_Registration_Date__c = YESTERDAY  AND EEM_Event_Status__C!='Cancelled'];
       for(EEM_Event__c event : eventsForRegistrationClose){
           event.EEM_Event_Status__c = 'Closed For Registration';
       }
       update eventsForRegistrationClose;
   }
}