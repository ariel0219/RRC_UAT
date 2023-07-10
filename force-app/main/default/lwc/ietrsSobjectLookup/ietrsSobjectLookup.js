import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

// Apex
import searchRecords from '@salesforce/apex/IETRS_I_SObjectLookupController.searchRecords';

// Schema
import SmallPhotoUrlField from '@salesforce/schema/User.SmallPhotoUrl';

// Constants
const SearchResultClass = 'search-result df nowrap ai-center p-xs cptr';
const SearchResultSelectedClass = 'selected';
const SearchBarSelector = 'c-ietrs-search-bar';
const SearchBarClass = 'df flex-grow';
const DarkPlaceholderClass = 'dark-placeholder';
const LoadingIcon = 'standard:generic_loading';
const DefaultIcon = 'standard:record';
const UserAvatarSize = 24;
const LookupDelay = 250;

/**
 * The sobject lookup component searches for records of a provided object type.
 * It can be configured to persist a record, which shows the name in the search bar's placeholder text.
 */
export default class IetrsSobjectLookup extends LightningElement {
    /*
        PROPERTIES
    */
    @api objectName;
    @api fields = [];
    @api placeholder;
    @api persistRecord;
    @api readOnly;
    @api icon;

    userAvatarSize = UserAvatarSize;

    @track isSearching = false;
    @track searchResults;
    @track defaultIcon = LoadingIcon;
    searchBar;
    record;
    defaultFields = [];
    searchTimeout;
    searchTerm;
    searchAgain = false;
    mouseDownOnMenu;
    inputFocused;
    resultCaret;
    focusInputOnRender;
    refreshtoken;

    /*
        LIFECYCLE HOOKS
    */

    /**
     * Called after the component is first connected to the DOM.
     * Adds the SmallPhotoUrl field to the defaultFields if this is a User lookup.
     */
    connectedCallback() {
        if (this.isUserLookup) {
            this.defaultFields.push(SmallPhotoUrlField.fieldApiName);
        }
    }

    /**
     * Called after every time the component is rendered.
     * Initializes the searchBar component.
     */
    renderedCallback() {
        if (!this.searchBar) {
            this.searchBar = this.template.querySelector(SearchBarSelector);
        }
        if (this.focusInputOnRender && this.searchBar) {
            this.focusInputOnRender = false;
            this.searchBar.focusInput();
        }
    }

    /*
        WIRED DATA AND APEX CALLOUTS
    */

    /**
     * Gets the object info for Project.
     * @param {object} result - Object Info for Project.
     */
    @wire(getObjectInfo, { objectApiName: '$objectName' })
    wiredObjectInfo(result) {
        if (result.data) {
            if (result.data.themeInfo && result.data.themeInfo.iconUrl) {
                var match = result.data.themeInfo.iconUrl.match(/\/(\w+)\/(\w+)_\d+\.png/);
                if (match) {
                    this.defaultIcon = match[1] + ':' + match[2];
                } else {
                    this.defaultIcon = DefaultIcon;
                }
            } else {
                this.defaultIcon = DefaultIcon;
            }
        } else if (result.error) {
            console.log('Error getting object info: ', result.error);
        }
    }

    /**
     * Calls a back-end method to return user search results.
     */
    searchRecords() {
        if (this.isSearching) {
            this.searchAgain = true;
        } else {
            if (this.searchTimeout) {
                clearTimeout(this.searchTimeout);
            }

            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.searchTimeout = setTimeout(() => {
                if (!this.searchTerm) return;
                this.isSearching = true;
                var searchTerm = this.searchTerm;
                var searchParams = {
                    objectName: this.objectName,
                    searchTerm: searchTerm
                };
                searchRecords(searchParams)
                    .then(data => {
                        console.log(this.objectName + ' lookup results for ' + searchTerm, data);
                        this.searchResults = data;
                        if (data.length) {
                            this.setResultCaret(0);
                        }
                        this.onSearchComplete();
                    })
                    .catch(error => {
                        var errorMsg = this.getErrorMessageFromFetchResponse(error);
                        console.log(errorMsg);
                        this.onSearchComplete();
                    });
            }, LookupDelay);
        }
    }

