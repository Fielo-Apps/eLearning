@isTest
public with sharing class TestModuleController {
	@testSetup static void setup(){
        MockUpFactory.InsertTestData();
        MockUpFactory.activateCourse();
		
    }
	@isTest
	static void TestModuleController() {
	FieloELR__Module__c	 module = [SELECT Id FROM FieloELR__Module__c LIMIT 1];

	 SObject content = ModuleController.getContent(
	 	'Name'
	 	,'Id'
	 	,module.Id);
	}
}