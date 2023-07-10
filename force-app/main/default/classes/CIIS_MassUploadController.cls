public with sharing class CIIS_MassUploadController {
@AuraEnabled(cacheable=true)
    public static List<Account> validateMassUploadData(String operatorId,List<Account> listAccount) {
        List<String> listSupplierTypes=new String[]{'Gas Processing Facility','Underground Storage Facility','3rd Party Interconnect','Producer/Lease','SWD','OL Compressor','Direct Connect','Pipeline Tap'};
         
        System.debug('listAccount:'+listAccount);
        //Check for Required field missing
        for(Integer count=0;count<listAccount.size();++count){
            Account acc=listAccount.get(count);
            if(String.isEmpty(acc.IETRS_P5_Number__c) || String.isEmpty(acc.IETRS_Account_ID__c) ||String.isEmpty(acc.CIIS_Supply_Chain_Facility_Type__c)){
                if(String.isEmpty(acc.Description)){
                    acc.Description='Row '+(count+1)+' , Required field(s) are missing';
                }
            }
        }

        //Check for 6 Digit Operstor Number
        for(Integer count=0;count<listAccount.size();++count){
            Account acc=listAccount.get(count);
            String P5Number=acc.IETRS_P5_Number__c;
            if(!String.isEmpty(P5Number) && P5Number.length()<6){
                if(String.isEmpty(acc.Description)){
                    acc.Description='Row '+(count+1)+', P5 Numbers must be 6 digit numeric';
                }
            }
        }

        //Check for Supplier Type
        for(Integer count=0;count<listAccount.size();++count){
        	Account acc=listAccount.get(count);
            if(String.isEmpty(acc.CIIS_Supply_Chain_Facility_Type__c) ||
               !listSupplierTypes.contains(acc.CIIS_Supply_Chain_Facility_Type__c)){
                   
                if(String.isEmpty(acc.Description)){
                    acc.Description='Row '+(count+1)+', Supplier Type is invalid. It should be spelled correctly';
                }
            }
        }


        //Check for receiver Ids
        List<String> externalReceiverIds=new List<String>();
        for(Integer count=0;count<listAccount.size();++count){
            Account acc=listAccount.get(count);
            if(!String.isEmpty(acc.IETRS_Account_ID__c)){
                externalReceiverIds.add(acc.IETRS_Account_ID__c);
            }
        }
        if(externalReceiverIds.size()>0){
            List<Account> listExternalAccount=[SELECT Id,IETRS_Account_ID__c FROM ACCOUNT WHERE IETRS_Account_ID__c IN:externalReceiverIds]; 
            for(Integer count=0;count<listAccount.size();++count){
                Account csvAccount=listAccount.get(count);
                boolean isFound=false;
                for(Account externalAccount:listExternalAccount){
                    if(csvAccount.IETRS_Account_ID__c==externalAccount.IETRS_Account_ID__c){
                        isFound=true;
                        break;
                    }
                }
                if(!isFound){
                    if(String.isEmpty(csvAccount.Description)){
                        csvAccount.Description = 'Row '+(count+1)+', Operator Number you provided does not match the Operator Number for this facility in our database';
                    }
                }
            }
        }

        //Check for supplier P5 Number
        List<String> supplierP5Numbers=new List<String>();
        for(Integer count=0;count<listAccount.size();++count){
            Account csvAccount=listAccount.get(count);
            if(!String.isEmpty(csvAccount.IETRS_P5_Number__c)){
                supplierP5Numbers.add(csvAccount.IETRS_P5_Number__c);
            }
        }
        if(supplierP5Numbers.size()>0){
            List<Account> supplierAccount=[SELECT Id,IETRS_P5_Number__c FROM ACCOUNT WHERE IETRS_P5_Number__c IN:supplierP5Numbers]; 
            for(Integer count=0;count<listAccount.size();++count){
                Account csvAccount=listAccount.get(count);
                boolean isFound=false;
                for(Account dbAccount:supplierAccount){
                    if(csvAccount.IETRS_P5_Number__c==dbAccount.IETRS_P5_Number__c){
                        isFound=true;
                        break;
                    }
                }
                if(!isFound){
                    if(String.isEmpty(csvAccount.Description)){
                        csvAccount.Description = 'Row '+(count+1)+', Supplier P5 Number you provided does not match the facility in our database';
                    }
                }
            }
        }
 
        //Check for supplier P5 Number & Facility Type
        supplierP5Numbers=new List<String>();
        for(Integer count=0;count<listAccount.size();++count){
            Account csvAccount=listAccount.get(count);
            if(!String.isEmpty(csvAccount.IETRS_P5_Number__c)){
                supplierP5Numbers.add(csvAccount.IETRS_P5_Number__c);
            }
        }
        if(supplierP5Numbers.size()>0){
            List<Account> dbAccountList=[SELECT Id,IETRS_P5_Number__c,CIIS_Supply_Chain_Facility_Type__c FROM ACCOUNT WHERE IETRS_P5_Number__c IN:supplierP5Numbers]; 
            for(Integer count=0;count<listAccount.size();++count){
                Account csvAccount=listAccount.get(count);
                boolean isFound=false;
                for(Account dbAccount:dbAccountList){
                    if(csvAccount.IETRS_P5_Number__c==dbAccount.IETRS_P5_Number__c && csvAccount.CIIS_Supply_Chain_Facility_Type__c==dbAccount.CIIS_Supply_Chain_Facility_Type__c){
                        isFound=true;
                        break;
                    }
                }
                if(!isFound){
                    if(String.isEmpty(csvAccount.Description)){
                        //TODO: commented for testing, need to remove or fixed the logic.
                        //csvAccount.Description = 'Row '+(count+1)+', Supplier facility type you provided does not match the facility type in our database for given P5 Number';
                    }
                }
            }
        } 
        
        //TXRRC-797 : Check For Supplier is in selected operator's scope
        //3.Can you match all of the operators using the provided p5 number?
        supplierP5Numbers=new List<String>();
        for(Integer count=0;count<listAccount.size();++count){
            Account csvAccount=listAccount.get(count);
            if(!String.isEmpty(csvAccount.IETRS_P5_Number__c)){
                supplierP5Numbers.add(csvAccount.IETRS_P5_Number__c);
            }
        }
        
        if(supplierP5Numbers.size()>0){
            List<Account> dbAccountList=
                [
                SELECT Id,IETRS_P5_Number__c,
                    IETRS_OrganizationofRegEntity__c 
                    FROM ACCOUNT WHERE 
                    IETRS_P5_Number__c IN:supplierP5Numbers
                ];
            
            System.debug('operatorId:'+operatorId);
            System.debug('csvListAccount:'+listAccount);
            System.debug('Check For Supplier is in selected operator\'s scope');
            System.debug('dbAccountList:'+dbAccountList);
            for(Integer count=0;count<listAccount.size();++count){
                Account csvAccount=listAccount.get(count);
                boolean isFound=false;
                for(Account dbAccount:dbAccountList){
                    if(csvAccount.IETRS_P5_Number__c==dbAccount.IETRS_P5_Number__c && operatorId==dbAccount.IETRS_OrganizationofRegEntity__c){
                        isFound=true;
                        break;
                    }
                    
                }
                if(!isFound){
                    if(String.isEmpty(csvAccount.Description)){
                        //TODO: commented for testing, need to remove or fixed the logic.
                        //csvAccount.Description = 'Row '+(count+1)+', The supplier P5 Number you provided does not match the facility in operator\'s scope';
                    }                    
                }
            }
        }
       
        //TXRRC-797 : Check For Receiver & Supplier Type
        //4. Is the supplier facility type allowed to send gas to the receiver facility type?
        externalReceiverIds=new List<String>();
        //supplierP5Numbers=new List<String>();
        for(Integer count=0;count<listAccount.size();++count){
            Account csvAccount=listAccount.get(count);
            if(!String.isEmpty(csvAccount.IETRS_Account_ID__c)){
                externalReceiverIds.add(csvAccount.IETRS_Account_ID__c);
            }
            /*
            if(!String.isEmpty(csvAccount.IETRS_P5_Number__c)){
                supplierP5Numbers.add(csvAccount.IETRS_P5_Number__c);
            }*/
        }
        
        if(externalReceiverIds.size()>0 && supplierP5Numbers.size()>0){
            List<Account> dbReceiverAccountList=[
                SELECT Id,IETRS_P5_Number__c,IETRS_Account_ID__c,CIIS_Supply_Chain_Facility_Type__c 
                FROM ACCOUNT WHERE IETRS_Account_ID__c IN:externalReceiverIds
            ];
            /*
            List<Account> dbSupplierAccountList=[
                SELECT Id,IETRS_P5_Number__c,IETRS_Account_ID__c,CIIS_Supply_Chain_Facility_Type__c 
                FROM ACCOUNT WHERE IETRS_P5_Number__c IN:supplierP5Numbers
            ];*/
            
            for(Integer count=0;count<listAccount.size();++count){
                Account csvAccount=	listAccount.get(count);
                Account receiverAccount;
                //Account supplierAccount;
                for(Account receiver:dbReceiverAccountList){
                    if(csvAccount.IETRS_Account_ID__c==receiver.IETRS_Account_ID__c){
                        receiverAccount=receiver;
                        break;
                    }
                }
                /*
                for(Account supplier:dbSupplierAccountList){
                    if(csvAccount.IETRS_P5_Number__c==supplier.IETRS_P5_Number__c){
                        supplierAccount=supplier;
                        break;
                    }
                }*/
                if(receiverAccount!=NULL){
                    if(receiverAccount.CIIS_Supply_Chain_Facility_Type__c=='Producer' || receiverAccount.CIIS_Supply_Chain_Facility_Type__c=='OL Compressor'){
                        if(String.isEmpty(csvAccount.Description)){
                            //TODO: commented for testing, need to remove or fixed the logic.
                            //csvAccount.Description = 'Row '+(count+1)+', The Supplier facility type isn\'t allowed to send gas to the receiver facility type';
                        }
                    }
                }
            }
        }
        return listAccount;
    }
    
    @AuraEnabled
    public static List<CIIS_SupplyChainConnectionWrapper> getSupplyChainConnections(List<CIIS_Supply_Chain_Connection__c> supplyChainList){
        if(supplyChainList==null){
            supplyChainList=new List<CIIS_Supply_Chain_Connection__c>();
        }
        
        List<CIIS_SupplyChainConnectionWrapper> listSupplyChainConnection=new List<CIIS_SupplyChainConnectionWrapper>();
        List<String> receiverIds=new List<String>();
        List<String> supplierIds=new List<String>();
      
        for(CIIS_Supply_Chain_Connection__c scc:supplyChainList){
            receiverIds.add(scc.CIIS_Receiver__c);
            supplierIds.add(scc.CIIS_Supplier__c);
        }
        Map<ID, Account> receiverAccountMap = new Map<ID, Account>([SELECT Id,Name,IETRS_Account_ID__c,IETRS_P5_Number__c,CIIS_Supply_Chain_Facility_Type__c FROM Account WHERE ID IN:receiverIds]);
        Map<ID, Account> supplierAccountMap = new Map<ID, Account>([SELECT Id,Name,IETRS_Account_ID__c,IETRS_P5_Number__c,CIIS_Supply_Chain_Facility_Type__c FROM Account WHERE ID IN:supplierIds]);
        
        for(CIIS_Supply_Chain_Connection__c scc:supplyChainList){
            CIIS_SupplyChainConnectionWrapper gscw=new CIIS_SupplyChainConnectionWrapper();
            Account receiver=receiverAccountMap.get(scc.CIIS_Receiver__c);
            Account supplier=supplierAccountMap.get(scc.CIIS_Supplier__c);
            gscw.receiverId=receiver.Id;
            gscw.supplierId=supplier.Id;
            gscw.receiverName=receiver.Name;
            gscw.receiverP5Number=receiver.IETRS_P5_Number__c;
            gscw.receiverSystemId=receiver.IETRS_Account_ID__c;
            gscw.receiverType=receiver.CIIS_Supply_Chain_Facility_Type__c;
            gscw.supplierName=supplier.Name;
            gscw.supplierP5Number=supplier.IETRS_P5_Number__c;
            gscw.supplierType=supplier.CIIS_Supply_Chain_Facility_Type__c;
            gscw.id=String.valueOf(Math.random()); 
            listSupplyChainConnection.add(gscw);
        }
        return listSupplyChainConnection;
    } 

}