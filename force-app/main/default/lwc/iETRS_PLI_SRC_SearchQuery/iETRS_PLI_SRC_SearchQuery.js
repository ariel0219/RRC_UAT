import {
    LightningElement, api, wire, track
} from 'lwc';
import pubsub from 'c/iETRS_PLI_PubSub';
import getSRCRecordNotification from '@salesforce/apex/IETRS_PLI_LWCQuery.fetchNotificationSRCRecods';
//Imported by Ayesha on 14th DEC 2020 for getting record type ID
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import NOTIFICATION_OBJECT from '@salesforce/schema/IETRS_Insp_Notification__c';
export default class IETRS_PLI_SRC_SearchQuery extends LightningElement {

    operatorName;
    getSRCData;
    p5number;
    systemname;
    //Added by Ayesha for capturing the Ids on 10TH DEC 2020
    operatorNameId;
    p5numberId;
    systemnameId;
    //To desable the button
    disableButton = true;
    @api getValuePS_TABs;

     //Added by Ayesha for obtaining the record type Id
    recordTypeId; 
    @track objectInfo;
    // @wire(getObjectInfo, { objectApiName: NOTIFICATION_OBJECT})
    // objectInfo;
    @wire(getObjectInfo, { objectApiName: NOTIFICATION_OBJECT})
    setObjectInfo({error,data}){
        if(data){
            this.objectInfo = data;
        }
        else if (error){
            //FC Note: Add error handling here
        }
    };

        
    
    onoperatornameChange(event) {
        this.operatorName = event.detail.selectedValue;
        this.operatorNameId = event.detail.selectedRecordId;
        console.log('operatorNameId=>'+this.operatorNameId);
        if (this.p5number != null) {
            this.template.querySelector('[data-id="psId"]').removeRecordOnLookup();
            this.p5number = null;
            this.p5numberId = null;
        }
        if (this.operatorName != null || this.p5number != null || this.systemname != null)
            this.disableButton = false;
        else
            this.disableButton = true;
    }
    onp5numberchange(event) {
        this.p5number = event.detail.selectedValue;
        this.p5numberId = event.detail.selectedRecordId;
        if (this.operatorName != null) {
            this.template.querySelector('[data-id="accid"]').removeRecordOnLookup();
            this.operatorName = null;
            this.operatorNameId = null;
        }
        if (this.operatorName != null || this.p5number != null || this.systemname != null)
            this.disableButton = false;
        else
            this.disableButton = true;
    }
    onregulatedpsystemnameChange(event) {
        this.systemname = event.detail.selectedValue;
        this.systemnameId = event.detail.selectedRecordId;
        //alert(this.systemnameId);
        if (this.operatorName != null || this.p5number != null || this.systemname != null)
            this.disableButton = false;
        else
            this.disableButton = true;
    }

