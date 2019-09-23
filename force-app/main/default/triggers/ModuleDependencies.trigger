trigger ModuleDependencies on ModuleDependency__c (before insert, before update, after insert, after delete) {
	SObjectDomain.triggerHandler(ModuleDependencies.class);
}