trigger QuestionResponses on QuestionResponse__c (before insert, after insert, before update, after update, before delete, after delete) {
	if( SObjectDomain.isHandlerActive(FieloPLT__Triggers__c.QuestionResponse__c)){
		SObjectDomain.triggerHandler(QuestionResponses.class);
	}
}