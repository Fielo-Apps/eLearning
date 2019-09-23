trigger CourseDependencies on FieloELR__CourseDependency__c (before insert, before update, after insert, after delete) {
	SObjectDomain.triggerHandler(CourseDependencies.class);
}