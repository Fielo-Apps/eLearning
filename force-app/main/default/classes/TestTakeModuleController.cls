@isTest
public with sharing class TestTakeModuleController {
	
@testSetup static void setup(){
        MockUpFactory.InsertTestData();
        MockUpFactory.activateCourse();		
    }

	@isTest
	static void TestTakeModuleController() {
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

	String mmbTkModule = TakeModuleController.memberTakeModule(
		member.Id
		,module.Id);
		
	}
}