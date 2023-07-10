/**
 * @File Name          : EmailHandlerAction.trigger
 * @Description        : 
 * @Author             : Ronald Stewart
 * @Group              : 
 * @Last Modified By   : Ronald Stewart
 * @Last Modified On   : 04/07/2021
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0        12/10/2020               Ronald Stewart             Initial Version
 * 2.0		  04/07/2021               Ronald Stewart			  Added query and set email from OrgWideEmailAddress
**/
public class EmailHandlerAction {
    @InvocableMethod(label='Send email to recipients action' description='This action allows for 5 plus recipients' category='Email')
    public static List<String> sendEmailToParties(List<List<String>> emailInfo) {
        List<String> extractEmailInfo = new List<String>();
        for(List<String>temp:emailInfo){
            //System.debug(temp);
            extractEmailInfo = temp;
        }
        // Get a list of emails
        List<String> addresses = returnListofAddresses(extractEmailInfo[0]);
        // Get the subject
        String subject = extractEmailInfo[1];
        // Get the body
        String body = extractEmailInfo[2];
        
        //Send email
        sendEmail(addresses, subject, body);
        
        return new List<String>{'Success'};
    }
    
    // Utiliy methods to make a list
    private static List<String> returnListofAddresses (String emails){
        List<String> parameterList = emails.split(',');
        //System.debug('Emails: '+parameterList);
        return parameterList;
    }
    
    // Utiliy method to send out email to recipients
    private static void sendEmail(List<String> addresses, String subject, String body){
        // Query from Organization-Wide Email Address
        List<OrgWideEmailAddress> orgWideEmailAddresses =[select Id from OrgWideEmailAddress WHERE Address='noreplyrrc@rrc.texas.gov'];
        // Set up email for reciepents
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(orgWideEmailAddresses[0].Id);
        email.setToAddresses(addresses);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        
        //Send out email
        Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[]{email};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);          
        
        //Check for any errors
        if(results[0].success){
           System.debug('The email was sent successfully'); 
        }else{
           System.debug('The email failed to send: '+results[0].errors[0].message);
        }
    }
}