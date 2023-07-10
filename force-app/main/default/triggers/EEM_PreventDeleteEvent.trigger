trigger EEM_PreventDeleteEvent on EEM_Event__c (before delete) {

  If(trigger.isBefore){
   If(Trigger.isDelete){
       for(EEM_Event__c ee: trigger.old){
           if(ee.EEM_Total_Registrant__c> 0){
               ee.adderror('You can’t delete an event that has registrants');
                 }
             }

        }
   }
}