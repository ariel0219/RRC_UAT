public class IETRS_InpectionController {

    @AuraEnabled
    public static IETRS_Inspection__c getInpections(Id recordId, Integer recordNumber){
         system.debug('recordNumber###'+recordNumber);
         IETRS_Inspection__c inspection = [SELECT Id, Name, RecordType.Name
                                           from IETRS_Inspection__c WHERE IETRS_Inspection_Package__c = :recordId LIMIT 1 offset :recordNumber];
         return inspection;
    }
    
    @AuraEnabled
    public static IETRS_Inspection_Package__c getRecName(Id recordId){
     IETRS_Inspection_Package__c inspakage = [SELECT Id, Name from IETRS_Inspection_Package__c WHERE Id = :recordId];   
      return inspakage;
    }
    
    @AuraEnabled
    public static Integer getallInpections(Id recordId){
         return [SELECT Id, Name, RecordType.Name from IETRS_Inspection__c WHERE IETRS_Inspection_Package__c = :recordId].size();
    }
    
   @AuraEnabled
    public static List<Inspection_Setting__mdt> getinspectionsettings(){
         return [SELECT Fields__c, DataList__c, Label,Relationship_Names__c FROM Inspection_Setting__mdt];
    }
    
    @AuraEnabled
    public static IETRS_Inspection__c getrelateddata(Id recordId,String recordtype){
        Inspection_Setting__mdt record = [SELECT Related_Fields__c, Label FROM Inspection_Setting__mdt WHERE Label =: recordtype];
        IETRS_Inspection__c inspakage = Database.Query('SELECT Id,'+record.Related_Fields__c+' from IETRS_Inspection__c  WHERE Id =\''+ recordId+'\'');
        return inspakage;
    }
}