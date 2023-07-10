import { LightningElement, track, api, wire } from 'lwc';
import pubsub from 'c/iETRS_PLI_PubSub';

//Added by Ayesha on 4th DEC 2020
import fetchNotificationSRCRecodsOnRefresh from '@salesforce/apex/IETRS_PLI_LWCQuery.fetchNotificationSRCRecodsOnRefresh';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import deleteNotificationRecordById from '@salesforce/apex/IETRS_PLI_LWCQuery.deleteNotificationRecordById';
import isCurrentUserPortalUser from '@salesforce/apex/IETRS_PLI_LWCQuery.isCurrentUserPortalUser';
import identifyPortalUserAcessOrganization from '@salesforce/apex/IETRS_PLI_LWCQuery.identifyPortalUserAcessOrganization';
import getAccountIdByNotificationIdForSRCAndImp from '@salesforce/apex/IETRS_PLI_LWCQuery.getAccountIdByNotificationIdForSRCAndImp';

const actions = [
  { label: "Show details", name: "show_details" },
  { label: "Delete", name: "delete" }
];
const columns = [
  { label: "PHMSA SRC #", fieldName: "IETRS_PHMSA_SRC_ID__c", type: "text" },
  { label: "Organization name", fieldName: "Organization_Name", type: "text" },
  { label: "P5 Number", fieldName: "IETRS_P5_Number_Formula__c", type: "text" },
  { label: "Regulated Entity Name", fieldName: "System_Name", type: "text" },
  { label: "Regulated Entity ID", fieldName: "IETRS_Regulated_Entity_ID__c", type: "text" },
  { label: "Date of Discovery", fieldName: "IETRS_Date_of_Discovery__c", type: "text" },
  { label: "Created Date", fieldName: "CreatedDate", type: "Date" },
  { label: "Created By", fieldName: "CreatedBy", type: "text" },
  { label: "Status", fieldName: "IETRS_Status__c", type: "text" },
  { label: "Lead Inspector", fieldName: "Lead_Inspector", type: "text" },
  {
    label: "Attached File", fieldName: "Attached_File", type: "text",
    typeAttributes: { label: { fieldName: "IETRS_Attached_File_Correspondence_r.Name" }, tooltip: "Attach File", target: "_self" }
  },
  /*{ label: "Leak Location", fieldName: "LeakLocation", type: "text" },
  { label: "Pipe Size", fieldName: "PipeSize", type: "text" },
  { label: "Pipe Type", fieldName: "pipeType", type: "text" },
  {
    label: "Leak Classification",
    fieldName: "LeakClassification",
    type: "text"
  },*/
  {
    type: "action",
    typeAttributes: { rowActions: actions }
  }
];
const columnsIMP = [
  { label: "PHMSA IMP #", fieldName: "IETRS_PHMSA_IMP_ID__c", type: "text" },
  { label: "Organization name", fieldName: "Organization_Name", type: "text" },
  { label: "P5 Number", fieldName: "IETRS_P5_Number_Formula__c", type: "text" },
  { label: "Regulated Entity Name", fieldName: "System_Name", type: "text" },
  { label: "Regulated Entity ID", fieldName: "IETRS_Regulated_Entity_ID__c", type: "text" },
  { label: "Date of Discovery", fieldName: "IETRS_Date_of_Discovery__c", type: "text" },
  { label: "Created Date", fieldName: "CreatedDate", type: "Date" },
  { label: "Created By", fieldName: "CreatedBy", type: "text" },
  { label: "Status", fieldName: "IETRS_Status__c", type: "text" },
  { label: "Lead Inspector", fieldName: "Lead_Inspector", type: "text" },
  {
    label: "Attached File", fieldName: "Attached_File", type: "text",
    typeAttributes: { label: { fieldName: "IETRS_Attached_File_Correspondence__r.Name" }, tooltip: "Attach File", target: "_self" }
  },
  /*{ label: "Leak Location", fieldName: "LeakLocation", type: "text" },
  { label: "Pipe Size", fieldName: "PipeSize", type: "text" },
  { label: "Pipe Type", fieldName: "pipeType", type: "text" },
  {
    label: "Leak Classification",
    fieldName: "LeakClassification",
    type: "text"
  },*/
  {
    type: "action",
    typeAttributes: { rowActions: actions }
  }
];

