import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOperatorList from '@salesforce/apex/CIIS_GscOperatorSelectionCtrl.getOperatorList';

const selectedOperatorStorageKey = 'selectedOperator';
export default class CiisGscOperatorSelection extends NavigationMixin(
    LightningElement
) {
    @track operators = [];
    @track isLoading = true;
    @track selectedOperator;

    get operatorOptions() {
        return this.operators.map((operator) => {
            return {
                label: operator.Name,
                value: operator.Id
            };
        });
    }

    /**
     * Returns true if operators are available and component is done retrieving data from server
     */
    get hasOperators() {
        return this.operators.length > 0;
    }

    //Commented this code due to infinite refresh browser url.

    @wire(getOperatorList)
    wiredOperators({ error, data }) {
        if (data) {
            this.operators = data;
            this.isLoading = false;
            const urlParams = new URLSearchParams(window.location.search);
            const recordId = urlParams.get('recordId');
            if (recordId) {
                this.selectedOperator = recordId;
                this.saveSelectedIdToLocalStorage();
            } else {
                // use the local storage value if available
                const selectedOperatorFromLocalStorage = localStorage.getItem(
                    selectedOperatorStorageKey
                );
                if (
                    selectedOperatorFromLocalStorage &&
                    data.some(
                        (operator) =>
                            operator.Id === selectedOperatorFromLocalStorage
                    )
                ) {
                    this.selectedOperator = selectedOperatorFromLocalStorage;
                    this.navigateToSelectedOperator(true);
                }
            }

            if (
                !this.selectedOperator &&
                data !== undefined &&
                data.length > 0
            ) {
                this.selectedOperator = data[0].Id;
                /*
                if(this.selectedOperator.length>15){
                    this.selectedOperator=this.selectedOperator.substring(0,15);
                }*/
                this.navigateToSelectedOperator(true);
            }
        } else if (error) {
            this.isLoading = false;
            if (Array.isArray(error.body)) {
                this.error = error.body.map((e) => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            this.showNotification(this.error, 'error', 'Error !');
        }
    }

    /*
    connectedCallback() {
        // todo: get oeprators with wire service
        this.isLoading = true;
        const urlParams = new URLSearchParams(window.location.search);
        const recordId = urlParams.get('recordId');
        if (recordId) {
            this.selectedOperator = recordId;
        }
        // feetching data from server has moved to wire method but it was going in infinite loop....need to fix
        this.getRecord();
    }
    
    getRecord() {
        this.isLoading = true;
        getOperatorList()
            .then((data) => {
                this.operators = data;
                this.isLoading = false;
                if (!this.selectedOperator) {
                    this.selectedOperator = this.operators[0].Id;
                    this.navigateToSelectedOperator(true);
                }
            })
            .catch((error) => {
                this.isLoading = false;
                if (Array.isArray(error.body)) {
                    this.error = error.body.map((e) => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.error = error.body.message;
                }
                this.showNotification(this.error, 'error', 'Error !');
            });
    }
    */

    changeHandler(event) {
        this.selectedOperator = event.target.value;
        /*
        if(this.selectedOperator.length>15){
            this.selectedOperator=this.selectedOperator.substring(0,15);
        }*/
        this.navigateToSelectedOperator(false);
        this.saveSelectedIdToLocalStorage();
    }

    saveSelectedIdToLocalStorage() {
        localStorage.setItem(selectedOperatorStorageKey, this.selectedOperator);
    }

    navigateToSelectedOperator(replaceHistory) {
        const { origin, pathname, search } = document.location;
        if (!this.selectedOperator) {
            return;
        }
        const newSearch =
            search.replace(
                /recordId=[^&]*/,
                'recordId=' + this.selectedOperator
            ) || '?recordId=' + this.selectedOperator;
        this[NavigationMixin.Navigate](
            {
                type: 'standard__webPage',
                attributes: {
                    url: origin + pathname + newSearch
                }
            },
            replaceHistory
        );
    }

    showNotification(message, variant, title) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}