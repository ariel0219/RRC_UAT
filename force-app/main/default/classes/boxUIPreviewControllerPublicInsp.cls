/*
  @Page Name          : boxUIPreviewControllerPublic.apxc
  @Description        : 
  @Author             : Kevin Lu
  @Group              : 
  @Last Modified By   : Kevin Lu
  @Last Modified On   : 5/30/2019, 11:15:00 AM
  @Modification Log   : 
  ==============================================================================
  Ver         Date                     Author                 Modification
  ==============================================================================
  1.0    5/30/2019, 11:15:00 AM   Kevin Lu     Initial Version
*/
public with sharing class boxUIPreviewControllerPublicInsp {
    private IETRS_Inspection_Public_FC_Document__c fileCorrespondence;
    private String downscopeToken;
    //private static final String SYS_ADMIN_ID = [Select Id From Profile Where Name = 'System Administrator' Limit 1].get(0).Id;
    
    public boxUIPreviewControllerPublicInsp(ApexPages.StandardController stdController){
        this.fileCorrespondence = (IETRS_Inspection_Public_FC_Document__c)stdController.getRecord();
        if(Test.isRunningTest()){
            this.fileCorrespondence = [SELECT Id, IETRS_Box_File_ID_Public__c FROM IETRS_Inspection_Public_FC_Document__c WHERE Id = :this.fileCorrespondence.Id];
        }
    }
    
    public void initalizeToken(){
        IETRSBox box = new IETRSBox();
        if(fileCorrespondence.IETRS_Box_File_ID_Public__c != null && fileCorrespondence.IETRS_Box_File_ID_Public__c != '') {
            this.downscopeToken = box.getDownscopeToken(fileCorrespondence.IETRS_Box_File_ID_Public__c);
        }
        //box.updateBoxCustomSetting();
    }
    
    public String getDownscopeToken(){
        return this.downscopeToken;
    }
    
    public String getBoxFileId(){
        return fileCorrespondence.IETRS_Box_File_ID_Public__c;
    }
}