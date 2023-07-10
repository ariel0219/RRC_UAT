import { LightningElement, api, track } from 'lwc';

// Constants
const TextInputBaseClass = 'slds-input slds-p-left_x-large';
const TextInputReadOnlyClass = 'read-only';
const BaseClassDefault = 'dif pos-r ai-center w100';
const PointerClass = 'cptr';

/**
 * Simple search bar component that emits an event when the value has changed.
 */
export default class IetrsSearchBar extends LightningElement {
    /*
        PROPERTIES
    */
    @api placeholder;
    @api icon = 'utility:search';
    @api persistClear;
    @api readOnly;
    @api hideClearIcon;
    @track inputValue;
    @track inputFocused;

    /*
        LIFECYCLE HOOKS
    */

    /**
     * Called every time the component is rendered.
     */
    renderedCallback() {
        if (!this.textInput) {
            this.textInput = this.template.querySelector('.' + TextInputBaseClass);
        }
    }

    /* 
        PUBLIC API METHODS
    */

    /**
     * Sets the input value to a specified string.
     * @param {string} value - The value.
     */
    @api
    setValue(value) {
        this.inputValue = value;
    }

    /**
     * Sets the focus on the text input.
     */
    @api
    focusInput() {
        this.textInput.focus();
    }

    /**
     * Sets the focus on the text input.
     */
    @api
    blurInput() {
        this.textInput.blur();
    }

    /**
     * Selects the text input.
     */
    @api
    selectInput() {
        this.textInput.select();
    }

    /* 
        EVENT LISTENERS
    */

    /**
     * Event listener - Triggered by 'keyup' or 'paste' event on the input.
     * Listens for changes to the input.
     * @param  {Event} event - The event.
     */
    onInputChange(event) {
        this.inputValue = event.target.value;
        this.sendValueChangeEvent('valuechange');
    }

    handleSubmit(event) {
        event.preventDefault();
    }

    /**
     * Event listener - Triggered by 'focus' event on the input.
     * Relays a 'focus' event to be handled by the parent.
     */
    onInputFocus(evt) {
        evt.stopPropagation();
        this.dispatchEvent(
            new CustomEvent('focus', {
                detail: {
                    value: this.value
                }
            })
        );
        this.inputFocused = true;
        if (this.selectInputOnFocus) {
            this.selectInputOnFocus = false;
            this.selectInput();
        }
    }

    /**
     * Event listener - Triggered by 'blur' event on the input.
     * Relays a 'blur' event to be handled by the parent.
     */
    onInputBlur(evt) {
        evt.stopPropagation();
        this.dispatchEvent(new CustomEvent('blur'));
        this.inputFocused = false;
    }

    /**
     * Event listener - Triggered by clicking on the root element.
     */
    onSearchBarClick() {
        if (!this.inputFocused) {
            this.focusInput();
            this.selectInputOnFocus = true;
        }
    }

    /**
     * Event listener - Triggered by 'click' event on the clear icon.
     */
    onClearIconClick() {
        this.clearValue();
    }

    /* 
        PRIVATE CLASS METHODS
    */

    /**
     * Sends a 'valuechange' or 'clear' event to be handled by the parent.
     * @param  {string} eventType - Which event type to fire.
     * @param  {boolean} softClear - Whether this is a "soft clear", which is when there was no text to begin with.
     */
    sendValueChangeEvent(eventType, softClear) {
        this.dispatchEvent(
            new CustomEvent(eventType, {
                detail: {
                    value: this.inputValue,
                    softClear: softClear
                }
            })
        );
    }

    /**
     * Clears the search input value.
     */
    clearValue() {
        var softClear = !this.inputValue;
        this.inputValue = '';
        this.sendValueChangeEvent('clear', softClear);
    }

    /* 
        GETTERS AND SETTERS
    */

    /**
     * @returns {string} The input value or an empty string.
     */
    get value() {
        return this.inputValue || '';
    }

    /**
     * @returns {string} The CSS class string for the text input.
     */
    get textInputClass() {
        return TextInputBaseClass + (this.readOnly ? ' ' + TextInputReadOnlyClass : '');
    }

    /**
     * @returns {boolean} Whether to show the clear icon button.
     */
    get showClearIcon() {
        return !this.hideClearIcon && !this.readOnly && (this.persistClear || this.inputValue);
    }

    /**
     * @returns {string} The CSS class string for the base element.
     */
    get baseClass() {
        return (
            BaseClassDefault +
            (!this.inputFocused && !this.readOnly ? ' ' + PointerClass : '') +
            (this.readOnly ? ' ' + TextInputReadOnlyClass : '')
        );
    }
}