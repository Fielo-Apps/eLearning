@isTest
private class TestCreateAnswerResponse {

	private static List<FieloPLT__Program__c> listProg;
	private static List<FieloPLT__Segment__c> listSeg;
	private static List<FieloELR__Course__c> listCourse;
	private static List<FieloPLT__Member__c> listMemb;
	private static List<FieloELR__CourseStatus__c> listCourseStatus = new List<FieloELR__CourseStatus__c>();
	private static List<FieloELR__Module__c> listMod = new List<FieloELR__Module__c>();
	private static List<FieloELR__Question__c> listQuest = new List<FieloELR__Question__c>();
	private static List<FieloELR__AnswerOption__c> listAnsOpt = new List<FieloELR__AnswerOption__c>();
	private static List<FieloELR__ModuleResponse__c> listModResp = new List<FieloELR__ModuleResponse__c>();
	private static List<FieloELR__QuestionResponse__c> listQuestResp = new List<FieloELR__QuestionResponse__c>();
	private static List<FieloELR__Answer__c> listAnsResp = new List<FieloELR__Answer__c>();

	private static FieloELR__Answer__c answer1 = new FieloELR__Answer__c();
	private static FieloELR__Answer__c answer2 = new FieloELR__Answer__c();
	private static FieloELR__Answer__c answer3 = new FieloELR__Answer__c();
	private static FieloELR__Answer__c answer4 = new FieloELR__Answer__c();

