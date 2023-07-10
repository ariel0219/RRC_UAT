import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CiisNavigateFromFlow extends NavigationMixin(
    LightningElement
) {
    @api
    pageReferenceJson;

    @api
    replaceHistory = false;

    pageReference;

    connectedCallback() {
        try {
            this.pageReference = JSON.parse(this.pageReferenceJson);
        } catch (e) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error parsing page reference',
                    message: e.message,
                    variant: 'error'
                })
            );
        }
        this.navigateToPage();
    }

    navigateToPage(replaceHistory) {
        try {
            this[NavigationMixin.Navigate](this.pageReference, replaceHistory);
        } catch (e) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error navigating to page',
                    message: e.message,
                    variant: 'error'
                })
            );
        }
    }
}