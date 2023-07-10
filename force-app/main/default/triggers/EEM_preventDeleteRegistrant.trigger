trigger EEM_preventDeleteRegistrant on EEM_Registrant__c (before delete) {

If(trigger.isBefore){
   If(Trigger.isDelete){
       for(EEM_Registrant__c er:trigger.old){
           if(er.EEM_Total_Event_Association__c>0) {
               er.adderror('You can’t delete Registrant record that has Event Registration associated with it.');
                 }
             }
        }
   }
}