/**
 * @File Name          : IETRS_RecordEditController.cls
 * @Description        : 
 * @Author             : Mark Frizzell
 * @Group              : 
 * @Last Modified By   : Mark Frizzell
 * @Last Modified On   : 8/9/2019, 10:25:55 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    7/28/2019                Mark Frizzell     Initial Version
**/
public with sharing class IETRS_RecordEditController {
    
    
    /**
    * @description Loads sections, columns, and fields for the page layout for either a specified record or record type
    * @author Mark Frizzell | 7/28/2019
    * @param Id recordId - Optional (use either recordId, recordTypeId, or objectName)
    * @param Id recordTypeId - Optional (use either recordId, recordTypeId, or objectName)
    * @param String objectName - Optional (use either recordId, recordTypeId, or objectName)
    * @return List<LayoutSection> - Sections, columns, and fields
    */
    @AuraEnabled 
    public static List<LayoutSection> loadPageLayoutFields(Id recordId, Id recordTypeId, String objectName) {

        List<LayoutSection> sections = new List<LayoutSection>();
        
        try {

            // Get user profile name
            Id profileId = UserInfo.getProfileId();
            String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId LIMIT 1].Name;
            System.debug('profileName: ' + profileName);

            // Get record type from recordId, recordTypeId, or default record type info for the object/user
            Id recTypeId = null;
            String recTypeName = '';
            String objectType = '';
            if(recordId != null) {
                objectType = recordId.getSObjectType().getDescribe().getName();
                List<SObject> objRecType = Database.query('SELECT Id, RecordTypeId FROM ' + objectType + ' WHERE Id = :recordId LIMIT 1');
                recTypeId = String.valueOf(objRecType[0].get('RecordTypeId'));
                System.debug('recTypeId from record: ' + recTypeId);
            } else if(recordTypeId != null) {
                recTypeId = recordTypeId;
                System.debug('recTypeId from component: ' + recTypeId);
            } else if(objectName != null && objectName != '') {
                SObjectType sobjType = Schema.getGlobalDescribe().get(objectName);
                Schema.DescribeSObjectResult dsr = sobjType.getDescribe();
                for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
                    if(rti.isDefaultRecordTypeMapping()) {
                        recTypeId = rti.getRecordTypeId();
                        System.debug('default recTypeId from object: ' + recTypeId);
                    }
                }
            } else {
                System.debug('ERROR: Could not find record type for this record or user');
                return null;
            }
            
            RecordType recType = [SELECT DeveloperName, SObjectType FROM RecordType WHERE Id = :recTypeId LIMIT 1];
            recTypeName = recType.DeveloperName;
            objectType = recType.SObjectType;
            System.debug('objectType: ' + objectType);
            System.debug('recTypeName: ' + recTypeName);

            // Get the layout name for this profile and record type from custom metadata
            String layoutName = [SELECT Page_Layout_Name__c 
                                 FROM IETRS_Edit_Page_Layout_Assignment__mdt 
                                 WHERE Object_API_Name__c = :objectType 
                                 AND Profile_Name__c = :profileName 
                                 AND Record_Type_API_Name__c = :recTypeName 
                                 LIMIT 1].Page_Layout_Name__c;
            layoutName = objectType + '-' + layoutName;
            System.debug('layoutName: ' + layoutName);

            // Use Metadata API to get layout details
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String> { layoutName });
            Metadata.Layout contLayout = (Metadata.Layout) components.get(0);
            System.debug('layout: ' + contLayout);
            
            // Get sections, columns, and fields
            for(Metadata.LayoutSection ls : contLayout.layoutSections) {
                System.debug('section: ' + ls.label);
                LayoutSection section = new LayoutSection(ls.label, ls.layoutColumns.size());
                List<LayoutColumn> columns = new List<LayoutColumn>();
                Integer maxFieldsInColumn = 0;

                for(Metadata.LayoutColumn lc : ls.layoutColumns) {
                    LayoutColumn column = new LayoutColumn();

                    // Check if there are fields available in that column
                    if(lc.layoutItems != null) { 

                        // Get the max number of fields in a column to preserve the alignment 
                        if(maxFieldsInColumn < lc.layoutItems.size()) {
                            maxFieldsInColumn = lc.layoutItems.size();
                        }
                        for(Metadata.LayoutItem li : lc.layoutItems) {
                            System.debug('---- field: ' + li.field);
                            column.fields.add(new LayoutField(li));
                        }
                    }

                    // No need to add a column in the section if there is no field available 
                    if(column.fields.size() > 0) {
                        columns.add(column);
                    }
                    
                }
                
                // Add columns and fields
                if(maxFieldsInColumn > 0) {
                    for(Integer i = 0; i < maxFieldsInColumn; i++) {
                        for(Integer j = 0; j < columns.size(); j++) {
                            if(columns[j].fields.size() > i) {
                                section.fields.add(columns[j].fields[i]);    
                            }    
                            else {
                                section.fields.add(new LayoutField());
                            }
                        }    
                    }    
                }
                
                sections.add(section);
            }
        }
        catch(Exception e) {
            System.debug('Error : ' + e.getMessage() + ' @ ' + e.getLineNumber());
        }
        return sections;
    }
    

    public class LayoutSection {   
	@AuraEnabled public String label;
    	@AuraEnabled public List<LayoutField> fields;
        @AuraEnabled public Integer totalColumns;
        public LayoutSection(String label, Integer totalColumns) {
	    this.label = label;
            this.totalColumns = totalColumns;
            this.fields = new List<LayoutField>();
        }
    }
    

    private class LayoutColumn {
    	private List<LayoutField> fields;    
        public LayoutColumn() {
            this.fields = new List<LayoutField>();
        }
    }
    

    public class LayoutField {
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public Boolean isReadOnly;
        
        public LayoutField() {}
        
        public LayoutField(Metadata.LayoutItem li) {
        	
            this.fieldName = li.field;
            if(li.behavior == Metadata.UiBehavior.Required) {
                this.isRequired = true;
            }
            else if(li.behavior == Metadata.UiBehavior.ReadOnly) {
                this.isReadOnly = true;
            }    
        }
    }
    
}