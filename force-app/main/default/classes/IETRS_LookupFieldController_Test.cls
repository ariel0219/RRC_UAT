/**
 * @File Name          : IETRS_LookupFieldController_Test.cls
 * @Description        : 
 * @Author             : Mark Frizzell
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 6/11/2020, 3:16:06 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    7/10/2019, 1:21:54 AM   Mark Frizzell     Initial Version
 * 2.0    9/19/2019               Kevin Lu          Updated loadDistrict test to include the proper business area
 * 3.0    10/29/2019              Kevin Lu          Added drilling permit tests
 * 4.0    06/20/2020              Forrest Chang     Added UIC tests
**/
@IsTest
private class IETRS_LookupFieldController_Test {
    
    private static String caseSearch = '';
    private static List<Case> searchExclude;

    private static String jsonOperator = '{"operators":[{"operatorNumber":"247628","operatorName":"ELECTRAGAS, INC.","operatorStatus":"Active","operatorType":"CORPORATION","locationAddress":"9211 WEST RD STE 143 151","locationCity":"HOUSTON","locationState":"TX","locationZip":"77064","billingAddress":"9211 WEST RD STE 143 151","billingCity":"HOUSTON","billingState":"TX","billingZip":"77064","operatorPhone":"(832) 435-4471","tnr91_114":"No","p5_renewal_month":"March","initial_p5_file_date":"03-23-2004","last_P5_file_date":"02-14-2020"}]}';
    private static String jsonOfficers = '{"officers":[{"operatorNumber":"247628","officerName":"SPARKS,WILLIAMLEE","officerTitle":"PRESIDENT","locationAddress":"135CASTLEGATELANE","locationCity":"HOUSTON","locationState":"TX","locationZip":"77065-2053","billingAddress":"9211WESTRDSTE143151","billingCity":"HOUSTON","billingState":"TX","billingZip":"77064"},{"operatorNumber":"247628","officerName":"SPARKS,LAURENMARY","officerTitle":"SECRETARY","locationAddress":"135CASTLEGATELANE","locationCity":"HOUSTON","locationState":"TX","locationZip":"77065-2053","billingAddress":"9211WESTRDSTE143151","billingCity":"HOUSTON","billingState":"TX","billingZip":"77064"}]}';
    private static String jsonLease = '{"leases":[{"leaseNumber":"04137","districtCode":"01","leaseName":"EASTELROYUNIT","fieldNumber":"28722001","fieldName":"ELROY,EAST","operatorNumber":"247628"}]}';
    private static String jsonWell = '{"wells":[{"wellNumber":"M2","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300326","county":"TRAVIS"},{"wellNumber":"M3","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300327","county":"TRAVIS"},{"wellNumber":"M5","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300329","county":"TRAVIS"},{"wellNumber":"M6","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300330","county":"TRAVIS"},{"wellNumber":"M9","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300332","county":"TRAVIS"},{"wellNumber":"M10","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300333","county":"TRAVIS"},{"wellNumber":"M11","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300334","county":"TRAVIS"},{"wellNumber":"B1","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300417","county":"TRAVIS"},{"wellNumber":"B2","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300418","county":"TRAVIS"},{"wellNumber":"A1","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300421","county":"TRAVIS"},{"wellNumber":"A2","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300422","county":"TRAVIS"},{"wellNumber":"A3","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300423","county":"TRAVIS"},{"wellNumber":"A4","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300424","county":"TRAVIS"},{"wellNumber":"J3","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45300510","county":"TRAVIS"},{"wellNumber":"A7","leaseNumber":"04137","districtCode":"01","operatorNumber":"247628","apiNumber":"45320000","county":"TRAVIS"}]}';
    private static String jsonDrillingPermit = '{"drillingPermits":[{"drillingPermitNumber":"679291","drillingPermitSequence":"99","operatorNumber":"177997","districtCode":"09","countyName":"HARDEMAN","leaseName":"JACKSON-O\'NEAL UNIT","wellNumber":"   1  ","totalDepth":"9300","wellApiNumber":"19731641","submittedDate":"03-09-2009","approvedDate":"03-18-2009","permitStatus":"Approved","caseDocketNumber":null,"surfaceLocationType":"Land","datum":null,"latitudeDegree":null,"latitudeMinute":null,"latitudeSecond":null,"longitudeDegree":null,"longitudeMinute":null,"longitudeSecond":null,"statePlaneX":null,"statePlaneY":null,"statePlaneZone":null,"survey":"W&NW RR CO/CORBIN, L","section":"128","block":"H","abstractNumber":"1509","wellboreProfiles":"Vertical","mainframeCaseNumber":null,"permittedFields":[{"primaryField":"Y","fieldNumber":"73613500","fieldName":"QUANAH, SOUTH (CHAPPEL)","districtCode":"09","horizSevUpperDepth":null,"horizSevLowerDepth":null,"swr37lException":"N","swr37bException":"N","swr37iException":"N","swr37hException":"N","swr38Exception":"N","swr38dException":"N","swr39Exception":"N","pooledUnitizedFlag":"TRUE","completionDepth":"9300"},{"primaryField":"N","fieldNumber":"00022001","fieldName":"WILDCAT","districtCode":"09","horizSevUpperDepth":null,"horizSevLowerDepth":null,"swr37lException":"N","swr37bException":"N","swr37iException":"N","swr37hException":"N","swr38Exception":"N","swr38dException":"N","swr39Exception":"N","pooledUnitizedFlag":"TRUE","completionDepth":"9300"},{"primaryField":"N","fieldNumber":"60177600","fieldName":"MEDICINE DOG (7250 CONGLOMERATE)","districtCode":"09","horizSevUpperDepth":null,"horizSevLowerDepth":null,"swr37lException":"N","swr37bException":"N","swr37iException":"N","swr37hException":"N","swr38Exception":"N","swr38dException":"N","swr39Exception":"N","pooledUnitizedFlag":"TRUE","completionDepth":"9300"}]}]}';
    private static STring jsonUIC = '{"uicinfo":[{"uicNumber":"000122596","uicPermitNumber":null,"uicProjectNumber":"08436","wellNumber":"1601","leaseNumber":"03850","districtCode":"10","operatorNumber":"161639","apiNumber":"37500000","county":"POTTER","fieldNumber":"68825800","fieldName":"PANHANDLE (RED CAVE)"},{"uicNumber":"000122618","uicPermitNumber":null,"uicProjectNumber":"08436","wellNumber":"2105","leaseNumber":"03850","districtCode":"10","operatorNumber":"161639","apiNumber":"37500000","county":"POTTER","fieldNumber":"68825800","fieldName":"PANHANDLE (RED CAVE)"},{"uicNumber":"000122621","uicPermitNumber":null,"uicProjectNumber":"08436","wellNumber":"2108","leaseNumber":"03850","districtCode":"10","operatorNumber":"161639","apiNumber":"37500000","county":"POTTER","fieldNumber":"68825800","fieldName":"PANHANDLE (RED CAVE)"},{"uicNumber":"000112652","uicPermitNumber":"15047","uicProjectNumber":null,"wellNumber":"1","leaseNumber":"000000","districtCode":"10","operatorNumber":null,"apiNumber":"37500000","county":"POTTER","fieldNumber":null,"fieldName":null},{"uicNumber":"000112653","uicPermitNumber":"15048","uicProjectNumber":null,"wellNumber":"1","leaseNumber":"000000","districtCode":"10","operatorNumber":null,"apiNumber":"37500000","county":"POTTER","fieldNumber":null,"fieldName":null},{"uicNumber":"000112654","uicPermitNumber":"15049","uicProjectNumber":null,"wellNumber":"1","leaseNumber":"000000","districtCode":"10","operatorNumber":null,"apiNumber":"37500000","county":"POTTER","fieldNumber":null,"fieldName":null}]}';


