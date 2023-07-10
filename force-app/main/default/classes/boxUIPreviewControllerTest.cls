/**
 * @File Name          : boxUIPreviewControllerTest.cls
 * @Description        : Test class for the Box UI Preview controller
 * @Author             : Kevin Lu
 * @Group              :
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 7/11/2019, 9:18:09 AM
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    7/11/2019, 9:18:00 AM   Kevin Lu     Initial Version
 **/
@isTest
private class boxUIPreviewControllerTest {
    //private static final String SYS_ADMIN_ID = [Select Id From Profile Where Name = 'System Administrator' Limit 1].get(0).Id;

    @TestSetup
    static void setup() {
        /*Box_API_Keys__c keys = new Box_API_Keys__c();
        keys.AccessToken__c = 'V2MYvn96tBFDXi/uTeG092FkCXD6vMBMpHCFP1K/m6jPCyJEBJ8LRH+fGH44aQZtLa4wuloLJelk/+LERN3+ow==';
        keys.RefreshToken__c = 'HX0RXi5m1BoMp74y36JMhZPDzWhkMn+YGm3q7QREAjj31QuiV9sBHLFUhzf+rdloTRu5UlQv96eFD6GsR6mhGXyY/e9gfN/6YVC7W91Ld++z8aCCk5X889wi0bWwnYKh';
        keys.ClientId__c = '1C7ridNrA/L1l2hZr7YgGmpT8A33DrslW1fFZQZKBx0dPJpeaBAmKRlY5EkPTCiakWTfeg37M3T+JxzLAbhcbw==';
        keys.ClientSecret__c = 'evOkjcheGiDjC4fUPxtZ/HYQAJ05xJH4VURmw4+8pC2vDbQIL8oKfzD03OVSEk4502tMSi4lIYf62Oafz+apqQ==';
        keys.EncryptionKey__c = 'nQ9QnvSIbdf0/hgprrif3rTsWFEf3Gyw72T36Iw3/Bw=';
        keys.AccessTokenExpirationDateTime__c = DateTime.newInstance(2019, 5, 13, 16, 22, 0);
        keys.SetupOwnerId = SYS_ADMIN_ID;
        insert keys;*/
    }

    @isTest
    static void testPage() {
        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));

        IETRS_Files_Correspondence__c fileCorrespondence = new IETRS_Files_Correspondence__c();
        /**        fileCorrespondence.IETRS_Case_Box_File_ID__c = '462262211131';**/
        insert fileCorrespondence;

        Test.startTest();
        boxUIPreviewController pageTest = new boxUIPreviewController(
            new ApexPages.StandardController(fileCorrespondence)
        );
        pageTest.initalizeToken();
        Test.stopTest();

        // System.assertEquals('T9cE5asGnuyYCCqIZFoWjFHvNbvVqHjl', pageTest.getDownscopeToken(), 'Access token does not match');
        // System.assertEquals('462262211131', pageTest.getBoxFileId(), 'Box File Id does not match');
    }
}