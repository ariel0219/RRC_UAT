import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CiisGscFacilityRecords extends NavigationMixin(LightningElement) {
    @api title;
}