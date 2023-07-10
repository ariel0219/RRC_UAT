public class EEM_EmailSendingController {
    public EEM_Event__c eemevent {get; set;}
    public List<EEM_Event_Registration__c> eemRegistationList {get; set;}
    public List<EEM_Registrant__c> eemRegistrantList {get; set;}
    public Id RecordId {get;set;}
	public string toMail { get; set;}
	public string ccMail { get; set;}
    public string repMail { get; set;}
    public string subjectMail { get; set;}
    public string htmlBodyMail { get; set;}
	public boolean All {get; set;}
    public string oweaId;
    public boolean validatedEmail;
    public boolean registrantCheck {get; set;}
    public boolean userAccessCheck {get; set;}
    ApexPages.StandardController sc;
     OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreplyrrc@rrc.texas.gov'];
    
    public EEM_EmailSendingController(ApexPages.StandardController sc){
        String uRoleId = UserInfo.getUserRoleId();
        if(uRoleId != null){UserRole[] uRoleName = [select DeveloperName from UserRole where Id =:uRoleId ];
        System.debug('uRoleName :'+ uRoleName.get(0).DeveloperName);
        if(uRoleName.get(0).DeveloperName != 'EEM_COP_Event_Facilitator'){ this.userAccessCheck = true; 
        }else{
            this.userAccessCheck = false; 
        apexpages.addmessage(new apexpages.message(apexpages.severity.WARNING,'You do not have access to Custom Email To Registrant. Please reach out to Administrator.'));    
        }
        }else{
          this.userAccessCheck = true;   
        }
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
        String  queryRegistrantIds = 'SELECT EEM_Email__c,EEM_Name__c,EEM_Company_Name__c,EEM_Event_Registered__c FROM EEM_Registrant__c where Id IN' + ids+ ' order by Id'  ;
       this.eemRegistrantList = Database.query(queryRegistrantIds);    }else{this.registrantCheck = false;apexpages.addmessage(new apexpages.message(apexpages.severity.error,'Registrant Not found.'));
        }
      
    }  
    
	public void sendEEMMail(String recipient){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string[] to = new string[] {recipient};
        string[] cc = new string[] {ccMail};
         repMail = 'noreplyrrc@rrc.texas.gov';
       
        if ( owea.size() > 0 ) {
         email.setOrgWideEmailAddressId(owea.get(0).Id);
       }
        
		email.setToAddresses(to);
        
		if(ccMail!=null && ccMail != ''){    email.setCcAddresses(cc);}		
		
        email.setReplyTo(repMail);
       
        
        email.setSubject(subjectMail);
        
        email.setHtmlBody(htmlBodyMail);
        try{
          Messaging.SendEmailResult[] results =   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            if (!results[0].isSuccess())  {
             System.debug('The email failed to send: ' +  results[0].errors[0].message);                
              
                apexpages.addmessage(new apexpages.message(apexpages.severity.ERROR,'The email failed to send: ' +  results[0].errors[0].message));
            } else {          
                System.debug('The email was sent successfully.');
              
              apexpages.addmessage(new apexpages.message(apexpages.severity.CONFIRM,'The email was sent successfully to: '+ recipient));
            }
        }catch(exception e){
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        }
        
     
    }
        public void sendMail(){
        validatedEmail = this.emailValidation();
        if(validatedEmail == false){
         if (All == true){Messaging.Email[] messages = new Messaging.Email[0];for(EEM_Registrant__c  recordRegistrant : eemRegistrantList){ Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); repMail = 'noreplyrrc@rrc.texas.gov';string[] to = new string[] {String.valueOf(recordRegistrant.get('EEM_Email__c'))};string[] cc = new string[] {ccMail};
        if ( owea.size() > 0 ) {
             //System.debug('check All vlaue: '+ All);
         
         email.setOrgWideEmailAddressId(owea.get(0).Id);
       }
        email.setToAddresses(to);
        if(ccMail!=null && ccMail != '')
	    {    email.setCcAddresses(cc);}		
		email.setReplyTo(repMail);
        email.setSubject(subjectMail);
        email.setHtmlBody(htmlBodyMail);
        messages.add(email);
             
             System.debug('check Registrant Name: '+ String.valueOf(recordRegistrant.get('EEM_Name__c')));
             System.debug('check Registrant Name: '+ String.valueOf(recordRegistrant.get('EEM_Email__c')));
	       
	   	   }
         
             
             try{
          Messaging.SendEmailResult[] results =   Messaging.sendEmail(messages);
            if (!results[0].isSuccess())  {
             System.debug('The email failed to send: ' +  results[0].errors[0].message);                
              
                apexpages.addmessage(new apexpages.message(apexpages.severity.ERROR,'The email failed to send: ' +  results[0].errors[0].message));
            } else {          
                System.debug('The email was sent successfully.');
              
              apexpages.addmessage(new apexpages.message(apexpages.severity.CONFIRM,'The email was sent successfully to All Registrants. '));
            }
        }catch(exception e){
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        }
             
             
         }else{
            this.sendEEMMail(toMail);
        }  
        toMail = '';
        ccMail = '';        
        subjectMail = '';
        htmlBodyMail = '';
        All = false;
        }
    }
    public boolean emailValidation(){
        if(toMail == null || toMail =='' ){if(All == false){apexpages.addmessage(new apexpages.message(apexpages.severity.error,'Enter at least one address in Email To or check the Email To All Registrants checkbox'));return true;
            }
        }
        if(subjectMail == null || subjectMail ==''){apexpages.addmessage(new apexpages.message(apexpages.severity.error,'Please enter a Subject'));return true;
        }
        if(htmlBodyMail == null || htmlBodyMail ==''){apexpages.addmessage(new apexpages.message(apexpages.severity.error,'Please enter your message'));return true;
        }
        
         if(this.eemRegistationList.size() <= 0){apexpages.addmessage(new apexpages.message(apexpages.severity.error,'Registrant Not Found.'));return true;
             }
        return false;
    } 
    
    
}