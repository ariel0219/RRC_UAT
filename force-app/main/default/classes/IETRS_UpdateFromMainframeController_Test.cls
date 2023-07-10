/**
 * @File Name          : IETRS_UpdateFromMainframeController_Test.cls
 * @Description        : 
 * @Author             : Mark Frizzell
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 12/17/2019, 11:42:54 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    7/20/2019, 12:08:41 PM   Mark Frizzell     Initial Version
 * 2.0    10/29/2019               Kevin Lu          Added drilling permit tests
 * 3.0    12/17/2019               Kevin Lu          Updated drilling permit test to include Operator record
**/
@IsTest
private class IETRS_UpdateFromMainframeController_Test {
    
    private static String jsonOperator = '{"operators":[{"operatorNumber":"247628","operatorName":"ELECTRAGAS,INC.","operatorStatus":"Active","operatorType":"CORPORATION","locationAddress":"9211WESTRDSTE143151","locationCity":"HOUSTON","locationState":"TX","locationZip":"77064","billingAddress":"9211WESTRDSTE143151","billingCity":"HOUSTON","billingState":"TX","billingZip":"77064","operatorPhone":"(832)435-4471","tnr91_114":"No"}]}';
    private static String jsonOfficers = '{"officers":[{"operatorNumber":"247628","officerName":"SPARKS,WILLIAMLEE","officerTitle":"PRESIDENT","locationAddress":"135CASTLEGATELANE","locationCity":"HOUSTON","locationState":"TX","locationZip":"77065-2053","billingAddress":"9211WESTRDSTE143151","billingCity":"HOUSTON","billingState":"TX","billingZip":"77064"},{"operatorNumber":"247628","officerName":"SPARKS,LAURENMARY","officerTitle":"SECRETARY","locationAddress":"135CASTLEGATELANE","locationCity":"HOUSTON","locationState":"TX","locationZip":"77065-2053","billingAddress":"9211WESTRDSTE143151","billingCity":"HOUSTON","billingState":"TX","billingZip":"77064"}]}';
    private static String jsonLease = '{"leases":[{"leaseNumber":"04137","districtCode":"01","leaseName":"EASTELROYUNIT","fieldNumber":"28722001","fieldName":"ELROY,EAST","operatorNumber":"247628"}]}';
    private static String jsonWell = '{"wells":[{"wellNumber":"M2","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300326","county":"TRAVIS"},{"wellNumber":"M3","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300327","county":"TRAVIS"},{"wellNumber":"M5","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300329","county":"TRAVIS"},{"wellNumber":"M6","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300330","county":"TRAVIS"},{"wellNumber":"M9","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300332","county":"TRAVIS"},{"wellNumber":"M10","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300333","county":"TRAVIS"},{"wellNumber":"M11","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300334","county":"TRAVIS"},{"wellNumber":"B1","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300417","county":"TRAVIS"},{"wellNumber":"B2","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300418","county":"TRAVIS"},{"wellNumber":"A1","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300421","county":"TRAVIS"},{"wellNumber":"A2","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300422","county":"TRAVIS"},{"wellNumber":"A3","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300423","county":"TRAVIS"},{"wellNumber":"A4","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300424","county":"TRAVIS"},{"wellNumber":"J3","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300510","county":"TRAVIS"},{"wellNumber":"A7","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45320000","county":"TRAVIS"}]}';
    private static String jsonDrillingPermit = '{"drillingPermits":[{"drillingPermitNumber":"679291","drillingPermitSequence":"99","operatorNumber":"177997","districtCode":"09","countyName":"HARDEMAN","leaseName":"JACKSON-O\'NEAL UNIT","wellNumber":"   1  ","totalDepth":"9300","wellApiNumber":"19731641","submittedDate":"03-09-2009","approvedDate":"03-18-2009","permitStatus":"Approved","caseDocketNumber":null,"permittedFields":[{"primaryField":"Y","fieldNumber":"73613500","fieldName":"QUANAH, SOUTH (CHAPPEL)","districtCode":"09","horizSevUpperDepth":null,"horizSevLowerDepth":null,"swr37lException":"N","swr37bException":"N","swr37iException":"N","swr37hException":"N","swr38Exception":"N","swr38dException":"N","swr39Exception":"N"},{"primaryField":"N","fieldNumber":"00022001","fieldName":"WILDCAT","districtCode":"09","horizSevUpperDepth":null,"horizSevLowerDepth":null,"swr37lException":"N","swr37bException":"N","swr37iException":"N","swr37hException":"N","swr38Exception":"N","swr38dException":"N","swr39Exception":"N"},{"primaryField":"N","fieldNumber":"60177600","fieldName":"MEDICINE DOG (7250 CONGLOMERATE)","districtCode":"09","horizSevUpperDepth":null,"horizSevLowerDepth":null,"swr37lException":"N","swr37bException":"N","swr37iException":"N","swr37hException":"N","swr38Exception":"N","swr38dException":"N","swr39Exception":"N"}]}]}';
    private static STring jsonUIC = '{"uicinfo":[{"uicNumber":"000122596","uicPermitNumber":null,"uicProjectNumber":"08436","wellNumber":"1601","leaseNumber":"03850","districtCode":"10","operatorNumber":"161639","apiNumber":"37500000","county":"POTTER","fieldNumber":"68825800","fieldName":"PANHANDLE (RED CAVE)"},{"uicNumber":"000122618","uicPermitNumber":null,"uicProjectNumber":"08436","wellNumber":"2105","leaseNumber":"03850","districtCode":"10","operatorNumber":"161639","apiNumber":"37500000","county":"POTTER","fieldNumber":"68825800","fieldName":"PANHANDLE (RED CAVE)"},{"uicNumber":"000122621","uicPermitNumber":null,"uicProjectNumber":"08436","wellNumber":"2108","leaseNumber":"03850","districtCode":"10","operatorNumber":"161639","apiNumber":"37500000","county":"POTTER","fieldNumber":"68825800","fieldName":"PANHANDLE (RED CAVE)"},{"uicNumber":"000112652","uicPermitNumber":"15047","uicProjectNumber":null,"wellNumber":"1","leaseNumber":"000000","districtCode":"10","operatorNumber":null,"apiNumber":"37500000","county":"POTTER","fieldNumber":null,"fieldName":null},{"uicNumber":"000112653","uicPermitNumber":"15048","uicProjectNumber":null,"wellNumber":"1","leaseNumber":"000000","districtCode":"10","operatorNumber":null,"apiNumber":"37500000","county":"POTTER","fieldNumber":null,"fieldName":null},{"uicNumber":"000112654","uicPermitNumber":"15049","uicProjectNumber":null,"wellNumber":"1","leaseNumber":"000000","districtCode":"10","operatorNumber":null,"apiNumber":"37500000","county":"POTTER","fieldNumber":null,"fieldName":null}]}';

