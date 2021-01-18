// subscribeComponent.js
import { LightningElement, wire } from "lwc";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";

import SAMPLEMC from "@salesforce/messageChannel/MyMessageChannel__c";

export default class SubscribeComponent extends LightningElement {
  @wire(MessageContext)
  messageContext;

  subscription = null;
  receivedMessage;
  isDisabled = false;
  isDisabledUnsb = true;
  subscribeMC() {
    this.isDisabled = true;
    this.isDisabledUnsb = false;
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(
      this.messageContext,
      SAMPLEMC,
      message => {
        this.handleMessage(message);
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  unsubscribeMC() {
    unsubscribe(this.subscription);
    this.subscription = null;
    this.isDisabled = false;
    this.isDisabledUnsb = true;
  }

  handleMessage(message) {
      console.log('message ',message);
    this.receivedMessage = message
      ? JSON.stringify(message, null, "\t")
      : "no message payload";
  }
}