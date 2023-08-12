/**
* @author Ariel Zhang - CGI
* @date 7/31/2023
*
* @description: Tests for File to Attachment Conversion features
*/

@isTest
public class ConvertFileToAttachmentTest {
  @TestSetup
  static void createFiles(){
  ConvertFileToAttachment.DocClass doc1 = new ConvertFileToAttachment.DocClass();
  ConvertFileToAttachment.DocClass doc2 = new ConvertFileToAttachment.DocClass();

  doc1.FilesCorrespondenceID = '0012b00000CorrespA';
  doc1.OriginalFileName ='doc1_originalName_TEST';
  doc2.FilesCorrespondenceID = '0012b00000CorrespB';
  doc2.OriginalFileName ='doc2_originalName_TEST';

  ContentDocumentLink cdl_1 = new ContentDocumentLink();
  ContentDocumentLink cdl_2 = new ContentDocumentLink();
  cdl_1.LinkedEntityId = doc1.FilesCorrespondenceID;
  cdl_2.LinkedEntityId  = doc2.FilesCorrespondenceID;

  cdl_1.ContentDocumentId = '0692b00000OoCDA';
  cdl_2.ContentDocumentId = '0692b00000OoCDB';

  ContentVersion cv_1 = new ContentVersion();
  ContentVersion cv_2 = new ContentVersion();
  cv_1.ContentDocumentId = '0692b00000OoCDA';
  cv_2.ContentDocumentId = '0692b00000OoCDB';
  cv_1.VersionData = Blob.valueof('versionData_1');
  cv_2.VersionData = Blob.valueof('versionData_2');
/*
  insert cdl_1;
  insert cdl_2;
  insert cv_1;
  insert cv_2;
  */

  }

  @isTest
  public static void convertFiles_TEST() {
    
  ConvertFileToAttachment.DocClass doc1 = new ConvertFileToAttachment.DocClass();
  ConvertFileToAttachment.DocClass doc2 = new ConvertFileToAttachment.DocClass();

  doc1.FilesCorrespondenceID = '0012b00000CorrespA';
  doc1.OriginalFileName ='doc1_originalName_TEST';
  doc2.FilesCorrespondenceID = '0012b00000CorrespB';
  doc2.OriginalFileName ='doc2_originalName_TEST';
  List<ConvertFileToAttachment.DocClass> docList = new List<ConvertFileToAttachment.DocClass>();

  Test.startTest();
  //ConvertFileToAttachment obj = new ConvertFileToAttachment();
  List<string> result = ConvertFileToAttachment.convertFiles(docList);
  List<string> compare = new List<String>{
    'Error: No record found'
  };
  System.assertEquals(compare, result, 'error: return value not match!');
  Test.stopTest();
  }
}