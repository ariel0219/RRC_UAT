import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class EEM_AFS_Listview extends NavigationMixin(LightningElement) {

navigatetoLPGInitialCourseListview(){
    
this[NavigationMixin.Navigate]({
        type:'standard__objectPage',
        attributes:{
            objectApiName:'EEM_Event__c',
            actionName:'list'
        },
        state:{
            filterName:'00Bt0000001eWCNEA2'
        },
    });
}
navigateToLPGContinuing()
{
this[NavigationMixin.Navigate]({
        type:'standard__objectPage',
        attributes:{
            objectApiName:'EEM_Event__c',
            actionName:'list'
        },
        state:{
            filterName:'00Bt0000001eWCLEA2'
        },
    });
}
navigateToInPersonExam()
{
this[NavigationMixin.Navigate]({
        type:'standard__objectPage',
        attributes:{
            objectApiName:'EEM_Event__c',
            actionName:'list'
        },
        state:{
            filterName:'00Bt0000001eWCKEA2'
        },
    });
}
navigateToOnlineExam()
{
this[NavigationMixin.Navigate]({
        type:'standard__objectPage',
        attributes:{
            objectApiName:'EEM_Event__c',
            actionName:'list'
        },
        state:{
            filterName:'00Bt0000001eWCOEA2'
        },
    });
}


}