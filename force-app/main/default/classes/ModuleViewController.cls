public with sharing class ModuleViewController extends PageSettingsController {
	public Module__c record {get;set;}
	public String buttonString {get;set;}
	public String toolsString {get;set;}
	public static String secondaryParameters {get;set;}
	public List<Map<String,Object>> buttonList {get;set;}
	private ApexPages.StandardController controller;
	private Set<String> fieldFilter = new Set<String> {'lastreferenceddate', 'lastvieweddate'};

	/**
    * @brief constructor
    */
	public ModuleViewController(ApexPages.StandardController controller) {
		String objectName = 'FieloELR__Module__c';
		this.controller = controller;
		Id recordId = controller.getId();
		Set<String> fields = new Set<String>();

		fields.addAll(Schema.describeSObjects(new String[]{objectName})[0].fields.getMap().keySet());
        // Cast all fieldNames to lowercase
        for(String fieldName: fields){
            fields.remove(fieldName);
            if(!fieldFilter.contains(fieldName)){
                fields.add(fieldName.toLowerCase());
            }  
		}

		if(!Test.isRunningTest()){
            this.controller.addFields(new List<String>(fields));
        }

        record = (FieloELR__Module__c)controller.getRecord();

		buttonList = new List<Map<String,Object>>();

		if( getshowActivate() ){
			buttonList.add(new Map<String,Object>{
                'Label' => 'Activate',
                'Type' => 'Remote',
                'Action' => 'FieloELR.ModuleViewController.activate',
                'Confirm' => true
            });
		}
		if( getShowInactivate() ){
			buttonList.add(new Map<String,Object>{
                'Label' => 'Inactivate',
                'Type' => 'Remote',
                'Action' => 'FieloELR.ModuleViewController.inactivate',
                'Confirm' => true
            });
		}

		if(!buttonList.isEmpty()){
            buttonString = JSON.serialize(buttonList);
            buttonString = buttonString.substring(1,buttonString.length()-1);    
        }

        String standardTools = '';
        PageReference exportPage = Page.FieloPLT__XMLExport;
		exportPage.getParameters().put( 'retURL', System.currentPageReference().getUrl() );
		exportPage.getParameters().put( 'courseId', recordId );
		exportPage.getParameters().put( 'type', 'course' );

		initPageSettings( objectName, (SObject) record, buttonString, '', '',record.Id );

		if (relatedSettings != null) {
			for(FieloPLT__PageSettings__c settings:relatedSettings) {
				if(settings.FieloPLT__TargetObject__c == 'FieloELR__Question__c') {
					settings.FieloPLT__Buttons__c = '{"Label":"Manage","Type":"Modal","Action":"FieloELR__Question__cFormManage"}' +
						(settings.FieloPLT__Buttons__c != '' && settings.FieloPLT__Buttons__c != null ?
							',' + settings.FieloPLT__Buttons__c :
							'');
				}
			}
		}

		if (relatedFormsSettings != null) {
			for(FieloPLT__PageSettings__c settings:relatedFormsSettings) {
				if(settings.FieloPLT__Object__c == 'FieloELR__ModuleDependency__c') {
					settings.FieloPLT__Sections__c = getSectionsWithModuleWhereCondition(
						settings.FieloPLT__Sections__c,
						record.Course__c,
						record.Id
					);
				}
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
			
			// SR: Dynamic FLS Check
			Map<String, Schema.SObjectField> moduleFieldsMap = Schema.SObjectType.Module__c.fields.getMap();
			for (String fieldName : fields) {
				if ( moduleFieldsMap.containsKey(fieldName) && !moduleFieldsMap.get(fieldName).getDescribe().isAccessible() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c',fieldName}));
				}
			}
			
			if ( Schema.sObjectType.FieloELR__Module__c.isAccessible() ) {
				record = Database.query(query);
				setRecord(record);
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c'}));
			}
		}
	}

	public Boolean getShowActivate() {
		return !this.record.FieloELR__IsActive__c;
	}

	public Boolean getShowInActivate() {
		return this.record.FieloELR__IsActive__c;
	}

	public static String getSectionsWithModuleWhereCondition(String sectionsString, String courseId, String moduleId){
	    Section section = (Section) JSON.deserialize( sectionsString, ModuleViewController.Section.class );
		for ( List<FormField> r :section.rows ) {
			for ( FormField f :r ) {
		  		if(f.Name != null) {
		    		if(f.Name == 'FieloELR__Predecessor__c') {
		        		f.WhereCondition = ' FieloELR__Course__c = /' + courseId + '/ AND Id != /' + moduleId + '/';
		    		}
		  		}
			}
		}
        return JSON.serialize(section);
    }

    public FieloPLT__PageSettings__c getPageSettings(String pageSetingsName, String defaultSection) {
		Map<String,Schema.SObjectField> pageSettingsFieldsMap = Schema.SObjectType.FieloPLT__PageSettings__c.fields.getMap();
        Map<String,Schema.SObjectField> FieldsMap = pageSettingsFieldsMap.clone();
        if(FieldsMap.containskey('lastreferenceddate')){
            FieldsMap.remove('lastreferenceddate');
        }
        if(FieldsMap.containskey('lastvieweddate')){
            FieldsMap.remove('lastvieweddate');
        }

        for (String fieldName : FieldsMap.keySet() ) {
            if ( !FieldsMap.get(fieldName).getDescribe().isAccessible() ) {
                throw new FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__PageSettings__c', fieldName}));
            }
        }

        String query = 'SELECT ';
        query += String.join(new List<String>(FieldsMap.keySet()), ',');
        query += ' FROM FieloPLT__PageSettings__c';
        query += ' WHERE Name = :pageSetingsName AND FieloPLT__IsActive__c = true' ;
        query += ' LIMIT 1';
        List<sObject> result;

		if(Schema.sObjectType.FieloPLT__PageSettings__c.isAccessible()){
        	result = Database.query(query);
		} else {
			throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__PageSettings__c'}));
		}
		
		if (result.isEmpty()) {
			return new FieloPLT__PageSettings__c(
				FieloPLT__Sections__c = defaultSection
			);
		} else {
			return (FieloPLT__PageSettings__c) result.get(0);
		}
    }

    public FieloPLT__PageSettings__c manageQuestionPS {get{
    	if (manageQuestionPS== null) {
    		manageQuestionPS = getPageSettings('Module (Question Manage) > Edit',
    			'{\'Name\':\'Module Setup\',' +
    			'\'Rows\':[[{\'Name\':\'FieloELR__PenaltyMode__c\',\'Type\':\'radio\'},{\'Name\':\'FieloELR__AttemptsAllowedPerQuestion__c\',\'Type\':\'picklist\'},'+
    			'{\'Name\':\'FieloELR__QuestionPool__c\',\'Type\':\'input\'}],[{\'Name\':\'FieloELR__ShuffleQuestions__c\',\'Type\':\'checkbox\'},' +
    			'{\'Name\':\'FieloELR__WeightedQuestions__c\',\'Type\':\'checkbox\'}]]}'
    		);
    	}
        return manageQuestionPS;
    }set;}

	@RemoteAction
  	public static RemoteActionResult save( Module__c record, List<String> nullFields) {
		Savepoint sp;
		RemoteActionResult result = new RemoteActionResult();
		Map<String,Schema.SObjectField> fieldsMap = Schema.sObjectType.Module__c.fields.getMap();
		try{
			sp = Database.setSavepoint();
			for ( String f : nullFields ) {
				if( fieldsMap.get(f).getDescribe().isCreateable() && fieldsMap.get(f).getDescribe().isUpdateable()){
         			record.put(f, null );
				}
			}

			// SR: FLS Check
			for ( String f : record.getPopulatedFieldsAsMap().keySet() ) {
				if ( f != 'Id' && fieldsMap.containsKey(f) && !fieldsMap.get(f).getDescribe().isUpdateable() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{'Module__c',f}));
				}
				if ( f != 'Id' && fieldsMap.containsKey(f) && !fieldsMap.get(f).getDescribe().isCreateable() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_insertable, new List<String>{'Module__c',f}));
				}
			}

			// SR: CRUD Check
		 	if(Schema.sObjectType.Module__c.isUpdateable() && Schema.sObjectType.Module__c.isCreateable()){
				upsert record;
          	} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'Module__c'}));
          	}
        	
			//TODO Crear Label DataSavedSuccessfully
			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.DataSavedSuccessfully) );
			result.redirectURL = '/' + record.Id;
    	}catch(DmlException e){
			result.addMessage(new RemoteActionResult.RemoteActionMessage(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
    	}catch(Exception e){
        	result.addMessage(new RemoteActionResult.RemoteActionMessage(ApexPages.Severity.ERROR, e.getMessage()));
    	}
    	return result;
  	}

  	@RemoteAction
  	public static RemoteActionResult saveQuestion(SObject record, List<String> nullFields) {
		Savepoint sp;
		RemoteActionResult result = new RemoteActionResult();
		Map<String,Schema.SObjectField> fieldsMap = Schema.sObjectType.Question__c.fields.getMap();
		try{
			sp = Database.setSavepoint();
			for ( String f :nullFields ) {
				if( Schema.sObjectType.Question__c.fields.getMap().get(f).getDescribe().isCreateable() && Schema.sObjectType.Question__c.fields.getMap().get(f).getDescribe().isUpdateable()){
         			record.put(f, null );
				}
			}

			// SR: FLS Check
			for ( String f : record.getPopulatedFieldsAsMap().keySet() ) {
				if ( fieldsMap.containsKey(f) && !fieldsMap.get(f).getDescribe().isUpdateable() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{'Question__c',f}));
				}
				if ( fieldsMap.containsKey(f) && !fieldsMap.get(f).getDescribe().isCreateable() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_insertable, new List<String>{'Question__c',f}));
				}
			}

			if(Schema.sObjectType.Question__c.isUpdateable() && Schema.sObjectType.Question__c.isCreateable()){
				upsert (Question__c) record;
          	}else{
            	throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'Question__c'}));
          	}

			//TODO Crear Label DataSavedSuccessfully
			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.DataSavedSuccessfully) );
			result.redirectURL = '/' + record.Id;
    	}catch(DmlException e){
			result.addMessage(new RemoteActionResult.RemoteActionMessage(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
    	}catch(Exception e){
        	result.addMessage(new RemoteActionResult.RemoteActionMessage(ApexPages.Severity.ERROR, e.getMessage()));
    	}
    	return result;
  	}

  	@RemoteAction
  	public static RemoteActionResult saveModuleDependency(SObject record, List<String> nullFields) {
		Savepoint sp;
		RemoteActionResult result = new RemoteActionResult();
		Map<String,Schema.SObjectField> fieldsMap = Schema.sObjectType.ModuleDependency__c.fields.getMap();
		try{
			sp = Database.setSavepoint();
			for ( String f :nullFields ) {
				if( Schema.sObjectType.ModuleDependency__c.fields.getMap().get(f).getDescribe().isCreateable() && Schema.sObjectType.ModuleDependency__c.fields.getMap().get(f).getDescribe().isUpdateable()){
         			record.put(f, null );
				}
			}

			if (Schema.sObjectType.ModuleDependency__c.isUpdateable() && Schema.sObjectType.ModuleDependency__c.isCreateable()){
				upsert (ModuleDependency__c) record;            	
          	} else {
            	throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'ModuleDependency__c'}));
          	}

			// SR: FLS Check
			for ( String f : record.getPopulatedFieldsAsMap().keySet() ) {
				if ( f != 'Id' && fieldsMap.containsKey(f) && !fieldsMap.get(f).getDescribe().isUpdateable() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{'ModuleDependency__c',f}));
				}
				if ( f != 'Id' && fieldsMap.containsKey(f) && !fieldsMap.get(f).getDescribe().isCreateable() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_insertable, new List<String>{'ModuleDependency__c',f}));
				}
			}
     
			//TODO Crear Label DataSavedSuccessfully
			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.DataSavedSuccessfully) );
			result.redirectURL = '/' + ((ModuleDependency__c)record).Module__c;
    	}catch(DmlException e){
    		result.addMessage(new RemoteActionResult.RemoteActionMessage(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
    	}catch(Exception e){
        	result.addMessage(new RemoteActionResult.RemoteActionMessage(ApexPages.Severity.ERROR, e.getMessage()));
    	}
    	return result;
  	}

  	@RemoteAction
	public static sObject retrieve( String objectName, String recordId, String fields ){
		Map<String, Schema.SObjectField> fieldsMap = Schema.describeSObjects(new String[]{objectName})[0].fields.getMap();

		for (String fieldName : fields.split(',') ) {
			if ( fieldsMap.containsKey(fieldName) && !fieldsMap.get(fieldName).getDescribe().isAccessible() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{objectName, fieldName}));
			}
		}

		String query = 'SELECT ' + fields;
		query += ' FROM ' + objectName;
		query += ' WHERE ID = :recordId' ;
		query += ' LIMIT 1';
		List<sObject> result;

		if( Schema.describeSObjects(new List<String>{objectName})[0].isAccessible() ){
			result = Database.query(query);
		} else {
			throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{objectName}));
		}
		return result.get(0);
	}

	@RemoteAction
  	public static RemoteActionResult activate( Id recordId ){
		RemoteActionResult result = new RemoteActionResult();
		try{
			Module__c record = new Module__c ( Id = recordId);
			if( Schema.sObjectType.Module__c.fields.IsActive__c.isCreateable() && Schema.sObjectType.Module__c.fields.IsActive__c.isUpdateable() ){
				record.IsActive__c = true;
			}

			if( Schema.sObjectType.Module__c.isUpdateable() ){
				update record;
          	}else{
            	throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
          	}
			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.ModuleActivated) );
			result.redirectURL = '/' + recordId;
		} catch(DmlException e){
			result.addMessage(new RemoteActionResult.RemoteActionMessage(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
		} catch(Exception e) {
			result.addMessage(new RemoteActionResult.RemoteActionMessage(ApexPages.Severity.ERROR, e.getMessage()));
		}
		return result;
	}

	@RemoteAction
  	public static RemoteActionResult inactivate( Id recordId ){
		RemoteActionResult result = new RemoteActionResult();
		try{
			Module__c record = new Module__c ( Id = recordId);
			if( Schema.sObjectType.Module__c.fields.IsActive__c.isCreateable() && Schema.sObjectType.Module__c.fields.IsActive__c.isUpdateable() ){
				record.IsActive__c = false;
			}

			if( Schema.sObjectType.Module__c.isUpdateable() ){
				update record;
          	}else{
            	throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
          	}

			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.ModuleInactivated) );

			result.redirectURL = '/' + recordId;

		} catch(DmlException e){
			result.addMessage(new RemoteActionResult.RemoteActionMessage(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
		} catch(Exception e) {
			result.addMessage(new RemoteActionResult.RemoteActionMessage(ApexPages.Severity.ERROR, e.getMessage()));
		}
		return result;
	}

	@RemoteAction
  	public static List<SObject> getRecords( String objectName, String fields, Integer offset, String orderBy, String dataFilters, Integer recordsPerPage, String whereClause ) {
		Map<String, Schema.SObjectField> fieldsMap = Schema.describeSObjects(new String[]{objectName})[0].fields.getMap();

		for (String fieldName : fields.split(',') ) {
			if ( fieldsMap.containsKey(fieldName) && !fieldsMap.get(fieldName).getDescribe().isAccessible() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{objectName, fieldName}));
			}
		}

		String query = 'SELECT Id, ' + fields;
		query += ' FROM ' + objectName;
		query += getWhereCondition( dataFilters ); 
		// ORDER BY       
		if ( orderBy == null ) {
			orderBy = 'LastModifiedDate DESC';
		}
		query += ' ORDER BY '+ orderBy; //DESC
		// LIMIT & OFFSET
		if ( recordsPerPage == null ) {
			recordsPerPage = 10;
		}
		query += ' LIMIT '+ String.valueOf(recordsPerPage);
		if ( offset != null ){
		query += ' OFFSET '+ String.valueOf(offset);
		}
		List<SObject> listObjects;

		if( Schema.describeSObjects(new List<String>{objectName})[0].isAccessible() ){
			listObjects = Database.query(query);
		} else {
			throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{objectName}));
		}
				
		return listObjects;
	}

	private static String getWhereCondition( String filterJson ) {
		String whereCondition = '';
		if (filterJson != null ) { 
			try {
				Map<String,Object> filter = (Map<String, Object>) JSON.deserializeUntyped( filterJson);
		  		for ( String k :filter.keySet() ) {
			    	String value = (String) filter.get(k);
		    		if ( value.startsWith('!') ) {
			      		whereCondition += ' AND ' + k + ' <> \'' +  String.escapeSingleQuotes(value.substring(1)) + '\'';            
		    		} else {
			      		whereCondition += ' AND ' + k + ' = \'' +  String.escapeSingleQuotes(value) + '\'';
		    		}
		  		}
				if ( whereCondition != '') {          
				    whereCondition = ' WHERE ' + whereCondition.substring(4);
		  		}
			} catch( JSONException e ) {
				system.debug(LoggingLevel.ERROR, 'INVALID JSON ' + filterJson );        
			}
		}
		return whereCondition;
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