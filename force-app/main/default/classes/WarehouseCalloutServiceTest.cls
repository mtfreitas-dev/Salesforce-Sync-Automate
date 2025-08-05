@IsTest
private class WarehouseCalloutServiceTest {
    //implementa teste de callout simulado
    //implement mock callout test
    @IsTest static void wareHouseCalloutServiceTestApi(){
        WarehouseCalloutService newCallout = new WarehouseCalloutService();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        System.enqueueJob(newCallout);
        Test.stopTest();

        System.assert([SELECT count() FROM Product2] > 0, 'Product Table is empty');

    }
}