import { LightningElement,wire,track,api } from 'lwc';
import checkRegisterNumber from '@salesforce/apex/EEM_RegisterNumberController.checkRegisterNumber';
export default class Eem_VerifyRegisterNbr extends LightningElement {

 
 @api register_nbr;
 @api manual_amount; 
 @api myRgnb = '';

 @track myMsg;
 @track errorMsg;
 
 
   
   
    handleNumberChange(){
       
       this.myRgnb = this.register_nbr;
       checkRegisterNumber({checkRegisterNbr: this.myRgnb})
       .then(result =>{
        this.myMsg = result;
        })
        .catch(error =>{
         this.errorMsg = error;   
        })
       console.log('Calling isInputValid');
      
       if(this.isInputValid()) {
            console.log('IsInputValid : True');
        }else{
           console.log('IsInputValid : False');
        }

     }

     handleRegisterChange(event){
     this.register_nbr = event.target.value;
     }

     handleManualAmountChange(event){
      this.manual_amount = event.target.value;
      }

     isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
                console.log('In validate check inputfield lable.' +inputField.label);
            }
            
        });
        return isValid;
    }

   @api
    validate() {
        console.log('In validate method check inputfields.');
        if (!this.isInputValid()) {
            return {
                isValid: false,
                errorMessage: "<span style='font-size:20px'>" + 'Value is required. '+  "</span>"
            };
        }

        //If the component is invalid, return the isValid parameter as false and return an error message. 
        return {
            isValid: true,


        };
    }


}