trigger AnswerOptions on AnswerOption__c (before insert, before update, before delete) {
	SObjectDomain.triggerHandler(AnswerOptions.class);
}