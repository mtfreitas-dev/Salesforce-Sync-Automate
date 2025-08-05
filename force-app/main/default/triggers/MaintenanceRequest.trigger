trigger MaintenanceRequest on Case (after insert, after update) {
    switch on Trigger.operationType {
        when  AFTER_UPDATE{
            MaintenanceRequestHelper.createNewCase(Trigger.newMap);
        }
    }
}