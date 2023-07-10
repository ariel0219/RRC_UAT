import { LightningElement, api,track } from 'lwc';
import {FlowAttributeChangeEvent,FlowNavigationNextEvent} from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import INSTRUCTION_PDF from '@salesforce/resourceUrl/GscMassUploadInstruction';
import TEMPLATE_CSV from '@salesforce/resourceUrl/GscMassUploadTemplate';
import validateMassUploadData from '@salesforce/apex/CIIS_MassUploadController.validateMassUploadData';
 

/**
 * A simple parser for UTF-8 encoded, comma separated .csv files.
 * @alias CsvToDatatable
 * @extends LightningElement 
 * @hideconstructor
 *
 * @example
 * <c-csv-to-datatable></c-csv-to-datatable>
 */
export default class CiisMassUploadComponent extends NavigationMixin(LightningElement) {
  @track recordId;
  @track columns = [];
  @track data = [];
  
  @track isValidationExecuted=false;
  @track GscMassUploadInstruction=INSTRUCTION_PDF;
  @track GscMassUploadTemplate=TEMPLATE_CSV;
  @track disableButton=true;
  @track isLoading=false;

  //Upload Messages
  @track fileName = '';
  @track uploadSuccessMessage='';
  @track uploadErrorMessage='';
  @track uploadDefaultMessage='No file uploaded yet.'
  
  @api availableActions = [];
  @api csvAccountList=[];
  

  connectedCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        this.recordId = urlParams.get('operatorId');
  }

    gotoHomePage(event) {
        console.log(recordId);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'GSC_Home_Page__c'
            },
            state: {
                recordId: this.recordId
            }
        });
    }



    get acceptedFormats() {
        return ['.csv'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log('No. of files uploaded : ' + JSON.stringify(uploadedFiles[0]));

    }

    handleClick(event){    
      try{
      console.log(this.userInput);
      const attributeChangeEvent = new FlowAttributeChangeEvent(
          'userInput',
          this.uploadMessage
      );
      this.dispatchEvent(attributeChangeEvent);
      }catch(e){
          console.log(e);
      }
    }

  handleFileUpload(event) {
    this.data=[];
    this.fileName='';
    this.columns=[];
    this.disableButton=true;

    const files = event.detail.files;

    if (files.length > 0) {
      const file = files[0];
      this.fileName = file.name;
      this.read(file);
    }
  }

  async read(file) {
    try {
      const result = await this.load(file);
      this.parse(result);
    } catch (e) {
      this.uploadErrorMessage='Selected file :'+this.fileName + ' is invlid, please choose the right CSV template for mass upload';
      this.uploadDefaultMessage='';
      this.uploadSuccessMessage='';
      this.error = e;
    }
  }

  async load(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();

      reader.onload = () => {
        resolve(reader.result);
      };
      reader.onerror = () => {
        reject(reader.error);
      };
      reader.readAsText(file);
    });
  }

  parse(csv) {
    const lines = csv.split(/\r\n|\n/);

    const headers = lines[0].split(',');
    
    this.columns = headers.map((header) => {
      return { label: header, fieldName: header };
    });

    const data = [];
    lines.forEach((line, i) => {
      if (i === 0) return;

      const obj = {};
      if(line===undefined || line.trim()===''){
        return;
      }
      const currentline = line.split(',');
      for (let j = 0; j < headers.length; j++) {
        obj[headers[j]] = currentline[j];
      }
      data.push(obj);
    });
    this.data = data;
    if(data.length>0){
      this.disableButton=false;
    }else{
      this.uploadErrorMessage='Selected file :'+this.fileName + ' do not contains record(s), please choose the right CSV template for mass upload';
      this.uploadDefaultMessage='';
      this.uploadSuccessMessage='';
    }
  }

   showNotification(message,variant,title) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.columns=[];
        this.data = [];
        this.fileName = '';
        this.isDisabled=false;
    }
    
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        //this.isValidationExecuted=false;
    }
    submitDetails(event) {
      this.isLoading=true;
      this.isValidationExecuted=true;
      console.log(JSON.stringify(event.target));
      console.log('submitDetails called---');
      var listAccountObj=[];
      this.data.forEach(record =>{
          var accountObj={};
          accountObj.IETRS_P5_Number__c=record['Supplier Operator Number'];
          accountObj.CIIS_Supply_Chain_Facility_Type__c=record['Supplier Type'];
          accountObj.IETRS_Account_ID__c=record['System ID'];
          listAccountObj.push(accountObj);
      });
      console.log(JSON.stringify(listAccountObj));
      validateMassUploadData({"operatorId":this.recordId,"listAccount":listAccountObj})
          .then((result) => {
            this.csvAccountList=result;
            this.isLoading=false;
            this.isModalOpen = false;
            this.handleGoNext()
            /*
            console.log(JSON.stringify(result));
            for (let i = 0; i < result.length; i++) {
              var record = result[i];
              if(record.Description!='' || record.Description!=undefined){
                this.uploadErrorMessage='Selected file :'+this.fileName + ', data validate error found,';
                this.uploadDefaultMessage='';
                this.uploadSuccessMessage='';
                break;
              }
            }
            this.isLoading=false;
            this.isModalOpen = false;
            this.userInput=this.uploadMessage;
            const attributeChangeEvent = new FlowAttributeChangeEvent(
                'userInput',
                this.userInput
            );
            this.dispatchEvent(attributeChangeEvent);
            */            
          })
          .catch((error) => {
              this.isLoading = false;
              this.isModalOpen = false;
              if (Array.isArray(error.body)) {
                  this.error = error.body.map((e) => e.message).join(', ');
              } else if (typeof error.body.message === 'string') {
                  this.error = error.body.message;
              }
              this.showNotification(this.error, 'error', 'Error !');
          });
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        //this.isModalOpen = false;
        //this.isFileProcessed=true;
    }

    handleGoNext() {
        // check if NEXT is allowed on this screen
        if (this.availableActions.find((action) => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }    

}