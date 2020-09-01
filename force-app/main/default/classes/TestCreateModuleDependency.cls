@isTest
private class TestCreateModuleDependency {

	private static List<FieloPLT__Program__c> listProg;
	private static List<FieloPLT__Segment__c> listSeg;
	private static List<FieloELR__Course__c> listCourse;
	private static List<FieloELR__Module__c> listMod = new List<FieloELR__Module__c>();
	private static List<FieloELR__ModuleDependency__c> listModDepen = new List<FieloELR__ModuleDependency__c>();

	private static FieloELR__ModuleDependency__c modDepen1 = new FieloELR__ModuleDependency__c();

	@testSetup static void setup() {
		//////PROGRAMS
		listProg = MockUpFactory.createPrograms('program', 1);

		insert listProg;

		//////SEGMENTS
		listSeg = MockUpFactory.createSegments('segment', 1, 'Dynamic');
		listSeg.get(0).FieloPLT__Program__c = listProg.get(0).Id;

		insert listSeg;

		///////COURSES
		listCourse = MockUpFactory.createCourses(listProg.get(0).Id, listSeg.get(0).Id, 2);

		insert listCourse;

		//////MODULES
		FieloELR__Module__c module1 = new FieloELR__Module__c();
		module1.Name = 'module1';
		module1.FieloELR__Course__c = listCourse.get(0).Id;
		module1.FieloELR__ApprovalGrade__c = 0;
		listMod.add(module1);

		FieloELR__Module__c module2 = new FieloELR__Module__c();
		module2.Name = 'module2';
		module2.FieloELR__Course__c = listCourse.get(0).Id;
		module2.FieloELR__ApprovalGrade__c = 0;
		listMod.add(module2);

		FieloELR__Module__c module3 = new FieloELR__Module__c();
		module3.Name = 'module3';
		module3.FieloELR__Course__c = listCourse.get(1).Id;
		module3.FieloELR__ApprovalGrade__c = 0;
		listMod.add(module3);

		FieloELR__Module__c module4 = new FieloELR__Module__c();
		module4.Name = 'module4';
		module4.FieloELR__Course__c = listCourse.get(1).Id;
		module4.FieloELR__ApprovalGrade__c = 0;
		listMod.add(module4);

		FieloELR__Module__c module5 = new FieloELR__Module__c();
		module5.Name = 'module5';
		module5.FieloELR__Course__c = listCourse.get(1).Id;
		module5.FieloELR__ApprovalGrade__c = 0;
		listMod.add(module5);

		insert listMod;

		//////MODULE DEPENDENCIES
		modDepen1.FieloELR__Module__c = listMod.get(2).Id;
		modDepen1.FieloELR__Predecessor__c = listMod.get(3).Id;
		listModDepen.add(modDepen1);

		insert listModDepen;
	}
	
	/*	TEST-1731
		Create Module Dependency - (OK)
	*/
	@isTest static void ELR_0004_FB() {
		modDepen1.FieloELR__Module__c = [SELECT Id FROM FieloELR__Module__c WHERE Name = 'module1' LIMIT 1].Id;
		modDepen1.FieloELR__Predecessor__c = [SELECT Id FROM FieloELR__Module__c WHERE Name = 'module2' LIMIT 1].Id;
		listModDepen.add(modDepen1);

		insert listModDepen;

		listModDepen = [SELECT Id FROM FieloELR__ModuleDependency__c WHERE Id IN :listModDepen LIMIT 1];

		System.assertEquals(1, listModDepen.size());
	}
	
	/*	TEST-1732
		Create Module Dependency
		- Validations
		- Module field is null (NOK)
	*/
	@isTest static void ELR_0004_FA1() {
		modDepen1.FieloELR__Predecessor__c = [SELECT Id FROM FieloELR__Module__c WHERE Name = 'module2' LIMIT 1].Id;
		listModDepen.add(modDepen1);

		try{
    		insert listModDepen;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('Both modules must belong to the same course.'));
		}
	}
	
	/*	TEST-1733
		Create Module Dependency
		- Validations
		- Predecessor field is null (NOK)
	*/
	@isTest static void ELR_0004_FA2() {
		modDepen1.FieloELR__Module__c = [SELECT Id FROM FieloELR__Module__c WHERE Name = 'module2' LIMIT 1].Id;
		listModDepen.add(modDepen1);

    	try{
    		insert listModDepen;
		} catch(System.DmlException d) {
			System.assert(d.getMessage().Contains('Both modules must belong to the same course.'));
		}
	}

	/*	TEST-1734
		Create Module Dependency
		- Validations
		- Module and Predecessor are the same (NOK)
	*/
	@isTest static void ELR_0004_FA3() {
		modDepen1.FieloELR__Module__c = [SELECT Id FROM FieloELR__Module__c WHERE Name = 'module1' LIMIT 1].Id;
		modDepen1.FieloELR__Predecessor__c = [SELECT Id FROM FieloELR__Module__c WHERE Name = 'module1' LIMIT 1].Id;
		listModDepen.add(modDepen1);

		try{
    		insert listModDepen;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('A module cannot be its own prerequisite'));
		}
	}

	/*	TEST-1735
		Create Module Dependency
		- Validations
		- Module and Predecessor are not related to the same course (NOK)
	*/
	@isTest static void ELR_0004_FA4(){
		modDepen1.FieloELR__Module__c = [SELECT Id FROM FieloELR__Module__c WHERE Name = 'module1' LIMIT 1].Id;
		modDepen1.FieloELR__Predecessor__c = [SELECT Id FROM FieloELR__Module__c WHERE Name = 'module3' LIMIT 1].Id;
		listModDepen.add(modDepen1);

		String errorMsg = '';
		try{
    		insert listModDepen;
		}catch(System.DmlException d){
			errorMsg = d.getMessage();
		}
		System.assert(errorMsg.Contains('Both modules must belong to the same course.'));
	}

	/*	TEST-1736
		Create Module Dependency
		- Validations
		- There is already a module dependency with the same modules (NOK)
	*/
	@isTest static void ELR_0004_FA5() {
		modDepen1.FieloELR__Module__c = [SELECT Id FROM FieloELR__Module__c WHERE Name = 'module3' LIMIT 1].Id;
		modDepen1.FieloELR__Predecessor__c = [SELECT Id FROM FieloELR__Module__c WHERE Name = 'module4' LIMIT 1].Id;
		listModDepen.add(modDepen1);
		System.debug(listModDepen);

		String errorMsg = '';
		try{
    		insert listModDepen;
		}catch(System.DmlException d){
			errorMsg = d.getMessage();
		}
		System.debug(errorMsg);
		System.assert(!errorMsg.Contains('This module dependency already exists.'));
	}

	/*	TEST-1737
		Create Module Dependency
		- Edit a module dependency (OK)
	*/
	@isTest static void ELR_0004_FA6(){
		listModDepen = [SELECT Id, FieloELR__Module__c FROM FieloELR__ModuleDependency__c WHERE FieloELR__Module__r.Name = 'module3' LIMIT 1];
		listModDepen.get(0).FieloELR__Module__c = [SELECT Id FROM FieloELR__Module__c WHERE Name = 'module5' LIMIT 1].Id;

		update listModDepen;

		listModDepen = [SELECT FieloELR__Module__c FROM FieloELR__ModuleDependency__c WHERE FieloELR__Module__r.Name = 'module5' LIMIT 1];

		System.assertEquals(1, listModDepen.size());
	}
}