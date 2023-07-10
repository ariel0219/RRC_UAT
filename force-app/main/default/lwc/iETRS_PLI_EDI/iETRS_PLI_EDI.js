import { api, LightningElement, track, wire } from 'lwc';
import { subscribe, unsubscribe } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import pubsub from 'c/iETRS_PLI_PubSub';
import createBoxFile from '@salesforce/apex/IETRS_PLI_EDI_FileHandler.createBoxFile';
import createFCRecord from '@salesforce/apex/IETRS_PLI_EDI_FileHandler.createFCRecord';
import updateFCRecord from '@salesforce/apex/IETRS_PLI_EDI_FileHandler.updateFCRecord';
import readEDIFile from '@salesforce/apex/IETRS_PLI_EDI_FileHandler.readEDIFile';
import saveEDIRepairedLeaks from '@salesforce/apex/IETRS_PLI_EDI_FileHandler.saveEDIRepairedLeaks';
import getEDICustomMetadata from '@salesforce/apex/IETRS_PLI_EDI_FileHandler.getEDICustomMetadata';
import deleteDocument from '@salesforce/apex/IETRS_PLI_EDI_FileHandler.deleteDocument';
import getCountyCode from '@salesforce/apex/IETRS_PLI_EDI_FileHandler.getCountyCode';
import getOperLeakId from '@salesforce/apex/IETRS_PLI_EDI_FileHandler.getOperLeakId';
import getNotificationRecord from '@salesforce/apex/IETRS_PLI_LWCQuery.fetchNotificationDetailRecs';
import saveNotification from '@salesforce/apex/IETRS_PLI_LWCQuery.updateNotificationRecord';
import getRegEntIdList from '@salesforce/apex/IETRS_PLI_EDI_FileHandler.getRegEntIdList';
import getIdOfNotDetRecType from '@salesforce/apex/IETRS_PLI_EDI_FileHandler.getIdOfNotDetRecType';
import hasEditPS95 from '@salesforce/customPermission/Edit_PS_95';
import isCurrentUserPortalUser from '@salesforce/apex/IETRS_PLI_LWCQuery.isCurrentUserPortalUser';
import identifyPortalUserAccessOrganization from '@salesforce/apex/IETRS_PLI_LWCQuery.identifyPortalUserAcessOrganization';
import getBatchStatus from '@salesforce/apex/IETRS_PLI_EDI_FileHandler.getBatchStatus';

export default class IETRS_PLI_EDI extends LightningElement {
    @track operatorName;
    @track companyId;
    @track ReportPeriod;
    @track organizationAccountId;
    @track fileDocId;
    @track isNextBtnDisabled = true;
    @track setNotificationRecord;
    arrOperatorLeakIds = [];
    reCRLF = RegExp('\r\n');
    reCR = RegExp('\r');
    reLF = RegExp('\n');
    reNonNumber = RegExp('[^0-9]');
    reNonFloat = RegExp('[^0-9.]$');
    reZipCode = RegExp('^[0-9]{5}(-[0-9]{4})?$');
    dtToday = new Date();
    dtPeriodStart;
    dtPeriodEnd;
    reportedLeakDate;

    @track p5Number;

    @track grade1 = 0;
    @track grade2 = 0;
    @track grade3 = 0;

    arrCompCoupMatType = [];
    facilityType = [];
    leakCause = [];
    leakClassification = [];
    leakLocatedOn = [];
    leakLocation = [];
    leakRepairMethod = [];
    pipeASTMMaterialCode = [];
    pipeManufacturer = [];
    pipeSize = [];
    pipeType = [];
    typeOfLeakingFitting = [];
    typeofLeakingJoint = [];
    recTypNotDetId;

    isHeaderDisplayTextShow;
    isHeaderDisplayRecordsFound;
    @track notificationID = '';
    @track isDataCreated = false;
    @track metaDataEDI;
    @track error;
    @track message;
    @track updatedFileResponse;
    @track validationFailed = false;
    @track numValidationPercent = 0;
    @track numValidationCount = 0;
    @track numTotalRepairedLeaks = 0;

    @track ediFileName;

    //for EDI Parsing
    notifRecrd = new Object();
    arrErrorMessages = [];
    strErrorHeader = 'Error: Line ';
    @track arrNotificationDetails = [];

    objRegEntMap = new Object();
    countyCodeList = new Object();

    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded
    @track isModalOpen = false;
    @track isNextModalOpen = false;
    @track isValidationModalPassed = false;
    @track fileIsValidated = false;
    @track blnLastFullChunk = false;
    @track isLoaded = false;
    @track isBatchSaving = false;



    //Platform Event variables
    channelName = '/event/IETRS_EDI_Save_Complete__e';
    subscription = {};
    batchJobId = '';

    @api recordId;

    get acceptedFormats() {
        return ['.txt'];
    }

    get isPS95Viewable() {
        return hasEditPS95;
    }

    get isInitalPS95Displayed() {
        if (hasEditPS95 == true && this.isDataCreated == false) {
            return true;
        }
    }
    @track blnPortalUser = false;
    @wire(getCountyCode) wiredCountyList({ error, data }) {
        if (data) {
            data.forEach((element) => {
                this.countyCodeList[element.IETRS_Oil_Gas_County_Code__c] =
                    element.Id;
            });
        } else if (error) {
            console.log('getCountyCode Error: ' + error);
        }
    }

    @wire(isCurrentUserPortalUser)
    wiredPortalUser({ error, data }) {
        if (data) {
            this.blnPortalUser = data;
            console.log('wire success');
            console.log(data);
        } else if (error) {
            console.log('wire error');
            console.log(error);
        }
    }
    @track blnOrgAccess = false;

