trigger ModuleDependencies on ModuleDependency__c (before insert, before update, after insert, after delete) {
	if( SObjectDomain.isHandlerActive(FieloPLT__Triggers__c.ModuleDependency__c)){
		SObjectDomain.triggerHandler(ModuleDependencies.class);
	}
}