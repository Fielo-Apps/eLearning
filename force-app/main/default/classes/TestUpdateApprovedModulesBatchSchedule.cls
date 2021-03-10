@isTest
public class TestUpdateApprovedModulesBatchSchedule {

    static void setup(){
        MockUpFactory.InsertTestData();
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
    }

    @isTest
    static void runUpdate(){
        setup();

        Test.startTest();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        System.assertEquals('Automatic', [SELECT SubscriptionMode__c FROM Course__c WHERE Id = :course.Id LIMIT 1].SubscriptionMode__c);

        MockUpFactory.activateCourse();

        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of rows queried in this apex code so far: ' + Limits.getDmlRows());

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        List<Module__c> modules = [SELECT Id, Course__c FROM Module__c WHERE Name IN ('Basic','Intermediate') AND Course__c = :course.Id ORDER BY Name];
        FieloELR__Module__c module1 = modules[0];
        FieloELR__Module__c module2 = modules[1];

        ModuleService.ModuleWrapper moduleWrapper1 = FieloELR.ModuleService.takeModule(
            module1.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of rows queried in this apex code so far: ' + Limits.getDmlRows());

        System.assertEquals(String.valueOf(course.Id) + String.valueOf(member.Id), [SELECT ExternalKey__c FROM CourseStatus__c LIMIT 1].ExternalKey__c);

        MockUpFactory.answerModuleCorrectly(moduleWrapper1);

        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('Number of rows queried in this apex code so far: ' + Limits.getDmlRows());

        System.assertEquals(1, [SELECT count() FROM CourseStatus__c]);

        ModuleResponse__c mr = [SELECT Id, IsSubmitted__c, IsApproved__c FROM ModuleResponse__c WHERE Id = :moduleWrapper1.moduleResponse.Id];

        System.assertEquals(true, mr.isSubmitted__c);
        System.assertEquals(true, mr.IsApproved__c);

        ModuleService.ModuleWrapper moduleWrapper2 = FieloELR.ModuleService.takeModule(
            module2.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        MockUpFactory.answerModuleCorrectly(moduleWrapper2);

        mr = [SELECT Id, IsSubmitted__c, IsApproved__c, CourseStatus__c, CourseStatus__r.Progress__c, CourseStatus__r.Course__r.Name, CourseStatus__r.ApprovedModules__c FROM ModuleResponse__c WHERE Id = :moduleWrapper2.moduleResponse.Id];

        System.assertEquals(true, mr.isSubmitted__c);
        System.assertEquals(true, mr.IsApproved__c);
        System.assertEquals(1, [SELECT Count() FROM CourseStatus__c]);
        System.assertEquals('Course 0',mr.CourseStatus__r.Course__r.Name);
        System.assertEquals(2,mr.CourseStatus__r.ApprovedModules__c);
        System.assertEquals(100, mr.CourseStatus__r.FieloELR__Progress__c);

        insert new FieloPLT__PublicSettings__c (FieloELR__EnableEditingWhileActive__c  = true);

        update new Module__c(
            Id = module1.Id,
            IsActive__c = false
        );

        DataBase.executeBatch(new UpdateApprovedModulesBatchSchedule());
        Test.stopTest();
    }
}