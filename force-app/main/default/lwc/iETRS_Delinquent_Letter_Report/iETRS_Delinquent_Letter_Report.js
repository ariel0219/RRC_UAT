import { LightningElement, wire } from 'lwc';
import getIPCorrespondenceDates from '@salesforce/apex/IETRS_Delinquent_Letters_Rep.getIPCorrespondenceDates';
import getIPCorrespondenceDatesWrapper from '@salesforce/apex/IETRS_Delinquent_Letters_Rep.getIPCorrespondenceDatesWrapper';


const columns = [
    {
        label: "Inspection Package ID #", fieldName: "InspectionPackageID",
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_self'
        }
    },
    { label: "POC Due Date", fieldName: "POCDueDate", type: "date-local",typeAttributes: {
        year: "numeric",
        month: "numeric",
        day: "numeric"
    } },
    { label: "Days Old", fieldName: "DaysOld", type: "Number" },
    { label: "Organization", fieldName: "Organization", type: "text" },
    { label: "Unit", fieldName: "Unit", type: "text" }];

/*
const columns = [
    { label: 'Opportunity name', fieldName: 'opportunityName', type: 'text' },
    {
        label: 'Confidence', fieldName: 'confidence', type: 'percent', cellAttributes:
            { iconName: { fieldName: 'trendIcon' }, iconPosition: 'right' }
    },
    { label: 'Amount', fieldName: 'amount', type: 'currency', typeAttributes: { currencyCode: 'EUR', step: '0.001' } },
    { label: 'Contact Email', fieldName: 'contact', type: 'email' },
    { label: 'Contact Phone', fieldName: 'phone', type: 'phone' },
];

const data = [{
    id: 'a',
    opportunityName: 'Cloudhub',
    confidence: 0.2,
    amount: 25000,
    contact: 'jrogers@cloudhub.com',
    phone: '2352235235',
    trendIcon: 'utility:down'
},
{
    id: 'b',
    opportunityName: 'Quip',
    confidence: 0.78,
    amount: 740000,
    contact: 'quipy@quip.com',
    phone: '2352235235',
    trendIcon: 'utility:up'
}];*/


export default class IETRS_Delinquent_Letter_Report extends LightningElement {

    data = [];
    columns = columns;
    sortBy;
    sortDirection;


    @wire(getIPCorrespondenceDatesWrapper)
    wiredOpps(result) {
        console.log('Result Attribute ' + result.data);
        console.log(this.coloumns);
        if (result.data) {
            this.data = result.data;
            this.sortData('DaysOld', 'asc'); //This will do the Sorting.
            console.log('Data Log =>' + this.data);
        } else if (result.error) {
            this.data = undefined;
            console.log(result.error);
        }
    }

    handleSortdata(event) {
        this.sortBy = event.detail.fieldName;
        console.log(this.sortBy);
        this.sortDirection = event.detail.sortDirection;

        this.sortData(event.detail.fieldName, event.detail.sortDirection);
        console.log(this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));

        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'desc' ? 1 : -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

            return isReverse * ((x > y) - (y > x));
        });

        this.data = parseData;

    }

}