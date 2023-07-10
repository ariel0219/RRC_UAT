import { LightningElement, api, wire } from 'lwc';

/** Events  */
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**Apex Methods*/

import getContactRepsRecords_Organization from '@salesforce/apex/IETRS_Contact_Detail_Controller.getContactsByParentId_Organization';

import getContactRepsRecords_Unit from '@salesforce/apex/IETRS_Contact_Detail_Controller.getContactsByParentId_Unit';

import getContactRepsRecords_InspectionPackage from '@salesforce/apex/IETRS_Contact_Detail_Controller.getContactsByParentId_InspectionPackage';

import createCorrespondence_Mailing_Org from '@salesforce/apex/IETRS_Contact_Detail_Controller.createCorrespondence_Mailing_Org';

import createCorrespondence_Mailing_Unit from '@salesforce/apex/IETRS_Contact_Detail_Controller.createCorrespondence_Mailing_Unit';

import createCorrespondence_Mailing_InspectionPackage from '@salesforce/apex/IETRS_Contact_Detail_Controller.createCorrespondence_Mailing_InspectionPackage';

export default class ContactDetailForAddRep extends LightningElement {
    @api sobjectId = '';
    @api recordId; //This Will have current Record

    value = '';
    contactResps;

    OrgName = '';
    UnitName = '';
    IpName = '';


    @api contactsUnderOrganization;
    @api contactsUnderUnit;
    @api contactsUnderInspectionPackage;


    //tempListToHandleCheckBoxLogic = [];

    listOfcontactsWithEmailOptions_Orgs_To = [];
    listOfcontactsWithEmailOptions_Orgs_CC = [];
    //finallistOfcontactsWithEmailOptions_Orgs_To_CC = []; // Final list on Save from Component to Apex

    listOfcontactsWithEmailOptions_Units_To = [];
    listOfcontactsWithEmailOptions_Units_CC = [];
    //finallistOfcontactsWithEmailOptions_Units_To_CC = [];// Final list on Save from Component to Apex

    listOfcontactsWithEmailOptions_IPs_To = [];
    listOfcontactsWithEmailOptions_IPs_CC = [];
    //finallistOfcontactsWithEmailOptions_IPs_To_CC = []; // Final list on Save from Component to Apex

    closeQuickAction() {
        // this.dispatchEvent(new CloseActionScreenEvent()); // this will only when the lwc is directly used in quickAction
        let closeAction = true;
        const sendDataEvent = new CustomEvent('closeAction', {
            detail: { closeAction }
        });

        //Actually dispatching the event that we created above.
        this.dispatchEvent(sendDataEvent);
    }


