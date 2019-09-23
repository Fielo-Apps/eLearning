trigger Courses on Course__c (before update, before delete, before insert, after update) {
	SObjectDomain.triggerHandler(Courses.class);
}