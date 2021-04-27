trigger Answers on Answer__c (before insert, before update, before delete) {
	if( SObjectDomain.isHandlerActive('FieloELR__Answer__c')){
		SObjectDomain.triggerHandler(Answers.class);
	}
}