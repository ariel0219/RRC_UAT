@isTest
public class EEM_RegistrationCheckInTest {
    
     
    @isTest static void testGetRegistrationCheckInList(){
        List<EEM_Event_Registration__c> eemRegistationList = new List<EEM_Event_Registration__c>();
        eemRegistationList = [SELECT Registrant_Name__c,EEM_Event__c  FROM EEM_Event_Registration__c WHERE EEM_Event__c !=null and Registrant_Name__c !=null limit 1];
        String rName;
        String vEventId;
        for(EEM_Event_Registration__c recordRegistration : eemRegistationList )
        { 
          rName = String.valueOf(recordRegistration.get('Registrant_Name__c'));
          vEventId = String.valueOf(recordRegistration.get('EEM_Event__c'));
        }
        
        System.Test.startTest();
        List<EEM_Event_Registration__c> listRegistrations= EEM_RegistrationCheckIn.getRegistrationCheckInList(vEventId);
        List<EEM_Event_Registration__c> findRegistrations =  EEM_RegistrationCheckIn.findRegistrationCheckIn(rName,vEventId);
        Integer vtotalCount = EEM_RegistrationCheckIn.getTotalCount(vEventId);
        Integer vCheckInCount = EEM_RegistrationCheckIn.getCheckInCount(vEventId);
        
        Integer vNotCheckedInCount = EEM_RegistrationCheckIn.getNotCheckedInCount(vEventId);
        Integer vOnholdCount = EEM_RegistrationCheckIn.getOnholdCount(vEventId);
        Integer vregisteredCount = EEM_RegistrationCheckIn.getRegisteredCount(vEventId);
        String vevenTile =  EEM_RegistrationCheckIn.getEventTitle(vEventId);
        
        System.Test.stopTest();
       
    }
}