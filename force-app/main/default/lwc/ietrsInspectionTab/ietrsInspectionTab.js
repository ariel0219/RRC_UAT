import { LightningElement, api } from 'lwc';

const baseClass = 'slds-tabs_default__item';
const activeClass = 'slds-is-active';
const tabId = 'inspection-tabs';

export default class IetrsInspectionTab extends LightningElement {
    @api label;
    @api tabName;
    @api isActive;
    @api index;

    get ariaControls() {
        return `${tabId}-${this.index}`;
    }

    get ariaId() {
        return `${this.ariaControls}__item`;
    }

    get tabClass() {
        let result = baseClass;
        if (this.isActive) {
            result += ' ' + activeClass;
        }
        return result;
    }

    handleClick(evt) {
        evt.preventDefault();
        this.dispatchEvent(new CustomEvent('tabchange', { detail: this.tabName }));
    }
}