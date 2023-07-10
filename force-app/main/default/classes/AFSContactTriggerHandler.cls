public with sharing class AFSContactTriggerHandler {
    
    public static void beforeInsertLogic(List<Contact> newContactList) {
        List<Contact> newContactCollection = new List<Contact>();
        for (Contact newCont : newContactList) {
            if (newCont.AFS_Social_Security_Number__c != null && newCont.AFS_Social_Security_Number__c.length() >= 4) {
                newCont.AFS_Last_4_SSN__c = string.ValueOf(newCont.AFS_Social_Security_Number__c.right(4));
            }
        }
    }
    
    public static void updateContactFields(List<Contact> contactList, Map<Id, Contact> oldMap) {                                        
        for (Contact con : contactList) {
            if (oldMap != null && con.AFS_Social_Security_Number__c != oldMap.get(con.Id).AFS_Social_Security_Number__c && con.AFS_Social_Security_Number__c.length() >= 4) {
                con.AFS_Last_4_SSN__c = string.ValueOf(con.AFS_Social_Security_Number__c.right(4));
                System.debug('Last 4 SSN = ' + string.ValueOf(con.AFS_Social_Security_Number__c.right(4)));
                System.debug('Record Last 4 SSN = ' + con.AFS_Last_4_SSN__c);
            } else if (oldMap != null && con.AFS_LIS_Person_ID__c != oldMap.get(con.Id).AFS_LIS_Person_ID__c) {
                con.AFS_Social_Security_Number__c = null;
            }
        }
    }
    
    /*public static void updateRegistrantFields(List<Contact> contactList, Map<Id, Contact> oldMap) { 
        List<EEM_Registrant__c> updateRegList = new List<EEM_Registrant__c>();
        Set<Id> conIds = new Set<Id>();
        for (Contact con : contactList) {
            if (con.AFS_Social_Security_Number__c != oldMap.get(con.Id).AFS_Social_Security_Number__c 
                || con.FirstName != oldMap.get(con.Id).FirstName || con.LastName != oldMap.get(con.Id).LastName
                || con.Email != oldMap.get(con.Id).Email || con.Phone != oldMap.get(con.Id).Phone
                || con.MailingAddress != oldMap.get(con.Id).MailingAddress) {
        		conIds.add(con.Id);  
             }
        }
        List<EEM_Registrant__c> regList = [Select id, EEM_First_Name__c, EEM_Last_Name__c, EEM_Email__c, 
                                   EEM_Phone_Number__c, EEM_Street_Address_1__c, EEM_City__c, 
                                   EEM_State__c, EEM_Zip_Code__c, EEM_Country__c, AFS_Related_Contact__c  
                                   from EEM_Registrant__c where AFS_Related_Contact__c in: conIds];
        if(conIds != null && conIds.size() > 0 && regList.size() > 0){
            for (Contact con : contactList) {
                for (EEM_Registrant__c reg : regList) {
                    if(con.Id == reg.AFS_Related_Contact__c) { 
                        reg.EEM_First_Name__c = con.FirstName;
                        reg.EEM_Last_Name__c = con.LastName;
                        reg.EEM_Email__c = con.Email;
                        reg.EEM_Phone_Number__c = con.Phone;
                        reg.EEM_Street_Address_1__c = con.MailingStreet;
                        reg.EEM_City__c = con.MailingCity;
                        reg.EEM_State__c = con.MailingState;
                        reg.EEM_Zip_Code__c = con.MailingPostalCode;
                        reg.EEM_Country__c = con.MailingCountry;
                        reg.AFS_Social_Security_Number__c  = con.AFS_Social_Security_Number__c;
                        updateRegList.add(reg);
                    }
                } 
            }
            if(updateRegList != null && updateRegList.size() > 0) {
                update updateRegList;
            }            
        }
    }*/

}