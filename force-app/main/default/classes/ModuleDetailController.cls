public with sharing class ModuleDetailController {
	@AuraEnabled
	public static String getModule(FieloPLT__Member__c member, String moduleId, String moduleFields, String moduleResponseFields) {
		try{
			String memberId = member.Id;
			Map<String,Schema.SObjectField> moduleFieldsMap = Schema.sObjectType.Module__c.fields.getMap();
			Map<String,Schema.SObjectField> moduleResponseFieldsMap = Schema.sObjectType.ModuleResponse__c.fields.getMap();

			Set<String> moduleFieldSet = new Set<String>();
			if (moduleFields != '' && moduleFields != null) {
				// SR: FLS Check
				for(String s :  moduleFields.split(',')){
					if( moduleFieldsMap.containsKey(s) && !moduleFieldsMap.get(s).getDescribe().isAccessible() ){
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', s}));
					} else {
						moduleFieldSet.add(s);
					}
				}
			}

			// SR: FLS Check
			if( Schema.sObjectType.Module__c.fields.KeyDependencies__c.isAccessible() ){
				moduleFieldSet.add('FieloELR__KeyDependencies__c');
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', 'FieloELR__KeyDependencies__c'}));
			}

			// SR: FLS Check
			if( Schema.sObjectType.Module__c.fields.Course__c.isAccessible() ){
				moduleFieldSet.add('FieloELR__Course__c');
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', 'FieloELR__Course__c'}));
			}

			String modulesQuery = 'SELECT ' +
				String.join(new List<String>(moduleFieldSet), ',') +
				' FROM FieloELR__Module__c WHERE Id = :moduleId';

			List<Module__c> modules;

			// SR: CRUD Check
			if( Schema.sObjectType.Module__c.isAccessible() ){
				modules = (List<Module__c>) Database.query(modulesQuery);
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c'}));
			}

			Set<String> moduleResponseFieldSet = new Set<String>();
			if (moduleResponseFields != '' && moduleResponseFields != null) {
				// SR: FLS Check
				for(String s : moduleResponseFields.split(',')){
					if( moduleResponseFieldsMap.containsKey(s) && !moduleResponseFieldsMap.get(s).getDescribe().isAccessible() ){
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'ModuleResponse__c', s}));
					} else {
						moduleResponseFieldSet.add(s);
					}
				}
			}

			// SR: FLS Check
			if( Schema.sObjectType.ModuleResponse__c.fields.Member__c.isAccessible() ){
				moduleResponseFieldSet.add('FieloELR__Member__c');
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'ModuleResponse__c', 'FieloELR__Member__c'}));
			}

			String modulesResponseQuery = 'SELECT ' +
				String.join(new List<String>(moduleResponseFieldSet), ',') +
				' FROM FieloELR__ModuleResponse__c WHERE FieloELR__Module__c = :moduleId AND FieloELR__Member__c = :memberId AND FieloELR__IsSubmitted__c = true ORDER BY CreatedDate DESC';
			
			List<ModuleResponse__c> moduleResponses;
			
			// SR: CRUD Check
			if( Schema.sObjectType.ModuleResponse__c.isAccessible() ){
				moduleResponses = (List<ModuleResponse__c>) Database.query(modulesResponseQuery);
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'ModuleResponse__c'}));
			}

			String moduleDependencyQuery = 'SELECT Id, ' +
				'FieloELR__Predecessor__r.Name ' +
				' FROM FieloELR__ModuleDependency__c ' +
				' WHERE FieloELR__Module__c = :moduleId AND FieloELR__Predecessor__r.FieloELR__IsActive__c = true';

			List<ModuleDependency__c> dependencies;

			// SR: CRUD Check
			if( Schema.sObjectType.ModuleDependency__c.isAccessible() && Schema.sObjectType.Module__c.isAccessible() ){
				dependencies = (List<ModuleDependency__c>) Database.query(moduleDependencyQuery);
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'ModuleDependency__c, Module__c'}));
			}

			CourseService.ModuleWrapper mw;
			
			if (!moduleResponses.isEmpty()) {
				mw = new CourseService.ModuleWrapper(modules[0], moduleResponses, dependencies);
			} else {
				mw = new CourseService.ModuleWrapper(modules[0], dependencies, member.Id);
			}

			return JSON.serialize(mw);
		} catch(DMLException e) {
           	throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e){
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
	public static String getCourseData(FieloPLT__Member__c member, String courseId) {
		try{
			String key = courseId + member.Id;
			String courseStatusQuery = 'SELECT Id, Name, FieloELR__Course__c, (SELECT Id, Name, FieloELR__Module__c, FieloELR__NumberofApprove__c FROM FieloELR__ModuleResponses__r ORDER BY FieloELR__Module__r.FieloELR__Order__c, FieloELR__NumberOfAttempt__c ) FROM FieloELR__CourseStatus__c WHERE FieloELR__ExternalKey__c = :key';

			List<FieloELR__CourseStatus__c> courseStatus;
			if( Schema.sObjectType.CourseStatus__c.isAccessible() && Schema.sObjectType.CourseStatus__c.fields.Course__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.Module__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.NumberofApprove__c.isAccessible() ){
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

			return JSON.serialize(new Map<String, Object>{
				'courseStatus' => courseStatus,
				'courseWrapper' => courseWrappers,
				'coursePoints' => coursesPoints != null ? JSON.deserializeUntyped(coursesPoints) : null
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