@isTest
public class TestChangeCourseStatus {
	private static List<FieloPLT__Program__c> programs = new List<FieloPLT__Program__c>();
	private static List<FieloPLT__Segment__c> segments = new List<FieloPLT__Segment__c>();
	private static List<FieloELR__Course__c> courses = new List<FieloELR__Course__c>();
	private static List<FieloPLT__Member__c> members = new List<FieloPLT__Member__c>();
	private static List<FieloPLT__MemberSegment__c> memberSegments = new List<FieloPLT__MemberSegment__c>();
	private static List<FieloELR__CourseStatus__c> courseStatusList = new List<FieloELR__CourseStatus__c>();
	private static List<FieloELR__CourseDependency__c> courseDependencies = new List<FieloELR__CourseDependency__c>();
	private static List<FieloELR__Module__c> modules = new List<FieloELR__Module__c>();
	private static List<FieloELR__Question__c> questions = new List<FieloELR__Question__c>();
	private static List<FieloELR__AnswerOption__c> answerOptions = new List<FieloELR__AnswerOption__c>();
	private static List<FieloELR__ModuleResponse__c> moduleResponses = new List<FieloELR__ModuleResponse__c>();
	private static FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c();

	@testSetup static void setup(){
		programs = MockUpFactory.createPrograms('Default', 1);
        insert programs;

        segments = MockUpFactory.createSegments('Segment',1,'Manual');
        insert segments;

        courses = MockUpFactory.createCourses(programs.get(0).id, segments.get(0).id, 1);
        courses.get(0).StartDate__c = System.today();
        courses.get(0).EndDate__c = System.today().addDays(15);
        insert courses;

        members = MockUpFactory.createMembers(programs.get(0).id, 1);
        insert members;

        FieloPLT__MemberSegment__c memberSegment = new FieloPLT__MemberSegment__c(
            FieloPLT__Segment__c = segments.get(0).Id,
            FieloPLT__Member__c = members.get(0).Id
        );
        insert memberSegment;

        //Module
        modules.add(
        	new Module__c(Name = 'Basic', Course__c = courses.get(0).id, ApprovalGrade__c = 0, AttemptsAllowed__c = 2, AttemptsAllowedPerQuestion__c = 2, PenaltyMode__c = 'None')
        );

        insert modules;

        questions.add(new Question__c(Name = 'Q1', Module__c = modules.get(0).Id, QuestionText__c = 'Which one is the most popular programming language?', Type__c = 'Single Choice'));
        questions.add(new Question__c(Name = 'Q2', Module__c = modules.get(0).Id, QuestionText__c = 'Acronymn for Personal Computer', Type__c = 'Short Answer'));
        questions.add(new Question__c(Name = 'Q3', Module__c = modules.get(0).Id, QuestionText__c = 'Which of the following are Family-C programming languages?', Type__c = 'Multiple Choice'));
        questions.add(new Question__c(Name = 'Q4', Module__c = modules.get(0).Id, QuestionText__c = 'C++ is more performatic than java', Type__c = 'Statement'));
        questions.add(new Question__c(Name = 'Q5', Module__c = modules.get(0).Id, QuestionText__c = 'Match statement with its meaning', Type__c = 'Matching Options'));

        insert questions;

        // Answers Q1
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'Java'));
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'C++'));
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'SQL'));
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'PHP'));
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = true, AnswerOptionText__c = 'JavaScript'));
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'HTML'));

        // Answers Q2
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'PC'));
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'pc'));
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'p.c.'));
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'P.C.'));

        // Answers Q3
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'C++'));
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'Java'));
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'PHP'));
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'Python'));
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'Objective-C'));

        // Answers Q4
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(3).Id, IsCorrect__c = true, AnswerOptionText__c = 'True'));
        answerOptions.add(new AnswerOption__c(Question__c = questions.get(3).Id, IsCorrect__c = false, AnswerOptionText__c = 'False'));

        // Answers Q5
        answerOptions.add(new AnswerOption__c( Question__c = questions.get(4).Id, IsCorrect__c = true, AnswerOptionText__c = 'if', MatchingText__c = 'conditional'));
        answerOptions.add(new AnswerOption__c( Question__c = questions.get(4).Id, IsCorrect__c = true, AnswerOptionText__c = 'for', MatchingText__c = 'loop'));
        answerOptions.add(new AnswerOption__c( Question__c = questions.get(4).Id, IsCorrect__c = true, AnswerOptionText__c = 'while', MatchingText__c = 'loop'));
        answerOptions.add(new AnswerOption__c( Question__c = questions.get(4).Id, IsCorrect__c = true, AnswerOptionText__c = 'break', MatchingText__c = 'exit loop'));

        insert answerOptions;
	}

	/*	TEST-1665
		Change Status of Course
		- Activate a draft course where current date is within the course period - OK
	*/
	@isTest static void ELR_0024_FB() {
		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];
		modules = [SELECT Id, IsActive__c FROM Module__c];

		for (Module__c m: modules) {
			m.IsActive__c = true;
		}
        update modules;

		System.assertEquals('Draft', courses.get(0).Status__c);

        CourseService.activateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Active', courses.get(0).Status__c);
	}

	/*	TEST-1666
		Change Status of Course
		- Validations - Activate a course that has no active related modules (NOK)
	*/
	@isTest static void ELR_0024_FA4() {
		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

		System.assertEquals('Draft', courses.get(0).Status__c);

        courses.get(0).Status__c = 'Active';

        try {
	        update courses;
        } catch (Exception e) {}

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Draft', courses.get(0).Status__c);
	}

	/*	TEST-1678
		Change Status of Course
		- Inactivate an active course (OK)
	*/
	@isTest static void ELR_0024_FA5() {
		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];
		modules = [SELECT Id, IsActive__c FROM Module__c];

		for (Module__c m: modules) {
			m.IsActive__c = true;
		}
        update modules;

		System.assertEquals('Draft', courses.get(0).Status__c);

        courses.get(0).Status__c = 'Active';

        CourseService.activateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Active', courses.get(0).Status__c);

        CourseService.inactivateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Inactive', courses.get(0).Status__c);
	}

	/*	TEST-1973
		Change Status of Course
		- Activate a course in status “Draft” that has no defined period (OK)
	*/
	@isTest static void ELR_0024_FA1() {
		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];
		modules = [SELECT Id, IsActive__c FROM Module__c];

		courses.get(0).StartDate__c = null;
		courses.get(0).EndDate__c = null;

		update courses;

		for (Module__c m: modules) {
			m.IsActive__c = true;
		}
        update modules;

		System.assertEquals('Draft', courses.get(0).Status__c);

        CourseService.activateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Active', courses.get(0).Status__c);
	}

	/*	TEST-1974
		Change Status of Course
		- Schedule a course in status “Draft” that has its start date in the future (OK)
	*/
	@isTest static void ELR_0024_FA2() {
		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];
		modules = [SELECT Id, IsActive__c FROM Module__c];

		courses.get(0).StartDate__c = System.today().addDays(10);
		courses.get(0).EndDate__c = System.today().addDays(100);

		update courses;

		for (Module__c m: modules) {
			m.IsActive__c = true;
		}
        update modules;

		System.assertEquals('Draft', courses.get(0).Status__c);

        CourseService.activateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Scheduled', courses.get(0).Status__c);
	}

	/*	TEST-1975
		Change Status of Course
		- Complete a course in status “Draft” that has its end date in the past (OK)
	*/
	@isTest static void ELR_0024_FA3() {
		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];
		modules = [SELECT Id, IsActive__c FROM Module__c];

		courses.get(0).StartDate__c = System.today().addDays(-100);
		courses.get(0).EndDate__c = System.today().addDays(-10);

		FieloELR.Courses.validateAdminFields = false;
		update courses;
		FieloELR.Courses.validateAdminFields = true;

		for (Module__c m: modules) {
			m.IsActive__c = true;
		}
        update modules;

		System.assertEquals('Draft', courses.get(0).Status__c);

        CourseService.activateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Completed', courses.get(0).Status__c);
	}

	/*	TEST-1976
		Change Status of Course - Inactivate a scheduled course (OK)
	*/
	@isTest static void ELR_0024_FA6() {
		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];
		modules = [SELECT Id, IsActive__c FROM Module__c];

		courses.get(0).StartDate__c = System.today().addDays(10);
		courses.get(0).EndDate__c = System.today().addDays(100);

		update courses;

		for (Module__c m: modules) {
			m.IsActive__c = true;
		}
        update modules;

		System.assertEquals('Draft', courses.get(0).Status__c);

        CourseService.activateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Scheduled', courses.get(0).Status__c);

		CourseService.inactivateCourses(new Set<Id>{courses.get(0).Id});

		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

		System.assertEquals('Inactive', courses.get(0).Status__c);
	}

	/*	TEST-1977
		Change Status of Course - Inactivate a completed course (OK)
	*/
	@isTest static void ELR_0024_FA7() {
		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];
		modules = [SELECT Id, IsActive__c FROM Module__c];

		courses.get(0).StartDate__c = System.today().addDays(-100);
		courses.get(0).EndDate__c = System.today().addDays(-10);

		FieloELR.Courses.validateAdminFields = false;
		update courses;
		FieloELR.Courses.validateAdminFields = true;

		for (Module__c m: modules) {
			m.IsActive__c = true;
		}
        update modules;

		System.assertEquals('Draft', courses.get(0).Status__c);

        CourseService.activateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Completed', courses.get(0).Status__c);

        CourseService.inactivateCourses(new Set<Id>{courses.get(0).Id});

		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

		System.assertEquals('Inactive', courses.get(0).Status__c);
	}

	/*	TEST-1978
		Change Status of Course - Activate an inactive course (OK)
	*/
	@isTest static void ELR_0024_FA8() {
		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];
		modules = [SELECT Id, IsActive__c FROM Module__c];

		for (Module__c m: modules) {
			m.IsActive__c = true;
		}
        update modules;

		System.assertEquals('Draft', courses.get(0).Status__c);

        courses.get(0).Status__c = 'Active';

        CourseService.activateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Active', courses.get(0).Status__c);

        CourseService.inactivateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Inactive', courses.get(0).Status__c);

        CourseService.activateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Active', courses.get(0).Status__c);
	}

	/*	TEST-1979
		Change Status of Course - Schedule an inactive course (OK)
	*/
	@isTest static void ELR_0024_FA9() {
		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];
		modules = [SELECT Id, IsActive__c FROM Module__c];

		for (Module__c m: modules) {
			m.IsActive__c = true;
		}
        update modules;

		System.assertEquals('Draft', courses.get(0).Status__c);

        courses.get(0).Status__c = 'Active';

        CourseService.activateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Active', courses.get(0).Status__c);

        CourseService.inactivateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Inactive', courses.get(0).Status__c);

		courses.get(0).StartDate__c = system.today().addDays(10);
		courses.get(0).EndDate__c = system.today().addDays(100);

		update courses;

		CourseService.activateCourses(new Set<Id>{courses.get(0).Id});
	}

	/*	TEST-1980
		Change Status of Course - Complete an inactive course (OK)
	*/
	@isTest static void ELR_0024_FA10() {
		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];
		modules = [SELECT Id, IsActive__c FROM Module__c];

		for (Module__c m: modules) {
			m.IsActive__c = true;
		}
        update modules;

		System.assertEquals('Draft', courses.get(0).Status__c);

        courses.get(0).Status__c = 'Active';

        CourseService.activateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Active', courses.get(0).Status__c);

        CourseService.inactivateCourses(new Set<Id>{courses.get(0).Id});

        courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

        System.assertEquals('Inactive', courses.get(0).Status__c);

		courses.get(0).StartDate__c = system.today().addDays(-100);
		courses.get(0).EndDate__c = system.today().addDays(-10);

		FieloELR.Courses.validateAdminFields = false;
		update courses;
		FieloELR.Courses.validateAdminFields = true;

		CourseService.activateCourses(new Set<Id>{courses.get(0).Id});

		courses = [SELECT Id, Status__c FROM Course__c LIMIT 1];

		System.assertEquals('Completed', courses.get(0).Status__c);
	}
}