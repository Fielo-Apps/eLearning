@isTest
private class TestCreateAnswer{
	
	private static List<FieloPLT__Program__c> listProg;
	private static List<FieloPLT__Segment__c> listSeg;
	private static List<FieloELR__Course__c> listCourse;
	private static List<FieloPLT__Member__c> listMember;
	private static List<FieloELR__Module__c> listMod = new List<FieloELR__Module__c>();
	private static List<FieloELR__Question__c> listQuest = new List<FieloELR__Question__c>();
	private static List<FieloELR__AnswerOption__c> listAnsOpt = new List<FieloELR__AnswerOption__c>();

	private static FieloELR__AnswerOption__c answers1 = new FieloELR__AnswerOption__c();
	private static FieloELR__AnswerOption__c answers2 = new FieloELR__AnswerOption__c();
	private static FieloELR__AnswerOption__c answers3 = new FieloELR__AnswerOption__c();
	private static FieloELR__AnswerOption__c answers4 = new FieloELR__AnswerOption__c();
	private static FieloELR__AnswerOption__c answers5 = new FieloELR__AnswerOption__c();
	private static FieloELR__AnswerOption__c answers6 = new FieloELR__AnswerOption__c();

	@testSetup static void setup(){

		//////PROGRAMS
		listProg = MockUpFactory.createPrograms('program', 1);

		insert listProg;

		//////SEGMENTS
		listSeg = MockUpFactory.createSegments('segment', 1, 'Manual');
		listSeg.get(0).FieloPLT__Program__c = listProg.get(0).Id;

		insert listSeg;

		///////COURSES
		listCourse = MockUpFactory.createCourses(listProg.get(0).Id, listSeg.get(0).Id, 1);

		insert listCourse;

		listMember = MockUpFactory.createMembers(listProg.get(0).Id,1);
		
		insert listMember;

		insert new FieloPLT__MemberSegment__c(
			FieloPLT__Member__c = listMember.get(0).Id,
			FieloPLT__Segment__c = listSeg.get(0).Id,
			FieloPLT__MemberSegmentCombination__c = '' + listMember.get(0).Id + '' + listSeg.get(0).Id
		);

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

		insert listMod;

		/////QUESTIONS
		FieloELR__Question__c question1 = new FieloELR__Question__c();
		question1.Name = 'multiple choice 1';
		question1.FieloELR__Module__c = module1.Id;
		question1.FieloELR__QuestionText__c = 'How are you?';
		question1.FieloELR__Type__c = 'Multiple Choice';
		listQuest.add(question1);

		FieloELR__Question__c question2 = new FieloELR__Question__c();
		question2.Name = 'short answer 1';
		question2.FieloELR__Module__c = module2.Id;
		question2.FieloELR__QuestionText__c = 'How are you?';
		question2.FieloELR__Type__c = 'Short Answer';
		listQuest.add(question2);

		FieloELR__Question__c question3 = new FieloELR__Question__c();
		question3.Name = 'single choice 1';
		question3.FieloELR__Module__c = module1.Id;
		question3.FieloELR__QuestionText__c = 'How are you?';
		question3.FieloELR__Type__c = 'Single Choice';
		listQuest.add(question3);

		FieloELR__Question__c question4 = new FieloELR__Question__c();
		question4.Name = 'short answer 2';
		question4.FieloELR__Module__c = module1.Id;
		question4.FieloELR__QuestionText__c = 'How are you?';
		question4.FieloELR__Type__c = 'Short Answer';
		listQuest.add(question4);

		FieloELR__Question__c question5 = new FieloELR__Question__c();
		question5.Name = 'statement 1';
		question5.FieloELR__Module__c = module1.Id;
		question5.FieloELR__QuestionText__c = 'How are you?';
		question5.FieloELR__Type__c = 'Statement';
		listQuest.add(question5);

		FieloELR__Question__c question6 = new FieloELR__Question__c();
		question6.Name = 'matching options 1';
		question6.FieloELR__Module__c = module1.Id;
		question6.FieloELR__QuestionText__c = 'How are you?';
		question6.FieloELR__Type__c = 'Matching Options';
		listQuest.add(question6);

		FieloELR__Question__c question7 = new FieloELR__Question__c();
		question7.Name = 'statement 2';
		question7.FieloELR__Module__c = module1.Id;
		question7.FieloELR__QuestionText__c = 'How are you?';
		question7.FieloELR__Type__c = 'Statement';
		listQuest.add(question7);

		FieloELR__Question__c question8 = new FieloELR__Question__c();
		question8.Name = 'single choice 2';
		question8.FieloELR__Module__c = module1.Id;
		question8.FieloELR__QuestionText__c = 'How are you?';
		question8.FieloELR__Type__c = 'Single Choice';
		listQuest.add(question8);

		FieloELR__Question__c question9 = new FieloELR__Question__c();
		question9.Name = 'statement 3';
		question9.FieloELR__Module__c = module1.Id;
		question9.FieloELR__QuestionText__c = 'How are you?';
		question9.FieloELR__Type__c = 'Statement';
		listQuest.add(question9);

		insert listQuest;

		//////ANSWERS
		answers1.FieloELR__Question__c = question2.Id;
		answers1.FieloELR__IsCorrect__c = true;
		answers1.FieloELR__AnswerOptionText__c = 'Esta es correcta y activa';
		listAnsOpt.add(answers1);

		answers2.FieloELR__Question__c = question7.Id;
		answers2.FieloELR__AnswerOptionText__c = 'Esta es incorrecta y de Statement';
		listAnsOpt.add(answers2);

		answers3.FieloELR__Question__c = question7.Id;
		answers3.FieloELR__AnswerOptionText__c = 'Esta es la segunda incorrecta y de Statement';
		listAnsOpt.add(answers3);

		answers4.FieloELR__Question__c = question8.Id;
		answers4.FieloELR__IsCorrect__c = true;
		answers4.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		listAnsOpt.add(answers4);

		answers5.FieloELR__Question__c = question9.Id;
		answers5.FieloELR__IsCorrect__c = true;
		answers5.FieloELR__AnswerOptionText__c = 'Esta es correcta y del segundo Statement';
		listAnsOpt.add(answers5);

		answers6.FieloELR__Question__c = question9.Id;
		answers6.FieloELR__AnswerOptionText__c = 'Esta es incorrecta y del segundo Statement';
		listAnsOpt.add(answers6);

		insert listAnsOpt;


		//////MODULE UPDATE
		module2.FieloELR__IsActive__c = true;
		update listMod;
	}

