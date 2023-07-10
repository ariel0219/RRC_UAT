import { LightningElement, api } from 'lwc';
import LOCALE from '@salesforce/i18n/locale';

export default class CiisFormElement extends LightningElement {
    @api label;
    @api value;
    @api fieldType = 'text';

    get showFormElement() {
        return (this.label || '').length > 0 && this._fieldType !== 'hidden';
    }

    get _fieldType() {
        return (this.fieldType || 'text').toLowerCase();
    }

    get formattedValue() {
        let formattedValue = this.value;
        if ((this.value || '').length === 0) {
            return formattedValue;
        }
        // format the value based on the field type
        try {
            if (this._fieldType === 'datetime') {
                // set formattedValue to format date using this format: MM/dd/yyyy h:mm a
                formattedValue = new Intl.DateTimeFormat(LOCALE, {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit',
                    hour12: true
                }).format(new Date(this.value));
            } else if (this._fieldType === 'date') {
                formattedValue = new Intl.DateTimeFormat(LOCALE).format(
                    new Date(this.value)
                );
            }
        } catch (e) {
            formattedValue = this.value;
        }
        return formattedValue || '';
    }
}