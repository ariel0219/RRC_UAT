import { LightningElement,track } from 'lwc';
import pubsub from 'c/iETRS_PLI_PubSub';
export default class IERTS_PLI_Report_Details extends LightningElement {
  
    
    @track organizationName;
    
    connectedCallback() {
        this.regiser();
    }
    regiser() {
        pubsub.register('viewDetails', this.handleEvent.bind(this));
    }
    handleEvent(messageFromEvt){
        var getSRCRecord = JSON.parse(messageFromEvt.viewDetails);
        this.organizationName = getSRCRecord.IETRS_Organization__r.Name;
        //window.alert('ERRRRRRRR'+getSRCRecord.IETRS_Organization__r.Name);
    
    }
}