export default class IERTS_PLI_SRC_ReportList extends LightningElement {
  @api getDataSRCreports = [];
  @track columns;// = columns;
  @track notificationID;

  //For modal
  @track shownew;
  @track recordId;
  @track showedit;
  @track bShowModal;
  @track showError = false;
  //NEw Notification Record Id
  newNotificationRecId;

  //Added by Ayesha for receive on the Operator or System or P5 Number
  @track operatorName;
  @track systemName;
  @track psNumber;
  @track accountRecordId = '';
  recordTypeId;
  isSRC;


  /* javaScipt functions start */
  connectedCallback() {
    this.regiser();
  }
  regiser() {
    //window.alert('event registered ');
    pubsub.register('getSRCDataRecordsEVT', this.handleEvent.bind(this));
  }
  handleEvent(messageFromEvt) {
    console.log('messageFromEvt====>' + JSON.stringify(messageFromEvt));
    //var getReportRecordData = JSON.stringify(messageFromEvt.setDataSRCstr); 
    //Added by Ayesha for receive on the Operator or System or P5 Number

    var SRCLst = JSON.parse(messageFromEvt.setDataSRCstr);
    this.operatorName = messageFromEvt.operatorName;
    this.systemName = messageFromEvt.systemName;
    this.psNumber = messageFromEvt.psNumber;
    this.getDataSRCreports = SRCLst;
    this.recordTypeId = messageFromEvt.recordTypeId;
    this.getValuePS_TABs = messageFromEvt.getValuePS_TABs;
    if (this.getValuePS_TABs == 'SRC') {
      this.isSRC = true;
      this.columns = columns;
    }
    else {
      this.columns = columnsIMP;
    }
    this.notificationID = messageFromEvt.notificationID;
    for (var i = 0; i < SRCLst.length; i++) {
      //alert('SRCLST 1st=>'+SRCLST[i].IETRS_Organization__r.Name);
      var row = SRCLst[i];
      if (row !== null) {
        if (row.IETRS_Organization__c) {
          row.Organization_Name = row.IETRS_Organization__r.Name;
        }
        if (row.CreatedBy) {
          row.CreatedBy = row.CreatedBy.Name;
        }
        if (row.IETRS_Regulated_Entity__c) {
          row.System_Name = row.IETRS_Regulated_Entity__r.Name;
        }
        if (row.IETRS_Inspector__c) {
          row.Lead_Inspector = row.IETRS_Inspector__r.Name;
        }
        if (row.CreatedDate) {
          row.CreatedDate = row.CreatedDate.split("T")[0];
        }
        if (row.IETRS_Attached_File_Correspondence__c) {
          row.Attached_File = row.IETRS_Attached_File_Correspondence__r.IETRS_File_Name__c;
        }

        /*if(row.CreatedDate){
            let dt = row.CreatedDate;//new Date();
            const dtf = new Intl.DateTimeFormat('en', {
                year: 'numeric',
                month: 'short',
                day: '2-digit'
            })
            const [{value: mo}, , {value: da}, , {value: ye}] = dtf.formatToParts(dt);

            row.CreatedDate = `${da}-${mo}-${ye}`;
            console.log('formatedDate ===> '+row.CreatedDate);
        }*/
      }

    }

    /*getAccountIdByNotificationIdForSRCAndImp({ operatorName: this.operatorName }).then(result => {
      if (result != null && result != '') {
        this.accountRecordId = result;
      }
    }).catch(error => {
      console.error(error);
    })*/


  }
  handleOnselect(event) {
    const value = true;
    const valueChangeEvent = new CustomEvent("valuechangeSrc", {
      detail: {
        value
      }
    });
    this.dispatchEvent(valueChangeEvent);
    var selectedVal = event.detail.value;
    var convertJSON = JSON.stringify(selectedVal);
    let message = {
      "viewDetails": convertJSON,
    }
    pubsub.fire('viewDetails', message);
  }

