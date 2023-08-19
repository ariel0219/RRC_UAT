import { LightningElement } from 'lwc';
import  wrapper  from '@salesforce/apex/RRC_BoxAccess_AuraEnabled.initiateBoxConnection';

const fs = require('node:fs');

const Box = require('box-node-sdk');

export default class RRC_BoxUploader extends LightningElement {

    constructor(filename, folderID) {
    super()

    this.filename = filename;
    this.fileSize = fs.stat(this.filename).size;
    this.folderID = folderID;

    this.sdk = new Box({
      clientID: wrapper.clientID,
      clientSecret: wrapper.clientSecret,
    });

    this.client = this.sdk.getBasicClient(wrapper.downscopeToken)

    this.stream = fs.createReadStream(filename);
  }

  upload() {
    return this.client.files.getNewVersionChunkedUploader(
      this.folderID,
      this.fileSize,
      this.filename,
      this.stream,
    )
      .then(uploader => uploader.start())
    ;
  }
}