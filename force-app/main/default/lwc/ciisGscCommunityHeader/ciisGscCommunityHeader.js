import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class GscCommunityHeader extends NavigationMixin(
    LightningElement
) {
    @api pageTitle;
    @api showBreadcrumbs = false;
    @track currentBreadcrumb;
    homeBreadcrumb = {
        label: 'Back to RRC MAP Home Page',
        name: 'GasSupplyChainHome'
    };

    connectedCallback() {
        if (this.currentBreadcrumbLabel) {
            this.currentBreadcrumb = {
                label: this.currentBreadcrumbLabel,
                name: this.currentBreadcrumbLabel.replaceAll(' ', '')
            };
        }
    }

    handleBreadcrumbClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'GSC_Home_Page__c'
            }
        });
    }

    handleHomeClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }
}