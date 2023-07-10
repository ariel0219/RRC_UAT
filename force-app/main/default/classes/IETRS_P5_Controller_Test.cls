/**
 * @File Name          : IETRS_P5_Controller_Test.cls
 * @Description        : 
 * @Author             : cmckee@sensecorp.com
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 6/25/2020, 8:00:22 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    6/21/2019, 1:34:51 PM   cmckee@sensecorp.com     Initial Version
 * 2.0    06/25/2020              Kevin Lu                 Updated JSON for testing
**/
@IsTest
public with sharing class IETRS_P5_Controller_Test {
    private static String jsonOfficers = '{"officers":[{"operatorNumber":"247628","officerName":"KERR, THOMAS J.","officerTitle":"RESIDENT TEXAS AGENT","locationAddress":"SUITE 360; 16800 IMPERIAL VALLEY DRIVE","locationCity":"HOUSTON","locationState":"TX","locationZip":"77060","billingAddress":"%KERR-WILSON PC, STE 360; 16800 IMPERIAL VALLEY DR","billingCity":"HOUSTON","billingState":"TX","billingZip":"77060","type":"AGENT"},{"operatorNumber":"247628","officerName":"SPARKS, WILLIAM LEE","officerTitle":"PRESIDENT","locationAddress":"135 CASTLEGATE LANE","locationCity":"HOUSTON","locationState":"TX","locationZip":"77065-2053","billingAddress":"9211 WEST RD STE 143 151","billingCity":"HOUSTON","billingState":"TX","billingZip":"77064","type":"OFFICER"},{"operatorNumber":"247628","officerName":"SPARKS, LAUREN MARY","officerTitle":"SECRETARY","locationAddress":"135 CASTLEGATE LANE","locationCity":"HOUSTON","locationState":"TX","locationZip":"77065-2053","billingAddress":"9211 WEST RD STE 143 151","billingCity":"HOUSTON","billingState":"TX","billingZip":"77064","type":"OFFICER"}]}';
    private static String jsonOperator = '{"operators":[{"operatorNumber":"247628","operatorName":"ELECTRAGAS, INC.","operatorStatus":"Active","operatorType":"CORPORATION","locationAddress":"9211 WEST RD STE 143 151","locationCity":"HOUSTON","locationState":"TX","locationZip":"77064","billingAddress":"9211 WEST RD STE 143 151","billingCity":"HOUSTON","billingState":"TX","billingZip":"77064","operatorPhone":"(832) 435-4471","tnr91_114":"No","p5_renewal_month":"March","initial_p5_file_date":"03-23-2004","last_P5_file_date":"02-14-2020"}]}';
   
    private static Officers mfOfficer;
    private static Operators mfOperator;

    static testMethod void testAddOperator()
    {
        mfOperator = Operators.parse(jsonOperator);
        Test.startTest();
        IETRS_P5_Controller testControllerP5 = new IETRS_P5_Controller();
        testControllerP5.addOperator(mfOperator);
        Test.stopTest();

		String upsertedP5Number = mfOperator.Operators.get(0).operatorNumber;
        String p5Number = [Select IETRS_P5_Number__c from Account Where IETRS_P5_Number__c = :upsertedP5Number].get(0).IETRS_P5_Number__c;
        System.assert(p5Number == upsertedP5Number);
    }
    static testMethod void testAddOfficer()
    {
        System.debug('Officers Test Start');
        mfOfficer = Officers.parse(jsonOfficers);
        Test.startTest();
        IETRS_P5_Controller testControllerP5 = new IETRS_P5_Controller();
        testControllerP5.addOfficer(mfOfficer);
        System.debug('Officers Test in-progress');
        Test.stopTest();
        String upsertedLastName= mfOfficer.officers.get(0).officerName.substringBefore(',').Trim();
        String officerLastName = [Select LastName from Contact Where LastName = :upsertedLastName].get(0).LastName;
        System.debug('Officers Test End');
        System.assert(officerLastName == upsertedLastName);
    }

}