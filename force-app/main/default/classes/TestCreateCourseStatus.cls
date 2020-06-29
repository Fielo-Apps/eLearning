@isTest
private class TestCreateCourseStatus{

	private static List<FieloPLT__Program__c> listProg;
	private static List<FieloPLT__Segment__c> listSeg;
	private static List<FieloELR__Course__c> listCourse;
	private static List<FieloPLT__Member__c> listMemb;
	private static List<FieloPLT__Promotion__c> listProm;
	private static List<FieloPLT__Rule__c> listRule;
	private static List<FieloPLT__MemberSegment__c> listMembSeg;
	private static List<FieloELR__CourseStatus__c> listCourseStatus = new List<FieloELR__CourseStatus__c>();
	private static List<FieloELR__CourseDependency__c> listCourseDepen = new List<FieloELR__CourseDependency__c>();
	private static List<FieloELR__Module__c> listMod = new List<FieloELR__Module__c>();
	private static List<FieloELR__Question__c> listQuest = new List<FieloELR__Question__c>();
	private static List<FieloELR__AnswerOption__c> listAnsOpt = new List<FieloELR__AnswerOption__c>();
	private static List<FieloELR__ModuleResponse__c> listModResp = new List<FieloELR__ModuleResponse__c>();

	private static FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c();