	@testSetup
	static void setup(){

		//////PROGRAMS
		listProg = MockUpFactory.createPrograms('program', 1);

		insert listProg;

		//////SEGMENTS
		listSeg = MockUpFactory.createSegments('segment', 1, 'Dynamic');
		listSeg.get(0).FieloPLT__Program__c = listProg.get(0).Id;

		insert listSeg;

		///////COURSES
		listCourse = MockUpFactory.createCourses(listProg.get(0).Id, listSeg.get(0).Id, 1);

		insert listCourse;

		//////MEMBERS
		listMemb = MockUpFactory.createMembers(listProg.get(0).Id, 1);

		insert listMemb;

		//////MODULES
		FieloELR__Module__c module1 = new FieloELR__Module__c();
		module1.Name = 'module1';
		module1.FieloELR__Course__c = listCourse.get(0).Id;
		module1.FieloELR__ApprovalGrade__c = 0;
		listMod.add(module1);

		insert listMod;

		/////QUESTIONS
		FieloELR__Question__c question1 = new FieloELR__Question__c();
		question1.Name = 'statement 1';
		question1.FieloELR__Module__c = listMod.get(0).Id;
		question1.FieloELR__QuestionText__c = 'How are you?';
		question1.FieloELR__Type__c = 'Statement';
		listQuest.add(question1);

		FieloELR__Question__c question2 = new FieloELR__Question__c();
		question2.Name = 'single choice 1';
		question2.FieloELR__Module__c = listMod.get(0).Id;
		question2.FieloELR__QuestionText__c = 'How are you?';
		question2.FieloELR__Type__c = 'Single Choice';
		listQuest.add(question2);

		FieloELR__Question__c question3 = new FieloELR__Question__c();
		question3.Name = 'multiple choice 1';
		question3.FieloELR__Module__c = listMod.get(0).Id;
		question3.FieloELR__QuestionText__c = 'How are you?';
		question3.FieloELR__Type__c = 'Multiple Choice';
		listQuest.add(question3);

		FieloELR__Question__c question4 = new FieloELR__Question__c();
		question4.Name = 'matching options 1';
		question4.FieloELR__Module__c = listMod.get(0).Id;
		question4.FieloELR__QuestionText__c = 'How are you?';
		question4.FieloELR__Type__c = 'Matching Options';
		listQuest.add(question4);

		FieloELR__Question__c question5 = new FieloELR__Question__c();
		question5.Name = 'statement 2';
		question5.FieloELR__Module__c = listMod.get(0).Id;
		question5.FieloELR__QuestionText__c = 'How are you?';
		question5.FieloELR__Type__c = 'Statement';
		listQuest.add(question5);

		FieloELR__Question__c question6 = new FieloELR__Question__c();
		question6.Name = 'single choice 2';
		question6.FieloELR__Module__c = listMod.get(0).Id;
		question6.FieloELR__QuestionText__c = 'How are you?';
		question6.FieloELR__Type__c = 'Single Choice';
		listQuest.add(question6);

		FieloELR__Question__c question7 = new FieloELR__Question__c();
		question7.Name = 'multiple choice 2';
		question7.FieloELR__Module__c = listMod.get(0).Id;
		question7.FieloELR__QuestionText__c = 'How are you?';
		question7.FieloELR__Type__c = 'Multiple Choice';
		listQuest.add(question7);

		insert listQuest;

		Map<Id,List<Id>> questionMap = new Map<Id,List<Id>>();

		for (Question__c q: listQuest) {
			questionMap.put(q.Id, new List<Id>());
		}

		//////ANSWER OPTIONS
		FieloELR__AnswerOption__c ansOpt1 = new FieloELR__AnswerOption__c();
		ansOpt1.FieloELR__Question__c = listQuest.get(0).Id;
		ansOpt1.FieloELR__IsCorrect__c = true;
		ansOpt1.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		listAnsOpt.add(ansOpt1);

		ansOpt1 = new FieloELR__AnswerOption__c();
		ansOpt1.FieloELR__Question__c = listQuest.get(0).Id;
		ansOpt1.FieloELR__IsCorrect__c = false;
		ansOpt1.FieloELR__AnswerOptionText__c = 'Esta es incorrecta';
		listAnsOpt.add(ansOpt1);

		FieloELR__AnswerOption__c ansOpt2 = new FieloELR__AnswerOption__c();
		ansOpt2.FieloELR__Question__c = listQuest.get(1).Id;
		ansOpt2.FieloELR__IsCorrect__c = true;
		ansOpt2.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		listAnsOpt.add(ansOpt2);

		ansOpt2 = new FieloELR__AnswerOption__c();
		ansOpt2.FieloELR__Question__c = listQuest.get(1).Id;
		ansOpt2.FieloELR__IsCorrect__c = false;
		ansOpt2.FieloELR__AnswerOptionText__c = 'Esta es incorrecta';
		listAnsOpt.add(ansOpt2);

		FieloELR__AnswerOption__c ansOpt3 = new FieloELR__AnswerOption__c();
		ansOpt3.FieloELR__Question__c = listQuest.get(2).Id;
		ansOpt3.FieloELR__IsCorrect__c = true;
		ansOpt3.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		listAnsOpt.add(ansOpt3);

		ansOpt3 = new FieloELR__AnswerOption__c();
		ansOpt3.FieloELR__Question__c = listQuest.get(2).Id;
		ansOpt3.FieloELR__IsCorrect__c = false;
		ansOpt3.FieloELR__AnswerOptionText__c = 'Esta es incorrecta';
		listAnsOpt.add(ansOpt3);

		FieloELR__AnswerOption__c ansOpt4 = new FieloELR__AnswerOption__c();
		ansOpt4.FieloELR__Question__c = listQuest.get(3).Id;
		ansOpt4.FieloELR__IsCorrect__c = true;
		ansOpt4.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		ansOpt4.FieloELR__MatchingText__c = 'Va con esta';
		listAnsOpt.add(ansOpt4);

		ansOpt4 = new FieloELR__AnswerOption__c();
		ansOpt4.FieloELR__Question__c = listQuest.get(3).Id;
		ansOpt4.FieloELR__IsCorrect__c = false;
		ansOpt4.FieloELR__AnswerOptionText__c = 'Esta es incorrecta';
		ansOpt4.FieloELR__MatchingText__c = 'Va con esta';
		listAnsOpt.add(ansOpt4);

		FieloELR__AnswerOption__c ansOpt5 = new FieloELR__AnswerOption__c();
		ansOpt5.FieloELR__Question__c = listQuest.get(4).Id;
		ansOpt5.FieloELR__IsCorrect__c = true;
		ansOpt5.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		listAnsOpt.add(ansOpt5);

		ansOpt5 = new FieloELR__AnswerOption__c();
		ansOpt5.FieloELR__Question__c = listQuest.get(4).Id;
		ansOpt5.FieloELR__IsCorrect__c = false;
		ansOpt5.FieloELR__AnswerOptionText__c = 'Esta es incorrecta';
		listAnsOpt.add(ansOpt5);

		FieloELR__AnswerOption__c ansOpt6 = new FieloELR__AnswerOption__c();
		ansOpt6.FieloELR__Question__c = listQuest.get(5).Id;
		ansOpt6.FieloELR__IsCorrect__c = true;
		ansOpt6.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		listAnsOpt.add(ansOpt6);

		ansOpt6 = new FieloELR__AnswerOption__c();
		ansOpt6.FieloELR__Question__c = listQuest.get(5).Id;
		ansOpt6.FieloELR__IsCorrect__c = false;
		ansOpt6.FieloELR__AnswerOptionText__c = 'Esta es incorrecta';
		listAnsOpt.add(ansOpt6);

		FieloELR__AnswerOption__c ansOpt7 = new FieloELR__AnswerOption__c();
		ansOpt7.FieloELR__Question__c = listQuest.get(6).Id;
		ansOpt7.FieloELR__IsCorrect__c = true;
		ansOpt7.FieloELR__AnswerOptionText__c = 'Esta es correcta';
		listAnsOpt.add(ansOpt7);

		ansOpt7 = new FieloELR__AnswerOption__c();
		ansOpt7.FieloELR__Question__c = listQuest.get(6).Id;
		ansOpt7.FieloELR__IsCorrect__c = false;
		ansOpt7.FieloELR__AnswerOptionText__c = 'Esta es incorrecta';
		listAnsOpt.add(ansOpt7);

		insert listAnsOpt;

		for (AnswerOption__c ao: listAnsOpt) {
			questionMap.get(ao.Question__c).add(ao.Id);
		}

        //////MODULES UPDATE
		listMod.get(0).FieloELR__IsActive__c = true;
		update listMod;

		//////COURSES UPDATE
		listCourse.get(0).FieloELR__Status__c = 'Active';
		update listCourse;


		//////COURSES STATUS
		FieloELR__CourseStatus__c cStatus1 = new FieloELR__CourseStatus__c();
		cStatus1.FieloELR__Member__c = listMemb.get(0).Id;
		cStatus1.FieloELR__Course__c = listCourse.get(0).Id;
		listCourseStatus.add(cStatus1);

		insert listCourseStatus;

		//MODULES RESPONSE
        FieloELR__ModuleResponse__c mResp1 = new FieloELR__ModuleResponse__c();
        mResp1.FieloELR__Module__c = listMod.get(0).id;
        mResp1.FieloELR__Member__c = listMemb.get(0).id;
        listModResp.add(mResp1);

        insert listModResp;

		//QUESTIONS RESPONSE
        FieloELR__QuestionResponse__c qResp1 = new FieloELR__QuestionResponse__c();
        qResp1.FieloELR__Question__c = listQuest.get(0).id;
        qResp1.FieloELR__ModuleResponse__c = listModResp.get(0).id;
        listQuestResp.add(qResp1);

        FieloELR__QuestionResponse__c qResp2 = new FieloELR__QuestionResponse__c();
        qResp2.FieloELR__Question__c = listQuest.get(1).id;
        qResp2.FieloELR__ModuleResponse__c = listModResp.get(0).id;
        listQuestResp.add(qResp2);

        FieloELR__QuestionResponse__c qResp3 = new FieloELR__QuestionResponse__c();
        qResp3.FieloELR__Question__c = listQuest.get(2).id;
        qResp3.FieloELR__ModuleResponse__c = listModResp.get(0).id;
        listQuestResp.add(qResp3);

        FieloELR__QuestionResponse__c qResp4 = new FieloELR__QuestionResponse__c();
        qResp4.FieloELR__Question__c = listQuest.get(2).id;
        qResp4.FieloELR__ModuleResponse__c = listModResp.get(0).id;
        listQuestResp.add(qResp4);

        FieloELR__QuestionResponse__c qResp5 = new FieloELR__QuestionResponse__c();
        qResp5.FieloELR__Question__c = listQuest.get(3).id;
        qResp5.FieloELR__ModuleResponse__c = listModResp.get(0).id;
        listQuestResp.add(qResp5);

        FieloELR__QuestionResponse__c qResp6 = new FieloELR__QuestionResponse__c();
        qResp6.FieloELR__Question__c = listQuest.get(4).id;
        qResp6.FieloELR__ModuleResponse__c = listModResp.get(0).id;
        listQuestResp.add(qResp6);

        FieloELR__QuestionResponse__c qResp7 = new FieloELR__QuestionResponse__c();
        qResp7.FieloELR__Question__c = listQuest.get(5).id;
        qResp7.FieloELR__ModuleResponse__c = listModResp.get(0).id;
        listQuestResp.add(qResp7);

        FieloELR__QuestionResponse__c qResp8 = new FieloELR__QuestionResponse__c();
        qResp8.FieloELR__Question__c = listQuest.get(6).id;
        qResp8.FieloELR__ModuleResponse__c = listModResp.get(0).id;
        listQuestResp.add(qResp8);

        insert listQuestResp;

        /*
        	Q0	A0
				A1
			Q1	A2
				A3
			Q2  A4
				A5
			Q3  A6
				A7
			Q4  A8
				A9
			Q5  A10
				A11
			Q6  A12
				A13
        */

        //ANSWERS RESPONSE
        answer1.FieloELR__QuestionResponse__c = listQuestResp.get(5).Id;
        answer1.FieloELR__AnswerOption__c = questionMap.get(listQuestResp.get(5).Question__c).get(0);
        listAnsResp.add(answer1);

        answer2.FieloELR__QuestionResponse__c = listQuestResp.get(6).Id;
        answer2.FieloELR__AnswerOption__c = questionMap.get(listQuestResp.get(6).Question__c).get(0);
        listAnsResp.add(answer2);

        answer3.FieloELR__QuestionResponse__c = listQuestResp.get(7).Id;
        answer3.FieloELR__AnswerOption__c = questionMap.get(listQuestResp.get(7).Question__c).get(0);
        listAnsResp.add(answer3);

        answer4.FieloELR__QuestionResponse__c = listQuestResp.get(3).Id;
        answer4.FieloELR__AnswerOption__c = questionMap.get(listQuestResp.get(3).Question__c).get(0);
        listAnsResp.add(answer4);

        insert listAnsResp;


        //////UPDATE QUESTION RESPONSES
        listQuestResp.get(3).FieloELR__IsSubmitted__c = true;

        update listQuestResp;
	}
	
