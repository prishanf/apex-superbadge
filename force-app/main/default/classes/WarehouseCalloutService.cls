public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
   
    public static void runWarehouseEquipmentSync() {
        handleUpdates();
                
    }

    @Future(callout=true)
    public static void handleUpdates(){
        List<Equipment> equimentList =  makeGetCallout();
        updateEquipments(equimentList);
    }

    public static List<Equipment> makeGetCallout() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        List<Equipment> results = null;
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            String resposeBody = response.getBody().replaceAll('_', '');
            results = (List<Equipment>)JSON.deserializeStrict(resposeBody, List<Equipment>.class);
            // Cast the values in the 'animals' key as a list
            System.debug('Received the following animals:' + results);
  
        }
        return results;
    }

    private static void updateEquipments(List<Equipment> equimentList){
        List<Product2> toUpdate = new List<Product2>();
        for(Equipment eqip : equimentList){
            toUpdate.add(new Product2(Name=eqip.Name, Warehouse_SKU__c= eqip.Sku,Replacement_Part__c=eqip.Replacement,
                    Maintenance_Cycle__c=eqip.Maintenanceperiod,
                    Lifespan_Months__c=eqip.Lifespan,Cost__c=eqip.Cost,Current_Inventory__c=eqip.Quantity,ExternalId=eqip.Id)
            );
        }
        Schema.SObjectField f = Product2.Fields.Warehouse_SKU__c;
        System.debug(toUpdate);
        Database.UpsertResult [] cr = Database.upsert(toUpdate, f, false);
        System.debug(cr);
        //upsert toUpdate;
    }
    
    public class Equipment {
        public String Id {get;set;}
        public Boolean Replacement {get;set;}
        public Integer Quantity {get;set;}
        public String Name {get;set;}
        public Integer Maintenanceperiod {get;set;}
        public Integer Lifespan {get;set;}
        public Double Cost {get;set;}
        public String Sku {get;set;}
    }

}