// Script to get Fields for a given Object 

void getFieldApis(String sObjectName){
    System.debug('=========  '+ sObjectName +'=============');
    List<Schema.SObjectField> sss=new list<Schema.SObjectField>();
    List<String> fieldNames = new List<String>();

    if(sObjectName != null && sObjectName != '' ){

        Schema.SObjectType gd = Schema.getGlobalDescribe().get(sObjectName); 
        Schema.DescribeSobjectResult dsr = gd.getDescribe();
        fieldNames.addAll(dsr.fields.getMap().keyset());
        System.debug( String.join(fieldNames,','));
        
    }
}

String sObjectName = 'Product2';
getFieldApis(sObjectName);

Integer generateRandomNumber(Integer size){
        Decimal d = math.random() * size;
        return d.intValue();
    }

System.debug('randomNumber  is '+generateRandomNumber(1));

String CRON_EXP = '0 0 1 * * ? *';
String jobID = system.schedule('External Equipment Data Sync', CRON_EXP, new WarehouseSyncSchedule());