	@testSetup static void setup(){
		//////PROGRAMS
		listProg = MockUpFactory.createPrograms('program', 5);
		insert listProg;

		//////SEGMENTS
		listSeg = MockUpFactory.createSegments('segment', 5, 'Manual');
		listSeg.get(0).FieloPLT__Program__c = listProg.get(0).Id;
		listSeg.get(1).FieloPLT__Program__c = listProg.get(1).Id;
		listSeg.get(2).FieloPLT__Program__c = listProg.get(2).Id;
		listSeg.get(3).FieloPLT__Program__c = listProg.get(3).Id;
		listSeg.get(4).FieloPLT__Program__c = listProg.get(4).Id;

		insert listSeg;

		///////COURSES
		listCourse = MockUpFactory.createCourses(listProg.get(0).Id, listSeg.get(0).Id, 7);
		listCourse.get(2).FieloELR__SubscriptionMode__c = 'Automatic';
		listCourse.get(3).FieloELR__Program__c = listProg.get(2).Id;
		listCourse.get(3).FieloELR__Segment__c = listSeg.get(2).Id;
		listCourse.get(4).FieloELR__Program__c = listProg.get(3).Id;
		listCourse.get(4).FieloELR__Segment__c = listSeg.get(3).Id;
		listCourse.get(5).FieloELR__Program__c = listProg.get(3).Id;
		listCourse.get(5).FieloELR__Segment__c = listSeg.get(3).Id;
		listCourse.get(6).FieloELR__Program__c = listProg.get(4).Id;
		listCourse.get(6).FieloELR__Segment__c = listSeg.get(4).Id;

		insert listCourse;

		//////MEMBERS
		listMemb = MockUpFactory.createMembers(listProg.get(0).Id, 6);
		listMemb.get(1).FieloPLT__Program__c = listProg.get(1).Id;
		listMemb.get(2).FieloPLT__Program__c = listProg.get(2).Id;
		listMemb.get(3).FieloPLT__Program__c = listProg.get(3).Id;
		listMemb.get(4).FieloPLT__Program__c = listProg.get(4).Id;
		listMemb.get(5).FieloPLT__Program__c = listProg.get(3).Id;

		insert listMemb;

		//////MODULES
		FieloELR__Module__c module1 = new FieloELR__Module__c();
		module1.Name = 'module1';
		module1.FieloELR__Course__c = listCourse.get(0).Id;
		module1.FieloELR__ApprovalGrade__c = 0;
		listMod.add(module1);

		FieloELR__Module__c module2 = new FieloELR__Module__c();
		module2.Name = 'module2';
		module2.FieloELR__Course__c = listCourse.get(2).Id;
		module2.FieloELR__ApprovalGrade__c = 0;
		listMod.add(module2);

		FieloELR__Module__c module3 = new FieloELR__Module__c();
		module3.Name = 'module3';
		module3.FieloELR__Course__c = listCourse.get(3).Id;
		module3.FieloELR__ApprovalGrade__c = 0;
		listMod.add(module3);

		FieloELR__Module__c module4 = new FieloELR__Module__c();
		module4.Name = 'module4';
		module4.FieloELR__Course__c = listCourse.get(4).Id;
		module4.FieloELR__ApprovalGrade__c = 0;
		listMod.add(module4);

		FieloELR__Module__c module5 = new FieloELR__Module__c();
		module5.Name = 'module5';
		module5.FieloELR__Course__c = listCourse.get(5).Id;
		module5.FieloELR__ApprovalGrade__c = 0;
		listMod.add(module5);

		FieloELR__Module__c module6 = new FieloELR__Module__c();
		module6.Name = 'module6';
		module6.FieloELR__Course__c = listCourse.get(6).Id;
		module6.FieloELR__ApprovalGrade__c = 0;
		listMod.add(module6);

		insert listMod;

		/////QUESTIONS
		FieloELR__Question__c question1 = new FieloELR__Question__c();
		question1.Name = 'short answer 1';
		question1.FieloELR__Module__c = module1.Id;
		question1.FieloELR__QuestionText__c = 'How are you?';
		question1.FieloELR__Type__c = 'Short Answer';
		listQuest.add(question1);

		FieloELR__Question__c question2 = new FieloELR__Question__c();
		question2.Name = 'short answer 2';
		question2.FieloELR__Module__c = module2.Id;
		question2.FieloELR__QuestionText__c = 'How are you?';
		question2.FieloELR__Type__c = 'Short Answer';
		listQuest.add(question2);

		FieloELR__Question__c question3 = new FieloELR__Question__c();
		question3.Name = 'short answer 3';
		question3.FieloELR__Module__c = module3.Id;
		question3.FieloELR__QuestionText__c = 'How are you?';
		question3.FieloELR__Type__c = 'Short Answer';
		listQuest.add(question3);

		FieloELR__Question__c question4 = new FieloELR__Question__c();
		question4.Name = 'short answer 4';
		question4.FieloELR__Module__c = module4.Id;
		question4.FieloELR__QuestionText__c = 'How are you?';
		question4.FieloELR__Type__c = 'Short Answer';
		listQuest.add(question4);

		FieloELR__Question__c question5 = new FieloELR__Question__c();
		question5.Name = 'short answer 5';
		question5.FieloELR__Module__c = module5.Id;
		question5.FieloELR__QuestionText__c = 'How are you?';
		question5.FieloELR__Type__c = 'Short Answer';
		listQuest.add(question5);

		FieloELR__Question__c question6 = new FieloELR__Question__c();
		question6.Name = 'short answer 6';
		question6.FieloELR__Module__c = module6.Id;
		question6.FieloELR__QuestionText__c = 'How are you?';
		question6.FieloELR__Type__c = 'Short Answer';
		listQuest.add(question6);

		insert listQuest;

		//////ANSWERS
		FieloELR__AnswerOption__c answers1 = new FieloELR__AnswerOption__c();
		answers1.FieloELR__Question__c = question1.Id;
		answers1.FieloELR__IsCorrect__c = true;
		answers1.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		listAnsOpt.add(answers1);

		FieloELR__AnswerOption__c answers2 = new FieloELR__AnswerOption__c();
		answers2.FieloELR__Question__c = question2.Id;
		answers2.FieloELR__IsCorrect__c = true;
		answers2.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		listAnsOpt.add(answers2);

		FieloELR__AnswerOption__c answers3 = new FieloELR__AnswerOption__c();
		answers3.FieloELR__Question__c = question3.Id;
		answers3.FieloELR__IsCorrect__c = true;
		answers3.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		listAnsOpt.add(answers3);

		FieloELR__AnswerOption__c answers4 = new FieloELR__AnswerOption__c();
		answers4.FieloELR__Question__c = question4.Id;
		answers4.FieloELR__IsCorrect__c = true;
		answers4.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		listAnsOpt.add(answers4);

		FieloELR__AnswerOption__c answers5 = new FieloELR__AnswerOption__c();
		answers5.FieloELR__Question__c = question5.Id;
		answers5.FieloELR__IsCorrect__c = true;
		answers5.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		listAnsOpt.add(answers5);

		FieloELR__AnswerOption__c answers6 = new FieloELR__AnswerOption__c();
		answers6.FieloELR__Question__c = question6.Id;
		answers6.FieloELR__IsCorrect__c = true;
		answers6.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		listAnsOpt.add(answers6);

		insert listAnsOpt;

		//////MEMBER SEGMENT
		listMembSeg = new List<FieloPLT__MemberSegment__c>();
		for(FieloPLT__Member__c member: listMemb) {
			for (FieloPLT__Segment__c segment: listSeg) {
				if (member.FieloPLT__Program__c == segment.FieloPLT__Program__c) {
					listMembSeg.add(
						new FieloPLT__MemberSegment__c(
							FieloPLT__Member__c = member.Id,
							FieloPLT__Segment__c = segment.Id
						)
					);
				}
			}
		}

		insert listMembSeg;

		///////COURSES DEPENDENCIES
		FieloELR__CourseDependency__c cDepen = new FieloELR__CourseDependency__c();
		cDepen.FieloELR__Predecessor__c = listCourse.get(4).Id;
		cDepen.FieloELR__Course__c = listCourse.get(5).Id;
		listCourseDepen.add(cDepen);

		insert listCourseDepen;


		//////MODULES UPDATE
		module1.FieloELR__IsActive__c = true;
		module2.FieloELR__IsActive__c = true;
		module3.FieloELR__IsActive__c = true;
		module4.FieloELR__IsActive__c = true;
		module5.FieloELR__IsActive__c = true;
		module6.FieloELR__IsActive__c = true;
		update listMod;

		//////COURSES UPDATE
		listCourse.get(0).FieloELR__Status__c = 'Active';
		listCourse.get(2).FieloELR__Status__c = 'Active';
		listCourse.get(3).FieloELR__Status__c = 'Active';
		listCourse.get(4).FieloELR__Status__c = 'Active';
		listCourse.get(5).FieloELR__Status__c = 'Active';
		listCourse.get(6).FieloELR__Status__c = 'Active';
		update listCourse;

		FieloPLT.SObjectService.setStaticVariables();
		//////COURSES STATUS
		FieloELR__CourseStatus__c cStatus1 = new FieloELR__CourseStatus__c();
		cStatus1.FieloELR__Member__c = listMemb.get(3).Id;
		cStatus1.FieloELR__Course__c = listCourse.get(4).Id;
		listCourseStatus.add(cStatus1);

		FieloELR__CourseStatus__c cStatus2 = new FieloELR__CourseStatus__c();
		cStatus2.FieloELR__Member__c = listMemb.get(4).Id;
		cStatus2.FieloELR__Course__c = listCourse.get(6).Id;
		listCourseStatus.add(cStatus2);

		insert listCourseStatus;

		//////MODULE RESPONSES
		FieloELR__ModuleResponse__c modResp1 = new FieloELR__ModuleResponse__c();
		modResp1.FieloELR__CourseStatus__c = listCourseStatus.get(0).Id;
		modResp1.FieloELR__Module__c = listMod.get(3).Id;
		modResp1.FieloELR__Member__c = listMemb.get(3).Id;
		listModResp.add(modResp1);

		insert listModResp;
	}

