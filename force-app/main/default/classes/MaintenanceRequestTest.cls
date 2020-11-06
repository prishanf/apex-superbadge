@isTest
public with sharing class MaintenanceRequestTest {
    
    @testsetup
    public static void testDataSetup(){
        List<Product2>  products = createEquimplement(1,true);
        List<Vehicle__c> vehicals = createVehical(1,true);
        List<Case>  requests = createMaintainanceRequest(1,true, vehicals,products);
        //addWorkParts(requests[0],products);

    }
    @isTest
    public static void testAutoMaintainanceWithWorkItems(){
        Case currentRequest = [SELECT Subject, Vehicle__c,Equipment__c, Type, status FROM Case Limit 1];
        Product2 equipment1 = createEquimplement(100);
        Product2 equipment2 = createEquimplement(50);
        addWorkParts(currentRequest,new List<Product2>{equipment1,equipment2});

        currentRequest.Status='Closed';
        update currentRequest;
        List<Case> newCases = [SELECT Subject, Date_Due__c, Vehicle__c,Equipment__c, Type, status FROM Case WHERE id != :currentRequest.Id];
        System.debug(newCases);
        System.assertEquals(1, newCases.size());
        System.debug('newCase Due Date: ' + newCases[0].Date_Due__c);
        System.assertEquals(Date.today().addDays(50), newCases[0].Date_Due__c);
    }

    @isTest
    public static void testAutoMaintainanceRecordsWithNoWorkItem(){
        Case currentRequest = [SELECT Subject, Vehicle__c,Equipment__c, Type, status FROM Case Limit 1];
        currentRequest.Status='Closed';
        update currentRequest;
        List<Case> newCases = [SELECT Subject, Date_Due__c, Vehicle__c,Equipment__c, Type, status FROM Case WHERE id != :currentRequest.Id];
        System.debug(newCases);
        System.assertEquals(1, newCases.size());
        System.assertEquals(Date.today().addDays(180), newCases[0].Date_Due__c);
    }

    @isTest
    public static void testBulkAutoMaintainanceRecordsWithNoWorkItem(){
        List<Product2>  products = createEquimplement(100,true);
        List<Vehicle__c> vehicals = createVehical(200,true);
        List<Case>  requests = createMaintainanceRequest(300,true, vehicals,products);


        List<Case> currentRequests = [SELECT Subject, Vehicle__c,Equipment__c, Type, status FROM Case Limit 300];
        for (Case currentRequest : currentRequests) {
            currentRequest.Status='Closed';
        }
       
        update currentRequests;
        List<Case> newCases = [SELECT Subject, Date_Due__c, Vehicle__c,Equipment__c, Type, status FROM Case WHERE id != :currentRequests];
        System.debug(newCases);
        System.assertEquals(301, newCases.size());
        System.assertEquals(Date.today().addDays(180), newCases[10].Date_Due__c);
    }

    @isTest
    public static void testBulkAutoMaintainanceRecordsWithWorkItem(){
        List<Product2>  products = createEquimplement(100,true);
        List<Vehicle__c> vehicals = createVehical(200,true);
        List<Case>  requests = createMaintainanceRequest(300,true, vehicals,products);
       
        

        Product2 equipment1 = createEquimplement(100);
        Product2 equipment2 = createEquimplement(50);

        List<Case> currentRequests = [SELECT Subject, Vehicle__c,Equipment__c, Type, status FROM Case Limit 300];
        for (Case currentRequest : currentRequests) {
            currentRequest.Status='Closed';
        }
        addWorkParts(currentRequests,new List<Product2>{equipment1,equipment2});
        update currentRequests;
        List<Case> newCases = [SELECT Subject, Date_Due__c, Vehicle__c,Equipment__c, Type, status FROM Case WHERE id != :currentRequests];
        System.assertEquals(301, newCases.size());
        System.debug('newCase Due Date: ' + newCases[50].Date_Due__c);
        System.assertEquals(Date.today().addDays(50), newCases[50].Date_Due__c);
    }


    public static List<Product2> createEquimplement(Integer numOfRecods, Boolean isInsert){
        List<Product2> equipments = new List<Product2>();
        for(Integer i=0; i<numOfRecods; i++){
            equipments.add(new Product2(Name='Test Equipments' + i, Maintenance_Cycle__c = 180, Lifespan_Months__c=24,Replacement_Part__c=true));
        }
        if(isInsert){
            insert equipments;
        }
        return equipments;
    }

    public static Product2 createEquimplement(Integer lifespan){
        Product2 equipment  = new Product2(Name='Test Equipments', Maintenance_Cycle__c = lifespan, Lifespan_Months__c=24,Replacement_Part__c=true);
        insert equipment;
        return equipment;
    }

    public static List<Vehicle__c> createVehical(Integer numOfRecods, Boolean isInsert){
        List<Vehicle__c> equipments = new List<Vehicle__c>();
        for(Integer i=0; i<numOfRecods; i++){
            equipments.add(new Vehicle__c(Name='Test Equipments' + i));
        }
        if(isInsert){
            insert equipments;
        }
        return equipments;
    }

    public static List<Case> createMaintainanceRequest(Integer numOfRecods, Boolean isInsert,List<Vehicle__c> vehicals,List<Product2> equipments){
        List<Case> maintainanceRequests = new List<Case>();
        List<String> types = new List<String>{'Repair','Routine Maintenance'};
        for(Integer i=0; i<numOfRecods; i++){
            Vehicle__c vehical = null;
            Product2 equipment = null;
            if(vehicals!=null && vehicals.size()>0){
                vehical = vehicals.get(generateRandomNumber(vehicals.size()));
            }
            if(equipments!=null && equipments.size()>0){
                equipment = equipments.get(generateRandomNumber(equipments.size()));
            }

            maintainanceRequests.add(new Case(Subject='Test Case' + i,Type=types.get(generateRandomNumber(types.size())),Vehicle__c =vehical.Id, Equipment__c=equipment.Id));
        }
        if(isInsert){
            insert maintainanceRequests;
        }
        return maintainanceRequests;
    }

    public static void addWorkParts(Case mrequest,List<Product2> equipments){
        List<Work_Part__c> workParts = new List<Work_Part__c>();
        for(Product2 part : equipments){
            workParts.add(new Work_Part__c(Maintenance_Request__c=mrequest.id, Equipment__c = part.id));
        }
        insert workParts;
    }

    public static void addWorkParts(List<Case> mrequests,List<Product2> equipments){
        List<Work_Part__c> workParts = new List<Work_Part__c>();
        for(Case item : mrequests ){
            for(Product2 part : equipments){
                workParts.add(new Work_Part__c(Maintenance_Request__c=item.id, Equipment__c = part.id));
            }
        }
        insert workParts;
    }

    private static Integer generateRandomNumber(Integer size){
        Decimal d = math.random() * size;
        return d.intValue();
    }
}
