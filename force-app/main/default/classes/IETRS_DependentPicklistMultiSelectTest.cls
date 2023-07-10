@istest
public with sharing class IETRS_DependentPicklistMultiSelectTest {

    static string objectApiName='Account';
    static string controllingField='Industry';
    static string dependentField='Type';
    
    testmethod static void getfieldDepedencyMapTest(){
        //Object Postive test
        IETRS_DepPickMultiSelectController.getFieldDependencyMap(objectApiName, controllingField, dependentField);
        
        //Object Negative Test
        IETRS_DepPickMultiSelectController.getFieldDependencyMap(null, 'controllingField', dependentField);
        
        //Field Negative
        IETRS_DepPickMultiSelectController.getFieldDependencyMap(objectApiName, 'NonExistentField', dependentField);
    }
    
    testmethod static void wrapperClassesTest(){
        
        //PicklistEntryWrapper
        IETRS_DepPickMultiSelectController.PicklistEntryWrapper obj1 = new IETRS_DepPickMultiSelectController.PicklistEntryWrapper();
        obj1.active='Yes';
        obj1.defaultValue='';
        obj1.value='';
        
        //recordTypeWrapper
        IETRS_DepPickMultiSelectController.recordTypeWrapper obj3 = new IETRS_DepPickMultiSelectController.recordTypeWrapper(null,null,null,true);
        //obj3.incorrectApiName=true;
        //obj3.rtId='';
        //obj3.rtIsMaster=false;
        //obj3.rtName='';
        
        //picklistValues
        IETRS_DepPickMultiSelectController.piclistValues obj4 = new IETRS_DepPickMultiSelectController.piclistValues();
        obj4.label='';
        obj4.value='';
        IETRS_DepPickMultiSelectController.piclistValues[] picklistvalueList = new IETRS_DepPickMultiSelectController.piclistValues[]{};
        picklistvalueList.add(obj4);
        
        //picklistWrapper
        IETRS_DepPickMultiSelectController.picklistWrapper obj2 = new IETRS_DepPickMultiSelectController.picklistWrapper();
        obj2.values=picklistvalueList;
    }
    
    testmethod static void getRecordtypesTest(){
        //Postive Test
        IETRS_DepPickMultiSelectController.getRecordTypes(objectApiName);
        
        //Negative Test: No object
        IETRS_DepPickMultiSelectController.getRecordTypes('');
        
        //Negative Test: No record type
        IETRS_DepPickMultiSelectController.getRecordTypes('AccountTeamMember');
        
    }
    
    testmethod static void isfieldMSPtypeTest(){
        IETRS_DepPickMultiSelectController.isfieldMSPtype('Account','Industry');
    }
    
    testmethod static void getPicklistValuesTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IETRS_DependentPicklistMultiSelectMock());
        IETRS_DepPickMultiSelectController.getPicklistValues('', '', '');
        Test.stopTest();
    }
 
}