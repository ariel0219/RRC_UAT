public class CIIS_PrepareMassUploadConfirmList { 
	@InvocableMethod (label = 'Return MassUploadSuccessList' description = 'Convert CSV data into Supply chain record list')
    public static List<List<CIIS_Supply_Chain_Connection__c>> convertCSVToSupplyChain(List<List<Account>> listCsvAccountList){
        List<Account> csvAccountList=listCsvAccountList.get(0);
        
        List<CIIS_Supply_Chain_Connection__c> supplyChainList=new List<CIIS_Supply_Chain_Connection__c>(); 
        List<String> listSupplierTypes=new String[]{'Gas Processing Facility','Underground Storage Facility','3rd Party Interconnect','Producer','SWD','OL Compressor','Direct Connect','Pipeline Tap'};

        List<String> p5NumberList=new List<String>();
        List<String> receiverExternalIds=new List<String>();
        
        for(Account csvAccount:csvAccountList){
            if(!p5NumberList.contains(csvAccount.IETRS_P5_Number__c)){
                p5NumberList.add(csvAccount.IETRS_P5_Number__c);
            }
            if(!receiverExternalIds.contains(csvAccount.IETRS_Account_ID__c)){
                receiverExternalIds.add(csvAccount.IETRS_Account_ID__c);
            }
        }
        /*THIS LOGIC HAS TO VERIFY*/
        /*
        List<Account> dbAccountList = [
            Select Id,Name,IETRS_P5_Number__c,IETRS_OrganizationofRegEntity__c,
            IETRS_OrganizationofRegEntity__r.CIIS_Supply_Chain_Facility_Type__c,
            IETRS_OrganizationofRegEntity__r.Name,IETRS_OrganizationofRegEntity__r.IETRS_Account_ID__c,
            CIIS_Supply_Chain_Facility_Type__c FROM Account WHERE IETRS_P5_Number__c IN:p5NumberList
        ];
        
        for(Account csvAccount:csvAccountList){
            for(Account dbAccount:dbAccountList){
                if(csvAccount.IETRS_P5_Number__c==dbAccount.IETRS_P5_Number__c 
                   && csvAccount.IETRS_Account_ID__c==dbAccount.IETRS_OrganizationofRegEntity__r.IETRS_Account_ID__c
                   && csvAccount.CIIS_Supply_Chain_Facility_Type__c==dbAccount.CIIS_Supply_Chain_Facility_Type__c)
                {
                    CIIS_Supply_Chain_Connection__c supplyChainRecord=new CIIS_Supply_Chain_Connection__c();
                    supplyChainRecord.CIIS_Status__c='Pending';
                    supplyChainRecord.CIIS_Supplier_Type__c=dbAccount.CIIS_Supply_Chain_Facility_Type__c;
                    supplyChainRecord.CIIS_Supplier__c=dbAccount.Id;
                    supplyChainRecord.CIIS_Receiver__c=dbAccount.IETRS_OrganizationofRegEntity__c;
                    supplyChainList.add(supplyChainRecord);
                }
            }*/
        //Supplier Details
        List<Account> dbSupplierAccountList = [
            Select Id,Name,IETRS_P5_Number__c FROM Account WHERE IETRS_P5_Number__c IN:p5NumberList
        ];
        
        //Receiver Details
        List<Account> dbReceiverAccountList = [
            Select Id,Name,IETRS_Account_ID__c,IETRS_P5_Number__c FROM Account WHERE IETRS_Account_ID__c IN:receiverExternalIds
        ];
        
        for(Account csvAccount:csvAccountList){
            CIIS_Supply_Chain_Connection__c supplyChainRecord=new CIIS_Supply_Chain_Connection__c();
            supplyChainRecord.CIIS_Status__c='Pending';
            supplyChainRecord.CIIS_Supplier_Type__c=csvAccount.CIIS_Supply_Chain_Facility_Type__c;
            
            boolean isSupplierFound=false;
            boolean isReceiverFound=false;
            
            for(Account dbAccount:dbSupplierAccountList){
                if(csvAccount.IETRS_P5_Number__c==dbAccount.IETRS_P5_Number__c){
                    isSupplierFound=true;
                    supplyChainRecord.CIIS_Supplier__c=dbAccount.Id;
                    //supplyChainRecord.CIIS_Supplier_Name__c=dbAccount.Name;
                    //supplyChainRecord.CIIS_Supplier_Operator_Number__c=dbAccount.IETRS_P5_Number__c;
                    break;
                }
            }  
            
            for(Account dbAccount:dbReceiverAccountList){
                if(csvAccount.IETRS_Account_ID__c==dbAccount.IETRS_Account_ID__c){
                    isReceiverFound=true;
                    supplyChainRecord.CIIS_Receiver__c=dbAccount.Id;
                    supplyChainRecord.CIIS_Supplier_Type__c=csvAccount.CIIS_Supply_Chain_Facility_Type__c;
                    /*supplyChainRecord.CIIS_Receiver_Name__c=dbAccount.Name;
                    supplyChainRecord.CIIS_Receiver_P5_Number__c=dbAccount.IETRS_P5_Number__c;
                    supplyChainRecord.CIIS_Receiver_System_Id__c=dbAccount.IETRS_Account_ID__c;*/
                    break;
                }
            } 
            if(isSupplierFound & isReceiverFound){
                supplyChainList.add(supplyChainRecord);
            }
        }
        List<List<CIIS_Supply_Chain_Connection__c>> returnList=new List<List<CIIS_Supply_Chain_Connection__c>>();
        returnList.add(supplyChainList);
        return returnList;
    }
   
}