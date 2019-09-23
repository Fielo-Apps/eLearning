public with sharing class PicklistController {

	public class Entry {
		public String Id{get;set;}
		public String Label{get;set;}
		public String MetaLabel{get;set;}

		public Entry ( String Id, String Label ) {
			  this.Id = Id;
			  this.Label = Label;
			}
	}

	public String cOptions {get;set;}
	public String cValue {get;set;}

	public String optionsString {get {
		if ( optionsString == null && !String.isBlank(cOptions) ) {
			optionsString = cOptions;
			if ( cOptions.substring(1) != '['  ) {
				optionsString = cOptions.replace('\'', '"');
			} else {
				optionsString = cOptions;
			}
		}
		return optionsString;
	} set;}


	public List<Entry> optionsList { get {
		  if ( optionsList == null ) {
		    if ( !String.isBlank(cOptions)  ) {
		      cOptions = cOptions.replace('\\\'', '&&&');
		      cOptions = cOptions.replace('\"', '$$$');
		      cOptions = cOptions.replace('\'', '"');
		      cOptions = cOptions.replace('&&&', '\'');
		      cOptions = cOptions.replace('$$$', '"');
		      try {
		    	optionsList = (List<Entry>) JSON.deserialize( cOptions, List<Entry>.class );
	          } catch( JSONException e ) {
	              system.debug(LoggingLevel.ERROR, 'INVALID JSON ' + cOptions );        
	          }
		    } else {
		    	optionsList = new List<Entry>();
		    }
		  }
		  return optionsList;
	} set; }

	public String fixedName { get{
		if (fixedName == null && cValue != null) {
			fixedName = ((String) getName(cValue).get('Name')) ;
		} 
		return fixedName;
	} set;}

	@RemoteAction
	public static List<sObject> getRecordsSOSL( String sObjectName, String idField, String idLabel, String metaField, String whereCondition, String searchTerm  ){
		if ( searchTerm.length() > 1 ) {
			DescribeSObjectResult objectDescribe = Schema.describeSObjects(new String[]{sObjectName})[0];
			Map<String, Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();

			String q = 'FIND {' + String.escapeSingleQuotes(searchTerm)+ '*} IN NAME FIELDS RETURNING ' + sObjectName + '( ' + idField + ',' + idLabel + ')';
			if ( !String.isBlank(whereCondition) ) {
				q += ' WHERE ' +  whereCondition.replace('/', '\'') + ' AND ';
			}

			List<List<SObject>> records;
			// SR: CRUD Check
			if ( objectDescribe.isAccessible() ) {
				// SR: FLS Check
				if ( fieldsMap.get(idField).getDescribe().isAccessible() && fieldsMap.get(idLabel).getDescribe().isAccessible() ) {
					records  = search.query( q );
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{sObjectName, idField + ',' + idLabel}));
				}
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{sObjectName}));
			}

			return records.get(0);	
		}
		return null;
	}

	@RemoteAction
	public static List<sObject> getRecords( String sObjectName, String idField, String idLabel, String metaField, String whereCondition, String searchTerm  ){
		DescribeSObjectResult objectDescribe = Schema.describeSObjects(new String[]{sObjectName})[0];
		Map<String, Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();

		String q = 'SELECT ' + idField + ',' + idLabel;
		if ( !String.isBlank(metaField) ) {
			if ( fieldsMap.get(metaField).getDescribe().isAccessible() ) {
				q += ', ' + metaField;
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{sObjectName, metaField}));
			}
		}
		q += ' FROM ' + sObjectName + ' WHERE ';
		if ( !String.isBlank(whereCondition) ) {
			q += whereCondition.replace('/', '\'') + ' AND ';
		}
		q += idLabel + ' LIKE \'%'  + String.escapeSingleQuotes(searchTerm) + '%\' LIMIT 100';

		List<sObject> records;
		// SR: CRUD Check
		if ( objectDescribe.isAccessible() ) {
			// SR: FLS Check
			if ( fieldsMap.get(idField).getDescribe().isAccessible() && fieldsMap.get(idLabel).getDescribe().isAccessible() ) {
				records  = Database.query( q );
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{sObjectName, idField + ',' + idLabel}));
			}
		}

		return records;
	}

    @RemoteAction
    public static sObject getName( ID lookupId ) {
        return CoreService.getName(lookupId);
    } 
}
