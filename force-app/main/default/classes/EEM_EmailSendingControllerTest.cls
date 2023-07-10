@isTest(SeeAllData=true)
public with sharing class EEM_EmailSendingControllerTest {

 static testMethod void testEEM_EmailSendingControllerTest(){
   EEM_Event__c evtObj = new EEM_Event__c();
   EEM_Event_Registration__c evtRegist = new  EEM_Event_Registration__c();
     
Try{
    evtRegist = [SELECT EEM_Event__c,EEM_Registrant__c,Id FROM EEM_Event_Registration__c where EEM_Registrant__c !=null order by EEM_Registrant__c LIMIT 1];
   evtObj = [SELECT Id,Name from EEM_Event__c where Id = :evtRegist.EEM_Event__c ];
} 
Catch(System.QueryException e){
   // Perform logic here
    System.debug('test evtObj error'+e.getMessage());
}       
System.debug('test evtObj Id '+ evtObj.Id);

     PageReference pageRef = Page.EEM_sendEmail;
      Test.setCurrentPage(pageRef);
        
     pageRef.getParameters().put('Id', evtObj.Id);
     ApexPages.StandardController sc = new ApexPages.StandardController(evtObj);
            
        System.debug('test '+ sc.getId());
        
     EEM_EmailSendingController testRegistrants = new EEM_EmailSendingController(sc);
     System.debug('TestRegistrants : '+ testRegistrants.eemRegistrantList.get(0).EEM_Name__c);
     testRegistrants.toMail = 'sarabpreet.singh@rrc.texas.gov';
     testRegistrants.subjectMail = 'Testing EmailSendingController';
     testRegistrants.htmlBodyMail = 'Email testing for EmailSendingController class';
     testRegistrants.All = false;
     testRegistrants.sendMail();
	 
    }
}