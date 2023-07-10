public class EEM_PDFTagsController {
    public EEM_Event__c eemevent {get; set;}
    public List<EEM_Event_Registration__c> eemRegistationList {get; set;}
    public List<EEM_Registrant__c> eemRegistrantList {get; set;}
    public Id RecordId {get;set;}
    public boolean registrantCheck {get; set;}
    public boolean errorCheck {get; set;}
    ApexPages.StandardController sc;
    public EEM_PDFTagsController(ApexPages.StandardController sc){
        this.sc = sc;
       List<String> registrantIds = new List<String>();
        RecordId  = ApexPages.currentPage().getParameters().get('id');
        this.eemevent = [SELECT EEM_Event_Title__c,Id 
                         FROM EEM_Event__c WHERE id =:RecordId];
        
        this.eemRegistationList = [SELECT EEM_Full_Name__c,Name,EEM_Registration_Date__c,EEM_Registrant__c
                                   FROM EEM_Event_Registration__c WHERE EEM_Event__c =:this.eemevent.Id and EEM_Registrant__c !=null];
       
        if(this.eemRegistationList.size() > 0){
            this.registrantCheck = true;
        for(EEM_Event_Registration__c recordRegistration : eemRegistationList )
        { 
          registrantIds.add(String.valueOf(recordRegistration.get('EEM_Registrant__c')));
        
        }
        String ids ='(';
                for(Integer i=0; i<registrantIds.size(); i++) {
                    ids = ids + '\'' + registrantIds[i] + '\'' + ',';
                }
                ids = ids.removeend(',') + ')';
        
        System.debug('registrantId :'+ ids);    
        String  queryRegistrantIds = 'SELECT EEM_Name__c,EEM_Company_Name__c FROM EEM_Registrant__c where Id IN' + ids+ ' order by Id'  ;
       this.eemRegistrantList = Database.query(queryRegistrantIds);   
        }else{
            this.errorCheck = true;
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,'Registrant Not found.'));
        }
        
    }  
    
    
}