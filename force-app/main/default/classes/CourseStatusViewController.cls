public with sharing class CourseStatusViewController extends PageSettingsController {
	public CourseStatus__c record {get;set;}
	public String buttonString {get;set;}
	// public String toolsString {get;set;}
	public static String secondaryParameters {get;set;}
	public List<Map<String,Object>> buttonList {get;set;}
	private ApexPages.StandardController controller;
    private Set<String> fieldFilter = new Set<String> {'lastreferenceddate', 'lastvieweddate'};
	/**
    * @brief constructor
    */
	public CourseStatusViewController(ApexPages.StandardController controller) {
		String objectName = 'FieloELR__CourseStatus__c';
		this.controller = controller;
		Id recordId = controller.getId();
		Set<String> fields = new Set<String>();

		
		fields.addAll(Schema.describeSObjects(
			new String[]{objectName})[0].fields.getMap().keySet());

        if(!Test.isRunningTest()){
            this.controller.addFields(new List<String>(fields));
        }
        // Cast all fieldNames to lowercase
        for(String fieldName: fields){
            fields.remove(fieldName);
            if(!fieldFilter.contains(fieldName)){
                fields.add(fieldName.toLowerCase());
            }  
		}

        record = (FieloELR__CourseStatus__c)controller.getRecord();

		buttonList = new List<Map<String,Object>>();

		if(!buttonList.isEmpty()){
            buttonString = JSON.serialize(buttonList);
            buttonString = buttonString.substring(1,buttonString.length()-1);    
        }

        String standardTools = '';
        PageReference exportPage = Page.FieloPLT__XMLExport;
		exportPage.getParameters().put( 'retURL', System.currentPageReference().getUrl() );
		exportPage.getParameters().put( 'courseStatusId', recordId );
		exportPage.getParameters().put( 'type', 'courseStatus' );

		initPageSettings( objectName, (SObject) record, buttonString, '', '',record.Id );

		for(FieloPLT__PageSettings__c settings:relatedSettings) {
			if(settings.FieloPLT__TargetObject__c == 'FieloELR__ModuleResponse__c') {
					settings.FieloPLT__Buttons__c = !String.IsBlank(settings.FieloPLT__Buttons__c) ?
																	settings.FieloPLT__Buttons__c :
																	'';	
			}
		}

		if ( fieldList.size() > 0  ) {
			for(String fieldName:fieldList) {
				fields.add(fieldName);
			}

			// SR: Dynamic FLS Check
			Map<String,Schema.SObjectField> courseStatusFieldsMap = Schema.SObjectType.CourseStatus__c.fields.getMap();
			for (String fieldName : fields) {
				if ( courseStatusFieldsMap.containsKey(fieldName) && !courseStatusFieldsMap.get(fieldName).getDescribe().isAccessible() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'CourseStatus__c',fieldName}));
				}
			}

			String query = String.format(
				'SELECT {0} FROM {1} WHERE Id = :recordId',
				new String[]{
					String.join(new List<String>(fields), ','),
					objectName
				}
			);

			if ( Schema.sObjectType.CourseStatus__c.isAccessible() ) {
            	record = Database.query(query);
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c'}));
			}
			setRecord(record);
		}
	}

  	@RemoteAction
	public static sObject retrieve( String objectName, String recordId, String fields ){
		Schema.DescribeSobjectResult[] objectsDescribe = Schema.describeSObjects(new List<String>{objectName});
		Map<String,Schema.SObjectField> objectFieldsMap = objectsDescribe[0].fields.getMap();

		// SR: Dynamic FLS Check
		for ( String fieldName : fields.split(',') ) {
			if (!objectFieldsMap.get(fieldName.trim()).getDescribe().isAccessible() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{objectName, fieldName.trim()}));
			}
		}

		String query = 'SELECT ' + String.escapeSingleQuotes(fields);
		query += ' FROM ' + objectName;
		query += ' WHERE ID = :recordId' ;
		query += ' LIMIT 1';

		List<sObject> result;
		// SR: Dynamic CRUD Check
		if ( objectsDescribe[0].isAccessible() ) {
        	result = Database.query(query);
		} else {
			throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{objectName}));
		}
		return result.get(0);
	}


	@RemoteAction
  	public static RemoteActionResult save( CourseStatus__c record, List<String> nullFields) {
		Savepoint sp;
		RemoteActionResult result = new RemoteActionResult();
		Map<String,Schema.SObjectField> courseStatusFieldsMap = Schema.SObjectType.CourseStatus__c.fields.getMap();
		try{
			sp = Database.setSavepoint();
			for ( String f : nullFields ) {
         		record.put(f, null );
			}

			Set<String> courseStatusFields = new Set<String>(record.getPopulatedFieldsAsMap().keySet());
			if ( nullFields != null && !nullFields.isEmpty() ) {
				courseStatusFields.addAll(nullFields);
			}

			// SR: Dynamic FLS Check
			for ( String fieldName : courseStatusFields ) {
				// SR: Update / Insert Check
				if ( !courseStatusFieldsMap.get(fieldName).getDescribe().isUpdateable() || !courseStatusFieldsMap.get(fieldName).getDescribe().isCreateable() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{'CourseStatus__c', fieldName}));
				}
			}

			if( Schema.sObjectType.CourseStatus__c.isCreateable() && Schema.sObjectType.CourseStatus__c.isUpdateable() ){
				upsert record;
            } else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'CourseStatus__c'}));
			}
        	
			//TODO Crear Label DataSavedSuccessfully
			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.DataSavedSuccessfully) );
			result.redirectURL = '/' + record.Id;
    	} catch(DmlException e) {
    		if(sp != null){
	            Database.rollback(sp);
        	}
			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.ERROR,e.getDmlMessage(0)));
    	}catch(Exception e){
        	if(sp != null){
	            Database.rollback(sp);
        	}
        	result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
    	}
    	return result;
  	}

  	@RemoteAction
  	public static RemoteActionResult saveModuleResponse( SObject record, List<String> nullFields) {
		Map<String,Schema.SObjectField> objectFieldsMap = Schema.SObjectType.CourseStatus__c.fields.getMap();
		Savepoint sp;
		RemoteActionResult result = new RemoteActionResult();
		try{
			sp = Database.setSavepoint();
			for ( String f :nullFields ) {
         		record.put(f, null );
			}

			Set<String> fieldSet = new Set<String>(record.getPopulatedFieldsAsMap().keySet());
			if ( nullFields != null && !nullFields.isEmpty() ) {
				fieldSet.addAll(nullFields);
			}

			// SR: Dynamic FLS Check
			for ( String fieldName : fieldSet ) {
				// SR: Update / Insert Check
				if ( !objectFieldsMap.get(fieldName).getDescribe().isCreateable() || !objectFieldsMap.get(fieldName).getDescribe().isUpdateable()) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'CourseStatus__c', fieldName}));
				}
			}

			// TODO: Change to Create API
			if( Schema.sObjectType.ModuleResponse__c.isUpdateable() && Schema.sObjectType.ModuleResponse__c.isCreateable() ) {
				upsert (ModuleResponse__c) record;
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'ModuleResponse__c'}));
			}

			//TODO Crear Label DataSavedSuccessfully
			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.DataSavedSuccessfully) );
			result.redirectURL = '/' + record.Id;
    	}catch(DMLException e){
    		if(sp != null){
	            Database.rollback(sp);
        	}
            result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.ERROR,e.getDmlMessage(0)));
        }catch(Exception e){
    		system.debug('Exception: ' + e);
        	if(sp != null){
	            Database.rollback(sp);
        	}
        	result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
    	}
    	return result;
  	}

    public class Section {
        public String Name{get;set;}
        public List<List<FormField>> Rows{get;set;}
        public String CssClass{get;set;}
    }

    public class FormField {
        public String Type{get;set;}
        public String MetaField{get;set;}
        public String Name{get;set;}
        public String onchange{get;set;}
        public String Label{get;set;}
        public String Value{get;set;}
        public String WhereCondition{get;set;}
        public Boolean Required{get;set;}

        public String getRequiredValue () {
            if ( Required != null ) {
                return Required ? 'true' : 'false';
            }
            return '';
        }
    }
}