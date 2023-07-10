import { LightningElement, api, wire, track } from 'lwc';
import getAssociatedExamsFromEvent from '@salesforce/apex/EEM_EventController.getAssociatedExamsFromEvent';
import getClassFee from '@salesforce/apex/EEM_EventController.getClassFee';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';


const columns = [
    { label: 'Exam Title', fieldName: 'EEM_Event_Title__c' },
    { label: 'Exam Level', fieldName: 'EEM_Exam_Level__c' },
    { label: 'Fuel Type', fieldName: 'EEM_Fuel_Type__c' }
];

export default class EEMSelectAssociatedExamsFromParentEvent extends LightningElement {
    @api recordId;
    @api recordTypeName;
    @api events;
    @api exams = [];
    @api examIds = '';
    @api totalFees = 0;
    @api classFeeSelectedExamFee=[];
    @api selectedFuelType=[];
    @api selectedExamTitle=[];
    @api selectedExamFee=[];
    @api selectedExamLevel=[];
    @api selectedExamIds=[];
    @api selectedExamLevelOne;
    @api selectedExamLevelTwo;
    @api selectedExamDetailsOne;
    @api selectedExamDetailsTwo;
    @api selectedExamFeeOne;
    @api selectedExamFeeTwo;
    @api selectedFuelTypeOne;
    @api selectedFuelTypeTwo;
    @track maxRowSelection = 2;
    //@track showmessage=false;
    @track eventType;
    columns = columns;
    @track feecode = [];
    @api classFuelType = [];
    @track checkBool = false;
    @track selectedRowsId = [];
    selectedRowsTitle = [];
    mainEvent;



    @wire(getAssociatedExamsFromEvent, {
        eventId: '$recordId', recordType: '$recordTypeName'
    }) wiredExams({ error, data }) {
        if(data) {
            this.events = data;
            console.log('data' + data);
        }
    }

    @wire(getClassFee, { eventId: '$recordId' }) wiredfees({ error, data }) {
        if (data) {

            for (let i = 0; i < data.length; i++) {
                this.feecode.push(data[i].EEM_Fee_Code__c);
                this.classFuelType.push(data[i].EEM_Fuel_Type__c);
                this.mainEvent = data[i];
                //console.log('classfuel',this.classFuelType);
                console.log('recordtype', +data[i].recordTypeId);
                // this.selectedRowsId=[...this.selectedRowsId,result[i].EEM_Fee_Code__c];
                this.classFeeSelectedExamFee = this.feecode;
                //In case of 2.1 dispenser operation you can select one or both associated exams
                if (data[i].EEM_ICI_Type__c == '2.1 dispenser operations course') {
                    this.maxRowSelection = 2;
                }
                if ((data[i].EEM_ICI_Type__c != '2.1 dispenser operations course') && (data[i].EEM_Event_Type__c != 'Online') && (data[i].EEM_Event_Type__c != 'In Person')) {
                    this.maxRowSelection = 1;
                }
                if (data[i].EEM_ICI_Type__c == 'Category E course' || data[i].EEM_ICI_Type__c == 'Category F, G, I and J course' || data[i].EEM_ICI_Type__c == '2.3 bobtail operations course' || data[i].EEM_ICI_Type__c == '3.2 residential system installation course' || data[i].EEM_ICI_Type__c == '3.3 appliance conversion, installation and venting course' || data[i].EEM_ICI_Type__c == '3.8 recreational vehicle gas appliances course') {
                    this.maxRowSelection = 1;
                }
                if (data[i].EEM_Event_Type__c == 'In Person') {
                    this.eventType = data[i].EEM_Event_Type__c;
                }
                if (data[i].EEM_Event_Type__c == 'Online') {
                    this.eventType = data[i].EEM_Event_Type__c;
                }
                if (data[i].EEM_Event_Type__c == 'Online' && data[i].EEM_ICI_Type__c == '2.1 dispenser operations course') {
                    this.maxRowSelection = 2;
                    //this.eventTypeInPerson=data[i].EEM_Event_Type__c;
                    console.log('@@eventtype' + this.eventTypeInPerson);
                    //this.showmessage=true;
                }
                if (data[i].EEM_Event_Type__c == 'In Person' && (data[i].EEM_ICI_Type__c == '3.2 residential system installation course' || data[i].EEM_ICI_Type__c == '2.3 bobtail operations course')) {
                    this.maxRowSelection = 1;
                    //this.showmessage=true;
                }

            }

        }
        else if (error) {
            this.error = error;
            this.data = undefined;
        }
        console.log('@@eventtype' + this.eventTypeInPerson);

    }



