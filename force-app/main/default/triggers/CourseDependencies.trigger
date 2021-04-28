trigger CourseDependencies on CourseDependency__c (before insert, before update, after insert, after delete) {
	if( SObjectDomain.isHandlerActive(FieloPLT__Triggers__c.CourseDependency__c)){
		SObjectDomain.triggerHandler(CourseDependencies.class);
	}
}