({
    /*
     * @Description: - Create a Map and put all the inputtype
     * : - with attribute and then use this map while creating the fieldsets.
     * Available inputs for "lightning:input" are below
     * checkbox, date, datetime, email, file, password, search, tel, url, number, radio, and toggle
     */

    configMap: {
        string: {
            componentDef: 'lightning:input',
            attributes: {}
        },
        DateRange: {
            componentDef: 'c:DateRangecmp',
            attributes: {}
        },
        checkbox: {
            componentDef: 'lightning:input',
            attributes: {
                // prettier-ignore
                'class': 'slds-checkbox__label'
            }
        },
        button: {
            componentDef: 'lightning:button',
            attributes: {
                variant: 'brand',
                iconName: 'utility:automate',
                label: 'Submit Form'
            }
        },
        picklist: {
            componentDef: 'ui:inputSelect',
            attributes: {
                // prettier-ignore
                'class': 'slds-select slds-select_container ',
                style: ' width: 395px;'
            }
        },
        multipicklist: {
            componentDef: 'lightning:dualListbox',
            attributes: {
                sourceLabel: 'Available Options',
                selectedLabe: 'Selected Options',
                readonly: false
            }
        },
        textarea: {
            componentDef: 'lightning:textarea',
            attributes: {
                // prettier-ignore
                'class': 'slds-input container'
            }
        },
        lookup: {
            componentDef: 'lightning:combobox',
            attributes: {}
        }
    },
    fieldSetMember: '',
    onInit: function(component, event, helper) {
        var getSobject = component.get('c.getsObjects');
        getSobject.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')) {
                var sObjectList = response.getReturnValue();

                var listOptions = [];
                listOptions.push({
                    label: '--Select One--',
                    value: ''
                });
                for (var i = 0; i < sObjectList.length; i++) {
                    listOptions.push({
                        label: sObjectList[i].split('####')[1],
                        value: sObjectList[i].split('####')[0]
                    });
                }
                component.set('v.sObjectList', listOptions);
            } else if (state === 'INCOMPLETE') {
                console.log('User is Offline System does not support drafts ' + JSON.stringify(response.getError()));
            } else if (state === 'ERROR') {
            } else {
            }

            component.set('v.loading', false);
        });
        //getSobject.setStorable();
        $A.enqueueAction(getSobject);
    },

    onFieldSetChange: function(component, event, helper) {
        var objectName = component.get('v.sObjectName');
        //Object.keys(objectName).forEach(function(k) { delete objectName[k]});
        component.set('v.sObjectName', {});
        var self = this;
        var selectedObject = component.find('selectObject').get('v.value');
        //alert(JSON.stringify(selectedObject));

        var FiledSetMember = component.get('c.getFieldSetMember');
        FiledSetMember.setParams({
            objectName: selectedObject
        });
        FiledSetMember.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')) {
                var resp = response.getReturnValue();
                if (resp === '[]') {
                    var form = [];
                    component.set('v.theForm', form);
                    component.set('v.resultList', null);
                } else {
                    this.fieldSetMember = JSON.parse(resp);
                    self.createForm(component, event, helper, this.fieldSetMember);
                }
            } else if (state === 'INCOMPLETE') {
                console.log('User is Offline System does not support drafts ' + JSON.stringify(response.getError()));
            } else if (state === 'ERROR') {
                console.log(response.getError());
            } else {
            }
            component.set('v.loading', false);
        });
        ///FiledSetMember.setStorable();
        $A.enqueueAction(FiledSetMember);
    },
    createForm: function(component, event, helper, fieldSetMember) {
        // Create a map with availale inputs and according to this use the global map.
        var lightningInputMap = new Map();
        lightningInputMap.set('string', 'string');
        lightningInputMap.set('checkbox', 'checkbox');
        lightningInputMap.set('date', 'date');
        lightningInputMap.set('datetime', 'datetime');
        lightningInputMap.set('email', 'email');
        lightningInputMap.set('file', 'file');
        lightningInputMap.set('password', 'password');
        lightningInputMap.set('search', 'search');
        lightningInputMap.set('tel', 'tel');
        lightningInputMap.set('url', 'url');
        lightningInputMap.set('number', 'number');
        lightningInputMap.set('radio', 'radio');
        lightningInputMap.set('text', 'text');

        // list of components to create and put into the component body..
        var inputDesc = [];
        var config = null;

        /*
         * parse the FieldSet members and then create the members dynamically
         * and put those components into the component.
         */

        for (var i = 0; i < fieldSetMember.length; i++) {
            var objectName = component.getReference('v.sObjectName');
            if (lightningInputMap.has(fieldSetMember[i].fieldType.toLowerCase())) {
                config = JSON.parse(JSON.stringify(this.configMap['string']));
                if (config) {
                    if (fieldSetMember[i].fieldType == 'Date') {
                        if (fieldSetMember[i].showStartDate) {
                            let labelSuffix = fieldSetMember[i].showEndDate ? ' - On or After' : '';
                            config.attributes.label = fieldSetMember[i].fieldLabel + labelSuffix;
                            config.attributes.type = fieldSetMember[i].fieldType;
                            config.attributes.required = fieldSetMember[i].isRequired || fieldSetMember[i].isDBRequired;
                            config.attributes.value = component.getReference(
                                'v.sObjectName.' + fieldSetMember[i].fieldAPIName
                            );
                            inputDesc.push([config.componentDef, config.attributes]);
                        }
                        if (fieldSetMember[i].showEndDate) {
                            let labelSuffix = fieldSetMember[i].showStartDate ? ' - On or Before' : '';
                            config = JSON.parse(JSON.stringify(this.configMap['string']));
                            config.attributes.label = fieldSetMember[i].fieldLabel + labelSuffix;
                            config.attributes.type = fieldSetMember[i].fieldType;
                            config.attributes.required = fieldSetMember[i].isRequired || fieldSetMember[i].isDBRequired;
                            config.attributes.value = component.getReference(
                                'v.sObjectName.' + fieldSetMember[i].fieldAPIName + '_E'
                            );
                            inputDesc.push([config.componentDef, config.attributes]);
                        }
                    } else {
                        config.attributes.label = fieldSetMember[i].fieldLabel;
                        config.attributes.type = fieldSetMember[i].fieldType;
                        config.attributes.required = fieldSetMember[i].isRequired || fieldSetMember[i].isDBRequired;
                        config.attributes.value = component.getReference(
                            'v.sObjectName.' + fieldSetMember[i].fieldAPIName
                        );
                        inputDesc.push([config.componentDef, config.attributes]);
                    }
                }
            } else {
                if (fieldSetMember[i].fieldType.toLowerCase() === 'integer') {
                    config = JSON.parse(JSON.stringify(this.configMap['string']));
                    config.attributes.label = fieldSetMember[i].fieldLabel;
                    config.attributes.type = 'number';
                    config.attributes.required = fieldSetMember[i].isRequired || fieldSetMember[i].isDBRequired;
                    config.attributes.value = component.getReference('v.sObjectName.' + fieldSetMember[i].fieldAPIName);
                    inputDesc.push([config.componentDef, config.attributes]);
                } else if (fieldSetMember[i].fieldType.toLowerCase() === 'phone') {
                    config = JSON.parse(JSON.stringify(this.configMap['string']));
                    config.attributes.label = fieldSetMember[i].fieldLabel;
                    config.attributes.type = 'tel';
                    config.attributes.required = fieldSetMember[i].isRequired || fieldSetMember[i].isDBRequired;
                    config.attributes.value = component.getReference('v.sObjectName.' + fieldSetMember[i].fieldAPIName);

                    inputDesc.push([config.componentDef, config.attributes]);
                } else if (fieldSetMember[i].fieldType.toLowerCase() === 'textarea') {
                    config = JSON.parse(JSON.stringify(this.configMap['textarea']));
                    config.attributes.label = fieldSetMember[i].fieldLabel;
                    config.attributes.name = fieldSetMember[i].fieldLabel;

                    config.attributes.required = fieldSetMember[i].isRequired || fieldSetMember[i].isDBRequired;
                    config.attributes.value = component.getReference('v.sObjectName.' + fieldSetMember[i].fieldAPIName);

                    inputDesc.push([config.componentDef, config.attributes]);
                } else if (fieldSetMember[i].fieldType.toLowerCase() === 'picklist') {
                    config = JSON.parse(JSON.stringify(this.configMap['picklist']));
                    config.attributes.label = fieldSetMember[i].fieldLabel;
                    config.attributes.name = fieldSetMember[i].fieldLabel;
                    var pickList = fieldSetMember[i].pickListValues;
                    var options = [];
                    options.push({
                        value: '',
                        label: '--Select a value--'
                    });
                    for (var k = 0; k < pickList.length; k++) {
                        if (pickList[k].active) {
                            options.push({
                                value: pickList[k].value,
                                label: pickList[k].label
                            });
                        }
                    }
                    config.attributes.options = options;
                    config.attributes.required = fieldSetMember[i].isRequired || fieldSetMember[i].isDBRequired;
                    config.attributes.value = component.getReference('v.sObjectName.' + fieldSetMember[i].fieldAPIName);

                    inputDesc.push([config.componentDef, config.attributes]);
                } else if (fieldSetMember[i].fieldType.toLowerCase() === 'multipicklist') {
                    config = JSON.parse(JSON.stringify(this.configMap['multipicklist']));
                    config.attributes.label = fieldSetMember[i].fieldLabel;
                    config.attributes.name = fieldSetMember[i].fieldLabel;
                    var pickList = fieldSetMember[i].pickListValues;
                    var options = [];
                    for (var k = 0; k < pickList.length; k++) {
                        if (pickList[k].active) {
                            options.push({
                                value: pickList[k].value,
                                label: pickList[k].label
                            });
                        }
                    }
                    config.attributes.options = options;
                    config.attributes.required = fieldSetMember[i].isRequired || fieldSetMember[i].isDBRequired;
                    config.attributes.value = component.getReference('v.sObjectName.' + fieldSetMember[i].fieldAPIName);
                    /*
                    inputDesc.push([
                        config.componentDef,
                        config.attributes
                    ]);*/
                } else if (fieldSetMember[i].fieldType.toLowerCase() === 'lookup') {
                    var lookupConfig = JSON.parse(JSON.stringify(this.configMap.lookup));
                    lookupConfig.attributes.label = fieldSetMember[i].fieldLabel;
                    lookupConfig.attributes.name = fieldSetMember[i].fieldLabel;
                    lookupConfig.attributes.options = fieldSetMember[i].lookupOptions;
                    lookupConfig.attributes.required = fieldSetMember[i].isRequired || fieldSetMember[i].isDBRequired;
                    lookupConfig.attributes.value = component.getReference(
                        'v.sObjectName.' + fieldSetMember[i].fieldAPIName
                    );
                    inputDesc.push([lookupConfig.componentDef, lookupConfig.attributes]);
                }
            }
        }

        $A.createComponents(inputDesc, function(components, status, errorMessage) {
            if (status === 'SUCCESS') {
                var form = [];
                for (var j = 0; j < components.length; j++) {
                    form.push(components[j]);
                }
                component.set('v.theForm', form);
            } else if (status === 'INCOMPLETE') {
                console.log('No response from server or client is offline.');
            } else if (status === 'ERROR') {
                console.log('Error: ' + errorMessage);
                console.log(errorMessage);
            }
        });
    },
    onSearchData: function(component, event, helper) {
        var selectedObject = component.find('selectObject').get('v.value');

        var objectName = component.get('v.sObjectName');
        var action = component.get('c.displayObjResults');
        // add the start date api name if only an end date is provided
        console.log('objectName::'+objectName);
        for (let prop in objectName) {
            // ends with _E
            console.log('prop'+prop);
            if (prop.lastIndexOf('_E') === prop.length - 2) {
                // if the start date is not provided
                let startDateName = prop.slice(0, prop.lastIndexOf('_E'));
                if (!objectName[startDateName]) {
                    objectName[startDateName] = '';
                }
            }
        }
        action.setParams({
            objName: selectedObject,
            filterJSON: JSON.stringify(objectName)
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var myWrap = response.getReturnValue();
                var mapCols = myWrap.mapCols;
                component.set('v.columnsByFieldName', mapCols);
                var first = true;
                var colmns = [];
                for (var key in mapCols) {
                    if (first) {
                        first = false;
                        colmns.push({
                            label: mapCols[key].label,
                            fieldName: 'linkName',
                            type: 'url',
                            sortable: true,
                            typeAttributes: { label: { fieldName: key }, target: '_blank' }
                        });
                    } else {
                        colmns.push({
                            label: mapCols[key].label,
                            fieldName: key,
                            type: mapCols[key].type,
                            sortable: true
                        });
                    }
                }

                component.set('v.colList', colmns);  console.log('#########colmns',colmns);

                var records = myWrap.lstRecords;

                records.forEach(function(record) {
                    record.linkName = '/' + record.Id;
                });

                component.set('v.resultList', records);
            } else {
                var toastEvent = $A.get('e.force:showToast');
                var errors = response.getError();
                var message = 'Unknown error';
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                    if (message.includes('CPU time limit')) {
                        message =
                            'Your search returned too many records to display on this page. Please narrow your search criteria or create a report.';
                    }
                }
                toastEvent.setParams({
                    title: 'Error',
                    message: message,
                    type: 'error'
                });
                toastEvent.fire();
            }
            component.set('v.loading', false);
            component.set('v.hasSearched', true);
        });

        $A.enqueueAction(action);
    },
    onResetPage: function(component, event, helper) {
        component.set('v.loading', true);
        this.onFieldSetChange(component, event, helper);
        //component.set("v.theForm", form);
        component.set('v.resultList', null);
        //component.set("v.sObjText","");
    }
});