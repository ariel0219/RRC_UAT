/**
 * @File Name          : IETRS_Party_Assignments_Test.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 6/10/2020, 10:38:50 AM
 * @Modification Log   : 
 * Ver      Date            Author      		    Modification
 * 1.0      03/23/2020      Kevin Lu                Initial Version
 * 2.0      06/10/2020      Kevin Lu                Changed test setup to include last change date
**/
@IsTest
private class IETRS_Party_Assignments_Test {
    @TestSetup
    static void makeData(){
        IETRS_WebService__c webServiceSetting = new IETRS_WebService__c();
        webServiceSetting.authEndPoint__c = 'http://test.rrc.texas.gov/integration/oauth/token';
        webServiceSetting.Client_Id__c = 'sensecorp';
        webServiceSetting.Client_Secret__c = 'ietrs4RRC';
        webServiceSetting.Rest_EndPoint__c = 'http://test.rrc.texas.gov/integration/oauth/rest/';
        
        insert webServiceSetting;
        
        RecordType organizationRecordType = [Select Id From RecordType Where SObjectType = 'Account' And Name = 'Organization' Limit 1];
        RecordType contactRecordType = [Select Id From RecordType Where SObjectType = 'Contact' And Name = 'Read Only Contact' Limit 1];

        Account operator = new Account(
            RecordTypeId = organizationRecordType.Id,
            Name = 'ELECTRAGAS, INC.',
            IETRS_P5_Number__c = '247628',
            IETRS_Last_Change__c = Date.newInstance(2020, 5, 1)
        );
        insert operator;

        Contact officerOne = new Contact(
            RecordTypeId = contactRecordType.Id,
            LastName = 'SPARKS',
            FirstName = 'WILLIAM LEE',
            Title = 'PRESIDENT',
            IETRS_Contact_Type__c = 'Officer',
            AccountId = operator.Id,
            IETRS_P5_Officer_ID__c = 'WILLIAM LEE|SPARKS|PRESIDENT|247628',
            IETRS_Last_Change__c = Date.newInstance(2020, 5, 1)
        );
        insert officerOne;

        Contact officerTwo = new Contact(
            RecordTypeId = contactRecordType.Id,
            LastName = 'SPARKS',
            FirstName = 'LAUREN MARY',
            Title = 'SECRETARY',
            IETRS_Contact_Type__c = 'Officer',
            AccountId = operator.Id,
            IETRS_P5_Officer_ID__c = 'LAUREN MARY|SPARKS|SECRETARY|247628',
            IETRS_Last_Change__c = Date.newInstance(2020, 5, 1)
        );
        insert officerTwo;

        Contact outdatedOfficer = new Contact(
            RecordTypeId = contactRecordType.Id,
            LastName = 'SPARKS',
            FirstName = 'JANE',
            Title = 'SECRETARY',
            IETRS_Contact_Type__c = 'Officer',
            AccountId = operator.Id,
            IETRS_P5_Officer_ID__c = 'JANE|SPARKS|SECRETARY|247628',
            IETRS_Last_Change__c = Date.newInstance(2020, 5, 1)
        );
        insert outdatedOfficer;

        Case c = new Case(
            Subject = 'Test Case',
            IETRS_Primary_Account_Assignment__c = operator.Id,
            Status = 'Active'
        );
        insert c;

        Case secondaryCase = new Case(
            Subject = 'Test Case 2',
            IETRS_Primary_Account_Assignment__c = operator.Id,
            Status = 'Active'
        );
        insert secondaryCase;

        //Party Assignemnts automatically created
    }
    
    @IsTest
    static void testUpdatePartyAssignments(){
        Case c = [Select Id From Case Where Subject = 'Test Case' Limit 1];

        List<MockHttpResponseGenerator_IETRS.MockResponse> responses = new List<MockHttpResponseGenerator_IETRS.MockResponse>();
        MockHttpResponseGenerator_IETRS.MockResponse tokenResponse = new MockHttpResponseGenerator_IETRS.MockResponse('{"access_token":"fake_token"}', 'OK', 200);
        responses.add(tokenResponse);

        MockHttpResponseGenerator_IETRS.MockResponse operatorResponse = new MockHttpResponseGenerator_IETRS.MockResponse('{"operators":[{"operatorNumber":"247628","operatorName":"ELECTRAGAS, INC.","operatorStatus":"Active","operatorType":"CORPORATION","locationAddress":"9211 WEST RD STE 143 151","locationCity":"HOUSTON","locationState":"TX","locationZip":"77064","billingAddress":"9211 WEST RD STE 143 151","billingCity":"HOUSTON","billingState":"TX","billingZip":"77064","operatorPhone":"(832) 435-4471","tnr91_114":"No","p5_renewal_month":"March","initial_p5_file_date":"03-23-2004","last_P5_file_date":"02-14-2020"}]}', 'OK', 200);
        responses.add(operatorResponse);

        MockHttpResponseGenerator_IETRS.MockResponse officerResponse = new MockHttpResponseGenerator_IETRS.MockResponse('{"officers":[{"operatorNumber":"247628","officerName":"KERR, THOMAS J.","officerTitle":"RESIDENT TEXAS AGENT","locationAddress":"SUITE 360; 16800 IMPERIAL VALLEY DRIVE","locationCity":"HOUSTON","locationState":"TX","locationZip":"77060","billingAddress":"%KERR-WILSON PC, STE 360; 16800 IMPERIAL VALLEY DR","billingCity":"HOUSTON","billingState":"TX","billingZip":"77060","type":"AGENT"},{"operatorNumber":"247628","officerName":"SPARKS, WILLIAM LEE","officerTitle":"PRESIDENT","locationAddress":"135 CASTLEGATE LANE","locationCity":"HOUSTON","locationState":"TX","locationZip":"77065-2053","billingAddress":"9211 WEST RD STE 143 151","billingCity":"HOUSTON","billingState":"TX","billingZip":"77064","type":"OFFICER"},{"operatorNumber":"247628","officerName":"SPARKS, LAUREN MARY","officerTitle":"SECRETARY","locationAddress":"135 CASTLEGATE LANE","locationCity":"HOUSTON","locationState":"TX","locationZip":"77065-2053","billingAddress":"9211 WEST RD STE 143 151","billingCity":"HOUSTON","billingState":"TX","billingZip":"77064","type":"OFFICER"}]}', 'OK', 200);
        responses.add(officerResponse);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_IETRS(responses));
        Test.startTest();
        List<Id> lstId = new List<Id>();
        lstId.add(c.Id);
        List<String> listResult = IETRS_Party_Assignments_Controller.updatePartyAssignments(lstId);
        Test.stopTest();
        System.assertEquals(1, 1, 'This should never fail');

        for(Case caseRecord : [
            Select Id, Subject, (Select Id, IETRS_Contact__r.Name From Party_Assignments__r)
            From Case
            Where IETRS_Primary_Account_Assignment__r.IETRS_P5_Number__c = '247628'
        ]) {
            for(IETRS_Party_Assignment__c pa : caseRecord.Party_Assignments__r) {
                System.debug(pa.IETRS_Contact__r.Name);
            }
            System.assertEquals(3, caseRecord.Party_Assignments__r.size(), 'Incorrect number of assignments for case ' + caseRecord.subject);   
        }
    }
}