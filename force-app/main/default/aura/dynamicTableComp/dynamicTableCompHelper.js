({
    sortBy: function(field, reverse, fieldType) {
        var key = function(x) {
            var val = x[field];
            switch (fieldType) {
                case 'currency':
                case 'number':
                case 'percent':
                    val = parseFloat(val || 0);
                    break;
                case 'date':
                case 'date-local':
                    val = +new Date(val) || 0;
                    break;
                default:
                    val = isNaN(parseFloat(val)) ? val || '' : parseFloat(val);
                    break;
            }
            return val;
        };
        
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },
    
    handleSort: function(cmp, evt) {
        var sortedBy = evt.getParam('fieldName');
        var sortDirection = evt.getParam('sortDirection');
        var columnsByFieldName = cmp.get('v.columnsByFieldName') || {};
        var fieldType = (columnsByFieldName[sortedBy] || {}).type || 'text';
        var cloneData = (cmp.get('v.dataList') || []).slice(0);
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1, fieldType));
        cmp.set('v.dataList', cloneData);
        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
    },
    
    convertArrayOfObjectsToCSV : function(component, objectRecords){
        
        var csvStringResult, counter, columnDivider, lineDivider, keylabel, keys;
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        
        columnDivider = ',';
        lineDivider =  '\n';
        
        console.log('objectRecords####', objectRecords);
        var keys = new Set();
        objectRecords.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                if(key !== 'Id' && key !== 'linkName')
                    keys.add(key);
            });
        });    
        
        keys = Array.from(keys);      
        console.log('FieldNameList#####', keys);
        if(component.get("v.sObjText") === 'IETRS_Complaint__c')
            var keylabel = ['Complaint ID','Received Date','Complaint Type','Complaint Processing Status','Complainant Name','Complaint Resolution Status','Description Type',
                            'Explanation Type','Close Date','City','Lead Inspector','Region'];   
        
        if(component.get("v.sObjText") === 'IETRS_Incident__c')
            var keylabel = ['Incident ID','Incident Date','Organization ID','Organization Name','Status','Inspector Name','Regulated Entity ID','Regulated Entity Name','County','Region','Injuries','Fatalities']; 
        
        if(component.get("v.sObjText") === 'IETRS_Inspection_Package__c')
            var keylabel = ['Package ID','Status','Inspection Type','Inspection Package Sub-Type','Begin Date','End Date','Organization ID','Organization','Unit Name','Unit ID','Lead Inspector'];
        
        
        if(component.get("v.sObjText") === 'IETRS_Inspection__c')
            var keylabel = ['Inspection ID','Inspection Package ID','Inspection Package Type','Inspection Package Sub-Type','Entity ID at Eval','Entity Name at Eval','Organization ID',
                            'Entity Code at Eval','Organization Name','Inspection Status','T4 Permit at Eval','Begin Date','End Date','Lead Inspector']; 
        
        
        csvStringResult = '';
        csvStringResult += keylabel.join(columnDivider); console.log('csvStringResult####', csvStringResult);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;
                
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }    
                
                var value = objectRecords[i][skey] === undefined ? '' : objectRecords[i][skey];
                if(value.includes('"'))
                {
                    // var ky='IETRS_EntityNameAtEval__c';
                    //var kyy='IETRS_Inspection_Package__r.IETRS_Organization_ID__c';
                   // console.log('value:5:'+objectRecords[i][ky]);
                   // console.log('value:6:'+objectRecords[i][kyy]); 
                   
                    var splitVal=value.split('"');
                        var tempVal='"';
                        for(var l=0;l<splitVal.length-1;l++)
                            {
                               tempVal+=splitVal[l]+'""'; 
                            }
                       tempVal+=splitVal[splitVal.length-1]+'"';
                        console.log('tempVal:'+tempVal);
                      csvStringResult += tempVal;   
                    //csvStringResult += '"'+ value +''; 
                    
                }
                else
                {
                  csvStringResult += '"'+ value +'"';   
                }
                
                counter++;
                
            } 
            csvStringResult += lineDivider;
        }
        
        return csvStringResult;        
    },
    
    
});