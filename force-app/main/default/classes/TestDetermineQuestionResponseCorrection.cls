@isTest
private class TestDetermineQuestionResponseCorrection{
    private static String errorMsg;

    /*	TEST-1814
    	Determine Question Response Correction
    	- Question from type Single Choice is correct (OK)
    */
    @isTest static void ELR_0011_FB() {
        MockUpFactory.InsertTestData();
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

        MockUpFactory.answerModuleCorrectly(moduleWrapper);

        List<QuestionResponse__c> questionResponses = [SELECT Id, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Type__c = 'Single Choice' AND Question__r.Module__c = :module.Id];

        System.assertEquals(true, questionResponses[0].IsCorrect__c);
    }

    /*	TEST-1815
    	Determine Question Response Correction
    	- Question from type Single Choice is not correct (OK)
    */
    @isTest static void ELR_0011_FA1() {
        MockUpFactory.InsertTestData();
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

        MockUpFactory.answerModuleIncorrectly(moduleWrapper);

        List<QuestionResponse__c> questionResponses = [SELECT Id, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Type__c = 'Single Choice' AND Question__r.Module__c = :module.Id];

        System.assertEquals(false, questionResponses[0].IsCorrect__c);
    }

    /*	TEST-1816
    	Determine Question Response Correction
    	- Question from type Multiple Choice is correct (OK)
    */
    @isTest static void ELR_0011_FA2() {
        MockUpFactory.InsertTestData();
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

        MockUpFactory.answerModuleCorrectly(moduleWrapper);

        List<QuestionResponse__c> questionResponses = [SELECT Id, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Type__c = 'Multiple Choice' AND Question__r.Module__c = :module.Id];

        System.assertEquals(true, questionResponses[0].IsCorrect__c);
    }

    /*	TEST-1817
    	Determine Question Response Correction
    	- Question from type Multiple Choice is not correct (OK)
    */
    @isTest static void ELR_0011_FA3() {
        MockUpFactory.InsertTestData();
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

        MockUpFactory.answerModuleIncorrectly(moduleWrapper);

        List<QuestionResponse__c> questionResponses = [SELECT Id, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Type__c = 'Multiple Choice' AND Question__r.Module__c = :module.Id];

        System.assertEquals(false, questionResponses[0].IsCorrect__c);
    }

    /*	TEST-1818
    	Determine Question Response Correction
    	- Question from type Short Answer is correct (OK)
    */
    @isTest static void ELR_0011_FA4() {
        MockUpFactory.InsertTestData();
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

        MockUpFactory.answerModuleCorrectly(moduleWrapper);

        List<QuestionResponse__c> questionResponses = [SELECT Id, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Type__c = 'Short Answer' AND Question__r.Module__c = :module.Id];

        System.assertEquals(true, questionResponses[0].IsCorrect__c);
    }

    /*	TEST-1819
    	Determine Question Response Correction
    	- Question from type Short Answer is not correct (OK)
    */
    @isTest static void ELR_0011_FA5() {
        MockUpFactory.InsertTestData();
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

        MockUpFactory.answerModuleIncorrectly(moduleWrapper);

        List<QuestionResponse__c> questionResponses = [SELECT Id, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Type__c = 'Short Answer' AND Question__r.Module__c = :module.Id];

        System.assertEquals(false, questionResponses[0].IsCorrect__c);
    }

    /*	TEST-1820
    	Determine Question Response Correction
    	- Question from type Statement is correct (OK)
    */
    @isTest static void ELR_0011_FA6() {
        MockUpFactory.InsertTestData();
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

        MockUpFactory.answerModuleCorrectly(moduleWrapper);

        List<QuestionResponse__c> questionResponses = [SELECT Id, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Type__c = 'Statement' AND Question__r.Module__c = :module.Id];

        System.assertEquals(true, questionResponses[0].IsCorrect__c);
    }

    /*	TEST-1821
    	Determine Question Response Correction
    	- Question from type Statement is not correct (OK)
    */
    @isTest static void ELR_0011_FA7() {
        MockUpFactory.InsertTestData();
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

        MockUpFactory.answerModuleIncorrectly(moduleWrapper);

        List<QuestionResponse__c> questionResponses = [SELECT Id, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Type__c = 'Statement' AND Question__r.Module__c = :module.Id];

        System.assertEquals(false, questionResponses[0].IsCorrect__c);
    }

    /*	TEST-1822
    	Determine Question Response Correction
    	- Question from type Matching Options is correct (OK)
    */
    @isTest static void ELR_0011_FA8() {
        MockUpFactory.InsertTestData();
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

        MockUpFactory.answerModuleCorrectly(moduleWrapper);

        List<QuestionResponse__c> questionResponses = [SELECT Id, IsCorrect__c, (SELECT AnswerOption__r.AnswerOptionText__c, AnswerOption__r.MatchingText__c, TextValue__c FROM Answers__r) FROM QuestionResponse__c WHERE Question__r.Type__c = 'Matching Options' AND Question__r.Module__c = :module.Id];

        System.debug(JSON.serializePretty(questionResponses));

        System.assertEquals(true, questionResponses[0].IsCorrect__c);
    }

    /*	TEST-1823
    	Determine Question Response Correction
    	- Question from type Matching Options is not correct (OK)
    */
    @isTest static void ELR_0011_FA9() {
        MockUpFactory.InsertTestData();
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

        MockUpFactory.answerModuleIncorrectly(moduleWrapper);

        List<QuestionResponse__c> questionResponses = [SELECT Id, IsCorrect__c FROM QuestionResponse__c WHERE Question__r.Type__c = 'Matching Options' AND Question__r.Module__c = :module.Id];

        System.assertEquals(false, questionResponses[0].IsCorrect__c);
    }
}