public without sharing class CoreService {

    public static sObject getName(Id lookupId){
        String sObjectName = lookupId.getSObjectType().getDescribe().getName();
        String query = 'SELECT Name FROM ' + sObjectName + ' WHERE id = \'' + lookupId + '\'';
        List<sObject> records;
        // SR: CRUD Check
        if ( lookupId.getSObjectType().getDescribe().isAccessible() ) {
            records = Database.query(query);
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{sObjectName}));
        }
        return !records.isEmpty() ? records[0] : null;
    }

}
