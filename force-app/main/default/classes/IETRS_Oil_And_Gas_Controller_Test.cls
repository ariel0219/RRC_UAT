/**
 * @File Name          : IETRS_Oil_And_Gas_Controller_Test.cls
 * @Description        : 
 * @Author             : cmckee@sensecorp.com
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 10/21/2019, 2:44:57 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    6/20/2019, 3:15:44 PM   cmckee@sensecorp.com     Initial Version
 * 2.0	  10/15/2019			  Kevin Lu				   Added test for drilling permits
**/
@isTest
public with sharing class IETRS_Oil_And_Gas_Controller_Test {
    private static Wells testWells;
    private static Leases testLease;
        
    @TestSetup
    static void methodCustomSetting() {
        try{
			RecordType recordTypeOp = [Select Id From RecordType Where SObjectType = 'Account' And Name = 'Organization'].get(0);
			IETRS_County__c county = new IETRS_County__c();
			county.Name = 'Travis';
			county.IETRS_Oil_Gas_County_Code__c = '001';
			upsert county IETRS_Oil_Gas_County_Code__c;
				
			IETRS_County_Group__c cGroup = new IETRS_County_Group__c();
			cGroup.Name = 'TRAVIS';
			cGroup.IETRS_County_Group_External_ID__c = '01|OG';
			System.debug(cGroup);
			upsert cGroup IETRS_County_Group_External_ID__c;
				
			IETRS_County_Group__c ctyStatewide = new IETRS_County_Group__c();
			ctyStatewide.IETRS_Group_Type__c = 'Region';
			ctyStatewide.Name = '00-Statewide';
			ctyStatewide.IETRS_Business_Area__c = 'Pipeline Safety';
			insert ctyStatewide;
				
			IETRS_P5_Controller controller  = new IETRS_P5_Controller();
			Operators mfOperator = Operators.parse(testOperatorsJSON());
			controller.addOperator(mfOperator);
			controller.upsertP5();
        } catch (DmlException e) {
            System.debug(e.getMessage());
            System.debug(e.getCause());
        }
    }

    @isTest
	static void testAddWell() {
        testWells = Wells.parse(testWellJSON());
        Test.startTest();
        IETRS_Oil_And_Gas_Controller testController = new IETRS_Oil_And_Gas_Controller();
        testController.addWell(testWells);
        Test.stopTest();
        List<Wells.Well> ws = testWells.wells;
        System.debug(ws.get(0).apiNumber);
        String upsertedAPINUmber = ws.get(0).apiNumber;
        String apiNumber = [Select IETRS_API__c from Account Where IETRS_API__c = :upsertedAPINUmber].get(0).IETRS_API__c;
        System.assert(apiNumber == upsertedAPINUmber);
    }

    @isTest
	static void testAddLease() {
        testLease = Leases.parse(testLeaseJSON());
        System.debug(testLease);
        Test.startTest();
        IETRS_Oil_And_Gas_Controller testController = new IETRS_Oil_And_Gas_Controller();
        testController.addLease(testLease);
        Test.stopTest();
        String upsertedLeaseNumber = testLease.Leases.get(0).leaseNumber;
        System.debug('upsertedLeaseNumber: '+upsertedLeaseNumber);
        
        String leaseNumber = [Select IETRS_Lease_Number__c from Account Where IETRS_Lease_Number__c = :upsertedLeaseNumber].get(0).IETRS_Lease_Number__c;
        System.debug('leaseNumber: '+leaseNumber);
        System.assert(leaseNumber == upsertedLeaseNumber);
    }

	@isTest
	static void testAddDrillingPermits() {
		IETRS_DrillingPermits testDrillingPermit = IETRS_DrillingPermits.parse(testDrillingPermitJSON());
		Test.startTest();
		IETRS_Oil_And_Gas_Controller testController = new IETRS_Oil_And_Gas_Controller();
		testController.addDrillingPermits(testDrillingPermit);
		Test.stopTest();

		List<Account> lstDrillingPermits = [Select Id From Account Where RecordType.Name = 'Regulated Entity - OG' And Type = 'Drilling Permit'];
		System.assertEquals(1, lstDrillingPermits.size(), 'Drilling Permit Mismatch');

		List<Account> lstPermittedFields = [Select Id From Account Where RecordType.Name = 'Field' And Type = 'Permitted Field'];
		System.assertEquals(3, lstPermittedFields.size(), 'Permitted Fields Mismatch');
	}

	private static String testDrillingPermitJSON() {
		String json = '{"drillingPermits":[{"drillingPermitNumber":"679291","drillingPermitSequence":"99","operatorNumber":"177997","districtCode":"09","countyName":"HARDEMAN","leaseName":"JACKSON-O\'NEAL UNIT","wellNumber":"   1  ","totalDepth":"9300","wellApiNumber":"19731641","submittedDate":"03-09-2009","approvedDate":"03-18-2009","permitStatus":"Approved","permittedFields":[{"primaryField":"Y","fieldNumber":"73613500","fieldName":"QUANAH, SOUTH (CHAPPEL)","districtCode":"09","horizSevUpperDepth":null,"horizSevLowerDepth":null,"swr37lException":"N","swr37bException":"N","swr37iException":"N","swr37hException":"N","swr38Exception":"N","swr38dException":"N","swr39Exception":"N"},{"primaryField":"N","fieldNumber":"00022001","fieldName":"WILDCAT","districtCode":"09","horizSevUpperDepth":null,"horizSevLowerDepth":null,"swr37lException":"N","swr37bException":"N","swr37iException":"N","swr37hException":"N","swr38Exception":"N","swr38dException":"N","swr39Exception":"N"},{"primaryField":"N","fieldNumber":"60177600","fieldName":"MEDICINE DOG (7250 CONGLOMERATE)","districtCode":"09","horizSevUpperDepth":null,"horizSevLowerDepth":null,"swr37lException":"N","swr37bException":"N","swr37iException":"N","swr37hException":"N","swr38Exception":"N","swr38dException":"N","swr39Exception":"N"}]}]}';
		return json;
	}

    private static String testLeaseJSON() {
		String json = '{"leases": [{"leaseNumber": "04137","districtCode": "01","leaseName": "EAST ELROY UNIT","fieldNumber": "28722001","fieldName": "ELROY, EAST","operatorNumber": "247628"}]}';
        return json;
	}

    private static String testWellJSON() {
        String json = '{'+
		'    \"wells\": ['+
		'        {'+
		'            \"wellNumber\": \"M  2  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300326\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"M  3  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300327\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"M  5  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300329\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"M  6  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300330\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"M  9  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300332\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"M 10  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300333\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"M 11  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300334\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"B  1  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300417\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"B  2  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300418\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"A  1  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300421\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"A  2  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300422\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"A  3  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300423\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"A  4  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300424\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"J  3  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45300510\",'+
		'            \"county\": \"TRAVIS\"'+
		'        },'+
		'        {'+
		'            \"wellNumber\": \"A  7  \",'+
		'            \"leaseNumber\": \"04137\",'+
		'            \"districtCode\": \"01\",'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"apiNumber\": \"45320000\",'+
		'            \"county\": \"TRAVIS\"'+
		'        }'+
		'    ]'+
		'}';
        return json;
     }
    private static String testOperatorsJSON() {
		String json = '{'+
		'    \"operators\": ['+
		'        {'+
		'            \"operatorNumber\": \"247628\",'+
		'            \"operatorName\": \"ELECTRAGAS, INC.\",'+
		'            \"operatorStatus\": \"Active\",'+
		'            \"operatorType\": \"CORPORATION\",'+
		'            \"locationAddress\": \"9211 WEST RD STE 143 151\",'+
		'            \"locationCity\": \"HOUSTON\",'+
		'            \"locationState\": \"TX\",'+
		'            \"locationZip\": \"77064\",'+
		'            \"billingAddress\": \"9211 WEST RD STE 143 151\",'+
		'            \"billingCity\": \"HOUSTON\",'+
		'            \"billingState\": \"TX\",'+
		'            \"billingZip\": \"77064\",'+
		'            \"operatorPhone\": \"(832) 435-4471\",'+
		'            \"tnr91_114\": \"No\"'+
		'        }'+
            +']'+
		
		'}';
        return json;
     }
}