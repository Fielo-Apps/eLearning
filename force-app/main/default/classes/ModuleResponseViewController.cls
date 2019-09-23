public with sharing class ModuleResponseViewController extends PageSettingsController {
	public ModuleResponse__c record {get;set;}
	public String buttonString {get;set;}
	// public String toolsString {get;set;}
	public static String secondaryParameters {get;set;}
	public List<Map<String,Object>> buttonList {get;set;}
	private ApexPages.StandardController controller;

	/**
    * @brief constructor
    */
	public ModuleResponseViewController(ApexPages.StandardController controller) {
		Map<String, sObjectField> fieldsMap = Schema.sObjectType.ModuleResponse__c.fields.getMap();
		String objectName = 'FieloELR__ModuleResponse__c';
		this.controller = controller;
		Id recordId = controller.getId();
		Set<String> fields = new Set<String>();

		fields.addAll(fieldsMap.keySet());

        if(!Test.isRunningTest()){
            this.controller.addFields(new List<String>(fields));
        }
        // Cast all fieldNames to lowercase
        for(String fieldName: fields){
			fields.remove(fieldName);
			fields.add(fieldName.toLowerCase());
		}

        record = (FieloELR__ModuleResponse__c)controller.getRecord();

		buttonList = new List<Map<String,Object>>();

		if(!buttonList.isEmpty()){
            buttonString = JSON.serialize(buttonList);
            buttonString = buttonString.substring(1,buttonString.length()-1);    
        }

        String standardTools = '';
        PageReference exportPage = Page.FieloPLT__XMLExport;
		exportPage.getParameters().put( 'retURL', System.currentPageReference().getUrl() );
		exportPage.getParameters().put( 'moduleResponseId', recordId );
		exportPage.getParameters().put( 'type', 'moduleResponse' );

		initPageSettings( objectName, (SObject) record, buttonString, '', '',record.Id );

		for(FieloPLT__PageSettings__c settings:relatedSettings) {
			if(settings.FieloPLT__TargetObject__c == 'FieloELR__QuestionResponse__c') {
					settings.FieloPLT__Buttons__c = !String.IsBlank(settings.FieloPLT__Buttons__c) ?
																	settings.FieloPLT__Buttons__c :
																	'';	
			}
		}

		if ( fieldList.size() > 0  ) {
			for(String fieldName:fieldList) {
				fields.add(fieldName);
			}
			String query = String.format(
				'SELECT {0} FROM {1} WHERE Id = :recordId',
				new String[]{
					String.join(new List<String>(fields), ','),
					objectName
				}
			);
			
			// SR: CRUD Check
			if ( Schema.sObjectType.ModuleResponse__c.isAccessible() ) {	
				// SR: FLS Check
				for (String f : fields) {
					if (fieldsMap.containsKey(f.trim()) && !fieldsMap.get(f.trim()).getDescribe().isAccessible() ) {
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'ModuleResponse__c', f.trim()}));
					}
				}
				record = Database.query(query);
				setRecord(record);
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'ModuleResponse__c'}));
			}

		}
	}

  	@RemoteAction
	public static sObject retrieve( String objectName, String recordId, String fields ){
		DescribeSObjectResult objectDescribe = Schema.describeSObjects(new String[]{objectName})[0];
		Map<String, sObjectField> fieldsMap = objectDescribe.fields.getMap();
		Set<String> fieldSet = new Set<String>(fields.split(','));
		List<String> fieldList = new List<String>();

		for (String f : fieldSet ) {
			if (fieldsMap.containsKey(f.trim()) && !fieldsMap.get(f.trim()).getDescribe().isAccessible() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{ objectName, f.trim()})); 
			} else {
				fieldList.add(f.trim());
			}
		}

		String query = 'SELECT ' + fields;
		query += ' FROM ' + objectName;
		query += ' WHERE ID = :recordId' ;
		query += ' LIMIT 1';
		List<sObject> result;

		// SR: CRUD Check
		if ( objectDescribe.isAccessible() ) {
		 	result = Database.query(query);
		} else {
			throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{ objectDescribe.getName() })); 
		}
		 
		return result.get(0);
	}


	@RemoteAction
  	public static RemoteActionResult save(ModuleResponse__c record, List<String> nullFields) {
		Savepoint sp;
		RemoteActionResult result = new RemoteActionResult();
		Map<String,Schema.SObjectField> fieldsMap = Schema.sObjectType.ModuleResponse__c.fields.getMap();
		try{
			sp = Database.setSavepoint();
			for ( String f : nullFields ) {
				if( fieldsMap.get(f).getDescribe().isCreateable() && fieldsMap.get(f).getDescribe().isUpdateable()){
         			record.put(f, null );
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{'ModuleResponse__c', f}));
				}
			}

			// SR: FLS Check
			for ( String f : record.getPopulatedFieldsAsMap().keySet() ) {
				if ( f != 'Id' && fieldsMap.containsKey(f) && !fieldsMap.get(f).getDescribe().isUpdateable() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{'ModuleResponse__c',f}));
				}
				if ( f != 'Id' && fieldsMap.containsKey(f) && !fieldsMap.get(f).getDescribe().isCreateable() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_insertable, new List<String>{'ModuleResponse__c',f}));
				}
			}

			if ( !Schema.sObjectType.ModuleResponse__c.isUpdateable() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'ModuleResponse__c'}));
			} else if ( !Schema.sObjectType.ModuleResponse__c.isCreateable() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_insertable, new List<String>{'ModuleResponse__c'}));
			} else {
				upsert record;
			}

			//TODO Crear Label DataSavedSuccessfully
			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.DataSavedSuccessfully) );
			result.redirectURL = '/' + record.Id;
    	}catch(DmlException e){
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
  	public static RemoteActionResult saveQuestionResponse(SObject record, List<String> nullFields) {
		Savepoint sp;
		RemoteActionResult result = new RemoteActionResult();
		Map<String,Schema.SObjectField> fieldsMap = Schema.sObjectType.QuestionResponse__c.fields.getMap();
		try{
			sp = Database.setSavepoint();
			for ( String f :nullFields ) {
				if( fieldsMap.get(f).getDescribe().isCreateable() && fieldsMap.get(f).getDescribe().isUpdateable()){
         			record.put(f, null );
				}
			}

			// SR: FLS Check
			for ( String f : record.getPopulatedFieldsAsMap().keySet() ) {
				if ( f != 'Id' && fieldsMap.containsKey(f) && !fieldsMap.get(f).getDescribe().isUpdateable() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{'QuestionResponse__c',f}));
				}
				if ( f != 'Id' && fieldsMap.containsKey(f) && !fieldsMap.get(f).getDescribe().isCreateable() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_insertable, new List<String>{'QuestionResponse__c',f}));
				}
			}

			// TODO: Change to Create API
			if( !Schema.sObjectType.QuestionResponse__c.isUpdateable() ){
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'QuestionResponse__c'}));
			} else if ( !Schema.sObjectType.QuestionResponse__c.isCreateable() ){
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_insertable, new List<String>{'QuestionResponse__c'}));
			}else{
				upsert (QuestionResponse__c) record;
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