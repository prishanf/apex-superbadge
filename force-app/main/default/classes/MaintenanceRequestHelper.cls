public with sharing class MaintenanceRequestHelper {

    private Static String CASE_TYPE_REPAIR = 'Repair';
    private Static String CASE_TYPE_RM= 'Routine Maintenance';
    private Static String CASE_STATUS_CLOSED= 'Closed';
    private Static String CASE_NEW_TITLE= 'Maintenance Reminder for:';
    
    public static void createNextMaintainanceRequest(Map<Id,Case> maintenanceRequestsMap){
        List<Case> maintenanceRequests = selectCasesWithWorParts(maintenanceRequestsMap.keySet());
        
        List<Case> futureMaintenanceRequets = new List<Case>();
        
        for(Case item : maintenanceRequests ){
                
                Case newMaintenanceRequest = new Case();
                List<Work_Part__c> workParts =  item.Work_Parts__r;
                Work_Part__c workPart =null;
                if(workParts !=null && workParts.size()>0){
                    workPart = getShortestLifEquipment(workParts);
                }
                newMaintenanceRequest.Type =CASE_TYPE_RM;
                newMaintenanceRequest.Vehicle__c = item.Vehicle__c;
                newMaintenanceRequest.Date_Reported__c = Date.today();
                // When Request has multiple Equipments 
                if(workPart != null){
                    newMaintenanceRequest.Subject = CASE_NEW_TITLE + workPart.Equipment__r.Name;
                    newMaintenanceRequest.Date_Due__c = newMaintenanceRequest.Date_Reported__c.addDays(Integer.valueOf(workPart.Equipment__r.Maintenance_Cycle__c));
                    newMaintenanceRequest.Equipment__c = workPart.Equipment__c;
                }else{
                    newMaintenanceRequest.Subject = CASE_NEW_TITLE + item.Equipment__r.Name;
                    newMaintenanceRequest.Date_Due__c = newMaintenanceRequest.Date_Reported__c.addDays(Integer.valueOf(item.Equipment__r.Maintenance_Cycle__c));
                    newMaintenanceRequest.Equipment__c = item.Equipment__c;
                }
                futureMaintenanceRequets.add(newMaintenanceRequest);
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

    private  static List<Case> selectCasesWithWorParts(Set<Id> caseIds) {
        return [SELECT id, Status, Type,Vehicle__c,Equipment__c,Equipment__r.Name, Equipment__r.Maintenance_Cycle__c,
                    (SELECT Id,Equipment__r.Name, Equipment__r.Maintenance_Cycle__c FROM Work_Parts__r)
                FROM CASE 
                WHERE Id in :caseIds and Status = : CASE_STATUS_CLOSED AND ( Type=:CASE_TYPE_REPAIR OR Type =:CASE_TYPE_RM)];
    }

}
