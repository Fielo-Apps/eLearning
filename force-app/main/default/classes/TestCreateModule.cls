@isTest
private class TestCreateModule{

    private static List<FieloPLT__Program__c> programs;
    private static List<FieloPLT__Segment__c> segments;
    private static List<FieloELR__Course__c> courses;
    private static List<FieloPLT__Member__c> members;
    private static List<FieloELR__Question__c>  questions = new List<FieloELR__Question__c>();
    private static List<FieloELR__Module__c> modules = new List<FieloELR__Module__c>();
    private static List<FieloELR__AnswerOption__c> answers = new List<FieloELR__AnswerOption__c>();
    private static List<FieloELR__ModuleResponse__c> moduleResponses = new List<FieloELR__ModuleResponse__c>();
    private static List<FieloELR__CourseStatus__c> courseStatus = new List<FieloELR__CourseStatus__c>();
    private static List<FieloELR__ModuleDependency__c> moduleDependencies = new List<FieloELR__ModuleDependency__c>();

    private static FieloELR__Module__c setupModuleTest(){
        FieloELR__Module__c moduleTest = new FieloELR__Module__c(Name = 'moduleTest', FieloELR__ApprovalGrade__c = 50, FieloELR__WeightedQuestions__c = false, FieloELR__Order__c = 1, FieloELR__IsActive__c= false, FieloELR__Description__c = 'Description');
        return moduleTest;
    }

    private static void setupInactiveModuleResponse(){
        // Module
        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];
        modules.get(0).FieloELR__IsActive__c = true;
        update modules.get(0);

        courses = [SELECT Id, FieloELR__Program__c, FieloELR__Status__c FROM FieloELR__Course__c WHERE Id = : modules.get(0).FieloELR__Course__c];
        courses.get(0).FieloELR__Status__c = 'Active';
        update courses.get(0);

        courses.get(0).FieloELR__Status__c = 'Active';
        update courses.get(0);

