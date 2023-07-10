@isTest
public class IETRS_StaffAssignmentsTest {

    @isTest
    static void caseStaffAssignmentsSetup(){
        Id idCaseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Hearings').getRecordTypeId();
        Id idAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        
        //Create a Org Account to assign as a Primary Account to Case
        Account acctTest = new Account(Name='Test Account', RecordTypeId=idAccountRecordType);
        insert acctTest;
        
        //Create a Case to which Staff Assignments will be assigned
        Case caseTest = new Case(RecordTypeId=idCaseRecordType,
                                IETRS_Primary_Account_Assignment__c=acctTest.Id,
                                Status='Active',
                                Type='AFR');
        insert caseTest;

        //Create a set of test users that will be associated with a case as Staff Assignment records
        List<User> lstUser = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='IETRS Case - Hearings'];
        for (Integer i=0; i<4; i++){
            String uniqueUserName = 'hearinguser' + i + '@testorg.com'; 
            User u = new User(Alias = 'hearing',
                            Email='hearinguser@testorg.com',
                            EmailEncodingKey='UTF-8', 
                            LastName='Testing', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName=uniqueUserName);
            lstUser.add(u);
        }

        //Create a map of Roles and Lead status to assign sequentially to the Staff Assignment records
        Map<String,Boolean> mapRoleLead = new Map<String,Boolean>();
        mapRoleLead.put('Technical Reviewer', true);
        mapRoleLead.put('Administrative Staff', false);
        mapRoleLead.put('Staff Attorney', false);
        mapRoleLead.put('Staff Examiner', true);

        Integer j = 0;
        List<IETRS_Case_Staff_Assignment__c> lstSA = new List<IETRS_Case_Staff_Assignment__c>();
        String strHearingsRecTypeId = Schema.Sobjecttype.IETRS_Case_Staff_Assignment__c.getRecordTypeInfosByDeveloperName().get('Division_Managed').getRecordTypeId();
        for(string key : mapRoleLead.keySet()){
            IETRS_Case_Staff_Assignment__c sa = new IETRS_Case_Staff_Assignment__c(IETRS_Case__c = caseTest.Id,
                                                                                IETRS_Assigned_Staff_Member__c = lstUser[j].Id,
                                                                                IETRS_Role__c = key,
                                                                                IETRS_Lead__c = mapRoleLead.get(key),
                                                                                RecordTypeId = strHearingsRecTypeId);
            lstSA.add(sa);
            j++;
        }
        insert lstSA;

    }

    @isTest
    static void getSortedStaffAssignmentsList(){
        caseStaffAssignmentsSetup();
        List<Case> lstcaseTest = [SELECT ID FROM Case LIMIT 1];
        Case caseTest = lstcaseTest[0];
        String strSortOrder = 'Staff Attorney;Staff Examiner;Technical Reviewer;Administrative Staff';
        boolean blnHearings = False;

        List<IETRS_Case_Staff_Assignment__c> lstSA =  IETRS_StaffAssignmentsController.getRelatedStaffAssignments(String.valueof(caseTest.Id), strSortOrder, blnHearings);

        for (Integer i=0; i<lstSA.size(); i++){
            IETRS_Case_Staff_Assignment__c sa = lstSA[i];
            switch on i{
                when 0{
                    system.assertEquals('Staff Examiner', sa.IETRS_Role__c);
                    system.assertEquals(true, sa.IETRS_Lead__c);
                }
                when 1{
                    system.assertEquals('Technical Reviewer', sa.IETRS_Role__c);
                    system.assertEquals(true, sa.IETRS_Lead__c);
                }
                when 2{
                    system.assertEquals('Staff Attorney', sa.IETRS_Role__c);
                    system.assertEquals(false, sa.IETRS_Lead__c);
                }
                when 3{
                    system.assertEquals('Administrative Staff', sa.IETRS_Role__c);
                    system.assertEquals(false, sa.IETRS_Lead__c);
                }
            }
            
        }
        
    }
}