@isTest
public class IETRS_CommActionCasesControllerTest {
    static testMethod void IETRS_CommActionCasesControllerTest(){
        Account acct = new Account(Name='Test');
        insert acct;

        Case c = new Case(IETRS_Primary_Account_Assignment__c = acct.Id,
                          IETRS_Ready_for_Conference__c= true, 
                          IETRS_Agenda_Section__c= 'Agreed Enforcement Orders');
        c.IETRS_Conference_Date__c = Date.newInstance(2020, 12, 9);
        insert c;

        IETRS_Commission_Action__c ca = new IETRS_Commission_Action__c(IETRS_Agenda_Section__c='Agreed Enforcement Orders');
        insert ca;
        
		list<Case> lstCasesPositiveTest = IETRS_CommActionCasesController.getCaseList(true, 'Agreed Enforcement Orders', Date.newInstance(2020, 12, 9), ca.Id);
        system.assertEquals(c.id, lstCasesPositiveTest[0].id);
        
        //list<Case> lstCasesNegativeTest = IETRS_CommActionCasesController.getCaseList(false, 'Agreed Enforcement Orders', Date.newInstance(2020, 12, 9));
        //system.assertEquals(0, lstCasesNegativeTest.size());
    }
}