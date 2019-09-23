@isTest
private class TestCreateQuestion{
    private static String errorMsg;

    @testSetup static void setup(){
        MockUpFactory.InsertTestData();
    }

    /*  TEST-1738
        Create Question - Question type is “Single Choice” (OK)
    */
    @isTest static void ELR_0005_FB() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        Map<String, String> questionsMap = new Map<String, String>{'Which one is the LEAST popular programming language?' => 'Single Choice'};

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);
        questions[0].Order__c = 0;
        questions[0].IncorrectWeight__c = 0;
        questions[0].PenaltyPerAttempt__c = 0;

        insert questions;

        questions = [SELECT Id, Name, Module__c, Type__c, QuestionText__c, Order__c, IncorrectWeight__c, PenaltyPerAttempt__c, CorrectWeight__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals(1,questions.size());
        System.assert(questions[0].Name != null);
        System.assert(questions[0].Module__c != null);
        System.assert(questions[0].Type__c != null);
        System.assert(questions[0].QuestionText__c != null);
        System.assert(questions[0].Order__c != null);
        System.assert(questions[0].IncorrectWeight__c != null);
        System.assert(questions[0].PenaltyPerAttempt__c != null);
        System.assert(questions[0].CorrectWeight__c != null);

        System.assertEquals(1,questions[0].CorrectWeight__c);
    }

    /*  TEST-1739
        Create Question
        - Validations
        - The related module is active (NOK)
    */
    @isTest static void ELR_0005_FA1() {
        MockUpFactory.activateCourse();

        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        Map<String, String> questionsMap = new Map<String, String>{'Which one is the LEAST popular programming language?' => 'Single Choice'};

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);

        errorMsg = '';
        try{
            insert questions;
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains(Label.ValidateQuestionActiveModulesQuestions));
    }

    /*  TEST-1740
        Create Question
        - Validations
        - The “Question Text” field is null (NOK)
    */
    @isTest static void ELR_0005_FA3() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        Map<String, String> questionsMap = new Map<String, String>{'Which one is the LEAST popular programming language?' => 'Single Choice'};

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);
        questions[0].QuestionText__c = null;

        String errorMsg = '';
        try{
            insert questions;
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains('The question text is required'));
    }

    /*  TEST-1741
        Create Question
        - Order field is null (OK)
    */
    @isTest static void ELR_0005_FA4() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        Map<String, String> questionsMap = new Map<String, String>{'Which one is the LEAST popular programming language?' => 'Single Choice'};

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);

        insert questions;

        questions = [SELECT Id, Name, Module__c, Type__c, QuestionText__c, Order__c, IncorrectWeight__c, PenaltyPerAttempt__c, CorrectWeight__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals(1,questions.size());
        
        //There are already 5 questions in the module.

        System.assertEquals(6, questions[0].Order__c);
    }

    /*  TEST-1742
        Create Question
        - Validations
        - The related module has module response (NOK)
    */
    @isTest static void ELR_0005_FA2() {
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];
        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.assert(moduleWrapper.moduleResponse.Id != null);

        Map<String, String> questionsMap = new Map<String, String>{'Which one is the LEAST popular programming language?' => 'Single Choice'};

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);

        errorMsg = '';
        try{
            insert questions;
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains(Label.ValidateQuestionActiveModulesQuestions));
    }

    /*  TEST-1743
        Create Question
        - “Correct Weight” field is greater than one and “Question Pool” of related module is not null (OK)
    */
    @isTest static void ELR_0005_FA5() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        module.QuestionPool__c = 3;

        update module;

        Map<String, String> questionsMap = new Map<String, String>{'Which one is the LEAST popular programming language?' => 'Single Choice'};

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);
        questions[0].CorrectWeight__c = 10;

        insert questions;

        System.assert(questions[0].Id != null);

        questions = [SELECT Id, CorrectWeight__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals(1, questions[0].CorrectWeight__c);

    }

    /*  TEST-1744
        Create Question
        - Validations
        - The “Correct Weight” field is negative and “Weighted Questions” of related module is true (NOK)
    */
    @isTest static void ELR_0005_FA6() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        module.WeightedQuestions__c = true;

        update module;

        Map<String, String> questionsMap = new Map<String, String>{'Which one is the LEAST popular programming language?' => 'Single Choice'};

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);
        questions[0].CorrectWeight__c = -10;

        errorMsg = '';
        try {
            insert questions;
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.assert(errorMsg.contains('The correct weight must be a positive number'));

        System.assert(questions[0].Id == null);
    }

    /*  TEST-1745
        Create Question
        - “Correct Weight” field is greater than one and “Weighted Questions” of related module is false (OK)
    */
    @isTest static void ELR_0005_FA7() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        module.WeightedQuestions__c = true;

        update module;

        Map<String, String> questionsMap = new Map<String, String>{'Which one is the LEAST popular programming language?' => 'Single Choice'};

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);
        questions[0].CorrectWeight__c = 10;

        insert questions;

        System.assert(questions[0].Id != null);

        questions = [SELECT Id, CorrectWeight__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals(10, questions[0].CorrectWeight__c);
    }

    /*  TEST-1746
        Create Question
        - “Incorrect Weight” field is null (OK)
    */
    @isTest static void ELR_0005_FA8() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        Map<String, String> questionsMap = new Map<String, String>{'Which one is the LEAST popular programming language?' => 'Single Choice'};

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);

        insert questions;

        questions = [SELECT Id, Name, Module__c, Type__c, QuestionText__c, Order__c, IncorrectWeight__c, PenaltyPerAttempt__c, CorrectWeight__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals(1,questions.size());
        System.assert(questions[0].IncorrectWeight__c != null);
        System.assertEquals(0,questions[0].IncorrectWeight__c);
    }

    /*  TEST-1747
        Create Question
        - “Penalty per Attempt” field is null (OK)
    */
    @isTest static void ELR_0005_FA9() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        Map<String, String> questionsMap = new Map<String, String>{'Which one is the LEAST popular programming language?' => 'Single Choice'};

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);
        
        System.assert(questions[0].PenaltyPerAttempt__c == null);

        insert questions;

        System.assert(questions[0].Id != null);

        questions = [SELECT Id, PenaltyPerAttempt__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals(0, questions[0].PenaltyPerAttempt__c);
    }

    /*  TEST-1748
        Create Question
        - Validations
        - “Penalty per Attempt” field is invalid (NOK)
    */
    @isTest static void ELR_0005_FA10() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        Map<String, String> questionsMap = new Map<String, String>{'Which one is the LEAST popular programming language?' => 'Single Choice'};

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);

        questions[0].PenaltyPerAttempt__c = 150;
        
        System.assert(questions[0].PenaltyPerAttempt__c != null);

        errorMsg = '';
        try {
            insert questions;    
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.debug(errorMsg.contains('The penalty per attempt must have a value  between 0 and 100'));

        System.assert(questions[0].Id == null);
    }

    /*  TEST-1749
        Create Question
        - Validations
        - The question “Type” field is null (NOK)
    */
    @isTest static void ELR_0005_FA11() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        Map<String, String> questionsMap = new Map<String, String>{'Which one is the LEAST popular programming language?' => 'Single Choice'};

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);

        questions[0].Type__c = null;
        
        System.assert(questions[0].Type__c == null);

        errorMsg = '';
        try {
            insert questions;    
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.debug(errorMsg.contains('Required fields are missing: [FieloELR__Type__c]'));

        System.assert(questions[0].Id == null);
    }

    /*  TEST-1750
        Create Question
        - Question type is “Statement” (OK)
    */
    @isTest static void ELR_0005_FA12() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        Map<String, String> questionsMap = new Map<String, String>{
            'C++ is more performatic then Java' => 'Statement'
        };

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);
        questions[0].Order__c = 0;
        questions[0].CorrectWeight__c = 1;
        questions[0].IncorrectWeight__c = 0;
        questions[0].PenaltyPerAttempt__c = 0;

        insert questions;

        questions = [SELECT Id, Name, Module__c, Type__c, QuestionText__c, Order__c, IncorrectWeight__c, PenaltyPerAttempt__c, CorrectWeight__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals(1,questions.size());
        System.assert(questions[0].Name != null);
        System.assert(questions[0].Module__c != null);
        System.assert(questions[0].Type__c != null);
        System.assert(questions[0].QuestionText__c != null);
        System.assert(questions[0].Order__c != null);
        System.assert(questions[0].IncorrectWeight__c != null);
        System.assert(questions[0].PenaltyPerAttempt__c != null);
        System.assert(questions[0].CorrectWeight__c != null);

        System.assertEquals(1,questions[0].CorrectWeight__c);
    }

    /*  TEST-1751
        Create Question
        - Question type is “Multiple Choice” (OK)
    */
    @isTest static void ELR_0005_FA13() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        Map<String, String> questionsMap = new Map<String, String>{
            'Select all Family-C programming languages?' => 'Multiple Choice'
        };

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);
        questions[0].Order__c = 0;
        questions[0].CorrectWeight__c = 1;
        questions[0].IncorrectWeight__c = 0;
        questions[0].PenaltyPerAttempt__c = 0;

        insert questions;

        questions = [SELECT Id, Name, Module__c, Type__c, QuestionText__c, Order__c, IncorrectWeight__c, PenaltyPerAttempt__c, CorrectWeight__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals(1,questions.size());
        System.assert(questions[0].Name != null);
        System.assert(questions[0].Module__c != null);
        System.assert(questions[0].Type__c != null);
        System.assert(questions[0].QuestionText__c != null);
        System.assert(questions[0].Order__c != null);
        System.assert(questions[0].IncorrectWeight__c != null);
        System.assert(questions[0].PenaltyPerAttempt__c != null);
        System.assert(questions[0].CorrectWeight__c != null);

        System.assertEquals(1,questions[0].CorrectWeight__c);
    }


    /*  TEST-1752
        Create Question
        - Question type is “Short Answer” (OK)
    */
    @isTest static void ELR_0005_FA14() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        Map<String, String> questionsMap = new Map<String, String>{
            'Acronym for Personal Computer' => 'Short Answer'
        };

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);
        questions[0].Order__c = 0;
        questions[0].CorrectWeight__c = 1;
        questions[0].IncorrectWeight__c = 0;
        questions[0].PenaltyPerAttempt__c = 0;

        insert questions;

        questions = [SELECT Id, Name, Module__c, Type__c, QuestionText__c, Order__c, IncorrectWeight__c, PenaltyPerAttempt__c, CorrectWeight__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals(1,questions.size());
        System.assert(questions[0].Name != null);
        System.assert(questions[0].Module__c != null);
        System.assert(questions[0].Type__c != null);
        System.assert(questions[0].QuestionText__c != null);
        System.assert(questions[0].Order__c != null);
        System.assert(questions[0].IncorrectWeight__c != null);
        System.assert(questions[0].PenaltyPerAttempt__c != null);
        System.assert(questions[0].CorrectWeight__c != null);

        System.assertEquals(1,questions[0].CorrectWeight__c);
    }

    /*  TEST-1753
        Create Question
        - Question type is “Matching Options” (OK)
    */
    @isTest static void ELR_0005_FA15() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        Map<String, String> questionsMap = new Map<String, String>{
            'Match statement with its meaning' => 'Matching Options'
        };

        List<FieloELR__Question__c> questions = MockUpFactory.createQuestions(module.Id, questionsMap);
        questions[0].Order__c = 0;
        questions[0].CorrectWeight__c = 1;
        questions[0].IncorrectWeight__c = 0;
        questions[0].PenaltyPerAttempt__c = 0;

        insert questions;

        questions = [SELECT Id, Name, Module__c, Type__c, QuestionText__c, Order__c, IncorrectWeight__c, PenaltyPerAttempt__c, CorrectWeight__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals(1,questions.size());
        System.assert(questions[0].Name != null);
        System.assert(questions[0].Module__c != null);
        System.assert(questions[0].Type__c != null);
        System.assert(questions[0].QuestionText__c != null);
        System.assert(questions[0].Order__c != null);
        System.assert(questions[0].IncorrectWeight__c != null);
        System.assert(questions[0].PenaltyPerAttempt__c != null);
        System.assert(questions[0].CorrectWeight__c != null);

        System.assertEquals(1,questions[0].CorrectWeight__c);
    }

    /*  TEST-1754
        Create Question
        - Delete question when related module is inactive and does not have module response (OK)
    */
    @isTest static void ELR_0005_FA16() {
        MockUpFactory.activateCourse();

        Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        module.IsActive__c = false;

        CourseService.inactivateCourses(new Set<Id>{module.Course__c});

        update module;

        List<Question__c> questions = [SELECT Id FROM Question__c WHERE Module__c = :module.Id];

        System.assertEquals(5, questions.size());

        delete [SELECT Id FROM Question__c WHERE Module__c = :module.Id LIMIT 1];

        questions = [SELECT Id FROM Question__c WHERE Module__c = :module.Id];

        System.assertEquals(4, questions.size());
    }

    /*  TEST-1755
        Create Question
        - Validations
        - Delete question when related module is active (NOK)
    */
    @isTest static void ELR_0005_FA18() {
        MockUpFactory.activateCourse();

        Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        List<Question__c> questions = [SELECT Id FROM Question__c WHERE Module__c = :module.Id];

        System.assertEquals(5, questions.size());

        errorMsg = '';
        try {
            delete [SELECT Id FROM Question__c WHERE Module__c = :module.Id LIMIT 1];
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains(Label.ValidateQuestionActiveModulesQuestions));

        questions = [SELECT Id FROM Question__c WHERE Module__c = :module.Id];

        System.assertEquals(5, questions.size());
    }

    /*  TEST-1756
        Create Question
        - Edit question when related module is inactive and does not have module response (OK)
    */
    @isTest static void ELR_0005_FA22() {
        MockUpFactory.activateCourse();

        Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        module.IsActive__c = false;

        CourseService.inactivateCourses(new Set<Id>{module.Course__c});

        update module;

        List<Question__c> questions = [SELECT Id, QuestionText__c FROM Question__c WHERE Module__c = :module.Id];

        System.assertEquals(5, questions.size());

        questions[0].QuestionText__c = questions[0].QuestionText__c + '??';

        update questions[0];

        questions = [SELECT Id, QuestionText__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals('??', questions[0].QuestionText__c.right(2));
    }

    /*  TEST-1757
        Create Question
        - Validations
        - Edit question when related module is active (NOK)
    */
    @isTest static void ELR_0005_FA21() {
        MockUpFactory.activateCourse();

        Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        List<Question__c> questions = [SELECT Id, QuestionText__c FROM Question__c WHERE Module__c = :module.Id];

        System.assertEquals(5, questions.size());

        questions[0].QuestionText__c = questions[0].QuestionText__c + '??';

        errorMsg = '';
        try{
            update questions[0];
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains(Label.ActiveModuleQuestionNotEditable));
    }

    /*  TEST-1758
        Create Question
        - Edit question when “Question Pool” of related module is different from null (OK)
    */
    @isTest static void ELR_0005_FA28() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        module.QuestionPool__c = 4;

        update module;

        List<Question__c> questions = [SELECT Id, CorrectWeight__c FROM Question__c WHERE Module__c = :module.Id];

        questions[0].CorrectWeight__c = 10;

        System.assertEquals(10,questions[0].CorrectWeight__c);

        update questions[0];

        questions = [SELECT Id, CorrectWeight__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals(1,questions[0].CorrectWeight__c);
    }

    /*  TEST-1759
        Create Question
        - Validations
        - Edit question type (NOK)
    */
    @isTest static void ELR_0005_FA19() {
        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];

        List<Question__c> questions = [SELECT Id, CorrectWeight__c, Type__c FROM Question__c WHERE Module__c = :module.Id AND Type__c = 'Single Choice'];

        questions[0].Type__c = 'Multiple Choice';

        System.assertEquals('Multiple Choice',questions[0].Type__c);

        errorMsg = '';
        try {
            update questions[0];
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains('The question type cannot be changed'));

        questions = [SELECT Id, CorrectWeight__c, Type__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals('Single Choice',questions[0].Type__c);
    }

    /*  TEST-1924
        Create Question
        - Validations
        - Delete question when related module is inactive and has module response (NOK)
    */
    @isTest static void ELR_0005_FA17() {
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];
        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.assert(moduleWrapper.moduleResponse.Id != null);

        List<FieloELR__Question__c> questions = [SELECT Id FROM Question__c WHERE Module__c = :module.Id];

        System.assertEquals(5, questions.size());

        errorMsg = '';
        try{
            delete questions[0];
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains(Label.ValidateQuestionActiveModulesQuestions));

        questions = [SELECT Id FROM Question__c WHERE Module__c = :module.Id];

        System.assertEquals(5, questions.size());
    }

    /*  TEST-1925
        Create Question
        - Validations
        - Edit the related module (NOK)
    */
    @isTest static void ELR_0005_FA20() {
        List<Module__c> modules = [SELECT Id FROM Module__c ORDER BY Name];
        /**
         *  ORDER BY Name
         *  modules[0] - Basic
         *  modules[1] - Intermediate
         **/
        List<FieloELR__Question__c> questions = [SELECT Id FROM Question__c WHERE Module__c = :modules[0].Id];

        System.assertEquals(5, questions.size());

        Id questionId = questions[0].Id;

        update new Question__c(
            Id = questions[0].Id,
            Module__c = modules[1].Id
        );

        questions = [SELECT Id, Module__c FROM Question__c WHERE Module__c = :modules[0].Id];

        System.assertEquals(5, questions.size());

        Map<Id, Question__c> questionsMap = new Map<Id, Question__c>(questions);

        System.assertEquals(questionsMap.get(questionId).Module__c, modules[0].Id);
    }

    /*  TEST-1926
        Create Question
        - Edit Question Name when related module is inactive and has module response (OK)
    */
    @isTest static void ELR_0005_FA23() {
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];
        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.assert(moduleWrapper.moduleResponse.Id != null);

        MockUpFactory.inactivateCourse();

        List<Question__c> questions = [SELECT Id, Name FROM Question__c WHERE Module__c = :module.Id];

        questions[0].Name = questions[0].Name + 'suffix';

        update questions[0];

        questions = [SELECT Id, Name FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals('suffix', questions[0].Name.right(6));
    }

    /*  TEST-1927
        Create Question
        - Edit Question Text when related module is inactive and has module response (OK)
    */
    @isTest static void ELR_0005_FA24() {
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];
        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.assert(moduleWrapper.moduleResponse.Id != null);

        MockUpFactory.inactivateCourse();

        List<Question__c> questions = [SELECT Id, QuestionText__c FROM Question__c WHERE Module__c = :module.Id];

        questions[0].QuestionText__c = questions[0].QuestionText__c + 'suffix';

        update questions[0];

        questions = [SELECT Id, QuestionText__c FROM Question__c WHERE Id = :questions[0].Id];

        System.assertEquals('suffix', questions[0].QuestionText__c.right(6));
    }

    /*  TEST-1928
        Create Question
        - Validations
        - Edit Correct Weight when related module is inactive and has module response (NOK)
    */
    @isTest static void ELR_0005_FA25() {
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];
        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.assert(moduleWrapper.moduleResponse.Id != null);

        MockUpFactory.inactivateCourse();

        List<Question__c> questions = [SELECT Id, CorrectWeight__c FROM Question__c WHERE Module__c = :module.Id];

        questions[0].CorrectWeight__c = 10;

        errorMsg = '';
        try{
            update questions[0];
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains(Label.QuestionReadOnlyFields));
    }

    /*  TEST-1929
        Create Question
        - Validations
        - Edit Penalty per Attempt when related module is inactive and has module response (NOK)
    */
    @isTest static void ELR_0005_FA26() {
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];
        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.assert(moduleWrapper.moduleResponse.Id != null);

        MockUpFactory.inactivateCourse();

        List<Question__c> questions = [SELECT Id, CorrectWeight__c FROM Question__c WHERE Module__c = :module.Id];

        questions[0].PenaltyPerAttempt__c = 50;

        errorMsg = '';
        try{
            update questions[0];
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains(Label.QuestionReadOnlyFields));
    }

    /*  TEST-1930
        Create Question
        - Validations
        - Edit Incorrect Weight when related module is inactive and has module response (NOK)
    */
    @isTest static void ELR_0005_FA27() {
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        Module__c module = [SELECT Id FROM Module__c WHERE Name = 'Basic'];
        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.assert(moduleWrapper.moduleResponse.Id != null);

        MockUpFactory.inactivateCourse();

        List<Question__c> questions = [SELECT Id, CorrectWeight__c FROM Question__c WHERE Module__c = :module.Id];

        questions[0].IncorrectWeight__c = 10;

        errorMsg = '';
        try{
            update questions[0];
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains(Label.QuestionReadOnlyFields));
    }
}