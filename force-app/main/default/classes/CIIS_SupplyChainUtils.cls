public with sharing class CIIS_SupplyChainUtils {
    /**
     * Convert a JSON string to an Account object
     * @param jsonAcc The JSON string to convert
     * @return The Account object
     */
    public static Account jsonToAccount(String jsonAcc) {
        Account result = new Account();
        if (jsonAcc != null) {
			System.debug('Json : ' + jsonAcc );
            try{
            result = (Account) JSON.deserialize(jsonAcc, Account.class);
            }
            catch(exception e){
                system.debug('Exception : ' + e);
            }
        }
        return result;
    }
}