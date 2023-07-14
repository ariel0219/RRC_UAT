({

    fetchDistricts : function(cmp) {
        let action = cmp.get('c.loadDistricts');
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS') {
                let results = response.getReturnValue();
                if(results) {
                    console.log('districts', JSON.stringify(results));
                    cmp.set('v.districtOptions', results);
                }
            } else {
                this.showToast(cmp, 'error', 'Error Loading Districts', 'Please refresh the page to try again.');
            }
            cmp.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    search : function(cmp) {
        console.log('search()');
        
        let valid = cmp.find('mfInput').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if(valid) {
            cmp.set('v.isLoading', true);
        
            cmp.find('dataTable').set('v.selectedRows', null);
            
            switch(cmp.get('v.searchType')) {
                case 'Operators':
                    var action = cmp.get('c.searchOperators');
                    action.setParams({
                        'searchString' : cmp.get('v.searchText')
                    });
                    break;
                case 'Officers':
                    var action = cmp.get('c.searchOfficers');
                    action.setParams({
                        'operatorNumber' : cmp.get('v.searchText')
                    });
                    break;
                case 'Leases':
                    var action = cmp.get('c.searchLeases');
                    action.setParams({
                        'leaseNumber' : cmp.get('v.searchText'),
                        'districtCode' : cmp.get('v.districtCode')
                    });
                    break;
                case 'Wells':
                    var action = cmp.get('c.searchWells');
                    action.setParams({
                        'leaseNumber' : cmp.get('v.searchText'),
                        'districtCode' : cmp.get('v.districtCode')
                    });
                    break;
                case 'Drilling Permits':
                    var action = cmp.get('c.searchDrillingPermits');
                    action.setParams({
                        'drillingPermitNumber' : cmp.get('v.searchText')
                    });
                    break;
                case 'UIC':
                        var action = cmp.get('c.searchUIC');
                        action.setParams({
                            'apiNumber' : cmp.get('v.searchText')
                        });
                        break;
            }
            
            action.setCallback(this, function(response) {
                let state = response.getState();
                if(state === 'SUCCESS') {
                    let results = response.getReturnValue();
                    if(results) {
                        console.log('mfResults', JSON.parse(results));
                        cmp.set('v.results', JSON.parse(results));
                    }
                } else {
                    this.showToast(cmp, 'error', 'Error Loading Mainframe Results', 'Please refresh the page to try again.');
                }
                cmp.set('v.isLoading', false);
            });
            $A.enqueueAction(action);
        }
    },

    import : function(cmp) {
        let selected = cmp.get('v.selected'),
            searchType = cmp.get('v.searchType'),
            action;
        
        console.log('selected', selected);
        console.log('searchType', searchType);

        if(selected && searchType) {
            let selectedJSON = JSON.stringify(selected);
            console.log('selectedJSON', selectedJSON);
            
            switch(searchType) {
                case 'Operators':
                    action = cmp.get('c.addSingleOperatorWithoutUpdatingOfficer');
                    action.setParams({
                        'operatorsJSON' : '{"Operators":' + selectedJSON + '}'
                    });
                    break;
                case 'Officers':
                    action = cmp.get('c.addOfficers');
                    action.setParams({
                        'officersJSON' : '{"Officers":' + selectedJSON + '}'
                    });
                    break;
                case 'Leases':
                    action = cmp.get('c.addLeases');
                    action.setParams({
                        'leasesJSON' : '{"Leases":' + selectedJSON + '}'
                    });
                    break;
                case 'Wells':
                    action = cmp.get('c.addWells');
                    action.setParams({
                        'wellsJSON' : '{"Wells":' + selectedJSON + '}'
                    });
                    break;
                case 'Drilling Permits':
                    action = cmp.get('c.addDrillingPermits');
                    action.setParams({
                        'drillingPermitsJSON' : selectedJSON
                    });
                    break;
                case 'UIC':
                    action = cmp.get('c.addUIC');
                    action.setParams({
                        'uicJSON' : '{"uicinfo":' + selectedJSON + '}'
                    });
                    break;
            }

            action.setCallback(this, function(response) {
                let state = response.getState();
                if(state === 'SUCCESS') {
                    let results = response.getReturnValue();
                    if(results) {
                        console.log('importResults', JSON.stringify(results, null, 4));
                        this.showToast(cmp, 'success', 'Import Successful', 'The import was successful. You can now search for the new record.');
                        cmp.destroy();
                    }
                } else {
                    this.showToast(cmp, 'error', 'Import Error', 'Please refresh the page to try again.');
                }
                cmp.set('v.isImporting', false);
            });
            $A.enqueueAction(action);
        }
    },

    sortData : function (cmp, fieldName, sortDirection) {
        let data = cmp.get('v.results');
        let reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set('v.results', data);
    },

    sortBy: function (field, reverse, primer) {
        let key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
        }
    },

    showToast : function(cmp, type, title, message) {
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'type'    : type, 
            'title'   : title,
            'message' : message
        });
        toastEvent.fire();
    },
})