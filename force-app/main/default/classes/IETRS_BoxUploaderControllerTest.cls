/**
 * @File Name          : IETRS_BoxUploaderControllerTest.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 2020-08-21
 * @Modification Log   : 
 * Ver      Date            Author          Modification
 * 1.0      03/16/2020      Kevin Lu        Initial Version
**/
@IsTest
public class IETRS_BoxUploaderControllerTest {
    @TestSetup
    public static void makeData() {
        String recTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('AFS').getRecordTypeId();
        Case c = new Case(IETRS_Business_Area__c = 'Alternative Fuels', Type = 'AFS', RecordTypeId = recTypeId);
        insert c;
        AFS_Exemption__c exemp = new AFS_Exemption__c();
        exemp.AFS_First_Name__c = 'Gwen';
        exemp.AFS_Middle_Name__c = 'Elizabeth';
        exemp.AFS_Last_Name__c = 'Stacy';
        exemp.AFS_Social_Security_Number__c = '867530999';
        insert exemp;
        List<IETRS_Files_Correspondence__c> testFCs = new List<IETRS_Files_Correspondence__c>();
        IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c(IETRS_Case__c = c.Id);
        IETRS_Files_Correspondence__c fc1 = new IETRS_Files_Correspondence__c(AFS_Exemption__c = exemp.Id, IETRS_Box_File_Folder__c = 'test');
        IETRS_Files_Correspondence__c fc2 = new IETRS_Files_Correspondence__c(AFS_Exemption__c = exemp.Id);
        testFCs.add(fc);
        testFCs.add(fc1);
        testFCs.add(fc2);
        insert testFCs;
    }

