trigger Questions on Question__c (before insert, before update, before delete, after insert, after update) {
	SObjectDomain.triggerHandler(Questions.class);
}