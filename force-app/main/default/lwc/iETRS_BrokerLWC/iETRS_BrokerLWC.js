import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener } from "c/pubsub";

//Generic Broker LWC that is a child of the Aura Component IETRS_AuraBrokerController.
//This LWC registers a Listener with the standard Salesforce Pubsub module. Then sends a bubble up Custom Event to
//the parent Aura Component. At which point the Aura Component refreshes the current page.
export default class IETRS_BrokerLWC extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        // subscribe to searchKeyChange event
        registerListener('refreshfromlwc', this.refresh, this);
        console.log('Listener Registered');
    }

    refresh() {
        console.log('LWC Event Heard');
        const refreshEvent = new CustomEvent('refreshevent');
        this.dispatchEvent(refreshEvent);

    }
}