/*
  @Page Name          : boxUIPreviewPublicPortalDoc.apxc
  @Description        : 
  @Author             : Kevin Lu/Connor Rivera
  @Group              : 
  @Last Modified By   : Kevin Lu/Connor Rivera
  @Last Modified On   : 5/30/2023, 6:00:00 AM
  @Modification Log   : 
  ==============================================================================
  Ver         Date                     Author                 Modification
  ==============================================================================
  1.0    5/30/2025, 6:00:00 AM   Connor     Initial Version
*/
public with sharing class boxUIPreviewControllerPublicPortalDoc {
    private CIIS_Public_Portal_Document__c fileCorrespondence;
    private String downscopeToken;
    //private static final String SYS_ADMIN_ID = [Select Id From Profile Where Name = 'System Administrator' Limit 1].get(0).Id;
    
    public boxUIPreviewControllerPublicPortalDoc(ApexPages.StandardController stdController){
        this.fileCorrespondence = (CIIS_Public_Portal_Document__c)stdController.getRecord();
        if(Test.isRunningTest()){
            this.fileCorrespondence = [SELECT Id, CIIS_Box_File_ID__c FROM CIIS_Public_Portal_Document__c WHERE Id = :this.fileCorrespondence.Id];
        }
    }
    
    public void initalizeToken(){
       IETRSBox box = new IETRSBox();
        if(fileCorrespondence.CIIS_Box_File_ID__c != null && fileCorrespondence.CIIS_Box_File_ID__c != '') {
            this.downscopeToken = box.getDownscopeToken(fileCorrespondence.CIIS_Box_File_ID__c);
        }
        //box.updateBoxCustomSetting();
    }
    
    public String getDownscopeToken(){
        return this.downscopeToken;
    }
    
    public String getBoxFileId(){
        return fileCorrespondence.CIIS_Box_File_ID__c;
    }
}