import { LightningElement,api } from 'lwc';  

export default class CiisFileCorrespondencePreview extends LightningElement {

    siteURL;
    @api recordId;

    connectedCallback() {
        
        this.siteURL = '/apex/CIIS_boxUIPreview?id=' + this.recordId;

    }

}