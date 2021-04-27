trigger Questions on Question__c (before insert, before update, before delete, after insert, after update) {
	if( SObjectDomain.isHandlerActive(FieloPLT__Triggers__c.Question__c)){
		SObjectDomain.triggerHandler(Questions.class);
	}
}