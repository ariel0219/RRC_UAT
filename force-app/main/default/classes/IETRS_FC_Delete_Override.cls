public without sharing class IETRS_FC_Delete_Override {
    private IETRS_Files_Correspondence__c fcDelete;
    private ApexPages.StandardController standardController;

    public IETRS_FC_Delete_Override(ApexPages.StandardController stdController){
        this.fcDelete = (IETRS_Files_Correspondence__c)stdController.getRecord();
        standardController = stdController;
    }
    public void deleteFC() {
        Exception ex;
        try {
            delete fcDelete; 
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, e.getDmlMessage(0)));
            ex = e;
        }
        if(ex == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm, 'Delete Successful. You may close this tab.' ));
        }
    }
}