    static void webSvcsSetup() {
        IETRS_WebService__c webServiceSetting = new IETRS_WebService__c();
        webServiceSetting.authEndPoint__c = 'https://test.rrc.texas.gov/integration/oauth/token';
        webServiceSetting.Client_Id__c = 'sensecorp';
        webServiceSetting.Client_Secret__c = 'ietrs4RRC';
        webServiceSetting.Rest_EndPoint__c = 'https://test.rrc.texas.gov/integration/oauth/rest/';
        insert webServiceSetting;
        Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator_IETRS('{"access_token":"fake_token"}'));
    }
    

    @IsTest
    static void testLoadRecord_Positive() {
        Account testAcct = new Account(
            Name = 'Test Account'
        );
        insert testAcct;

        Test.startTest();
            SObject result = IETRS_UpdateFromMainframeController.loadRecord(testAcct.Id, 'Account');
        Test.stopTest();
        System.assert(result.Id == testAcct.Id);
    }

    
    @IsTest
    static void testLoadRecord_Negative() {
        Test.startTest();
            SObject result = IETRS_UpdateFromMainframeController.loadRecord(null, 'Account');
        Test.stopTest();
        System.assert(result.Id == null);
    }


    @IsTest
    static void testLoadOperatorData() {
        webSvcsSetup();
        Test.startTest();
            IETRS_Web_Services wb = new IETRS_Web_Services();
            Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator_IETRS(jsonOperator));
            String result = IETRS_UpdateFromMainframeController.loadOperatorData('247628');
        Test.stopTest();
        System.assert(result != null);
    }


    @IsTest
    static void testLoadLeaseData() {
        webSvcsSetup();
        Test.startTest();
            IETRS_Web_Services wb = new IETRS_Web_Services();
            Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator_IETRS(jsonLease));
            String result = IETRS_UpdateFromMainframeController.loadLeaseData('04137', '01');
        Test.stopTest();
        System.assert(result != null);
    }

    @IsTest
    static void testLoadDrillingPermitData() {
        webSvcsSetup();

        Account a = new Account();
        a.Name = 'Test Account';
        a.IETRS_P5_Number__c = '177997';
        insert a;

        Test.startTest();
        IETRS_Web_Services wb = new IETRS_Web_Services();
        Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator_IETRS(jsonDrillingPermit));
        String result = IETRS_UpdateFromMainframeController.loadDrillingPermitData('679291');
        Test.stopTest();

        System.assert(result != null);
    }
    

    @IsTest
    static void testLoadUICPermitData() {
        webSvcsSetup();

        Account a = new Account();
        a.Name = 'Test Account';
        a.IETRS_P5_Number__c = '161639';
        insert a;

        Test.startTest();
        IETRS_Web_Services wb = new IETRS_Web_Services();
        Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator_IETRS(jsonUIC));
        String result = IETRS_UpdateFromMainframeController.loadUICPermitData('37500000', '000122596');
        Test.stopTest();

        System.assert(result != null);
    }


    @IsTest
    static void testUpdateOperator() {
        Account testAcct = new Account(
            Name = 'Test Account'
        );
        insert testAcct;
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'UpdateFromMF',
            Email = 'TestUpdateFromMF@test.test',
            AccountId = testAcct.Id
        );
        insert testContact;
        String mfJSON = '{"operator":{"tnr91_114":"No","operatorType":"LIMITED LIAB COMPANY","operatorStatus":"Active","operatorPhone":"(512) 560-0208","operatorNumber":"953818","operatorName":"3DG ENERGY, LLC","locationZip":"78734","locationState":"TX","locationCity":"AUSTIN","locationAddress":"302 BUNNY HOP TRAIL","billingZip":"78734","billingState":"TX","billingCity":"AUSTIN","billingAddress":"302 BUNNY HOP TRAIL"},"officers":[{"operatorNumber":"953818","officerTitle":"MEMBER","officerName":"FOWLER, AMY GENEVA","locationZip":"78734","locationState":"TX","locationCity":"AUSTIN","locationAddress":"302 BUNNY HOP TRAIL","billingZip":"78734","billingState":"TX","billingCity":"AUSTIN","billingAddress":"302 BUNNY HOP TRAIL"},{"operatorNumber":"953818","officerTitle":"MEMBER","officerName":"JENKNS, DENNIS DEE","locationZip":"78657","locationState":"TX","locationCity":"HORSESHOE BAY","locationAddress":"105 ALAMO CT","billingZip":"78734","billingState":"TX","billingCity":"AUSTIN","billingAddress":"302 BUNNY HOP TRAIL"},{"operatorNumber":"953818","officerTitle":"MEMBER","officerName":"JENKINS, JASON DANE","locationZip":"78732","locationState":"TX","locationCity":"AUSTIN","locationAddress":"4800 STEINER RANCH BLVD; #5-303","billingZip":"78734","billingState":"TX","billingCity":"AUSTIN","billingAddress":"302 BUNNY HOP TRAIL"}]}';

        Test.startTest();
            String result = IETRS_UpdateFromMainframeController.updateOperator(testAcct, mfJSON);
        Test.stopTest();
        System.assert(result != null);
    }

    @IsTest
    static void testUpdateDrillingPermit(){
        Account testAcct = new Account(
            Name = 'Test Account'
        );
        insert testAcct;

        Test.startTest();
        String result = IETRS_UpdateFromMainframeController.updateDrillingPermit(testAcct, jsonDrillingPermit);
        Test.stopTest();

        System.assertEquals('Success', result, 'Unable to update drilling permit');
    }

    @IsTest
    static void testUpdateUICPermit(){
        Account testAcct = new Account(
            Name = 'Test Account'
        );
        insert testAcct;

        Test.startTest();
        String result = IETRS_UpdateFromMainframeController.updateUICPermit(testAcct, jsonUIC);
        Test.stopTest();

        System.assertEquals('Success', result, 'Unable to update drilling permit');
    }

    @IsTest
    static void testUpdateLease() {
        Account testLease = new Account(
            Name = 'Test Lease'
        );
        insert testLease;
        List<Account> testWells = new List<Account>();
        for(Integer i = 1; i < 4; i++) {
            testWells.add(new Account(
                Name = 'Test Well ' + i,
                ParentId = testLease.Id
            ));
        }
        insert testWells;
        String mfJSON = '{"lease":{"operatorNumber":"247628","leaseNumber":"04137","leaseName":"EAST ELROY UNIT","fieldNumber":"28722001","fieldName":"ELROY, EAST","districtCode":"01"},"wells":[{"wellNumber":"M  2  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300326"},{"wellNumber":"M  3  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300327"},{"wellNumber":"M  5  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300329"},{"wellNumber":"M  6  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300330"},{"wellNumber":"M  9  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300332"},{"wellNumber":"M 10  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300333"},{"wellNumber":"M 11  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300334"},{"wellNumber":"B  1  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300417"},{"wellNumber":"B  2  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300418"},{"wellNumber":"A  1  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300421"},{"wellNumber":"A  2  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300422"},{"wellNumber":"A  3  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300423"},{"wellNumber":"A  4  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300424"},{"wellNumber":"J  3  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45300510"},{"wellNumber":"A  7  ","operatorNumber":"247628","leaseNumber":"04137","districtCode":"01","county":"TRAVIS","apiNumber":"45320000"}]}';

        Test.startTest();
            String result = IETRS_UpdateFromMainframeController.updateLease(testLease, mfJSON);
        Test.stopTest();
        System.assert(result != null);
    }
}