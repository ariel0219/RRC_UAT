import { LightningElement, api } from 'lwc';

export default class OutsideInstructorChildComponent extends LightningElement {
    @api getValueFromParent;
    @api indexNumber;
    get rowNumber(){
      return this.getValueFromParent+1;
    }
}