trigger MaintenanceRequest on Case (after update) {

    MaintenanceRequestHelper.createNextMaintainanceRequest(Trigger.newMap);

}