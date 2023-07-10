({

    handleInit : function(cmp, evt, h) {
        cmp.set('v.isLoading', true);
        h.fetchDistricts(cmp);
    },

    searchTypeChange : function (cmp) {
        let columns = [];
        switch(cmp.get('v.searchType')) {
            case 'Operators':
                columns = [
                    { label : 'Operator',   fieldName : 'operatorNumber',   type : 'text',  sortable : true, initialWidth: 110 },
                    { label : 'Name',       fieldName : 'operatorName',     type : 'text',  sortable : true },
                    { label : 'City',       fieldName : 'locationCity',     type : 'text',  sortable : true, initialWidth: 150 },
                    { label : 'Type',       fieldName : 'operatorType',     type : 'text',  sortable : true, initialWidth: 180 },
                    { label : 'Status',     fieldName : 'operatorStatus',   type : 'text',  sortable : true, initialWidth: 100 }
                ];
                cmp.set('v.placeholder', 'Enter operator name or P5 number to search');
                break;
            case 'Officers':
                columns = [
                    { label : 'Operator',   fieldName : 'operatorNumber',   type : 'text',  sortable : true, initialWidth: 110 },
                    { label : 'Name',       fieldName : 'officerName',      type : 'text',  sortable : true },
                    { label : 'Title',      fieldName : 'officerTitle',     type : 'text',  sortable : true, initialWidth: 180 },
                    { label : 'City',       fieldName : 'locationCity',     type : 'text',  sortable : true, initialWidth: 150 }
                ];
                cmp.set('v.placeholder', 'Enter P5 number to search');
                break;
            case 'Leases':
                columns = [
                    { label : 'Operator',   fieldName : 'operatorNumber',   type : 'text',  sortable : true, initialWidth: 110 },
                    { label : 'Lease #',    fieldName : 'leaseNumber',      type : 'text',  sortable : true, initialWidth: 110 },
                    { label : 'Name',       fieldName : 'leaseName',        type : 'text',  sortable : true },
                    { label : 'District',   fieldName : 'districtCode',     type : 'text',  sortable : true, initialWidth: 110 },
                    { label : 'Field Name', fieldName : 'fieldName',        type : 'text',  sortable : true },
                    { label : 'Field #',    fieldName : 'fieldNumber',      type : 'text',  sortable : true, initialWidth: 110 }
                ];
                cmp.set('v.placeholder', 'Enter lease number to search');
                break;
            case 'Wells':
                columns = [
                    { label : 'Operator',   fieldName : 'operatorNumber',   type : 'text',  sortable : true, initialWidth: 110 },
                    { label : 'Lease #',    fieldName : 'leaseNumber',      type : 'text',  sortable : true, initialWidth: 110 },
                    { label : 'Well #',     fieldName : 'wellNumber',       type : 'text',  sortable : true, initialWidth: 110 },
                    { label : 'API #',      fieldName : 'apiNumber',        type : 'text',  sortable : true, initialWidth: 110 },
                    { label : 'District',   fieldName : 'districtCode',     type : 'text',  sortable : true, initialWidth: 110 },
                    { label : 'County',     fieldName : 'county',           type : 'text',  sortable : true }
                ];
                cmp.set('v.placeholder', 'Enter lease number to search');
                break;
            case 'Drilling Permits':
                columns = [
                    { label : 'Permit #',       fieldName : 'drillingPermitNumber',         type : 'text',  sortable : true, initialWidth: 110 },
                    { label : '# of Versions',  fieldName : 'drillingPermitVersionCount',   type : 'number',sortable : true, initialWidth: 150 },
                    { label : 'Versions',       fieldName : 'drillingPermitVersions',       type : 'text',  sortable : true, initialWidth: 300 },
                    { label : 'Operator Name',  fieldName : 'operatorName',                 type : 'text',  sortable : true, initialWidth: 150 },
                    { label : 'Operator #',     fieldName : 'operatorNumber',               type : 'text',  sortable : true, initialWidth: 110 },
                    { label : 'Lease Name',     fieldName : 'leaseName',                    type : 'text',  sortable : true }
                ];
                cmp.set('v.placeholder', 'Enter permit number to search');
                break;
            case 'UIC':
                    columns = [
                    { label : 'API',                    fieldName : 'apiNumber',            type : 'text',  sortable : true, initialWidth: 180 },
                    { label : 'UIC Number',             fieldName : 'uicNumber',            type : 'text',  sortable : true, initialWidth: 180 },
                    { label : 'UIC Permit Number',      fieldName : 'uicPermitNumber',      type : 'text',  sortable : true, initialWidth: 200 },
                    { label : 'UIC Project Number',     fieldName : 'uicProjectNumber',     type : 'text',  sortable : true,  }
                    ];
                    cmp.set('v.placeholder', 'Enter API number to search');
                    break;
        }

        // // Details button
        // columns.push({ 
        //     type: 'button-icon', 
        //     fixedWidth: 50, 
        //     typeAttributes: {
        //         iconName : 'utility:description',
        //         name     : 'Details', 
        //         title    : 'Show Details', 
        //         disabled : false,
        //         variant  : 'bare'
        //     }
        // });
        cmp.set('v.columns', columns);

        cmp.set('v.searchText', '');
        cmp.set('v.results', []);
    },

    searchClick : function (cmp, evt, h) {
        console.log('searchClick()');
        h.search(cmp);
    },

    importClick : function(cmp, evt, h) {
        let selected = cmp.get('v.selected');
        
        if(selected.length > 0) {
            cmp.set('v.isImporting', true);
            h.import(cmp);
        } 
    },

    closeClick : function(cmp, evt, h) {
        cmp.destroy();
    },

    handleKeyUp : function(cmp, evt, h) {
        let isEnterKey = evt.keyCode === 13;
        if(isEnterKey) {
            console.log('handleKeyUp: enter pressed');
            h.search(cmp);
        }    
    },
    
    handleRowSelect : function(cmp, evt, h) {
        console.log('handleRowSelect()');
        cmp.set('v.selected', evt.getParam('selectedRows'));
    },

    handleRowAction: function (cmp, evt, h) {
        let action = evt.getParam('action');
        let row = evt.getParam('row');
        
        switch (action.name) {
            case 'show_details':
                console.log('Showing Details: ' + JSON.stringify(row));
                break;
            default:
                break;
        }
    },
    
    handleSort: function (cmp, evt, h) {
        let fieldName = evt.getParam('fieldName');
        let sortDirection = evt.getParam('sortDirection');
        cmp.set('v.sortedBy', fieldName);
        cmp.set('v.sortedDirection', sortDirection); // true=asc
        h.sortData(cmp, fieldName, sortDirection);
    },

})