	/*	TEST-1763
		Create Answer Option
		- Related question type is “Multiple Choice” (OK)
	*/
	@isTest	static void ELR_0006_FB(){

		answers1.FieloELR__AnswerOptionText__c = 'Esta es incorrecta';
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name = 'multiple choice 1' LIMIT 1].Id;
		answers1.FieloELR__Order__c = 1;
		listAnsOpt.add(answers1);

		answers2.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		answers2.FieloELR__Question__c = answers1.FieloELR__Question__c;
		answers2.FieloELR__Order__c = 2;
		answers2.FieloELR__IsCorrect__c = true;
		listAnsOpt.add(answers2);

		insert listAnsOpt;

		listAnsOpt = [SELECT Id FROM FieloELR__AnswerOption__c WHERE Id IN :listAnsOpt];

		System.assertEquals(2, listAnsOpt.size());
	}

	/*	TEST-1768
		Create Answer Option
		- Related question type is “Single Choice” and no other answer option was defined as correct (OK)
	*/
	@isTest	static void ELR_0006_FA9(){
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name = 'single choice 1' LIMIT 1].Id;
		answers1.FieloELR__AnswerOptionText__c = 'No tiene respuesta';
		answers1.FieloELR__Order__c = 1;
		listAnsOpt.add(answers1);

		insert listAnsOpt;

		listAnsOpt = [SELECT FieloELR__IsCorrect__c FROM FieloELR__AnswerOption__c WHERE Id IN :listAnsOpt];

		System.assert(!listAnsOpt.get(0).FieloELR__IsCorrect__c);
	}

	/*	TEST-1915
		Create Answer Option
		- Validations
		- Related question type is “Statement” with already another answer option defined as correct (NOK)
	*/
	@isTest static void ELR_0006_FA8(){

		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name = 'statement 1' LIMIT 1].Id;
		answers1.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		answers1.FieloELR__IsCorrect__c = true;
		answers1.FieloELR__Order__c = 1;

		insert answers1;

		answers2.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name = 'statement 1' LIMIT 1].Id;
		answers2.FieloELR__AnswerOptionText__c = 'Esta tambien es correcta';
		answers2.FieloELR__IsCorrect__c = true;
		answers2.FieloELR__Order__c = 2;

		try{
			insert answers2;
		} catch (Exception e) {}

		listAnsOpt = [SELECT FieloELR__IsCorrect__c FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = :answers1.FieloELR__Question__c];

		System.assertEquals(1, listAnsOpt.size());
	}

	/*	TEST-1914
		Create Answer Option
		- Related question type is “Statement” without no other answer option defined as correct (OK)
	*/
	@isTest static void ELR_0006_FA7(){
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name = 'statement 1' LIMIT 1].Id;
		answers1.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		answers1.FieloELR__Order__c = 1;
		listAnsOpt.add(answers1);

		insert listAnsOpt;

		listAnsOpt = [SELECT Id FROM FieloELR__AnswerOption__c WHERE Id IN :listAnsOpt];

		System.assertEquals(1, listAnsOpt.size());
	}

	/*	TEST-1767
		Create Answer Option
		- Validations
		- Related question type is “Statement” with already two answer options (NOK)
	*/
	@isTest static void ELR_0006_FA6(){
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='statement 1' LIMIT 1].Id;
		answers1.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		answers1.FieloELR__Order__c = 1;
		answers1.FieloELR__IsCorrect__c = true;

		answers2.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='statement 1' LIMIT 1].Id;
		answers2.FieloELR__AnswerOptionText__c = 'Esta es incorrecta';
		answers2.FieloELR__Order__c = 1;
		answers2.FieloELR__IsCorrect__c = false;

		listAnsOpt.add(answers1);
		listAnsOpt.add(answers2);

		insert listAnsOpt;
		
		answers3.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='statement 1' LIMIT 1].Id;
		answers3.FieloELR__AnswerOptionText__c = 'Esta es incorrecta';
		answers3.FieloELR__Order__c = 1;
		answers3.FieloELR__IsCorrect__c = false;

		try{
			insert answers3;
		} catch (Exception e) {}

		listAnsOpt = [SELECT Id, Name FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = :answers1.FieloELR__Question__c];

		System.assertEquals(2,listAnsOpt.size());
	}

	/*	TEST-1913
		Create Answer Option
		- Related question type is “Statement” without its two answer options (OK)
	*/
	@isTest static void ELR_0006_FA5(){
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='statement 1' LIMIT 1].Id;
		answers1.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		answers1.FieloELR__Order__c = 1;
		answers1.FieloELR__IsCorrect__c = true;
		listAnsOpt.add(answers1);

		insert listAnsOpt;

		listAnsOpt = [SELECT Id FROM FieloELR__AnswerOption__c WHERE Id IN :listAnsOpt];

		System.assertEquals(1, listAnsOpt.size());
	}

	/*	TEST-1766
		Create Answer Option - The Order field is null (OK)
	*/
	@isTest static void ELR_0006_FA4(){
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name = 'statement 1' LIMIT 1].Id;
		answers1.FieloELR__AnswerOptionText__c = 'Esta respuesta esta de mas';
		listAnsOpt.add(answers1);

		insert listAnsOpt;
		
		listAnsOpt = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = : answers1.FieloELR__Question__c];

		System.assertEquals(1, listAnsOpt.size());
	}

	/*	TEST-1765
		Create Answer Option
		- Validations
		- The Answer Option Text is null (NOK)
	*/
	@isTest static void ELR_0006_FA3(){
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name = 'statement 1' LIMIT 1].Id;
		answers1.FieloELR__Order__c = 1;
		listAnsOpt.add(answers1);

		try {
			insert listAnsOpt;
		} catch (Exception e) {}
		
		listAnsOpt = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = : answers1.FieloELR__Question__c];

		System.assertEquals(0, listAnsOpt.size());
	}

	/*	TEST-1778
		Create Answer Option
		- Validations
		- Set correct answer option for question Type “Statement” when another answer option is defined as correct (NOK)
	*/
	@isTest static void ELR_0006_FA22() {
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='statement 1' LIMIT 1].Id;
		answers1.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		answers1.FieloELR__Order__c = 1;
		answers1.FieloELR__IsCorrect__c = true;

		answers2.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='statement 1' LIMIT 1].Id;
		answers2.FieloELR__AnswerOptionText__c = 'Esta es incorrecta';
		answers2.FieloELR__Order__c = 1;
		answers2.FieloELR__IsCorrect__c = false;

		listAnsOpt.add(answers1);
		listAnsOpt.add(answers2);

		insert listAnsOpt;
		
		answers2.FieloELR__IsCorrect__c = true;

		try{
			update answers2;
		} catch (Exception e) {}

		listAnsOpt = [SELECT Id, Name FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = :answers1.FieloELR__Question__c AND FieloELR__IsCorrect__c = true];

		System.assertEquals(1,listAnsOpt.size());
	}

	/*	TEST-1777
		Create Answer Option
		- Set correct answer option for question Type “Statement” when no other answer option is defined as correct (OK)
	*/
	@isTest static void ELR_0006_FA21() {
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='statement 1' LIMIT 1].Id;
		answers1.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		answers1.FieloELR__Order__c = 1;
		answers1.FieloELR__IsCorrect__c = false;

		answers2.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='statement 1' LIMIT 1].Id;
		answers2.FieloELR__AnswerOptionText__c = 'Esta es incorrecta';
		answers2.FieloELR__Order__c = 1;
		answers2.FieloELR__IsCorrect__c = false;

		listAnsOpt.add(answers1);
		listAnsOpt.add(answers2);

		insert listAnsOpt;
		
		answers1.FieloELR__IsCorrect__c = true;

		update answers1;

		listAnsOpt = [SELECT Id, Name FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = :answers1.FieloELR__Question__c AND FieloELR__IsCorrect__c = true];

		System.assertEquals(1,listAnsOpt.size());
	}

	/*	TEST-1917
		Create Answer Option
		- Edit answer option when related module is inactive and the related question has question response (NOK)
	*/
	@isTest static void ELR_0006_FA20() {
		FieloPLT__Member__c member = [Select Id, Name From FieloPLT__Member__c LIMIT 1];
		FieloELR__Course__c course = [Select Id, Name From FieloELR__Course__c LIMIT 1];
		FieloELR__Module__c module = [Select Id, Name From FieloELR__Module__c Where Name = 'module2' LIMIT 1];
		FieloELR__Question__c question = [Select Id, Name From FieloELR__Question__c Where FieloELR__Module__r.Name = 'module2' AND Name = 'short answer 1' LIMIT 1];

		course.FieloELR__Status__c = 'Active';
		
		Courses.validateAdminFields = false;

		update course;

		Courses.validateAdminFields = true;

		course = [Select Id, Name, FieloELR__Status__c From FieloELR__Course__c LIMIT 1];

		System.debug( course.FieloELR__Status__c );

		FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c(
			FieloELR__Member__c = member.Id,
			FieloELR__Course__c = course.Id
		);

		insert courseStatus;

		FieloELR__ModuleResponse__c moduleResponse = new FieloELR__ModuleResponse__c(
			FieloELR__Member__c = member.Id,
			FieloELR__Module__c = module.Id,
			FieloELR__CourseStatus__c = courseStatus.Id
		);

		insert moduleResponse;

		FieloELR__QuestionResponse__c questionResponse = new FieloELR__QuestionResponse__c(
			FieloELR__Question__c = question.Id,
			FieloELR__ModuleResponse__c = moduleResponse.Id
		);

		insert questionResponse;

		course.FieloELR__Status__c = 'Inactive';
		module.FieloELR__IsActive__c = false;

		Courses.validateAdminFields = false;
		update course;
		Courses.validateAdminFields = true;

		Modules.validateAdminFields = false;
		update module;
		Modules.validateAdminFields = true;

		answers1 = [SELECT Id, Name, FieloELR__Order__c FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = :question.Id LIMIT 1];
		answers1.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		answers1.FieloELR__Order__c = 6;
		answers1.FieloELR__IsCorrect__c = true;

		try{
			update answers1;
		} catch (Exception e) {System.debug(e.getMessage());}

		System.assertEquals(1, [SELECT Id, Name, FieloELR__Order__c FROM FieloELR__AnswerOption__c WHERE Id = :answers1.Id LIMIT 1].FieloELR__Order__c);
	}

	/*	TEST-1912
		Create Answer Option
		- Validations
		- The related module has a module response (NOK)
	*/
	@isTest static void ELR_0006_FA2(){
		FieloPLT__Member__c member = [Select Id, Name From FieloPLT__Member__c LIMIT 1];
		FieloELR__Course__c course = [Select Id, Name From FieloELR__Course__c LIMIT 1];
		FieloELR__Module__c module = [Select Id, Name From FieloELR__Module__c Where Name = 'module2' LIMIT 1];
		FieloELR__Question__c question = [Select Id, Name From FieloELR__Question__c Where FieloELR__Module__r.Name = 'module2' AND Name = 'short answer 1' LIMIT 1];

		course.FieloELR__Status__c = 'Active';
		
		Courses.validateAdminFields = false;

		update course;

		Courses.validateAdminFields = true;

		course = [Select Id, Name, FieloELR__Status__c From FieloELR__Course__c LIMIT 1];

		System.debug( course.FieloELR__Status__c );

		FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c(
			FieloELR__Member__c = member.Id,
			FieloELR__Course__c = course.Id
		);

		insert courseStatus;

		FieloELR__ModuleResponse__c moduleResponse = new FieloELR__ModuleResponse__c(
			FieloELR__Member__c = member.Id,
			FieloELR__Module__c = module.Id,
			FieloELR__CourseStatus__c = courseStatus.Id
		);

		insert moduleResponse;

		course.FieloELR__Status__c = 'Inactive';
		module.FieloELR__IsActive__c = false;

		Courses.validateAdminFields = false;
		update course;
		Courses.validateAdminFields = true;

		Modules.validateAdminFields = false;
		update module;
		Modules.validateAdminFields = true;

		answers1.FieloELR__Question__c = question.Id;
		answers1.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		answers1.FieloELR__Order__c = 1;
		answers1.FieloELR__IsCorrect__c = true;

		try{
			insert answers1;
		} catch (Exception e) {System.debug(e.getMessage());}

		System.assert(answers1.Id == null);
	}

	/*	TEST-1775
		Create Answer Option
		- Edit answer option when related module is inactive and the related question does not have question response (OK)
	*/
	@isTest static void ELR_0006_FA19(){
		FieloPLT__Member__c member = [Select Id, Name From FieloPLT__Member__c LIMIT 1];
		FieloELR__Course__c course = [Select Id, Name From FieloELR__Course__c LIMIT 1];
		FieloELR__Module__c module = [Select Id, Name From FieloELR__Module__c Where Name = 'module2' LIMIT 1];
		FieloELR__Question__c question = [Select Id, Name From FieloELR__Question__c Where FieloELR__Module__r.Name = 'module2' AND Name = 'short answer 1' LIMIT 1];

		course.FieloELR__Status__c = 'Active';
		
		Courses.validateAdminFields = false;

		update course;

		Courses.validateAdminFields = true;

		course.FieloELR__Status__c = 'Inactive';
		module.FieloELR__IsActive__c = false;

		Courses.validateAdminFields = false;
		update course;
		Courses.validateAdminFields = true;

		Modules.validateAdminFields = false;
		update module;
		Modules.validateAdminFields = true;

		answers1 = [SELECT Id, Name, FieloELR__Order__c FROM FieloELR__AnswerOption__c Where FieloELR__Question__c = :question.Id LIMIT 1];
		answers1.FieloELR__Order__c = 9;

		try{
			update answers1;
		} catch (Exception e) {System.debug(e.getMessage());}

		System.assertEquals(9, [SELECT Id, Name, FieloELR__Order__c FROM FieloELR__AnswerOption__c WHERE Id = :answers1.Id LIMIT 1].FieloELR__Order__c);
	}

	/*	TEST-1776
		Create Answer Option
		- Validations
		- Edit answer option when related module is active (NOK)
	*/
	@isTest static void ELR_0006_FA18() {
		FieloPLT__Member__c member = [Select Id, Name From FieloPLT__Member__c LIMIT 1];
		FieloELR__Course__c course = [Select Id, Name From FieloELR__Course__c LIMIT 1];
		FieloELR__Module__c module = [Select Id, Name From FieloELR__Module__c Where Name = 'module2' LIMIT 1];
		FieloELR__Question__c question = [Select Id, Name From FieloELR__Question__c Where FieloELR__Module__r.Name = 'module2' AND Name = 'short answer 1' LIMIT 1];

		answers1 = [SELECT Id, Name, FieloELR__Order__c FROM FieloELR__AnswerOption__c Where FieloELR__Question__c = :question.Id LIMIT 1];
		Decimal oldOrder = answers1.FieloELR__Order__c;
		answers1.FieloELR__Order__c = 9;

		try{
			update answers1;
		} catch (Exception e) {System.debug(e.getMessage());}

		System.assertEquals(oldOrder, [SELECT Id, Name, FieloELR__Order__c FROM FieloELR__AnswerOption__c WHERE Id = :answers1.Id LIMIT 1].FieloELR__Order__c);
	}

	/*	TEST-1774
		Create Answer Option
		- Validations
		- Delete answer option when related module is active (NOK)
	*/
	@isTest static void ELR_0006_FA17() {
		FieloPLT__Member__c member = [Select Id, Name From FieloPLT__Member__c LIMIT 1];
		FieloELR__Course__c course = [Select Id, Name From FieloELR__Course__c LIMIT 1];
		FieloELR__Module__c module = [Select Id, Name From FieloELR__Module__c Where Name = 'module2' LIMIT 1];
		FieloELR__Question__c question = [Select Id, Name From FieloELR__Question__c Where FieloELR__Module__r.Name = 'module2' AND Name = 'short answer 1' LIMIT 1];

		answers1 = [SELECT Id, Name, FieloELR__Order__c FROM FieloELR__AnswerOption__c Where FieloELR__Question__c = :question.Id LIMIT 1];
		try{
			delete answers1;
		} catch (Exception e) {System.debug(e.getMessage());}

		System.assertEquals(1, [SELECT Id, Name, FieloELR__Order__c FROM FieloELR__AnswerOption__c WHERE Id = :answers1.Id].size());
	}

	/*	TEST-1916
		Create Answer Option
		- Delete answer option when related module is not active and the related question have a question response (NOK)
	*/
	@isTest static void ELR_0006_FA16() {
		FieloPLT__Member__c member = [Select Id, Name From FieloPLT__Member__c LIMIT 1];
		FieloELR__Course__c course = [Select Id, Name From FieloELR__Course__c LIMIT 1];
		FieloELR__Module__c module = [Select Id, Name From FieloELR__Module__c Where Name = 'module2' LIMIT 1];
		FieloELR__Question__c question = [Select Id, Name From FieloELR__Question__c Where FieloELR__Module__r.Name = 'module2' AND Name = 'short answer 1' LIMIT 1];

		course.FieloELR__Status__c = 'Active';
		
		Courses.validateAdminFields = false;

		update course;

		Courses.validateAdminFields = true;

		course = [Select Id, Name, FieloELR__Status__c From FieloELR__Course__c LIMIT 1];

		System.debug( course.FieloELR__Status__c );

		FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c(
			FieloELR__Member__c = member.Id,
			FieloELR__Course__c = course.Id
		);

		insert courseStatus;

		FieloELR__ModuleResponse__c moduleResponse = new FieloELR__ModuleResponse__c(
			FieloELR__Member__c = member.Id,
			FieloELR__Module__c = module.Id,
			FieloELR__CourseStatus__c = courseStatus.Id
		);

		insert moduleResponse;

		FieloELR__QuestionResponse__c questionResponse = new FieloELR__QuestionResponse__c(
			FieloELR__Question__c = question.Id,
			FieloELR__ModuleResponse__c = moduleResponse.Id
		);

		insert questionResponse;

		course.FieloELR__Status__c = 'Inactive';
		module.FieloELR__IsActive__c = false;

		Courses.validateAdminFields = false;
		update course;
		Courses.validateAdminFields = true;

		Modules.validateAdminFields = false;
		update module;
		Modules.validateAdminFields = true;

		answers1 = [SELECT Id, Name, FieloELR__Order__c FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = :question.Id LIMIT 1];

		try{
			delete answers1;
		} catch (Exception e) {System.debug(e.getMessage());}

		System.assertEquals(1, [SELECT Id, Name, FieloELR__Order__c FROM FieloELR__AnswerOption__c WHERE Id = :answers1.Id LIMIT 1].size());
	}

	/*	TEST-1773
		Create Answer Option
		- Delete answer option when related module is not active and the related question does not have question response (OK)
	*/
	@isTest static void ELR_0006_FA15(){
		FieloPLT__Member__c member = [Select Id, Name From FieloPLT__Member__c LIMIT 1];
		FieloELR__Course__c course = [Select Id, Name From FieloELR__Course__c LIMIT 1];
		FieloELR__Module__c module = [Select Id, Name From FieloELR__Module__c Where Name = 'module2' LIMIT 1];
		FieloELR__Question__c question = [Select Id, Name From FieloELR__Question__c Where FieloELR__Module__r.Name = 'module2' AND Name = 'short answer 1' LIMIT 1];

		course.FieloELR__Status__c = 'Active';
		
		Courses.validateAdminFields = false;

		update course;

		Courses.validateAdminFields = true;

		course.FieloELR__Status__c = 'Inactive';
		module.FieloELR__IsActive__c = false;

		Courses.validateAdminFields = false;
		update course;
		Courses.validateAdminFields = true;

		Modules.validateAdminFields = false;
		update module;
		Modules.validateAdminFields = true;

		answers1 = [SELECT Id, Name, FieloELR__Order__c FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = :question.Id LIMIT 1];

		try{
			delete answers1;
		} catch (Exception e) {System.debug(e.getMessage());}

		System.assertEquals(0, [SELECT Id, Name, FieloELR__Order__c FROM FieloELR__AnswerOption__c WHERE Id = :answers1.Id LIMIT 1].size());
	}

	/*	TEST-1858
		Create Answer Option
		- Validations
		- Related question “Type” is “Matching Options” and “Matching Text” field is null (NOK)
	*/
	@isTest static void ELR_0006_FA14() {
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='matching options 1' LIMIT 1].Id;
		answers1.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		answers1.FieloELR__Order__c = 1;
		answers1.FieloELR__IsCorrect__c = true;
		listAnsOpt.add(answers1);

		try {
			insert listAnsOpt;
		} catch (Exception e) {
			System.debug(e.getMessage());
		}

		listAnsOpt = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = :answers1.FieloELR__Question__c];

		System.assertEquals(0, listAnsOpt.size());
	}

	/*	TEST-1772
		Create Answer Option
		- Related question type is “Matching Options” and there is not a matching pair (OK)
	*/
	@isTest static void ELR_0006_FA13() {
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='matching options 1' LIMIT 1].Id;
		answers1.FieloELR__MatchingText__c = 'Esta es correcta';
		answers1.FieloELR__Order__c = 1;
		answers1.FieloELR__IsCorrect__c = true;
		listAnsOpt.add(answers1);

		insert listAnsOpt;

		listAnsOpt = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = :answers1.FieloELR__Question__c];

		System.assertEquals(1, listAnsOpt.size());
	}

	/*	TEST-1771
		Create Answer Option
		- Related question “Type” is “Matching Options” and there is a matching pair (OK)
	*/
	@isTest static void ELR_0006_FA12() {
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='matching options 1' LIMIT 1].Id;
		answers1.FieloELR__AnswerOptionText__c = 'A';
		answers1.FieloELR__MatchingText__c = 'Matches With A';
		answers1.FieloELR__Order__c = 1;
		answers1.FieloELR__IsCorrect__c = true;
		listAnsOpt.add(answers1);

		insert listAnsOpt;

		listAnsOpt = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = :answers1.FieloELR__Question__c];

		System.assertEquals(1, listAnsOpt.size());
	}

	/*	TEST-1770
		Create Answer Option
		- Related question type is “Short Answer” (OK)
	*/
	@isTest static void ELR_0006_FA11() {
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='short answer 2' LIMIT 1].Id;
		answers1.FieloELR__AnswerOptionText__c = 'this is correct';
		answers1.FieloELR__Order__c = 1;
		listAnsOpt.add(answers1);

		insert listAnsOpt;

		listAnsOpt = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = :answers1.FieloELR__Question__c];

		System.assertEquals(1, listAnsOpt.size());
	}

	/*	TEST-1769
		Create Answer Option
		- Validations
		- Related question type is “Single Choice” and another answer option was defined as correct (NOK)
	*/
	@isTest
	static void ELR_0006_FA10(){
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='single choice 1' LIMIT 1].Id;
		answers1.FieloELR__AnswerOptionText__c = 'this is correct';
		answers1.FieloELR__IsCorrect__c = true;
		answers1.FieloELR__Order__c = 1;
		
		insert answers1;

		answers2.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name ='single choice 1' LIMIT 1].Id;
		answers2.FieloELR__AnswerOptionText__c = 'this is also correct';
		answers2.FieloELR__IsCorrect__c = true;
		answers2.FieloELR__Order__c = 1;

		try {
			insert answers2;
		} catch (Exception e) {}

		listAnsOpt = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = :answers1.FieloELR__Question__c];

		System.assertEquals(1, listAnsOpt.size());
	}

	/*	TEST-1764
		Create Answer Option
		- Validations
		- The related module is active (NOK)
	*/
	@isTest	static void ELR_0006_FA1(){
		answers1.FieloELR__Question__c = [SELECT Id FROM FieloELR__Question__c WHERE Name = 'multiple choice 1' LIMIT 1].Id;
		answers1.FieloELR__AnswerOptionText__c = 'Esta es incorrecta';
		answers1.FieloELR__Order__c = 1;
		listAnsOpt.add(answers1);

		try{
    		insert listAnsOpt;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('Active modules cannot have changes in their set of answer options.'));
		}
	}
}