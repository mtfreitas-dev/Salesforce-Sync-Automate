public with sharing class WarehouseSyncSchedule implements Schedulable{
    //implementa código agendado
    //implement scheduled code
    public void execute(SchedulableContext ctx){
        System.enqueueJob(new WarehouseCalloutService());
    }
}