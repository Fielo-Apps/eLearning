trigger Modules on Module__c (before insert, before update, after update, before delete) {
	if( SObjectDomain.isHandlerActive(FieloPLT__Triggers__c.Module__c)){
		SObjectDomain.triggerHandler(Modules.class);
	}
}