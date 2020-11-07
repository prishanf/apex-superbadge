@isTest
public with sharing class WarehouseCalloutServiceTest {
    
    @IsTest
    static void testrunWarehouseEquipmentSync(){
        
       
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        List<Product2> products = [SELECT Id FROM Product2];
        System.assertEquals(0, products.size());
        System.debug(products);
        WarehouseCalloutService.runWarehouseEquipmentSync();
        
        Test.stopTest();
        products = [SELECT Id FROM Product2];
        System.debug(products);
        System.assertEquals(22, products.size());
        
    }


}