    handleRowSelection(event) {
        var selectedRows = event.detail.selectedRows;

        console.log('selected' + JSON.stringify(selectedRows));


       

        if (this.eventType == 'Online' || this.eventType == 'In Person') {
            this.selectedRows = event.detail.selectedRows.map(row => {
                if (selectedRows.length > 1 && (row.EEM_Event_Title__c != 'F-3 Motor/Mobile Fuel Filler' && row.EEM_Event_Title__c != 'E-3 DOT cylinder filler')) {
                    if (selectedRows.length != 3) {
                        var el = this.template.querySelector('lightning-datatable');
                        selectedRows = el.selectedRows = el.selectedRows.slice(1);
                        console.log('selec value' + selectedRows);

                        event.preventDefault();
                    }
                    else {
                        var el = this.template.querySelector('lightning-datatable');
                        selectedRows = el.selectedRows = el.selectedRows.slice(3);
                        console.log('selec value 2' + selectedRows);
                        event.preventDefault();
                    }

                    return;
                }
            });
            this.exams = this.template.querySelector('lightning-datatable').getSelectedRows();
            this.processSelectedRows();

        }
        /*if (this.eventType == 'In Person') {
            console.log('In person');
            this.exams = this.template.querySelector('lightning-datatable').getSelectedRows();
            if ( this.exams.length > 1 &&  ((this.exams[0].EEM_Event_Title__c == 'A-3 Bobtail Driver' && this.exams[1].EEM_Event_Title__c == 'B-3 Service and Installation Technician') || (this.exams[1].EEM_Event_Title__c == 'A-3 Bobtail Driver' && this.exams[0].EEM_Event_Title__c == 'B-3 Service and Installation Technician'))) {
                var el = this.template.querySelector('lightning-datatable');
                el.selectedRows = el.selectedRows.slice(1);
                this.exams = this.template.querySelector('lightning-datatable').getSelectedRows();
                console.log('examsss==>' + JSON.stringify(this.exams));
                console.log('@@eventtype' + this.eventTypeInPerson);
                this.showNotification();
                event.preventDefault();
                return;
            }
            
            this.processSelectedRows();

        }
        console.log('@@selectedtitle' + this.selectedRowsTitle); */


    }

    processSelectedRows() {
        let selectedRowsFuelType = [];
        let selectedRowsId = [];
        let selectedRowsFeeCode = [];
        let selectedRowsTitle = [] ;

        for (let i = 0; i < this.exams.length; i++) {
            selectedRowsFuelType.push(this.exams[i].EEM_Fuel_Type__c);
            selectedRowsId.push(this.exams[i].Id);
            selectedRowsFeeCode.push(this.exams[i].EEM_Fee_Code__c);
            selectedRowsTitle.push(this.exams[i].EEM_Event_Title__c);
        }

        
         
        if(selectedRowsId) { //added this condition 5-Aug-22
            this.selectedExamIds = selectedRowsId.concat(this.recordId);
        } //added this ending bracket 5-Aug-22
        this.selectedFuelType = selectedRowsFuelType;
        this.selectedExamTitle = selectedRowsTitle;
        this.classFeeSelectedExamFee = selectedRowsFeeCode;
        this.classFeeSelectedExamFee = this.classFeeSelectedExamFee.concat(this.feecode);
        if(this.exams && this.exams[0]) { //added this condition 5-Aug-22
            this.selectedExamDetailsOne=this.exams[0].EEM_Event_Title__c;
            this.selectedExamFeeOne=this.exams[0].EEM_Exam_Fee__c;
            this.selectedExamLevelOne=this.exams[0].EEM_Exam_Level__c;
            this.selectedFuelTypeOne=this.exams[0].EEM_Fuel_Type__c;
        } //added this ending bracket 5-Aug-22
        if(this.exams && this.exams[1]) { //added this condition 5-Aug-22
            this.selectedExamDetailsTwo=this.exams[1].EEM_Event_Title__c;
            this.selectedExamFeeTwo=this.exams[1].EEM_Exam_Fee__c;
            this.selectedExamLevelTwo=this.exams[1].EEM_Exam_Level__c;
            this.selectedFuelTypeTwo=this.exams[1].EEM_Fuel_Type__c;
        } //added this ending bracket 5-Aug-22
        //alert(this.selectedExamDetailsOne);
        
       
    }


