public class AFSContactAccountTestHelper {
    
    public static Contact getContactWithAccount() {
        
        Account acc = AFSContactAccountTestHelper.GetAccount();
        System.debug('Account Found = ' + acc);       
        
        Contact con = new Contact();
        con.FirstName = 'Peter';
        con.LastName = 'Parker';
        con.AFS_Social_Security_Number__c = '687530999';
        con.AccountId = acc.Id;
        insert con;

        con = [SELECT Id, Name
               FROM Contact
               WHERE Name = 'Peter Parker'][0];
        System.debug('Contact Found = ' + con);       

        return con;
    }
    
    public static Account GetAccount(){
        Account acc = new Account();
        acc.Name = 'The Daily Bugle';
        insert acc;
        
        acc = [Select Id, Name from Account where Name='The Daily Bugle'][0];
        
        return acc;
    }

}