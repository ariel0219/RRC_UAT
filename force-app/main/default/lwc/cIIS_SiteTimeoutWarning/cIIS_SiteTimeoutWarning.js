import { LightningElement } from 'lwc';

export default class MyComponent extends LightningElement {
    connectedCallback() {
        this.startAlertTimeout();
    }

    startAlertTimeout() {
        setInterval(function() {
           window.alert('Please click "OK" to extend your RRC portal login session.');
        }, 14 * 60 * 1000);

    }

}