        members = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE FieloPLT__Program__c = : courses.get(0).FieloELR__Program__c];

        courseStatus.add(new FieloELR__CourseStatus__c(FieloELR__Member__c = members.get(0).Id, FieloELR__Course__c =  modules.get(0).FieloELR__Course__c));
        insert courseStatus;

        // Module Response
        moduleResponses.add(new FieloELR__ModuleResponse__c(FieloELR__Module__c = modules.get(0).Id, FieloELR__Member__c = members.get(0).Id, FieloELR__CourseStatus__c = courseStatus.get(0).Id, FieloELR__IsApproved__c = true));
        insert moduleResponses;

        courses.get(0).FieloELR__Status__c = 'Draft';
        update courses.get(0);
        modules.get(0).FieloELR__IsActive__c = false;
        update modules.get(0);
    }

    static void setup(){
        // Must be at least 10
        Integer testQuantity = 11;
        // Programs
        programs = MockUpFactory.createPrograms('testProgram', testQuantity);
        insert programs;

        // Segments
        segments = MockUpFactory.createSegments('testSegment', testQuantity ,'Dynamic');
        for (Integer i = 0; i < segments.size(); i++){
            segments.get(i).FieloPLT__Program__c = programs.get(i).Id;
        }
        insert segments;

        // Courses
        courses = MockUpFactory.createCourses(programs.get(0).id, segments.get(0).id, testQuantity);
        for (Integer i = 0; i < courses.size(); i++){
            courses.get(i).FieloELR__Description__c = 'TestCourse';
            courses.get(i).FieloELR__Program__c = programs.get(i).Id;
            courses.get(i).FieloELR__Segment__c = segments.get(i).Id;
            courses.get(i).FieloELR__Status__c = 'Draft';
            courses.get(i).FieloELR__Order__c = i;
        }
        insert courses;

        // Members
        members = MockUpFactory.createMembers(programs.get(0).id, testQuantity);
        for (Integer i = 0; i < members.size(); i++){
            members.get(i).FieloPLT__Program__c = programs.get((math.mod(i,2) == 0) ? i : i - 1).Id;
        }
        insert members;

        // Modules
        for (Integer i = 0; i < testQuantity; i++){
            modules.add(new FieloELR__Module__c(Name = 'testModule ' + i, FieloELR__Course__c = courses.get(i).Id, FieloELR__ApprovalGrade__c = 50, FieloELR__WeightedQuestions__c = true, FieloELR__PenaltyMode__c = 'Percent Decrease', FieloELR__Description__c = 'testDescription'));
        }
        insert modules;

        // Questions
        for (Integer i = 0; i < testQuantity; i++){
            questions.add(new FieloELR__Question__c(Name = 'Question ' + i, FieloELR__Module__c = ((i == testQuantity) ? null : modules.get(i).Id), FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c =( (i == testQuantity) ? null : 'Statement'), FieloELR__PenaltyPerAttempt__c = i, FieloELR__CorrectWeight__c = i + 1));
        }
        insert questions;

        // Answers
        for (Integer i = 0; i < testQuantity; i++){
            answers.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(i).Id, FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Very well done, that is a correct answer!'));
            answers.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(i).Id, FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Very well done, that is a incorrect answer!'));
        }
        insert answers;

        // Activate Modules
        for (Integer i = 0; i < modules.size(); i++){
            modules.get(i).FieloELR__IsActive__c = false;
        }
        update modules;

        // Activate some Courses
        for (Integer i = 0; i < courses.size(); i++){
            courses.get(i).FieloELR__Status__c = 'Draft';
        }
        update courses;

        /////////////////

        // Modules with questions and answers
        modules.clear();
        modules.add(new FieloELR__Module__c(Name = 'testModuleWithQuestionsAndAnswers', FieloELR__Course__c = courses.get(1).Id, FieloELR__ApprovalGrade__c = 50, FieloELR__WeightedQuestions__c = true, FieloELR__PenaltyMode__c = 'Percent Decrease', FieloELR__Description__c = 'testDescription', FieloELR__IsActive__c = false));
        modules.add(new FieloELR__Module__c(Name = 'testModule Predecessor', FieloELR__Course__c = courses.get(1).Id, FieloELR__WeightedQuestions__c = true, FieloELR__PenaltyMode__c = 'Percent Decrease', FieloELR__Description__c = 'testDescription', FieloELR__IsActive__c = false));
        modules.add(new FieloELR__Module__c(Name = 'testModuleWithRandomQuestionsAndAnswers', FieloELR__Course__c = courses.get(1).Id, FieloELR__ApprovalGrade__c = 50, FieloELR__WeightedQuestions__c = false, FieloELR__PenaltyMode__c = 'Percent Decrease', FieloELR__Description__c = 'testDescription', FieloELR__IsActive__c = false));
        insert modules;

        // Questions
        questions.clear();
        questions.add(new FieloELR__Question__c(Name = 'Question', FieloELR__Module__c = modules.get(0).Id, FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c = 'Statement', FieloELR__PenaltyPerAttempt__c = 1, FieloELR__CorrectWeight__c = 1));
        questions.add(new FieloELR__Question__c(Name = 'Question', FieloELR__Module__c = modules.get(0).Id, FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c = 'Single Choice', FieloELR__PenaltyPerAttempt__c = 1, FieloELR__CorrectWeight__c = 1));
        questions.add(new FieloELR__Question__c(Name = 'Question', FieloELR__Module__c = modules.get(0).Id, FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c = 'Short Answer', FieloELR__PenaltyPerAttempt__c = 1, FieloELR__CorrectWeight__c = 1));
        questions.add(new FieloELR__Question__c(Name = 'Question', FieloELR__Module__c = modules.get(0).Id, FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c = 'Multiple Choice', FieloELR__PenaltyPerAttempt__c = 1, FieloELR__CorrectWeight__c = 1));
        questions.add(new FieloELR__Question__c(Name = 'Question', FieloELR__Module__c = modules.get(0).Id, FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c = 'Matching Options', FieloELR__PenaltyPerAttempt__c = 1, FieloELR__CorrectWeight__c = 1));

        questions.add(new FieloELR__Question__c(Name = 'Question', FieloELR__Module__c = modules.get(2).Id, FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c = 'Statement'));
        questions.add(new FieloELR__Question__c(Name = 'Question', FieloELR__Module__c = modules.get(2).Id, FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c = 'Single Choice'));
        questions.add(new FieloELR__Question__c(Name = 'Question', FieloELR__Module__c = modules.get(2).Id, FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c = 'Short Answer'));
        questions.add(new FieloELR__Question__c(Name = 'Question', FieloELR__Module__c = modules.get(2).Id, FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c = 'Multiple Choice'));
        questions.add(new FieloELR__Question__c(Name = 'Question', FieloELR__Module__c = modules.get(2).Id, FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c = 'Matching Options'));
        insert questions;

        // Answers
        answers.clear();
        for (Integer i = 10; i > 0; i--){
            answers.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(questions.size() - i).Id, FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Very well done, that is a correct answer!', FieloELR__MatchingText__c = 'Matching Text'));
            answers.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(questions.size() - i).Id, FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Very well done, that is a incorrect answer!', FieloELR__MatchingText__c = 'Matching Text'));
        }
        insert answers;

        // Member
        members.clear();
        members = MockUpFactory.createMembers(programs.get(0).id, 1);
        members.get(0).FieloPLT__Program__c = programs.get(1).Id;
        insert members.get(0);

        // Module Dependencies
        moduleDependencies.add(new FieloELR__ModuleDependency__c(FieloELR__Module__c = modules.get(1).Id, FieloELR__Predecessor__c = modules.get(0).Id));
        insert moduleDependencies;
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1563
    */
    @isTest static void ELR_0003_FA46() {
        setup();

        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithRandomQuestionsAndAnswers' LIMIT 1];
        modules.get(0).FieloELR__QuestionPool__c = 10;

        update modules.get(0);

        modules.get(0).FieloELR__IsActive__c = true;

        try {
            CourseService.enableAdminPermission(false);
            update modules.get(0);
        } catch (Exception e) {
            System.assert(e.getMessage().Contains(Label.QuestionPoolGreaterThenQuestionNumber));
        }

        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithRandomQuestionsAndAnswers' LIMIT 1];

        System.assertEquals(false, modules.get(0).FieloELR__IsActive__c);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1674
    */
    @isTest static void ELR_0003_FA40(){
        setup();
        setupInactiveModuleResponse();
        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        try {
            delete modules.get(0);
        } catch (System.DmlException e){
            System.assert(e.getMessage().Contains(Label.ValidateModuleEditableFields));
        }

        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        System.assertEquals(1, modules.size());
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1675
    */
    @isTest static void ELR_0003_FA18(){
        setup();

        modules = [SELECT Id, Name, FieloELR__Description__c FROM FieloELR__Module__c LIMIT 1];

        modules.get(0).FieloELR__IsActive__c = true;

        update modules;

        modules.get(0).Name = 'Changed Name';

        try {
            update modules.get(0);
        }
        catch (System.DmlException e){
            System.assert(e.getMessage().Contains(Label.ActiveModuleCannotBeEdited));
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1679
    */
    @isTest static void ELR_0003_FA5(){
        setup();

        courses = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE FieloELR__Status__c = 'Draft' LIMIT 1];

        FieloELR__Module__c moduleTest = setupModuleTest();
        moduleTest.FieloELR__Course__c = courses.get(0).id;
        moduleTest.FieloELR__QuestionPool__c = null;

        insert moduleTest;

        System.Assert(moduleTest.Id != null);

        FieloELR__Module__c moduleTest2 = setupModuleTest();
        moduleTest2.FieloELR__Course__c = courses.get(0).id;
        moduleTest2.FieloELR__QuestionPool__c = null;
        moduleTest2.FieloELR__WeightedQuestions__c = true;

        insert moduleTest2;

        System.Assert(moduleTest2.Id != null);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1688

    */
    @isTest static void ELR_0003_FB(){
        setup();

        courses = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE FieloELR__Status__c = 'Draft' LIMIT 1];

        FieloELR__Module__c moduleTest = setupModuleTest();
        moduleTest.FieloELR__Course__c = courses.get(0).id;
        moduleTest.FieloELR__QuestionPool__c = 10;

        insert moduleTest;

        System.Assert(moduleTest.Id != null);

        courses.get(0).FieloELR__Status__c = 'Inactive';
        update  courses.get(0);

        FieloELR__Module__c moduleTest2 = setupModuleTest();
        moduleTest2.FieloELR__Course__c = courses.get(0).id;
        moduleTest2.FieloELR__QuestionPool__c = 10;

        insert moduleTest2;

        System.Assert(moduleTest2.Id != null);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1689
    */
    @isTest static void ELR_0003_FA1(){
        setup();

        FieloELR__Module__c moduleTest = setupModuleTest();

        try {
            insert moduleTest;
        }
        catch (System.DmlException e){
            System.assert(e.getMessage().Contains('The course is mandatory'));
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1690
    */
    @isTest static void ELR_0003_FA2(){
        setup();

        courses = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c LIMIT 1];

        courses.get(0).Status__c = 'Active';

        FieloELR__Module__c moduleTest = setupModuleTest();
        moduleTest.FieloELR__Course__c = courses.get(0).id;

        try {
            insert moduleTest;
        } catch (System.DmlException e) {
            System.assert(e.getMessage().Contains('On module creation, course cannot be active, completed or scheduled'));
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1691
    */
    @isTest static void ELR_0003_FA3(){
        setup();

        courses = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE FieloELR__Status__c = 'Draft' LIMIT 1];

        FieloELR__Module__c moduleTest = setupModuleTest();
        moduleTest.FieloELR__Course__c = courses.get(0).id;
        moduleTest.FieloELR__ApprovalGrade__c = -50;
        moduleTest.FieloELR__QuestionPool__c = 1;

        try {
            insert moduleTest;
        } catch (System.DmlException e){
            System.assert(e.getMessage().Contains('The approval grade must be a value between 0 and 100'));
        }

        courses.get(0).FieloELR__Status__c = 'Inactive';
        update  courses.get(0);

        FieloELR__Module__c moduleTest2 = setupModuleTest();
        moduleTest2.FieloELR__Course__c = courses.get(0).id;
        moduleTest2.FieloELR__ApprovalGrade__c = 150;
        moduleTest2.FieloELR__QuestionPool__c = 1;

        try {
            insert moduleTest2;
        } catch (System.DmlException e){
            System.assert(e.getMessage().Contains('The approval grade must be a value between 0 and 100'));
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1692
    */
    @isTest static void ELR_0003_FA4(){
        setup();

        courses = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE FieloELR__Status__c = 'Draft' LIMIT 1];
        FieloELR__Module__c moduleTest = setupModuleTest();
        moduleTest.FieloELR__Course__c = courses.get(0).id;
        moduleTest.FieloELR__WeightedQuestions__c = true;
        moduleTest.FieloELR__QuestionPool__c = 1;

        try {
            insert moduleTest;
        }
        catch (System.DmlException e){
            System.debug(e.getMessage());
            System.assert(e.getMessage() != null);
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1693
    */
    @isTest static void ELR_0003_FA7() {
        setup();

        courses = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE FieloELR__Status__c = 'Draft' LIMIT 1];

        FieloELR__Module__c moduleTest = setupModuleTest();
        moduleTest.FieloELR__Course__c = courses.get(0).id;
        moduleTest.FieloELR__IsActive__c = true;

        insert moduleTest;

        List<FieloELR__Module__c> moduleTestIsActive = [SELECT Id, FieloELR__IsActive__c FROM FieloELR__Module__c WHERE Id = : moduleTest.Id LIMIT 1];

        System.assert(moduleTestIsActive.get(0).FieloELR__IsActive__c == false);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1694
    */
    @isTest static void ELR_0003_FA8() {
        setup();

        courses = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE FieloELR__Status__c = 'Draft' LIMIT 1];

        FieloELR__Module__c moduleTest = setupModuleTest();
        moduleTest.FieloELR__Course__c = courses.get(0).id;
        moduleTest.FieloELR__AttemptsAllowed__c = -1;

        try {
            insert moduleTest;
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1695
    */
    @isTest static void ELR_0003_FA9() {
        setup();

        courses = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE FieloELR__Status__c = 'Draft' LIMIT 1];

        FieloELR__Module__c moduleTest = setupModuleTest();
        moduleTest.FieloELR__Course__c = courses.get(0).id;
        moduleTest.FieloELR__AttemptsAllowedPerQuestion__c = -1;

        try {
            insert moduleTest;
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1696
    */
    @isTest static void ELR_0003_FA10() {
        setup();

        courses = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE FieloELR__Status__c = 'Draft' LIMIT 1];

        FieloELR__Module__c moduleTest = setupModuleTest();
        moduleTest.FieloELR__Course__c = courses.get(0).id;
        moduleTest.FieloELR__Order__c = null;

        insert moduleTest;

        List<FieloELR__Module__c> moduleTestOrder = [SELECT Id, FieloELR__Order__c FROM FieloELR__Module__c WHERE Id = : moduleTest.Id LIMIT 1];
        System.assert(moduleTestOrder.get(0).FieloELR__Order__c == ([SELECT COUNT() FROM FieloELR__Module__c WHERE FieloELR__Course__r.Id = : courses.get(0).id]));
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1697
    */
    @isTest static void ELR_0003_FA11() {
        setup();

        modules = [SELECT Id, Name, FieloELR__Description__c FROM FieloELR__Module__c WHERE FieloELR__IsActive__c = false LIMIT 1];

        modules.get(0).Name = 'Changed Name';

        update modules.get(0);

        modules = [SELECT Id, Name, FieloELR__Description__c FROM FieloELR__Module__c WHERE Id = : modules.get(0).Id LIMIT 1];

        System.assert(modules.get(0).Name == 'Changed Name');

        modules.get(0).FieloELR__Description__c = 'Changed Description';

        update modules.get(0);

        modules = [SELECT Id, Name, FieloELR__Description__c FROM FieloELR__Module__c WHERE Id = : modules.get(0).Id LIMIT 1];

        System.assert(modules.get(0).FieloELR__Description__c == 'Changed Description');
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1698
    */
    @isTest static void ELR_0003_FA12() {
        setup();

        Integer testQuantity = 3;
        courses = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE FieloELR__Status__c = 'Draft' LIMIT 1];

        List<FieloELR__Module__c> modulesTest = new List<FieloELR__Module__c>();
        for (Integer i = 0; i < testQuantity; i++){
            modulesTest.add(new FieloELR__Module__c(Name = 'testModule ' + i, FieloELR__Course__c = courses.get(0).Id, FieloELR__ApprovalGrade__c = 50, FieloELR__WeightedQuestions__c = false));
        }
        insert modulesTest;

        List<FieloELR__Question__c> questionsTest = new List<FieloELR__Question__c>();
        for (Integer i = 0; i < testQuantity; i++){
            questionsTest.add(new FieloELR__Question__c(Name = 'Question ' + i, FieloELR__Module__c = modulesTest.get(i).Id, FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c = 'Short Answer', FieloELR__CorrectWeight__c = i + 1));
        }
        insert questionsTest;

        modules = [SELECT Id, FieloELR__WeightedQuestions__c, FieloELR__QuestionPool__c FROM FieloELR__Module__c WHERE FieloELR__QuestionPool__c = null AND FieloELR__WeightedQuestions__c = false AND FieloELR__IsActive__c = false LIMIT 1];

        modules.get(0).FieloELR__QuestionPool__c = 1;

        update modules.get(0);

        questions = [SELECT Id, FieloELR__CorrectWeight__c FROM FieloELR__Question__c WHERE FieloELR__Module__r.Id = : modules.get(0).Id LIMIT 1];

        System.assert(questions.get(0).FieloELR__CorrectWeight__c == 1);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1699
    */
    @isTest static void ELR_0003_FA13() {
        setup();

        modules = [SELECT Id, FieloELR__WeightedQuestions__c, FieloELR__QuestionPool__c FROM FieloELR__Module__c WHERE FieloELR__QuestionPool__c = null AND FieloELR__WeightedQuestions__c = true AND FieloELR__IsActive__c = false LIMIT 1];

        modules.get(0).FieloELR__WeightedQuestions__c = false;

        update modules.get(0);

        questions = [SELECT Id, FieloELR__CorrectWeight__c FROM FieloELR__Question__c WHERE FieloELR__Module__r.Id = : modules.get(0).Id LIMIT 1];

        System.assert(questions.get(0).FieloELR__CorrectWeight__c == 1);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1700
    */
    @isTest static void ELR_0003_FA14() {
        setup();

        modules = [SELECT Id FROM FieloELR__Module__c WHERE FieloELR__PenaltyMode__c = 'Percent Decrease' AND FieloELR__IsActive__c = false LIMIT 1];

        modules.get(0).FieloELR__PenaltyMode__c = 'Negative Weight';

        update modules.get(0);

        questions = [SELECT Id, FieloELR__PenaltyPerAttempt__c FROM FieloELR__Question__c WHERE FieloELR__Module__r.Id = : modules.get(0).Id LIMIT 1];

        System.assert(questions.get(0).FieloELR__PenaltyPerAttempt__c == 0);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1701
    */
    @isTest static void ELR_0003_FA15() {
        setup();

        modules = [SELECT Id FROM FieloELR__Module__c WHERE FieloELR__PenaltyMode__c = 'Percent Decrease' AND FieloELR__IsActive__c = false LIMIT 1];

        modules.get(0).FieloELR__PenaltyMode__c = 'None';

        update modules.get(0);

        questions = [SELECT Id, FieloELR__PenaltyPerAttempt__c FROM FieloELR__Question__c WHERE FieloELR__Module__r.Id = : modules.get(0).Id LIMIT 1];

        System.assert(questions.get(0).FieloELR__PenaltyPerAttempt__c == 0);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1702
    */
    @isTest static void ELR_0003_FA16() {
        setup();

        Integer testQuantity = 3;
        courses = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE FieloELR__Status__c = 'Draft' LIMIT 1];

        List<FieloELR__Module__c> modulesTest = new List<FieloELR__Module__c>();
        for (Integer i = 0; i < testQuantity; i++){
            modulesTest.add(new FieloELR__Module__c(Name = 'testModule ' + i, FieloELR__Course__c = courses.get(0).Id, FieloELR__ApprovalGrade__c = 50, FieloELR__WeightedQuestions__c = false, FieloELR__PenaltyMode__c = 'Negative Weight'));
        }
        insert modulesTest;

        List<FieloELR__Question__c> questionsTest = new List<FieloELR__Question__c>();
        for (Integer i = 0; i < testQuantity; i++){
            questionsTest.add(new FieloELR__Question__c(Name = 'Question ' + i, FieloELR__Module__c = modulesTest.get(i).Id, FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c = 'Short Answer'));
        }
        insert questionsTest;

        modules = [SELECT Id FROM FieloELR__Module__c WHERE FieloELR__PenaltyMode__c = 'Negative Weight' AND FieloELR__IsActive__c = false LIMIT 1];

        modules.get(0).FieloELR__PenaltyMode__c = 'Percent Decrease';

        update modules.get(0);

        questions = [SELECT Id, FieloELR__IncorrectWeight__c FROM FieloELR__Question__c WHERE FieloELR__Module__r.Id = : modules.get(0).Id LIMIT 1];

        System.assert(questions.get(0).FieloELR__IncorrectWeight__c == 0);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1703
    */
    @isTest static void ELR_0003_FA17() {
        setup();

        Integer testQuantity = 3;
        courses = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE FieloELR__Status__c = 'Draft' LIMIT 1];

        List<FieloELR__Module__c> modulesTest = new List<FieloELR__Module__c>();
        for (Integer i = 0; i < testQuantity; i++){
            modulesTest.add(new FieloELR__Module__c(Name = 'testModule ' + i, FieloELR__Course__c = courses.get(0).Id, FieloELR__ApprovalGrade__c = 50, FieloELR__WeightedQuestions__c = false, FieloELR__PenaltyMode__c = 'Negative Weight'));
        }
        insert modulesTest;

        List<FieloELR__Question__c> questionsTest = new List<FieloELR__Question__c>();
        for (Integer i = 0; i < testQuantity; i++){
            questionsTest.add(new FieloELR__Question__c(Name = 'Question ' + i, FieloELR__Module__c = modulesTest.get(i).Id, FieloELR__QuestionText__c = 'What hour is it?', FieloELR__Type__c = 'Short Answer'));
        }
        insert questionsTest;

        modules = [SELECT Id FROM FieloELR__Module__c WHERE FieloELR__PenaltyMode__c = 'Negative Weight' AND FieloELR__IsActive__c = false LIMIT 1];

        modules.get(0).FieloELR__PenaltyMode__c = 'None';

        update modules.get(0);

        questions = [SELECT Id, FieloELR__IncorrectWeight__c FROM FieloELR__Question__c WHERE FieloELR__Module__r.Id = : modules.get(0).Id LIMIT 1];

        System.assert(questions.get(0).FieloELR__IncorrectWeight__c == 0);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1704
    */
    @isTest static void ELR_0003_FA19() {
        setup();
        // Module
        setupInactiveModuleResponse();
        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        modules.get(0).Name = 'Changed Name';

        update modules.get(0);

        List<FieloELR__Module__c> moduleTestNameChange = [SELECT Id, Name FROM FieloELR__Module__c WHERE Id = : modules.get(0).Id LIMIT 1];

        System.assert(moduleTestNameChange.get(0).Name == modules.get(0).Name);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1705
    */
    @isTest static void ELR_0003_FA20() {
        setup();
        // Module
        setupInactiveModuleResponse();

        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c, FieloELR__Description__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        modules.get(0).FieloELR__Description__c = 'Changed Description';

        update modules.get(0);

        List<FieloELR__Module__c> moduleTestNameChange = [SELECT Id, FieloELR__Description__c FROM FieloELR__Module__c WHERE Id = : modules.get(0).Id LIMIT 1];

        System.assert(moduleTestNameChange.get(0).FieloELR__Description__c == modules.get(0).FieloELR__Description__c);

        /*
            The system updates the module
            The system displays the module detail page
        */
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1706
    */
    @isTest static void ELR_0003_FA21() {
        setup();
        // Module
        setupInactiveModuleResponse();
        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c, FieloELR__Order__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        modules.get(0).FieloELR__Order__c = 10;

        update modules.get(0);

        List<FieloELR__Module__c> moduleTestOrderChange = [SELECT Id, FieloELR__Order__c FROM FieloELR__Module__c WHERE Id = : modules.get(0).Id LIMIT 1];

        System.assert(moduleTestOrderChange.get(0).FieloELR__Order__c == modules.get(0).FieloELR__Order__c);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1707
    */
    @isTest static void ELR_0003_FA22() {
        setup();
        // Module
        setupInactiveModuleResponse();
        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c, FieloELR__ShuffleQuestions__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        modules.get(0).FieloELR__ShuffleQuestions__c = true;

        update modules.get(0);

        List<FieloELR__Module__c> moduleTestShuffleChange = [SELECT Id, FieloELR__ShuffleQuestions__c FROM FieloELR__Module__c WHERE Id = : modules.get(0).Id LIMIT 1];

        System.assert(moduleTestShuffleChange.get(0).FieloELR__ShuffleQuestions__c == modules.get(0).FieloELR__ShuffleQuestions__c);

        /*
            The system updates the module
            The system displays the module detail page
        */
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1708
    */
    @isTest static void ELR_0003_FA6() {
        setup();

        courses = [SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE FieloELR__Status__c = 'Draft' LIMIT 1];

        FieloELR__Module__c moduleTest = setupModuleTest();
        moduleTest.FieloELR__Course__c = courses.get(0).id;
        moduleTest.FieloELR__QuestionPool__c = 0;

        try {
            insert moduleTest;
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }

        courses.get(0).FieloELR__Status__c = 'Inactive';
        update  courses.get(0);

        FieloELR__Module__c moduleTest2 = setupModuleTest();
        moduleTest2.FieloELR__Course__c = courses.get(0).id;
        moduleTest2.FieloELR__QuestionPool__c = -50;

        try {
            insert moduleTest2;
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1709
    */
    @isTest static void ELR_0003_FA23() {
        setup();
        // Module
        setupInactiveModuleResponse();
        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c, FieloELR__AttemptsAllowed__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        modules.get(0).FieloELR__AttemptsAllowed__c = 10;

        try {
            update modules.get(0);
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1710
    */
    @isTest static void ELR_0003_FA24() {
        setup();
        // Module
        setupInactiveModuleResponse();
        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c, FieloELR__AttemptsAllowedPerQuestion__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        modules.get(0).FieloELR__AttemptsAllowedPerQuestion__c = 10;

        try {
            update modules.get(0);
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1711
    */
    @isTest static void ELR_0003_FA25() {
        setup();
        // Module
        setupInactiveModuleResponse();
        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c, FieloELR__ApprovalGrade__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        modules.get(0).FieloELR__ApprovalGrade__c = 10;

        try {
            update modules.get(0);
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1712
    */
    @isTest static void ELR_0003_FA26() {
        setup();
        // Module
        setupInactiveModuleResponse();
        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c, FieloELR__PenaltyMode__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        modules.get(0).FieloELR__PenaltyMode__c = 'None';

        try {
            update modules.get(0);
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1713
    */
    @isTest static void ELR_0003_FA27() {
        setup();
        // Module
        setupInactiveModuleResponse();
        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c, FieloELR__QuestionPool__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        modules.get(0).FieloELR__QuestionPool__c = 10;

        try {
            update modules.get(0);
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1714
    */
    @isTest static void ELR_0003_FA28() {
        // Module
        /*setupInactiveModuleResponse();
        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c, FieloELR__WeightedQuestions__c, (SELECT Id, Name FROM FieloELR__ModuleResponses__r) FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        System.assertNotEquals(0, modules.get(0).FieloELR__ModuleResponses__r.size());

        modules.get(0).FieloELR__WeightedQuestions__c = false;

        try {
            update modules.get(0);
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }

        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c, FieloELR__WeightedQuestions__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];
        System.assertEquals(true, modules.get(0).FieloELR__WeightedQuestions__c);
        */
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1715
    */
    @isTest static void ELR_0003_FA29() {
        setup();
        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];
        modules.get(0).FieloELR__IsActive__c = true;
        update modules.get(0);

        List<FieloELR__Module__c> moduleTestIsActiveChange = [SELECT Id, FieloELR__IsActive__c FROM FieloELR__Module__c WHERE Id = : modules.get(0).Id LIMIT 1];
        System.assert(modules.get(0).FieloELR__IsActive__c == moduleTestIsActiveChange.get(0).FieloELR__IsActive__c);
    }


    /*
        https://fieloww.atlassian.net/browse/TEST-1716
    */
    @isTest static void ELR_0003_FA30() {
        setup();
        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];
        modules.get(0).FieloELR__IsActive__c = true;
        modules.get(0).FieloELR__ApprovalGrade__c = null;

        try {
            update modules.get(0);
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1717
    */
    @isTest static void ELR_0003_FA31() {
        setup();
        modules = [SELECT Id, (SELECT Id FROM FieloELR__Questions__r) FROM FieloELR__Module__c WHERE FieloELR__IsActive__c = false LIMIT 1];

        delete modules.get(0).FieloELR__Questions__r;

        modules = [SELECT Id, (SELECT Id FROM FieloELR__Questions__r) FROM FieloELR__Module__c WHERE FieloELR__IsActive__c = false LIMIT 1];

        modules.get(0).FieloELR__IsActive__c = true;

        System.assertEquals(0, modules.get(0).FieloELR__Questions__r.size());

        try {
            update modules.get(0);
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1718
    */
    @isTest static void ELR_0003_FA32() {
        setup();
        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        questions = [SELECT Id FROM FieloELR__Question__c WHERE FieloELR__Module__c = : modules.get(0).Id AND FieloELR__Type__c = 'Statement'];
        answers = [SELECT Id, FieloELR__IsCorrect__c FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = : questions.get(0).Id];

        System.assertEquals(false, modules.get(0).FieloELR__IsActive__c, 'Module should be inactive');
        System.assert(!answers.isEmpty(), 'Question should have answer options');

        for (FieloELR__AnswerOption__c ao: answers) {
            ao.FieloELR__IsCorrect__c = false;
        }

        update answers;

        modules.get(0).FieloELR__IsActive__c = true;

        String errorMessage = '';
        try {
            CourseService.enableAdminPermission(false);
            System.debug('updating module response');
            update modules.get(0);
        }
        catch (System.DmlException e){
            errorMessage = e.getMessage();
        }
        System.assert(String.isNotBlank(errorMessage), 'No error message was thrown');

        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];
        System.assertEquals(false, modules.get(0).FieloELR__IsActive__c);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1719
    */
    @isTest static void ELR_0003_FA33() {
        setup();
        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        questions = [SELECT Id FROM FieloELR__Question__c WHERE FieloELR__Module__c = : modules.get(0).Id AND FieloELR__Type__c = 'Single Choice'];
        answers = [SELECT Id, FieloELR__IsCorrect__c FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = : questions.get(0).Id];

        for (FieloELR__AnswerOption__c ao: answers) {
            ao.FieloELR__IsCorrect__c = false;
        }

        update answers;

        modules.get(0).FieloELR__IsActive__c = true;

        try {
            CourseService.enableAdminPermission(false);
            update modules.get(0);
        } catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }

        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        System.assertEquals(false, modules.get(0).FieloELR__IsActive__c);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1720
    */
    @isTest static void ELR_0003_FA34() {
        setup();
        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        questions = [SELECT Id FROM FieloELR__Question__c WHERE FieloELR__Module__c = : modules.get(0).Id AND FieloELR__Type__c = 'Statement'];
        answers = [SELECT Id, FieloELR__IsCorrect__c FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = : questions.get(0).Id];

        delete answers;

        modules.get(0).FieloELR__IsActive__c = true;

        try {
            CourseService.enableAdminPermission(false);
            update modules.get(0);
        } catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }

        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        System.assertEquals(false, modules.get(0).FieloELR__IsActive__c);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1721
    */
    @isTest static void ELR_0003_FA35() {
        setup();
        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        questions = [SELECT Id FROM FieloELR__Question__c WHERE FieloELR__Module__c = : modules.get(0).Id AND FieloELR__Type__c = 'Single Choice'];
        answers = [SELECT Id, FieloELR__IsCorrect__c FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = : questions.get(0).Id];

        delete answers;

        modules.get(0).FieloELR__IsActive__c = true;

        try {
            CourseService.enableAdminPermission(false);
            update modules.get(0);
        } catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }

        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        System.assertEquals(false, modules.get(0).FieloELR__IsActive__c);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1722
    */
    @isTest static void ELR_0003_FA36() {
        setup();
        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        questions = [SELECT Id FROM FieloELR__Question__c WHERE FieloELR__Module__c = : modules.get(0).Id AND FieloELR__Type__c = 'Multiple Choice'];
        answers = [SELECT Id, FieloELR__IsCorrect__c FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = : questions.get(0).Id];

        delete answers;

        modules.get(0).FieloELR__IsActive__c = true;

        try {
            CourseService.enableAdminPermission(false);
            update modules.get(0);
        } catch (System.DmlException e) {
            System.assert(e.getMessage() != null);
        }

        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        System.assertEquals(false, modules.get(0).FieloELR__IsActive__c);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1723
    */
    @isTest static void ELR_0003_FA37() {
        setup();
        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        questions = [SELECT Id FROM FieloELR__Question__c WHERE FieloELR__Module__c = : modules.get(0).Id AND FieloELR__Type__c = 'Matching Options'];
        answers = [SELECT Id, FieloELR__IsCorrect__c FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = : questions.get(0).Id];

        delete answers;

        modules.get(0).FieloELR__IsActive__c = true;

        try {
            CourseService.enableAdminPermission(false);
            update modules.get(0);
        } catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }

        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        System.assertEquals(false, modules.get(0).FieloELR__IsActive__c);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1724
    */
    @isTest static void ELR_0003_FA38() {
        setup();
        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' AND FieloELR__IsActive__c = false LIMIT 1];

        questions = [SELECT Id FROM FieloELR__Question__c WHERE FieloELR__Module__c = : modules.get(0).Id AND FieloELR__Type__c = 'Short Answer'];
        answers = [SELECT Id, FieloELR__IsCorrect__c FROM FieloELR__AnswerOption__c WHERE FieloELR__Question__c = : questions.get(0).Id];

        delete answers;

        modules.get(0).FieloELR__IsActive__c = true;

        try {
            CourseService.enableAdminPermission(false);
            update modules.get(0);
        } catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }

        modules = [SELECT Id, FieloELR__IsActive__c, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' AND FieloELR__IsActive__c = false LIMIT 1];

        System.assertEquals(false, modules.get(0).FieloELR__IsActive__c);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1725
    */
    @isTest static void ELR_0003_FA39() {
        setup();
        modules = [SELECT Id, Name FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' AND FieloELR__IsActive__c = false LIMIT 1];

        Integer moduleSize = 1, questionsSize = 0, moduleDependenciesSize = 0;
        Id moduleId = modules.get(0).Id;
        questionsSize = [SELECT COUNT() FROM FieloELR__Question__c WHERE FieloELR__Module__c = : moduleId];
        moduleDependenciesSize = [SELECT COUNT() FROM FieloELR__ModuleDependency__c WHERE FieloELR__Predecessor__c = : moduleId];

        delete modules.get(0);

        System.Assert(moduleSize != [SELECT COUNT() FROM FieloELR__Module__c WHERE Id = : moduleId]);
        System.Assert(moduleDependenciesSize != [SELECT COUNT() FROM FieloELR__ModuleDependency__c WHERE FieloELR__Predecessor__c = : moduleId]);
        System.Assert(questionsSize != [SELECT COUNT() FROM FieloELR__Question__c WHERE FieloELR__Module__c = : moduleId]);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1726
    */
    @isTest static void ELR_0003_FA41() {
        setup();
        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];
        modules.get(0).FieloELR__IsActive__c = true;
        update modules.get(0);

        Integer moduleSize = 1, questionsSize = 0, moduleDependenciesSize = 0;
        Decimal courseActiveModulesBefore = 0, courseActiveModulesAfter = 0;
        Id moduleId = modules.get(0).Id;
        questionsSize = [SELECT COUNT() FROM FieloELR__Question__c WHERE FieloELR__Module__c = : moduleId];
        moduleDependenciesSize = [SELECT COUNT() FROM FieloELR__ModuleDependency__c WHERE FieloELR__Predecessor__c = : moduleId];
        courses = [SELECT FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Id = : modules.get(0).FieloELR__Course__c];
        courseActiveModulesBefore = courses.get(0).FieloELR__ActiveModules__c;

        delete modules.get(0);

        courses = [SELECT FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Id = : modules.get(0).FieloELR__Course__c];
        courseActiveModulesAfter = courses.get(0).FieloELR__ActiveModules__c;

        System.Assert(moduleSize != [SELECT COUNT() FROM FieloELR__Module__c WHERE Id = : moduleId]);
        System.Assert(moduleDependenciesSize != [SELECT COUNT() FROM FieloELR__ModuleDependency__c WHERE FieloELR__Predecessor__c = : moduleId]);
        System.Assert(questionsSize != [SELECT COUNT() FROM FieloELR__Question__c WHERE FieloELR__Module__c = : moduleId]);
        System.Assert((courseActiveModulesBefore - 1) == courseActiveModulesAfter);
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1727
    */
    @isTest static void ELR_0003_FA42() {
        setup();
        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];
        modules.get(0).FieloELR__IsActive__c = true;
        update modules.get(0);

        courses = [SELECT Id, FieloELR__Program__c FROM FieloELR__Course__c WHERE Id = : modules.get(0).FieloELR__Course__c];
        courses.get(0).FieloELR__Status__c = 'Active';
        update courses.get(0);

        members = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE FieloPLT__Program__c = : courses.get(0).FieloELR__Program__c];

        courseStatus.add(new FieloELR__CourseStatus__c(FieloELR__Member__c = members.get(0).Id, FieloELR__Course__c =  modules.get(0).FieloELR__Course__c));
        insert courseStatus;

        moduleResponses.add(new FieloELR__ModuleResponse__c(FieloELR__Module__c = modules.get(0).Id, FieloELR__Member__c = members.get(0).Id, FieloELR__CourseStatus__c = courseStatus.get(0).Id, FieloELR__IsApproved__c = true));
        insert moduleResponses;

        try {
            delete modules.get(0);
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }

        modules = [SELECT Id, FieloELR__IsActive__c, Name, FieloELR__Course__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];

        System.assertEquals(1, modules.size());
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1728
    */
    @isTest static void ELR_0003_FA43() {
        setup();
        modules = [SELECT Id, FieloELR__IsActive__c, FieloELR__Course__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];
        FieloELR__Module__c moduleTest = modules.get(0);
        moduleTest.FieloELR__IsActive__c = true;
        update moduleTest;

        Decimal courseActiveModulesBefore = 0, courseActiveModulesAfter = 0;

        courses = [SELECT Id, FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Id = : moduleTest.FieloELR__Course__c];
        courseActiveModulesBefore = courses.get(0).FieloELR__ActiveModules__c;

        moduleTest.FieloELR__IsActive__c = false;
        update moduleTest;

        courses = [SELECT Id, FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Id = : moduleTest.FieloELR__Course__c];
        courseActiveModulesAfter = courses.get(0).FieloELR__ActiveModules__c;

        System.Assert((courseActiveModulesBefore - 1) == courseActiveModulesAfter);
    }

    /*
         https://fieloww.atlassian.net/browse/TEST-1729
    */
    @isTest static void ELR_0003_FA44() {
        setup();
        modules = [SELECT Id, FieloELR__IsActive__c, FieloELR__Course__c FROM FieloELR__Module__c WHERE Name = 'testModuleWithQuestionsAndAnswers' LIMIT 1];
        FieloELR__Module__c moduleTest = modules.get(0);
        moduleTest.FieloELR__IsActive__c = true;
        update moduleTest;

        moduleTest.FieloELR__IsActive__c = false;

        try {
            update moduleTest;
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }
    }

    /*
        https://fieloww.atlassian.net/browse/TEST-1730
    */
    @isTest static void ELR_0003_FA45() {
        setup();
        modules = [SELECT Id, Name, FieloELR__Description__c, FieloELR__Course__c FROM FieloELR__Module__c WHERE FieloELR__IsActive__c = false LIMIT 1];

        courses = [SELECT Id FROM FieloELR__Course__c WHERE Id != :modules.get(0).FieloELR__Course__c LIMIT 1];

        Id oldCourse = modules.get(0).FieloELR__Course__c;

        modules.get(0).FieloELR__Course__c = courses.get(0).Id;

        try {
            update modules.get(0);
        }
        catch (System.DmlException e){
            System.assert(e.getMessage() != null);
        }

        modules = [SELECT Id, Name, FieloELR__Description__c, FieloELR__Course__c FROM FieloELR__Module__c WHERE FieloELR__IsActive__c = false LIMIT 1];

        System.assertEquals(oldCourse, modules.get(0).FieloELR__Course__c);
    }
}