  //Added by AYesha on 4th DEC 2020
  @api refreshNotificationDetailsLst() {
    //Get the Ids of all notification
    var notificationList = this.getDataSRCreports;
    console.log('getDataSRCreports=>' + JSON.stringify(notificationList));
    var notificationIds = [];
    for (var i = 0; i < notificationList.length; i++) {
      if (notificationList[i].Id != null) {
        notificationIds.push(notificationList[i].Id);
      }
    }
    //Add if new Notification Record is created for referesh
    if (this.newNotificationRecId != null) {
      notificationIds.push(this.newNotificationRecId);
    }
    if (notificationIds.length > 0) {
      console.log('notificationIds=>' + notificationIds);
      fetchNotificationSRCRecodsOnRefresh({ recordSet: notificationIds })
        .then(result => {
          //this.getNotificationDetailsLst = null;
          //this.getNotificationDetailsLst = result;
          var SRCLst = result;//JSON.parse(result);

          this.getDataSRCreports = SRCLst;
          console.log('getDataSRCreports==>' + JSON.stringify(SRCLst));
          for (var i = 0; i < SRCLst.length; i++) {
            //alert('SRCLST 1st=>'+SRCLST[i].IETRS_Organization__r.Name);
            var row = SRCLst[i];
            if (row !== null) {
              if (row.IETRS_Organization__c) {
                row.Organization_Name = row.IETRS_Organization__r.Name;
              }
              if (row.CreatedBy) {
                row.CreatedBy = row.CreatedBy.Name;
              }
              if (row.IETRS_Regulated_Entity__c) {
                row.System_Name = row.IETRS_Regulated_Entity__r.Name;
              }
              if (row.IETRS_Inspector__c) {
                row.Lead_Inspector = row.IETRS_Inspector__r.Name;
              }
              if (row.CreatedDate) {
                row.CreatedDate = row.CreatedDate.split("T")[0];
              }
              if (row.IETRS_Attached_File_Correspondence__c) {
                row.Attached_File = row.IETRS_Attached_File_Correspondence__r.IETRS_File_Name__c;
                console.log('row attached file name' + row.Attached_File)
              }
              /*if(row.CreatedDate){
                  let dt = row.CreatedDate;//new Date();
                  const dtf = new Intl.DateTimeFormat('en', {
                      year: 'numeric',
                      month: 'short',
                      day: '2-digit'
                  })
                  const [{value: mo}, , {value: da}, , {value: ye}] = dtf.formatToParts(dt);
  
                  row.CreatedDate = `${da}-${mo}-${ye}`;
                  console.log('formatedDate ===> '+row.CreatedDate);
              }*/
            }

          }
        })
        .catch(error => {
          this.error = error;
          console.log('Error' + this.error);
        });
    }
    //refreshApex(this.getDataSRCreports);
  }

