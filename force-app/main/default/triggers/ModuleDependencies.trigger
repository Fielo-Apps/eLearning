trigger ModuleDependencies on ModuleDependency__c (before insert, before update, after insert, after delete) {
	if( SObjectDomain.isHandlerActive('FieloELR__ModuleDependency__c')){
		SObjectDomain.triggerHandler(ModuleDependencies.class);
	}
}