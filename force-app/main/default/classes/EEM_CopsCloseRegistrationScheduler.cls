public class EEM_CopsCloseRegistrationScheduler implements Schedulable {
   public void execute(SchedulableContext SC) {
      List<EEM_Event__c> copsEventsForRegistrationClose = [SELECT Id,EEM_Event_Status__c FROM EEM_Event__c WHERE EEM_COPS_Close_Registration_Date__c = YESTERDAY  AND EEM_Event_Status__C!='Cancelled' AND EEM_Event_Status__C!= 'Closed'];
       for(EEM_Event__c event : copsEventsForRegistrationClose){
           event.EEM_Event_Status__c = 'Closed For Registration';
       }
       update copsEventsForRegistrationClose;
   }
}