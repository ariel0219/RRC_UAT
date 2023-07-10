public without sharing class EEM_RegistrantEmailController {
    public EEM_Event__c eemevent {get; set;}
    public EEM_Event_Registration__c eemeventRegistration {get; set;}
    public EEM_Registrant__c eemRegistrant {get; set;}
    public EEM_Transaction__c eemTrans {get; set;}
    public EEM_Transaction__c eemTran {get; set;}
    public RecordType  eemRecType  {get; set;}
    public Id RecordId {get;set;}
    public string repMail { get; set;}
    public string subjectMail { get; set;}
    public string htmlBodyMail { get; set;}    
    public string oweaId;
    public string emailConfirmation {get;set;}
    public String strConvertedDate {get; set;}
    public String venulocation {get; set;}
    public String formLabel {get; set;}
    public String formHead {get;set;}
    public String formHeadsec {get;set;}
    public String registrantAddress {get; set;}
    public String registrantMailingAddress {get; set;}
    public String registerNumber {get; set;}
    public String courseFee {get; set;}
    public String amountPaid {get;set;}
    public String classtitleone  {get;set;}
    public String classtitletwo  {get;set;}
    public String examlevelone  {get;set;}
    public String examleveltwo  {get;set;}
    public String examfeeone  {get;set;}
    public String examfeetwo  {get;set;}
    public String fueltypeone  {get;set;}
    public String fueltypetwo  {get;set;}
    public Boolean latefee  {get;set;}
    ApexPages.StandardController sc;
    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreplyrrc@rrc.texas.gov'];
    
    public EEM_RegistrantEmailController(){
        this.sc = sc;
        system.debug('sc - '+sc);
        RecordId  = ApexPages.currentPage().getParameters().get('registrantid');
        system.debug('RecordId - '+RecordId);
        String sEventRegistration  = ApexPages.currentPage().getParameters().get('eventregistration');
        system.debug('sEventRegistration - '+sEventRegistration);
        String sRegistrant  = ApexPages.currentPage().getParameters().get('registrant');
        system.debug('sRegistrant - '+sRegistrant);
        //String sTransaction  = ApexPages.currentPage().getParameters().get('transaction');
      //  system.debug('sTransaction - '+sTransaction);
        this.eemeventRegistration = String.isNotBlank(sEventRegistration) ? (EEM_Event_Registration__c)Json.deserialize(sEventRegistration, EEM_Event_Registration__c.class) : null;
        this.eemRegistrant = String.isNotBlank(sRegistrant) ? (EEM_Registrant__c)Json.deserialize(sRegistrant, EEM_Registrant__c.class) : null;
        //this.eemTrans = String.isNotBlank(sTransaction) ? (EEM_Transaction__c)Json.deserialize(sRegistrant, EEM_Transaction__c.class) : null;
        //this.eemeventRegistration = [SELECT EEM_Full_Name__c,EEM_Event_Title__c,EEM_Event_Start_Date_And_Time__c,EEM_Event__c,EEM_Registrant_Email__c,EEM_Amount_Paid__c,EEM_Register_Number__c,EEM_Registrant__c,EEM_Transaction__c
        //                           FROM EEM_Event_Registration__c WHERE id =:RecordId];
        system.debug('this.eemeventRegistration - '+this.eemeventRegistration);
        system.debug('this.eemRegistrant - '+this.eemRegistrant);
        system.debug('this.eemTrans - '+this.eemTrans);
        if(this.eemeventRegistration!=null) {
            this.eemevent = [SELECT EEM_Event_Title__c,Id,EEM_Venue__r.Name,EEM_Venue__r.EEM_Street_Address1__c,EEM_Venue__r.EEM_Street_Address2__c,EEM_Venue__r.EEM_City__c,EEM_Venue__r.EEM_State__c,EEM_Venue__r.EEM_Zip_Code__c,RecordTypeId,Recordtype.Name,EEM_Fuel_Type__c,EEM_Exam_Event__r.EEM_Exam_Level__c,EEM_Location_Address__c,Name,EEM_Class_Level__c,EEM_Class_Fee__c,EEM_Exam_Level__c,EEM_Exam_Fee__c  
                             FROM EEM_Event__c WHERE id =:this.eemeventRegistration.EEM_Event__c];
            //this.eemRegistrant =[SELECT EEM_Address__c,EEM_City_State_Zip__c,EEM_Late_Renewal_Fee__c,EEM_Name__c,Name,EEM_City__c,EEM_Company_Name__c,EEM_RRC_Company_License_Number__c,EEM_RRC_Number__c,EEM_State__c,EEM_Zip_Code__c,EEM_Associated_Exam__c
            //                    FROM EEM_Registrant__c WHERE id =:this.eemeventRegistration.EEM_Registrant__c];
            //this.eemTrans = [SELECT EEM_Register_Number__c,EEM_Remittance_Status__c
            //                FROM EEM_Transaction__c WHERE id =:this.eemeventRegistration.EEM_Transaction__c]; 
            
            this.eemRecType = [SELECT Name FROM RecordType where SobjectType = 'EEM_Event__c' and id =:this.eemevent.RecordTypeId];
            
            System.debug('@@'+this.eemTran.EEM_Register_Number__c);
            subjectMail = this.eemeventRegistration.EEM_Full_Name__c +' Registration Confirmation';
            amountPaid=this.eemeventRegistration.Amount_Paid__c;
            System.debug('@@amount'+amountPaid);
            //Datetime GMTDate = DateTime.valueOf(this.eemeventRegistration.EEM_Event_Start_Date_And_Time__c); //commented due to datatype change from datatime to formula in EEM_Event_Start_Date_And_Time__c field.
            //strConvertedDate =  GMTDate.format('MM/dd/yyyy', 'America/Chicago'); //commented due to datatype change from datatime to formula in EEM_Event_Start_Date_And_Time__c field.
            strConvertedDate = this.eemeventRegistration.EEM_Event_Start_Date_And_Time__c;//added due to datatype change from datatime to formula in EEM_Event_Start_Date_And_Time__c field.
            
            if(this.eemevent.EEM_Fuel_Type__c == 'LPG'){
                formLabel = 'LPG FORM 16';
                formHead='APPLICATION FOR CERTIFICATION';
                formHeadsec='OR CERTIFICATION RENEWAL';
                
            }
            if(this.eemevent.EEM_Fuel_Type__c == 'CNG'){
                formLabel = 'CNG FORM 1016';
                formHead='APPLICATION';
                formHeadsec='FOR EXAMINATION';
            }
            if(this.eemevent.EEM_Fuel_Type__c == 'LNG'){
                formLabel = 'LNG FORM 2016';
                formHead='APPLICATION';
                formHeadsec='FOR EXAMINATION';
            }
            
            if (this.eemeventRegistration.EEM_Register_Number__c !=null){
                registerNumber =this.eemeventRegistration.EEM_Register_Number__c; 
            }else{ 
                
                 registerNumber = this.eemeventRegistration.TransactionRegisterNumber__c; 
               
            }
            System.debug('registernumber'+registerNumber);
            
            if(this.eemevent.EEM_Class_Level__c !=null){
                courseFee = String.valueOf(this.eemevent.EEM_Class_Fee__c);
            }else
            {
                if(this.eemevent.EEM_Exam_Level__c	!=null){
                    courseFee = String.valueOf(this.eemevent.EEM_Exam_Fee__c);
                }
            }
            
            
            classtitleone=this.eemeventRegistration.Class_Title1__c;
            classtitletwo=this.eemeventRegistration.Class_Title_2__c;
            examlevelone=this.eemeventRegistration.Exam_Level_1__c;
            examleveltwo=this.eemeventRegistration.Exam_Level_2__c;
            examfeeone=this.eemeventRegistration.Exam_Fee_1__c;
            examfeetwo=this.eemeventRegistration.Exam_Fee_2__c;
            fueltypeone=this.eemeventRegistration.Fuel_Type1__c;
            fueltypetwo=this.eemeventRegistration.Fuel_Type2__c;
            venulocation = this.eemevent.EEM_Location_Address__c;
            latefee=this.eemRegistrant.EEM_Late_Renewal_Fee__c;
            registrantAddress = this.eemRegistrant.EEM_Address__c +this.eemRegistrant.EEM_City_State_Zip__c;
            registrantMailingAddress = this.eemRegistrant.EEM_Address__c;
        }
    }  
    
    
}