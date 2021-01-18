@isTest
public  class listorderProductsCrtTest {
    @testSetup static void setup() {

       
Product2 pro = new Product2(Name = 'iPhone X', Family = 'Mobile');
Insert pro;
 

Pricebook2 standardPricebook = new Pricebook2(
    Id = Test.getStandardPricebookId(),
    IsActive = true
);
 

Update standardPricebook;
 

standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];

 
 

    PricebookEntry pbe = new PricebookEntry(
        Pricebook2Id = standardPricebook.Id,
        Product2Id = pro.Id,
        UnitPrice = 1020,
        IsActive = true
    );
    Insert pbe;

    Account ta = new Account();
    ta.Name='{DAA3D05C-AD7C-4aee-988D-5DAE9F995CD4}';
    insert ta;
    Contract c = new Contract(Name='test',StartDate=Date.Today(),Status = 'Draft', AccountId = ta.Id,  ContractTerm = 4);
    insert c;
    c.Status='Activated';
    update c;
    Order to = new Order();
    to.Name = '{EC2D3B86-5BE2-4eab-9928-21F951023161}';
    to.AccountId = ta.Id;
    to.ContractId = c.Id;
    to.EffectiveDate = Date.Today();
    to.Status = 'Draft';
    to.Pricebook2Id = standardPricebook.Id;
    insert to;
 

        
    }
    @isTest
    static void positiveCalloutTest() {

        calloutMock fakeResponse = new calloutMock(200,'success', '[{"Name": "sForceTest1"}]');
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<Order> orderList = [SELECT Id
         FROM Order
         
        ];
        List<PricebookEntry> productsList = [SELECT Id,Name,Pricebook2Id,
        Product2Id,ProductCode,UnitPrice 
        FROM PricebookEntry];

        List<OrderItem> OrderItemList =listorderProductsCrt.addProduct( orderList[0].Id,productsList[0].Id,1020 );
        Test.startTest();  
            
            listorderProductsCrt.responseWrapper returnvalue= listorderProductsCrt.syncProduct( orderList[0].Id );
        Test.stopTest();
        System.assertEquals(true, returnvalue.isSuccess);

       

    }
}
