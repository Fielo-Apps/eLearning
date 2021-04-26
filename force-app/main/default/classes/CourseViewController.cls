global with sharing class CourseViewController extends PageSettingsController {
	public Course__c record {get;set;}
	public String buttonString {get;set;}
	// public String toolsString {get;set;}
	public static String secondaryParameters {get;set;}
	public List<Map<String,Object>> buttonList {get;set;}
	private ApexPages.StandardController controller;
	public FieloPLT__PageSettings__c cloneSettings {get; set;}
	private Set<String> fieldFilter = new Set<String> {'lastreferenceddate', 'lastvieweddate'};

	/**
    * @brief constructor
    */
	public CourseViewController(ApexPages.StandardController controller) {
		String objectName = 'FieloELR__Course__c';
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

        record = (FieloELR__Course__c)controller.getRecord();

		buttonList = new List<Map<String,Object>>();

		if( getshowActivate() ){
			buttonList.add(new Map<String,Object>{
                'Label' => 'Activate',
                'Type' => 'Remote',
                'Action' => 'FieloELR.CourseViewController.activate',
                'Confirm' => true
            });
		}
		if( getShowInactivate() ){
			buttonList.add(new Map<String,Object>{
                'Label' => 'Inactivate',
                'Type' => 'Remote',
                'Action' => 'FieloELR.CourseViewController.inactivate',
                'Confirm' => true
            });
		}

		if(!buttonList.isEmpty()){
            buttonString = JSON.serialize(buttonList);
            buttonString = buttonString.substring(1,buttonString.length()-1);
        }

        String standardTools = '';
        PageReference exportPage = Page.JSONExport;
		exportPage.getParameters().put( 'retURL', System.currentPageReference().getUrl() );
		exportPage.getParameters().put( 'courseId', recordId );
		exportPage.getParameters().put( 'type', 'courses' );


		buttonList = new List<Map<String,Object>>();
		buttonList.add(new Map<String,Object>{
            'Label' => 'Export',
            'Type' => 'Link', //Remote
            'Action' => exportPage.getUrl()
        });
        buttonList.add(new Map<String,Object>{
            'Label' => 'Save as Model',
            'Type' => 'Modal',
            'Action' => 'formModel',
            'Parameters' => '{ "cloneId": "' + recordId + '"}'
        });

		standardTools = JSON.serialize(buttonList);
        standardTools = standardTools.substring(1,standardTools.length()-1);

		initPageSettings(objectName, (SObject) record, buttonString, standardTools, '', record.Id);

		editSettings.FieloPLT__Sections__c = getSectionsWithSegmentWhereCondition(editSettings.FieloPLT__Sections__c, record.Program__c);
		try{
			// SR: CRUD Check
			if ( Schema.sObjectType.FieloPLT__PageSettings__c.isAccessible() ) {
				// SR: FLS Check
				if ( Schema.sObjectType.FieloPLT__PageSettings__c.fields.Name.isAccessible() && Schema.sObjectType.FieloPLT__PageSettings__c.fields.FieloPLT__Sections__c.isAccessible() && Schema.sObjectType.FieloPLT__PageSettings__c.fields.FieloPLT__Type__c.isAccessible() && Schema.sObjectType.FieloPLT__PageSettings__c.fields.FieloPLT__Object__c.isAccessible()) {
					cloneSettings = [SELECT Id, Name, FieloPLT__Sections__c FROM FieloPLT__PageSettings__c WHERE FieloPLT__Type__c = 'Clone' AND FieloPLT__Object__c = 'FieloELR__Course__c' LIMIT 1];
					cloneSettings.FieloPLT__Sections__c = '[' + cloneSettings.FieloPLT__Sections__c + ']';
					cloneSettings.FieloPLT__Sections__c = getSectionsWithSegmentWhereCondition(cloneSettings.FieloPLT__Sections__c, record.Program__c);
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__PageSettings__c', 'Name, FieloPLT__Sections__c, FieloPLT__Type__c, FieloPLT__Object__c'}));
				}
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__PageSettings__c'}));
			}
		}catch(Exception e){
			cloneSettings = editSettings;
		}

		if (relatedSettings != null) {
			for(FieloPLT__PageSettings__c settings:relatedSettings) {
				if(settings.FieloPLT__TargetObject__c == 'FieloELR__Module__c') {
					settings.FieloPLT__Buttons__c = '{"Label":"Reorder","Type":"Modal","Action":"FieloELR__Module__cFormReorder"}' +
					(settings.FieloPLT__Buttons__c != '' && settings.FieloPLT__Buttons__c != null ?
						',' + settings.FieloPLT__Buttons__c :
						'');
				}
			}
		}

		if (relatedFormsSettings != null) {
			for(FieloPLT__PageSettings__c settings:relatedFormsSettings) {
				if(settings.FieloPLT__Object__c == 'FieloELR__CourseDependency__c') {
					settings.FieloPLT__Sections__c = getSectionsWithCourseWhereCondition(
						settings.FieloPLT__Sections__c,
						record.Program__c,
						record.Id
					);
				}
			}
		}

		if ( fieldList.size() > 0  ) {
			for(String fieldName:fieldList) {
				fields.add(fieldName);
			}
			if (fields.contains('fieloelr__segment__c') || fields.contains('fieloelr__segment__r.name')) {
				secondaryParameters = 'FieloELR__Segment__c';
			}


			// SR: Dynamic FLS Check
			Map<String,Schema.SObjectField> courseFieldsMap = Schema.SObjectType.Course__c.fields.getMap();
			for (String fieldName : fields) {
				if ( courseFieldsMap.containsKey(fieldName) && !courseFieldsMap.get(fieldName).getDescribe().isAccessible() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c',fieldName}));
				}
			}

			String query = String.format(
				'SELECT {0} FROM {1} WHERE Id = :recordId',
				new String[]{
					String.join(new List<String>(fields), ','),
					objectName
				}
			);

			if ( Schema.sObjectType.Course__c.isAccessible() ) {
				record = Database.query(query);
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c'}));
			}
			setRecord(record);
		}
	}

	public Boolean getShowActivate() {
		return this.record.FieloELR__Status__c == 'Draft' ||
			this.record.FieloELR__Status__c == 'Inactive';
	}

	public Boolean getShowInActivate() {
		return this.record.FieloELR__Status__c == 'Active' ||
			this.record.FieloELR__Status__c == 'Scheduled' ||
			this.record.FieloELR__Status__c == 'Completed';
	}

	@RemoteAction
	global static Course__c retrieve( String objectName, String recordId, String fields ){
		Map<String,Schema.SObjectField> objectFieldsMap = Schema.sObjectType.Course__c.fields.getMap();

		String query = 'SELECT FieloELR__Segment__r.FieloPLT__RelatedSegments__c,' + String.escapeSingleQuotes(fields);
		query += ' FROM ' + objectName;
		query += ' WHERE ID = :recordId' ;
		query += ' LIMIT 1';

		// SR: Dynamic FLS Check
		for (String fieldName : fields.split(',')) {
			if ( fieldName.trim() != 'Id' && objectFieldsMap.containsKey(fieldName.trim()) && !objectFieldsMap.get(fieldName.trim()).getDescribe().isAccessible() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c',fieldName.trim()}));
			}
		}

		List<Course__c> result;

		// SR: CRUD Check
		if ( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.FieloPLT__Segment__c.isAccessible()) {
			if (Schema.sObjectType.FieloPLT__Segment__c.fields.FieloPLT__RelatedSegments__c.isAccessible()) {
				result = Database.query(query);
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__Segment__c', 'FieloPLT__RelatedSegments__c'}));
			}
		} else {
			throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c, FieloPLT__Segment__c'}));
		}

		if(result[0].Segment__r.FieloPLT__RelatedSegments__c != null){
			system.debug(result[0].Segment__r.FieloPLT__RelatedSegments__c);
			List<String> segIds15 = result[0].Segment__r.FieloPLT__RelatedSegments__c.split(';');
			List<Id> segIds18 = segIds15;
			result[0].Segment__r.FieloPLT__RelatedSegments__c = '';
			for(Id id18: segIds18){
				result[0].Segment__r.FieloPLT__RelatedSegments__c += id18 + ';';
			}
			result[0].Segment__r.FieloPLT__RelatedSegments__c = result[0].Segment__r.FieloPLT__RelatedSegments__c.removeEnd(';');
		}

		return result.get(0);
	}

	public static RemoteActionResult save( Course__c record, List<String> nullFields) {
		return save(record, nullFields, new List<String>());
	}

	@RemoteAction
  	global static RemoteActionResult save( Course__c record, List<String> nullFields, List<String> segments) {
		Savepoint sp;
		RemoteActionResult result = new RemoteActionResult();
		try{
			sp = Database.setSavepoint();
			for ( String f :nullFields ) {
         		record.put(f, null );
			}

			// SR: FLS Check
			if ( Schema.sObjectType.Course__c.fields.Segment__c.isUpdateable() && Schema.sObjectType.Course__c.fields.Segment__c.isCreateable() ) {
				if ( segments.size() == 1 ) {
					record.segment__c = segments.get(0);
				} else if ( segments.size() > 1 ) {
					record.segment__c = SegmentService.getMetaSegmentId( segments, record.Program__c ) ;
				} else {
					record.segment__c = null;
				}
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{'Course__c', 'Segment__c'}));
			}

			Map<String,Schema.SObjectField> courseFieldsMap = Schema.SObjectType.Course__c.fields.getMap();
			Set<String> courseFieldset = new Set<String>(record.getPopulatedFieldsAsMap().keySet());
			if (nullFields != null && !nullFields.isEmpty()) {
			    courseFieldset.addAll(nullFields);
            }

			// SR: Dynamic FLS Check
			for ( String fieldName : courseFieldset ) {
				if ( fieldName != 'Id' && (!courseFieldsMap.get(fieldName).getDescribe().isUpdateable() || !courseFieldsMap.get(fieldName).getDescribe().isCreateable()) ){
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c', fieldName}));
				}
			}

			if (Schema.sObjectType.Course__c.isUpdateable() && Schema.sObjectType.Course__c.isCreateable()){
				upsert record;
			}else{
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'Course__c'}));
			}

			//TODO Crear Label DataSavedSuccessfully
			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.DataSavedSuccessfully) );
			result.redirectURL = '/' + record.Id;
    	} catch(DmlException e){
    		if(sp != null){
	            Database.rollback(sp);
        	}
			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.ERROR,e.getDmlMessage(0)));
    	} catch(Exception e){
        	if(sp != null){
	            Database.rollback(sp);
        	}
        	result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
    	}
    	return result;
  	}

  	@RemoteAction
  	global static RemoteActionResult clone( Course__c record, List<String> nullFields, List<String> segments) {
		Savepoint sp;
		RemoteActionResult result = new RemoteActionResult();
		Map<String,Schema.SObjectField> courseFieldsMap = Schema.SObjectType.Course__c.fields.getMap();
		try{
			sp = Database.setSavepoint();
			for ( String f :nullFields ) {
         		record.put(f, null );
			}
			if ( Schema.sObjectType.Course__c.fields.Segment__c.isUpdateable() && Schema.sObjectType.Course__c.fields.Segment__c.isCreateable() ) {
				if ( segments.size() == 1 ) {
					record.segment__c = segments.get(0);
				} else if ( segments.size() > 1 ) {
					record.segment__c = SegmentService.getMetaSegmentId( segments, record.Program__c ) ;
				} else {
					record.segment__c = null;
				}
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{'Course__c', 'Segment__c'}));
			}

        	String courseJSON = ExportService.exportCourses(new List<Id>{record.Id});
        	SObjectUnitOfWork uow = ExportService.importData(courseJSON, new List<ExportService.MultiSegmentRelation>());
        	Map<String,Schema.SObjectField> fieldMap = record.getSObjectType().getDescribe().fields.getMap();

        	record.put('Id',null);

        	if ( uow.m_newListByType.containsKey('FieloELR__Course__c') ) {
                List<Course__c> courses = (List<Course__c>) uow.m_newListByType.get('FieloELR__Course__c');
                if ( courses.size() > 0 ) {
                    for(String fieldName: record.getPopulatedFieldsAsMap().keySet()) {
						// SR: FLS Check
						if ( fieldName != 'Id' && courseFieldsMap.containsKey(fieldName) && (!courseFieldsMap.get(fieldName).getDescribe().isUpdateable() || !courseFieldsMap.get(fieldName).getDescribe().isCreateable()) ){
							throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c', fieldName.trim()}));
						}
                    	if (fieldName != 'Id') {
                    		if (String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) == 'DOUBLE') {
                    			if (record.get(fieldName) != null) {
	                    			courses.get(0).put(fieldName,
	                    				record.get(fieldName) instanceof String ?
	                    					Decimal.valueOf((String)record.get(fieldName)):
	                    					Decimal.valueOf((Double)record.get(fieldName)));
                    			} else {
                    				courses.get(0).put(fieldName, null);
                    			}
                    		} else {
                    			courses.get(0).put(fieldName, record.get(fieldName));
                    		}
                    	}
					}
					courses.get(0).Status__c = 'Draft';

					if (Schema.sObjectType.Course__c.isUpdateable()) {
                    	ExportService.saveData(uow, null);
					} else {
						throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_insertable, new List<String>{'Course__c'}));
					}
                } else {
                    throw new FieloPLT.FieloException (label.FieloPLT.ModelEmpty);
                }
            } else {
                throw new FieloPLT.FieloException (label.FieloPLT.ModelEmpty);
            }

			//TODO Crear Label DataSavedSuccessfully
			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.DataSavedSuccessfully) );
			result.redirectURL = '/' + uow.m_newListByType.get('FieloELR__Course__c').get(0).Id;
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
  	global static RemoteActionResult saveModule( SObject record, List<String> nullFields) {
		Savepoint sp;
		RemoteActionResult result = new RemoteActionResult();
		try{
			sp = Database.setSavepoint();
			for ( String f :nullFields ) {
         		record.put(f, null );
			}

			Map<String,Schema.SObjectField> moduleFieldsMap = Schema.SObjectType.Module__c.fields.getMap();
			Set<String> moduleFieldSet = new Set<String>(record.getPopulatedFieldsAsMap().keySet());
			if (nullFields != null && !nullFields.isEmpty()) {
			    moduleFieldSet.addAll(nullFields);
            }

			// SR: Dynamic FLS Check
			for ( String fieldName : moduleFieldSet ) {
				if ( fieldName != 'Id' && (!moduleFieldsMap.get(fieldName).getDescribe().isUpdateable() || !moduleFieldsMap.get(fieldName).getDescribe().isCreateable()) ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', fieldName}));
				}
			}

			// TODO: Change to Create API
			if(Schema.sObjectType.Module__c.isUpdateable() && Schema.sObjectType.Module__c.isCreateable()){
				upsert (Module__c) record;
            }else{
               	throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'Module__c'}));
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

  	@RemoteAction
  	global static RemoteActionResult saveCourseDependency( SObject record, List<String> nullFields) {
		Savepoint sp;
		RemoteActionResult result = new RemoteActionResult();
		try{
			sp = Database.setSavepoint();
			for ( String f :nullFields ) {
         		record.put(f, null );
			}

			Map<String,Schema.SObjectField> courseDependencyFieldsMap = Schema.SObjectType.CourseDependency__c.fields.getMap();
			Set<String> courseDependencyFieldSet = new Set<String>(record.getPopulatedFieldsAsMap().keySet());
			if (nullFields != null && !nullFields.isEmpty()) {
			    courseDependencyFieldSet.addAll(nullFields);
            }

			// SR: Dynamic FLS Check
			for ( String fieldName : courseDependencyFieldSet ) {
				if ( fieldName != 'Id' && (!courseDependencyFieldsMap.get(fieldName).getDescribe().isUpdateable() || !courseDependencyFieldsMap.get(fieldName).getDescribe().isCreateable()) ){
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'CourseDependency__c', fieldName}));
				}
			}

			if (Schema.sObjectType.CourseDependency__c.isUpdateable() && Schema.sObjectType.CourseDependency__c.isCreateable()){
				upsert (CourseDependency__c) record;
			}else{
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'CourseDependency__c'}));
			}

			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.DataSavedSuccessfully) );
			result.redirectURL = '/' + ((CourseDependency__c)record).Course__c;
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

  	@RemoteAction
    global static List<SObject> getSegments( String programId ) {
        List<SObject> records;
        if ( Schema.sObjectType.FieloPLT__Segment__c.isAccessible() ) {
            if ( Schema.sObjectType.FieloPLT__Segment__c.fields.Name.isAccessible() ) {
                records = new SegmentsSelector(new Set<String>{'Id','Name'}).selectByProgramAndWithoutProgramWithCriteria(programId, new Set<String>{'Id','Name'});
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__Segment__c', 'Name'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__Segment__c'}));
        }
        return records;
    }

    public static String getSectionsWithSegmentWhereCondition(String sectionsString, String programId){
        List<FormController.Section> sections = (List<FormController.Section>) JSON.deserialize( sectionsString, List<FormController.Section>.class );
        for ( FormController.Section s :sections ) {
          for ( List<FormController.FormField> r :s.rows ) {
            for ( FormController.FormField f :r ) {
              if(f.Name != null) {
                if(f.Name == 'FieloELR__Segment__c') {
                    f.WhereCondition = ' FieloPLT__Program__c IN ( //, /' + programId + '/ ) AND RecordType.Name <> /Metasegment/ ';
                    secondaryParameters = 'FieloELR__Segment__c';
                }
              }
            }
          }
        }
        return JSON.serialize(sections);
    }

    public static String getSectionsWithCourseWhereCondition(String sectionsString, String programId, String courseId){
	    FormController.Section section = (FormController.Section) JSON.deserialize( sectionsString, FormController.Section.class );
		for ( List<FormController.FormField> r :section.rows ) {
			for ( FormController.FormField f :r ) {
		  		if(f.Name != null) {
		    		if(f.Name == 'FieloELR__Predecessor__c') {
		        		f.WhereCondition = ' FieloELR__Program__c = /' + programId + '/ AND Id != /' + courseId + '/';
		    		}
		  		}
			}
		}
        return JSON.serialize(section);
    }

    @RemoteAction
  	global static RemoteActionResult activate( Id recordId ){
		RemoteActionResult result = new RemoteActionResult();
		try{
			CourseService.activateCourses(new Set<Id>{recordId});

			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.CourseActivated) );

			result.redirectURL = '/' + recordId;

		} catch(DmlException e){
			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.ERROR,e.getDmlMessage(0)));
		} catch(Exception e) {
			result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
		}
		return result;
	}

	@RemoteAction
  	global static RemoteActionResult inactivate( Id recordId ){
		RemoteActionResult result = new RemoteActionResult();
		try{
			CourseService.inactivateCourses(new Set<Id>{recordId});

			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.CourseInactivated) );

			result.redirectURL = '/' + recordId;

		} catch(DmlException e){
			result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.ERROR,e.getDmlMessage(0)));
		} catch(Exception e) {
			result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
		}
		return result;
	}
}