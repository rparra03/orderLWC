public with sharing class listProductsCrt {
    @AuraEnabled(cacheable=true)
    public static List <PricebookEntry> listProducts(Integer limitSize, Integer offset, String orderId) {
        
        system.debug('orderId '+orderId);
        list<Order> listorder=[SELECT ActivatedDate,ContractId,Id,Name,OrderNumber,
        OriginalOrderId,PoNumber,Pricebook2Id 
        FROM Order
        WHERE
        Id=:orderId];
Id pricebookOrder;
        if(listorder.size()>0){
            pricebookOrder=listorder[0].Pricebook2Id;

        }

        List<PricebookEntry> productsList = [SELECT Id,Name,Pricebook2Id,
        Product2Id,ProductCode,UnitPrice 
        FROM PricebookEntry
        WHERE        
        Pricebook2Id =:pricebookOrder
        LIMIT :limitSize
        OFFSET :offset];
        system.debug('productsList '+productsList);
        return productsList;
    }

   
}
