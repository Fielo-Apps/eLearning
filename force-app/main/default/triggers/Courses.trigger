trigger Courses on Course__c (before update, before delete, before insert, after update) {
	if( SObjectDomain.isHandlerActive('FieloELR__Course__c') ){
		SObjectDomain.triggerHandler(Courses.class);
	}
}