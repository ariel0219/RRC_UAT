import { LightningElement, api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSupplyChainConnections from '@salesforce/apex/CIIS_MassUploadController.getSupplyChainConnections';

const columns = [
    { label: 'Gas Receiver P5',fieldName: 'receiverP5Number',type:'text'},
    { label: 'Gas Receiver System Id',fieldName: 'receiverSystemId',type:'text'},
    { label: 'Gas Receiver System Name',fieldName: 'receiverName',type:'text'},
    { label: 'Gas Supplier Type',fieldName: 'supplierType',type:'text'},
    { label: 'Gas Supplier Operator Number',fieldName: 'supplierP5Number',type:'text'},
    { label: 'Gas Supplier Operator Name',fieldName: 'supplierName',type:'text'}
];

export default class CiisMassUploadResult extends NavigationMixin(LightningElement) {
    @api supplyChainConnectionList=[];
    @track data=[];
    @track columns = columns
    @track recordId;
    @track error;
    @track isLoading=false;

    connectedCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        this.recordId = urlParams.get('recordId');
        this.getRecords();
    }

    getRecords(){
      this.isLoading=true;
      getSupplyChainConnections({"supplyChainList":this.supplyChainConnectionList})
          .then((result) => {
            this.data=result;
            //console.log('data:');
            //console.log(JSON.stringify(this.data));
            this.isLoading=false; 
          })
          .catch((error) => {
              //console.log(error);
              this.isLoading = false;
              if (Array.isArray(error.body)) {
                  this.error = error.body.map((e) => e.message).join(', ');
              } else if (typeof error.body.message === 'string') {
                  this.error = error.body.message;
              }
              this.showNotification(this.error, 'error', 'Error !');
          });        
    }

    showNotification(message,variant,title) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
}

}