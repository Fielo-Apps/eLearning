trigger Questions on Question__c (before insert, before update, before delete, after insert, after update) {
	if( SObjectDomain.isHandlerActive('FieloELR__Question__c')){
		SObjectDomain.triggerHandler(Questions.class);
	}
}