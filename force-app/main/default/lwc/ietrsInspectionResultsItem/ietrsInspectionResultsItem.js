import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class IetrsInspectionResultsItem extends LightningElement {
    @api inspectionResult;
    @api isViolationReadOnly;

    renderedCallback() {
        this.lookupSet = !this.inspectionResult.inspRec.IETRS_Regulatory_Code__c;
        if (!this.lookupSet) {
            const codeLookup = this.template.querySelector('c-ietrs-sobject-lookup');
            if (codeLookup) {
                const { Id, Name } = this.inspectionResult.inspRec.IETRS_Regulatory_Code__r;
                codeLookup.setRecord({ Id, Name }, true);
                this.lookupSet = true;
            }
        }
    }

    navigateToContactDetail(evt) {
        const recordId = evt.target.dataset.id;
        window.open('/' + recordId, '_blank');
    }

    handleRegCodeChange(evt) {
        var regCode = evt.detail.record;
        if (regCode) {
            const inspection = this.inspectionResult.inspRec.IETRS_Inspection__r || {};
            const entity = inspection.IETRS_Regulated_Entity__r || {};
            const regProductClass = entity.IETRS_Product_Class__c || '';
            const selectedViolationType = regCode.IETRS_Violation_Type__c || '';
            const violationTypeLowerCase = selectedViolationType.toLowerCase();
            const productClassLowerCase = regProductClass.toLowerCase();
            const stateType = 'state';
            const unknownType = 'unknown';
            if (
                violationTypeLowerCase.includes(productClassLowerCase) ||
                violationTypeLowerCase.includes(stateType) ||
                violationTypeLowerCase.includes(unknownType)
            ) {
                this.fireRecordChangeEvent({
                    IETRS_Regulatory_Code__c: regCode.Id,
                    IETRS_Regulatory_Code__r: {
                        Id: regCode.Id,
                        Name: regCode.Name
                    }
                });
            } else {
                const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: `The Regulatory Code Violation Type "${selectedViolationType}" is not allowed for the Regulated Entity's Product Class "${regProductClass}"`,
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
                evt.target.setRecord(null, true);
            }
        } else {
            this.fireRecordChangeEvent({
                IETRS_Regulatory_Code__c: null,
                IETRS_Regulatory_Code__r: {}
            });
        }
    }

    fireRecordChangeEvent(payload) {
        this.dispatchEvent(
            new CustomEvent('recordchange', {
                detail: { ...payload, Id: this.inspectionResult.inspRec.Id }
            })
        );
    }

    handleChange(evt) {
        const changes = {};
        const fieldName = evt.target.dataset.fieldName;
        const value = evt.target.value;
        changes[fieldName] = value;
        this.fireRecordChangeEvent(changes);
    }

    handleCreateViolationChange(evt) {
        const input = evt.target;
        this.fireRecordChangeEvent({
            IETRS_Create_Violation__c: input.checked
        });
    }

    handleSObjectClick(evt) {
        const { recordId, objectApiName } = evt.target.dataset;
        evt.preventDefault();
        this.dispatchEvent(
            new CustomEvent('sobjectclick', {
                detail: {
                    recordId,
                    objectApiName
                }
            })
        );
    }
}