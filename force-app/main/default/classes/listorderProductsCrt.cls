public with sharing class listorderProductsCrt {
    @AuraEnabled(cacheable=true)
    public static List <OrderItem> listOrder( Id recordId) {
        system.debug('recordId '+recordId);
        List<OrderItem> orderList = [SELECT Id,OrderId,OrderItemNumber,
        PricebookEntryId,Product2Id,Quantity,TotalPrice,UnitPrice
         FROM OrderItem
         Where
         OrderId =: recordId];
        system.debug('orderList '+orderList);
        return orderList;
    }
    @AuraEnabled
    public static List <OrderItem> addProduct( Id orderId, Id  productId,Decimal unitPriceVal ) {
        system.debug('orderId '+orderId);
        system.debug('productId '+productId);
        system.debug('unitPriceVal '+unitPriceVal);

        List<OrderItem> orderList = [SELECT Id,OrderId,OrderItemNumber,
        PricebookEntryId,Product2Id,Quantity,TotalPrice,UnitPrice
         FROM OrderItem
         Where
         OrderId =: orderId];
map<Id,OrderItem> mapIdProdOrderItem= new map<Id,OrderItem>();
for(OrderItem orderItem:orderList){  
        mapIdProdOrderItem.put(orderItem.PricebookEntryId,orderItem);    

}
OrderItem newItem;
if(mapIdProdOrderItem.containsKey(productId)){
    newItem= mapIdProdOrderItem.get(productId);
    newItem.Quantity++;
    newItem.UnitPrice+=unitPriceVal;

}
else{
        newItem= new OrderItem();
        newItem.OrderId=orderId;
        newItem.PricebookEntryId=productId;
        newItem.Quantity=1;
        newItem.UnitPrice=unitPriceVal;

}
try {
    upsert newItem;
    
} catch (Exception e) {
    throw new AuraHandledException( e.getMessage());
}     

       
       
        return listOrder( orderId);
    }

    @AuraEnabled
    public static responseWrapper syncProduct( Id orderId ) {
        responseWrapper returnValue= new responseWrapper();
        List<OrderItem> orderList = [SELECT  Id,OrderId,OrderItemNumber,
        Order.Account.AccountNumber,Order.OrderNumber,Order.Type, Order.Status,
        PricebookEntryId,Product2Id,Quantity,TotalPrice,UnitPrice, PricebookEntry.ProductCode
         FROM OrderItem
         Where
         OrderId =: orderId];
    String accountNumber;
    String orderNumber;
    String orderType;
    String OrderStatus;
    list<orderProduct> orderLineProducts = new list<orderProduct>();
    for(OrderItem orderitem:orderList){
        orderProduct newitem= new orderProduct();
        newitem.name=orderitem.OrderItemNumber;
        newitem.code=orderitem.PricebookEntry.ProductCode;
        newitem.unitPrice=orderitem.UnitPrice;
        newitem.quantity=orderitem.Quantity;
        accountNumber=orderitem.Order.Account.AccountNumber;
        orderNumber=orderitem.Order.OrderNumber;
        orderType=orderitem.Order.Type;
        OrderStatus=orderitem.Order.Status;
        orderLineProducts.add(newitem);
    
    }
    syncWrapper bodyWrapper= new   syncWrapper();
    bodyWrapper.accountNumber = accountNumber;
    bodyWrapper.orderNumber = orderNumber;
    bodyWrapper.type = orderType;
    bodyWrapper.status = OrderStatus;
    bodyWrapper.orderProducts=orderLineProducts;

try {

    Http http = new Http();
    HttpRequest reqTwo = new HttpRequest();
    HttpResponse respTwo = new HttpResponse();
   
    String reqTwoBody=JSON.serialize(bodyWrapper);
    system.debug('reqTwoBody : '+reqTwoBody);

    reqTwo.setMethod('POST');  
    reqTwo.setHeader('Content-Type', 'application/json');       
    reqTwo.setHeader('Accept', 'application/json');


      
    reqTwo.setEndpoint('callout:interview');       
    reqTwo.setBody(reqTwoBody); 

    respTwo = http.send(reqTwo);            
    system.debug('Response Two : '+respTwo);   
    if (respTwo.getStatusCode() != 200) {
        System.debug('The status code returned was not expected: ' + respTwo.getStatusCode() + ' ' + respTwo.getStatus());
        returnValue.isSuccess=false;   
        returnValue.message='The status code returned was not expected: ' + respTwo.getStatusCode() + ' ' + respTwo.getStatus();
        return returnValue;
       
    } 

Order orderUpdate= new Order();
orderUpdate.Id=orderId;
orderUpdate.Status='Activated';
update orderUpdate;

returnValue.isSuccess=true;   

} catch (Exception  e) {
    throw new AuraHandledException( e.getMessage());
}
system.debug('returnValue : '+returnValue); 
    return returnValue;
    
    
         
}
    
    
    
    public class orderProduct{
        public String name { get; set; }
        public String code { get; set; }
        public Decimal unitPrice { get; set; }
        public Decimal quantity { get; set; }  
       
    }
    
    public class syncWrapper{
    
        public String accountNumber { get; set; }
        public String orderNumber { get; set; }
        public String type { get; set; }
        public String status { get; set; }    
        public list<orderProduct> orderProducts { get; set; }
    }
    
    public class responseWrapper{
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;

    }

}





