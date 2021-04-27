trigger AnswerOptions on AnswerOption__c (before insert, before update, before delete) {
	if( SObjectDomain.isHandlerActive(FieloPLT__Triggers__c.AnswerOption__c)){
		SObjectDomain.triggerHandler(AnswerOptions.class);
	}
}