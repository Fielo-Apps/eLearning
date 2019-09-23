public with sharing class LookupController {
	@auraEnabled
	public static List<sObject> getRecords(String objectName, String fields, String whereClause) {
		try{
			List<String> fieldSet = new List<String>();
			DescribeSObjectResult sObjectDescribe = Schema.describeSObjects(new String[]{objectName})[0];
			Map<String, Schema.SObjectField> fieldsMap = sObjectDescribe.fields.getMap();

			if( fields != null && fields != '' ){
				for(String s : fields.split(',')){
					if( fieldsMap.containsKey(s.trim()) && fieldsMap.get(s.trim()).getDescribe().isAccessible() ) {
						fieldSet.add(s);
					}
				}
			}
			fieldSet.add('Id');
			fieldSet.add('Name');

			String query = 'SELECT ' + String.join(fieldSet,',') + ' FROM ' + objectName;
			if (whereClause != null && whereClause != '') {
				query += ' WHERE Name LIKE \'%' + whereClause + '%\'';
			}

			query += ' ORDER BY LastModifiedDate';
			if( !(whereClause != null && whereClause != '') ){
				query += ' LIMIT 5';
			}

			if( sObjectDescribe.isAccessible() ){
				return Database.query(query);
			} else {
				return new List<sObject>();
			}
		} catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
	}
}