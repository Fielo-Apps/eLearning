trigger Answers on Answer__c (before insert, before update, before delete) {
	if( SObjectDomain.isHandlerActive(FieloPLT__Triggers__c.Answer__c)){
		SObjectDomain.triggerHandler(Answers.class);
	}
}