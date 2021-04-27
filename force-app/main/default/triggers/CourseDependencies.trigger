trigger CourseDependencies on FieloELR__CourseDependency__c (before insert, before update, after insert, after delete) {
	if( SObjectDomain.isHandlerActive('FieloELR__CourseDependency__c')){
		SObjectDomain.triggerHandler(CourseDependencies.class);
	}
}