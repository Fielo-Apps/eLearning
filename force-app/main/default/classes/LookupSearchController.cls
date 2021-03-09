public  class LookupSearchController {
	@AuraEnabled
	public static List<sObject> getRecords(String fields, String sObjectName, String whereClause, Decimal quantity, Decimal offset, String orderBy) {
		try{

            List<SObject> result = new List<SObject>();
			Set<String> fieldSet = new Set<String>();
			DescribeSObjectResult objectDescribe = Schema.describeSObjects(new String[]{sObjectName})[0];
			Map<String, Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
			for(String s : fields.split(',')){
				if( fieldsMap.get(s).getDescribe().isAccessible() ){
					fieldSet.add( String.escapeSingleQuotes(s) );
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{sObjectName, s}));
				}
			}
			String query = 'SELECT {0} FROM {1} {2} ORDER BY {3} LIMIT {4} OFFSET {5}';

			if( whereClause != null && whereClause != '' ){
				whereClause = String.escapeSingleQuotes(whereClause);
			}

			query = String.format(query, new List<String>{
				String.join(new List<String>(fieldSet),','),
				sObjectName,
					whereClause != null && whereClause != ''? 'WHERE ' + (whereClause.contains('\'\'') ? whereClause.replace('\'\'','\'') : whereClause) : '',
					String.valueOf(String.escapeSingleQuotes(orderBy)),
					String.valueOf(String.escapeSingleQuotes(String.valueOf(quantity))),
					String.valueOf(String.escapeSingleQuotes(String.valueOf(offset)))
				}
			);

			System.debug(query);

			if( objectDescribe.isAccessible() ){
				result = Database.query(query);
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{ objectDescribe.getName() }));
			}

			return result;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
	}
}