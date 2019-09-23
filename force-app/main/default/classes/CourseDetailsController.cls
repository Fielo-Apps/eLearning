public with sharing class CourseDetailsController {
		
	@AuraEnabled
	public static String getCourse(FieloPLT__Member__c member, String courseId, String courseFields, String moduleFields, Boolean showPointsEarned){
		try{
			Set<String> courseStatusFields = new Set<String>();
			if (showPointsEarned != null && showPointsEarned) {
				courseStatusFields.add('(SELECT Id, FieloPLT__Points__c FROM FieloELR__Transactions__r WHERE FieloPLT__IsReverted__c = false AND FieloPLT__IsProcessed__c = true) FieloELR__Transactions__r');
				courseStatusFields.add('(SELECT Id, FieloPLT__Transaction__r.FieloPLT__Points__c FROM FieloELR__Trackers__r WHERE FieloPLT__IsReverted__c = false AND FieloPLT__IsProcessed__c = true) FieloELR__Trackers__r');
			}
			courseStatusFields.add('Id');
			courseStatusFields.add('FieloELR__Course__c');
			courseStatusFields.add('FieloELR__Progress__c');
			courseStatusFields.add('FieloELR__ApprovedModules__c');

			CourseStatusSelector selector = new CourseStatusSelector(courseStatusFields);
			String key = courseId + member.Id;
			
			List<CourseStatus__c> courseStatusList;

			if (Schema.sObjectType.FieloPLT__Tracker__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.isAccessible() && Schema.sObjectType.CourseStatus__c.isAccessible()) {
				if ( Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__Points__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__IsReverted__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__IsProcessed__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__IsReverted__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__IsProcessed__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__Transaction__c.isAccessible() && Schema.sObjectType.CourseStatus__c.fields.Course__c.isAccessible() && Schema.sObjectType.CourseStatus__c.fields.Progress__c.isAccessible() && Schema.sObjectType.CourseStatus__c.fields.ApprovedModules__c.isAccessible()) {
					courseStatusList = selector.selectByKey(new Set<String>{ key });
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c,FieloPLT__Transaction__c,FieloPLT__Tracker__c'}));
				}
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c,FieloPLT__Transaction__c,FieloPLT__Tracker__c'}));
			}

			Set<String> courseFieldsToQuery = new Set<String>();
			Set<String> fieldsCourse = new Set<String>(courseFields.split(','));
			Set<String> fieldsModule = new Set<String>(moduleFields.split(','));

			for(String fieldName: fieldsCourse) {
				if (fieldName != 'FieloELR__Modules__r') {
					courseFieldsToQuery.add(fieldName);
				}
			}
			
			fieldsModule.add('FieloELR__Order__c');
			
			List<FieloELR__Course__c> courses = CourseService.getCourses(
											courseFieldsToQuery, 
											new Set<String>{'Id','Name'},
											fieldsModule,
											new Set<Id>{courseId},
											null,
											member.FieloPLT__Program__c,
											member.Id,
											false,
											false,
											false,
											null,
											null,
											'LastModifiedDate DESC' ,
											'');

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
			
			Map<String, String> result = new Map<String, String>{
				'courses' => courses != null ? JSON.serialize(courses) : '',
				'wrappers' => courseWrappers != null ? JSON.serialize(courseWrappers) : '',
				'courseStatus' => courseStatusList != null ? JSON.serialize(courseStatusList) : '',
				'coursePoints' => coursesPoints
			};
			return JSON.serialize(result);
		} catch(DMLException e) {
			System.debug(e);
			throw new AuraHandledException(e.getDMLMessage(0));
		} catch(Exception e){
			System.debug(e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static String getConfig(String recordId, String memberId){
		try {
			Map<String,String> lcConfig = new Map<String,String>();
			String baseUrl = Network.getLoginUrl(Network.getNetworkId());
			String uselessString = baseURL.substring(baseURL.lastIndexOf('/')+1);
			baseURL = baseURL.replace(uselessString, '').replace('/s/','/');
			Set<String> queryableFields = new Set<String>{'Id','Name'};

			List<CourseStatus__c> csList;

			if (Schema.sObjectType.CourseStatus__c.isAccessible() && Schema.sObjectType.CourseStatus__c.fields.Name.isAccessible() && Schema.sObjectType.CourseStatus__c.fields.ExternalKey__c.isAccessible()) {
				csList = new List<CourseStatus__c>(new CourseStatusSelector(queryableFields).selectByKey(new Set<String>{String.valueOf(recordId) + String.valueOf(memberId)}));
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c'}));
			}

			lcConfig.put('orgId', UserInfo.getOrganizationId());
			lcConfig.put('locale', UserInfo.getLocale());
			lcConfig.put('profileId', UserInfo.getProfileId());
			lcConfig.put('communityURL', baseURL);
			lcConfig.put('joinedCourse', String.valueOf(!csList.isEmpty()));
			lcConfig.put('orgId', UserInfo.getOrganizationId());
			return JSON.serialize(lcConfig);
		}
		catch(DMLException e){
			throw new AuraHandledException(e.getDMLMessage(0));	
		} 
		catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static String getCourseStatus(FieloPLT__Member__c member, Id courseId, Boolean includePoints) {
		try{
			Id memberId = member.Id;
			String key = String.valueOf(courseId) + String.valueOf(memberId);

			Set<String> fieldsModuleResponse = new Set<String>();
			fieldsModuleResponse.add('Id');
			fieldsModuleResponse.add('FieloELR__Module__c');
			fieldsModuleResponse.add('FieloELR__IsApproved__c');
			fieldsModuleResponse.add('FieloELR__NumberOfAttempt__c');
			fieldsModuleResponse.add('FieloELR__NumberofApprove__c');
			fieldsModuleResponse.add('FieloELR__GradePercent__c');
			fieldsModuleResponse.add('FieloELR__SubmitDate__c');
			fieldsModuleResponse.add('FieloELR__CorrectQuestions__c');
			fieldsModuleResponse.add('FieloELR__IncorrectQuestions__c');
			fieldsModuleResponse.add('FieloELR__CourseStatus__r.FieloELR__Progress__c');
			fieldsModuleResponse.add('FieloELR__CourseStatus__r.FieloELR__Course_Accomplished__c');
			fieldsModuleResponse.add('FieloELR__Module__r.FieloELR__Order__c');
			fieldsModuleResponse.add('FieloELR__Module__r.Name');

			if (includePoints != null && includePoints) {
				fieldsModuleResponse.add('(SELECT Id, FieloPLT__Points__c FROM FieloELR__Transactions__r WHERE FieloPLT__IsReverted__c = false AND FieloPLT__IsProcessed__c = true) FieloELR__Transactions__r');
				fieldsModuleResponse.add('(SELECT Id, FieloPLT__Transaction__r.FieloPLT__Points__c FROM FieloELR__Trackers__r WHERE FieloPLT__IsReverted__c = false AND FieloPLT__IsProcessed__c = true) FieloELR__Trackers__r');
			}
			
			String queryModuleResponse = 'SELECT ' + String.join(new List<String>(fieldsModuleResponse), ',');
			queryModuleResponse += ' FROM FieloELR__ModuleResponse__c WHERE FieloELR__CourseStatus__r.FieloELR__ExternalKey__c = :key';

			String results;

			if (Schema.sObjectType.FieloPLT__Tracker__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.isAccessible() && Schema.sObjectType.CourseStatus__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.isAccessible() && Schema.sObjectType.Module__c.isAccessible()) {
				if ( Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__Points__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__IsReverted__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__IsProcessed__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__IsReverted__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__IsProcessed__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__Transaction__c.isAccessible() && Schema.sObjectType.CourseStatus__c.fields.Progress__c.isAccessible() && Schema.sObjectType.CourseStatus__c.fields.FieloELR__Course_Accomplished__c.isAccessible() && Schema.sObjectType.CourseStatus__c.fields.ExternalKey__c.isAccessible() && Schema.sObjectType.Module__c.fields.Order__c.isAccessible() && Schema.sObjectType.Module__c.fields.Name.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.Module__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.IsApproved__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.NumberOfAttempt__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.NumberOfApprove__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.GradePercent__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.SubmitDate__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.CorrectQuestions__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.IncorrectQuestions__c.isAccessible()) {
					results = JSON.serialize(Database.query(queryModuleResponse));
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c,FieloPLT__Transaction__c,FieloPLT__Tracker__c'}));
				}
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c,FieloPLT__Transaction__c,FieloPLT__Tracker__c'}));
			}			

			return results;
		} catch(DMLException e) {
			throw new AuraHandledException(e.getDMLMessage(0));
		} catch(Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static String getFieldsMetadata(String objectName, String fieldNames) {
		try{
            return AuraService.getFieldData(objectName,fieldNames);
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
	}
}