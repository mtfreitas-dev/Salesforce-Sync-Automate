@IsTest
public class WarehouseSyncScheduleTest {

    //Implemente teste de agendamento
    //Implement scheduling test
    @IsTest static void testScheduledJob() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String cron = '0 0 1 * * ?';
        System.schedule('WarehouseSyncScheduleJob - Test', cron, new WarehouseSyncSchedule());

        Test.stopTest();

        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE NextFireTime > TODAY];
        System.assert(ct.size() > 0);
   }
}