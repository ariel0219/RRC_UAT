import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountID from "@salesforce/apex/IETRS_GetSingleAccount.getAccountID";
import getDomainName from "@salesforce/apex/IETRS_GetDomainName.getDomainName";


export default class IETRS_Conga_Composer_Other_Reports_Card extends NavigationMixin(LightningElement) {
    @track asofDate;
    @api templateID;
    @api congaQueries;
    @api recordID;
    @api cardTitle;
    @api reportDescription;
    @api showAsOfDate;
    acctId = '';
    domainName = '';

    
    connectedCallback() {

        if(this.showAsOfDate){
            const dtToday = new Date();
            this.asofDate = dtToday.toISOString();
        }
    
        //Initialize Account ID variable to ensure it is set before the button click handler fires
        //THIS COULD BE REPLACED WITH A @WIRE CALL TO THE GETLISTUI API AND SOME OBJECT MANIPULATION TO AVOID USING APEX
        if(this.recordID === ''){
            getAccountID()
            .then(result => {
                this.recordID = result;       
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Application Warning',
                    message: error.message,
                    variant: 'warning',
                    mode: 'pester'
                });
                this.dispatchEvent(evt);
            });
        }
        //Initialize Domain ID variable to ensure it is set before the button click handler fires
        getDomainName()
        .then(result => {
            this.domainName = result;       
        })
        .catch(error => {
            const evt = new ShowToastEvent({
                title: 'Application Warning',
                message: error.message,
                variant: 'warning',
                mode: 'pester'
            });
            this.dispatchEvent(evt);
        });
        
    }

    //Handle the As Of Date input field On Change event to set the asofDate variable for the report query
    handleDateInput(event){
    this.asofDate = event.target.value;
    }   

    buttonHandlerGenerateReport() {
        //On Generate Report button click, generate the url given page builder parameters and navigate to the conga composer page
        //ex. templateID = a1Br0000001bKZHEA2
        //ex. congaQueries = [Common]a13r0000000rptvAAA,[OperatorsCount]a13r0000000wzLgAAI,[OperatorsInspected]a13r0000000wzLlAAI,[UnitsCount]a13r0000000wzLvAAI,[UnitsInspected]a13r0000000wzLqAAI
        //ex. domainName = rrctx--inspdev
    
        let congaQueriesRep = this.congaQueries.replace(/{asofdate}/gi, this.asofDate);
    
        let url = "https://"+ this.domainName +".lightning.force.com/apex/APXTConga4__Conga_Composer?serverUrl={!API.Partner_Server_URL_370}&id="+ this.recordID + "&TemplateiD="+ this.templateID +"&DefaultPDF=1&QueryID="+ congaQueriesRep
          
        this[NavigationMixin.Navigate]({
          type: "standard__webPage",
          attributes: {
            url: url
          }
          });
      }

}