    /* 
        PUBLIC API METHODS
    */

    /**
     * Sets the search bar's input value to a specified string.
     * @param {string} value - The value.
     */
    @api
    setSearchBarValue(value) {
        this.searchBar.setValue(value);
    }

    /**
     * Sets the record and optionally dispatches an event.
     * @param {object} record - The record to set.
     * @param {boolean} noEvent - Whether to dispatch a 'recordchange' event.
     */
    @api
    setRecord(record, noEvent) {
        console.log('setRecord');
        this.setSearchBarValue('');
        if (this.persistRecord) {
            this.record = record;
            this.refresh();
        }
        if (!noEvent) {
            this.dispatchEvent(
                new CustomEvent('recordchange', {
                    detail: {
                        record: record
                    }
                })
            );
        }
    }

    /* 
        EVENT LISTENERS
    */

    /**
     * Handles when a search is completed. Resets the searchTimeout and calls searchRecords again if necessary.
     */
    onSearchComplete() {
        this.isSearching = false;
        this.searchTimeout = null;
        if (this.searchAgain) {
            this.searchAgain = false;
            this.searchRecords();
        }
    }

    /**
     * Event listener - Triggered by 'valuechange' event on the search bar.
     * Initiates a lookup if necessary.
     * @param  {Event} evt - The event.
     */
    onTextInputChange(evt) {
        if (evt.detail.value && evt.detail.value.length > 1) {
            if (evt.detail.value !== this.searchTerm) {
                this.searchTerm = evt.detail.value;
                this.searchRecords();
            }
        } else {
            this.clearSearchResults();
        }
    }

    /**
     * Event listener - Triggered by 'keydown' event on the search bar.
     * The up arrow key decrements the highlighted index, while the down arrow key increments it.
     * Pressing enter will set the selected record to the highlighted search result.
     * @param  {Event} evt - The event.
     */
    onTextInputKeyDown(evt) {
        if (this.searchResults) {
            var key = evt.keyCode;
            if (key === 'ArrowUp') {
                evt.preventDefault();
                this.setResultCaret(this.resultCaret - 1);
            } else if (key === 'ArrowDown') {
                evt.preventDefault();
                this.setResultCaret(this.resultCaret + 1);
            } else if (key === 'Enter') {
                evt.preventDefault();
                this.setSelectedRecord(this.searchResults[this.resultCaret]);
                this.clearSearchResults();
                evt.target.blurInput();
            }
        }
    }

    /**
     * Event listener - Triggered by 'mousedown' event on the search results menu.
     * Sets a flag to prevent search results from clearing when the search bar input is blurred.
     */
    onMenuMouseDown() {
        this.mouseDownOnMenu = true;
    }

    /**
     * Event listener - Triggered by 'mouseleave' event on the search results menu.
     * Sets a flag to allow search results to clear when the search bar input is blurred.
     * Conditionally clears the search results menu if the input is already blurred.
     */
    onMenuMouseLeave() {
        this.mouseDownOnMenu = false;
        if (!this.inputFocused) {
            this.clearSearchResults();
        }
    }

    /**
     * Event listener - Triggered by 'focus' event on the search bar.
     * Sets a flag to prevent search results from clearing when the menu receives a 'mouseleave' event.
     * @param  {Event} evt - The event.
     */
    onTextInputFocus(evt) {
        this.inputFocused = true;
    }

    /**
     * Event listener - Triggered by 'blur' event on the search bar.
     * Sets a flag to allow search results to clear when the menu receives a 'mouseleave' event.
     * Conditionally clears the search results menu if the user is not clicking on it.
     * @param  {Event} evt - The event.
     */
    onTextInputBlur(evt) {
        if (!this.mouseDownOnMenu) {
            this.clearSearchResults();
        }
        this.inputFocused = false;
    }

    /**
     * Event listener - Triggered by 'clear' event on the search bar.
     * Unassigns the user.
     * @param  {Event} evt - The event.
     */
    onTextInputClear(evt) {
        this.clearSearchResults();
        if (this.persistRecord && evt.detail.softClear) {
            this.setRecord(null);
        }
    }

