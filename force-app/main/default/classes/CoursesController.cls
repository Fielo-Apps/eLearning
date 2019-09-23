public with sharing class CoursesController {
    @AuraEnabled
	public static String getFilterFieldset(String objectName, String fieldNames, String rangedFields, Boolean useStandardStatusList) {
		try{
			Set<String> rangedFieldSet = new Set<String>(rangedFields != '' && rangedFields != null ? rangedFields.split(',') : new List<String>());
			Map<String, Object> objectInfo = new Map<String, Object>();
			List<Object> fieldsInfoObj = new List<Object>();
            List<Map<String, String>> picklistEntries;
			List<Map<String, Object>> newfieldsInfo = new List<Map<String, Object>>();
			Map<String, Object> fieldMeta;
			Map<String, Object> fieldAttributes;
			Map<String, Object> fieldToMeta;
			Map<String, Object> fieldToAttributes;

			objectInfo = (Map<String, Object>) JSON.deserializeUntyped(AuraService.getFieldData(objectName,fieldNames));
			fieldsInfoObj = (List<Object>) objectInfo.get('fields');

			for (Object fieldMetaObject: fieldsInfoObj) {
				fieldMeta = (Map<String, Object>) fieldMetaObject;
				fieldAttributes = (Map<String, Object>) fieldMeta.get('attributes');
				if (!fieldAttributes.containsKey('isRanged')) {
					fieldAttributes.put('isRanged', (Object) String.valueOf(rangedFieldSet.contains(String.valueOf(fieldAttributes.get('name')))));
					if (rangeLabel.containsKey(String.valueOf(fieldAttributes.get('type')))) {
						fieldAttributes.put('rangeLabel', (Object) String.valueOf(rangeLabel.get(String.valueOf(fieldAttributes.get('type')))));	
					} else {
						fieldAttributes.put('rangeLabel', (Object) Label.RangeSuffix);
					}
				}
				if (String.valueOf(fieldAttributes.get('type')) == 'picklist' ) {
					fieldMeta.put('firstOptionLabel', (Object) Label.All);
				}

                if (objectName.toLowerCase() == 'fieloelr__course__c' && String.valueOf(fieldAttributes.get('name')).toLowerCase() == 'fieloelr__status__c' && !useStandardStatusList) {
					picklistEntries = new List<Map<String, String>>();
                    picklistEntries.add(new Map<String, String>{'value' => 'Active','label'=> Label.ActiveOption});
                    picklistEntries.add(new Map<String, String>{'value' => 'Scheduled','label'=> Label.ScheduledOption});
                    picklistEntries.add(new Map<String, String>{'value' => 'Completed','label'=> Label.CompletedOption});
					if (!picklistEntries.isEmpty()) {
						fieldMeta.put('picklistentries', (Object) picklistEntries);
					}
                    fieldMeta.put('firstOptionLabel', (Object) Label.All);
				}
				fieldMeta.put('attributes', (Object) fieldAttributes);
				newfieldsInfo.add(fieldMeta);
			}
			objectInfo.put('fields', (Object) newfieldsInfo);
            return JSON.serialize(objectInfo);
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
	}
    
    @AuraEnabled
    public static String getCourses(FieloPLT__Member__c member, List<String> coursesFieldset, List<String> modulesFieldset, Integer quantity, Integer offset, String status, String sortByClause, String dynamicFilter){
        try{
			Map<String,Schema.SObjectField> moduleFieldsMap = Schema.SObjectType.Module__c.fields.getMap();
			Map<String,Schema.SObjectField> courseFieldsMap = Schema.SObjectType.Course__c.fields.getMap();
            Set<String> fieldsCourse = new Set<String>(coursesFieldset); 
            Set<String> fieldsModule = new Set<String>(modulesFieldset);
            Set<String> fieldsCourseStatus = new Set<String>{'Name'};
            Set<String> fieldsModuleResponse = new Set<String>{'Name'};
            Set<String> statusList = new Set<String>();
            if ( status == '' || status == null) {
                statusList.add('Active');
				statusList.add('Scheduled');
				statusList.add('Completed');
            }
            Id memberId = member.Id;

			fieldsModule.add('FieloELR__Order__c');

			Set<String> courseFieldsToQuery = new Set<String>();


			for(String fieldName:fieldsCourse) {
				if (fieldName == 'FieloELR__Transactions__r') {
					if (Schema.sObjectType.FieloPLT__Transaction__c.isAccessible()) {
						if (Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__Points__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__IsReverted__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__IsProcessed__c.isAccessible()) {
                    		courseFieldsToQuery.add('(SELECT Id, FieloPLT__Points__c FROM FieloELR__Transactions__r WHERE FieloPLT__IsReverted__c = false AND FieloPLT__IsProcessed__c = true)');
						} else {
							throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__Transaction__c','FieloPLT__Points__c,FieloPLT__IsReverted__c,FieloPLT__IsProcessed__c'}));
						}
					} else {
						throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__Transaction__c'}));
					}
                } else if (fieldName == 'FieloELR__Trackers__r') {
					// SR: CRUD Check
					if (Schema.sObjectType.FieloPLT__Tracker__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.isAccessible()) {
						// SR: FLS Check
						if (Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__Transaction__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__Points__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__IsReverted__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__IsProcessed__c.isAccessible()) {
                    		courseFieldsToQuery.add('(SELECT Id, FieloPLT__Transaction__r.FieloPLT__Points__c FROM FieloELR__Trackers__r WHERE FieloPLT__IsReverted__c = false AND FieloPLT__IsProcessed__c = true)');
						} else {
							throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__Tracker__c','FieloPLT__Transaction__r.FieloPLT__Points__c,FieloPLT__IsReverted__c,FieloPLT__IsProcessed__c'}));
						}
					} else {
						throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__Tracker__c,FieloPLT__Transaction__c'}));
					}
                } else {
					// SR: Dynamic FLS Check
					if ( courseFieldsMap.containsKey(fieldName) && !courseFieldsMap.get(fieldName).getDescribe().isAccessible()) {
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c',fieldName}));
					} else {
						courseFieldsToQuery.add(fieldName);
					}
				}
			}
			
			List<FieloELR__Course__c> courses;
			List<CourseService.CourseWrapper> courseWrappers;
			// SR: CRUD Check
			if ( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.Module__c.isAccessible() && Schema.sObjectType.CourseDependency__c.isAccessible() && Schema.sObjectType.ModuleDependency__c.isAccessible()) {
				// SR: Dynamic FLS Check
				for ( String fieldName : fieldsModule ) {
					if ( moduleFieldsMap.containsKey(fieldName) && !moduleFieldsMap.get(fieldName).getDescribe().isAccessible() ) {
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c',fieldName}));
					}
				}
				// SR: FLS Check
				if ( Schema.sObjectType.Course__c.fields.SubscriptionMode__c.isAccessible() && Schema.sObjectType.Course__c.fields.Status__c.isAccessible() && Schema.sObjectType.Module__c.fields.Name.isAccessible() && Schema.sObjectType.CourseDependency__c.fields.Name.isAccessible() && Schema.sObjectType.ModuleDependency__c.fields.Name.isAccessible() && Schema.sObjectType.Course__c.fields.LastModifiedDate.isAccessible()) {
					courses = CourseService.getCourses(
													courseFieldsToQuery, 
													new Set<String>{'Id','Name'},
													fieldsModule,
													null,
													statusList,
													member.FieloPLT__Program__c,
													memberId,
													false,
													true,
													true,
													quantity,
													offset,
													sortByClause != null && sortByClause != '' ? sortByClause : 'LastModifiedDate DESC',
													dynamicFilter != null && dynamicFilter != '' ? dynamicFilter : '');

					Set<Id> courseIds = new Map<Id, FieloELR__Course__c>(courses).keyset();
					
					courseWrappers = CourseService.getCoursesMap(
													new Set<String>{'Id','FieloELR__SubscriptionMode__c','FieloELR__Status__c'},
													new Set<String>{'Id','Name'},
													new Set<String>{'Id','Name'},
													null,
													courseIds,
													member.FieloPLT__Program__c,
													memberId,
													false,
													false,
													quantity, 
													offset, 
													sortByClause != null && sortByClause != '' ? sortByClause : 'LastModifiedDate DESC',
													dynamicFilter != null && dynamicFilter != '' ? dynamicFilter : '');
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c,Module__c,CourseDependency__c,ModuleDependency__c,','Course.SubscriptionMode__c, Course__c.Status__c, Module__c.Name, CourseDependency__c.Name, ModuleDependency__c.Name'}));
				}
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,Module__c,CourseDependency__c,ModuleDependency__c'}));
			}

            return JSON.serialize( new Map<String, Object>{
				'list' => courses,
				'wrappers' => courseWrappers
			});
       	} catch(DMLException e) {
           throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e){
             throw new AuraHandledException(e.getMessage());
        }
    }

    public static Map<String, String> rangeLabel {get{
		if (rangeLabel == null) {
			rangeLabel = new Map<String, String>{
				'currency' => Label.CurrencyRangeSuffix,
        		'double' => Label.DoubleRangeSuffix,
        		'percent' => Label.PercentRangeSuffix,
        		'date' => Label.DateRangeSuffix,
        		'datetime' => Label.DatetimeRangeSuffix
			};
		}
		return rangeLabel;
	} set; }

	@AuraEnabled
	public static String getConfig() {
		try{
            Map<String,String> lcConfig = new Map<String,String>();

			String baseURL = Network.getLoginUrl(Network.getNetworkId());
			String uselessString = baseURL.substring(baseURL.lastIndexOf('/')+1);
			baseURL = baseURL.replace(uselessString, '');
			baseURL = baseURL.replace('/s/','/');

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

	@AuraEnabled
	public static String getFieldsMetadata(String objectName, String fieldNames) {
		try{
            return AuraService.getFieldData(objectName,fieldNames);
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
	}

	@AuraEnabled
	public static String getCourseByCourseStatus(FieloPLT__Member__c member, List<String> coursesFieldset, List<String> modulesFieldset, Integer quantity, Integer offset, String status, String sortByClause, String dynamicFilter, Boolean showPointsEarned) {
		try{
			Map<String,Schema.SObjectField> moduleFieldsMap = Schema.SObjectType.Module__c.fields.getMap();
			Map<String,Schema.SObjectField> courseFieldsMap = Schema.SObjectType.Course__c.fields.getMap();
			Map<String,Schema.SObjectField> courseStatusFieldsMap = Schema.SObjectType.CourseStatus__c.fields.getMap();

			Set<String> courseStatusFields = new Set<String>();
			if (showPointsEarned != null && showPointsEarned) {
				// SR: CRUD Check
				if (Schema.sObjectType.FieloPLT__Transaction__c.isAccessible()) {
					// SR: FLS Check
					if (Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__Points__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__IsReverted__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__IsProcessed__c.isAccessible()) {
						courseStatusFields.add('(SELECT Id, FieloPLT__Points__c FROM FieloELR__Transactions__r WHERE FieloPLT__IsReverted__c = false AND FieloPLT__IsProcessed__c = true) FieloELR__Transactions__r');
					} else {
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__Transaction__c','FieloPLT__Points__c,FieloPLT__IsReverted__c,FieloPLT__IsProcessed__c'}));
					}
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__Transaction__c'}));
				}
				// SR: CRUD Check
				if (Schema.sObjectType.FieloPLT__Tracker__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.isAccessible()) {
					// SR: FLS Check
					if (Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__Transaction__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__Points__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__IsReverted__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__IsProcessed__c.isAccessible()) {
						courseStatusFields.add('(SELECT Id, FieloPLT__Transaction__r.FieloPLT__Points__c FROM FieloELR__Trackers__r WHERE FieloPLT__IsReverted__c = false AND FieloPLT__IsProcessed__c = true) FieloELR__Trackers__r');
					} else {
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__Tracker__c','FieloPLT__Transaction__r.FieloPLT__Points__c,FieloPLT__IsReverted__c,FieloPLT__IsProcessed__c'}));
					}
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__Tracker__c,FieloPLT__Transaction__c'}));
				}
			}
			courseStatusFields.add('Id');
			courseStatusFields.add('FieloELR__Course__c');
			courseStatusFields.add('FieloELR__Member__c');
			courseStatusFields.add('FieloELR__Progress__c');
			courseStatusFields.add('FieloELR__ApprovedModules__c');

			// SR: CRUD Check
			if (Schema.sObjectType.ModuleResponse__c.isAccessible() && Schema.sObjectType.Module__c.isAccessible()) {
				// SR: FLS Check
				if (Schema.sObjectType.ModuleResponse__c.fields.NumberofApprove__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.Module__c.isAccessible() && Schema.sObjectType.Module__c.fields.Order__c.isAccessible()) {
					courseStatusFields.add('(SELECT Id, FieloELR__NumberofApprove__c, FieloELR__Module__c, FieloELR__Module__r.FieloELR__Order__c FROM FieloELR__ModuleResponses__r)');
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'ModuleResponse__c,Module__c','ModuleResponse__c.NumberofApprove__c, ModuleResponse__c.Module__c, Module__c.Order__c'}));
				}
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'ModuleResponse__c,Module__c'}));
			}

			// SR: Dynamic FLS Check
			for(String fieldName : courseStatusFields) {
				if ( courseStatusFieldsMap.containsKey(fieldName) && !courseStatusFieldsMap.get(fieldName).getDescribe().isAccessible()) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'CourseStatus__c',fieldName}));
				}
			}

            CourseStatusSelector selector = new CourseStatusSelector(courseStatusFields);
			selector.setLimit(quantity);
			selector.setOffset(offset);
			List<CourseStatus__c> courseStatusList;
			// SR: CRUD Check
			if (Schema.sObjectType.CourseStatus__c.isAccessible()) {
				// SR: FLS Check
				if (Schema.sObjectType.CourseStatus__c.fields.Member__c.isAccessible()) {
					courseStatusList = selector.selectByMemberId(new Set<Id>{member.Id});
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'CourseStatus__c','Member__c'}));
				}
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c'}));
			}

			Set<Id> courseIds = new Set<Id>();

			for(CourseStatus__c cs: courseStatusList) {
				courseIds.add(cs.Course__c);
			}

			Set<String> courseFieldsToQuery = new Set<String>();
			Set<String> fieldsCourse = new Set<String>(coursesFieldset);
            Set<String> fieldsModule = new Set<String>(modulesFieldset);

			System.debug(
				JSON.serializePretty(fieldsCourse)
			);

			for(String fieldName: fieldsCourse) {
				if (fieldName == 'FieloELR__Modules__r') {
					// SR: CRUD Check
					if ( Schema.sObjectType.Module__c.isAccessible()) {
						// SR: FLS Check
						if ( Schema.sObjectType.Module__c.fields.Name.isAccessible() && Schema.sObjectType.Module__c.fields.Order__c.isAccessible() && Schema.sObjectType.Module__c.fields.IsActive__c.isAccessible()) {
							courseFieldsToQuery.add('(SELECT Id, Name, FieloELR__Order__c FROM FieloELR__Modules__r WHERE FieloELR__IsActive__c = true) FieloELR__Modules__r');
						} else {
							throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c','Name,Order__c,IsActive__c'}));
						}
					} else {
						throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c'}));
					}
				} else {
					// SR: Dynamic FLS Check
					if ( courseFieldsMap.containsKey(fieldName) && !courseFieldsMap.get(fieldName).getDescribe().isAccessible()) {
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c',fieldName}));
					} else {
						courseFieldsToQuery.add(fieldName);
					}
				}
			}
			
			fieldsModule.add('FieloELR__Order__c');

			// SR: Dynamic FLS Check
			for(String fieldName : fieldsModule) {
				if ( moduleFieldsMap.containsKey(fieldName) && !moduleFieldsMap.get(fieldName).getDescribe().isAccessible()) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c',fieldName}));
				}
			}
            
			List<FieloELR__Course__c> courses;

			// SR: CRUD Check
			if (Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.CourseDependency__c.isAccessible() && Schema.sObjectType.Module__c.isAccessible()) {
				if (Schema.sObjectType.CourseDependency__c.fields.Name.isAccessible() && Schema.sObjectType.Course__c.fields.LastModifiedDate.isAccessible()) {
					courses = CourseService.getCourses(
													courseFieldsToQuery, 
													new Set<String>{'Id','Name'},
													fieldsModule,
													courseIds,
													null,
													member.FieloPLT__Program__c,
													member.Id,
													false,
													false,
													false,
													quantity,
													offset,
													sortByClause != null && sortByClause != '' ? sortByClause : 'LastModifiedDate DESC' ,
													dynamicFilter != null && dynamicFilter != '' ? dynamicFilter : '');
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'CourseDependency__c','Name'}));
				}
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,CourseDependency__c,Module__c'}));
			}

			List<CourseService.CourseWrapper> courseWrappers;

			// SR: CRUD Check
			if (Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.CourseDependency__c.isAccessible() && Schema.sObjectType.Module__c.isAccessible() && Schema.sObjectType.ModuleDependency__c.isAccessible()) {
				// SR: FLS Check
				if ( Schema.sObjectType.Course__c.fields.SubscriptionMode__c.isAccessible() && Schema.sObjectType.Course__c.fields.Status__c.isAccessible() && Schema.sObjectType.CourseDependency__c.fields.Name.isAccessible() && Schema.sObjectType.Module__c.fields.Name.isAccessible() && Schema.sObjectType.Course__c.fields.LastModifiedDate.isAccessible()) {
					courseWrappers = CourseService.getCoursesMap(
													new Set<String>{'Id','FieloELR__SubscriptionMode__c','FieloELR__Status__c'},
													new Set<String>{'Id','Name'},
													new Set<String>{'Id','Name'},
													null,
													courseIds,
													member.FieloPLT__Program__c,
													member.Id,
													false,
													false,
													quantity, 
													offset, 
													sortByClause != null && sortByClause != '' ? sortByClause : 'LastModifiedDate DESC',
													dynamicFilter != null && dynamicFilter != '' ? dynamicFilter : '');
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c,CourseDependency__c,Module__c,ModuleDependency__c','Course__c.SubscriptionMode__c, Course__c.Status__c, Course__c.LastModifiedDate, CourseDependency__c.Name, Module__c.Name'}));
				}
			} else {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,CourseDependency__c,Module__c,ModuleDependency__c'}));
			}

			String coursesPoints = CourseService.getCoursePoints(courseIds, member.Id);
			
			Map<String, Object> result = new Map<String, Object>{
				'courses' => (Object) courses,
				'wrappers' => (Object) courseWrappers,
				'courseStatus' => (Object) courseStatusList,
				'coursePoints' => coursesPoints != null ? JSON.deserializeUntyped(coursesPoints) : ''
			};
            return JSON.serialize(result);
       } catch(DMLException e) {
           throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e){
             throw new AuraHandledException(e.getMessage());
        }
	}
}