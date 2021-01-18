// publisherComponent.js
import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import SAMPLEMC from '@salesforce/messageChannel/MyMessageChannel__c';

export default class PublisherComponent extends LightningElement {
    @wire(MessageContext)
    messageContext;
          
    handleClick() {
        const message = {
            recordId: '001xx000003NGSFAA4',
            message : "This is simple message from LWC",
            source: "LWC",
            recordData: {accountName: 'Burlington Textiles Corp of America'}
        };
        publish(this.messageContext, SAMPLEMC, message);
    }
}