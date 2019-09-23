public class CourseCardContainerController {
    @AuraEnabled
    public static String getCourseRecord(String recordId, String fields) {
        try{
            Set<String> fieldNames = new Set<String>();
            Map<String,Schema.SObjectField> singleCourseDetailAccessable = Schema.SObjectType.Course__c.fields.getMap();
            for (String singleCourseDetailfieldToCheck : fields.split(',')) { 
                if (singleCourseDetailAccessable.get(singleCourseDetailfieldToCheck).getDescribe().isAccessible() ) {
                    fieldNames.add(singleCourseDetailfieldToCheck);
                } else {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c', singleCourseDetailfieldToCheck}));
                }
            }

            
            Set<String> queryableFields = new Set<String>();
            
            for(String fieldName:fieldNames) {
                if (fieldName == 'FieloELR__Modules__r') {
                    queryableFields.add('(SELECT Id, Name, FieloELR__Order__c FROM FieloELR__Modules__r WHERE FieloELR__IsActive__c = true) FieloELR__Modules__r');
                } else {
                    queryableFields.add(fieldName);
                }
            }
            CoursesSelector selector = new CoursesSelector(queryableFields);
            String results;

            if ( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.Module__c.isAccessible()) {
                if(Schema.sObjectType.Module__c.fields.Name.isAccessible() && Schema.sObjectType.Module__c.fields.FieloELR__Order__c.isAccessible() && Schema.sObjectType.Module__c.fields.FieloELR__IsActive__c.isAccessible()) {
                    results = JSON.serialize(selector.selectByIdCustom(new Set<Id>{recordId})[0]);
                } else {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', 'Name,Order__c,IsActive__c'}));
                }
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,Module__c'}));
            }

            return results;
        } catch(DMLException e) {
            throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getConfig(String courseId, String memberId, String csFields) {
        try{
            Map<String,String> lcConfig = new Map<String,String>();
            String baseURL = Network.getLoginUrl(Network.getNetworkId());
            String uselessString = baseURL.substring(baseURL.lastIndexOf('/')+1);
            baseURL = baseURL.replace(uselessString, '');
            
            Set<String> queryableFields = new Set<String>();
            Set<String> fieldNames = new Set<String>();
            if (csFields != null) {
                Map<String,Schema.SObjectField> singleCourseStatusDetailAccessable = Schema.SObjectType.CourseStatus__c.fields.getMap();
                for (String singleCourseStatusDetailfieldToCheck : csFields.split(',')) { 
                    if (singleCourseStatusDetailAccessable.get(singleCourseStatusDetailfieldToCheck).getDescribe().isAccessible() ) {
                        fieldNames.add(singleCourseStatusDetailfieldToCheck);
                    } else {
                        throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'CourseStatus__c', singleCourseStatusDetailfieldToCheck}));
                    }
                }

                for(String fieldName:fieldNames) {
                    if (fieldName == 'FieloELR__Transactions__r') {
                        if (Schema.sObjectType.FieloPLT__Transaction__c.isAccessible()) {
                            if ( Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__Points__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__IsReverted__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__IsProcessed__c.isAccessible()) {
                                queryableFields.add('(SELECT Id, FieloPLT__Points__c FROM FieloELR__Transactions__r WHERE FieloPLT__IsReverted__c = false AND FieloPLT__IsProcessed__c = true) FieloELR__Transactions__r');
                            } else {
                                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__Transaction__c', 'FieloPLT__Points__c,FieloPLT__IsReverted__c,FieloPLT__IsProcessed__c'}));
                            }
                        } else {
                            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__Transaction__c'}));
                        }
                    } else if (fieldName == 'FieloELR__Trackers__r') {
                        if (Schema.sObjectType.FieloPLT__Tracker__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.isAccessible()) {
                            if (Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__IsReverted__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__IsProcessed__c.isAccessible() && Schema.sObjectType.FieloPLT__Tracker__c.fields.FieloPLT__Transaction__c.isAccessible() && Schema.sObjectType.FieloPLT__Transaction__c.fields.FieloPLT__Points__c.isAccessible()) {
                                queryableFields.add('(SELECT Id, FieloPLT__Transaction__r.FieloPLT__Points__c FROM FieloELR__Trackers__r WHERE FieloPLT__IsReverted__c = false AND FieloPLT__IsProcessed__c = true) FieloELR__Trackers__r');
                            } else {
                                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__Tracker__c', 'FieloPLT__Transaction__r.FieloPLT__Points__c,FieloPLT__IsReverted__c,FieloPLT__IsProcessed__c'}));
                            }
                        } else {
                            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__Tracker__c,FieloPLT__Transaction__c'}));
                        }
                    }
                }
            }

            List<CourseStatus__c> csList = new List<CourseStatus__c>(new CourseStatusSelector(queryableFields).selectByKey(new Set<String>{String.valueOf(courseId) + String.valueOf(memberId)}));
            
            lcConfig.put('orgId', UserInfo.getOrganizationId());
            lcConfig.put('locale', UserInfo.getLocale());
            lcConfig.put('profileId', UserInfo.getProfileId());
            lcConfig.put('communityURL', baseURL);
            lcConfig.put('joinedCourse', String.valueOf(!csList.isEmpty()));
            if (!csList.isEmpty()) {
                lcConfig.put('courseStatus', JSON.serialize(csList[0]));
            }
            return JSON.serialize(lcConfig);
        } catch(DMLException e) {
            throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}