@isTest
global class WarehouseCalloutServiceMock  implements HttpCalloutMock{
    //implementa chamada simulada http
    // implement http mock callout
    global HttpResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('[{"_id":"55d66226726b611100aaf741","replacement":false,"quantity":5,"name":"Generator 1000 kW","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"100003"}]');
        return response;
    }
}