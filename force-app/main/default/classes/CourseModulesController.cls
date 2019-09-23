public with sharing class CourseModulesController {
	@AuraEnabled
	public static String getCourseMap(FieloPLT__Member__c member, Id courseId, String courseFields, String modulesFieldset) {
		try{
			Id memberId = member.Id;
			Id programId = member.FieloPLT__Program__c;
			
			Set<String> fieldsCourse = new Set<String> ( courseFields.split(',') );
			Set<String> fieldsModule = new Set<String> ( modulesFieldset.split(',') );

			fieldsModule.add('Id');
			fieldsModule.add('FieloELR__AttemptsAllowed__c');
			fieldsModule.add('FieloELR__IsActive__c');
			fieldsModule.add('FieloELR__KeyDependencies__c');

			fieldsCourse.add('Id');
			fieldsCourse.add('FieloELR__SubscriptionMode__c');
			fieldsCourse.add('FieloELR__Description__c');
			fieldsCourse.add('FieloELR__Status__c');

			List<CourseService.CourseWrapper> coursesMap;
			
			// SR: CRUD Check
			if ( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.CourseDependency__c.isAccessible() && Schema.sObjectType.Module__c.isAccessible() && Schema.sObjectType.ModuleDependency__c.isAccessible() ) {
				// SR: FLS Check
				if ( Schema.sObjectType.Course__c.fields.Name.isAccessible() && Schema.sObjectType.Module__c.fields.Name.isAccessible() ) {
					coursesMap = CourseService.getCoursesMap(
						fieldsCourse,
						new Set<String>{'Id','Name','FieloELR__Predecessor__r.Name'},
						fieldsModule,
						new Set<String>{'Id','FieloELR__Predecessor__r.Name'},
						new Set<Id>{courseId},
						programId,
						memberId,
						false,
						true,
						100,
						0,
						'FieloELR__Order__c',
						''
					);
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c, Module__c', 'Course__c.Name, Module__c.Name'}));
				}
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c, CourseDependency__c, Module__c, ModuleDependency__c'}));
			}

			return JSON.serialize(coursesMap);
		} catch(DMLException e) {
           	throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e){
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
			fieldsModuleResponse.add('FieloELR__CourseStatus__r.Id');
			fieldsModuleResponse.add('FieloELR__CourseStatus__r.FieloELR__Progress__c');

			if (includePoints != null && includePoints) {
				fieldsModuleResponse.add('(SELECT Id, FieloPLT__Points__c FROM FieloELR__Transactions__r WHERE FieloPLT__IsReverted__c = false AND FieloPLT__IsProcessed__c = true) FieloELR__Transactions__r');
                fieldsModuleResponse.add('(SELECT Id, FieloPLT__Transaction__r.FieloPLT__Points__c FROM FieloELR__Trackers__r WHERE FieloPLT__IsReverted__c = false AND FieloPLT__IsProcessed__c = true) FieloELR__Trackers__r');
			}
			
			String queryModuleResponse = 'SELECT ' + String.join(new List<String>(fieldsModuleResponse), ',');
			queryModuleResponse += ' FROM FieloELR__ModuleResponse__c WHERE FieloELR__CourseStatus__r.FieloELR__ExternalKey__c = :key';

			String coursesPoints = CourseService.getCoursePoints(new Set<Id>{courseId}, member.Id);

			Object moduleResponses;

			if (Schema.sObjectType.FieloPLT__Tracker__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.isAccessible() && Schema.sObjectType.CourseStatus__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.isAccessible()) {
				if ( Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__Points__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__IsReverted__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__IsProcessed__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__IsReverted__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__IsProcessed__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__Transaction__c.isAccessible() && Schema.sObjectType.CourseStatus__c.fields.Progress__c.isAccessible() && Schema.sObjectType.CourseStatus__c.fields.FieloELR__Course_Accomplished__c.isAccessible() && Schema.sObjectType.CourseStatus__c.fields.ExternalKey__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.Module__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.IsApproved__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.NumberOfAttempt__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.NumberOfApprove__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.GradePercent__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.SubmitDate__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.CorrectQuestions__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.IncorrectQuestions__c.isAccessible()) {
					moduleResponses = (Object) Database.query(queryModuleResponse);
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c,FieloPLT__Transaction__c,FieloPLT__Tracker__c'}));
				}
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c,FieloPLT__Transaction__c,FieloPLT__Tracker__c'}));
			}

			return JSON.serialize(new Map<String, Object>{
				'moduleResponses' => moduleResponses,
				'coursePoints' => coursesPoints != null ? JSON.deserializeUntyped(coursesPoints) : null
			});
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
}