	/*	TEST-1838
		Create Course Status
		- Course status is created when the Subscription Mode is Manual (OK)
	*/
    @isTest static void ELR_0013_FB(){
    	listCourse = [SELECT Id, FieloELR__SubscriptionMode__c FROM FieloELR__Course__c WHERE Name = 'Course 0' LIMIT 1];
    	listMemb = [SELECT Id FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];

		courseStatus.FieloELR__Course__c = listCourse.get(0).Id;
		courseStatus.FieloELR__Member__c = listMemb.get(0).Id;

		System.assertEquals('Manual', listCourse.get(0).FieloELR__SubscriptionMode__c);

		insert courseStatus;

		courseStatus = [SELECT FieloELR__ApprovedModules__c FROM FieloELR__CourseStatus__c LIMIT 1];

		System.assertEquals(0, courseStatus.FieloELR__ApprovedModules__c);
    }

    /*	TEST-1839
    	Create Course Status
    	- Validations
    	- The related course is not “Active” (NOK)
    */
    @isTest static void ELR_0013_FA2(){
    	listCourse = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE Name = 'Course 1' LIMIT 1];
    	listMemb = [SELECT Id FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];

    	System.assertNotEquals('Active', listCourse.get(0).FieloELR__Status__c);

    	courseStatus.FieloELR__Course__c = listCourse.get(0).Id;
    	courseStatus.FieloELR__Member__c = listMemb.get(0).Id;

