({
	doInit : function(component, event, helper) {
          console.log('=======inside=====');
		helper.getAccontRecord(component, component.get("v.recordId"), helper); // Calling Helper method      
	},
     continueFlag : function(component, event, helper) {
         var orgmilesOldInput=component.get("v.oldInputMiles");
         var orgmilesNewInput=component.get("v.newInputMiles");
         var orgmiles=component.get("v.accountDetails").IETRS_Total_Miles__c;
         //var total=orgmilesOldInput+orgmilesNewInput;
         if(orgmilesOldInput!=null && orgmilesNewInput!=null){

             console.log('======inside==continue====');
             component.set("v.isFirstPage",false);
             component.set("v.isSecondPage",true);


         }else{
             helper.showToast(
                 component,
                 event,
                 helper,
                 'Error',
                 'Error',
                 'Please enter "Original Regulated Entity Total Miles" and "New Regulated Entity Total Miles"'
             );
         }
      },
    
      backFlag : function(component, event, helper) {
        console.log('============');
        component.set("v.isFirstPage",true);
        component.set("v.isSecondPage",false); 
    },
    
    dosplit : function(component, event, helper) {
        console.log('=====inside do split=======');
        
    },
    doSplit:function(component, event, helper) {
        helper.doSplit(component, event, helper);
    },
    
    unDo:function(component, event, helper) {
        
        console.log('=====inside undo=======');
               
               var countydisplay =[];
                var countiesRetrived = component.get("v.accountDetails").Miles_by_County__r;
                var countRec;
                for(var i=0; i< countiesRetrived.length; i++)
                {
                     countRec=     { 
                                       'sobjectType': 'IETRS_Insp_Miles_by_County__c',
                                         'Id':countiesRetrived[i].Id,
                                        'Name':countiesRetrived[i].Name,
                                        "countyName":countiesRetrived[i].IETRS_County__r.Name,
                                        "account":countiesRetrived[i].IETRS_Regulated_Entity__r.Name,
                                       'IETRS_Miles__c': countiesRetrived[i].IETRS_Miles__c,
                                       'IETRS_Regulated_Entity__c':countiesRetrived[i].IETRS_Regulated_Entity__c,
                                       'IETRS_County__c':countiesRetrived[i].IETRS_County__c
                                       
                                        }
                     
                     countydisplay.push(countRec);
                }
                
                component.set("v.counties", countydisplay);
                //component.set("v.counties",[]);
                component.set("v.countiesToDelete",[]);
        
    },
    addDeleteEntities : function(component, event, helper) {
        
         console.log('--clicked-',event.target.getAttribute("data-produto"));
         var countiName = event.target.getAttribute("data-produto");
         if(countiName != undefined)
         {
             var allCounties = [];
             var allDeletedCounties = [];
             var allCountiesAfterRemove = [];
            // allCounties = JSON.parse(JSON.stringify(component.get("v.counties")));
             allCounties = JSON.parse(JSON.stringify(component.get("v.counties")));
             
             for(var i=0; i< allCounties.length; i++)
             {
                 if(allCounties[i].Name != countiName )
                 {
                     allCounties[i].IETRS_Miles__c 
                     allCountiesAfterRemove.push(allCounties[i]);
                 }
                 else
                 {
                     allDeletedCounties.push(allCounties[i]);
                 }
             }
             
             if(allCountiesAfterRemove.length >= 0)
             {
                 console.log('--allCountiesAfterRemove===',allCountiesAfterRemove);
                  component.set("v.counties",allCountiesAfterRemove);
                
             }
             
             if(allCountiesAfterRemove.length >= 0)
             {
                  component.set("v.countiesToDelete",allDeletedCounties);
                 
             }
             
             console.log('===allCounties===',allCounties);
             
             
         }
        
        
       
    },
    
     addcountRecord: function (component, event, helper) { 
         console.log('-here------');
     
         
          //selectedObj =JSON.parse (SelectedObj);
         
        
        
        if(component.get("v.SelectedObj") != undefined && component.get("v.SelectedObj") != "")
        {
             var selectedObj =  JSON.parse(component.get("v.SelectedObj"));
             console.log('---SelectedObj---',selectedObj);
             //console.log('---SelectedObj---',selectedObj["Name"]);
             //console.log('---SelectedObj---',selectedObj.IETRS_Miles__c);
              var countiesRetrived =[];
           
               countiesRetrived = JSON.parse(JSON.stringify(component.get("v.counties")));
                var countRec;
               
                 countRec=     { 
                                       'sobjectType': 'IETRS_Insp_Miles_by_County__c',
                                         'Id':selectedObj.Id,
                                        'Name':selectedObj.Name,
                                       'IETRS_Miles__c':selectedObj.IETRS_Miles__c,
                                       'IETRS_Regulated_Entity__c':selectedObj.IETRS_Regulated_Entity__c,
                                        'IETRS_County__c':selectedObj.IETRS_County__c,
                                        "countyName":selectedObj.IETRS_County__r.Name,
                                        "account":selectedObj.IETRS_Regulated_Entity__r.Name
                                       
                                        }
                     
                  countiesRetrived.push(countRec);
                 
                
                 component.set("v.counties", countiesRetrived);
                 component.set("v.SelectedObj", "");
                var childComp = component.find('childComp');
               childComp.clearSelectedAttorney();
            
            
        }
     },
     getSelectedsourceRegRecord: function (component, event, helper) {
         
         var recordSelected = event.getParam("recordId");
         var SelectedObj = event.getParam("selectedObject");
         component.set("v.SelectedObj", SelectedObj);
        
     },
    getSelectedCountyRec: function (component, event, helper) {
         
         var recordSelected = event.getParam("recordId"); 
		     
         component.set("v.accountDetails.IETRS_County__c", recordSelected);
        console.log('get county ->',component.get("v.accountDetails.IETRS_County__c"));
        
     },
    getSelectedRegion: function (component, event, helper) {
         
         var recordSelected = event.getParam("recordId"); 
		     
         component.set("v.accountDetails.IETRS_Region__c", recordSelected);
        console.log('get region ->',component.get("v.accountDetails.IETRS_Region__c"));
        
     }
    
        
    
})