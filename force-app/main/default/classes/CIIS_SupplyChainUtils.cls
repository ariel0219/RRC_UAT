public with sharing class CIIS_SupplyChainUtils {
    /**
     * Convert a JSON string to an Account object
     * @param jsonAcc The JSON string to convert
     * @return The Account object
     */
    public static Account jsonToAccount(String jsonAcc) {
        Account result = new Account();
        if (jsonAcc != null) {
            result = (Account) JSON.deserialize(jsonAcc, Account.class);
        }
        return result;
    }
}