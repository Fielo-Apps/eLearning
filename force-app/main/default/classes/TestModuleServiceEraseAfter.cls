@isTest
public with sharing class TestModuleServiceEraseAfter {
	@isTest
	static void TestModuleServiceEraseAfter() {
		MockUpFactory.InsertTestData();

		List<FieloPLT__Program__c> programs = [SELECT Id FROM FieloPLT__Program__c];

		List<FieloELR__Module__c> modules = [SELECT Id, IsActive__c FROM Module__c];
		modules.get(0).IsActive__c = true;
		upsert modules.get(0);

		FieloELR__Module__c module;
		if(!modules.isEmpty()){
			module = modules.get(0);
		}

		System.assertEquals(true, modules.get(0).IsActive__c);

		List<FieloELR__Course__c> courses = new List<FieloELR__Course__c>();
		courses = [SELECT Id, Status__c,Segment__c FROM Course__c WHERE Program__c =: programs.get(0).id];
		courses.get(0).Status__c = 'Active';
		courses.get(0).Segment__c = null;
		update courses;

		System.assertEquals('Active', courses.get(0).Status__c);

 		//Members
 		List<FieloPLT__Member__c> members = new List<FieloPLT__Member__c>();
 		members = [SELECT Id FROM FieloPLT__Member__c WHERE FieloPLT__Program__c =: programs.get(0).id];
        update members;

		FieloPLT__Member__c member;
		if(!members.isEmpty()){
			member = members.get(0);
		}

		FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c();
        courseStatus.FieloELR__Member__c = member.id;
        courseStatus.FieloELR__Course__c = courses.get(0).id;
        insert courseStatus;

		Set<String> fldModule = new Set<String>{'FieloELR__Content__c'};
		Set<String> fldQuestion = new Set<String>{'FieloELR__CorrectAnswerOptions__c'};
		Set<String> fldAnsOpt = new Set<String>{'FieloELR__AnswerOptionText__c'};





		ModuleService.ModuleWrapper modWrapper = ModuleService.takeModule(
			module.id
			,member.id
			,fldModule
			,fldQuestion
			,fldAnsOpt);

	}
}