    	try{
    		insert courseStatus;
    	}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('Course Status must be related to a Course with the Status Active'));
		}
    }

    /*	TEST-1840
    	Create Course Status
    	- Validations
    	- Course status is created by administrator when the “Subscription Mode” is “Automatic” (NOK)
    */
    @isTest static void ELR_0013_FA3(){
    	listCourse = [SELECT Id, FieloELR__SubscriptionMode__c FROM FieloELR__Course__c WHERE Name = 'Course 2' LIMIT 1];
    	listMemb = [SELECT Id FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];

    	System.assertEquals('Automatic', listCourse.get(0).FieloELR__SubscriptionMode__c);

    	courseStatus.FieloELR__Course__c = listCourse.get(0).Id;
    	courseStatus.FieloELR__Member__c = listMemb.get(0).Id;

    	try{
    		insert courseStatus;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('The course status cannot be created if the subscription mode of the course is ""Automatic""'));
		}
    }

    /*	TEST-1841
		Create Course Status
		- Validations
		- The Member field is null (NOK)
    */
    @isTest static void ELR_0013_FA4(){
    	courseStatus.FieloELR__Course__c = [SELECT Id FROM FieloELR__Course__c WHERE Name = 'Course 0' LIMIT 1].Id;

    	try{
    		insert courseStatus;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('Attempt to de-reference a null object'));
		}
    }

    /*	TEST-1842
    	Create Course Status
    	- Validations
    	- The Member does not belong to any segment of the course (NOK)
    */
    @isTest static void ELR_0013_FA6(){
    	listCourse = [SELECT Id, FieloELR__Segment__c FROM FieloELR__Course__c WHERE Name = 'Course 3' LIMIT 1];
    	listMemb = [SELECT Id, (Select Id, Name, FieloPLT__Segment__c From FieloPLT__MembersSegments__r) FROM FieloPLT__Member__c WHERE Name = 'Member 2' LIMIT 1];

    	delete listMemb.get(0).FieloPLT__MembersSegments__r;

    	courseStatus.FieloELR__Course__c = listCourse.get(0).Id;
    	courseStatus.FieloELR__Member__c = listMemb.get(0).Id;

    	try{
    		insert courseStatus;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('The member does not apply to the course\'s segment'));
		}
    }

    /*	TEST-1843
    	Create Course Status
    	- Validations
    	- The Member does not belong to the same program of the course (NOK)
    */
    @isTest static void ELR_0013_FA7(){
    	listCourse = [SELECT Id, FieloELR__Program__c FROM FieloELR__Course__c WHERE Name = 'Course 0' LIMIT 1];
    	listMemb = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE FieloPLT__Program__c != :listCourse.get(0).FieloELR__Program__c LIMIT 1];

    	System.assertNotEquals(listCourse.get(0).FieloELR__Program__c, listMemb.get(0).FieloPLT__Program__c);

    	courseStatus.FieloELR__Course__c = listCourse.get(0).Id;
    	courseStatus.FieloELR__Member__c = listMemb.get(0).Id;

    	try{
    		insert courseStatus;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('The member should belong to the course\'s program'));
		}
    }

    /*	TEST-1844
		Create Course Status
		- Validations
		- The Member has not completed the predecessors courses (NOK)
    */
    @isTest static void ELR_0013_FA8(){
    	listCourse = [SELECT Id FROM FieloELR__Course__c WHERE Name = 'Course 5' LIMIT 1];
		listMemb = [SELECT Id FROM FieloPLT__Member__c WHERE Name = 'Member 3' LIMIT 1];

    	courseStatus.FieloELR__Course__c = listCourse.get(0).Id;
    	courseStatus.FieloELR__Member__c = listMemb.get(0).Id;

    	try{
    		insert courseStatus;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('Course Predecessor was not completed at 100 per cent'));
		}
    }

    /*	TEST-1845
    	Create Course Status
    	- Validations
    	- There is already a course status created for the member in the course (NOK)
    */
    @isTest static void ELR_0013_FA9(){
    	listCourse = [SELECT Id FROM FieloELR__Course__c WHERE Name = 'Course 6' LIMIT 1];
    	listMemb = [SELECT Id FROM FieloPLT__Member__c WHERE Name = 'Member 4' LIMIT 1];

    	courseStatus.FieloELR__Course__c = listCourse.get(0).Id;
    	courseStatus.FieloELR__Member__c = listMemb.get(0).Id;

    	try{
    		insert courseStatus;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('This course status already exists'));
		}
    }

    /*	TEST-1846
    	Create Course Status
    	- Delete course status (OK)
    */
    @isTest static void ELR_0013_FA10(){
    	courseStatus = [SELECT Id FROM FieloELR__CourseStatus__c LIMIT 1];

    	delete courseStatus;

    	listCourseStatus = [SELECT Id FROM FieloELR__CourseStatus__c WHERE Id = :courseStatus.Id LIMIT 1];

    	System.assertEquals(0, listCourseStatus.size());
    }

    /*	TEST-1847
    	Create Course Status
    	- Validations
    	- Edit course status (NOK)
    */
    @isTest static void ELR_0013_FA11(){
    	courseStatus = [SELECT Id, FieloELR__Member__c, FieloELR__Course__c FROM FieloELR__CourseStatus__c LIMIT 1];

    	courseStatus.FieloELR__Course__c = [SELECT Id FROM FieloELR__Course__c WHERE Name = 'Course 0' LIMIT 1].Id;
		courseStatus.FieloELR__Member__c = [SELECT Id FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1].Id;

		try {
			update courseStatus;
		} catch(Exception e) {
			System.assert(e.getMessage().Contains('Course cannot be changed'));
		}
    }
}