@isTest
private class TestSubmitModuleResponse {

    private static List<FieloELR__QuestionResponse__c> questionResponses = new List<FieloELR__QuestionResponse__c>();
    private static List<FieloELR__Answer__c> answers = new List<FieloELR__Answer__c>();
    private static List<FieloELR__ModuleResponse__c> moduleResponses = new List<FieloELR__ModuleResponse__c>();
    private static List<FieloELR__Question__c> questions = new List<FieloELR__Question__c>();
    private static List<FieloELR__CourseStatus__c> courseStatus = new List<FieloELR__CourseStatus__c>();

    static void setup(){
        List<FieloELR__Course__c> courses = new List<FieloELR__Course__c>();
        List<FieloPLT__Member__c> members = new List<FieloPLT__Member__c>();
        List<FieloPLT__Program__c> programs;
        List<FieloPLT__Segment__c> segments;
        List<FieloELR__Module__c> modules = new List<FieloELR__Module__c>();
        List<FieloELR__AnswerOption__c> answersOpList = new List<FieloELR__AnswerOption__c>();
        List<FieloELR__Answer__c> answersList = new List<FieloELR__Answer__c>();

        programs = MockUpFactory.createPrograms('Default', 1);
        insert programs;

        segments = MockUpFactory.createSegments('Segment',1,'Manual');
        insert segments;

        courses = MockUpFactory.createCourses(programs.get(0).id, segments.get(0).id, 1);
        insert courses;

        members = MockUpFactory.createMembers(programs.get(0).id, 1);
        insert members;

        FieloPLT__MemberSegment__c memberSegment = new FieloPLT__MemberSegment__c(
            FieloPLT__Segment__c = segments.get(0).Id,
            FieloPLT__Member__c = members.get(0).Id
        );
        insert memberSegment;

        //Module
        modules.add(new Module__c(Name = 'Basic', Course__c = courses.get(0).id, ApprovalGrade__c = 75, AttemptsAllowed__c = 2, AttemptsAllowedPerQuestion__c = 2, PenaltyMode__c = 'None'));

        insert modules;

        //Basic Module Questions
        questions.add(new Question__c(Name = 'Q1', Module__c = modules.get(0).Id, QuestionText__c = 'Which one is the most popular programming language?', Type__c = 'Short Answer'));
        questions.add(new Question__c(Name = 'Q2', Module__c = modules.get(0).Id, QuestionText__c = 'Acronymn for Personal Computer', Type__c = 'Short Answer'));
        questions.add(new Question__c(Name = 'Q3', Module__c = modules.get(0).Id, QuestionText__c = 'Name one Family-C programming language?', Type__c = 'Short Answer'));
        questions.add(new Question__c(Name = 'Q4', Module__c = modules.get(0).Id, QuestionText__c = 'C++ is more performatic than java', Type__c = 'Short Answer'));

        insert questions;

        // Answers Q1 - Basic
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = true, AnswerOptionText__c = 'JavaScript'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = true, AnswerOptionText__c = 'javascript'));

        // Answers Q2 - Basic
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'PC'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'pc'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'p.c.'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'P.C.'));

        // Answers Q3 - Basic
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'C++'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'c++'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'Java'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'java'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'PHP'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'php'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'Python'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'python'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'Objective-C'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'objective-c'));

        // Answers Q4 - Basic
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(3).Id, IsCorrect__c = true, AnswerOptionText__c = 'True'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(3).Id, IsCorrect__c = true, AnswerOptionText__c = 'true'));

        insert answersOpList;

        //Set Module Active
        modules.get(0).IsActive__c = true;
        update modules;

        //Set Course Active
        courses.get(0).Status__c = 'Active';
        update courses;

        //Course Status
        courseStatus.add(new CourseStatus__c(Course__c = courses.get(0).id, Member__c = members.get(0).id));

        insert courseStatus;

        //Module Response
        moduleResponses.add(new ModuleResponse__c(Module__c = modules.get(0).Id, Member__c = members.get(0).id));

        insert moduleResponses;

        for (Question__c q: questions) {
            questionResponses.add(
                new QuestionResponse__c(
                    Question__c = q.Id,
                    ModuleResponse__c = moduleResponses.get(0).Id
                )
            );
            for (AnswerOption__c ao: answersOpList) {
                if (ao.Question__c == q.Id && ao.IsCorrect__c) {
                    questionResponses.get(questionResponses.size()-1).TextValue__c = ao.AnswerOptionText__c;
                    break;
                }
            }
        }

        insert questionResponses;
	}

    /*  TEST-1830
        Submit Module Response
        - Module response is approved when there are unsubmitted related question responses and the Question Pool is “null” (OK)
    */
	@isTest static void ELR_0010_FB() {
        setup();
		moduleResponses = [SELECT Id, Module__r.QuestionPool__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
		courseStatus = [SELECT Id, ApprovedModules__c, Progress__c FROM CourseStatus__c LIMIT 1];

		moduleResponses.get(0).IsSubmitted__c = true;

        FieloELR.ModuleResponses.validateAdminFields = false;
		update moduleResponses;
        FieloELR.ModuleResponses.validateAdminFields = true;

        questionResponses = [SELECT Id, IsSubmitted__c, PartialGradeValue__c FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id];
        moduleResponses = [SELECT Id, IsApproved__c, NumberofApprove__c, Module__r.QuestionPool__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        courseStatus = [SELECT Id, ApprovedModules__c, Progress__c FROM CourseStatus__c LIMIT 1];

        for (QuestionResponse__c qr: questionResponses) {
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assert(qr.PartialGradeValue__c != null);
        }

        System.assertEquals(true, moduleResponses.get(0).IsApproved__c);
        System.assert(moduleResponses.get(0).NumberofApprove__c > 0);

        System.assertEquals(1, courseStatus.get(0).ApprovedModules__c);

        System.assert(courseStatus.get(0).ApprovedModules__c > 0);
        System.assert(courseStatus.get(0).Progress__c != 0);
    }

    /*  TEST-1831
        Submit Module Response
        - Module response is approved when all the related question responses were submitted and the Question Pool is “null” (OK)
    */
    @isTest static void ELR_0010_FA1() {
        setup();
        moduleResponses = [SELECT Id FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        courseStatus = [SELECT Id FROM CourseStatus__c WHERE Course__r.Name = 'Course 0'];

        moduleResponses.get(0).IsSubmitted__c = true;
        FieloELR.CourseStatus.validateAdminFields = false;
        update moduleResponses;
        FieloELR.CourseStatus.validateAdminFields = true;

        questionResponses = [SELECT Id, IsSubmitted__c, PartialGradeValue__c FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id];
        moduleResponses = [SELECT Id, IsApproved__c, NumberofApprove__c, GradeValue__c, GradePercent__c, Module__r.TotalValue__c, Module__r.QuestionPool__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        courseStatus = [SELECT ApprovedModules__c, Progress__c, Course__r.ActiveModules__c FROM CourseStatus__c WHERE Course__r.Name = 'Course 0'];

        for (QuestionResponse__c qr: questionResponses) {
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assert(qr.PartialGradeValue__c != null);
        }

        System.assertEquals(true, moduleResponses.get(0).IsApproved__c);

        Decimal totalValue = moduleResponses.get(0).Module__r.QuestionPool__c == null ? moduleResponses.get(0).Module__r.TotalValue__c : moduleResponses.get(0).Module__r.QuestionPool__c;

        System.assertEquals(moduleResponses.get(0).GradePercent__c, ((moduleResponses.get(0).GradeValue__c / totalValue) * 100).setScale(2));

        System.assertEquals(true, moduleResponses.get(0).IsApproved__c);

        System.assert(courseStatus.get(0).ApprovedModules__c > 0);

        System.assert(courseStatus.get(0).Progress__c != 0);
    }

    /*  TEST-1832
        Submit Module Response
        - Module response is not approved when there are unsubmitted related question responses and the Question Pool is “null” (OK)
    */
    @isTest static void ELR_0010_FA2() {
        setup();
        moduleResponses = [SELECT Id, Module__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        questionResponses = [SELECT Id, Question__c FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id];
        courseStatus = [SELECT Id FROM CourseStatus__c WHERE Course__r.Name = 'Course 0'];

        Set<Id> questionIds = new Set<Id>();

        for (QuestionResponse__c qr: questionResponses) {
            questionIds.add(qr.Question__c);
        }

        delete questionResponses;

        questionResponses = new List<QuestionResponse__c>();
        questionResponses.clear();
        for (Id questionId: questionIds) {
            questionResponses.add(
                new QuestionResponse__c(
                    Question__c = questionId,
                    ModuleResponse__c = moduleResponses.get(0).Id,
                    TextValue__c = 'Wrong Answer'
                )
            );
        }

        insert questionResponses;

        moduleResponses.get(0).IsSubmitted__c = true;

        FieloELR.CourseStatus.validateAdminFields = false;
        update moduleResponses;
        FieloELR.CourseStatus.validateAdminFields = true;

        questionResponses = [SELECT Id, IsSubmitted__c, PartialGradeValue__c FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id];
        moduleResponses = [SELECT Id, IsApproved__c, NumberofApprove__c, GradeValue__c, GradePercent__c, Module__r.TotalValue__c, Module__r.QuestionPool__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        courseStatus = [SELECT ApprovedModules__c, Progress__c, Course__r.ActiveModules__c FROM CourseStatus__c WHERE Course__r.Name = 'Course 0'];

        for (QuestionResponse__c qr: questionResponses) {
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assert(qr.PartialGradeValue__c != null);
        }

        System.assertEquals(false, moduleResponses.get(0).IsApproved__c);
        System.assert(moduleResponses.get(0).NumberofApprove__c == 0);
        System.assert(courseStatus.get(0).Progress__c == 0);
      }

    /*  TEST-1833
        Submit Module Response
        - Module response is approved when there are unsubmitted related question responses and the Question Pool is not “null” (OK)
    */
    @isTest static void ELR_0010_FA3() {
        setup();
        Test.startTest();
        // Adding Question Pool
        List<Module__c> modules = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic' LIMIT 1];
        List<Course__c> courses = [SELECT Id FROM Course__c WHERE Id = :modules.get(0).Course__c LIMIT 1];
        List<Question__c> questions = [SELECT Id, (SELECT Id, IsCorrect__c, AnswerOptionText__c, Question__c FROM AnswerOptions__r WHERE IsCorrect__c = true) FROM Question__c Where Module__c = :modules.get(0).Id];
        List<CourseStatus__c> courseStatus = [SELECT Id FROM CourseStatus__c WHERE Course__c = :modules.get(0).Course__c LIMIT 1];
        moduleResponses = [SELECT Id, Member__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        questionResponses = [SELECT Id FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id LIMIT 1];

        String memberId = moduleResponses.get(0).Member__c;

        delete questionResponses;
        delete moduleResponses;
        delete courseStatus;

        modules.get(0).IsActive__c = false;
        courses.get(0).Status__c = 'Inactive';

        FieloELR.Courses.validateAdminFields = false;
        FieloELR.Modules.validateAdminFields = false;

        update courses;
        update modules;

        modules.get(0).QuestionPool__c = 4;

        update modules;

        modules.get(0).IsActive__c = true;
        courses.get(0).Status__c = 'Active';

        update modules;
        update courses;

        FieloELR.Courses.validateAdminFields = true;
        FieloELR.Modules.validateAdminFields = true;

        // Recreate
        courseStatus = new List<CourseStatus__c>();
        moduleResponses = new List<ModuleResponse__c>();
        questionResponses = new List<QuestionResponse__c>();

        //Course Status
        courseStatus.add(new CourseStatus__c(Course__c = courses.get(0).id, Member__c = memberId));

        insert courseStatus;

        //Module Response
        moduleResponses.add(new ModuleResponse__c(Module__c = modules.get(0).Id, Member__c = memberId));

        insert moduleResponses;

        List<FieloELR__AnswerOption__c> answersOpList = new List<FieloELR__AnswerOption__c>();
        for (Question__c q: questions) {
            questionResponses.add(
                new QuestionResponse__c(
                    Question__c = q.Id,
                    ModuleResponse__c = moduleResponses.get(0).Id
                )
            );
            answersOpList = q.AnswerOptions__r;
            for (AnswerOption__c ao: answersOpList) {
                if (ao.Question__c == q.Id && ao.IsCorrect__c) {
                    questionResponses.get(questionResponses.size()-1).TextValue__c = ao.AnswerOptionText__c;
                    break;
                }
            }
        }

        insert questionResponses;

        moduleResponses = [SELECT Id FROM FieloELR__ModuleResponse__c WHERE FieloELR__Module__r.Name = 'Basic' LIMIT 1];
        questionResponses = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__ModuleResponse__r.Id =: moduleResponses.get(0).id LIMIT 1];
        courseStatus = [SELECT Id FROM FieloELR__CourseStatus__c WHERE FieloELR__Course__r.Name = 'Course 1'];

        moduleResponses.get(0).IsSubmitted__c = true;
        FieloELR.CourseStatus.validateAdminFields = false;
        update moduleResponses;
        FieloELR.CourseStatus.validateAdminFields = true;

        questionResponses = [SELECT Id, IsSubmitted__c, PartialGradeValue__c FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id];
        moduleResponses = [SELECT Id, IsApproved__c, NumberofApprove__c, GradeValue__c, GradePercent__c, Module__r.TotalValue__c, Module__r.QuestionPool__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        courseStatus = [SELECT ApprovedModules__c, Progress__c, Course__r.ActiveModules__c FROM CourseStatus__c WHERE Course__r.Name = 'Course 0'];

        for (QuestionResponse__c qr: questionResponses) {
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assert(qr.PartialGradeValue__c != null);
        }

        System.assertEquals(true, moduleResponses.get(0).IsApproved__c);

        Decimal totalValue = moduleResponses.get(0).Module__r.QuestionPool__c == null ? moduleResponses.get(0).Module__r.TotalValue__c : moduleResponses.get(0).Module__r.QuestionPool__c;

        System.assertEquals(moduleResponses.get(0).GradePercent__c, ((moduleResponses.get(0).GradeValue__c / totalValue) * 100).setScale(2));

        System.assertEquals(true, moduleResponses.get(0).IsApproved__c);

        System.assert(courseStatus.get(0).ApprovedModules__c > 0);

        System.assert(courseStatus.get(0).Progress__c != 0);
        Test.stopTest();
    }

    /*  TEST-1834
        Submit Module Response
        - Module response is not approved when there are unsubmitted related question responses and the Question Pool is not “null” (OK)
    */
    @isTest static void ELR_0010_FA4() {
        setup();
        // Adding Question Pool
        List<Module__c> modules = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic' LIMIT 1];
        List<Course__c> courses = [SELECT Id FROM Course__c WHERE Id = :modules.get(0).Course__c LIMIT 1];
        List<Question__c> questions = [SELECT Id, (SELECT Id, IsCorrect__c, AnswerOptionText__c, Question__c FROM AnswerOptions__r WHERE IsCorrect__c = true) FROM Question__c Where Module__c = :modules.get(0).Id];
        List<CourseStatus__c> courseStatus = [SELECT Id FROM CourseStatus__c WHERE Course__c = :modules.get(0).Course__c LIMIT 1];
        moduleResponses = [SELECT Id, Member__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        questionResponses = [SELECT Id FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id LIMIT 1];

        String memberId = moduleResponses.get(0).Member__c;

        delete questionResponses;
        delete moduleResponses;
        delete courseStatus;

        modules.get(0).IsActive__c = false;
        courses.get(0).Status__c = 'Inactive';

        FieloELR.Courses.validateAdminFields = false;
        FieloELR.Modules.validateAdminFields = false;

        update courses;
        update modules;

        modules.get(0).QuestionPool__c = 4;

        update modules;

        modules.get(0).IsActive__c = true;
        courses.get(0).Status__c = 'Active';

        update modules;
        update courses;

        FieloELR.Courses.validateAdminFields = true;
        FieloELR.Modules.validateAdminFields = true;

        // Recreate
        courseStatus = new List<CourseStatus__c>();
        moduleResponses = new List<ModuleResponse__c>();
        questionResponses = new List<QuestionResponse__c>();

        //Course Status
        courseStatus.add(new CourseStatus__c(Course__c = courses.get(0).id, Member__c = memberId));

        insert courseStatus;

        //Module Response
        moduleResponses.add(new ModuleResponse__c(Module__c = modules.get(0).Id, Member__c = memberId));

        insert moduleResponses;

        for (Question__c q: questions) {
            questionResponses.add(
                new QuestionResponse__c(
                    Question__c = q.Id,
                    ModuleResponse__c = moduleResponses.get(0).Id,
                    TextValue__c = 'Wrong Answer'
                )
            );
        }

        insert questionResponses;

        moduleResponses = [SELECT Id FROM FieloELR__ModuleResponse__c WHERE FieloELR__Module__r.Name = 'Basic' LIMIT 1];
        questionResponses = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__ModuleResponse__r.Id =: moduleResponses.get(0).id LIMIT 1];
        courseStatus = [SELECT Id FROM FieloELR__CourseStatus__c WHERE FieloELR__Course__r.Name = 'Course 1'];

        moduleResponses.get(0).IsSubmitted__c = true;
        FieloELR.CourseStatus.validateAdminFields = false;
        update moduleResponses;
        FieloELR.CourseStatus.validateAdminFields = true;

        questionResponses = [SELECT Id, IsSubmitted__c, PartialGradeValue__c FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id];
        moduleResponses = [SELECT Id, IsApproved__c, NumberofApprove__c, GradeValue__c, GradePercent__c, Module__r.TotalValue__c, Module__r.QuestionPool__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        courseStatus = [SELECT ApprovedModules__c, Progress__c, Course__r.ActiveModules__c FROM CourseStatus__c WHERE Course__r.Name = 'Course 0'];

        for (QuestionResponse__c qr: questionResponses) {
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assert(qr.PartialGradeValue__c != null);
        }

        System.assertEquals(false, moduleResponses.get(0).IsApproved__c);
        System.assert(moduleResponses.get(0).NumberofApprove__c == 0);
        System.assert(courseStatus.get(0).Progress__c == 0);
    }

    /*  TEST-1835
        Submit Module Response
        - Module response is not approved when all the related question responses were submitted and the Question Pool is “null” (OK)
    */
    @isTest static void ELR_0010_FA5() {
        setup();
        moduleResponses = [SELECT Id FROM FieloELR__ModuleResponse__c WHERE FieloELR__Module__r.Name = 'Basic' LIMIT 1];
        questionResponses = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__ModuleResponse__r.Id =: moduleResponses.get(0).id];
        courseStatus = [SELECT Id FROM FieloELR__CourseStatus__c WHERE FieloELR__Course__r.Name = 'Course 1'];

        for (QuestionResponse__c qr: questionResponses) {
            qr.TextValue__c = 'Wrong Answer';
            qr.IsSubmitted__c = true;
        }

        update questionResponses;


        moduleResponses.get(0).IsSubmitted__c = true;
        FieloELR.CourseStatus.validateAdminFields = false;
        update moduleResponses;
        FieloELR.CourseStatus.validateAdminFields = true;

        questionResponses = [SELECT Id, IsSubmitted__c, PartialGradeValue__c FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id];
        moduleResponses = [SELECT Id, IsApproved__c, NumberofApprove__c, GradeValue__c, GradePercent__c, Module__r.TotalValue__c, Module__r.QuestionPool__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        courseStatus = [SELECT ApprovedModules__c, Progress__c, Course__r.ActiveModules__c FROM CourseStatus__c WHERE Course__r.Name = 'Course 0'];

        for (QuestionResponse__c qr: questionResponses) {
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assert(qr.PartialGradeValue__c != null);
        }

        System.assertEquals(false, moduleResponses.get(0).IsApproved__c);
        System.assert(moduleResponses.get(0).NumberofApprove__c == 0);
        System.assert(courseStatus.get(0).Progress__c == 0);
    }

    /*  TEST-1836
        Submit Module Response
        - Module response is approved when all the related question responses were submitted and the Question Pool is not “null” (OK)
    */
    @isTest static void ELR_0010_FA6() {
        setup();
        moduleResponses = [SELECT Id FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        courseStatus = [SELECT Id FROM CourseStatus__c WHERE Course__r.Name = 'Course 0'];
        questionResponses = [SELECT Id, IsSubmitted__c, PartialGradeValue__c FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id];

        for (QuestionResponse__c qr: questionResponses) {
            qr.IsSubmitted__c = true;
        }
        update questionResponses;

        moduleResponses.get(0).IsSubmitted__c = true;
        FieloELR.CourseStatus.validateAdminFields = false;
        update moduleResponses;
        FieloELR.CourseStatus.validateAdminFields = true;

        questionResponses = [SELECT Id, IsSubmitted__c, PartialGradeValue__c FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id];
        moduleResponses = [SELECT Id, IsApproved__c, NumberofApprove__c, GradeValue__c, GradePercent__c, Module__r.TotalValue__c, Module__r.QuestionPool__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        courseStatus = [SELECT ApprovedModules__c, Progress__c, Course__r.ActiveModules__c FROM CourseStatus__c WHERE Course__r.Name = 'Course 0'];

        for (QuestionResponse__c qr: questionResponses) {
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assert(qr.PartialGradeValue__c != null);
        }

        System.assertEquals(true, moduleResponses.get(0).IsApproved__c);

        Decimal totalValue = moduleResponses.get(0).Module__r.QuestionPool__c == null ? moduleResponses.get(0).Module__r.TotalValue__c : moduleResponses.get(0).Module__r.QuestionPool__c;

        System.assertEquals(moduleResponses.get(0).GradePercent__c, ((moduleResponses.get(0).GradeValue__c / totalValue) * 100).setScale(2));

        System.assertEquals(true, moduleResponses.get(0).IsApproved__c);

        System.assert(courseStatus.get(0).ApprovedModules__c > 0);

        System.assert(courseStatus.get(0).Progress__c != 0);
    }

    /*  TEST-1837
        Submit Module Response
        - Module response is not approved when all the related question responses were submitted and the Question Pool is not “null” (OK)
    */
    @isTest static void ELR_0010_FA7() {
        setup();
        // Adding Question Pool
        List<Module__c> modules = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic' LIMIT 1];
        List<Course__c> courses = [SELECT Id FROM Course__c WHERE Id = :modules.get(0).Course__c LIMIT 1];
        List<Question__c> questions = [SELECT Id, (SELECT Id, IsCorrect__c, AnswerOptionText__c, Question__c FROM AnswerOptions__r WHERE IsCorrect__c = true) FROM Question__c Where Module__c = :modules.get(0).Id];
        List<CourseStatus__c> courseStatus = [SELECT Id FROM CourseStatus__c WHERE Course__c = :modules.get(0).Course__c LIMIT 1];
        moduleResponses = [SELECT Id, Member__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        questionResponses = [SELECT Id FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id LIMIT 1];

        String memberId = moduleResponses.get(0).Member__c;

        delete questionResponses;
        delete moduleResponses;
        delete courseStatus;

        modules.get(0).IsActive__c = false;
        courses.get(0).Status__c = 'Inactive';

        FieloELR.Courses.validateAdminFields = false;
        FieloELR.Modules.validateAdminFields = false;

        update courses;
        update modules;

        modules.get(0).QuestionPool__c = 4;

        update modules;

        modules.get(0).IsActive__c = true;
        courses.get(0).Status__c = 'Active';

        update modules;
        update courses;

        FieloELR.Courses.validateAdminFields = true;
        FieloELR.Modules.validateAdminFields = true;

        // Recreate
        courseStatus = new List<CourseStatus__c>();
        moduleResponses = new List<ModuleResponse__c>();
        questionResponses = new List<QuestionResponse__c>();

        //Course Status
        courseStatus.add(new CourseStatus__c(Course__c = courses.get(0).id, Member__c = memberId));

        insert courseStatus;

        //Module Response
        moduleResponses.add(new ModuleResponse__c(Module__c = modules.get(0).Id, Member__c = memberId));

        insert moduleResponses;

        for (Question__c q: questions) {
            questionResponses.add(
                new QuestionResponse__c(
                    Question__c = q.Id,
                    ModuleResponse__c = moduleResponses.get(0).Id,
                    TextValue__c = 'Wrong Answer',
                    IsSubmitted__c = true
                )
            );
        }

        insert questionResponses;

        moduleResponses = [SELECT Id FROM FieloELR__ModuleResponse__c WHERE FieloELR__Module__r.Name = 'Basic' LIMIT 1];
        questionResponses = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__ModuleResponse__r.Id =: moduleResponses.get(0).id LIMIT 1];
        courseStatus = [SELECT Id FROM FieloELR__CourseStatus__c WHERE FieloELR__Course__r.Name = 'Course 1'];

        moduleResponses.get(0).IsSubmitted__c = true;
        update moduleResponses;

        questionResponses = [SELECT Id, IsSubmitted__c, PartialGradeValue__c FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id];
        moduleResponses = [SELECT Id, IsApproved__c, NumberofApprove__c, GradeValue__c, GradePercent__c, Module__r.TotalValue__c, Module__r.QuestionPool__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        courseStatus = [SELECT ApprovedModules__c, Progress__c, Course__r.ActiveModules__c FROM CourseStatus__c WHERE Course__r.Name = 'Course 0'];

        for (QuestionResponse__c qr: questionResponses) {
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assertEquals(true, qr.IsSubmitted__c);
            System.assert(qr.PartialGradeValue__c != null);
        }

        System.assertEquals(false, moduleResponses.get(0).IsApproved__c);
        System.assert(moduleResponses.get(0).NumberofApprove__c == 0);
        System.assert(courseStatus.get(0).Progress__c == 0);
    }

    /*  TEST-1955
        Submit Module Response
        - Validations
        - Related course is not active (NOK)
    */
    @isTest static void ELR_0010_FA8() {
        setup();
        //Inactivate Course
        List<Module__c> modules = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic' LIMIT 1];
        List<Course__c> courses = [SELECT Id FROM Course__c WHERE Id = :modules.get(0).Course__c LIMIT 1];

        courses.get(0).Status__c = 'Inactivate';

        FieloELR.Courses.validateAdminFields = false;
        update courses;
        FieloELR.Courses.validateAdminFields = true;

        moduleResponses = [SELECT Id FROM FieloELR__ModuleResponse__c WHERE FieloELR__Module__r.Name = 'Basic' LIMIT 1];
        questionResponses = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__ModuleResponse__r.Id =: moduleResponses.get(0).id];
        courseStatus = [SELECT Id FROM FieloELR__CourseStatus__c WHERE FieloELR__Course__r.Name = 'Course 1'];

        update questionResponses;


        moduleResponses.get(0).IsSubmitted__c = true;

        try {
            update moduleResponses;
        } catch (Exception e) {}

        questionResponses = [SELECT Id, IsSubmitted__c, PartialGradeValue__c FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id];
        moduleResponses = [SELECT Id, IsApproved__c, IsSubmitted__c, NumberofApprove__c, GradeValue__c, GradePercent__c, Module__r.TotalValue__c, Module__r.QuestionPool__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        courseStatus = [SELECT ApprovedModules__c, Progress__c, Course__r.ActiveModules__c FROM CourseStatus__c WHERE Course__r.Name = 'Course 0'];

        for (QuestionResponse__c qr: questionResponses) {
            System.assertEquals(false, qr.IsSubmitted__c);
            System.assertEquals(false, qr.IsSubmitted__c);
        }

        System.assertEquals(false, moduleResponses.get(0).IsApproved__c);
        System.assertEquals(false, moduleResponses.get(0).IsSubmitted__c);
    }

    /*  TEST-1956
        Submit Module Response
        - Validations
        - Related module is not active (NOK)
    */
    @isTest static void ELR_0010_FA9() {
        setup();
        //Inactivate Course
        List<Module__c> modules = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic' LIMIT 1];
        List<Course__c> courses = [SELECT Id FROM Course__c WHERE Id = :modules.get(0).Course__c LIMIT 1];

        courses.get(0).Status__c = 'Inactivate';
        modules.get(0).IsActive__c = false;

        FieloELR.Courses.validateAdminFields = false;
        FieloELR.Modules.validateAdminFields = false;
        update courses;
        update modules;
        FieloELR.Modules.validateAdminFields = true;
        FieloELR.Courses.validateAdminFields = true;

        moduleResponses = [SELECT Id FROM FieloELR__ModuleResponse__c WHERE FieloELR__Module__r.Name = 'Basic' LIMIT 1];
        questionResponses = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__ModuleResponse__r.Id =: moduleResponses.get(0).id];
        courseStatus = [SELECT Id FROM FieloELR__CourseStatus__c WHERE FieloELR__Course__r.Name = 'Course 1'];

        update questionResponses;


        moduleResponses.get(0).IsSubmitted__c = true;

        try {
            update moduleResponses;
        } catch (Exception e) {}

        questionResponses = [SELECT Id, IsSubmitted__c, PartialGradeValue__c FROM QuestionResponse__c WHERE ModuleResponse__r.Id =: moduleResponses.get(0).id];
        moduleResponses = [SELECT Id, IsApproved__c, IsSubmitted__c, NumberofApprove__c, GradeValue__c, GradePercent__c, Module__r.TotalValue__c, Module__r.QuestionPool__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        courseStatus = [SELECT ApprovedModules__c, Progress__c, Course__r.ActiveModules__c FROM CourseStatus__c WHERE Course__r.Name = 'Course 0'];

        for (QuestionResponse__c qr: questionResponses) {
            System.assertEquals(false, qr.IsSubmitted__c);
            System.assertEquals(false, qr.IsSubmitted__c);
        }

        System.assertEquals(false, moduleResponses.get(0).IsApproved__c);
        System.assertEquals(false, moduleResponses.get(0).IsSubmitted__c);
    }
}