    /**
     * Event listener - Triggered by 'click' on a search result.
     * @param  {Event} evt - The event.
     */
    onSearchResultClick(evt) {
        var index = parseInt(evt.currentTarget.dataset.index);
        this.setSelectedRecord(this.searchResults[index]);
        this.clearSearchResults();
    }

    /* 
        PRIVATE CLASS METHODS
    */

    refresh() {
        this.refreshtoken = new Date().getTime();
    }

    /**
     * Sets the selected record and dispatches an event to be handled by the parent.
     * @param {object} record - The record.
     */
    setSelectedRecord(record) {
        this.searchResults = null;
        delete record.$class;
        this.setRecord(record);
        if (!this.persistRecord) {
            this.focusInputOnRender = true;
        }
    }

    /**
     * Clears the search results to hide the menu.
     */
    clearSearchResults() {
        this.searchTerm = null;
        this.searchResults = undefined;
    }

    /**
     * Sets the resultCaret index, which determines the search result to mark as highlighted.
     * @param {number} value - The index in searchResults to set as highlighted.
     */
    setResultCaret(value) {
        this.resultCaret = Math.max(0, Math.min(value, this.searchResults.length - 1));
        this.searchResults.forEach(result => {
            result.$class = SearchResultClass;
        });
        var selectedClass = SearchResultClass + ' ' + SearchResultSelectedClass;
        this.searchResults[this.resultCaret].$class = selectedClass;

        var elSelector = '.' + SearchResultClass.split(' ')[0] + '[data-index="' + this.resultCaret + '"]';
        var el = this.template.querySelector(elSelector);
        if (el) {
            el.parentNode.scrollTop = el.offsetTop;
            // el.scrollIntoView({behavior: 'smooth', block: 'end', inline: 'nearest'});
        }
    }

    /**
     * Returns error message string from server FetchResponse error object.
     * See: https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.data_error .
     * @param  {object} fetchResponse - The response.
     * @returns {string} - The error message.
     */
    getErrorMessageFromFetchResponse(fetchResponse) {
        let errorMsg = 'Unknown error';
        if (fetchResponse.message) {
            errorMsg = fetchResponse.message;
        } else if (Array.isArray(fetchResponse.body)) {
            // UI API read operations, such as getRecord, return error.body as an array of objects
            errorMsg = fetchResponse.body.map(e => e.message).join(', ');
        } else {
            // UI API write operations, apex methods and network errors return error.body as an array of objects
            if (
                fetchResponse.body.output &&
                fetchResponse.body.output.errors &&
                fetchResponse.body.output.errors.length
            ) {
                errorMsg = fetchResponse.body.output.errors.map(e => e.message).join(', ');
            } else if (typeof fetchResponse.body.message === 'string') {
                errorMsg = fetchResponse.body.message;
            }
        }
        // Show the stack trace
        var e = new Error();
        if (e.stack) {
            var stack = e.stack.toString().split(/\r\n|\n/);
            if (fetchResponse === '') {
                fetchResponse = '""';
            }
            // eslint-disable-next-line no-console
            console.log(fetchResponse, '          [' + stack[1] + ']');
        }
        return errorMsg;
    }

    /* 
        GETTERS AND SETTERS
    */

    /**
     * @returns {boolean} Whether to show the search results menu.
     */
    get shouldShowResultsMenu() {
        return this.searchResults || this.isSearching;
    }

    /**
     * @returns {boolean} Whether to persist showing the clear icon if a record is set.
     */
    get shouldPersistClear() {
        return this.persistRecord && this.record;
    }

    /**
     * @returns {boolean} Whether this is a user lookup.
     */
    get isUserLookup() {
        return this.objectName === 'User';
    }

    /**
     * @returns {string} The placeholder to show in the search bar, with the record name overriding the default.
     */
    get searchBarPlaceholder() {
        return this.record ? this.record.Name : this.placeholder;
    }

    /**
     * @returns {string} The CSS class string to use for the search bar.
     */
    get searchBarClass() {
        return SearchBarClass + (this.record ? ' ' + DarkPlaceholderClass : '');
    }

    /**
     * @returns {string} The passed in icon or the default icon for the object type.
     */
    get lookupIcon() {
        return this.icon || this.defaultIcon;
    }
}