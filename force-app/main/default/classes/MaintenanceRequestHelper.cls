public with sharing class MaintenanceRequestHelper {
    
    public static void createNextMaintainanceRequest(Map<Id,Case> maintenanceRequestsMap){
        //Get All the Equipment is linked to the Request via work part
        //Loop through all the Mainrenance Request and get the lowest maintainance cycle and set the due date
        List<Work_Part__c> workParts = [Select Maintenance_Request__c, Equipment__c,Equipment__r.Name ,Equipment__r.Maintenance_Cycle__c 
                                            FROM Work_Part__c 
                                            WHERE Maintenance_Request__c in :maintenanceRequestsMap.keySet()];
        List<Case> futureMaintenanceRequets = new List<Case>();

        Map<Id,List<Work_Part__c>> requestToWorkPartMap = new Map<Id,List<Work_Part__c>>();
    
        for(Work_Part__c workPart : workParts){
            if(requestToWorkPartMap.containsKey(workPart.Maintenance_Request__c)){
                requestToWorkPartMap.get(workPart.Maintenance_Request__c).add(workPart);
            }else{
                requestToWorkPartMap.put(workPart.Maintenance_Request__c, new List<Work_Part__c>{workPart});
            }
            
        }

        for(Case item : maintenanceRequestsMap.values()){
            if(item.Status =='Closed' && (item.Type=='Repair' || item.Type=='Routine Maintenance')){
                Work_Part__c workPart = getShortestLifEquipment(requestToWorkPartMap.get(item.id));
                Case newMaintenanceRequest = new Case();
                newMaintenanceRequest.Type ='Routine Maintenance';
                newMaintenanceRequest.Subject = 'Maintenance Reminder for -<part Name>';
                newMaintenanceRequest.Vehicle__c = item.Vehicle__c;
                newMaintenanceRequest.Date_Reported__c = Date.today();
                newMaintenanceRequest.Equipment__c = workPart.Equipment__c;
                newMaintenanceRequest.Date_Due__c = Date.today().addDays(Integer.valueOf(workPart.Equipment__r.Maintenance_Cycle__c));

                futureMaintenanceRequets.add(newMaintenanceRequest);
            }
        }
        insert futureMaintenanceRequets;

    }


    private static Work_Part__c getShortestLifEquipment(List<Work_Part__c> workParts){
        Work_Part__c lowestMaintainanceCyclePart = null;
        Integer currentLowest = 999999;
        for(Work_Part__c part :workParts){
            Integer partCylceValue = Integer.valueOf(part.Equipment__r.Maintenance_Cycle__c);
            if(partCylceValue<currentLowest){
                currentLowest = partCylceValue;
                lowestMaintainanceCyclePart = part;
            }
        }
        return lowestMaintainanceCyclePart;
    }

}
