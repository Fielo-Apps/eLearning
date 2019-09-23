@isTest
private class TestSubmitQuestionResponse {
    private static List<FieloELR__QuestionResponse__c> questionResponses = new List<FieloELR__QuestionResponse__c>();
    private static List<FieloELR__ModuleResponse__c> moduleResponses = new List<FieloELR__ModuleResponse__c>();
    private static List<FieloELR__CourseStatus__c> courseStatus = new List<FieloELR__CourseStatus__c>();
    
    @testSetup static void setup() {
        List<FieloELR__Course__c> courses = new List<FieloELR__Course__c>();            
        List<FieloELR__Question__c> questions = new List<FieloELR__Question__c>();
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
        FieloELR__Module__c moduleTest1 = new FieloELR__Module__c();
        moduleTest1.Name = 'Basic';
        moduleTest1.FieloELR__Course__c = courses.get(0).id;
        moduleTest1.FieloELR__ApprovalGrade__c = 0;
        moduleTest1.FieloELR__AttemptsAllowed__c = 2;
        moduleTest1.FieloELR__AttemptsAllowedPerQuestion__c = 2;
        moduleTest1.FieloELR__PenaltyMode__c = 'None';
        modules.add(moduleTest1);

        insert modules;

        //Basic Module Questions
        questions.add(
            new FieloELR__Question__c(
                Name = 'Q1',
                FieloELR__Module__c = modules.get(0).Id,
                FieloELR__QuestionText__c = 'Which one is the most popular programming language?',
                FieloELR__Type__c = 'Single Choice'
            )
        );

        questions.add(
            new FieloELR__Question__c(
                Name = 'Q2',
                FieloELR__Module__c = modules.get(0).Id,
                FieloELR__QuestionText__c = 'Acronymn for Personal Computer',
                FieloELR__Type__c = 'Short Answer'
            )
        );

        questions.add(
            new FieloELR__Question__c(
                Name = 'Q3',
                FieloELR__Module__c = modules.get(0).Id,
                FieloELR__QuestionText__c = 'Which of the following are Family-C programming languages?',
                FieloELR__Type__c = 'Multiple Choice'
            )
        );

        questions.add(
            new FieloELR__Question__c(
                Name = 'Q4',
                FieloELR__Module__c = modules.get(0).Id,
                FieloELR__QuestionText__c = 'C++ is more performatic than java',
                FieloELR__Type__c = 'Statement'
            )
        );

        questions.add(
            new FieloELR__Question__c(
                Name = 'Q5',
                FieloELR__Module__c = modules.get(0).Id,
                FieloELR__QuestionText__c = 'Match statement with its meaning',
                FieloELR__Type__c = 'Matching Options'
            )
        );
        insert questions;

        // Answers Q1
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'Java'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'C++'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'SQL'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'PHP'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = true, AnswerOptionText__c = 'JavaScript'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'HTML'));

        // Answers Q2
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'PC'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'pc'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'p.c.'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'P.C.'));

        // Answers Q3
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'C++'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'Java'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'PHP'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'Python'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'Objective-C'));

        // Answers Q4
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(3).Id, IsCorrect__c = true, AnswerOptionText__c = 'True'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(3).Id, IsCorrect__c = false, AnswerOptionText__c = 'False'));

        // Answers Q5
        answersOpList.add(new AnswerOption__c( Question__c = questions.get(4).Id, IsCorrect__c = true, AnswerOptionText__c = 'if', MatchingText__c = 'conditional'));
        answersOpList.add(new AnswerOption__c( Question__c = questions.get(4).Id, IsCorrect__c = true, AnswerOptionText__c = 'for', MatchingText__c = 'loop'));
        answersOpList.add(new AnswerOption__c( Question__c = questions.get(4).Id, IsCorrect__c = true, AnswerOptionText__c = 'while', MatchingText__c = 'loop'));
        answersOpList.add(new AnswerOption__c( Question__c = questions.get(4).Id, IsCorrect__c = true, AnswerOptionText__c = 'break', MatchingText__c = 'exit loop'));

        insert answersOpList;

        //Set Module Active
        modules.get(0).IsActive__c = true;
        update modules;

        //Set Course Active
        courses.get(0).Status__c = 'Active';
        update courses;

        //Course Status
        FieloELR__CourseStatus__c courseStatusTest = new FieloELR__CourseStatus__c();
        courseStatusTest.FieloELR__Course__c = courses.get(0).id;
        courseStatusTest.FieloELR__Member__c = members.get(0).id;
        courseStatus.add(courseStatusTest);
        insert courseStatus;

        //Module Response
        FieloELR__ModuleResponse__c moduleResponseTest = new FieloELR__ModuleResponse__c();
        moduleResponseTest.FieloELR__Module__c = modules.get(0).id;
        moduleResponseTest.FieloELR__Member__c = members.get(0).id;
        moduleResponses.add(moduleResponseTest);
        insert moduleResponses;

        //Question Response
        questionResponses.add( new QuestionResponse__c(Question__c = questions.get(0).Id, ModuleResponse__c = moduleResponses.get(0).Id));
        questionResponses.add( new QuestionResponse__c(Question__c = questions.get(1).Id, ModuleResponse__c = moduleResponses.get(0).Id));
        questionResponses.add( new QuestionResponse__c(Question__c = questions.get(2).Id, ModuleResponse__c = moduleResponses.get(0).Id));
        questionResponses.add( new QuestionResponse__c(Question__c = questions.get(3).Id, ModuleResponse__c = moduleResponses.get(0).Id));
        questionResponses.add( new QuestionResponse__c(Question__c = questions.get(4).Id, ModuleResponse__c = moduleResponses.get(0).Id));
        insert questionResponses;
    }

    /* TEST-1824
        Submit Question Response
        - “IsCorrect” field is set to “true” and the related module “Penalty Mode” is set to “None” (OK)
    */    
    @isTest static void ELR_0012_FB() {
        questionResponses = [SELECT Id, Question__c, IsSubmitted__c, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Name = 'Q1' LIMIT 1];
        List<FieloELR__Question__c> questions = [SELECT Id, (SELECT Id, FieloELR__AnswerOptionText__c FROM AnswerOptions__r Where IsCorrect__c = true) FROM Question__c Where Id = :questionResponses.get(0).Question__c LIMIT 1];

        List<Answer__c> answers = new List<Answer__c>();
        for (AnswerOption__c ao: questions.get(0).AnswerOptions__r) {
            answers.add(
                new Answer__c(
                    AnswerOption__c = ao.Id,
                    QuestionResponse__c = questionResponses.get(0).Id
                )
            );
        }
        insert answers;

        questionResponses.get(0).FieloELR__IsSubmitted__c = true;
        
        update questionResponses;

        questionResponses = [SELECT Id, Question__c, IsSubmitted__c, IsCorrect__c, PartialGradeValue__c FROM QuestionResponse__c WHERE Question__r.Name = 'Q1' LIMIT 1];

        System.assertEquals(true, questionResponses.get(0).IsSubmitted__c);
        System.assertEquals(true, questionResponses.get(0).IsCorrect__c);
        System.assert(questionResponses.get(0).PartialGradeValue__c != null);
    }

    
    /*  TEST-1825
        Submit Question Response
        - “IsCorrect” field is set to “false” and the related module “Penalty Mode” is set to “None” (OK)
    */
    @isTest static void ELR_0012_FA1(){
        questionResponses = [SELECT Id, Question__c, IsSubmitted__c, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Name = 'Q1' LIMIT 1];
        List<FieloELR__Question__c> questions = [SELECT Id, (SELECT Id, FieloELR__AnswerOptionText__c FROM AnswerOptions__r Where IsCorrect__c = false LIMIT 1) FROM Question__c Where Id = :questionResponses.get(0).Question__c LIMIT 1];

        List<Answer__c> answers = new List<Answer__c>();
        for (AnswerOption__c ao: questions.get(0).AnswerOptions__r) {
            answers.add(
                new Answer__c(
                    AnswerOption__c = ao.Id,
                    QuestionResponse__c = questionResponses.get(0).Id
                )
            );
        }
        insert answers;

        questionResponses.get(0).FieloELR__IsSubmitted__c = true;
        
        update questionResponses;

        questionResponses = [SELECT Id, Question__c, IsSubmitted__c, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Name = 'Q1' LIMIT 1];

        System.assertEquals(true, questionResponses.get(0).IsSubmitted__c);
        System.assertEquals(false, questionResponses.get(0).IsCorrect__c);
    }

    /*  TEST-1826
        Submit Question Response - “IsCorrect” field is set to “true” and the related module “Penalty Mode” is set to “Negative Weight” (OK)
    */
    @isTest static void ELR_0012_FA2() {
        Course__c course = [SELECT Id, Status__c FROM Course__c LIMIT 1];
        Module__c module = [SELECT Id, IsActive__c FROM Module__c LIMIT 1];

        course.Status__c = 'Inactive';
        module.IsActive__c = false;

        FieloELR.Courses.validateAdminFields = false;
        Update course;
        FieloELR.Courses.validateAdminFields = true;
        FieloELR.Modules.validateAdminFields = false;
        Update module;
        FieloELR.Modules.validateAdminFields = true;

        module.PenaltyMode__c = 'Negative Weight';
        module.IsActive__c = true;

        FieloELR.Modules.validateAdminFields = false;
        Update module;
        FieloELR.Modules.validateAdminFields = true;

        course.Status__c = 'Active';

        FieloELR.Courses.validateAdminFields = false;
        Update course;
        FieloELR.Courses.validateAdminFields = true;

        questionResponses = [SELECT Id, Question__c, IsSubmitted__c, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Name = 'Q1' LIMIT 1];
        List<Question__c> questions = [SELECT Id, (SELECT Id, AnswerOptionText__c FROM AnswerOptions__r Where IsCorrect__c = true) FROM Question__c Where Id = :questionResponses.get(0).Question__c LIMIT 1];

        List<Answer__c> answers = new List<Answer__c>();
        for (AnswerOption__c ao: questions.get(0).AnswerOptions__r) {
            answers.add(
                new Answer__c(
                    AnswerOption__c = ao.Id,
                    QuestionResponse__c = questionResponses.get(0).Id
                )
            );
        }
        insert answers;

        questionResponses.get(0).FieloELR__IsSubmitted__c = true;
        
        update questionResponses;

        questionResponses = [SELECT Id, Question__c, IsSubmitted__c, IsCorrect__c, PartialGradeValue__c FROM QuestionResponse__c WHERE Question__r.Name = 'Q1' LIMIT 1];

        System.assertEquals(true, questionResponses.get(0).IsSubmitted__c);
        System.assertEquals(true, questionResponses.get(0).IsCorrect__c);
        System.assert(questionResponses.get(0).PartialGradeValue__c != null);
    }

    /*  TEST-1827
        Submit Question Response- “IsCorrect” field is set to “false” and the related module “Penalty Mode” is set to “Negative Weight” (OK)
    */
    @isTest static void ELR_0012_FA3() {
        Course__c course = [SELECT Id, Status__c FROM Course__c LIMIT 1];
        Module__c module = [SELECT Id, IsActive__c FROM Module__c LIMIT 1];

        course.Status__c = 'Inactive';
        module.IsActive__c = false;

        FieloELR.Courses.validateAdminFields = false;
        Update course;
        FieloELR.Courses.validateAdminFields = true;
        FieloELR.Modules.validateAdminFields = false;
        Update module;
        FieloELR.Modules.validateAdminFields = true;

        module.PenaltyMode__c = 'Negative Weight';
        module.IsActive__c = true;

        FieloELR.Modules.validateAdminFields = false;
        Update module;
        FieloELR.Modules.validateAdminFields = true;

        course.Status__c = 'Active';

        FieloELR.Courses.validateAdminFields = false;
        Update course;
        FieloELR.Courses.validateAdminFields = true;

        questionResponses = [SELECT Id, Question__c, IsSubmitted__c, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Name = 'Q1' LIMIT 1];
        List<Question__c> questions = [SELECT Id, (SELECT Id, AnswerOptionText__c FROM AnswerOptions__r Where IsCorrect__c = false LIMIT 1) FROM Question__c Where Id = :questionResponses.get(0).Question__c LIMIT 1];

        List<Answer__c> answers = new List<Answer__c>();
        for (AnswerOption__c ao: questions.get(0).AnswerOptions__r) {
            answers.add(
                new Answer__c(
                    AnswerOption__c = ao.Id,
                    QuestionResponse__c = questionResponses.get(0).Id
                )
            );
        }
        insert answers;

        questionResponses.get(0).FieloELR__IsSubmitted__c = true;
        
        update questionResponses;

        questionResponses = [SELECT Id, Question__c, IsSubmitted__c, IsCorrect__c, PartialGradeValue__c FROM QuestionResponse__c WHERE Question__r.Name = 'Q1' LIMIT 1];

        System.assertEquals(true, questionResponses.get(0).IsSubmitted__c);
        System.assertEquals(false, questionResponses.get(0).IsCorrect__c);
        System.assert(questionResponses.get(0).PartialGradeValue__c != null);
    }

    /*  TEST-1828
        Submit Question Response
        - “IsCorrect” field is set to “true” and the related module “Penalty Mode” is set to “Percent Decrease” (OK)
    */
    @isTest static void ELR_0012_FA4() {
        Course__c course = [SELECT Id, Status__c FROM Course__c LIMIT 1];
        Module__c module = [SELECT Id, IsActive__c FROM Module__c LIMIT 1];

        course.Status__c = 'Inactive';
        module.IsActive__c = false;

        FieloELR.Courses.validateAdminFields = false;
        Update course;
        FieloELR.Courses.validateAdminFields = true;
        FieloELR.Modules.validateAdminFields = false;
        Update module;
        FieloELR.Modules.validateAdminFields = true;

        module.PenaltyMode__c = 'Percent Decrease';
        module.IsActive__c = true;

        FieloELR.Modules.validateAdminFields = false;
        Update module;
        FieloELR.Modules.validateAdminFields = true;

        course.Status__c = 'Active';

        FieloELR.Courses.validateAdminFields = false;
        Update course;
        FieloELR.Courses.validateAdminFields = true;

        questionResponses = [SELECT Id, Question__c, IsSubmitted__c, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Name = 'Q1' LIMIT 1];
        List<Question__c> questions = [SELECT Id, (SELECT Id, AnswerOptionText__c FROM AnswerOptions__r Where IsCorrect__c = true) FROM Question__c Where Id = :questionResponses.get(0).Question__c LIMIT 1];

        List<Answer__c> answers = new List<Answer__c>();
        for (AnswerOption__c ao: questions.get(0).AnswerOptions__r) {
            answers.add(
                new Answer__c(
                    AnswerOption__c = ao.Id,
                    QuestionResponse__c = questionResponses.get(0).Id
                )
            );
        }
        insert answers;

        questionResponses.get(0).FieloELR__IsSubmitted__c = true;
        
        update questionResponses;

        questionResponses = [SELECT Id, Question__c, IsSubmitted__c, IsCorrect__c, PartialGradeValue__c FROM QuestionResponse__c WHERE Question__r.Name = 'Q1' LIMIT 1];

        System.assertEquals(true, questionResponses.get(0).IsSubmitted__c);
        System.assertEquals(true, questionResponses.get(0).IsCorrect__c);
        System.assert(questionResponses.get(0).PartialGradeValue__c != null);
    }

    /*  TEST-1829
        Submit Question Response
        - “IsCorrect” field is set to “false” and the related module “Penalty Mode” is set to “Percent Decrease” (OK)
    */
    @isTest static void ELR_0012_FA5() {
        Course__c course = [SELECT Id, Status__c FROM Course__c LIMIT 1];
        Module__c module = [SELECT Id, IsActive__c FROM Module__c LIMIT 1];

        course.Status__c = 'Inactive';
        module.IsActive__c = false;

        FieloELR.Courses.validateAdminFields = false;
        Update course;
        FieloELR.Courses.validateAdminFields = true;
        FieloELR.Modules.validateAdminFields = false;
        Update module;
        FieloELR.Modules.validateAdminFields = true;

        module.PenaltyMode__c = 'Percent Decrease';
        module.IsActive__c = true;

        FieloELR.Modules.validateAdminFields = false;
        Update module;
        FieloELR.Modules.validateAdminFields = true;

        course.Status__c = 'Active';

        FieloELR.Courses.validateAdminFields = false;
        Update course;
        FieloELR.Courses.validateAdminFields = true;

        questionResponses = [SELECT Id, Question__c, IsSubmitted__c, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Name = 'Q1' LIMIT 1];
        List<Question__c> questions = [SELECT Id, (SELECT Id, AnswerOptionText__c FROM AnswerOptions__r Where IsCorrect__c = false LIMIT 1) FROM Question__c Where Id = :questionResponses.get(0).Question__c LIMIT 1];

        List<Answer__c> answers = new List<Answer__c>();
        for (AnswerOption__c ao: questions.get(0).AnswerOptions__r) {
            answers.add(
                new Answer__c(
                    AnswerOption__c = ao.Id,
                    QuestionResponse__c = questionResponses.get(0).Id
                )
            );
        }
        insert answers;

        questionResponses.get(0).FieloELR__IsSubmitted__c = true;
        
        update questionResponses;

        questionResponses = [SELECT Id, Question__c, IsSubmitted__c, IsCorrect__c, PartialGradeValue__c FROM QuestionResponse__c WHERE Question__r.Name = 'Q1' LIMIT 1];

        System.assertEquals(true, questionResponses.get(0).IsSubmitted__c);
        System.assertEquals(false, questionResponses.get(0).IsCorrect__c);
        System.assert(questionResponses.get(0).PartialGradeValue__c != null);
    }
}