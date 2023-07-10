global without sharing class Form16attachmentscontroller {

/* Variables and Constants */

global String PageContents{ get; set; }
global String RegistrantId{ get; set {
    UpdateContents(value);
} }

  
public  void UpdateContents(String RegistrantId) 
{       
    try {
        PageReference pageRef = Page.EEM_LPG;
        List<EEM_Event_Registration__c> lstEvents = [SELECT EEM_Full_Name__c,TransactionRegisterNumber__c,EEM_Event_Title__c,Amount_Paid__c,Fuel_Type1__c,Fuel_Type2__c,Class_Title1__c,Class_Title_2__c,Exam_Fee_1__c,Exam_Fee_2__c,Exam_Level_1__c,Exam_Level_2__c,EEM_Event_Start_Date_And_Time__c,EEM_Event__c,EEM_Registrant_Email__c,EEM_Amount_Paid__c,EEM_Register_Number__c,EEM_Registrant__c,EEM_Transaction__c
                                   FROM EEM_Event_Registration__c WHERE Id =:registrantId];
        if(!lstEvents.isEmpty()) {
            List<EEM_Registrant__c> lstRegistrant = [SELECT EEM_Address__c,EEM_City_State_Zip__c,EEM_Late_Renewal_Fee__c,EEM_Name__c,Name,EEM_City__c,EEM_Company_Name__c,EEM_RRC_Company_License_Number__c,EEM_RRC_Number__c,EEM_State__c,EEM_Zip_Code__c,EEM_Associated_Exam__c
                            FROM EEM_Registrant__c WHERE id =:lstEvents[0].EEM_Registrant__c];
            List<EEM_Transaction__c> lstTran = [SELECT EEM_Register_Number__c,EEM_Remittance_Status__c
                        FROM EEM_Transaction__c WHERE id =:lstEvents[0].EEM_Transaction__c]; 
            pageRef.getParameters().put('registrantid', RegistrantId);
            pageRef.getParameters().put('eventregistration', !lstEvents.isEmpty() ? JSON.serialize(lstEvents[0]) : '');
            pageRef.getParameters().put('registrant', !lstRegistrant.isEmpty() ? JSON.serialize(lstRegistrant[0]) : '');
            pageRef.getParameters().put('transaction', !lstTran.isEmpty() ? JSON.serialize(lstTran[0]) : '');
        }
       PageContents = pageRef.getContent().toString().replace
     
        ('<html style="display:none !important;">', '<html>');
    } catch(exception ex) { 
        PageContents = 'An error has occurred while trying to generate this form.  Please contact your administrator.';
     
    
    }
    
}
}