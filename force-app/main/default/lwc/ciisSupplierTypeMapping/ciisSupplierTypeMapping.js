import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecord from '@salesforce/apex/CIIS_SupplierTypeMappingForReceiver.getSupplerType';


export default class CiisSupplierTypeMapping extends LightningElement {
    @api receiverType;
    @track options=[];
    @track error;
    @track isFound=false;
    @api selectedSupplierType='';

    @wire(getRecord, {
        receiverType: '$receiverType'
    })
    wiredRecordCb({ error, data }) {
        if (data) {
            try{
            console.log('Supplier Type Data');
            console.log(data);
            this.error = undefined;
            data.forEach(currentItem => {
                var option={};
                option.value=currentItem;
                option.label=currentItem;
                this.options.push(option);
            });
            this.isFound=true;
            }catch(e){
                console.log(e);            
            }
        } else if (error) {            
            if (Array.isArray(error.body)) {
                this.error = error.body.map((e) => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            this.showNotification(this.error, 'error', 'Error !');
        }
    }

    showNotification(message,variant,title) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleChange(event) {
        this.selectedSupplierType = event.detail.value;
    }    

}