import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class CIIS_actionButton extends NavigationMixin(
    LightningElement
) {
    @api pageName;
    @api recordId;

    connectedCallback() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: this.pageName
            },
            state: {
                recordId: this.recordId
            }
        });
    }
}