    openModal(event) {
        // to open modal set isModalOpen track value as true
        this.isModalOpen = true;
        getOperLeakId({ strNotificationID: this.notificationID })
            .then((result) => {
                this.arrOperatorLeakIds = Array.from(result);
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
    }
    @api
    closeModal() {

        //debug starts:
        console.log("numTotalRepairedLeaks: -->" + this.numTotalRepairedLeaks);
        //debug ends.
        // to close modal set track value as false
        this.isModalOpen = false;
        this.isNextModalOpen = false;
        this.isValidationModalPassed = false;
        this.validationFailed = false;
        this.isNextBtnDisabled = true;
        this.isLoaded = false;
        this.fileIsValidated = false;

        if (this.fileDocId != null) {
            //need to verify if this will have a value
            this.deleteEDIFile();
            this.clearCacheOfStoredVariables();
        }
    }


    parseMeta() {
        // this.metaDataEDI - list of IETRS_PLI_PS95_EDI_Code_Mappings__mdt records
        //
        for (var i in this.metaDataEDI) {
            switch (this.metaDataEDI[i].IETRS_Code_Type__c) {
                //IETRS_Compression_Coupling_Material_Type__c
                case 'IETRS_Compression_Coupling_Material_Type__c':
                    this.arrCompCoupMatType[
                        this.metaDataEDI[i].IETRS_EDI_Code__c
                    ] = this.metaDataEDI[i].IETRS_Salesforce_Value__c;
                    break;

                //IETRS_Facility_Type__c
                case 'IETRS_Facility_Type__c':
                    this.facilityType[this.metaDataEDI[i].IETRS_EDI_Code__c] =
                        this.metaDataEDI[i].IETRS_Salesforce_Value__c;
                    break;

                //IETRS_Leak_Cause__c
                case 'IETRS_Leak_Cause__c':
                    this.leakCause[this.metaDataEDI[i].IETRS_EDI_Code__c] =
                        this.metaDataEDI[i].IETRS_Salesforce_Value__c;
                    break;

                //IETRS_Leak_Classification__c
                case 'IETRS_Leak_Classification__c':
                    this.leakClassification[
                        this.metaDataEDI[i].IETRS_EDI_Code__c
                    ] = this.metaDataEDI[i].IETRS_Salesforce_Value__c;
                    break;

                //IETRS_Leak_Located_On__c
                case 'IETRS_Leak_Located_On__c':
                    this.leakLocatedOn[this.metaDataEDI[i].IETRS_EDI_Code__c] =
                        this.metaDataEDI[i].IETRS_Salesforce_Value__c;
                    break;

                //IETRS_Leak_Location__c
                case 'IETRS_Leak_Location__c':
                    this.leakLocation[this.metaDataEDI[i].IETRS_EDI_Code__c] =
                        this.metaDataEDI[i].IETRS_Salesforce_Value__c;
                    break;

                //IETRS_Leak_Repair_Method__c
                case 'IETRS_Leak_Repair_Method__c':
                    this.leakRepairMethod[
                        this.metaDataEDI[i].IETRS_EDI_Code__c
                    ] = this.metaDataEDI[i].IETRS_Salesforce_Value__c;
                    break;

                //IETRS_Pipe_ASTM_Material_Code__c
                case 'IETRS_Pipe_ASTM_Material_Code__c':
                    this.pipeASTMMaterialCode[
                        this.metaDataEDI[i].IETRS_EDI_Code__c
                    ] = this.metaDataEDI[i].IETRS_Salesforce_Value__c;
                    break;

                //IETRS_Pipe_Manufacturer__c
                case 'IETRS_Pipe_Manufacturer__c':
                    this.pipeManufacturer[
                        this.metaDataEDI[i].IETRS_EDI_Code__c
                    ] = this.metaDataEDI[i].IETRS_Salesforce_Value__c;
                    break;

                //IETRS_Pipe_Size__c
                case 'IETRS_Pipe_Size__c':
                    this.pipeSize[this.metaDataEDI[i].IETRS_EDI_Code__c] =
                        this.metaDataEDI[i].IETRS_Salesforce_Value__c;
                    break;

                //IETRS_Pipe_Type__c
                case 'IETRS_Pipe_Type__c':
                    this.pipeType[this.metaDataEDI[i].IETRS_EDI_Code__c] =
                        this.metaDataEDI[i].IETRS_Salesforce_Value__c;
                    break;

                //IETRS_Type_of_Leaking_Fitting__c
                case 'IETRS_Type_of_Leaking_Fitting__c':
                    this.typeOfLeakingFitting[
                        this.metaDataEDI[i].IETRS_EDI_Code__c
                    ] = this.metaDataEDI[i].IETRS_Salesforce_Value__c;
                    break;

                //IETRS_Type_of_Leaking_Joint__c
                case 'IETRS_Type_of_Leaking_Joint__c':
                    this.typeofLeakingJoint[
                        this.metaDataEDI[i].IETRS_EDI_Code__c
                    ] = this.metaDataEDI[i].IETRS_Salesforce_Value__c;
                    break;
            }
        }
    }

    connectedCallback() {
        this.register();
        //this.isNextBtnDisabled;
    }

    validateHelper() {
        //Pipeline System ID creation
        var myPipelineSystemIDArray = [];
        for (var ps in this.objRegEntMap) {
            myPipelineSystemIDArray[
                this.objRegEntMap[ps].IETRS_Regulated_Entity_ID__c
            ] = this.objRegEntMap[ps].Id;
        }

        //Trim the final newline character from the EDI file
        this.updatedFileResponse = this.updatedFileResponse.trim();

        //Handle Linux, Windows, and Mac standard End of Line EOL characters CR, LF, and CRLF.
        let strEOLchar = this.reCRLF.exec(this.updatedFileResponse)
            ? '\r\n'
            : this.reCR.exec(this.updatedFileResponse)
            ? '\r'
            : this.reLF.exec(this.updatedFileResponse)
            ? '\n'
            : '\r\n';

        //Split the full data set into rows using the EOL character identified above.
        let edi_list = this.updatedFileResponse.split(strEOLchar); // => [string, string]
        //splits each new line and into array
        let rows = edi_list.map(function (val) {
            // => [[string, string], [string, string]]
            return val.split('}');
        });

        let ediHeaderRow = rows.shift(); // remove first item, assign to ediHeaderRow
        let ediUnrepairedRow = rows.shift(); // remove second item, assign to ediUnrepairedRow
        let ediRepairedLeaksRows = rows; // same list wihtout first two rows

        if (edi_list != null) {
            /*********************************************
            HEADER RECORD - INDEX 0
            *********************************************/
            if (ediHeaderRow.length == 9) {
                /*********************************************
                Record Type - Index 0
                *********************************************/
                this.validateRecordType(ediHeaderRow[0], 1, 1); //record type

                /*********************************************
                Report Type - Index 1
                *********************************************/
                this.validateReportType(ediHeaderRow[1], 'PS95', 1); //Report Type

                /*********************************************
                Operator Number - Index 5
                *********************************************/
                //Operator Number 6 digits P5 Number
                if (
                    ediHeaderRow[5].length != 6 ||
                    ediHeaderRow[5].match(this.reNonNumber)
                ) {
                    this.arrErrorMessages.push(
                        this.strErrorHeader +
                            ' 1, Value: ' +
                            ediHeaderRow[5] +
                            ' Must be in Format ######, 6 digit numeric for Operator Number.'
                    );
                }
                //Operator Number must match P5 Number selected
                if (ediHeaderRow[5] != this.p5Number) {
                    this.arrErrorMessages.push(
                        this.strErrorHeader +
                            ' 1, Value: ' +
                            ediHeaderRow[5] +
                            ' Does not match the P5 number for the selected Operator: ' +
                            this.p5Number +
                            '.'
                    );
                }

                /*********************************************
                Report Year - Index 6
                Report Period - Index 7
                *********************************************/
                if (
                    ediHeaderRow[6].length != 4 ||
                    ediHeaderRow[6].match(this.reNonNumber)
                ) {
                    this.arrErrorMessages.push(
                        this.strErrorHeader +
                            ' 1, Value: ' +
                            ediHeaderRow[6] +
                            ', is an invalid Report Year format. Format must be YYYY.'
                    );
                }
                //Validation handling for else if happens in validatePeriodDate function.
                else if (
                    !this.validatePeriodDate(
                        this.ReportPeriod,
                        ediHeaderRow[6],
                        ediHeaderRow[7],
                        1
                    )
                ) {
                } else {
                    //Period start is either Jan 1 YYYY or July 1 YYYY
                    this.dtPeriodStart = new Date(
                        ediHeaderRow[6],
                        ediHeaderRow[7] == 1 ? 0 : 6
                    );
                    //Period end is either June 30 YYYY or December 31 YYYY
                    this.dtPeriodEnd = new Date(
                        ediHeaderRow[6],
                        ediHeaderRow[7] == 1 ? 5 : 11,
                        ediHeaderRow[7] == 1 ? 30 : 31
                    );
                }

                /*********************************************
                Record Count - Index 8
                *********************************************/
                if (ediHeaderRow[8] != rows.length) {
                    //may need to remove the last row if there is an empty row
                    this.arrErrorMessages.push(
                        this.strErrorHeader +
                            ' 1, Value: ' +
                            ediHeaderRow[8] +
                            ' Record Count indicated does not match the count of repaired leak detail rows in this file'
                    );
                }
            }

            /*********************************************
            UNREPAIRED LEAK RECORD - INDEX 1
            *********************************************/
            //Validate that the row has the correct number of elements, throw error and do not process row if not.
            if (ediUnrepairedRow.length == 4) {
                /*********************************************
                Record Type - Index 0
                *********************************************/
                this.validateRecordType(ediUnrepairedRow[0], 2, 2);

                /*********************************************
                Total Grade 1 Unrepaired Leaks - Index 1
                *********************************************/
                this.grade1 = this.validateUnrepairedValue(
                    ediUnrepairedRow[1],
                    'Unrepaired Grade 1',
                    2
                )
                    ? ediUnrepairedRow[1]
                    : 0;

                /*********************************************
                Total Grade 2 Unrepaired Leaks - Index 2
                *********************************************/
                this.grade2 = this.validateUnrepairedValue(
                    ediUnrepairedRow[2],
                    'Unrepaired Grade 2',
                    2
                )
                    ? ediUnrepairedRow[2]
                    : 0;

                /*********************************************
                Total Grade 3 Unrepaired Leaks - Index 3
                *********************************************/
                this.grade3 = this.validateUnrepairedValue(
                    ediUnrepairedRow[3],
                    'Unrepaired Grade 3',
                    2
                )
                    ? ediUnrepairedRow[3]
                    : 0;
            } else {
                this.arrErrorMessages.push(
                    this.strErrorHeader +
                        (i + 3) +
                        ', Invalid number of delimited values for Unrepaired Leaks. Values found: ' +
                        ediUnrepairedRow.length +
                        '. Should be 4.'
                );
            }

            /*********************************************
            REPAIRED LEAK RECORDS - INDICES 2 -> END
            *********************************************/
           //debug starts:
           console.log("ediRepairedLeaksRows: -->" + ediRepairedLeaksRows.length);
           //debug ends.
            this.numTotalRepairedLeaks = ediRepairedLeaksRows.length;
            for (var i = 0; i < this.numTotalRepairedLeaks; i++) {
                //Validate that the row has the correct number of elements, throw error and do not process row if not.
                if (ediRepairedLeaksRows[i].length == 27) {
                    //Instatiate the Notification Detail record to be populated from the current EDI row
                    //Validation and population of the record occur simultaneously
                    let notificationDetailRecord = new Object();
                    notificationDetailRecord.sObjectType =
                        'IETRS_Insp_Notification_Detail__c';

                    //Set progress variables to be reflected on the UI every 100 records validated
                    if (i % 100 == 0) {
                        //this.numValidationPercent = Math.round(
                            //(i / this.numLeaks) * 100
                        //);
                        this.numValidationPercent = (i / this.numTotalRepairedLeaks).toFixed(2) * 100;
                        

                        this.numValidationCount = i;
                        console.log(
                            'Loading Record: ' +
                                i +
                                ' of ' +
                                ediHeaderRow[8] +
                                '.'
                        );
                        console.log("======>" + this.numValidationPercent + "%");
                        if (this.arrErrorMessages.length != null) {
                            console.log(
                                'Error Count:  ',
                                this.arrErrorMessages.length
                            );
                        }
                    }

                    /*********************************************
                    //Record Type - Index 0
                    *********************************************/
                    this.validateRecordType(
                        ediRepairedLeaksRows[i][0],
                        3,
                        i + 3
                    );

                    /*********************************************
                    Pipeline System ID - Index 1
                    *********************************************/
                    var newstring = ediRepairedLeaksRows[i][1];

                    if (
                        this.objRegEntMap.some(
                            (e) => e.IETRS_Regulated_Entity_ID__c === newstring
                        ) &&
                        (newstring.length === 6 || newstring.length === 8)
                    ) {
                        notificationDetailRecord.IETRS_Pipelines_System_ID__c =
                            myPipelineSystemIDArray[newstring];
                    } else {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Pipeline System Not Found in system.'
                        );
                    }

                    /*********************************************
                    IETRS_Operator_Leak_ID__c - Index 2
                    *********************************************/
                    if (
                        this.arrOperatorLeakIds.some(
                            (e) => e == ediRepairedLeaksRows[i][2]
                        )
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Duplicate Leak ID Detected. Leak ID ' +
                                ediRepairedLeaksRows[i][2] +
                                ' is not unique.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Operator_Leak_ID__c =
                            ediRepairedLeaksRows[i][2];
                    }
                    //Add the Operator Leak Id to the full list of Operator Leak Ids returned from the System to handle repeat Leak Ids within the same file submission
                    this.arrOperatorLeakIds.push(ediRepairedLeaksRows[i][2]);

                    /*********************************************
                    IETRS_Date_Leak_Reported__c - Index 3
                    *********************************************/
                    if (
                        this.validateDate(
                            ediRepairedLeaksRows[i][3],
                            i + 3,
                            'Date Leak Reported'
                        )
                    ) {
                        this.reportedLeakDate = this.formatToDate(
                            ediRepairedLeaksRows[i][3]
                        );
                        if (
                            this.reportedLeakDate > this.dtToday ||
                            this.reportedLeakDate > this.dtPeriodEnd
                        ) {
                            this.arrErrorMessages.push(
                                this.strErrorHeader +
                                    (i + 3) +
                                    ', Date Leak Reported cannot be future dated or after the end of the filing period for which it is being reported. Please correct the date.'
                            );
                        } else {
                            notificationDetailRecord.IETRS_Date_Leak_Reported__c =
                                this.formatToDate(ediRepairedLeaksRows[i][3]);
                        }
                    } else {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid Date Leak Reported: ' +
                                ediRepairedLeaksRows[i][3] +
                                '. Date cannot be blank and must be in format YYYYMMDD.'
                        );
                    }

                    /*********************************************
                    IETRS_Unit_Street_Address_1__c - Index 4
                    *********************************************/
                    if (ediRepairedLeaksRows[i][4].length >= 3) {
                        notificationDetailRecord.IETRS_Unit_Street_Address_1__c =
                            ediRepairedLeaksRows[i][4];
                    } else {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Address Line 1 must be greater than 3 characters in length. Please provide a valid address.'
                        );
                    }

                    //IETRS_Unit_Street_Address_2__c
                    /* console.log('ediRepairedLeaksRows[i][5]: ', ediRepairedLeaksRows[i][5]);
                    if (ediRepairedLeaksRows[i][5].length >= 3 && ediRepairedLeaksRows[i][5] != '') {
                        notificationDetailRecord.IETRS_Unit_Street_Address_2__c = ediRepairedLeaksRows[i][5];
                    }
                    else{
                        this.arrErrorMessages.push(this.strErrorHeader + 'Please provide a valid Address2 for Row '+ (i+3));
                    } */

                    /*********************************************
                    IETRS_Unit_Zip_Code__c - Index 6
                    *********************************************/
                    if (
                        ediRepairedLeaksRows[i][6].length >= 3 &&
                        ediRepairedLeaksRows[i][6] != null
                    ) {
                        notificationDetailRecord.IETRS_Unit_City__c =
                            ediRepairedLeaksRows[i][6];
                    } else {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ' City must be greater than 3 characters in length.'
                        );
                    }

                    /*********************************************
                    IETRS_Unit_Zip_Code__c - Index 7
                    *********************************************/
                    if (
                        ediRepairedLeaksRows[i][7].match(this.reZipCode) ||
                        ediRepairedLeaksRows[i][7] == ''
                    ) {
                        notificationDetailRecord.IETRS_Unit_Zip_Code__c =
                            ediRepairedLeaksRows[i][7];
                    } else {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid Zip Code: ' +
                                ediRepairedLeaksRows[i][7] +
                                '. Please provide a Zip Code in either 5 (#####) or 9 (#####-####) digit format.'
                        );
                    }

                    /*********************************************
                    IETRS_County__c - Index 8
                    *********************************************/
                    if (
                        ediRepairedLeaksRows[i][8].length != 3 ||
                        typeof ediRepairedLeaksRows[i][8] === 'undefined'
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid FIPS County Code: ' +
                                ediRepairedLeaksRows[i][8] +
                                '. FIPS County Code must be 3 digits in length.'
                        );
                    } else if (
                        ediRepairedLeaksRows[i][8].length == 3 &&
                        !this.countyCodeList[ediRepairedLeaksRows[i][8]]
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid FIPS County Code: ' +
                                ediRepairedLeaksRows[i][8] +
                                '. FIPS County Code does not exist in System.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_County__c =
                            this.countyCodeList[ediRepairedLeaksRows[i][8]];
                    }

