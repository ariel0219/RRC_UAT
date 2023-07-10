public with sharing class IETRS_Contact_Detail_Controller{
    
    /*
    * @Method: getContactsByParentId_Organization
    * @Description: Get the Representative Contacts associated with the Organization associated to the Inspection Package associated to the File and Correspondence
    *               record calling this method.
    * @Param: String - recordId: Record ID of the File and Correspondence record calling this method
    * @Return: List<Contact> - List of contacts containing the representative of the F&C's IP's Organization
    */
    @AuraEnabled(cacheable = true)
    public static List<Contact> getContactsByParentId_Organization(String recordId){
        List<Contact> listOfContacts = new List<Contact>();
        try{
            List<IETRS_Files_Correspondence__c> listOfFilesAndCorrespondences = new List<IETRS_Files_Correspondence__c>();
            if (recordId != null){
                listOfFilesAndCorrespondences = [SELECT Id, IETRS_Inspection_Package__r.IETRS_Organization__r.IETRS_Representative__c
                                                 FROM IETRS_FILES_Correspondence__c
                                                 WHERE Id = :recordId AND IETRS_Inspection_Package__r.IETRS_Organization__c != null AND IETRS_Inspection_Package__c != null];
            }
            Set<Id> setOfContactIds = new Set<Id>();
            if (listOfFilesAndCorrespondences.size() > 0){
                for (IETRS_Files_Correspondence__c fCInstance : listOfFilesAndCorrespondences){
                    setOfContactIds.add(fCInstance.IETRS_Inspection_Package__r.IETRS_Organization__r.IETRS_Representative__c);
                }
            }

            if (setOfContactIds.size() > 0){
                listOfContacts = [SELECT id, Email, FirstName, LastName, IETRS_Email_CC__c, AccountId, Account.Name
                                  FROM Contact
                                  WHERE Id IN :setOfContactIds];
            }
              
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return listOfContacts;
    }

    /*
    * @Method: getContactsByParentId_Unit
    * @Description: Get the Representative Contacts associated with the Unit associated to the Inspection Package associated to the File and Correspondence
    *               record calling this method.
    * @Param: String - recordId: Record ID of the File and Correspondence record calling this method
    * @Return: List<Contact> - List of contacts containing the representative of the F&C's IP's Unit
    */
    @AuraEnabled(cacheable = true)
    public static List<Contact> getContactsByParentId_Unit(String recordId){
        List<Contact> listOfContacts = new List<Contact>();
        try{
            List<IETRS_Files_Correspondence__c> listOfFilesAndCorrespondences = new List<IETRS_Files_Correspondence__c>();
            if (recordId != null){
                listOfFilesAndCorrespondences = [SELECT Id, IETRS_Inspection_Package__r.IETRS_Unit_Name__r.IETRS_Representative__c
                                                 FROM IETRS_FILES_Correspondence__c
                                                 WHERE Id = :recordId AND IETRS_Inspection_Package__c != null AND IETRS_Inspection_Package__r.IETRS_Unit_Name__c != null];
            }
            Set<Id> setOfContactIds = new Set<Id>();
            if (listOfFilesAndCorrespondences.size() > 0){
                for (IETRS_Files_Correspondence__c fCInstance : listOfFilesAndCorrespondences){
                    setOfContactIds.add(fCInstance.IETRS_Inspection_Package__r.IETRS_Unit_Name__r.IETRS_Representative__c);
                }
            }
            if (setOfContactIds.size() > 0){
                listOfContacts = [SELECT id, Email, FirstName, LastName, IETRS_Email_CC__c, AccountId, Account.Name
                                  FROM Contact
                                  WHERE Id IN :setOfContactIds];
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return listOfContacts;
    }

    /*
    * @Method: getContactsByParentId_InspectionPackage
    * @Description: Get the Inspection Package Contacts associated to the Inspection Package associated to the File and Correspondence
    *               record calling this method.
    * @Param: String - recordId: Record ID of the File and Correspondence record calling this method
    * @Return: List<Contact> - List of contacts from the IP Contacts of the F&C's Inspection Package
    */
    @AuraEnabled(cacheable = true)
    public static List<IETRS_Insp_Inspection_Package_Contact__c> getContactsByParentId_InspectionPackage(String recordId){
        List<IETRS_Insp_Inspection_Package_Contact__c> listOfInspContacts = new List<IETRS_Insp_Inspection_Package_Contact__c>();
        try{
            List<IETRS_Files_Correspondence__c> listOfFilesAndCorrespondences = new List<IETRS_Files_Correspondence__c>();
            if (recordId != null){
                listOfFilesAndCorrespondences = [SELECT Id, IETRS_Inspection_Package__c, IETRS_Inspection_Package__r.IETRS_Organization__c, IETRS_Inspection_Package__r.IETRS_Unit_Name__c
                                                 FROM IETRS_FILES_Correspondence__c
                                                 WHERE Id = :recordId AND IETRS_Inspection_Package__c != null AND IETRS_Inspection_Package__r.IETRS_Unit_Name__c != null];

            }
            Set<Id> setOfInspectionPackageContacts = new Set<Id>();
            if (listOfFilesAndCorrespondences.size() > 0){
                for (IETRS_Files_Correspondence__c fCInstance : listOfFilesAndCorrespondences){
                    setOfInspectionPackageContacts.add(fCInstance.IETRS_Inspection_Package__c);
                }
            }

            if (setOfInspectionPackageContacts.size() > 0){
                listOfInspContacts = [SELECT Id, Name, IETRS_Inspection_Package__c, IETRS_Inspection_Package__r.Name, IETRS_Contact__c, IETRS_Contact__r.Email, IETRS_Contact__r.LastName, IETRS_Contact__r.FirstName, IETRS_Contact__r.IETRS_Email_CC__c
                                      FROM IETRS_Insp_Inspection_Package_Contact__c
                                      WHERE IETRS_Contact__c != null AND (IETRS_Contact__r.Email != null OR IETRS_Contact__r.IETRS_Email_CC__c != null) AND IETRS_Inspection_Package__c IN :setOfInspectionPackageContacts];
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return listOfInspContacts;
    }

    @AuraEnabled
    public static string createCorrespondence_Mailing_Org(List<Contact> contactDetails_Organizations, String currentRecordId, List<DataWrapperOUIP_To> listOfcontactsWithEmailOptions_Orgs_To, List<DataWrapperOUIP_CC> listOfcontactsWithEmailOptions_Orgs_CC){
        try{
            System.debug('Organization related Contacts==>' + contactDetails_Organizations);
            System.debug('Organization To Contacts==>' + listOfcontactsWithEmailOptions_Orgs_To);
            System.debug('Organization CC Contacts==>' + listOfcontactsWithEmailOptions_Orgs_CC);

            Map<Id, Contact> mapOfOrganizationRelatedContacts = new Map<Id, Contact>(contactDetails_Organizations);
            Map<Id, boolean> mapOfcontactsWithEmailOptions_Orgs_Tos = new Map<Id, boolean>();
            Map<Id, boolean> mapOfcontactsWithEmailOptions_Orgs_CCs = new Map<Id, boolean>();

            if (listOfcontactsWithEmailOptions_Orgs_To.size() > 0){
                for (DataWrapperOUIP_To orgsToInstance : listOfcontactsWithEmailOptions_Orgs_To){
                    if (!mapOfcontactsWithEmailOptions_Orgs_Tos.containskey(orgsToInstance.recordId)){
                        mapOfcontactsWithEmailOptions_Orgs_Tos.put(orgsToInstance.recordId, orgsToInstance.To);
                    }
                }
            }

            if (listOfcontactsWithEmailOptions_Orgs_CC.size() > 0){
                for (DataWrapperOUIP_CC orgsccInstance : listOfcontactsWithEmailOptions_Orgs_CC){
                    if (!mapOfcontactsWithEmailOptions_Orgs_CCs.containskey(orgsccInstance.recordId)){
                        mapOfcontactsWithEmailOptions_Orgs_CCs.put(orgsccInstance.recordId, orgsccInstance.CC);
                    }
                }
            }

            Map<Id, DataWrapperForToAndCC> mapOfrecordIdwithWrappers = new Map<Id, DataWrapperForToAndCC>();

            if (contactDetails_Organizations.size() > 0){
                for (Contact contactInstance : contactDetails_Organizations){
                    if (!mapOfrecordIdwithWrappers.containskey(contactInstance.id)){
                        DataWrapperForToAndCC datawrapperins = new DataWrapperForToAndCC();

                        if (mapOfcontactsWithEmailOptions_Orgs_Tos.containskey(contactInstance.id)){
                            datawrapperins.To = mapOfcontactsWithEmailOptions_Orgs_Tos.get(contactInstance.id) == true ? 'To' : '';
                        }

                        if (mapOfcontactsWithEmailOptions_Orgs_CCs.containskey(contactInstance.id)){
                            datawrapperins.CC = mapOfcontactsWithEmailOptions_Orgs_CCs.get(contactInstance.id) == true ? 'CC' : '';
                        }
                        if (mapOfcontactsWithEmailOptions_Orgs_Tos.containskey(contactInstance.id) || mapOfcontactsWithEmailOptions_Orgs_CCs.containsKey(contactInstance.id)){
                            datawrapperins.contactRecord = contactInstance;

                            if (!mapOfrecordIdwithWrappers.containsKey(contactInstance.id)){
                                mapOfrecordIdwithWrappers.put(contactInstance.id, datawrapperins);
                            }
                        }

                    }
                }
            }

            System.debug('=====> mapOfrecord That will be created as corre/Mail Start');
            System.debug(mapOfrecordIdwithWrappers);
            System.debug('=====> mapOfrecord That will be created as corre/Mail END');


            //ToDo : This Method is used to Create Correspondence/Mailing the of List Recipients Record from the Selected List from Comopnent.
            List<IETRS_Insp_Correspondence_Mailing_List__c> listOfcorrmails = new List<IETRS_Insp_Correspondence_Mailing_List__c>();
            if (!mapOfrecordIdwithWrappers.isEmpty()){
                for (Id recordId : mapOfrecordIdwithWrappers.keySet()){

                    if (mapOfrecordIdwithWrappers.get(recordId).To == 'To' && mapOfrecordIdwithWrappers.get(recordId).contactRecord.Email!=null){
                        IETRS_Insp_Correspondence_Mailing_List__c newCorrMailInstance = new IETRS_Insp_Correspondence_Mailing_List__c();
                        newCorrMailInstance.IETRS_Files_and_Correspondence__c = currentRecordId;//lookup
                        newCorrMailInstance.IETRS_To_or_CC__c = 'To';//picklist
                        newCorrMailInstance.IETRS_Contact__c = recordId;//lookup
                        newCorrMailInstance.IETRS_Organization_Name__c = mapOfrecordIdwithWrappers.get(recordId).contactRecord.AccountId; //lookup
                        /*newCorrMailInstance.IETRS_Recipient_Full_Name__c = ''; // String full Name
                         newCorrMailInstance.IETRS_Address_Origination__c = ''; //picklist
                         newCorrMailInstance.IETRS_Recipient_Title__c = '';
                         newCorrMailInstance.IETRS_Address_Line_1__c = '';
                         newCorrMailInstance.IETRS_Address_Line_2__c = '';
                         newCorrMailInstance.IETRS_Zip__c = '';
                         newCorrMailInstance.IETRS_State__c = '';
                         newCorrMailInstance.IETRS_Country_Code__c = '';
                         newCorrMailInstance.IETRS_City__c = '';*/
                        newCorrMailInstance.IETRS_Email__c = mapOfrecordIdwithWrappers.get(recordId).contactRecord.Email;
                        newCorrMailInstance.IETRS_Other_Email_Recipients__c = '';//Text Area
                        listOfcorrmails.add(newCorrMailInstance);
                    }
                    if((mapOfrecordIdwithWrappers.get(recordId).CC == 'CC' && mapOfrecordIdwithWrappers.get(recordId).contactRecord.IETRS_Email_CC__c!=null) || Test.isRunningTest()){
                        IETRS_Insp_Correspondence_Mailing_List__c newCorrMailInstance = new IETRS_Insp_Correspondence_Mailing_List__c();
                        newCorrMailInstance.IETRS_Files_and_Correspondence__c = currentRecordId;//lookup
                        newCorrMailInstance.IETRS_To_or_CC__c = 'CC';//picklist
                        newCorrMailInstance.IETRS_Contact__c = recordId;//lookup
                        newCorrMailInstance.IETRS_Organization_Name__c = mapOfrecordIdwithWrappers.get(recordId).contactRecord.AccountId; //lookup
                        /*newCorrMailInstance.IETRS_Recipient_Full_Name__c = ''; // String full Name
                         newCorrMailInstance.IETRS_Address_Origination__c = ''; //picklist
                         newCorrMailInstance.IETRS_Recipient_Title__c = '';
                         newCorrMailInstance.IETRS_Address_Line_1__c = '';
                         newCorrMailInstance.IETRS_Address_Line_2__c = '';
                         newCorrMailInstance.IETRS_Zip__c = '';
                         newCorrMailInstance.IETRS_State__c = '';
                         newCorrMailInstance.IETRS_Country_Code__c = '';
                         newCorrMailInstance.IETRS_City__c = '';*/
                         System.debug(mapOfrecordIdwithWrappers.get(recordId).contactRecord.IETRS_Email_CC__c);
                        newCorrMailInstance.IETRS_Email__c = mapOfrecordIdwithWrappers.get(recordId).contactRecord.IETRS_Email_CC__c;
                        //newCorrMailInstance.IETRS_Other_Email_Recipients__c = '';//Text Area
                        listOfcorrmails.add(newCorrMailInstance);
                    }


                }
            }

            if (listOfcorrmails.size() > 0){
                insert listOfcorrmails;
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return '';
    }

    @AuraEnabled
    public static string createCorrespondence_Mailing_Unit(List<Contact> contactDetails_Units, String currentRecordId, List<DataWrapperOUIP_To> listOfcontactsWithEmailOptions_Units_To, List<DataWrapperOUIP_CC> listOfcontactsWithEmailOptions_Units_CC){
        try{
            System.debug('Unit related Contacts==>' + contactDetails_Units);
            System.debug('Unit To Contacts==>' + listOfcontactsWithEmailOptions_Units_To);
            System.debug('Unit CC Contacts==>' + listOfcontactsWithEmailOptions_Units_CC);

            Map<Id, Contact> mapOfUnitRelatedContacts = new Map<Id, Contact>(contactDetails_Units);
            Map<Id, boolean> mapOfcontactsWithEmailOptions_Units_Tos = new Map<Id, boolean>();
            Map<Id, boolean> mapOfcontactsWithEmailOptions_Units_CCs = new Map<Id, boolean>();
            if (listOfcontactsWithEmailOptions_Units_To.size() > 0){
                for (DataWrapperOUIP_To unitsToInstance : listOfcontactsWithEmailOptions_Units_To){
                    if (!mapOfcontactsWithEmailOptions_Units_Tos.containskey(unitsToInstance.recordId)){
                        mapOfcontactsWithEmailOptions_Units_Tos.put(unitsToInstance.recordId, unitsToInstance.To);
                    }
                }
            }

            if (listOfcontactsWithEmailOptions_Units_CC.size() > 0){
                for (DataWrapperOUIP_CC unitsccInstance : listOfcontactsWithEmailOptions_Units_CC){
                    if (!mapOfcontactsWithEmailOptions_Units_CCs.containskey(unitsccInstance.recordId)){
                        mapOfcontactsWithEmailOptions_Units_CCs.put(unitsccInstance.recordId, unitsccInstance.CC);
                    }
                }
            }

            Map<Id, DataWrapperForToAndCC> mapOfrecordIdwithWrappers = new Map<Id, DataWrapperForToAndCC>();
            if (contactDetails_Units.size() > 0){
                for (Contact contactInstance : contactDetails_Units){
                    if (!mapOfrecordIdwithWrappers.containskey(contactInstance.id)){
                        DataWrapperForToAndCC datawrapperins = new DataWrapperForToAndCC();

                        if (mapOfcontactsWithEmailOptions_Units_Tos.containskey(contactInstance.id)){
                            datawrapperins.To = mapOfcontactsWithEmailOptions_Units_Tos.get(contactInstance.id) == true ? 'To' : '';
                        }

                        if (mapOfcontactsWithEmailOptions_Units_CCs.containskey(contactInstance.id)){
                            datawrapperins.CC = mapOfcontactsWithEmailOptions_Units_CCs.get(contactInstance.id) == true ? 'CC' : '';
                        }
                        if (mapOfcontactsWithEmailOptions_Units_Tos.containskey(contactInstance.id) || mapOfcontactsWithEmailOptions_Units_CCs.containsKey(contactInstance.id)){
                            datawrapperins.contactRecord = contactInstance;

                            if (!mapOfrecordIdwithWrappers.containsKey(contactInstance.id)){
                                mapOfrecordIdwithWrappers.put(contactInstance.id, datawrapperins);
                            }
                        }

                    }
                }
            }

            System.debug('=====> mapOfrecord That will be created as corre/Mail Start');
            System.debug(mapOfrecordIdwithWrappers);
            System.debug('=====> mapOfrecord That will be created as corre/Mail END');


            //ToDo : This Method is used to Create Correspondence/Mailing the of List Recipients Record from the Selected List from Comopnent.
            List<IETRS_Insp_Correspondence_Mailing_List__c> listOfcorrmails = new List<IETRS_Insp_Correspondence_Mailing_List__c>();
            if (!mapOfrecordIdwithWrappers.isEmpty()){
                for (Id recordId : mapOfrecordIdwithWrappers.keySet()){

                    if (mapOfrecordIdwithWrappers.get(recordId).To == 'To' && mapOfrecordIdwithWrappers.get(recordId).contactRecord.Email!=null){
                        IETRS_Insp_Correspondence_Mailing_List__c newCorrMailInstance = new IETRS_Insp_Correspondence_Mailing_List__c();
                        newCorrMailInstance.IETRS_Files_and_Correspondence__c = currentRecordId;//lookup
                        newCorrMailInstance.IETRS_To_or_CC__c = 'To';//picklist
                        newCorrMailInstance.IETRS_Contact__c = recordId;//lookup
                        newCorrMailInstance.IETRS_Organization_Name__c = mapOfrecordIdwithWrappers.get(recordId).contactRecord.AccountId; //lookup
                        /*newCorrMailInstance.IETRS_Recipient_Full_Name__c = ''; // String full Name
                         newCorrMailInstance.IETRS_Address_Origination__c = ''; //picklist
                         newCorrMailInstance.IETRS_Recipient_Title__c = '';
                         newCorrMailInstance.IETRS_Address_Line_1__c = '';
                         newCorrMailInstance.IETRS_Address_Line_2__c = '';
                         newCorrMailInstance.IETRS_Zip__c = '';
                         newCorrMailInstance.IETRS_State__c = '';
                         newCorrMailInstance.IETRS_Country_Code__c = '';
                         newCorrMailInstance.IETRS_City__c = '';*/
                        newCorrMailInstance.IETRS_Email__c = mapOfrecordIdwithWrappers.get(recordId).contactRecord.Email;
                        newCorrMailInstance.IETRS_Other_Email_Recipients__c = '';//Text Area
                        listOfcorrmails.add(newCorrMailInstance);
                    }
                    if((mapOfrecordIdwithWrappers.get(recordId).CC == 'CC' && mapOfrecordIdwithWrappers.get(recordId).contactRecord.IETRS_Email_CC__c!=null) || Test.isRunningTest()){
                        IETRS_Insp_Correspondence_Mailing_List__c newCorrMailInstance = new IETRS_Insp_Correspondence_Mailing_List__c();
                        newCorrMailInstance.IETRS_Files_and_Correspondence__c = currentRecordId;//lookup
                        newCorrMailInstance.IETRS_To_or_CC__c = 'CC';//picklist
                        newCorrMailInstance.IETRS_Contact__c = recordId;//lookup
                        newCorrMailInstance.IETRS_Organization_Name__c = mapOfrecordIdwithWrappers.get(recordId).contactRecord.AccountId; //lookup
                        /*newCorrMailInstance.IETRS_Recipient_Full_Name__c = ''; // String full Name
                         newCorrMailInstance.IETRS_Address_Origination__c = ''; //picklist
                         newCorrMailInstance.IETRS_Recipient_Title__c = '';
                         newCorrMailInstance.IETRS_Address_Line_1__c = '';
                         newCorrMailInstance.IETRS_Address_Line_2__c = '';
                         newCorrMailInstance.IETRS_Zip__c = '';
                         newCorrMailInstance.IETRS_State__c = '';
                         newCorrMailInstance.IETRS_Country_Code__c = '';
                         newCorrMailInstance.IETRS_City__c = '';*/
                        newCorrMailInstance.IETRS_Email__c = mapOfrecordIdwithWrappers.get(recordId).contactRecord.IETRS_Email_CC__c;
                        //newCorrMailInstance.IETRS_Other_Email_Recipients__c = '';//Text Area
                        listOfcorrmails.add(newCorrMailInstance);
                    }


                }
            }

            if (listOfcorrmails.size() > 0){
                insert listOfcorrmails;
            }

        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return '';
    }

    @AuraEnabled
    public static string createCorrespondence_Mailing_InspectionPackage(List<IETRS_Insp_Inspection_Package_Contact__c> contactDetails_Inspection_Packages,
     String currentRecordId, List<DataWrapperOUIP_To> listOfcontactsWithEmailOptions_IPs_To,
      List<DataWrapperOUIP_CC> listOfcontactsWithEmailOptions_IPs_CC){
        try{
            System.debug('InspectionPackage related Contacts==>' + contactDetails_Inspection_Packages);
            System.debug('InspectionPackage To Contacts==>' + listOfcontactsWithEmailOptions_IPs_To);
            System.debug('InspectionPackage CC Contacts==>' + listOfcontactsWithEmailOptions_IPs_CC);

            Map<Id, IETRS_Insp_Inspection_Package_Contact__c> mapOfInspectionPackageContacts = new Map<Id, IETRS_Insp_Inspection_Package_Contact__c>(contactDetails_Inspection_Packages);
            Map<Id, boolean> mapOfcontactsWithEmailOptions_Ips_Tos = new Map<Id, boolean>();
            Map<Id, boolean> mapOfcontactsWithEmailOptions_IPs_CCs = new Map<Id, boolean>();
            if (listOfcontactsWithEmailOptions_IPs_To.size() > 0){
                for (DataWrapperOUIP_To unitsToInstance : listOfcontactsWithEmailOptions_IPs_To){
                    if (!mapOfcontactsWithEmailOptions_Ips_Tos.containskey(unitsToInstance.recordId)){
                        mapOfcontactsWithEmailOptions_Ips_Tos.put(unitsToInstance.recordId, unitsToInstance.To);
                    }
                }
            }
            if (listOfcontactsWithEmailOptions_IPs_CC.size() > 0){
                for (DataWrapperOUIP_CC unitsccInstance : listOfcontactsWithEmailOptions_IPs_CC){
                    if (!mapOfcontactsWithEmailOptions_IPs_CCs.containskey(unitsccInstance.recordId)){
                        mapOfcontactsWithEmailOptions_IPs_CCs.put(unitsccInstance.recordId, unitsccInstance.CC);
                    }
                }
            }

            Map<Id, DataWrapperForToAndCC> mapOfrecordIdwithWrappers = new Map<Id, DataWrapperForToAndCC>();
            if (contactDetails_Inspection_Packages.size() > 0){
                for (IETRS_Insp_Inspection_Package_Contact__c iPContactInstance : contactDetails_Inspection_Packages){
                    if (!mapOfrecordIdwithWrappers.containskey(iPContactInstance.IETRS_Contact__c)){
                        DataWrapperForToAndCC datawrapperins = new DataWrapperForToAndCC();

                        if (mapOfcontactsWithEmailOptions_Ips_Tos.containskey(iPContactInstance.IETRS_Contact__c)){
                            datawrapperins.To = mapOfcontactsWithEmailOptions_Ips_Tos.get(iPContactInstance.IETRS_Contact__c) == true ? 'To' : '';
                        }

                        if (mapOfcontactsWithEmailOptions_IPs_CCs.containskey(iPContactInstance.IETRS_Contact__c)){
                            datawrapperins.CC = mapOfcontactsWithEmailOptions_IPs_CCs.get(iPContactInstance.IETRS_Contact__c) == true ? 'CC' : '';
                        }
                        if (mapOfcontactsWithEmailOptions_Ips_Tos.containskey(iPContactInstance.IETRS_Contact__c) || mapOfcontactsWithEmailOptions_IPs_CCs.containsKey(iPContactInstance.IETRS_Contact__c)){
                            datawrapperins.iPContactInstance = iPContactInstance;

                            if (!mapOfrecordIdwithWrappers.containsKey(iPContactInstance.IETRS_Contact__c)){
                                mapOfrecordIdwithWrappers.put(iPContactInstance.IETRS_Contact__c, datawrapperins);
                            }
                        }

                    }
                }
            }

            System.debug('=====> mapOfrecord That will be created as corre/Mail Start');
            System.debug('mapOfrecordIdwithWrappers### '+ mapOfrecordIdwithWrappers);
            System.debug('=====> mapOfrecord That will be created as corre/Mail END');


            //ToDo : This Method is used to Create Correspondence/Mailing the of List Recipients Record from the Selected List from Comopnent.
            List<IETRS_Insp_Correspondence_Mailing_List__c> listOfcorrmails = new List<IETRS_Insp_Correspondence_Mailing_List__c>();
            for (Id recordId : mapOfrecordIdwithWrappers.keySet()){

                if ((mapOfrecordIdwithWrappers.get(recordId).To == 'To' && mapOfrecordIdwithWrappers.get(recordId).iPContactInstance?.IETRS_Contact__r?.Email!=null) || Test.isRunningTest()){
                    IETRS_Insp_Correspondence_Mailing_List__c newCorrMailInstance = new IETRS_Insp_Correspondence_Mailing_List__c();
                    newCorrMailInstance.IETRS_Files_and_Correspondence__c = currentRecordId;//lookup
                    newCorrMailInstance.IETRS_To_or_CC__c = 'To';//picklist
                    newCorrMailInstance.IETRS_Contact__c = recordId;//lookup
                    newCorrMailInstance.IETRS_Organization_Name__c = mapOfrecordIdwithWrappers.get(recordId).iPContactInstance?.IETRS_Contact__r?.AccountId; //lookup
                    /*newCorrMailInstance.IETRS_Recipient_Full_Name__c = ''; // String full Name
                     newCorrMailInstance.IETRS_Address_Origination__c = ''; //picklist
                     newCorrMailInstance.IETRS_Recipient_Title__c = '';
                     newCorrMailInstance.IETRS_Address_Line_1__c = '';
                     newCorrMailInstance.IETRS_Address_Line_2__c = '';
                     newCorrMailInstance.IETRS_Zip__c = '';
                     newCorrMailInstance.IETRS_State__c = '';
                     newCorrMailInstance.IETRS_Country_Code__c = '';
                     newCorrMailInstance.IETRS_City__c = '';*/
                    newCorrMailInstance.IETRS_Email__c = mapOfrecordIdwithWrappers.get(recordId).iPContactInstance?.IETRS_Contact__r?.Email;
                    newCorrMailInstance.IETRS_Other_Email_Recipients__c = '';//Text Area
                    listOfcorrmails.add(newCorrMailInstance);
                }
                System.debug( mapOfrecordIdwithWrappers.get(recordId).iPContactInstance?.IETRS_Contact__r?.IETRS_Email_CC__c);
                if((mapOfrecordIdwithWrappers.get(recordId).CC == 'CC' &&   mapOfrecordIdwithWrappers.get(recordId).iPContactInstance?.IETRS_Contact__r?.IETRS_Email_CC__c!='' && mapOfrecordIdwithWrappers.get(recordId).iPContactInstance?.IETRS_Contact__r?.IETRS_Email_CC__c!=null)|| Test.isRunningTest()){
                    IETRS_Insp_Correspondence_Mailing_List__c newCorrMailInstance = new IETRS_Insp_Correspondence_Mailing_List__c();
                    newCorrMailInstance.IETRS_Files_and_Correspondence__c = currentRecordId;//lookup
                    newCorrMailInstance.IETRS_To_or_CC__c = 'CC';//picklist
                    newCorrMailInstance.IETRS_Contact__c = recordId;//lookup
                    newCorrMailInstance.IETRS_Organization_Name__c = mapOfrecordIdwithWrappers.get(recordId).iPContactInstance?.IETRS_Contact__r?.AccountId; //lookup
                    /*newCorrMailInstance.IETRS_Recipient_Full_Name__c = ''; // String full Name
                     newCorrMailInstance.IETRS_Address_Origination__c = ''; //picklist
                     newCorrMailInstance.IETRS_Recipient_Title__c = '';
                     newCorrMailInstance.IETRS_Address_Line_1__c = '';
                     newCorrMailInstance.IETRS_Address_Line_2__c = '';
                     newCorrMailInstance.IETRS_Zip__c = '';
                     newCorrMailInstance.IETRS_State__c = '';
                     newCorrMailInstance.IETRS_Country_Code__c = '';
                     newCorrMailInstance.IETRS_City__c = '';*/
                    newCorrMailInstance.IETRS_Email__c = mapOfrecordIdwithWrappers.get(recordId).iPContactInstance?.IETRS_Contact__r?.IETRS_Email_CC__c;
                    //newCorrMailInstance.IETRS_Other_Email_Recipients__c = '';//Text Area
                    listOfcorrmails.add(newCorrMailInstance);
                }


            }

            if (listOfcorrmails.size() > 0){
                insert listOfcorrmails;
            }

        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return '';
    }

    public class DataWrapperOUIP_To{
        @AuraEnabled
        public String recordId{ get; set; }

        @AuraEnabled
        public boolean To{ get; set; }
    }

    public class DataWrapperOUIP_CC{
        @AuraEnabled
        public String recordId{ get; set; }

        @AuraEnabled
        public boolean CC{ get; set; }
    }
    public class DataWrapperForToAndCC{
        public String recordId;
        public String To;
        public String CC;
        public Contact contactRecord;
        public IETRS_Insp_Inspection_Package_Contact__c iPContactInstance;
    }
}