import { LightningElement , wire, track, api} from 'lwc';
import getListproduct from '@salesforce/apex/listProductsCrt.listProducts';
import { publish, MessageContext } from 'lightning/messageService';
import SAMPLEMC from '@salesforce/messageChannel/MyMessageChannel__c';
export default class ListProducts extends LightningElement {
    @api recordId;
    @track columns = [{
        label: 'Product name',
        fieldName: 'Name',
        type: 'text',
        sortable: true
    },
    {
        label: 'Unit Price',
        fieldName: 'UnitPrice',
        type: 'currency',
        sortable: true
    },
    { type: 'button', typeAttributes: { label: 'add product to Order', name: 'second_button', variant: 'base' } },
    
];

@track error;
 accList= [];

rowLimit =25;
rowOffSet=0;


    connectedCallback() {
        this.loadData();
    }

    loadData(){
        return  getListproduct({ limitSize: this.rowLimit , offset : this.rowOffSet , orderId : this.recordId})
        .then(result => {
            let updatedRecords = [...this.accList, ...result];
            this.accList = updatedRecords;
            this.error = undefined;
        })
        .catch(error => {
            console.log('error ',error);
            this.error = error;
            this.accList = undefined;
        });
    }

    loadMoreData(event) {
        
        const { target } = event;
        target.isLoading = true;

        this.rowOffSet = this.rowOffSet + this.rowLimit;
        this.loadData()
            .then(()=> {
                target.isLoading = false;
            });   
    }

   

    @wire(MessageContext)
    messageContext;
          
    handleRowAction(event) {
        let actionName = event.detail.action.name;
        console.log('actionName ====> ' + actionName);
        let row = event.detail.row;
        console.log('row ====> ', row.Id);
        const message = {
            recordId: row.Id,
            message : "add product",
            source: "listProduct",
            recordData: row
        };
        publish(this.messageContext, SAMPLEMC, message);
    }


    
}