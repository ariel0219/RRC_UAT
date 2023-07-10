import { LightningElement, api, track, wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import getEntityWithDefaultValues from '@salesforce/apex/CIIS_SupplyChainAccountsController.getEntityWithDefaultValues';
import getCountyId from '@salesforce/apex/CIIS_SupplyChainAccountsController.getCounty';

import {
    countyOptions,
    gasCommodityoptions,
    pipelineStatusOptions
} from './filterFieldOptions';

const fieldByProp = {
    p5Number: 'P5_NUM',
    t4PermitNumber: 'T4PERMIT',
    gasCommodity: 'COMMODITY1',
    systemName: 'SYS_NM',
    subSystemName: 'SUBSYS_NM',
    pipesSystemName: 'PLS_SYSNM',
    pipelineStatus: 'TX_REG',
    pipelineId: 'PLINE_ID',
    diameter: 'DIAMETER',
    county: 'COUNTY'
};

const searchPrompt = 'Use the form to search for a pipeline segment';
const noResultsMessage = 'No results found. Please try again.';

export default class CiisSelectPipelineSegment extends LightningElement {
    /*
     * PROPS
     */

    @api receiverLatitude;
    @api receiverLongitude;
    @api receiverName;
    @api endpoint;
    @api supplyChainType;
    @api operatorId;
    @api p5Number;
    @api
    get t4PermitNumber() {
        return this._t4PermitNumber;
    }
    set t4PermitNumber(value) {
        this._t4PermitNumber = value;
    }
    @track _t4PermitNumber;

    @api
    get pipelineId() {
        return this._pipelineId;
    }
    set pipelineId(value) {
        this._pipelineId = value;
    }
    @track _pipelineId = '';

    @api
    get gasCommodity() {
        return this._gasCommodity;
    }
    set gasCommodity(value) {
        this._gasCommodity = value;
    }
    @track _gasCommodity;

    @api
    get systemName() {
        return this._systemName;
    }
    set systemName(value) {
        this._systemName = value;
    }
    @track _systemName;

    @api
    get subSystemName() {
        return this._subSystemName;
    }
    set subSystemName(value) {
        this._subSystemName = value;
    }
    @track _subSystemName;

    @api
    get pipesSystemName() {
        return this._pipesSystemName;
    }
    set pipesSystemName(value) {
        this._pipesSystemName = value;
    }
    @track _pipesSystemName;

    @api
    get pipelineStatus() {
        return this._pipelineStatus;
    }
    set pipelineStatus(value) {
        this._pipelineStatus = value;
    }
    @track _pipelineStatus;

    @api
    get diameter() {
        return this._diameter;
    }
    set diameter(value) {
        this._diameter = value;
    }
    @track _diameter;

    @api
    get county() {
        return this._county;
    }
    set county(value) {
        this._county = value;
    }
    @track _county;

    @api
    get segmentLatitude() {
        return this._segmentLatitude;
    }
    set segmentLatitude(value) {
        this._segmentLatitude = value;
    }
    @track _segmentLatitude;

    @api
    get segmentLongitude() {
        return this._segmentLongitude;
    }
    set segmentLongitude(value) {
        this._segmentLongitude = value;
    }
    @track _segmentLongitude;

    @api
    get selectedPipelineSegment() {
        return this._selectedPipelineSegment;
    }

    @api
    get selectedSegmentWithDetails(){
        return this._selectedSegmentWithDetails;
    }
    set selectedPipelineSegment(value) {
        this._selectedPipelineSegment = value;
    }
    @track _selectedPipelineSegment = {};

    @track isLoading = false;
    searchResults = {};
    @track emptyMessage = searchPrompt;
    @track selectedSegmentValue;
    @track selectedSegmentCollection = [];
    @track _selectedSegmentWithDetails = [];
    @track isPanelOpen = true;
    @track error;
    wireDefaultSegmentValues = {};
    @track markers = [];
    pipelineStatusOptions = pipelineStatusOptions;
    gasCommodityOptions = gasCommodityoptions;
    countyOptions = countyOptions;
    // center on the middle of TX by default
    center = {
        location: {
            Latitude: '31.0',
            Longitude: '-99.0'
        }
    };
    zoomLevel = 6;

    get hasResults() {
        return this.markers && this.markers.length && !this.isLoading;
    }

    get panelContainerClass() {
        const isOpenClass = this.isPanelOpen ? 'slds-is-open' : '';
        return `slds-panel slds-size_medium slds-panel_docked slds-panel_docked-left ${isOpenClass}`;
    }

    get hasReceiverCoordinates() {
        return this.receiverLatitude && this.receiverLongitude;
    }

    /*
     * LIFECYCLE HOOKS
     */

    connectedCallback() {
        // if we have lat/long, center the map on that location
        if (this.receiverLatitude && this.receiverLongitude) {
            this.center = {
                location: {
                    Latitude: `${this.receiverLatitude || '31.0'}`,
                    Longitude: `${this.receiverLongitude || '-99.0'}`
                }
            };
            this.zoomLevel = 12;
            this.search(true);
        }
    }

    /*
     * METHODS
     */

    @api
    validate() {
        if (this.selectedSegmentValue) {
            return { isValid: true };
        }
        return {
            isValid: false,
            errorMessage: 'Please selected a pipeline segment to continue'
        };
    }

    @wire(getEntityWithDefaultValues, {
        supplyChainType: '$supplyChainType',
        operatorId: '$operatorId'
    })
    wiredDefaultValues({ error, data }) {
        if (data) {
            this.error = undefined;
            this._selectedPipelineSegment = { ...data };
            this.wireDefaultSegmentValues = { ...data };
        } else if (error) {
            console.log('error ', error);
            this.error = error.body.message;
        }
    }

    buildMapMarkers() {
        const markerColors = [
            '#177E89',
            '#084C61',
            '#DB3A34',
            '#FFC857',
            '#323031'
        ];
        const markers = [];
        if (this.receiverLatitude && this.receiverLongitude) {
            markers.push(this.getReceiverMarker());
        }
        this.searchResults.features?.forEach((feature, i) => {
            const paths = this.getPaths(feature.geometry.paths[0]);
            const roundedDiameter = parseFloat(
                Number.parseFloat(feature.attributes.DIAMETER).toFixed(2)
            );
            const roundedLength = parseFloat(
                Number.parseFloat(
                    feature.attributes.ALBERS_MILES || 0.0
                ).toFixed(2)
            );
            let markerColor = markerColors[i % markerColors.length];
            markers.push({
                paths,
                location: {
                    Latitude: `${paths[0].lat}`,
                    Longitude: `${paths[0].lng}`
                },
                title: `${feature.attributes.TPMS_ID}`,
                type: 'Polygon',
                strokeColor: markerColor,
                strokeOpacity: 0.75,
                strokeWeight: roundedDiameter,
                fillColor: markerColor,
                fillOpacity: 0.75
            });
            // show alber miles up to 5 decimal places
            const plineId = feature.attributes.PLINE_ID
                ? `PID ${feature.attributes.PLINE_ID}`
                : ``;
            markers.push({
                location: {
                    Latitude: `${paths[0].lat}`,
                    Longitude: `${paths[0].lng}`
                },
                icon: 'utility:data_mapping',
                title: `Seg #${feature.attributes.TPMS_ID} D${feature.attributes.DIAMETER} L${roundedLength} ${plineId}`,
                description: `<strong>County:</strong> ${feature.attributes.COUNTY}<br />
                <strong>Operator:</strong> ${feature.attributes.OPER_NM}<br />
                <strong>Commodity Details:</strong> ${feature.attributes.COMMODITY1}<br />
                <strong>System Name:</strong> ${feature.attributes.SYS_NM}<br />
                <strong>Subsystem Name:</strong> ${feature.attributes.SUBSYS_NM}<br />
                <strong>Diameter:</strong> ${feature.attributes.DIAMETER}<br />
                <strong>P5 Number:</strong> ${feature.attributes.P5_NUM}<br />
                <strong>T4 Permit:</strong> ${feature.attributes.T4PERMIT}<br />
                <strong>Interstate:</strong> ${feature.attributes.INTERSTATE}<br />
                <strong>Albers Miles:</strong> ${feature.attributes.ALBERS_MILES}<br />
                <strong>Pipeline Id:</strong> ${feature.attributes.PLINE_ID}`,
                value: `${feature.attributes.TPMS_ID}`,
                mapIcon: {
                    path: 'M28 15C28 22.5575 19.611 29.309 15.1629 39.0906C14.7597 39.9774 13.3213 39.9488 12.9431 39.0511C8.8312 29.2908 0 22.5473 0 15C0 6.71573 6.26801 0 14 0C21.732 0 28 6.71573 28 15Z',
                    fillColor: markerColor,
                    fillOpacity: 0.7,
                    strokeWeight: 1,
                    strokeOpacity: 0.9,
                    strokeColor: markerColor,
                    anchor: { x: 14, y: 42 }
                }
            });
        });
        this.markers = markers;
    }

    getReceiverMarker() {
        return {
            location: {
                Latitude: `${this.receiverLatitude}`,
                Longitude: `${this.receiverLongitude}`
            },
            icon: 'utility:forward',
            title: this.receiverName,
            mapIcon: {
                path: 'M 125,5 155,90 245,90 175,145 200,230 125,180 50,230 75,145 5,90 95,90 z',
                fillColor: '#e53d3c',
                fillOpacity: 0.8,
                strokeWeight: 0,
                scale: 0.3,
                anchor: { x: 122.5, y: 115 }
            }
        };
    }

    mapSegmentToAccount() {
        const selectedSegment = this.searchResults.features.find(
            (segment) =>
                `${segment.attributes.TPMS_ID}` === this.selectedSegmentValue
        );
        const { SYS_NM, SUBSYS_NM, TPMS_ID, DIAMETER, T4PERMIT } =
            selectedSegment.attributes;
        return {
            Name: `${SYS_NM} ${DIAMETER}"`,
            CIIS_Pipeline_Diameter__c: parseFloat(DIAMETER || 0),
            CIIS_PL_Facility_ID__c: `${TPMS_ID}`,
            IETRS_T4_Permit__c: `${T4PERMIT}`,
            CIIS_Pipeline_System_Name__c: SYS_NM,
            CIIS_Pipeline_Sub_System_Name__c: SUBSYS_NM
        };
    }
    mapSegmentToAccount2(selectedSeg, segLat, segLong, county) {
        const selectedSegment = this.searchResults.features.find(
            (segment) =>
                `${segment.attributes.TPMS_ID}` === selectedSeg
        );
        const { SYS_NM, SUBSYS_NM, TPMS_ID, DIAMETER, T4PERMIT } =
            selectedSegment.attributes;
        return {
            Name: `${SYS_NM} ${DIAMETER}"`,
            CIIS_Pipeline_Diameter__c: parseFloat(DIAMETER || 0),
            CIIS_PL_Facility_ID__c: `${TPMS_ID}`,
            IETRS_T4_Permit__c: `${T4PERMIT}`,
            CIIS_Pipeline_System_Name__c: SYS_NM,
            CIIS_Pipeline_Sub_System_Name__c: SUBSYS_NM,
            IETRS_Latitude__c: segLat,
            IETRS_Longitude__c: segLong,
            IETRS_County__c: county.Id,
            CIIS_County_Name__c: county.Name
        };
    }

    async getSearchResults(searchByReceiverLocation) {
        const queryString = this.getQueryString();
        const params = this.getEndpointParams(searchByReceiverLocation);
        const url = `${this.endpoint}?where=${queryString}${params}`;
        console.log('callout to ', url);
        // use async/await and fetch to make a get request to the url; handle errors and return the successful response as json
        const response = await fetch(url);
        // if the response is successful, return the json; if not return the error message
        if (response.ok) {
            return response.json();
        }
        throw new Error(response.statusText);
    }

    getEndpointParams(searchByReceiverLocation) {
        let geometry = '';
        let distance = '';
        let units = '';
        let geometryType = 'esriGeometryEnvelope';
        let resultRecordCount = 50;
        // distance=99000&units=esriSRUnit_Meter
        const currentCenter =
            this.template.querySelector('lightning-map')?.center;
        console.log(currentCenter);
        if (searchByReceiverLocation) {
            geometry = encodeURIComponent(
                `${this.receiverLongitude},${this.receiverLatitude}`
            );
            distance = '800';
            units = 'esriSRUnit_Meter';
            geometryType = 'esriGeometryPoint';
        }
        return `&text=&objectIds=&time=&geometry=${geometry}&geometryType=${geometryType}&distance=${distance}&units=${units}&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&having=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&resultRecordCount=${resultRecordCount}&returnExtentOnly=false&datumTransformation=&parameterValues=&rangeValues=&quantizationParameters=&f=json`;
    }

    getQueryString() {
        const defaultFilters = `STATUS_CD = 'I'`;
        const filterEls = this.template.querySelectorAll(
            'c-ciis-search-filter'
        );
        let result;
        if (filterEls && filterEls.length) {
            result = [...filterEls].reduce((acc, filter, i) => {
                const filterName = filter.dataset.filter;
                if ((filter.value || '').length) {
                    const filterValue =
                        filter.filterOperator === 'LIKE'
                            ? `%${filter.value}%`
                            : filter.value;
                    acc += ` and ${fieldByProp[filterName]} ${filter.filterOperator} '${filterValue}'`;
                }
                return acc;
            }, defaultFilters);
        } else {
            result = `${defaultFilters} and P5_NUM = '${this.p5Number}'`;
        }
        // url encode the query string
        return encodeURIComponent(result).replace(/%20/g, '+');

        // const queryString = `TX_REG = 'Y' and P5_NUM = '036599' and T4PERMIT = '91578' and SUBSYS_NM LIKE '%ATMOS%' and COMMODITY1 LIKE '%NG%' and PLINE_ID LIKE '%RRC%' and SYS_NM LIKE '%O1%'`;
    }

    getPaths(paths) {
        if (!paths) {
            return [];
        }
        // transform the paths into the format the map component expects
        const transformedPaths = paths.map((path) => {
            const [lng, lat] = path;
            return { lat, lng };
        });
        // close the polygon by reversing the paths back to the beginning
        const newPaths = [
            ...transformedPaths,
            ...transformedPaths.slice(0, -1).reverse()
        ];
        return newPaths;
    }

    /*
     * EVENT HANDLERS
     */

    async handleMarkerSelect(event) {
        this.selectedSegmentValue = event.target.selectedMarkerValue;
        if(event.target.selectedMarkerValue != '' && event.target.selectedMarkerValue != undefined &&  !this.selectedSegmentCollection.includes(event.target.selectedMarkerValue)){
            this.selectedSegmentCollection = [...this.selectedSegmentCollection, this.selectedSegmentValue ];
            
            
        
        const selectedMarker = this.markers.find(
            (marker) => marker.value === this.selectedSegmentValue
        );
        const selectedSegment = this.searchResults.features.find(
            (segment) =>
                `${segment.attributes.TPMS_ID}` === this.selectedSegmentValue
        );
        const countyCode =  selectedSegment.attributes.COUNTY;
        let countyDetails = await getCountyId({ OGCode: countyCode });
        console.log('countyDetails ==>'  +countyDetails);
        let segmentLatitude;
        let segmentLongitude;
        if (selectedMarker && selectedMarker.location) {
            segmentLatitude = `${selectedMarker.location.Latitude}`;
            segmentLongitude = `${selectedMarker.location.Longitude}`;
        }
        this._segmentLatitude = segmentLatitude;
        this._segmentLongitude = segmentLongitude;


        const obj = this.mapSegmentToAccount2(this.selectedSegmentValue, segmentLatitude, segmentLongitude, countyDetails);
        let segObj = {... obj, ...this.wireDefaultSegmentValues };
            this._selectedSegmentWithDetails.push(segObj);
            console.log(this._selectedSegmentWithDetails);

    }
    this._selectedPipelineSegment = {
        ...this._selectedPipelineSegment,
        ...this.mapSegmentToAccount(),
    };
        // update selected pipeline lat/lng
        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'segmentLatitude',
                this._segmentLatitude
            )
        );
        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'segmentLongitude',
                this._segmentLongitude
            )
        );

        // update selected pipeline segment attribute
        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'selectedSegmentWithDetails',
                this._selectedSegmentWithDetails
            )
        );
    }
    handleClearSelectedSegmentFromList(event){
        var index = this.selectedSegmentCollection.indexOf(event.target.dataset.seg);
        console.log(index);
        if (index > -1) {
        this.selectedSegmentCollection.splice(index, 1);
        }
        index = this._selectedSegmentWithDetails.findIndex(obj => obj.CIIS_PL_Facility_ID__c === event.target.dataset.seg);
        if (index > -1) {
            this._selectedSegmentWithDetails.splice(index, 1);
        }
        // update selected pipeline segment attribute
        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'selectedSegmentWithDetails',
                this._selectedSegmentWithDetails
            )
        );
            
    }
    handleTogglePanelClick() {
        this.isPanelOpen = !this.isPanelOpen;
    }

    handleClearSelectedSegment() {
        this.selectedSegmentValue = null;
    }

    handleFilterChange(event) {
        const filterName = event.target.dataset.filter;
        const filterValue = event.detail.value;
        console.log(filterName, filterValue);
        this[filterName] = filterValue;
    }

    handleSearchClick() {
        this.search();
    }

    async search(searchByReceiverLocation) {
        this.isLoading = true;
        this.selectedSegmentValue = null;
        this.emptyMessage = noResultsMessage;
        try {
            this.searchResults = await this.getSearchResults(
                searchByReceiverLocation
            );
        } catch (error) {
            this.error = error;
            this.searchResults = {};
        }
        this.buildMapMarkers();
        this.isLoading = false;
        this.isPanelOpen = false;
    }

    handlePipelineSegmentChange(event) {
        const value = event.currentTarget.value;
        if ((value || value === '').length) {
            this.selectedSegmentValue = value;
        }
    }

    async getCountyRerord(countyCode){
        const result = '';
        try {
            result = await getCountyId({ OGCode: countyCode });
            
        } catch (error) {
            console.log(error);
        }
        return result;
    }
}