    @IsTest
    public static void testDownscopeToken() {
        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        String mockResponseBody = '{"access_token":"1!Y4yMspDGwzp6Wk_mCT4YaTrVO4k7Av6E408th7WDlP8HBl6iru2bLPgCNelTBHri8-H8A6Z4lbAcvfQgw2jdWAaYur0oYAEkr5zeFCfNkPezzFDh8ZheMFVb3RcP6Vb65tZmIz8BO-IYMiOaiEgrW2Ims9dKHkEKX3uK3PKqEyJSe-7TQfDH5Wk_uTis1Dut55zpGtaNEZo3Hvs2amXbXtVm1T-ucWfs4GXi-h4GDVUbs2dxXAy1Y4M4i9nRr9WG7dvUG_pkUzvjoZIhYnB80Kw94-rEB_lw9LiAtkbFm2UzpQYPHR3UwNHGT2WovFiCKC5ZL3bX5i4pMG_KWZutu_5Ysz7BnL7cednFOGXzAo046fLoIBFxuw958x_sTGuUfapYncPawDVqUviY9pthQ4eJOYG1OieS8j9xuQQ_bbzhCnxdZN2f7ybGsRmKCb38Xbt_PFIIs7yrytTLJzWMSisoPafwc19aL7TO6UsLbvlR1HCIC-n4bisNojgZ72Lbgu9npVfYjkG2"}';

        List<BoxTestMockCallout.MockResponse> responses = new List<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse authResponseMock = new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200);
        responses.add(authResponseMock);
        BoxTestMockCallout.MockResponse getDownscopedTokenMock = new BoxTestMockCallout.MockResponse(mockResponseBody, 'OK', 200);
        responses.add(getDownscopedTokenMock);

        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));

        Test.startTest();
        String token = IETRS_BoxUploaderController.getDownscopedAccessToken().get(0);
        Test.stopTest();

        System.assertEquals('1!Y4yMspDGwzp6Wk_mCT4YaTrVO4k7Av6E408th7WDlP8HBl6iru2bLPgCNelTBHri8-H8A6Z4lbAcvfQgw2jdWAaYur0oYAEkr5zeFCfNkPezzFDh8ZheMFVb3RcP6Vb65tZmIz8BO-IYMiOaiEgrW2Ims9dKHkEKX3uK3PKqEyJSe-7TQfDH5Wk_uTis1Dut55zpGtaNEZo3Hvs2amXbXtVm1T-ucWfs4GXi-h4GDVUbs2dxXAy1Y4M4i9nRr9WG7dvUG_pkUzvjoZIhYnB80Kw94-rEB_lw9LiAtkbFm2UzpQYPHR3UwNHGT2WovFiCKC5ZL3bX5i4pMG_KWZutu_5Ysz7BnL7cednFOGXzAo046fLoIBFxuw958x_sTGuUfapYncPawDVqUviY9pthQ4eJOYG1OieS8j9xuQQ_bbzhCnxdZN2f7ybGsRmKCb38Xbt_PFIIs7yrytTLJzWMSisoPafwc19aL7TO6UsLbvlR1HCIC-n4bisNojgZ72Lbgu9npVfYjkG2', token, 'Downscoped Token does not match');
    }

    @IsTest
    public static void testProcessUpload() {
        IETRS_Files_Correspondence__c fc = [Select 
                                                Id, Name, IETRS_Box_File_ID__c, IETRS_Original_File_Name__c, IETRS_Box_File_Folder__c, 
                                                AFS_Exemption__c,  AFS_Exemption__r.AFS_Box_FolderID__c, AFS_Exemption__r.Name
                                            From 
                                                IETRS_Files_Correspondence__c 
                                            Where IETRS_Case__c != null   
                                            Limit 1].get(0);
        Id recordId = fc.Id;

        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;

        List<BoxTestMockCallout.MockResponse> responses = new List<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse authResponseMock = new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200);
        responses.add(authResponseMock);
        BoxTestMockCallout.MockResponse moveFileMock = new BoxTestMockCallout.MockResponse('{}', 'OK', 200);
        responses.add(moveFileMock);
        BoxTestMockCallout.MockResponse renameFileMock = new BoxTestMockCallout.MockResponse('{}', 'OK', 200);
        responses.add(renameFileMock);
        BoxTestMockCallout.MockResponse collaborationAddMock = new BoxTestMockCallout.MockResponse('{}', 'OK', 200);
        responses.add(collaborationAddMock);

        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));
        
        Test.startTest();
        IETRS_BoxUploaderController.processFileUpload('12345', recordId, 'HelloWorld.txt', '500');
        Test.stopTest();

        fc = [Select 
                Id, Name, IETRS_Box_File_ID__c, IETRS_Original_File_Name__c
            From 
                IETRS_Files_Correspondence__c
            Where
                Id = :recordId
            Limit 1].get(0);
        System.assertEquals('12345', fc.IETRS_Box_File_ID__c, 'File Id not updated');
        System.assertEquals('HelloWorld.txt', fc.IETRS_Original_File_Name__c, 'Original File Name not uploaded');
    }

    @IsTest
    public static void testProcessExemptionUpload() {
        IETRS_Files_Correspondence__c fc = [Select 
                                                Id, Name, IETRS_Box_File_ID__c, IETRS_Original_File_Name__c, IETRS_Box_File_Folder__c,
                                                AFS_Exemption__c,  AFS_Exemption__r.AFS_Box_FolderID__c, AFS_Exemption__r.Name
                                            From 
                                                IETRS_Files_Correspondence__c 
                                            Where AFS_Exemption__c != null and IETRS_Box_File_Folder__c = null
                                            Limit 1].get(0);
        Id recordId = fc.Id;

        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;

        List<BoxTestMockCallout.MockResponse> responses = new List<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse authResponseMock = new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200);
        responses.add(authResponseMock);
        BoxTestMockCallout.MockResponse moveFileMock = new BoxTestMockCallout.MockResponse('{}', 'OK', 200);
        responses.add(moveFileMock);
        BoxTestMockCallout.MockResponse renameFileMock = new BoxTestMockCallout.MockResponse('{}', 'OK', 200);
        responses.add(renameFileMock);
        BoxTestMockCallout.MockResponse collaborationAddMock = new BoxTestMockCallout.MockResponse('{}', 'OK', 200);
        responses.add(collaborationAddMock);

        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));
        
        Test.startTest();
        IETRS_BoxUploaderController.processFileUploadExemption('12345', fc, 'HelloWorld.txt', '500', recordId);
        Test.stopTest();

        fc = [Select 
                Id, Name, IETRS_Box_File_ID__c, IETRS_Original_File_Name__c
            From 
                IETRS_Files_Correspondence__c
            Where
                Id = :recordId
            Limit 1].get(0);
        System.assertEquals('12345', fc.IETRS_Box_File_ID__c, 'File Id not updated');
        System.assertEquals('HelloWorld.txt', fc.IETRS_Original_File_Name__c, 'Original File Name not uploaded');
    }
    
    @IsTest
    public static void testProcessExemptionUpload1() {
        IETRS_Files_Correspondence__c fc = [Select 
                                                Id, Name, IETRS_Box_File_ID__c, IETRS_Original_File_Name__c, IETRS_Box_File_Folder__c,
                                                AFS_Exemption__c,  AFS_Exemption__r.AFS_Box_FolderID__c, AFS_Exemption__r.Name
                                            From 
                                                IETRS_Files_Correspondence__c 
                                            Where AFS_Exemption__c != null and IETRS_Box_File_Folder__c != null   
                                            Limit 1].get(0);
        Id recordId = fc.Id;

        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;

        List<BoxTestMockCallout.MockResponse> responses = new List<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse authResponseMock = new BoxTestMockCallout.MockResponse(authResponse, 'OK', 200);
        responses.add(authResponseMock);
        BoxTestMockCallout.MockResponse moveFileMock = new BoxTestMockCallout.MockResponse('{}', 'OK', 200);
        responses.add(moveFileMock);
        BoxTestMockCallout.MockResponse renameFileMock = new BoxTestMockCallout.MockResponse('{}', 'OK', 200);
        responses.add(renameFileMock);
        BoxTestMockCallout.MockResponse collaborationAddMock = new BoxTestMockCallout.MockResponse('{}', 'OK', 200);
        responses.add(collaborationAddMock);

        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));
        
        Test.startTest();
        IETRS_BoxUploaderController.processFileUploadExemption('12345', fc, 'HelloWorld.txt', '500', recordId);
        Test.stopTest();

        fc = [Select 
                Id, Name, IETRS_Box_File_ID__c, IETRS_Original_File_Name__c
            From 
                IETRS_Files_Correspondence__c
            Where
                Id = :recordId
            Limit 1].get(0);
        System.assertEquals('12345', fc.IETRS_Box_File_ID__c, 'File Id not updated');
        System.assertEquals('HelloWorld.txt', fc.IETRS_Original_File_Name__c, 'Original File Name not uploaded');
    }
}