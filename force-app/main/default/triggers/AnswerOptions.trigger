trigger AnswerOptions on AnswerOption__c (before insert, before update, before delete) {
	if( SObjectDomain.isHandlerActive('FieloELR__AnswerOption__c')){
		SObjectDomain.triggerHandler(AnswerOptions.class);
	}
}