public with sharing class MaintenanceRequestHelper {
    
    public static void createNextMaintainanceRequest(Map<Id,Case> maintenanceRequestsMap){
        //Get All the Equipment is linked to the Request via work part
        //Loop through all the Mainrenance Request and get the lowest maintainance cycle and set the due date

        List<Case> maintenanceRequests = [SELECT id, Status, Type,Vehicle__c,Equipment__c,Equipment__r.Name, Equipment__r.Maintenance_Cycle__c FROM CASE Where Id in :maintenanceRequestsMap.keySet()];
        
        
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

        for(Case item : maintenanceRequests ){
            if(item.Status =='Closed' && (item.Type=='Repair' || item.Type=='Routine Maintenance')){
                Work_Part__c workPart =null;
                if(requestToWorkPartMap.get(item.id) !=null && requestToWorkPartMap.get(item.id).size()>0){
                    workPart = getShortestLifEquipment(requestToWorkPartMap.get(item.id));
                }else{

                }
               
                Case newMaintenanceRequest = new Case();
                newMaintenanceRequest.Type ='Routine Maintenance';
                newMaintenanceRequest.Vehicle__c = item.Vehicle__c;
                newMaintenanceRequest.Date_Reported__c = Date.today();
                
                
                if(workPart != null){
                    newMaintenanceRequest.Subject = 'Maintenance Reminder for '+ workPart.Equipment__r.Name;
                    newMaintenanceRequest.Date_Due__c = newMaintenanceRequest.Date_Reported__c.addDays(Integer.valueOf(workPart.Equipment__r.Maintenance_Cycle__c));
                    newMaintenanceRequest.Equipment__c = workPart.Equipment__c;
                }else{
                    newMaintenanceRequest.Subject = 'Maintenance Reminder for '+ item.Equipment__r.Name;
                    newMaintenanceRequest.Date_Due__c = newMaintenanceRequest.Date_Reported__c.addDays(Integer.valueOf(item.Equipment__r.Maintenance_Cycle__c));
                    newMaintenanceRequest.Equipment__c = item.Equipment__c;
                }
               

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