  // opening the modal
  openModal() {
    var isportalUser = false;
    //console.log('record Id' + this.recordId);
    console.log('this.accountRecordId' + this.operatorName);
    isCurrentUserPortalUser({})
      .then(result => {
        isportalUser = result;
        console.log('isportalUser****==>' + isportalUser);
        if (isportalUser) {
          if (this.operatorName != null && this.operatorName != '') {
            identifyPortalUserAcessOrganization({ organizationId: this.operatorName })
              .then(result => {
                console.log('Inside bShoModal on New button 1')
                if (result) {
                  this.shownew = true;
                  this.recordId = null;
                  this.shownew = true;
                  this.showedit = false;
                  this.bShowModal = true;

                } else {
                  if (this.getValuePS_TABs == 'SRC') {
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: "Error!",
                        message: " Your user does not belong to the Organization listed on the SRC record(s). Your user cannot create or delete the record.",
                        variant: "error"
                      })
                    );
                  } else {
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: "Error!",
                        message: " Your user does not belong to the Organization listed on the IMP record(s). Your user cannot create or delete the record.",
                        variant: "error"
                      })
                    );
                    // this.disableSave = false;
                  }
                }
              }).catch(error => {
                console.log(JSON.stringify(error));
              })
          }
        } else {
          this.shownew = true;
          this.recordId = null;
          this.shownew = true;
          this.showedit = false;
          this.bShowModal = true;
        }
      }).catch(error => {
        console.log(JSON.stringify(error));
      })
  }
  // closeing the modal
  closeModal() {
    this.bShowModal = false;
  }

  //On action of data-table
  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case "delete":
        this.deleteRow(row);
        break;
      case "show_details":
        this.onviewRecord(row);
        break;
      default:
    }
  }

  //deleteRow method
  deleteRow(row) {
    const { id } = row;
    console.log('deleteRow=>' + JSON.stringify(row));
    //const index = this.findRowIndexById(row.Id);
    var isportalUser = false;
    //console.log('record Id' + this.recordId);
    console.log('this.accountRecordId' + this.operatorName);
    isCurrentUserPortalUser({})
      .then(result => {
        isportalUser = result;
        console.log('isportalUser****==>' + isportalUser);
        if (isportalUser) {
          if (this.operatorName != null && this.operatorName != '') {
            identifyPortalUserAcessOrganization({ organizationId: this.operatorName })
              .then(result => {
                console.log('Inside bShoModal on New button 1')
                if (result) {

                  this.deleteNotificationRecordById(row.Id);

                } else {
                  if (this.getValuePS_TABs == 'SRC') {
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: "Error!",
                        message: " Your user does not belong to the Organization listed on the SRC record(s). Your user cannot create or delete the record.",
                        variant: "error"
                      })
                    );
                  } else {
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: "Error!",
                        message: " Your user does not belong to the Organization listed on the IMP record(s). Your user cannot create or delete the record.",
                        variant: "error"
                      })
                    );
                    // this.disableSave = false;
                  }
                }
              }).catch(error => {
                console.log(JSON.stringify(error));
              })
          }
        } else {

          this.deleteNotificationRecordById(row.Id);
        }
      }).catch(error => {
        console.log(JSON.stringify(error));
      })

  }

  //Calling server for deletion
  deleteNotificationRecordById(recId) {
    console.log('deleteNotificationRecordById=>' + recId);
    deleteNotificationRecordById({ recordId: recId })
      .then(result => {
        this.refreshNotificationDetailsLst();

      })
      .catch(error => {
        this.error = error;
      });
  }
  //ViewRecord method
  onviewRecord(rowdata) {
    this.recordId = rowdata.Id;
    console.log('rowdata.Id=>' + rowdata.Id);
    this.shownew = false;
    this.bShowModal = true;
    this.shownew = false;
    this.showedit = true;
  }

  handleSuccess(event) {
    this.newNotificationRecId = event.detail.id;
    //console.log('event.detail.fields;'+JSON.stringify(event));
    if (this.bShowModal != false) {
      const evt = new ShowToastEvent({
        title: "Record has been created sucessfully.",
        variant: "success"
      });
      this.dispatchEvent(evt);
      this.bShowModal = false;
      //console.log('event.target.value;=>'+document.getElementById('id'));
      //Refresh the data
      this.refreshNotificationDetailsLst();
      console.log('At success 2');
      if (this.movetoUpload)
        this.uploadFileEvent(event, this.newNotificationRecId);
    }
  }
  //On Submit for edit
  onsubmitNotification(event) {
    var isportalUser = false;
    //console.log('record Id' + this.recordId);
    console.log('this.accountRecordId' + this.operatorName);
    isCurrentUserPortalUser({})
      .then(result => {
        isportalUser = result;
        console.log('isportalUser****==>' + isportalUser);
        if (isportalUser) {
          if (this.operatorName != null && this.operatorName != '') {
            identifyPortalUserAcessOrganization({ organizationId: this.operatorName })
              .then(result => {
                console.log('Inside bShoModal on New button 1')
                if (result) {



                  console.log('onsubmitNotification;' + event.target.value);
                  const fields = event.detail.fields;
                  this.template.querySelector('lightning-record-edit-form').submit(fields);
                  //this.uploadFileEvent();

                  this.onClickofSave();

                } else {
                  if (this.getValuePS_TABs == 'SRC') {
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: "Error!",
                        message: " Your user does not belong to the Organization listed on the SRC Your user cannot create or delete the record.",
                        variant: "error"
                      })
                    );
                  } else {
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: "Error!",
                        message: " Your user does not belong to the Organization listed on the IMP Your user cannot create or delete the record.",
                        variant: "error"
                      })
                    );
                  }
                }
              }).catch(error => {
                console.log(JSON.stringify(error));
              })
          }
        } else {



          console.log('onsubmitNotification;' + event.target.value);
          const fields = event.detail.fields;
          this.template.querySelector('lightning-record-edit-form').submit(fields);
          //this.uploadFileEvent();

          this.onClickofSave();
        }
      }).catch(error => {
        console.log(JSON.stringify(error));
      })
  }
  //To refresh the Notification from the DB
  onsuccessofNotification(event) {
    //console.log('At success');
    this.showError = false;
    if (this.bShowModal != false) {
      const evt = new ShowToastEvent({
        title: "Record has been Updated sucessfully.",
        variant: "success"
      });
      this.dispatchEvent(evt);
      this.bShowModal = false;
      //Refresh the data
      this.refreshNotificationDetailsLst();
      console.log('onsuccessofNotification');
      if (this.movetoUpload)
        this.uploadFileEvent(event, this.recordId);
    }

  }
  //Added by Ayesha on 22nd DEC 2020 for invoking the event to AURA to trigger the flow
  uploadFileEvent(event, notiId) {
    const value = true;
    //const notiId = this.newNotificationRecId;
    console.log('uploadFileEvent=>' + notiId);
    const valueChangeEvent = new CustomEvent("valuechangeSrc", {
      detail: {
        value,
        notiId
      }
    });
    console.log('uploadFileEvent 2');
    this.dispatchEvent(valueChangeEvent);
  }
  movetoUpload;
  onClickofSaveAndUpload() {
    var isportalUser = false;
    //console.log('record Id' + this.recordId);
    console.log('this.accountRecordId' + this.operatorName);
    isCurrentUserPortalUser({})
      .then(result => {
        isportalUser = result;
        console.log('isportalUser****==>' + isportalUser);
        if (isportalUser) {
          if (this.operatorName != null && this.operatorName != '') {
            identifyPortalUserAcessOrganization({ organizationId: this.operatorName })
              .then(result => {
                console.log('Inside bShoModal on New button 1')
                if (result) {


                  this.movetoUpload = true;
                  console.log('onClickofSaveAndUpload 2' + this.movetoUpload);
                } else {
                  if (this.getValuePS_TABs == 'SRC') {
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: "Error!",
                        message: " Your user does not belong to the Organization listed on the SRC Your user cannot create or delete the record.",
                        variant: "error"
                      })
                    );
                  } else {
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: "Error!",
                        message: " Your user does not belong to the Organization listed on the IMP Your user cannot create or delete the record.",
                        variant: "error"
                      })
                    );
                  }
                }
              }).catch(error => {
                console.log(JSON.stringify(error));
              })
          }
        } else {

          this.movetoUpload = true;
          console.log('onClickofSaveAndUpload 2' + this.movetoUpload);
        }
      }).catch(error => {
        console.log(JSON.stringify(error));
      })

  }
  onClickofSave() {
    this.movetoUpload = false;
    console.log('onClickofSave 2' + this.movetoUpload);
  }

  handleerror(event) {
    this.showError = true;
  }
}