                    /*********************************************
                    IETRS_Leak_Location__c - Index 9
                    *********************************************/
                    if (
                        !(
                            ediRepairedLeaksRows[i][9] == 1 ||
                            ediRepairedLeaksRows[i][9] == 2
                        )
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ' Invalid Leak Located, must be either 1 or 2.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Leak_Location__c =
                            this.leakLocation[ediRepairedLeaksRows[i][9]];
                    }

                    /*********************************************
                    IETRS_Leak_Located_On__c - Index 10
                    *********************************************/
                    if (!this.leakLocatedOn[ediRepairedLeaksRows[i][10]]) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid Leak Located On value: ' +
                                ediRepairedLeaksRows[i][10] +
                                '.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Leak_Located_On__c =
                            this.leakLocatedOn[ediRepairedLeaksRows[i][10]];
                    }
                    let leakLocatedOn = ediRepairedLeaksRows[i][10];

                    /*********************************************
                    IETRS_Compression_Coupling_Material_Type__c - Index 11
                    *********************************************/
                    //If Leak Located On value is 12 then Compression Coupling Material Type must be a valid value in the EDI Custom Metadata.
                    if (
                        leakLocatedOn == '12' &&
                        !this.arrCompCoupMatType[ediRepairedLeaksRows[i][11]]
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid Compression Coupling Material Type: ' +
                                ediRepairedLeaksRows[i][11] +
                                '. Please supply a valid Material Type for the Leaking Compression Coupling.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Compression_Coupling_Material_Type__c =
                            this.arrCompCoupMatType[
                                ediRepairedLeaksRows[i][11]
                            ];
                    }

                    /*********************************************
                    IETRS_Compression_Coupling_Install_Date__c  - Index 12
                    *********************************************/
                    //If Leak Located On value is 12 then Compression Coupling Install Date must be provided and be a valid value.
                    if (
                        leakLocatedOn == '12' &&
                        ediRepairedLeaksRows[i][12] == ''
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Please supply a Compression Coupling Install Date for the Leaking Compression Coupling.'
                        );
                    } else if (
                        this.validateDate(
                            ediRepairedLeaksRows[i][12],
                            i + 3,
                            'Compression Coupling Install Date'
                        )
                    ) {
                        notificationDetailRecord.IETRS_Compression_Coupling_Install_Date__c =
                            this.formatToDate(ediRepairedLeaksRows[i][12]);
                    }

                    /*********************************************
                    IETRS_Facility_Type__c - Index 13
                    *********************************************/
                    if (!this.facilityType[ediRepairedLeaksRows[i][13]]) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid Value: ' +
                                ediRepairedLeaksRows[i][11] +
                                ' for Facility Type.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Facility_Type__c =
                            this.facilityType[ediRepairedLeaksRows[i][13]];
                    }

                    /*********************************************
                    IETRS_Pipe_Size__c - Index 14
                    *********************************************/
                    let floatSize = parseFloat(ediRepairedLeaksRows[i][14]);
                    if (
                        ediRepairedLeaksRows[i][14].match(this.reNonFloat) ||
                        !this.pipeSize[floatSize]
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid Pipe Size value: ' +
                                ediRepairedLeaksRows[i][14]
                        );
                    } else {
                        notificationDetailRecord.IETRS_Pipe_Size__c =
                            this.pipeSize[floatSize];
                    }

                    /*********************************************
                    IETRS_Pipe_Type__c - Index 15
                    *********************************************/
                    if (this.pipeType[ediRepairedLeaksRows[i][15]]) {
                        notificationDetailRecord.IETRS_Pipe_Type__c =
                            this.pipeType[ediRepairedLeaksRows[i][15]];
                    } else {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid Pipe Type value: ' +
                                ediRepairedLeaksRows[i][15]
                        );
                    }
                    let pipeTypeDependent = ['8', '9', '11', '12'].includes(
                        ediRepairedLeaksRows[i][15]
                    );

                    /*********************************************
                    IETRS_Pipe_Manufacturer__c - Index 16
                    *********************************************/
                    let pManufacturer =
                        this.pipeManufacturer[ediRepairedLeaksRows[i][16]];
                    if (
                        pipeTypeDependent &&
                        ediRepairedLeaksRows[i][16] == ''
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Please supply a Pipe Manufacturer.'
                        );
                    } else if (
                        pipeTypeDependent &&
                        pManufacturer == null &&
                        ediRepairedLeaksRows[i][16] != ''
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid Pipe Manufacturer value: ' +
                                ediRepairedLeaksRows[i][16] +
                                '.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Pipe_Manufacturer__c =
                            pManufacturer;
                    }

                    /*********************************************
                    IETRS_Pipe_ASTM_Material_Code__c - Index 17
                    *********************************************/
                    let pMatCode =
                        this.pipeASTMMaterialCode[ediRepairedLeaksRows[i][17]];
                    if (
                        pipeTypeDependent &&
                        ediRepairedLeaksRows[i][17] == ''
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Please supply a Pipe ASTM Material Code.'
                        );
                    } else if (
                        pipeTypeDependent &&
                        pMatCode == null &&
                        ediRepairedLeaksRows[i][17] != ''
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid Pipe ASTM Material Code value: ' +
                                ediRepairedLeaksRows[i][17] +
                                '.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Pipe_ASTM_Material_Code__c =
                            pMatCode;
                    }

                    /*********************************************
                    IETRS_Leak_Classification__c - Index 18
                    *********************************************/
                    if (
                        !ediRepairedLeaksRows[i][18] ||
                        !this.leakClassification[ediRepairedLeaksRows[i][18]]
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid Leak Classification Code value: ' +
                                ediRepairedLeaksRows[i][18] +
                                '.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Leak_Classification__c =
                            this.leakClassification[
                                ediRepairedLeaksRows[i][18]
                            ];
                    }

                    /*********************************************
                    IETRS_Type_of_Leaking_Joint__c - Index 19
                    *********************************************/
                    let jointType =
                        this.typeofLeakingJoint[ediRepairedLeaksRows[i][19]];
                    if (
                        leakLocatedOn == '5' &&
                        ediRepairedLeaksRows[i][19] == ''
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Please supply a Type of Leaking Joint Code.'
                        );
                    } else if (
                        leakLocatedOn == '5' &&
                        !jointType &&
                        ediRepairedLeaksRows[i][19] != ''
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid Type of Leaking Joint value: ' +
                                ediRepairedLeaksRows[i][19] +
                                '.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Type_of_Leaking_Joint__c =
                            jointType;
                    }

                    /*********************************************
                    IETRS_Type_of_Leaking_Fitting__c - Index 20
                    *********************************************/
                    let leakingFittingType =
                        this.typeOfLeakingFitting[ediRepairedLeaksRows[i][20]];
                    if (
                        leakLocatedOn == '4' &&
                        ediRepairedLeaksRows[i][20] == null
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Please supply a Type of Leaking Fitting Code.'
                        );
                    } else if (
                        leakLocatedOn == '4' &&
                        !leakingFittingType &&
                        ediRepairedLeaksRows[i][20] != null
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid Type of Leaking Fitting: ' +
                                ediRepairedLeaksRows[i][20] +
                                '.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Type_of_Leaking_Fitting__c =
                            leakingFittingType;
                    }

                    /*********************************************
                    IETRS_Coupling_Model__c - Index 21
                    *********************************************/
                    if (
                        leakLocatedOn == '12' &&
                        ediRepairedLeaksRows[i][21] == ''
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Please supply a Coupling Model for the Leaking Compression Coupling.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Coupling_Model__c =
                            ediRepairedLeaksRows[i][21];
                    }

                    /*********************************************
                    IETRS_Coupling_Manufacturer__c - Index 22
                    *********************************************/
                    if (
                        leakLocatedOn == '12' &&
                        ediRepairedLeaksRows[i][22] == ''
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Please supply a Coupling Manufacturer for the Leaking Compression Coupling.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Coupling_Manufacturer__c =
                            ediRepairedLeaksRows[i][22];
                    }

                    /*********************************************
                    IETRS_Leak_Cause__c - Index 23
                    *********************************************/
                    if (
                        !ediRepairedLeaksRows[i][23] ||
                        !this.leakCause[ediRepairedLeaksRows[i][23]]
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid or no Leak Cause provided: ' +
                                ediRepairedLeaksRows[i][23] +
                                '.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Leak_Cause__c =
                            this.leakCause[ediRepairedLeaksRows[i][23]];
                    }

                    /*********************************************
                    IETRS_Leak_Cause_of_Other__c - Index 24
                    *********************************************/
                    if (
                        ediRepairedLeaksRows[i][23] == '81' &&
                        ediRepairedLeaksRows[i][24] != ''
                    ) {
                        notificationDetailRecord.IETRS_Leak_Cause_of_Other__c =
                            ediRepairedLeaksRows[i][24];
                    } else if (
                        ediRepairedLeaksRows[i][23] == '81' &&
                        ediRepairedLeaksRows[i][24] == ''
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Leak Cause of Other was selected, please add additional description for the Leak Cause of Other.'
                        );
                    }

                    /*********************************************
                    IETRS_Leak_Repair_Method__c - Index 25
                    *********************************************/
                    if (
                        ediRepairedLeaksRows[i][25] == null ||
                        !this.leakRepairMethod[ediRepairedLeaksRows[i][25]]
                    ) {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid or no Leak Repair Method provided: ' +
                                ediRepairedLeaksRows[i][25] +
                                '.'
                        );
                    } else {
                        notificationDetailRecord.IETRS_Leak_Repair_Method__c =
                            this.leakRepairMethod[ediRepairedLeaksRows[i][25]];
                    }

                    /*********************************************
                    IETRS_Repair_Date__c - Index 26
                    *********************************************/
                    if (
                        this.validateDate(
                            ediRepairedLeaksRows[i][26],
                            i + 3,
                            'Repair Date'
                        ) &&
                        ediRepairedLeaksRows[i][26] != ''
                    ) {
                        let repairDate = this.formatToDate(
                            ediRepairedLeaksRows[i][26]
                        );
                        if (repairDate > this.dtToday) {
                            this.arrErrorMessages.push(
                                this.strErrorHeader +
                                    (i + 3) +
                                    ', Invalid Repair Date: ' +
                                    repairDate +
                                    ', date cannot be future dated.'
                            );
                        } else if (repairDate < this.reportedLeakDate) {
                            this.arrErrorMessages.push(
                                this.strErrorHeader +
                                    (i + 3) +
                                    ', Invalid Repair Date: ' +
                                    repairDate +
                                    ', date cannot be before the date leak reported.'
                            );
                        } else if (
                            repairDate < this.dtPeriodStart ||
                            repairDate > this.dtPeriodEnd
                        ) {
                            this.arrErrorMessages.push(
                                this.strErrorHeader +
                                    (i + 3) +
                                    ', Invalid Repair Date: ' +
                                    repairDate +
                                    ', date must be between the filing start and end date.'
                            );
                        } else {
                            notificationDetailRecord.IETRS_Repair_Date__c =
                                this.formatToDate(ediRepairedLeaksRows[i][26]);
                        }
                    } else {
                        this.arrErrorMessages.push(
                            this.strErrorHeader +
                                (i + 3) +
                                ', Invalid Repair Date: ' +
                                ediRepairedLeaksRows[i][26] +
                                ', field cannot be blank and must be in the format YYYYMMDD.'
                        );
                    }

                    //Set RecordIdType on Notification Detail Record
                    notificationDetailRecord.RecordTypeId =
                        this.recTypNotDetId[0].Id;

                    //Set Parent Notification Id on Notification Detail Record
                    notificationDetailRecord.IETRS_Notification__c =
                        this.notificationID;

                    //Add to Array collection of Notification Details
                    this.arrNotificationDetails.push(notificationDetailRecord);
                } else {
                    this.arrErrorMessages.push(
                        this.strErrorHeader +
                            (i + 3) +
                            ', Invalid number of delimited values for Repaired Leaks. Values found: ' +
                            ediRepairedLeaksRows[i].length +
                            '. Should be 27.'
                    );
                }
            }
        }
        //closes Next Modal
        if (this.arrErrorMessages.length == 0) {
            this.isNextModalOpen = false;
            this.isValidationModalPassed = true;
        } else {
            console.log(
                'this.arrErrorMessages:= ',
                JSON.stringify(this.arrErrorMessages, null, '\n')
            );
            this.isValidationModalPassed = false;
            this.isNextModalOpen = false;
            this.validationFailed = true;
        }
    }

    /**************************************************
    BUTTON HANDLER FUNCTIONS
    ***************************************************/
    validateBtn() {
        this.parseMeta();
        //this.isLoaded = true;
        this.validateHelper();
        this.fileIsValidated = true;
    }
    // Saves only after the validation has processed
    @api
    handleSubmit() {
        if (this.fileIsValidated == false) {
            //checks if file was validated
            this.validateBtn();
            this.isValidationModalPassed = true;
            this.handleSubmit();
        }
        if (this.arrErrorMessages.length == 0) {
            console.log('passed the validation check...');
            if (this.isValidationModalPassed == true) {
                //Subscribe to EDI Save Platform Event to listen for event passed from batch apex when the Notification Detail records are saved.
                if (!this.blnPortalUser) {
                    this.subscribeEDISaveEvent();
                }
                console.log('Validation modal passed');
                //Checks for portal user and Org access then updates the Notification record and inserts Notification Details records.
                //isValidationModalPass is also controling the pop window closure. 
                //put this right before the checkPortal task complete to avoid duplicate pop window that lay on top of each other
                
                //this.isValidationModalPassed = false;

                this.checkPortalUser() 
                this.isValidationModalPassed = false;
                console.log('Past this.checkPortalUser()');
                this.deleteEDIFile();
                console.log('Past this.deleteEDIFile()');
            }
        }
        
          
    }
    nextmodal() {
        this.numValidationPercent = 0; //clear cache of validation progress indicator
        // to close modal set isModalOpen track value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
        //opens next Modal page
        this.isNextModalOpen = true;

        //metaDataEDI
        getEDICustomMetadata()
            .then((result) => {
                this.metaDataEDI = result;
            })
            .catch((error) => {
                this.message = error;
                this.message =
                    'Error received: code ' +
                    error.errorCode +
                    ', ' +
                    'message ';
            });
        //grab Reg Ent ID from Operators list
        this.getRegEntIds();
        //grabs the Pipeline System ID from the Regulated Entity ID
        //this.getPipeSysId();
        //get the ID of the Notification Detail Record Type
        this.NotifDetRecType();
    }
    @api
    backmodal() {
        // to go back modal set isModalOpen track value as true
        //Add your code to call apex method or do some processing
        this.isModalOpen = true;
        //opens last Modal page
        this.isNextModalOpen = false;
    }
    @api
    nextModalSubmit() {
        this.isNextModalOpen = false;
    }
    closeBatchModal() {
        this.isBatchSaving = false;
    }
    /**************************************************
    VALIDATION HELPER FUNCTIONS
    ***************************************************/

    validateRecordType(recTypeId, expectedValue, rowNumber) {
        if (recTypeId == expectedValue) {
            //do nothing
        } else {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    rowNumber +
                    ', has an invalid Record Type value, must be ' +
                    expectedValue +
                    '.'
            );
        }
    }
    validateReportType(reportType, expectedValue, rowNumber) {
        if (reportType == expectedValue) {
            //do nothing
        } else {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    rowNumber +
                    ', has an invalid Report Type value, must be ' +
                    expectedValue +
                    '.'
            );
        }
    }

    validateUnrepairedValue(strGivenNum, strFieldName, rowNumber) {
        if (
            strGivenNum == '' ||
            strGivenNum.match(this.reNonNumber || parseInt(strGivenNum) < 0)
        ) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    rowNumber +
                    ', Invalid or no value:' +
                    strGivenNum +
                    ' given for ' +
                    strFieldName +
                    ' Unrepaired Leaks for Filing Period.'
            );
            return false;
        }

        return true;
    }

    validateFromArray(val, arrToCheck, rowNumber) {
        let index;
        for (let i = 0; i < arrToCheck.size(); i++) {
            if (arrToCheck[i] == val) {
                this.index = i;
            } else {
                this.arrErrorMessages.push(
                    this.strErrorHeader +
                        rowNumber +
                        ', invalid value for ' +
                        arrToCheck.fieldName +
                        '.'
                );
            }
        }
        return index;
    }

    validateDate(givenDate, rowNumber, labelName) {
        if (
            givenDate != '' &&
            (givenDate.length != 8 || givenDate.match(this.reNonNumber))
        ) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    rowNumber +
                    ', Value: ' +
                    givenDate +
                    ', needs to be in 8 digit format YYYYMMDD for ' +
                    labelName +
                    '.'
            );
            return false;
        }
        return true;
    }
    validatePeriodDate(givenDate, givenYear, givenPeriod, rowNumber) {
        var myPeriodArray = givenDate.split(' ');
        var myYear = myPeriodArray[0];
        var myPeriod = myPeriodArray[1];

        if (
            (myPeriod == 'Jan-Jun' && givenPeriod != 1) ||
            (myPeriod == 'Jul-Dec' && givenPeriod != 2)
        ) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    rowNumber +
                    ', Selected period does not match EDI File. Selected Period was: ' +
                    myPeriod +
                    ' EDI File Period was: ' +
                    givenPeriod +
                    ' (Jan-Jun = 1 & Jul-Dec = 2).'
            );
            return false;
        } else if (myYear != givenYear) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    rowNumber +
                    ', Selected period year does not match EDI File. Selected Year was: ' +
                    myYear +
                    ' EDI File Year was: ' +
                    givenYear +
                    '.'
            );
            return false;
        }

        return true;
    }
    //used to format 8 digit date to formated readable date
    formatToDate(givenDate) {
        if (givenDate == '' || givenDate == null) {
            //fixing error where if date is empty it returns a default date
            return '';
        }
        return new Date(
            parseInt(givenDate.substr(0, 4), 10),
            parseInt(givenDate.substr(4, 2), 10) - 1,
            parseInt(givenDate.substr(6, 2), 10)
        );
    }

    /**************************************************
    SAVE AND EVENT HELPER FUNCTIONS
    ***************************************************/
    @api
    updateNotification() {
        saveNotification({
            notificationRecordID: this.notificationID,
            grade1: this.grade1,
            grade2: this.grade2,
            grade3: this.grade3
        })
            .then((result) => {
                console.log('Record updated successfully.');
                //refreshApex(this.resultsum);
                this.fireCustomEvent(this.notificationID);
            })
            .catch((error) => {
                window.alert(JSON.stringify(error));
            });
        console.log('notification record submitted');
    }

    @api
    saveNotificationDetails() {
        console.log('saveNotificationDetails()');
        let chunkedArrNotifDetails = [];
        let i,
            arrTemp,
            chunkSize = 3000;

        //Split the array of Notification Details into chunks of 3000 and store in an array of arrays.
        for (i = 0; i < this.arrNotificationDetails.length; i += chunkSize) {
            arrTemp = this.arrNotificationDetails.slice(i, i + chunkSize);
            //Workaround Stringify and Parse to remove the chunked array from nested Proxies caused by the Lightning Locker Service.
            chunkedArrNotifDetails.push(JSON.parse(JSON.stringify(arrTemp)));
        }

        //For each chunk array within the chunkedArrNotifDetails, invoke saveEDIRepairedLeaks apex method.
        //This is a workaround for an undocumented Salesforce limitation on array size (~4300 Length) passed through the LWC to Apex interface.
        for (let i = 0; i < chunkedArrNotifDetails.length; i++) { //for loop starts
            //Set flag to Batch Apex to send Platform Event on Finish method on the last full chunked array (3000 records).
            //Unless the array has less records than the chunk size (length == 1), in which case, send platform event on finish.
            if (
                i == chunkedArrNotifDetails.length - 2 ||
                (chunkedArrNotifDetails.length == 1 &&
                    i == chunkedArrNotifDetails.length - 1)
            ) {
                this.blnLastFullChunk = true;
            } else {
                this.blnLastFullChunk = false;
            }

            //Imperatively call Apex class to invoke batch Apex insert of Notification Details.
            saveEDIRepairedLeaks({
                lstInsertNotifDetails: chunkedArrNotifDetails[i],
                blnSendEventOnFinish: this.blnLastFullChunk
            })
                .then((result) => {
                    //Promise does not contain callback function, instead see function subscribeEDISaveEvent() and the messageCallback constant.
                    if (result != '') { 
                        this.batchJobId = result;
                        if (this.blnPortalUser) {
                            this.monitorBatchProgress();
                        }
                    }
                    // create f&c record and box file from uploaded file
                    //this.createFCRecordAndBoxFile();  
                })
                .catch((error) => {
                    this.error = error;
                    console.log(
                        'Error in saveEDIRepaiedLeaks: ',
                        JSON.stringify(this.error)
                    );
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: this.error,
                            variant: 'error'
                        })
                    );
                });
                
        }//for loop ends here

        this.createFCRecordAndBoxFile();


    }


    createFCRecordAndBoxFile() {
        let fcRecordId;
        createFCRecord({
            notificationId: this.notificationID,
            fileId: this.fileDocId
        })
            .then((recordId) => {
                fcRecordId = recordId;
                return createBoxFile({
                    notificationId: this.notificationID,
                    fileId: this.fileDocId
                });
            })
            .then((fcRecordWithFileDetails) => {
                const fcRecord = { Id: fcRecordId, ...fcRecordWithFileDetails };
                return updateFCRecord({ fcRecord });
            })
            .then(() => {
                deleteDocument({ strEDIFileId: this.fileDocId });
                this.handleFullScreenRefresh();
            })
            .catch((err) => {
                this.error = err;
                console.log("[!!!WRN] save file error: " + JSON.stringify(err));     
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: `The leak data was successfully uploaded, but there was a problem saving the file: ${
                            (err || {}).message || 'Unknown Error.'
                        }`,
                        variant: 'error'
                    })
                );
            })
            .finally(() =>{
                this.clearCacheOfStoredVariables();
            });       
    }

    monitorBatchProgress() {
        this.isBatchSaving = true;
        getBatchStatus({ strJobId: this.batchJobId })
            .then((result) => {
                console.log('monitorBatchProgress()');
                console.log(result);
                if (result == 'Completed') {
                    window.clearTimeout(this.delayTimeout);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!',
                            message:
                                'EDI Repaired Leak records loaded successfully.',
                            variant: 'success'
                        })
                    );
                    this.isBatchSaving = false;
                    this.handleFullScreenRefresh();
                } else {
                    this.delayTimeout = setTimeout(() => {
                        this.monitorBatchProgress();
                    }, 10000);
                }
            })
            .catch((error) => {
                this.error = error;
                console.log(
                    'Error in saveEDIRepaiedLeaks: ',
                    JSON.stringify(this.error)
                );
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!',
                        message: this.error,
                        variant: 'error'
                    })
                );
            });
    }
    //removes EDI file from Salesforce
    deleteEDIFile() {
        //this.closeModal();
        // deleteDocument({ strEDIFileId: this.fileDocId })
        //     .then((result) => {
        //         this.closeModal();
        //     })
        //     .catch((error) => {
        //         this.error = error.message;
        //     });
    }
    //to call a list of regulated entities
    getRegEntIds() {
        getRegEntIdList({ strOrgID: this.organizationAccountId })
            .then((result) => {
                this.objRegEntMap = result;
            })
            .catch((error) => {
                this.error = error.message;
            });
    }

    //gets Notification Details Record Type Id
    NotifDetRecType() {
        getIdOfNotDetRecType()
            .then((result) => {
                this.recTypNotDetId = result;
            })
            .catch((error) => {
                this.message = error;
                this.message =
                    'Error received: code ' +
                    error.errorCode +
                    ', ' +
                    'message ';
            });
    }
    //SET BOOLEAN VALUE AND CALLING PARENT CMP OF AURA COMPONENT
    fireCustomEvent(blnValue) {
        const value = blnValue;
        const valueChangeEvent = new CustomEvent('valuechange', {
            detail: {
                value
            }
        });
        this.dispatchEvent(valueChangeEvent);
    }

    checkPortalUser() {
        console.log('In checkPortalUser()');
        console.log(this.blnPortalUser);
        //Check if the user is a portal user.
        if (this.blnPortalUser) {
            console.log('User is a portal User');
            console.log(
                'this.organizationAccountId: ',
                this.organizationAccountId
            );
            console.log('this.blnOrgAccess: ' + this.blnOrgAccess);

            //If the user is a Portal user, validate that they are associated with the the Organization for which they are submitting a PS-95
            if (this.blnOrgAccess) {
                //User is a portal user and is associated with the Organization for which the PS-95 is being submitted.
                //Update Notification Record and Insert Notification Details Records.
                this.updateNotification();
                this.saveNotificationDetails();
            }
            //User is not associated with the Organization in the PS-95 Report.
            //Throw an error notifying the user that they cannot submit save the EDI submission.
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message:
                            'Your user does not belong to the Organization listed on the PS-95 record(s). Your user will be unable to complete a PS-95 EDI submission.',
                        variant: 'error'
                    })
                );
            }
        } else {
            console.log('Is Current user a Portal user? ', this.blnPortalUser);
            //User is an internal not portal user.
            //Update Notification Record and Insert Notification Details Records.
            this.updateNotification();
            this.saveNotificationDetails();
        }
    }

    subscribeEDISaveEvent() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            // Response contains the payload of the new message received
            if (response.data.payload.IETRS_Job_ID__c == this.batchJobId) {
                console.log(
                    'New Platform Event received: ',
                    JSON.stringify(response)
                );
                this.isBatchSaving = false;
                // Show Success Message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!',
                        message:
                            'EDI Repaired Leak records loaded successfully.',
                        variant: 'success'
                    })
                );
                this.handleFullScreenRefresh();
            }
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            console.log("[Debug] channelName-------> " + this.channelName);
            console.log(
                'Subscription request sent to: ',
                JSON.stringify(response.channel)
            );
            this.subscription = response;
            this.isBatchSaving = true;
        });
    }
    register() {
        pubsub.register('simplevt', this.handleEvent.bind(this));
    }

    handleEvent(messageFromEvt) {
        if (hasEditPS95 == true) {
            this.isDataCreated = true;
        }
        var LWCQueryObj = messageFromEvt;

        if (LWCQueryObj.getNotificationRecord == 'no rows') {
            this.isHeaderDisplayTextShow = true;
            this.isHeaderDisplayRecordsFound = false;
            this.isNoRecords = true;
            this.operatorName = LWCQueryObj.operatorNameParent;
            this.ReportPeriod = LWCQueryObj.ReportPeriodParent;
            this.companyId = LWCQueryObj.companyIdParent;
            this.organizationAccountId = LWCQueryObj.accRecordID;
            this.notificationID = LWCQueryObj.Id;
        } else {
            this.isHeaderDisplayTextShow = false;
            this.isHeaderDisplayRecordsFound = true;
            this.isNoRecords = false;
            this.operatorName =
                LWCQueryObj.getNotificationRecord.IETRS_PS95_Organization__r.Name;
            this.ReportPeriod =
                LWCQueryObj.getNotificationRecord.IETRS_Report_Period__c;
            this.companyId =
                LWCQueryObj.getNotificationRecord.IETRS_PS95_Organization__r.IETRS_Company_ID__c;
            this.p5Number =
                LWCQueryObj.getNotificationRecord.IETRS_P5_Number_Formula__c;
            this.organizationAccountId =
                LWCQueryObj.getNotificationRecord.IETRS_PS95_Organization__c;
            this.notificationID = LWCQueryObj.getNotificationRecord.Id;
        }
        identifyPortalUserAccessOrganization({
            organizationId: this.organizationAccountId
        })
            .then((result) => {
                this.blnOrgAccess = result;
                console.log('event identy portal user access');
                console.log(this.organizationAccountId);
                console.log(this.blnOrgAccess);
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
    }
    //handles the file load and reads it to a string
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFile = event.detail.files;
        this.ediFileName = uploadedFile[0].name;
        this.fileDocId = uploadedFile[0].documentId;
        //use Doc ID and process in Class
        readEDIFile({
            //strBody: fileDocId
            strEDIFileId: this.fileDocId
        })
            .then((result) => {
                console.log('handleUploadFinished() Promise.');
                this.updatedFileResponse = result;
                //console.log("[debug] uploaded File content: ----> " + result);
                this.isNextBtnDisabled = false;
            })
            .catch((errorLoadEDI) => {
                this.message = errorLoadEDI;
            });
    }

    /**************************************************
    SCREEN MANIPULATION HELPER FUNCTIONS
    ***************************************************/
    handleFullScreenRefresh() {
        getNotificationRecord({
            operatorName: this.operatorName,
            p5Number: this.p5Number,
            reportingPeriod: this.ReportPeriod
        })
            .then((result) => {
                this.fireCustomEvent(true);
                this.setNotificationRecord = result;
                if (result == null) {
                    //this.noRecordsMethod();
                    console.log('No records found');
                } else {
                    let message = {
                        getNotificationRecord: this.setNotificationRecord
                    };
                    pubsub.fire('simplevt', message);
                }
            })
            .catch((error) => {
                this.error = error;
                console.log('SearchError ' + this.error);
            });
    }

    /**************************************************
    UTILITY METHODS
    ***************************************************/
   showPercentage(currentProgress, totalTasks){
    return (currentProgress / totalTasks).toFixed(2) * 100;
   }

   clearCacheOfStoredVariables(){
    this.updatedFileResponse = null;
            this.ediFileName = null;
            this.arrNotificationDetails = [];
            this.arrErrorMessages = [];
            this.fileDocId = null;
            this.isLoaded = false;
            this.numValidationCount = 0;
            this.numValidationPercent = 0;
   }

}