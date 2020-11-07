@isTest
public with sharing class WarehouseSyncScheduleTest {

    public static String CRON_EXP = '0 0 1 * * ? *';
    @IsTest
    static void testSchdeuleJob(){
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        List<Product2> products = [SELECT Id FROM Product2];
        System.assertEquals(0, products.size());
        System.debug(products);
        String jobId = System.schedule('WarehouseSyncScheduleTest',CRON_EXP,new WarehouseSyncSchedule());
        Test.stopTest();
        
    }
}
