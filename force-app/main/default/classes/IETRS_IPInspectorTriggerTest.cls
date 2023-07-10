@isTest
public class IETRS_IPInspectorTriggerTest {

    @isTest
    public static void testDataSetup(){
       List<IETRS_Insp_Inspection_Package_Inspector__c> ipInspectors = new List<IETRS_Insp_Inspection_Package_Inspector__c>();
         Profile inspectorProfile = [SELECT Id FROM Profile WHERE Name = 'IETRS Inspections - Inspector' LIMIT 1];
         User us = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = inspectorProfile.Id,
                            isActive=true,
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        
        IETRS_Inspection_Package__c testIp= new IETRS_Inspection_Package__c();
        testIp.IETRS_Lead_Inspector__c=us.Id;
        insert testIp;        
        
        
        for (User u : [SELECT Id FROM User WHERE ProfileId = :inspectorProfile.Id LIMIT 3]) {
            if (testIp.IETRS_Lead_Inspector__c == null) {
                testIp.IETRS_Lead_Inspector__c = u.Id;
            } else {
                ipInspectors.add(
                    new IETRS_Insp_Inspection_Package_Inspector__c(
                        IETRS_Inspector__c = u.Id,
                        IETRS_Inspection_Package__c = testIp.Id
                    )
                );
            }
        }
        
        insert ipInspectors;
       
        update ipInspectors;
        
        delete ipInspectors;
        
        undelete ipInspectors;
        
        
        
        Test.startTest();
        // update test ip with a lead inspector
        /*update testIp;
        // insert
        insert ipInspectors;
        // update
        ipInspectors[0].IETRS_Inspector__c = ipInspectors[1].IETRS_Inspector__c;
        update ipInspectors[0];
        // delete
        Id deleteId = ipInspectors[0].Id;
        delete ipInspectors[0];
        // undelete
        undelete [SELECT Id FROM IETRS_Insp_Inspection_Package_Inspector__c WHERE Id = :deleteId ALL ROWS];
        Test.stopTest();
        IETRS_Inspection_Package__c postTestIp = [
            SELECT Id, IETRS_Assigned_Inspector_List__c
            FROM IETRS_Inspection_Package__c
            WHERE Id = :testIp.Id
            LIMIT 1
        ];
        
        System.assert(
            postTestIp.IETRS_Assigned_Inspector_List__c != null,
            'The IP assigned inspector list should have been set on this field.'
        );
        //IETRS_Insp_Inspection_Package_Inspector__c inspectionInstance=new IETRS_Insp_Inspection_Package_Inspector__c();
        //inspectionInstance.IETRS_Inspector__c=''; //User 
      //  inspectionInstance.IETRS_Inspection_Package__c='';//Inspection Package        
    	*/
    }
    
}