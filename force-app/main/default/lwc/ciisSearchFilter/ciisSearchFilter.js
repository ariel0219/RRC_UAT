import { LightningElement, api, track } from 'lwc';

const defaultContainerClass = 'slds-grid slds-grid_vertical-align-center';
const lockedContainerClass = `${defaultContainerClass} slds-is-locked`;

export default class CiisSearchFilter extends LightningElement {
    @api isLocked = false;
    @api label;
    @api value;
    @api options;
    @api required = false;
    @api filterOperator = '=';
    @api maxLength = 255;
    @track editingValue;

    containerClass = defaultContainerClass;

    connectedCallback() {
        if (this.options) {
            this.showSelect = true;
        } else {
            this.showInput = true;
        }

        if (this.isLocked) {
            this.containerClass = lockedContainerClass;
        }
    }

    setFilterValue(updatedValue) {
        this.editingValue = updatedValue;
        this.dispatchEvent(
            new CustomEvent('filterchange', {
                detail: {
                    value: this.editingValue
                }
            })
        );
        this.isEditing = false;
    }

    handleClick() {
        if (!this.isLocked) {
            this.editingValue = this.value;
            this.isEditing = true;
        }
    }

    handleBlur(evt) {
        this.setFilterValue(evt.target.value);
    }

    handleChange(evt) {
        this.setFilterValue(evt.target.value);
    }
}