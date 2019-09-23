@isTest
private class TestCreateQuestionResponse {
    private static List<FieloELR__QuestionResponse__c> questionResponses = new List<FieloELR__QuestionResponse__c>();
    private static List<FieloELR__ModuleResponse__c> moduleResponses = new List<FieloELR__ModuleResponse__c>();
    private static List<FieloELR__Question__c> questions = new List<FieloELR__Question__c>();
    private static List<FieloELR__CourseStatus__c> courseStatus = new List<FieloELR__CourseStatus__c>();

    @testSetup static void setup(){
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
        modules.add(new Module__c(Name = 'Basic', Course__c = courses.get(0).id, ApprovalGrade__c = 0, AttemptsAllowed__c = 2, AttemptsAllowedPerQuestion__c = 2, PenaltyMode__c = 'None'));
        modules.add(new Module__c(Name = 'Advanced', Course__c = courses.get(0).id, ApprovalGrade__c = 0, AttemptsAllowed__c = 2, AttemptsAllowedPerQuestion__c = 2, PenaltyMode__c = 'None'));

        insert modules;

        //Basic Module Questions
        questions.add(new Question__c(Name = 'Q1', Module__c = modules.get(0).Id, QuestionText__c = 'Which one is the most popular programming language?', Type__c = 'Single Choice'));
        questions.add(new Question__c(Name = 'Q2', Module__c = modules.get(0).Id, QuestionText__c = 'Acronymn for Personal Computer', Type__c = 'Short Answer'));
        questions.add(new Question__c(Name = 'Q3', Module__c = modules.get(0).Id, QuestionText__c = 'Which of the following are Family-C programming languages?', Type__c = 'Multiple Choice'));
        questions.add(new Question__c(Name = 'Q4', Module__c = modules.get(0).Id, QuestionText__c = 'C++ is more performatic than java', Type__c = 'Statement'));
        questions.add(new Question__c(Name = 'Q5', Module__c = modules.get(0).Id, QuestionText__c = 'Match statement with its meaning', Type__c = 'Matching Options'));
        //Advanced Module Questions
        questions.add(new Question__c(Name = 'Q1', Module__c = modules.get(1).Id, QuestionText__c = 'Which one is the least popular programming language?', Type__c = 'Single Choice'));

        insert questions;

        // Answers Q1 - Basic
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'Java'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'C++'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'SQL'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'PHP'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = true, AnswerOptionText__c = 'JavaScript'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(0).Id, IsCorrect__c = false, AnswerOptionText__c = 'HTML'));

        // Answers Q2 - Basic
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'PC'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'pc'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'p.c.'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(1).Id, IsCorrect__c = true, AnswerOptionText__c = 'P.C.'));

        // Answers Q3 - Basic
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'C++'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'Java'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'PHP'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'Python'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(2).Id, IsCorrect__c = true, AnswerOptionText__c = 'Objective-C'));

        // Answers Q4 - Basic
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(3).Id, IsCorrect__c = true, AnswerOptionText__c = 'True'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(3).Id, IsCorrect__c = false, AnswerOptionText__c = 'False'));

        // Answers Q5 - Basic
        answersOpList.add(new AnswerOption__c( Question__c = questions.get(4).Id, IsCorrect__c = true, AnswerOptionText__c = 'if', MatchingText__c = 'conditional'));
        answersOpList.add(new AnswerOption__c( Question__c = questions.get(4).Id, IsCorrect__c = true, AnswerOptionText__c = 'for', MatchingText__c = 'loop'));
        answersOpList.add(new AnswerOption__c( Question__c = questions.get(4).Id, IsCorrect__c = true, AnswerOptionText__c = 'while', MatchingText__c = 'loop'));
        answersOpList.add(new AnswerOption__c( Question__c = questions.get(4).Id, IsCorrect__c = true, AnswerOptionText__c = 'break', MatchingText__c = 'exit loop'));

        // Answers Q1 - Advanced
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(5).Id, IsCorrect__c = false, AnswerOptionText__c = 'Java'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(5).Id, IsCorrect__c = false, AnswerOptionText__c = 'C++'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(5).Id, IsCorrect__c = false, AnswerOptionText__c = 'SQL'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(5).Id, IsCorrect__c = false, AnswerOptionText__c = 'PHP'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(5).Id, IsCorrect__c = true, AnswerOptionText__c = 'Haskell'));
        answersOpList.add(new AnswerOption__c(Question__c = questions.get(5).Id, IsCorrect__c = false, AnswerOptionText__c = 'HTML'));

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
    }

    /*  TEST-1795
        Create Question Response (OK)
    */
    @isTest static void ELR_0008_FB() {
        moduleResponses = [SELECT Id, Module__c FROM ModuleResponse__c LIMIT 1];
        questions = [SELECT Id FROM Question__c WHERE Module__c = :moduleResponses.get(0).Module__c];
        
        for (Question__c q: questions) {
            questionResponses.add( new QuestionResponse__c(Question__c = q.Id, ModuleResponse__c = moduleResponses.get(0).Id));    
        }
        
        insert questionResponses;

        System.assertEquals(5, questionResponses.size());

        questionResponses = [SELECT Id, Question__c, NumberOfAttempt__c FROM QuestionResponse__c WHERE ModuleResponse__c = :moduleResponses.get(0).Id];

        for (QuestionResponse__c qr: questionResponses) {
            System.assertEquals(1, qr.NumberOfAttempt__c);
        }

    } 
    
    /*  TEST-1796
        Create Question Response
        - Validations
        - The related module response is submitted (NOK)
    */
    @isTest static void ELR_0008_FA1() {
        moduleResponses = [SELECT Id, Module__c FROM ModuleResponse__c LIMIT 1];
        questions = [SELECT Id FROM Question__c WHERE Module__c = :moduleResponses.get(0).Module__c];
        
        for (Question__c q: questions) {
            questionResponses.add( new QuestionResponse__c(Question__c = q.Id, ModuleResponse__c = moduleResponses.get(0).Id));
        }
        insert questionResponses;

        System.assertEquals(5, questionResponses.size());

        moduleResponses.get(0).IsSubmitted__c = true;

        update moduleResponses;

        questionResponses.clear();
        for (Question__c q: questions) {
            questionResponses.add( new QuestionResponse__c(Question__c = q.Id, ModuleResponse__c = moduleResponses.get(0).Id));    
        }
        try{
            insert questionResponses;        
        } catch (Exception e) {
            System.assert(e.getMessage().Contains(Label.ValidateQuestionResponseInsert));
        }

        questionResponses = [SELECT Id, Question__c, NumberOfAttempt__c, ModuleResponse__r.IsSubmitted__c FROM QuestionResponse__c WHERE ModuleResponse__c = :moduleResponses.get(0).Id];

        for (QuestionResponse__c qr: questionResponses) {
            System.assertEquals(true, qr.ModuleResponse__r.IsSubmitted__c);
        }

        System.assertEquals(5, questionResponses.size());

        for (QuestionResponse__c qr: questionResponses) {
            System.assertEquals(1, qr.NumberOfAttempt__c);
        }
    }

    /*  TEST-1797
        Create Question Response
        - Validations
        - Question field is null (NOK)
    */
    @isTest static void ELR_0008_FA2() {
        moduleResponses = [SELECT Id, Module__c FROM ModuleResponse__c Where Module__r.Name = 'Basic' LIMIT 1];
        questions = [SELECT Id FROM Question__c WHERE Module__c = :moduleResponses.get(0).Module__c];

        for (Question__c q: questions) {
            questionResponses.add( new QuestionResponse__c(ModuleResponse__c = moduleResponses.get(0).Id));    
        }
        
        String errorMsg = '';
        try{
            insert questionResponses;
        }catch(System.DmlException e){
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.assert(errorMsg.Contains(Label.QuestionFieldRequired));
    }

    /*  TEST-1798
        Create Question Response
        - Validations
        - Related question does not belong to the related module (NOK)
    */
    @isTest static void ELR_0008_FA3() {
        moduleResponses = [SELECT Id, Module__c FROM ModuleResponse__c LIMIT 1];
        questions = [SELECT Id FROM Question__c];
        
        for (Question__c q: questions) {
            questionResponses.add( new QuestionResponse__c(Question__c = q.Id, ModuleResponse__c = moduleResponses.get(0).Id));
        }
        
        System.assertEquals(6, questionResponses.size());

        String errorMsg = '';
        try {
            insert questionResponses;
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.assert(errorMsg.Contains('The related question doesn') && errorMsg.Contains('belong to this module'));
    }

    /*  TEST-1799
        Create Question Response
        - Validations
        - The Number of Attempt is greater than the “Attempts Allowed per Question” of the related module (NOK)
    */
    @isTest static void ELR_0008_FA4() {
        moduleResponses = [SELECT Id, Module__c FROM ModuleResponse__c LIMIT 1];
        questions = [SELECT Id FROM Question__c WHERE Module__c = :moduleResponses.get(0).Module__c];
        
        for(Integer i=1; i<=3; i++) {
            for (Question__c q: questions) {
                questionResponses.add( new QuestionResponse__c(Question__c = q.Id, ModuleResponse__c = moduleResponses.get(0).Id));    
            }
        }

        System.assertEquals(15, questionResponses.size());

        String errorMsg = '';
        try{
            insert questionResponses;
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains(' You have reached the limit of attempts for this question'));

        questionResponses = [SELECT Id, Question__c, NumberOfAttempt__c FROM QuestionResponse__c WHERE ModuleResponse__c = :moduleResponses.get(0).Id];

        System.assertEquals(0, questionResponses.size());
    }

    /*  TEST-1800
        Create Question Response
        - Delete a question response not submitted (OK)
    */
    @isTest static void ELR_0008_FA5() {
        moduleResponses = [SELECT Id, Module__c FROM ModuleResponse__c LIMIT 1];
        questions = [SELECT Id FROM Question__c WHERE Module__c = :moduleResponses.get(0).Module__c];
        
        for (Question__c q: questions) {
            questionResponses.add( new QuestionResponse__c(Question__c = q.Id, ModuleResponse__c = moduleResponses.get(0).Id));    
        }

        System.assertEquals(5, questionResponses.size());

        insert questionResponses;

        questionResponses = [SELECT Id, Question__c, NumberOfAttempt__c FROM QuestionResponse__c WHERE ModuleResponse__c = :moduleResponses.get(0).Id];

        delete questionResponses.get(0);

        questionResponses = [SELECT Id, Question__c, NumberOfAttempt__c FROM QuestionResponse__c WHERE ModuleResponse__c = :moduleResponses.get(0).Id];

        System.assertEquals(4, questionResponses.size());
    }

    /*  TEST-1801
        Create Question Response
        - Delete a question response already submitted (NOK)
    */
    @isTest static void ELR_0008_FA6() {
        moduleResponses = [SELECT Id, Module__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        questions = [SELECT Id FROM Question__c WHERE Module__c = :moduleResponses.get(0).Module__c];
        
        for (Question__c q: questions) {
            questionResponses.add( new QuestionResponse__c(Question__c = q.Id, ModuleResponse__c = moduleResponses.get(0).Id));
        }
        insert questionResponses;

        System.assertEquals(5, questionResponses.size());

        moduleResponses.get(0).IsSubmitted__c = true;

        update moduleResponses;

        questionResponses = [SELECT Id, Question__c, NumberOfAttempt__c FROM QuestionResponse__c WHERE ModuleResponse__c = :moduleResponses.get(0).Id];

        String errorMsg = '';
        try{
            delete questionResponses.get(0);
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }
        System.assert(errorMsg.contains('Cannot delete question responses from a module that was already submitted.'));
    }

    /*  TEST-1802
        Create Question Response
        - Edit a question response not submitted (OK)
    */
    @isTest static void ELR_0008_FA7() {
        moduleResponses = [SELECT Id, Module__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        questions = [SELECT Id FROM Question__c WHERE Module__c = :moduleResponses.get(0).Module__c];
        
        for (Question__c q: questions) {
            questionResponses.add( new QuestionResponse__c(Question__c = q.Id, ModuleResponse__c = moduleResponses.get(0).Id));
        }
        insert questionResponses;

        questionResponses = [SELECT Id, Question__c, NumberOfAttempt__c FROM QuestionResponse__c WHERE ModuleResponse__c = :moduleResponses.get(0).Id AND Question__r.Type__c = 'Short Answer'];

        questionResponses.get(0).TextValue__c = 'PC';

        update questionResponses.get(0);

        questionResponses = [SELECT Id, Question__c, NumberOfAttempt__c, TextValue__c FROM QuestionResponse__c WHERE ModuleResponse__c = :moduleResponses.get(0).Id AND Question__r.Type__c = 'Short Answer'];

        System.assertEquals('PC', questionResponses.get(0).TextValue__c);
    }

    /*  TEST-1803
        Create Question Response
        - Edit the question response already submitted (NOK)
    */
    @isTest static void ELR_0008_FA8() {
        moduleResponses = [SELECT Id, Module__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        questions = [SELECT Id FROM Question__c WHERE Module__c = :moduleResponses.get(0).Module__c];
        
        for (Question__c q: questions) {
            questionResponses.add( new QuestionResponse__c(Question__c = q.Id, ModuleResponse__c = moduleResponses.get(0).Id));
        }
        insert questionResponses;

        System.assertEquals(5, questionResponses.size());

        moduleResponses.get(0).IsSubmitted__c = true;

        update moduleResponses;

        questionResponses = [SELECT Id, Question__c, NumberOfAttempt__c FROM QuestionResponse__c WHERE ModuleResponse__c = :moduleResponses.get(0).Id AND Question__r.Type__c = 'Short Answer'];

        questionResponses.get(0).TextValue__c = 'PC';

        String errorMsg = '';
        try{
            update questionResponses.get(0);
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }
        
        System.debug(errorMsg);

        System.assert(errorMsg.contains('Cannot modify a question response already submitted'));
    }
    
    /*  TEST-1804
        Create Question Response
        - Submit the question response when there is already a correct question response for the related question (NOK)
    */
    @isTest static void ELR_0008_FA10(){
        moduleResponses = [SELECT Id, Module__c FROM ModuleResponse__c WHERE Module__r.Name = 'Basic' LIMIT 1];
        questions = [SELECT Id FROM Question__c WHERE Module__c = :moduleResponses.get(0).Module__c AND Type__c = 'Short Answer'];
        
        questionResponses.add( new QuestionResponse__c(Question__c = questions.get(0).Id, ModuleResponse__c = moduleResponses.get(0).Id));

        questionResponses.get(0).TextValue__c = 'PC';
        
        insert questionResponses;

        System.assertEquals(1, questionResponses.size());

        questionResponses.get(0).IsSubmitted__c = true;

        update questionResponses;

        questionResponses.clear();
        questionResponses.add( new QuestionResponse__c(Question__c = questions.get(0).Id, ModuleResponse__c = moduleResponses.get(0).Id));

        questionResponses.get(0).TextValue__c = 'PC';

        insert questionResponses;

        questionResponses.get(0).IsSubmitted__c = true;

        String errorMsg = '';
        try{
            update questionResponses;
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains(Label.ValidateQuestionResponseSubmit));
    }
}