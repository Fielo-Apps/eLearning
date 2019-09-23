public with sharing class ModuleResponseDetailController {
	
	@AuraEnabled
	public static string getModuleResponse(String moduleResponseId, String fieldsModuleResponse, String fieldsQuestion, String fieldsAnswerOption) {
		try{
			Set<String> fieldSetModuleResponse = new Set<String>();
			Set<String> fieldSetQuestion = new Set<String>();
			Set<String> fieldSetAnswerOption = new Set<String>();
			Map<String,Schema.SObjectField> moduleResponseFieldsMap = Schema.SObjectType.ModuleResponse__c.fields.getMap();
			Map<String,Schema.SObjectField> questionFieldsMap = Schema.SObjectType.Question__c.fields.getMap();
			Map<String,Schema.SObjectField> answerOptionFieldsMap = Schema.SObjectType.AnswerOption__c.fields.getMap();


			if ( !Schema.sObjectType.Module__c.isAccessible() )
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c'}));

			if ( !Schema.sObjectType.ModuleResponse__c.isAccessible() )
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'ModuleResponse__c'}));

			if ( !Schema.sObjectType.Course__c.isAccessible() )
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c'}));

			if ( !Schema.sObjectType.CourseStatus__c.isAccessible() )
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c'}));

			fieldSetModuleResponse.addAll(fieldsModuleResponse.split(','));
			fieldSetQuestion.addAll(fieldsQuestion.split(','));
			fieldSetAnswerOption.addAll(fieldsAnswerOption.split(','));

			// SR: FLS Check
			for (String fieldName : fieldSetModuleResponse) {
				if ( moduleResponseFieldsMap.containsKey(fieldName.trim()) && !moduleResponseFieldsMap.get(fieldName.trim()).getDescribe().isAccessible() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'ModuleResponse__c', fieldName}));
				}
			}

			// SR: FLS Check
			for (String fieldName : fieldSetQuestion) {
				if ( questionFieldsMap.containsKey(fieldName.trim()) && !questionFieldsMap.get(fieldName.trim()).getDescribe().isAccessible() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Question__c', fieldName}));
				}
			}

			// SR: FLS Check
			for (String fieldName : fieldSetAnswerOption) {
				if ( answerOptionFieldsMap.containsKey(fieldName.trim()) && !answerOptionFieldsMap.get(fieldName.trim()).getDescribe().isAccessible() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Question__c', fieldName}));
				}
			}

            return JSON.serialize(FieloELR.ModuleService.getModuleResponse(
				moduleResponseId,
				fieldSetModuleResponse,
				fieldSetQuestion,
				fieldSetAnswerOption
			));
		} catch(DMLException e) {
           	throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
	}

	@AuraEnabled
	public static String getFieldData(String sObjectName, String fields) {
		try{
			return AuraService.getFieldData(sObjectName, fields);
		} catch(DMLException e) {
           	throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
	}

	@AuraEnabled
	public static String getModule(FieloPLT__Member__c member, String moduleId, String moduleFields, String moduleResponseFields) {
		try{
			Map<String,Schema.SObjectField> moduleResponseFieldsMap = Schema.SObjectType.ModuleResponse__c.fields.getMap();
			Map<String,Schema.SObjectField> moduleFieldsMap = Schema.SObjectType.Module__c.fields.getMap();
			String memberId = member.Id;

			Set<String> moduleFieldSet = new Set<String>();
			if (moduleFields != '' && moduleFields != null) {
				moduleFieldSet.addAll(moduleFields.split(','));
			}

			// SR: FLS Check
			for (String fieldName : moduleFieldSet) {
				if ( moduleFieldsMap.containsKey(fieldName) && !moduleFieldsMap.get(fieldName).getDescribe().isAccessible() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', fieldName}));
				}
			}

			// SR: FLS Check
			if ( Schema.sObjectType.Module__c.fields.KeyDependencies__c.isAccessible() ) {
				moduleFieldSet.add('FieloELR__KeyDependencies__c');
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', 'KeyDependencies__c'}));
			}

			// SR: FLS Check
			if ( Schema.sObjectType.Module__c.fields.Course__c.isAccessible() ) {
				moduleFieldSet.add('FieloELR__Course__c');
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', 'Course__c'}));
			}

			String modulesQuery = 'SELECT ' +
				String.join(new List<String>(moduleFieldSet), ',') +
				' FROM FieloELR__Module__c WHERE Id = :moduleId';

			List<Module__c> modules;
			if ( Schema.sObjectType.Module__c.isAccessible() ) {
				modules = (List<Module__c>) Database.query(modulesQuery);
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c'}));
			}
			
			Set<String> moduleResponseFieldSet = new Set<String>();
			if (moduleResponseFields != '' && moduleResponseFields != null) {
				moduleResponseFieldSet.addAll(moduleResponseFields.split(','));
			}

			moduleResponseFieldSet.add('FieloELR__Member__c');

			String modulesResponseQuery = 'SELECT ' +
				String.join(new List<String>(moduleResponseFieldSet), ',') +
				' FROM FieloELR__ModuleResponse__c WHERE FieloELR__Module__c = :moduleId AND FieloELR__Member__c = :memberId AND FieloELR__IsSubmitted__c = true ORDER BY CreatedDate DESC';
			
			List<ModuleResponse__c> moduleResponses;

			// SR: FLS Check
			for (String fieldName : moduleResponseFieldSet) {
				if ( moduleResponseFieldsMap.containsKey(fieldName) && !moduleResponseFieldsMap.get(fieldName).getDescribe().isAccessible() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'ModuleResponse__c', fieldName}));
				}
			}
			
			// SE: CRUD Check
			if ( Schema.sObjectType.ModuleResponse__c.isAccessible() ){
				moduleResponses = (List<ModuleResponse__c>) Database.query(modulesResponseQuery);
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'ModuleResponse__c'}));
			}

			String moduleDependencyQuery = 'SELECT Id, ' +
				'FieloELR__Predecessor__r.Name ' +
				' FROM FieloELR__ModuleDependency__c ' +
				' WHERE FieloELR__Module__c = :moduleId AND FieloELR__Predecessor__r.FieloELR__IsActive__c = true';

			if ( !Schema.sObjectType.ModuleDependency__c.fields.Predecessor__c.isAccessible() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'ModuleDependency__c', 'Predecessor__c'}));
			}

			if ( !Schema.sObjectType.Module__c.fields.IsActive__c.isAccessible() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', 'IsActive__c'}));
			}

			List<ModuleDependency__c> dependencies;
			if ( Schema.sObjectType.ModuleDependency__c.isAccessible() ){
				dependencies = (List<ModuleDependency__c>) Database.query(moduleDependencyQuery);
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'ModuleDependency__c'}));
			}

			CourseService.ModuleWrapper mw = new CourseService.ModuleWrapper(modules[0], moduleResponses, dependencies);

			return JSON.serialize(mw);
		} catch(DMLException e) {
           	throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
	}

	@AuraEnabled
	public static String getCourseModules(FieloPLT__Member__c member, String courseId) {
		try{
			String courseQuery = 'SELECT Id, Name, (SELECT Id, Name, FieloELR__Order__c FROM FieloELR__Modules__r ORDER BY FieloELR__Order__c) FROM FieloELR__Course__c WHERE Id = :courseId';

			// SR: FLS Check
			if ( !Schema.sObjectType.Module__c.fields.Order__c.isAccessible() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', 'Order__c'}));
			}

			List<FieloELR__Course__c> courses;
			if ( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.Module__c.isAccessible()){
				courses = (List<FieloELR__Course__c>) Database.query(courseQuery);
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c'}));
			}

			String key = courseId + member.Id;

			String courseStatusQuery = 'SELECT Id, Name, (SELECT Id, Name, FieloELR__Module__c, FieloELR__NumberofApprove__c FROM FieloELR__ModuleResponses__r ORDER BY FieloELR__Module__r.FieloELR__Order__c, FieloELR__NumberOfAttempt__c ) FROM FieloELR__CourseStatus__c WHERE FieloELR__ExternalKey__c = :key';

			List<FieloELR__CourseStatus__c> courseStatus = (List<FieloELR__CourseStatus__c>) Database.query(courseStatusQuery);
			if ( Schema.sObjectType.CourseStatus__c.isAccessible() ){
				courseStatus = (List<FieloELR__CourseStatus__c>) Database.query(courseStatusQuery);
			}

			List<CourseService.CourseWrapper> courseWrappers = CourseService.getCoursesMap(
											new Set<String>{'Id','FieloELR__SubscriptionMode__c','FieloELR__Status__c'},
											new Set<String>{'Id','Name'},
											new Set<String>{'Id','Name'},
											null,
											new Set<Id>{courseId},
											member.FieloPLT__Program__c,
                                            member.Id,
											false,
											false,
											null, 
											null, 
											'LastModifiedDate DESC' ,
											'');

			String coursesPoints = CourseService.getCoursePoints(new Set<Id>{courseId}, member.Id);

			return JSON.serialize(new Map<String,Object>{
				'courses' => (Object) courses,
				'wrappers' => (Object) courseWrappers,
				'courseStatus' => (Object) courseStatus,
				'coursePoints' => coursesPoints != null ? JSON.deserializeUntyped(coursesPoints) : ''
			});
		} catch(DMLException e) {
           	throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
	}

	@AuraEnabled
	public static String getConfig() {
		try{
            Map<String,String> lcConfig = new Map<String,String>();

			String baseURL = '';
			if (!Test.isRunningTest()) {
				baseURL = Network.getLoginUrl(Network.getNetworkId());
				String uselessString = baseURL.substring(baseURL.lastIndexOf('/')+1);
				baseURL = baseURL.replace(uselessString, '');
				baseURL = baseURL.replace('/s/','/');
			}

			lcConfig.put('orgId', UserInfo.getOrganizationId());
			lcConfig.put('locale', UserInfo.getLocale());
			lcConfig.put('profileId', UserInfo.getProfileId());
			lcConfig.put('communityURL', baseURL);

            return JSON.serialize(lcConfig);
       } catch(DMLException e) {
           throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e){
             throw new AuraHandledException(e.getMessage());
        }
	}
}