    static void sfSearchSetup() {
        List<SObject> data = new List<SObject>();
        data.add(new Case());
        data.add(new Case());
        data.add(new Account(
            Name = 'Test Account'
        ));
        insert data;
        caseSearch = [SELECT CaseNumber FROM Case LIMIT 1].CaseNumber;
        searchExclude = [SELECT CaseNumber FROM Case WHERE CaseNumber != :caseSearch LIMIT 1];
        System.debug('caseSearch: ' + caseSearch);
        System.debug('searchExclude: ' + searchExclude);
    }


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
    static void testLoadRecordDetails_Positive() {
        Case testCase = new Case();
        insert testCase;

        Test.startTest();
            List<SObject> results = IETRS_LookupFieldController.loadRecordDetails(testCase.Id);
        Test.stopTest();
        System.assert(results.size() > 0);
    }


    @IsTest
    static void testLoadRecordDetails_Negative() {
        Test.startTest();
            IETRS_LookupFieldController.loadRecordDetails('');
        Test.stopTest();
    }


    @IsTest
    static void testLoadDistricts() {
        IETRS_County_Group__c district = new IETRS_County_Group__c(
            Name = '01-TestDistrict',
            IETRS_Group_Type__c = 'District',
            IETRS_Business_Area__c = 'Oil and Gas'
        );
        insert district; 

        Test.startTest();
            List<IETRS_LookupFieldController.SelectOption> results = IETRS_LookupFieldController.loadDistricts();
        Test.stopTest();
        System.assert(results.size() > 0);
    }


