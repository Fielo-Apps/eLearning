@isTest
public with sharing class TestModuleResponseController {

	@isTest
	static void TestModuleResponseController() {
		MockUpFactory.InsertTestData();
        MockUpFactory.activateCourse();
		List<FieloPLT__Program__c> programs = [SELECT Id FROM FieloPLT__Program__c LIMIT 1];

		//Course
		FieloELR__Course__c course = [SELECT Id, FieloELR__Program__c FROM FieloELR__Course__c  WHERE Program__c =: programs.get(0).id LIMIT 1];


		//Module
		FieloELR__Module__c module = [SELECT Id FROM FieloELR__Module__c WHERE FieloELR__Course__c =: course.Id LIMIT 1];
		//Member
		FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE FieloPLT__Program__c =: course.Program__c LIMIT 1];
		//Course Status
		FieloELR__CourseStatus__c courseSt = new FieloELR__CourseStatus__c(
		Member__c = member.id
		,Course__c = course.id);
		insert courseSt;

		//ModuleResponse
		FieloELR__ModuleResponse__c modResponse = new FieloELR__ModuleResponse__c(
			Member__c = member.Id
			,Module__c = module.Id
			,CourseStatus__c = courseSt.Id);
		insert modResponse;


		String getModResp = ModuleResponseController.getModuleResponse(
			modResponse.Id
			,new List<String>{
				'Name'
				});

		Map<String, String> mapFields = new Map<String, String>{'Name' => 'Modules'};

		mapFields = ModuleResponseController.getFieldLabels();
	}
}