    saveQucikActionHandler(){
        let saveAction = true;
        const sendDataEvent = new CustomEvent('saveAction', {
            detail: { saveAction }
        });

        //Actually dispatching the event that we created above.
        this.dispatchEvent(sendDataEvent);
    }
    showErrorToast(title, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showSuccessToast(title, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    get options() {
        return [
            { label: 'To', value: 'option1' },
            { label: 'CC', value: 'option2' },
        ];
    }

    @wire(getContactRepsRecords_Organization, { recordId: '$recordId' })
    getContactDetails_Organization(result) {
        console.log('Contact result Data => ' + result.data);
        if (result.data) {
            this.contactsUnderOrganization = result.data;
            this.OrgName = this.contactsUnderOrganization[0]?.Account?.Name;
            console.log('Contact result Data => ' + this.contactResps);
        } else if (result.error) {
            this.contactsUnderOrganization = undefined;
            console.log(result.error);
        }
    }


    @wire(getContactRepsRecords_Unit, { recordId: '$recordId' })
    getContactDetails_Unit(result) {
        console.log('Contact result Data => ' + result.data);
        if (result.data) {
            this.contactsUnderUnit = result.data;
            this.UnitName = this.contactsUnderUnit[0]?.Account?.Name;
            console.log('Contact result Data => ' + this.contactResps);
        } else if (result.error) {
            this.contactsUnderUnit = undefined;
            console.log(result.error);
        }
    }


    @wire(getContactRepsRecords_InspectionPackage, { recordId: '$recordId' })
    getContactDetails_InspectionPackage(result) {
        console.log('Contact result Data => ' + result.data);
        if (result.data) {
            this.contactsUnderInspectionPackage = result.data;
            this.IpName = this.contactsUnderInspectionPackage[0]?.IETRS_Inspection_Package__r?.Name
            console.log('Contact result Data => ' + this.contactResps);
        } else if (result.error) {
            this.contactsUnderInspectionPackage = undefined;
            console.log(result.error);
        }
    }

    handleChangeRadio(event) {
        console.log('event.detail.checked', event.target.checked);
        console.log('event.detail.checked', event.target.dataset.value);
        this.value = event.target.dataset.value;
        var idvalue = this.templatethis.template.querySelector('segDiv').key;
        console.log(idvalue);
        console.log('=>' + this.value)
        this.options.forEach(opt => {
            if (opt.value === this.value) {
                opt.checked = true;
            } else {
                opt.checked = false;
            }
        });
    }

    //Checkbox event Handler for To Org
    handleToCheckBox_Org(event) {
        console.log('To-Org' + event.target.checked);
        console.log('To-Org' + event.target.value);
        if (event.target.checked === true) {
            //When then list has  Items 
            /*  let allselectedCheckbox = this.template.querySelectorAll('.orgTo');
              /* for (let acheckBox of allselectedCheckbox) {
                   if (acheckBox.checked === true) {
                       console.log('DataSet' + JSON.stringify(acheckBox.dataset));*/
            if (this.listOfcontactsWithEmailOptions_Orgs_To.length > 0) {
                for (let i = 0; i < this.listOfcontactsWithEmailOptions_Orgs_To.length; i++) {
                    console.log('LoopStarted');
                    console.log(event.target.value);
                    console.log(this.listOfcontactsWithEmailOptions_Orgs_To[i]);
                    console.log('LoopValue' + this.listOfcontactsWithEmailOptions_Orgs_To[i].recordId);
                    console.log('TargetValue' + event.target.value);
                    console.log('Loopvalue' + this.listOfcontactsWithEmailOptions_Orgs_To[i].To);
                    console.log('TargetValue' + event.target.checked);
                    if (this.listOfcontactsWithEmailOptions_Orgs_To[i].recordId === event.target.value) {
                        this.listOfcontactsWithEmailOptions_Orgs_To[i].To = event.target.checked;
                    } else {
                        var ismatchFound = false;
                        for (let j = 0; j < this.listOfcontactsWithEmailOptions_Orgs_To.length; j++) {
                            if (this.listOfcontactsWithEmailOptions_Orgs_To[j].recordId === event.target.value) {
                                this.listOfcontactsWithEmailOptions_Orgs_To[i].To = event.target.checked;
                                ismatchFound = true;
                            }
                        }

                        if (ismatchFound === false) {
                            this.listOfcontactsWithEmailOptions_Orgs_To.push({ recordId: event.target.value, To: event.target.checked });
                        }
                    }
                }
                console.log('loopEnded' + JSON.stringify(this.listOfcontactsWithEmailOptions_Orgs_To));
            } else {
                this.listOfcontactsWithEmailOptions_Orgs_To.push({ recordId: event.target.value, To: event.target.checked });
            }
            /* }
         }*/
            console.log(JSON.stringify(this.listOfcontactsWithEmailOptions_Orgs_To));
        } else {
            //console.log('DataSet' + JSON.stringify(acheckBox.dataset));
            if (this.listOfcontactsWithEmailOptions_Orgs_To.length > 0) {
                console.log('else block=> 01' + JSON.stringify(this.listOfcontactsWithEmailOptions_Orgs_To));
                for (let i = 0; i < this.listOfcontactsWithEmailOptions_Orgs_To.length; i++) {
                    console.log('else block=> 02' + JSON.stringify(this.listOfcontactsWithEmailOptions_Orgs_To));
                    console.log('index' + '' + i + '\n' + this.listOfcontactsWithEmailOptions_Orgs_To[i]);
                    if (this.listOfcontactsWithEmailOptions_Orgs_To[i].recordId === event.target.value) {
                        console.log('index' + 'Inside Condition' + i);
                        //this.listOfcontactsWithEmailOptions_Orgs_To[i].pop();
                        this.listOfcontactsWithEmailOptions_Orgs_To[i].To = event.target.checked;
                    }
                }
            } else {
                this.listOfcontactsWithEmailOptions_Orgs_To = [];
            }
            console.log('else block=>' + JSON.stringify(this.listOfcontactsWithEmailOptions_Orgs_To));
        }


        console.log('final=>' + JSON.stringify(this.listOfcontactsWithEmailOptions_Orgs_To));
    }

    //Checkbox event Handler for CC Org
    handleCCCheckBox_Org(event) {
        console.log('CC-Org' + event.target.checked);
        console.log('CC-Org' + event.target.value);
        if (event.target.checked === true) {
            if (this.listOfcontactsWithEmailOptions_Orgs_CC.length > 0) {
                for (let i = 0; i < this.listOfcontactsWithEmailOptions_Orgs_CC.length; i++) {
                    console.log('LoopStarted');
                    console.log(event.target.value);
                    console.log(this.listOfcontactsWithEmailOptions_Orgs_CC[i]);
                    console.log('LoopValue' + this.listOfcontactsWithEmailOptions_Orgs_CC[i].recordId);
                    console.log('TargetValue' + event.target.value);
                    console.log('Loopvalue' + this.listOfcontactsWithEmailOptions_Orgs_CC[i].CC);
                    console.log('TargetValue' + event.target.checked);
                    if (this.listOfcontactsWithEmailOptions_Orgs_CC[i].recordId === event.target.value) {
                        this.listOfcontactsWithEmailOptions_Orgs_CC[i].CC = event.target.checked;
                    } else {
                        var ismatchFound = false;
                        for (let j = 0; j < this.listOfcontactsWithEmailOptions_Orgs_CC.length; j++) {
                            if (this.listOfcontactsWithEmailOptions_Orgs_CC[j].recordId === event.target.value) {
                                this.listOfcontactsWithEmailOptions_Orgs_CC[i].CC = event.target.checked;
                                ismatchFound = true;
                            }
                        }

                        if (ismatchFound === false) {
                            this.listOfcontactsWithEmailOptions_Orgs_CC.push({ recordId: event.target.value, CC: event.target.checked });
                        }
                    }
                }
                console.log('loopEnded' + JSON.stringify(this.listOfcontactsWithEmailOptions_Orgs_CC));
            } else {
                this.listOfcontactsWithEmailOptions_Orgs_CC.push({ recordId: event.target.value, CC: event.target.checked });
            }
            /* }
         }*/
            console.log(JSON.stringify(this.listOfcontactsWithEmailOptions_Orgs_CC));
        } else {
            //console.log('DataSet' + JSON.stringify(acheckBox.dataset));
            if (this.listOfcontactsWithEmailOptions_Orgs_CC.length > 0) {
                console.log('else block=> 01' + JSON.stringify(this.listOfcontactsWithEmailOptions_Orgs_CC));
                for (let i = 0; i < this.listOfcontactsWithEmailOptions_Orgs_CC.length; i++) {
                    console.log('else block=> 02' + JSON.stringify(this.listOfcontactsWithEmailOptions_Orgs_CC));
                    console.log('index' + '' + i + '\n' + this.listOfcontactsWithEmailOptions_Orgs_CC[i]);
                    if (this.listOfcontactsWithEmailOptions_Orgs_CC[i].recordId === event.target.value) {
                        console.log('index' + 'Inside Condition' + i);
                        this.listOfcontactsWithEmailOptions_Orgs_CC[i].CC = event.target.checked;
                    }
                }
            } else {
                this.listOfcontactsWithEmailOptions_Orgs_CC = [];
            }
            console.log('else block=>' + JSON.stringify(this.listOfcontactsWithEmailOptions_Orgs_CC));
        }
    }

    //Checkbox event Handler for To Unit
    handleToCheckBox_Unit(event) {
        console.log('To-Unit' + event.target.checked);
        console.log('To-Unit' + event.target.value);
        if (event.target.checked === true) {

            if (this.listOfcontactsWithEmailOptions_Units_To.length > 0) {
                for (let i = 0; i < this.listOfcontactsWithEmailOptions_Units_To.length; i++) {
                    console.log('LoopStarted');
                    console.log(event.target.value);
                    console.log(this.listOfcontactsWithEmailOptions_Units_To[i]);
                    console.log('LoopValue' + this.listOfcontactsWithEmailOptions_Units_To[i].recordId);
                    console.log('TargetValue' + event.target.value);
                    console.log('Loopvalue' + this.listOfcontactsWithEmailOptions_Units_To[i].To);
                    console.log('TargetValue' + event.target.checked);
                    if (this.listOfcontactsWithEmailOptions_Units_To[i].recordId === event.target.value) {
                        this.listOfcontactsWithEmailOptions_Units_To[i].To = event.target.checked;
                    } else {
                        var ismatchFound = false;
                        for (let j = 0; j < this.listOfcontactsWithEmailOptions_Units_To.length; j++) {
                            if (this.listOfcontactsWithEmailOptions_Units_To[j].recordId === event.target.value) {
                                this.listOfcontactsWithEmailOptions_Units_To[i].To = event.target.checked;
                                ismatchFound = true;
                            }
                        }

                        if (ismatchFound === false) {
                            this.listOfcontactsWithEmailOptions_Units_To.push({ recordId: event.target.value, To: event.target.checked });
                        }
                    }
                }
                console.log('loopEnded' + JSON.stringify(this.listOfcontactsWithEmailOptions_Units_To));
            } else {
                this.listOfcontactsWithEmailOptions_Units_To.push({ recordId: event.target.value, To: event.target.checked });
            }
            /* }
         }*/
            console.log(JSON.stringify(this.listOfcontactsWithEmailOptions_Units_To));
        } else {
            //console.log('DataSet' + JSON.stringify(acheckBox.dataset));
            if (this.listOfcontactsWithEmailOptions_Units_To.length > 0) {
                console.log('else block=> 01' + JSON.stringify(this.listOfcontactsWithEmailOptions_Units_To));
                for (let i = 0; i < this.listOfcontactsWithEmailOptions_Units_To.length; i++) {
                    console.log('else block=> 02' + JSON.stringify(this.listOfcontactsWithEmailOptions_Units_To));
                    console.log('index' + '' + i + '\n' + this.listOfcontactsWithEmailOptions_Units_To[i]);
                    if (this.listOfcontactsWithEmailOptions_Units_To[i].recordId === event.target.value) {
                        console.log('index' + 'Inside Condition' + i);
                        //this.listOfcontactsWithEmailOptions_Units_To[i].pop();
                        this.listOfcontactsWithEmailOptions_Units_To[i].To = event.target.checked;
                    }
                }
            } else {
                this.listOfcontactsWithEmailOptions_Units_To = [];
            }
            console.log('else block=>' + JSON.stringify(this.listOfcontactsWithEmailOptions_Units_To));
        }


        console.log('final=>' + JSON.stringify(this.listOfcontactsWithEmailOptions_Units_To));

    }

    //Checkbox event Handler for CC Unit
    handleCCCheckBox_Unit(event) {
        console.log('CC-Unit' + event.target.checked);
        console.log('CC-Unit' + event.target.value);

        if (event.target.checked === true) {
            if (this.listOfcontactsWithEmailOptions_Units_CC.length > 0) {
                for (let i = 0; i < this.listOfcontactsWithEmailOptions_Units_CC.length; i++) {
                    console.log('LoopStarted');
                    console.log(event.target.value);
                    console.log(this.listOfcontactsWithEmailOptions_Units_CC[i]);
                    console.log('LoopValue' + this.listOfcontactsWithEmailOptions_Units_CC[i].recordId);
                    console.log('TargetValue' + event.target.value);
                    console.log('Loopvalue' + this.listOfcontactsWithEmailOptions_Units_CC[i].CC);
                    console.log('TargetValue' + event.target.checked);
                    if (this.listOfcontactsWithEmailOptions_Units_CC[i].recordId === event.target.value) {
                        this.listOfcontactsWithEmailOptions_Units_CC[i].CC = event.target.checked;
                    } else {
                        var ismatchFound = false;
                        for (let j = 0; j < this.listOfcontactsWithEmailOptions_Units_CC.length; j++) {
                            if (this.listOfcontactsWithEmailOptions_Units_CC[j].recordId === event.target.value) {
                                this.listOfcontactsWithEmailOptions_Units_CC[i].CC = event.target.checked;
                                ismatchFound = true;
                            }
                        }

                        if (ismatchFound === false) {
                            this.listOfcontactsWithEmailOptions_Units_CC.push({ recordId: event.target.value, CC: event.target.checked });
                        }
                    }
                }
                console.log('loopEnded' + JSON.stringify(this.listOfcontactsWithEmailOptions_Units_CC));
            } else {
                this.listOfcontactsWithEmailOptions_Units_CC.push({ recordId: event.target.value, CC: event.target.checked });
            }
            /* }
         }*/
            console.log(JSON.stringify(this.listOfcontactsWithEmailOptions_Units_CC));
        } else {
            //console.log('DataSet' + JSON.stringify(acheckBox.dataset));
            if (this.listOfcontactsWithEmailOptions_Units_CC.length > 0) {
                console.log('else block=> 01' + JSON.stringify(this.listOfcontactsWithEmailOptions_Units_CC));
                for (let i = 0; i < this.listOfcontactsWithEmailOptions_Units_CC.length; i++) {
                    console.log('else block=> 02' + JSON.stringify(this.listOfcontactsWithEmailOptions_Units_CC));
                    console.log('index' + '' + i + '\n' + this.listOfcontactsWithEmailOptions_Units_CC[i]);
                    if (this.listOfcontactsWithEmailOptions_Units_CC[i].recordId === event.target.value) {
                        console.log('index' + 'Inside Condition' + i);
                        this.listOfcontactsWithEmailOptions_Units_CC[i].CC = event.target.checked;
                    }
                }
            } else {
                this.listOfcontactsWithEmailOptions_Units_CC = [];
            }
            console.log('else block=>' + JSON.stringify(this.listOfcontactsWithEmailOptions_Units_CC));
        }
    }

    //Checkbox event Handler for To IP
    handleToCheckBox_IP(event) {
        console.log('To-IP' + event.target.checked);
        console.log('To-IP' + event.target.value);
        console.log('To-Unit' + event.target.checked);
        console.log('To-Unit' + event.target.value);
        if (event.target.checked === true) {

            if (this.listOfcontactsWithEmailOptions_IPs_To.length > 0) {
                for (let i = 0; i < this.listOfcontactsWithEmailOptions_IPs_To.length; i++) {
                    console.log('LoopStarted');
                    console.log(event.target.value);
                    console.log(this.listOfcontactsWithEmailOptions_IPs_To[i]);
                    console.log('LoopValue' + this.listOfcontactsWithEmailOptions_IPs_To[i].recordId);
                    console.log('TargetValue' + event.target.value);
                    console.log('Loopvalue' + this.listOfcontactsWithEmailOptions_IPs_To[i].To);
                    console.log('TargetValue' + event.target.checked);
                    if (this.listOfcontactsWithEmailOptions_IPs_To[i].recordId === event.target.value) {
                        this.listOfcontactsWithEmailOptions_IPs_To[i].To = event.target.checked;
                    } else {
                        var ismatchFound = false;
                        for (let j = 0; j < this.listOfcontactsWithEmailOptions_IPs_To.length; j++) {
                            if (this.listOfcontactsWithEmailOptions_IPs_To[j].recordId === event.target.value) {
                                this.listOfcontactsWithEmailOptions_IPs_To[i].To = event.target.checked;
                                ismatchFound = true;
                            }
                        }

                        if (ismatchFound === false) {
                            this.listOfcontactsWithEmailOptions_IPs_To.push({ recordId: event.target.value, To: event.target.checked });
                        }
                    }
                }
                console.log('loopEnded' + JSON.stringify(this.listOfcontactsWithEmailOptions_IPs_To));
            } else {
                this.listOfcontactsWithEmailOptions_IPs_To.push({ recordId: event.target.value, To: event.target.checked });
            }
            /* }
         }*/
            console.log(JSON.stringify(this.listOfcontactsWithEmailOptions_IPs_To));
        } else {
            //console.log('DataSet' + JSON.stringify(acheckBox.dataset));
            if (this.listOfcontactsWithEmailOptions_IPs_To.length > 0) {
                console.log('else block=> 01' + JSON.stringify(this.listOfcontactsWithEmailOptions_IPs_To));
                for (let i = 0; i < this.listOfcontactsWithEmailOptions_IPs_To.length; i++) {
                    console.log('else block=> 02' + JSON.stringify(this.listOfcontactsWithEmailOptions_IPs_To));
                    console.log('index' + '' + i + '\n' + this.listOfcontactsWithEmailOptions_IPs_To[i]);
                    if (this.listOfcontactsWithEmailOptions_IPs_To[i].recordId === event.target.value) {
                        console.log('index' + 'Inside Condition' + i);
                        //this.listOfcontactsWithEmailOptions_IPs_To[i].pop();
                        this.listOfcontactsWithEmailOptions_IPs_To[i].To = event.target.checked;
                    }
                }
            } else {
                this.listOfcontactsWithEmailOptions_IPs_To = [];
            }
            console.log('else block=>' + JSON.stringify(this.listOfcontactsWithEmailOptions_IPs_To));
        }


        console.log('final=>' + JSON.stringify(this.listOfcontactsWithEmailOptions_IPs_To));

    }

    //Checkbox event Handler for CC IP
    handleCCCheckBox_IP(event) {
        console.log('CC-IP' + event.target.checked);
        console.log('CC-IP' + event.target.value);
        if (event.target.checked === true) {
            if (this.listOfcontactsWithEmailOptions_IPs_CC.length > 0) {
                for (let i = 0; i < this.listOfcontactsWithEmailOptions_IPs_CC.length; i++) {
                    console.log('LoopStarted');
                    console.log(event.target.value);
                    console.log(this.listOfcontactsWithEmailOptions_IPs_CC[i]);
                    console.log('LoopValue' + this.listOfcontactsWithEmailOptions_IPs_CC[i].recordId);
                    console.log('TargetValue' + event.target.value);
                    console.log('Loopvalue' + this.listOfcontactsWithEmailOptions_IPs_CC[i].CC);
                    console.log('TargetValue' + event.target.checked);
                    if (this.listOfcontactsWithEmailOptions_IPs_CC[i].recordId === event.target.value) {
                        this.listOfcontactsWithEmailOptions_IPs_CC[i].CC = event.target.checked;
                    } else {
                        var ismatchFound = false;
                        for (let j = 0; j < this.listOfcontactsWithEmailOptions_IPs_CC.length; j++) {
                            if (this.listOfcontactsWithEmailOptions_IPs_CC[j].recordId === event.target.value) {
                                this.listOfcontactsWithEmailOptions_IPs_CC[i].CC = event.target.checked;
                                ismatchFound = true;
                            }
                        }

                        if (ismatchFound === false) {
                            this.listOfcontactsWithEmailOptions_IPs_CC.push({ recordId: event.target.value, CC: event.target.checked });
                        }
                    }
                }
                console.log('loopEnded' + JSON.stringify(this.listOfcontactsWithEmailOptions_IPs_CC));
            } else {
                this.listOfcontactsWithEmailOptions_IPs_CC.push({ recordId: event.target.value, CC: event.target.checked });
            }
            /* }
         }*/
            console.log(JSON.stringify(this.listOfcontactsWithEmailOptions_IPs_CC));
        } else {
            //console.log('DataSet' + JSON.stringify(acheckBox.dataset));
            if (this.listOfcontactsWithEmailOptions_IPs_CC.length > 0) {
                console.log('else block=> 01' + JSON.stringify(this.listOfcontactsWithEmailOptions_IPs_CC));
                for (let i = 0; i < this.listOfcontactsWithEmailOptions_IPs_CC.length; i++) {
                    console.log('else block=> 02' + JSON.stringify(this.listOfcontactsWithEmailOptions_IPs_CC));
                    console.log('index' + '' + i + '\n' + this.listOfcontactsWithEmailOptions_IPs_CC[i]);
                    if (this.listOfcontactsWithEmailOptions_IPs_CC[i].recordId === event.target.value) {
                        console.log('index' + 'Inside Condition' + i);
                        this.listOfcontactsWithEmailOptions_IPs_CC[i].CC = event.target.checked;
                    }
                }
            } else {
                this.listOfcontactsWithEmailOptions_IPs_CC = [];
            }
            console.log('else block=>' + JSON.stringify(this.listOfcontactsWithEmailOptions_IPs_CC));
        }
    }

  

    //Explicit Calling of apex method
    @api handleSaveClick() {
        //ToDo : Get all the Contact Details and To and CC Selected list and Created the Record in using the Apex controller 
        //
        //Correspondence / Mailing List Recipients
        let isSuccessOrgRecordCreation = false;
        let isSuccessUnitRecordCreation = false;
        let isSuccessIPRecordCreation = false;

        if (this.listOfcontactsWithEmailOptions_Orgs_To.length > 0 || this.listOfcontactsWithEmailOptions_Orgs_CC.length > 0) {
            createCorrespondence_Mailing_Org({
                contactDetails_Organizations: this.contactsUnderOrganization,
                currentRecordId: this.recordId,
                listOfcontactsWithEmailOptions_Orgs_To: this.listOfcontactsWithEmailOptions_Orgs_To,
                listOfcontactsWithEmailOptions_Orgs_CC: this.listOfcontactsWithEmailOptions_Orgs_CC
            })
                .then(result => {

                    this.showSuccessToast('Success', 'Records Created Successfully');

                })
                .catch(error => {
                    this.showErrorToast('Error', 'Error creating contact. Please Contact System Admin');
                });
        }


        if (this.listOfcontactsWithEmailOptions_Units_To.length > 0 || this.listOfcontactsWithEmailOptions_Units_CC.length > 0) {
            createCorrespondence_Mailing_Unit({
                contactDetails_Units: this.contactsUnderUnit,
                currentRecordId: this.recordId,
                listOfcontactsWithEmailOptions_Units_To: this.listOfcontactsWithEmailOptions_Units_To,
                listOfcontactsWithEmailOptions_Units_CC: this.listOfcontactsWithEmailOptions_Units_CC
            })
                .then(result => {

                    this.showSuccessToast('Success', 'Records Created Successfully');
                })
                .catch(error => {
                    this.showErrorToast('Error', 'Error creating contact. Please Contact System Admin');
                });
        }

        if (this.listOfcontactsWithEmailOptions_IPs_To.length > 0 || this.listOfcontactsWithEmailOptions_IPs_CC.length > 0) {
            createCorrespondence_Mailing_InspectionPackage({
                contactDetails_Inspection_Packages: this.contactsUnderInspectionPackage,
                currentRecordId: this.recordId,
                listOfcontactsWithEmailOptions_IPs_To: this.listOfcontactsWithEmailOptions_IPs_To,
                listOfcontactsWithEmailOptions_IPs_CC: this.listOfcontactsWithEmailOptions_IPs_CC
            })
                .then(result => {

                    this.showSuccessToast('Success', 'Records Created Successfully');
                })
                .catch(error => {
                    this.showErrorToast('Error', 'Error creating contact. Please Contact System Admin');
                });
        }

       // this.closeQuickAction();
       // this.saveQucikActionHandler(); handling from Aura
        //this.closeQuickAction();  // This Helps to Auto Close the Quick Action 
    }

}