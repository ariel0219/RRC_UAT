import { LightningElement, api, track, wire } from "lwc";
import getApprovalHistory from "@salesforce/apex/ApprovalHistoryController.getApprovalHistory";
import {
  hideModal,
  showModal,
  clearModalState,
} from "./approvalHistoryUtil.js";
import { refreshApex } from "@salesforce/apex";

const columns = [
  {
    label: "Step Name",
    fieldName: "stepUrl",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "stepName"
      }
    }
  },
  {
    label: "Date",
    fieldName: "createdDate",
    type: "date",
    typeAttributes: {
      month: "numeric",
      day: "numeric",
      year: "numeric",
      hour: "numeric",
      minute: "numeric"
    }
  },
  { label: "Status", fieldName: "stepStatus" },
  {
    label: "Assigned To",
    fieldName: "assignedToUrl",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "assignedTo"
      }
    }
  },
  { label: "Comment", fieldName: "comments" }
  
];
export default class ApprovalHistory extends LightningElement {
  @api recordId;
  @api allowSubmitForApproval;
  @api showComments;
  @track approvalHistory; //approval history to display on page
  @track approvalHistoryViewAll; // Show All Approval History records
  wiredApprovalHistory; //property used to refreshApex

  get columns() {
    let tempColumns = columns;
    return tempColumns;
  }


  get showDataTable() {
    return this.approvalHistory && this.approvalHistory.approvalSteps.length > 0
      ? true
      : false;
  }

  get showViewAllModal() {
    return this.approvalHistoryViewAll && this.approvalHistoryViewAll.approvalSteps.length > 0
      ? true
      : false;
  }

  @wire(getApprovalHistory, { recordId: "$recordId", noOfRecords: '6' })
  wiredGetApprovalHist(value) {
    this.wiredApprovalHistory = value;
    if (value.data) {
      this.approvalHistory = value.data;
    } else if (value.error) {

    }
  }

  refreshApprovalHistory() {
    refreshApex(this.wiredApprovalHistory);
  }

  
  handleViewAllClick() {
    showModal(this);
    getApprovalHistory({ recordId: this.recordId, noOfRecords: 'All' })
            .then(result => {
                //console.log('result' + JSON.stringify(result));
                this.approvalHistoryViewAll = result;
                
            })
            .catch(error => {
                this.error = error;
            });
  }

  //end button click handlers


  handleModalCancel() {
    hideModal(this);
    clearModalState(this);
  }
 
}