    getSRCSearchResult() {
console.log(this.operatorName);
console.log(this.p5number);
console.log(this.systemname);
console.log(this.getValuePS_TABs);


        getSRCRecordNotification({
            operatorName: this.operatorName,
            psNumber: this.p5number,
            systemName: this.systemname,
            RecordTypeName: this.getValuePS_TABs
        })
            .then(result => {
                console.log('Result at Search query=>' + JSON.stringify(result));
                const value = true;
                //Added by Ayesh for sending the event based on the TAB
                
                if(this.getValuePS_TABs == 'SRC'){
                    const valueChangeEvent  = new CustomEvent("valuechangeSrc", {
                        detail: {
                            value
                        }
                    });
                    this.dispatchEvent(valueChangeEvent);
                }
                else{
                    const valueChangeEvent  = new CustomEvent("valuechangeImp", {
                        detail: {
                            value
                        }
                    });
                    this.dispatchEvent(valueChangeEvent);
                }
                 
                
                this.getSRCData = result;
                //console.log('hi::' + result);
                //alert('result==>'+result);
                var createJSON = JSON.stringify(result);
                console.log('createJSON=>>' + createJSON);
                var opName = null;
                var sysName = null;
                var p5Num = null;

                if (this.operatorNameId !== undefined)
                    opName = this.operatorNameId;

                if (this.systemnameId !== undefined)
                    sysName = this.systemnameId;


                if (this.p5numberId !== undefined)
                    p5Num = this.p5numberId;


                //To get the Record type ID
                this.getRecordTypeId(this.getValuePS_TABs);

                let message = {
                    "setDataSRCstr": createJSON,
                    //Added by Ayesha for passing on the Operator or System or P5 Number
                    "operatorName": opName,
                    "systemName": sysName,
                    "psNumber": p5Num,
                    "recordTypeId":this.recordTypeId,
                    "getValuePS_TABs":this.getValuePS_TABs
                }
                pubsub.fire('getSRCDataRecordsEVT', message);
            })
            .catch(error => {
                window.alert(JSON.stringify(error));
            });
    }/*
      handleOnselect(event){
        const value = true;
        const valueChangeEvent = new CustomEvent("valuechangeSrc", {
            detail: {
                value
            }
        });
        this.dispatchEvent(valueChangeEvent);
        var selectedVal = event.detail.value;
        var convertJSON = JSON.stringify(selectedVal);
        let message = {
            "viewDetails": convertJSON,
        }
        pubsub.fire('viewDetails', message);
    }*/
    //Added by AYesha on 11th DEC 2020 for making NULL on ondisablebuttonaction
    onSystemdisablebuttonaction(){
        this.systemnameId = null;
        if ((this.operatorNameId == null || this.operatorNameId == undefined) && 
            (this.p5numberId == null || this.p5numberId == undefined) && 
            (this.systemnameId == null || this.systemnameId == undefined)){
            this.disableButton=true;
            console.log('onSystemdisablebuttonaction=>'+this.operatorNameId);
        }

        //Added by Ayesha to remove the System name
        if(this.systemnameId == null || this.systemnameId == undefined)
            this.systemname = '';

    }

    onP5disablebuttonaction(){
        this.p5numberId = null;
        if ((this.operatorNameId == null || this.operatorNameId == undefined) && 
            (this.p5numberId == null || this.p5numberId == undefined) && 
            (this.systemnameId == null || this.systemnameId == undefined)){
            this.disableButton=true;
            console.log('onP5disablebuttonaction=>'+this.operatorNameId);
        }

        //Added by Ayesha to remove the P5 Number name
        if(this.p5numberId == null || this.p5numberId == undefined)
            this.p5number = '';
    }

    onOperatordisablebuttonaction(){
        console.log('onOperatordisablebuttonaction=>'+this.operatorNameId+'<=p5=>'+this.p5numberId+'<=sys=>'+this.systemnameId);
        this.operatorNameId = null;
        if ((this.operatorNameId == null || this.operatorNameId == undefined) && 
            (this.p5numberId == null || this.p5numberId == undefined) && 
            (this.systemnameId == null || this.systemnameId == undefined)){
            this.disableButton=true;
            console.log('onOperatordisablebuttonaction=>'+this.operatorNameId);
        }
        
        //Added by Ayesha to remove the Operator Number name
        if(this.operatorNameId == null || this.operatorNameId == undefined)
            this.operatorName = '';
            
    }
    
    getRecordTypeId(recordTypeName){
        console.log(' recordtypeinfo=>'+JSON.stringify(this.objectInfo));
        let recordtypeinfo = this.objectInfo.recordTypeInfos;
        console.log(' recordtypeinfo'+JSON.stringify(recordtypeinfo));
        let recordTypId;
        for(var eachRecordtype in  recordtypeinfo){
        console.log(' this.getRecordTypeId(this.recordTypeName);'+recordTypeName);

            if(recordtypeinfo[eachRecordtype].name===recordTypeName){
                recordTypId = recordtypeinfo[eachRecordtype].recordTypeId;
                break;

            }
        }
        console.log('returning -   ' + recordTypId);


        this.recordTypeId= recordTypId; 
    }
}