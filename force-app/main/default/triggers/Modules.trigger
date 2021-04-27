trigger Modules on Module__c (before insert, before update, after update, before delete) {
	if( SObjectDomain.isHandlerActive('FieloELR__Module__c')){
		SObjectDomain.triggerHandler(Modules.class);
	}
}