	/*	TEST-1806
		Create Answer
		- Validations
		- The “Question Response” is submitted (NOK)
	*/
	@isTest	static void ELR_0009_FA1(){
		answer1.FieloELR__QuestionResponse__c = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__IsSubmitted__c = true AND FieloELR__Question__r.Name = 'multiple choice 1' LIMIT 1].Id;
		answer1.FieloELR__AnswerOption__c = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__r.Name ='multiple choice 1' LIMIT 1].Id;
		listAnsResp.add(answer1);

		try{
    		insert listAnsResp;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('Question responses already submitted cannot have new answers or their existing ones updated or deleted.'));
		}
	}

	/*	TEST-1807
		Create Answer
		- Related question type is “Matching Options” (OK)
	*/
	@isTest	static void ELR_0009_FA2(){

		answer1.FieloELR__QuestionResponse__c = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__Question__r.Name = 'matching options 1' LIMIT 1].Id;
		listAnsResp.add(answer1);

		insert listAnsResp;

		listAnsResp = [SELECT Id FROM FieloELR__Answer__c WHERE Id IN :listAnsResp LIMIT 1];

		System.assertEquals(1, listAnsResp.size());
	}

	/*	TEST-1808
		Create Answer
		- Validations
		- The “Answer Option” is null (NOK)
	*/
	@isTest	static void ELR_0009_FA3(){

		answer1.FieloELR__QuestionResponse__c = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__Question__r.Name = 'statement 1' LIMIT 1].Id;

		listAnsResp.add(answer1);

		try{
    		insert listAnsResp;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('The answer is required.'));
		}
	}

	/*	TEST-1809
		Create Answer
		- Validations
		- The “Answer Option” and the “Question Response” don’t belong to the same question (NOK)
	*/
	@isTest	static void ELR_0009_FA4(){
		answer1.FieloELR__QuestionResponse__c = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__Question__r.Name = 'statement 1' LIMIT 1].Id;
		answer1.FieloELR__AnswerOption__c = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__r.Name ='single choice 1' LIMIT 1].Id;

		listAnsResp.add(answer1);

		try{
    		insert listAnsResp;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('The answer must belong to the same question.'));
		}
	}

	/*	TEST-1810
		Create Answer
		- Validations
		- There is already an Answer with the same question response and answer option (NOK)
	*/
	@isTest	static void ELR_0009_FA5(){
		answer1.FieloELR__QuestionResponse__c = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__Question__r.Name = 'statement 2' LIMIT 1].Id;
		answer1.FieloELR__AnswerOption__c = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__r.Name ='statement 2' LIMIT 1].Id;
		listAnsResp.add(answer1);

		answer2.FieloELR__QuestionResponse__c = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__Question__r.Name = 'single choice 2' LIMIT 1].Id;
		answer2.FieloELR__AnswerOption__c = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__r.Name ='single choice 2' LIMIT 1].Id;
		listAnsResp.add(answer2);

		answer3.FieloELR__QuestionResponse__c = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__Question__r.Name = 'multiple choice 2' LIMIT 1].Id;
		answer3.FieloELR__AnswerOption__c = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__r.Name ='multiple choice 2' LIMIT 1].Id;
		listAnsResp.add(answer3);

		try{
    		insert listAnsResp;
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('This answer already exists.'));
		}
	}

	/*	TEST-1811
		Create Answer
		- Delete answer when the related question response is not submitted (OK)
	*/
	@isTest	static void ELR_0009_FA6(){
		listAnsResp = [SELECT Id FROM FieloELR__Answer__c WHERE FieloELR__QuestionResponse__r.FieloELR__Question__r.Name = 'statement 2' LIMIT 1];

		delete listAnsResp.get(0);

		listAnsResp = [SELECT Id FROM FieloELR__Answer__c WHERE Id IN :listAnsResp LIMIT 1];

    	System.assertEquals(0, listAnsResp.size());
	}

	/*	TEST-1812
		Create Answer
		- Validations
		- Delete answer when the related question response is submitted (NOK)
	*/
	@isTest	static void ELR_0009_FA7(){
		listAnsResp = [SELECT Id FROM FieloELR__Answer__c WHERE FieloELR__QuestionResponse__r.FieloELR__Question__r.Name = 'multiple choice 1' LIMIT 1];

		try{
    		delete listAnsResp.get(0);
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('Question responses already submitted cannot have new answers or their existing ones updated or deleted.'));
		}
	}

	/*	TEST-1813
		Create Answer
		- Validations
		- Edit answer (NOK)
	*/
	@isTest	static void ELR_0009_FA8(){
		listAnsResp = [SELECT Id FROM FieloELR__Answer__c WHERE FieloELR__QuestionResponse__r.FieloELR__Question__r.Name = 'statement 2' LIMIT 1];

		listAnsResp.get(0).FieloELR__AnswerOption__c = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__r.Name ='multiple choice 2' LIMIT 1].Id;

		try{
    		update listAnsResp.get(0);
		}catch(System.DmlException d){
			System.assert(d.getMessage().Contains('An answer cannot be edited'));
		}
	}

	/*	TEST-1805
		Create Answer
		- Related question type is not “Matching Options” (OK)
	*/
	@isTest	static void ELR_0009_FB(){

		answer1.FieloELR__QuestionResponse__c = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__Question__r.Name = 'statement 1' LIMIT 1].Id;
		answer1.FieloELR__AnswerOption__c = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__r.Name ='statement 1' LIMIT 1].Id;
		listAnsResp.add(answer1);

		answer2.FieloELR__QuestionResponse__c = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__Question__r.Name = 'single choice 1' LIMIT 1].Id;
		answer2.FieloELR__AnswerOption__c = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__r.Name ='single choice 1' LIMIT 1].Id;
		listAnsResp.add(answer2);

		answer3.FieloELR__QuestionResponse__c = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__IsSubmitted__c = false AND FieloELR__Question__r.Name = 'multiple choice 1' LIMIT 1].Id;
		answer3.FieloELR__AnswerOption__c = [SELECT Id FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__r.Name ='multiple choice 1' LIMIT 1].Id;
		listAnsResp.add(answer3);

		insert listAnsResp;

		listAnsResp = [SELECT Id FROM FieloELR__Answer__c WHERE Id IN :listAnsResp LIMIT 3];

		System.assertEquals(3, listAnsResp.size());
	}
}