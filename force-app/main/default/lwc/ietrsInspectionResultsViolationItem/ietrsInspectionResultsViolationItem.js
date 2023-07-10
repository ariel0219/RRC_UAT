import { LightningElement, api } from 'lwc';

const hideClass = 'slds-hide';
const baseClass = 'slds-cell-buffer_left border-top_none';

export default class IetrsInspectionResultsViolationItem extends LightningElement {
    @api location;
    @api comments;
    @api inspectionResultId;
    @api showRow;
    @api readOnly;

    get colClass() {
        let result = baseClass;
        if (!this.showRow) {
            result += ' ' + hideClass;
        }
        return result;
    }

    fireRecordChangeEvent(payload) {
        this.dispatchEvent(
            new CustomEvent('recordchange', {
                detail: { ...payload, Id: this.inspectionResultId }
            })
        );
    }

    handleChange(evt) {
        const changes = {};
        const fieldName = evt.target.dataset.fieldName;
        const value = evt.target.value;
        changes[fieldName] = value;
        this.fireRecordChangeEvent(changes);
    }
}