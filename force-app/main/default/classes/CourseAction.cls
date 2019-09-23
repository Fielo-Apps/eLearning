public with sharing class CourseAction {
	@AuraEnabled
	public static String joinCourse(String memberId, String courseId) {
		try{
            if (true) {
				SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{CourseStatus__c.SObjectType});
				CourseStatus__c cs = new CourseStatus__c(
					Course__c = courseId,
					Member__c = memberId
				);
				uow.registerNew(cs);
				
				if ( Schema.sObjectType.CourseStatus__c.isCreateable() && Schema.sObjectType.CourseStatus__c.isUpdateable()) {
					if (Schema.sObjectType.CourseStatus__c.fields.Course__c.isCreateable() && Schema.sObjectType.CourseStatus__c.fields.Course__c.isUpdateable() && Schema.sObjectType.CourseStatus__c.fields.Member__c.isCreateable() && Schema.sObjectType.CourseStatus__c.fields.Member__c.isUpdateable()) {
						uow.commitWork();
					} else {
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_insertable, new List<String>{'CourseStatus__c', 'Course__c,Member__c'}));
					}
				} else {
					throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c'}));
				}

				return courseId;
			}
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
	}
}