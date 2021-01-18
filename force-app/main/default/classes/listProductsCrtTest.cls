@isTest
public  class listProductsCrtTest {
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
        
                
        
                List<Order> orderList = [SELECT Id
                 FROM Order
                 
                ];
               
               
                Test.startTest();  
                List <PricebookEntry> listPricebookEntry =listProductsCrt.listProducts( 25, 0,orderList[0].Id );
               
                Test.stopTest();
                System.assertEquals(1, listPricebookEntry.size());
        
               
        
            }


}