    @IsTest
    static void testSearch_Case() {
        sfSearchSetup();
        Test.startTest();
            List<SObject> results = IETRS_LookupFieldController.searchSObject(caseSearch, 'Case', '', searchExclude);
        Test.stopTest();
        System.assert(results.size() > 0);
    }


    @IsTest
    static void testSearch_Account() {
        sfSearchSetup();
        Test.startTest();
            List<SObject> results = IETRS_LookupFieldController.searchSObject('test', 'Account', '', null);
        Test.stopTest();
        System.assert(results.size() > 0);
    }


    @IsTest
    static void testSearch_NoResults() {
        Test.startTest();
            List<SObject> results = IETRS_LookupFieldController.searchSObject('1234', 'Case', '', null);
        Test.stopTest();
        System.assert(results.size() == 0);
    }


    @IsTest
    static void testSearchOperators() {
        webSvcsSetup();
        Test.startTest();
            IETRS_Web_Services wb = new IETRS_Web_Services();
            Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator_IETRS(jsonOperator));
            String result1 = IETRS_LookupFieldController.searchOperators('247628');
            String result2 = IETRS_LookupFieldController.searchOperators('ELECTRAGAS');
        Test.stopTest();
        System.assert(result1 != null);
        System.assert(result2 != null);
    }


    @IsTest
    static void testSearchOfficers() {
        webSvcsSetup();
        Test.startTest();
            IETRS_Web_Services wb = new IETRS_Web_Services();
            Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator_IETRS(jsonOfficers));
            String result = IETRS_LookupFieldController.searchOfficers('247628');
        Test.stopTest();
        System.assert(result != null);
    }


    @IsTest
    static void testSearchLeases() {
        webSvcsSetup();
        Test.startTest();
            IETRS_Web_Services wb = new IETRS_Web_Services();
            Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator_IETRS(jsonLease));
            String result = IETRS_LookupFieldController.searchLeases('04137', '01');
        Test.stopTest();
        System.assert(result != null);
    }


    @IsTest
    static void testSearchWells() {
        webSvcsSetup();
        Test.startTest();
            IETRS_Web_Services wb = new IETRS_Web_Services();
            Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator_IETRS(jsonWell));
            String result = IETRS_LookupFieldController.searchWells('04137', '01');
        Test.stopTest();
        System.assert(result != null);
    }

    @IsTest
    static void testSearchDrillingPermits() {
        webSvcsSetup();

        Test.startTest();
        IETRS_Web_Services wb = new IETRS_Web_Services();
        Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator_IETRS(jsonDrillingPermit));
        String result = IETRS_LookupFieldController.searchDrillingPermits('679291');
        Test.stopTest();

        System.assert(result != null);
    }

    @IsTest
    static void testSearchUIC() {
        webSvcsSetup();

        Test.startTest();
        IETRS_Web_Services wb = new IETRS_Web_Services();
        Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator_IETRS(jsonUIC));
        String result = IETRS_LookupFieldController.searchUIC('37500000');
        Test.stopTest();

        System.assert(result != null);
    }


    @IsTest
    static void testAddOperators() {
        webSvcsSetup();
        Test.startTest();
            IETRS_Web_Services wb = new IETRS_Web_Services();
            Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator_IETRS(jsonOfficers));
            List<Account> results = IETRS_LookupFieldController.addOperators(jsonOperator);
        Test.stopTest();
        System.assert(results.size() > 0);
    }


    @IsTest
    static void testAddOfficers() {
        Test.startTest();
            List<Contact> results = IETRS_LookupFieldController.addOfficers(jsonOfficers);
        Test.stopTest();
        System.assert(results.size() > 0);
    }


    @IsTest
    static void testAddLeases() {
        webSvcsSetup();
        Test.startTest();
            IETRS_Web_Services wb = new IETRS_Web_Services();
            Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator_IETRS(jsonWell));
            List<Account> results = IETRS_LookupFieldController.addLeases(jsonLease);
        Test.stopTest();
        System.assert(results.size() > 0);
    }


    @IsTest
    static void testAddWells() {
        Test.startTest();
            List<Account> results = IETRS_LookupFieldController.addWells(jsonWell);
        Test.stopTest();
        System.assert(results.size() > 0);
    }

    @IsTest
    static void testAddDrillingPermits() {
        Test.startTest();
        String result = IETRS_LookupFieldController.addDrillingPermits(jsonDrillingPermit);
        Test.stopTest();
        System.assertEquals('Success', result, 'Unable to add drilling permits');
    }

    @IsTest
    static void testAddUIC() {
        Test.startTest();
        List<Account> results = IETRS_LookupFieldController.addUIC(jsonUIC);
        Test.stopTest();
        System.assert(results.size() > 0);
    }
}