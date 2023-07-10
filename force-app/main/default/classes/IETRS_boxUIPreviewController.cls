/*
  @Page Name          : IETRS_boxUIPreviewController.apxc
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
public with sharing class IETRS_boxUIPreviewController {
	private final IETRS_Files_Correspondence__c fileCorrespondence;
    private String downscopeToken;
    //private static final String SYS_ADMIN_ID = [Select Id From Profile Where Name = 'System Administrator' Limit 1].get(0).Id;
    
    public IETRS_boxUIPreviewController(ApexPages.StandardController stdController){
        this.fileCorrespondence = (IETRS_Files_Correspondence__c)stdController.getRecord();
		system.debug(this.fileCorrespondence);
    }
    
    public void initalizeToken(){
        IETRSBox box = new IETRSBox();
        if(fileCorrespondence.IETRS_Box_File_ID__c != null && fileCorrespondence.IETRS_Box_File_ID__c != '') {
            this.downscopeToken = box.getDownscopeToken(fileCorrespondence.IETRS_Box_File_ID__c);
        }
        //box.updateBoxCustomSetting();
    }
    
    public String getDownscopeToken(){
        return this.downscopeToken;
    }
    
    public String getBoxFileId(){
        return fileCorrespondence.IETRS_Box_File_ID__c;
    }
}