    handleSelection(event) {
        this.exams = this.template.querySelector('lightning-datatable').getSelectedRows();
        var selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 1) {
            var el = this.template.querySelector('lightning-datatable');
            selectedRows = el.selectedRows = el.selectedRows.slice(1);
            event.preventDefault();
        }
        console.log('check selected rows' + JSON.stringify(this.exams.length));
        // checking if 'A-3 Bobtail Driver' and 'B-3 Service and Installation Technician' selected and showing notification
        // after deselecting one of them as user can select only one these from UI
        this.selectedRows = event.detail.selectedRows.map(row => {
            if ((row.EEM_Event_Title__c != 'F-3 Motor/Mobile Fuel Filler' || row.EEM_Event_Title__c != 'E-3 DOT cylinder filler') || this.exams.length > 1) {
                this.showNotificationSelectE3();
                // event.preventDefault();

            }
            /*else if(row.EEM_Event_Title__c=='F-3 Motor/Mobile Fuel Filler' )
            {

            }*/
            return row.Id;

        });



        let selectedRowsId = [];
        for (let i = 0; i < this.exams.length; i++) {
            selectedRowsId.push(this.exams[i].EEM_Fee_Code__c);

            this.classFeeSelectedExamFee = selectedRowsId;

        }
        this.classFeeSelectedExamFee = this.classFeeSelectedExamFee.concat(this.feecode);

        console.log('classFee' + JSON.stringify(this.classFeeSelectedExamFee));
        console.log('exam==>' + JSON.stringify(this.exams));




        if (this.exams.length == 2) {
            if ((this.exams[0].EEM_Event_Title__c == 'A-3 Bobtail Driver' && this.exams[1].EEM_Event_Title__c == 'B-3 Service and Installation Technician') || (this.exams[1].EEM_Event_Title__c == 'A-3 Bobtail Driver' && this.exams[0].EEM_Event_Title__c == 'B-3 Service and Installation Technician')) {
                var el = this.template.querySelector('lightning-datatable');
                //el.selectedRows=el.selectedRows.slice(1);
                this.exams = this.template.querySelector('lightning-datatable').getSelectedRows();
                console.log('examsss==>' + JSON.stringify(this.exams));
                console.log('@@eventtype' + this.eventTypeInPerson);
                this.showNotification();
                event.preventDefault();
                return;
            }

            if (this.eventType == 'Online') {
                if ((this.exams[0].EEM_Event_Title__c != 'E-3 DOT cylinder filler' || this.exams[1].EEM_Event_Title__c != 'F-3 Motor/Mobile Fuel Filler') && (this.exams[1].EEM_Event_Title__c != 'E-3 DOT cylinder filler' || this.exams[0].EEM_Event_Title__c != 'F-3 Motor/Mobile Fuel Filler')
                ) {
                    console.log('In data');
                    var el = this.template.querySelector('lightning-datatable');
                    // el.selectedRows=el.selectedRows.slice(1);
                    this.exams = this.template.querySelector('lightning-datatable').getSelectedRows();
                    console.log('examsss==>' + JSON.stringify(this.exams));
                    //this.showNotificationdotmotor();
                    event.preventDefault();
                    return;
                }
            }
        }
    }
    //Hook to Flow's Validation engine
    @api
    validate() {
        console.log('In validate method');
        if (this.exams.length == 0 && this.recordTypeName == 'Exam' && (this.eventType == 'Online' || this.eventType == 'In Person')) {
            return {
                isValid: false,
                errorMessage: "<span style='font-size:20px'>" + 'At least one selection is required' + "</span>"
            };
        }






        //If the component is invalid, return the isValid parameter as false and return an error message. 
        return {
            isValid: true,


        };
    }


    showNotification() {
        const event = new ShowToastEvent({
            message: '\'A-3 Bobtail Driver\' and \'B-3 Service and Installation Technician\' cannot be selected together',
            variant: 'warning',
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }
    showNotificationSelectE3() {
        const event = new ShowToastEvent({
            message: 'Only one record can be selected',
            variant: 'error',
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }
}