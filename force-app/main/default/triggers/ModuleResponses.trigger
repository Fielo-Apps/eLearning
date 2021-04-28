trigger ModuleResponses on ModuleResponse__c (before insert, after insert, before update, after update, before delete, after delete) {
	if( SObjectDomain.isHandlerActive(FieloPLT__Triggers__c.ModuleResponse__c)){
		SObjectDomain.triggerHandler(ModuleResponses.class);
	}
}