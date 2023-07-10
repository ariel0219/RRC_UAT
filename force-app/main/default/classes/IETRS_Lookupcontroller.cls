public class IETRS_Lookupcontroller {
    
	public IETRS_Lookupcontroller(){
	}

	@AuraEnabled
	public static List<sObject> querySalesforceRecord(String queryString){
		system.debug('=======queryString==============' + queryString);
		return Database.query(queryString);
	}

}