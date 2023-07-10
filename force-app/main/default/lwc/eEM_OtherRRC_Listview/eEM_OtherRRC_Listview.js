import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class EEM_OtherRRC_Listview extends NavigationMixin(LightningElement) {
navigateToOtherRRCEvents()
{
this[NavigationMixin.Navigate]({
        type:'standard__objectPage',
        attributes:{
            objectApiName:'EEM_Event__c',
            actionName:'list'
        },
        state:{
            filterName:'00Bt0000001eWCJEA2'
        },
    });
}
}