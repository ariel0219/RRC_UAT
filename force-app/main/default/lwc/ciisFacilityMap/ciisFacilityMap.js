import { LightningElement, api, track } from 'lwc';

export default class CiisFacilityMap extends LightningElement {
    @api required = false;
    @api readOnly = false;

    @api
    get latitude() {
        return this._latitude;
    }
    set latitude(value) {
        this._latitude = value;
    }
    @api
    get longitude() {
        return this._longitude;
    }
    set longitude(value) {
        this._longitude = value;
    }

    zoomLevel = 8;

    @track _latitude;
    @track _longitude;
    @track hasCoordinates = false;

    connectedCallback() {
        this.hasCoordinates = this.getHasCoordinates();
    }

    get mapMarkers() {
        if (!this.hasCoordinates) {
            return [
                {
                    location: {
                        State: 'Texas'
                    }
                }
            ];
        }
        return [
            {
                location: {
                    Latitude: this._latitude,
                    Longitude: this._longitude
                },
                value: 'f1',
                title: 'Facility Location',
                icon: 'standard:account'
            }
        ];
    }

    @api
    validate() {
        if (!this.required) {
            return { isValid: true };
        }
        const inputEl = this.template.querySelector('lightning-input-location');
        const isValid = inputEl.checkValidity();
        inputEl.reportValidity();
        if (isValid) {
            return { isValid: true };
        }

        return {
            isValid: false,
            errorMessage: 'Please provide a latiude and longitude value.'
        };
    }

    handleLocationChange(evt) {
        this._latitude = evt.detail.latitude;
        this._longitude = evt.detail.longitude;
        this.hasCoordinates = this.getHasCoordinates();
    }

    getHasCoordinates() {
        console.log(
            'getHasCoordinates',
            `${this.latitude || ''}`.length > 0 &&
                `${this.longitude || ''}`.length > 0
        );
        return (
            `${this.latitude || ''}`.length > 0 &&
            `${this.longitude || ''}`.length > 0
        );
    }
}