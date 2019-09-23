@isTest
private class TestCreateCourseDependency {

	private static List<FieloPLT__Program__c> listProg;
	private static List<FieloPLT__Segment__c> listSeg;
	private static List<FieloELR__Course__c> listCourse;
	private static List<FieloELR__CourseDependency__c> listCourseDepen = new List<FieloELR__CourseDependency__c>();

	private static FieloELR__CourseDependency__c courseDepen1 = new FieloELR__CourseDependency__c();

	@testSetup static void setup(){

		//////PROGRAMS
		listProg = MockUpFactory.createPrograms('program', 2);

		insert listProg;

		//////SEGMENTS
		listSeg = MockUpFactory.createSegments('segment', 2, 'Dynamic');
		listSeg.get(0).FieloPLT__Program__c = listProg.get(0).Id;
		listSeg.get(1).FieloPLT__Program__c = listProg.get(1).Id;

		insert listSeg;

		///////COURSES
		listCourse = MockUpFactory.createCourses(listProg.get(0).Id, listSeg.get(0).Id, 5);
		listCourse.get(0).FieloELR__Description__c = 'Course 1';
		listCourse.get(1).FieloELR__Description__c = 'Course 2';
		listCourse.get(2).FieloELR__Program__c = listProg.get(1).Id;
		listCourse.get(2).FieloELR__Segment__c = listSeg.get(1).Id;
		listCourse.get(2).FieloELR__Description__c = 'Course 3';
		listCourse.get(3).FieloELR__Program__c = listProg.get(1).Id;
		listCourse.get(3).FieloELR__Segment__c = listSeg.get(1).Id;
		listCourse.get(3).FieloELR__Description__c = 'Course 4';
		listCourse.get(4).FieloELR__Program__c = listProg.get(1).Id;
		listCourse.get(4).FieloELR__Segment__c = listSeg.get(1).Id;
		listCourse.get(4).FieloELR__Description__c = 'Course 5';

		insert listCourse;

		///////COURSE DEPENDENCIES
		courseDepen1.FieloELR__Course__c = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Description__c = 'Course 4' LIMIT 1].Id;
		courseDepen1.FieloELR__Predecessor__c = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Description__c = 'Course 3' LIMIT 1].Id;
		listCourseDepen.add(courseDepen1);

		insert listCourseDepen;
	}
	
	/*	TEST-1681
		Create Course Dependency - (OK)
	*/
	@isTest static void ELR_0002_FB() {
		courseDepen1.FieloELR__Course__c = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Description__c = 'Course 2' LIMIT 1].Id;
		courseDepen1.FieloELR__Predecessor__c = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Description__c = 'Course 1' LIMIT 1].Id;
		listCourseDepen.add(courseDepen1);

		insert listCourseDepen;

		listCourseDepen = [SELECT Id FROM FieloELR__CourseDependency__c WHERE Id IN :listCourseDepen LIMIT 1];

		System.assertEquals(1, listCourseDepen.size());
	}
	
	/*	TEST-1682
		Create Course Dependency
		- Validations
		- Course field is null (NOK)
	*/
	@isTest static void ELR_0002_FA1() {
		courseDepen1.FieloELR__Predecessor__c = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Description__c = 'Course 1' LIMIT 1].Id;
		listCourseDepen.add(courseDepen1);

		try{
    		insert listCourseDepen;
		}catch(System.DmlException d){
			System.debug(d.getMessage());
			System.assert(d.getMessage().Contains(Label.CourseRequiredField));
		}
	}
	
	/*	TEST-1683
		Create Course Dependency
		- Validations
		- Predecessor field is null (NOK)
	*/
	@isTest static void ELR_0002_FA2() {
		courseDepen1.FieloELR__Course__c = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Description__c = 'Course 2' LIMIT 1].Id;
		listCourseDepen.add(courseDepen1);

		try{
    		insert listCourseDepen;
		}catch(System.DmlException d){
			System.debug(d.getMessage());
			System.assert(d.getMessage().Contains(Label.PredecessorRequired));
		}
	}

	/*	TEST-1684
		Create Course Dependency
		- Validations
		- Course and Predecessor are the same (NOK)
	*/
	@isTest static void ELR_0002_FA3() {
		
		courseDepen1.FieloELR__Course__c = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Description__c = 'Course 1' LIMIT 1].Id;
		courseDepen1.FieloELR__Predecessor__c = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Description__c = 'Course 1' LIMIT 1].Id;
		listCourseDepen.add(courseDepen1);

		try{
    		insert listCourseDepen;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('Course and Prerequisite must be different'));
		}
	}

	/*	TEST-1685
		Create Course Dependency
		- Validations
		- Course and Predecessor are not related to the same program (NOK)
	*/
	@isTest static void ELR_0002_FA4() {
		
		courseDepen1.FieloELR__Course__c = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Description__c = 'Course 3' LIMIT 1].Id;
		courseDepen1.FieloELR__Predecessor__c = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Description__c = 'Course 1' LIMIT 1].Id;
		listCourseDepen.add(courseDepen1);

		try{
    		insert listCourseDepen;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('Course and Prerequisite must belong to the same Program'));
		}
	}

	/*	TEST-1686
		Create Course Dependency
		- Validations
		- There is already a course dependency with the same courses (NOK)
	*/
	@isTest	static void ELR_0002_FA5(){

		courseDepen1.FieloELR__Course__c = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Description__c = 'Course 4' LIMIT 1].Id;
		courseDepen1.FieloELR__Predecessor__c = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Description__c = 'Course 3' LIMIT 1].Id;
		listCourseDepen.add(courseDepen1);

		try{
    		insert listCourseDepen;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('This course dependency already exists.'));
		}
	}

	/*	TEST-1687
		Create Course Dependency
		- Edit a course dependency (OK)
	*/
	@isTest	static void ELR_0002_FA6(){

		courseDepen1 = [SELECT Id FROM FieloELR__CourseDependency__c WHERE FieloELR__Course__r.FieloELR__Description__c = 'Course 4' LIMIT 1];
		courseDepen1.FieloELR__Course__c = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Description__c = 'Course 5' LIMIT 1].Id;
		listCourseDepen.add(courseDepen1);

		update listCourseDepen;

		listCourseDepen = [SELECT FieloELR__Course__c FROM FieloELR__CourseDependency__c WHERE FieloELR__Course__r.FieloELR__Description__c = 'Course 5' LIMIT 1];

		System.assertEquals(1, listCourseDepen.size());
	}
}