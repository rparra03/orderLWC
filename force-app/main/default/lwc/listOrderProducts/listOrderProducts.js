import { LightningElement , wire, track, api} from 'lwc';
import getListOrder from '@salesforce/apex/listorderProductsCrt.listOrder';
import addProduct from '@salesforce/apex/listorderProductsCrt.addProduct';
import syncProduct from '@salesforce/apex/listorderProductsCrt.syncProduct';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
  } from "lightning/messageService";
  
import SAMPLEMC from "@salesforce/messageChannel/MyMessageChannel__c";
export default class ListOrderProducts extends LightningElement {
    @wire(MessageContext)
    messageContext;

    @api recordId;

    subscription = null;
    receivedMessage;

    @track columns = [{
        label: 'Order name',
        fieldName: 'OrderItemNumber',
        type: 'text',
        sortable: true
    },
    {
        label: 'Unit Price',
        fieldName: 'UnitPrice',
        type: 'currency',
        sortable: true
    },
    {
        label: 'Quantity',
        fieldName: 'Quantity',
        type: 'number',
        sortable: true
    },
    {
        label: 'Total Price',
        fieldName: 'TotalPrice',
        type: 'currency',
        sortable: true
    }
    
];

@track error;
@track accList ;
@wire(getListOrder,{ recordId : '$recordId'})
    wiredAccounts({
        error,
        data
    }) {
        if (data) {
            this.accList = data;
        } else if (error) {
            console.log('error',error);
            this.error = error;
        }
    }
    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            SAMPLEMC,
            message => {
            this.handleMessage(message);
            },
            { scope: APPLICATION_SCOPE }
        );
    }

    handleMessage(message) {
        console.log('message ',message);
        this.receivedMessage = message
          ? JSON.stringify(message, null, "\t")
          : "no message payload";
        this.addProduct(message);

      }

      addProduct(productIdvalue){ 
            
        return  addProduct({  orderId : this.recordId, productId :productIdvalue.recordData.Id, unitPriceVal : productIdvalue.recordData.UnitPrice    })
        .then(result => {
          
            this.accList = result;
            this.error = undefined;
        })
        .catch(error => {
            console.log('error ',error);
            this.error = error;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'external system Error '+error.body.message,
                variant:'error'
            });
            this.dispatchEvent(event);
        });
    }

    handleSync() {
        console.log('sync ');
        syncProduct({  orderId : this.recordId  })
        .then(result => {
            console.log('result ',result);
          if(result.isSuccess){
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'external system ok',
                variant:'success'
            });
            this.dispatchEvent(event);
          }
          else{
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'external system Error '+result.message,
                variant:'error'
            });
            this.dispatchEvent(event);
          }
            
        })
        .catch(error => {
            console.log('error ',error);
            this.error = error;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'external system Error '+error.body.message,
                variant:'error'
            });
            this.dispatchEvent(event);
            
        });
       

      }

}