@isTest
private class TestCreateModuleResponse {
    private static List<FieloELR__ModuleResponse__c> moduleRespList = new List<FieloELR__ModuleResponse__c>();

    /*  TEST-1779
        Create Module Response
    */
    @isTest static void ELR_0007_FB() {
        MockUpFactory.InsertTestData();
        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c(
            Member__c = member.Id,
            Course__c = module.Course__c
        );
        insert courseStatus;

        Test.startTest();

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.debug(JSON.serializePretty(moduleWrapper));

        System.assert(moduleWrapper.moduleResponse.Id != null);

        FieloELR__ModuleResponse__c mr = [SELECT Id, FieloELR__NumberOfAttempt__c FROM FieloELR__ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id];

        System.assertEquals(1, mr.FieloELR__NumberOfAttempt__c);

        Test.stopTest();
    }

    /*  TEST-1780
        Create Module Response
        - Validations
        - Module field is null (NOK)
    */
    @isTest static void ELR_0007_FA1() {
        MockUpFactory.InsertTestData();
        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c(
            Member__c = member.Id,
            Course__c = module.Course__c
        );
        insert courseStatus;

        Test.startTest();

        FieloELR__ModuleResponse__c mr = new FieloELR__ModuleResponse__c(
            Member__c = member.Id,
            CourseStatus__c = courseStatus.Id
        );
        String errorMsg = '';
        try{
            insert mr;
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }
        System.debug(errorMsg);
        System.assert(errorMsg.contains(Label.ModuleRequiredField));

        Test.stopTest();
    }

    /*  TEST-1781
        Create Module Response
        - Validations
        - Related module is not active (NOK)
    */
    @isTest static void ELR_0007_FA2() {
        MockUpFactory.InsertTestData();
        delete [SELECT Id From ModuleDependency__c];

        Module__c module = [SELECT Id, Course__c From Module__c WHERE Name = 'Intermediate'];
        module.IsActive__c = true;
        update module;

        CourseService.activateCourses(new Set<Id>{module.Course__c});

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c(
            Member__c = member.Id,
            Course__c = module.Course__c
        );
        insert courseStatus;

        Test.startTest();

        String errorMsg = '';
        try {
            ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
                module.Id,
                member.Id,
                new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
                new Set<String> {'FieloELR__QuestionText__c'},
                new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
            );
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains('The related module must be active'));
    }

    /*  TEST-1782
        Create Module Response
        - Validations
        - Member field is null (NOK)
    */
    @isTest static void ELR_0007_FA3() {
        MockUpFactory.InsertTestData();
        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c(
            Member__c = member.Id,
            Course__c = module.Course__c
        );
        insert courseStatus;

        Test.startTest();
        FieloELR__ModuleResponse__c mr = new FieloELR__ModuleResponse__c(
            Module__c = module.Id,
            CourseStatus__c = courseStatus.Id
        );
        String errorMsg = '';
        try{
            insert mr;
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }
        System.debug(errorMsg);
        System.assert(errorMsg.contains(Label.MemberRequiredField));

        Test.stopTest();
    }

    /*  TEST-1783
        Create Module Response
        - Validations
        - Member is not approved in the predecessors modules (NOK)
    */
    @isTest static void ELR_0007_FA7() {
        MockUpFactory.InsertTestData();
        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Intermediate'];

        FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c(
            Member__c = member.Id,
            Course__c = module.Course__c
        );
        insert courseStatus;

        Test.startTest();
        FieloELR__ModuleResponse__c mr = new FieloELR__ModuleResponse__c(
            Module__c = module.Id,
            Member__c = member.Id,
            CourseStatus__c = courseStatus.Id
        );
        String errorMsg = '';
        try{
            insert mr;
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }
        System.debug(errorMsg);
        System.assert(errorMsg.contains(Label.ValidateModuleResponseMemberApproved));

        Test.stopTest();
    }

    /*  TEST-1784
        Create Module Response
        - Validations
        - The date of the response is not within the period of the course (NOK)
    */
    @isTest static void ELR_0007_FA8() {
        MockUpFactory.InsertTestData();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.StartDatetime__c = System.today();
        course.EndDatetime__c = System.today().addDays(30);

        update course;

        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c(
            Member__c = member.Id,
            Course__c = module.Course__c
        );
        insert courseStatus;

        Test.startTest();

        FieloELR__ModuleResponse__c mr = new FieloELR__ModuleResponse__c(
            Module__c = module.Id,
            Member__c = member.Id,
            CourseStatus__c = courseStatus.Id,
            Date__c = System.today().addDays(-1)
        );

        String errorMsg = '';
        try{
            insert mr;
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains('The course is not available in this period') || errorMsg.contains(Label.OutOfCoursePeriod));

        mr = new FieloELR__ModuleResponse__c(
            Module__c = module.Id,
            Member__c = member.Id,
            CourseStatus__c = courseStatus.Id,
            Date__c = System.today().addDays(40)
        );

        errorMsg = '';
        try{
            insert mr;
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg.contains('The course is not available in this period') || errorMsg.contains(Label.OutOfCoursePeriod));

        Test.stopTest();
    }

    /*  TEST-1785
        Create Module Response
        - The Number of Attempt is equal to the “Attempts Allowed” of the related module (OK)
    */
    @isTest static void ELR_0007_FA9() {
        MockUpFactory.InsertTestData();
        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c(
            Member__c = member.Id,
            Course__c = module.Course__c
        );
        insert courseStatus;

        Test.startTest();

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.debug(JSON.serializePretty(moduleWrapper));

        System.assert(moduleWrapper.moduleResponse.Id != null);

        moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        FieloELR__ModuleResponse__c mr = [SELECT Id, NumberOfAttempt__c, LastChance__c FROM FieloELR__ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id];

        System.assertEquals(mr.NumberOfAttempt__c, moduleWrapper.module.AttemptsAllowed__c);

        System.assertEquals(mr.NumberOfAttempt__c, moduleWrapper.module.AttemptsAllowed__c);

        System.assertEquals(true,mr.LastChance__c);

        Test.stopTest();
    }

    /*  TEST-1786
        Create Module Response
        - Validations
        - The Number of Attempt is greater than the “Attempts Allowed” of the related module (NOK)
    */
    @isTest static void ELR_0007_FA10() {
        MockUpFactory.InsertTestData();
        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c(
            Member__c = member.Id,
            Course__c = module.Course__c
        );
        insert courseStatus;

        Test.startTest();

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.assert(moduleWrapper.moduleResponse.Id != null);

        moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        FieloELR__ModuleResponse__c mr = [SELECT Id, NumberOfAttempt__c, LastChance__c FROM FieloELR__ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id];

        System.assertEquals(mr.NumberOfAttempt__c, moduleWrapper.module.AttemptsAllowed__c);

        System.assertEquals(mr.NumberOfAttempt__c, moduleWrapper.module.AttemptsAllowed__c);

        System.assertEquals(true,mr.LastChance__c);

        String errorMsg = '';
        try{
            moduleWrapper = FieloELR.ModuleService.takeModule(
                module.Id,
                member.Id,
                new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
                new Set<String> {'FieloELR__QuestionText__c'},
                new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
            );
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.assert(errorMsg.contains('You have reached the limit of attempts for this module'));

        Test.stopTest();
    }

    /*  TEST-1787
        Create Module Response
        - The related course subscription mode is manual and the related course status does not exist (NOK)
    */
    @isTest static void ELR_0007_FA11() {
        MockUpFactory.InsertTestData();
        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        Test.startTest();

        String errorMsg = '';
        try{
            ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
                module.Id,
                member.Id,
                new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
                new Set<String> {'FieloELR__QuestionText__c'},
                new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
            );
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.assert(errorMsg.contains('The member is not registered in the related course'));

        Test.stopTest();
    }

    /*  TEST-1788
        Create Module Response - The related course subscription mode is automatic and the related course status already exists (OK)
    */
    @isTest static void ELR_0007_FA12() {
        MockUpFactory.InsertTestData();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c(
            Member__c = member.Id,
            Course__c = module.Course__c
        );
        CourseService.enableAdminPermission(true);
        insert courseStatus;
        CourseService.enableAdminPermission(false);

        Test.startTest();

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.debug(JSON.serializePretty(moduleWrapper));

        System.assert(moduleWrapper.moduleResponse.Id != null);

        FieloELR__ModuleResponse__c mr = [SELECT Id, FieloELR__NumberOfAttempt__c FROM FieloELR__ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id];

        System.assertEquals(1, mr.FieloELR__NumberOfAttempt__c);

        Test.stopTest();
    }

    /*  TEST-1789
        Create Module Response
        - The related course subscription mode is automatic and the related course status does not exist (OK)
    */
    @isTest static void ELR_0007_FA13() {
        MockUpFactory.InsertTestData();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        Test.startTest();

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.debug(JSON.serializePretty(moduleWrapper));

        System.assert(moduleWrapper.moduleResponse.Id != null);

        FieloELR__ModuleResponse__c mr = [SELECT Id, FieloELR__NumberOfAttempt__c FROM FieloELR__ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id];

        System.assertEquals(1, mr.FieloELR__NumberOfAttempt__c);

        Test.stopTest();
    }

    /*  TEST-1790
        Create Module Response - The administrator sets the “IsApproved” field to “true” (OK)
    */
    @isTest static void ELR_0007_FA14() {
        MockUpFactory.InsertTestData();
        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c(
            Member__c = member.Id,
            Course__c = module.Course__c
        );
        insert courseStatus;

        Test.startTest();

        FieloELR__ModuleResponse__c mr = new FieloELR__ModuleResponse__c(
            Module__c = module.Id,
            Member__c = member.Id,
            CourseStatus__c = courseStatus.Id,
            IsApproved__c = true
        );

        insert mr;

        mr = [SELECT Id, IsApproved__c FROM ModuleResponse__c WHERE Id = :mr.Id];

        System.assertEquals(false, mr.IsApproved__c);

        Test.stopTest();
    }

    /*  TEST-1791
        Create Module Response
        - Delete a module response not submitted (OK)
    */
    @isTest static void ELR_0007_FA15() {
        MockUpFactory.InsertTestData();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        Test.startTest();

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.assert(moduleWrapper.moduleResponse.Id != null);

        FieloELR__ModuleResponse__c mr = [SELECT Id, FieloELR__NumberOfAttempt__c FROM FieloELR__ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id];

        System.assertEquals(1, mr.FieloELR__NumberOfAttempt__c);

        delete [SELECT Id, FieloELR__NumberOfAttempt__c FROM FieloELR__ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id];

        System.assertEquals(0, [SELECT Id FROM ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id].size());

        Test.stopTest();
    }

    /*  TEST-1792
        Create Module Response
        - Delete a module response already submitted (OK)
    */
    @isTest static void ELR_0007_FA16() {
        MockUpFactory.InsertTestData();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        Test.startTest();

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.assert(moduleWrapper.moduleResponse.Id != null);

        FieloELR__ModuleResponse__c mr = [SELECT Id, FieloELR__NumberOfAttempt__c FROM FieloELR__ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id];

        mr.IsSubmitted__c = true;

        update mr;

        delete [SELECT Id, FieloELR__NumberOfAttempt__c FROM FieloELR__ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id];

        System.assertEquals(0, [SELECT Id FROM ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id].size());

        Test.stopTest();
    }

    /*  TEST-1793
        Create Module Response
        - Edit the course status of a module response not submitted (NOK)
    */
    @isTest static void ELR_0007_FA17() {
        MockUpFactory.InsertTestData();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        List<Course__c> courses = [SELECT Id FROM Course__c ORDER BY Name];
        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        CourseStatus__c cs = new CourseStatus__c (
            Course__c = courses[1].Id,
            Member__c = member.Id
        );

        insert cs;

        Test.startTest();

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.assert(moduleWrapper.moduleResponse.Id != null);

        FieloELR__ModuleResponse__c mr = [SELECT Id, FieloELR__NumberOfAttempt__c FROM FieloELR__ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id];

        mr.CourseStatus__c = cs.Id;

        String errorMsg = '';
        try{
            update mr;
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.assert(errorMsg.contains('Course Status can\'t be modified'));

        Test.stopTest();
    }

    /*  TEST-1794
        Create Module Response
        - Edit a module response already submitted (NOK)
    */
    @isTest static void ELR_0007_FA21() {
        MockUpFactory.InsertTestData();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        Test.startTest();

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            module.Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        System.assert(moduleWrapper.moduleResponse.Id != null);

        System.debug(JSON.serializePretty(moduleWrapper));

        MockUpFactory.answerModuleCorrectly(moduleWrapper);

        FieloELR__ModuleResponse__c mr = [SELECT Id, NumberOfAttempt__c, IsApproved__c, IsSubmitted__c FROM FieloELR__ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id];

        System.assertEquals('IsSubmited: ' + true, 'IsSubmited: ' + mr.IsSubmitted__c);

        System.assertEquals('IsApproved: ' + true, 'IsApproved: ' + mr.IsApproved__c);

        mr.FieloELR__IsSubmitted__c = false;

        String errorMsg = '';
        try{
            update mr;
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.assert(errorMsg.contains(Label.ValidateModuleResponseSubmitted));

        Test.stopTest();
    }

    /*  TEST-1918
        Create Module Response
        - Validations
        - Member does not belong to the program of the related course (NOK)
    */
    @isTest static void ELR_0007_FA4() {
        MockUpFactory.InsertTestData();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        List<FieloPLT__Member__c> members = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c ORDER BY Name];
        List<FieloELR__Module__c> modules = [SELECT Id, Course__c FROM Module__c ORDER BY Name];

        /**
         *  Order By Name:
         *  modules[0] - Basic
         *  modules[1] - Intermediate
         *
         *  member[0] - Member 0 - Program Default 0
         *  member[1] - Member 1 - Program Default 1
         *  member[2] - Member 2 - Program Default 0
        **/

        Test.startTest();

        String errorMsg = '';
        try{
            ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
                modules[0].Id,
                members[1].Id,
                new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
                new Set<String> {'FieloELR__QuestionText__c'},
                new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
            );
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.assert(errorMsg.contains('The member should belong to the course\'s program'));

        Test.stopTest();
    }

    /*  TEST-1919
        Create Module Response
        - Validations
        - Member does not belong to any of the segments of the related course (NOK)
    */
    @isTest static void ELR_0007_FA5() {
        MockUpFactory.InsertTestData();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        delete [SELECT Id FROM FieloPLT__MemberSegment__c];

        MockUpFactory.activateCourse();

        List<FieloPLT__Member__c> members = [SELECT Id, FieloPLT__RelatedSegments__c, FieloPLT__Program__c FROM FieloPLT__Member__c ORDER BY Name];
        List<FieloELR__Module__c> modules = [SELECT Id, Course__c FROM Module__c WHERE Course__r.Name = 'Course 0' ORDER BY Name];

        /**
         *  Order By Name:
         *  modules[0] - Basic
         *  modules[1] - Intermediate
         *
         *  member[0] - Member 0 - Program Default 0
         *  member[1] - Member 1 - Program Default 1
         *  member[2] - Member 2 - Program Default 0
        **/

        members.get(0).FieloPLT__RelatedSegments__c = null;
        update members;

        System.assert(String.isBlank(members.get(0).FieloPLT__RelatedSegments__c), 'Related Segments should be empty: ' + members.get(0).FieloPLT__RelatedSegments__c);

        Test.startTest();

        String errorMsg = '';
        try{
            ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
                modules[0].Id,
                members[0].Id,
                new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
                new Set<String> {'FieloELR__QuestionText__c'},
                new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
            );
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.assert(errorMsg.contains('The member does not apply to the course\'s segment'), 'Wrong message: ' + errorMsg);

        Test.stopTest();
    }

    /*  TEST-1920
        Create Module Response
        - Validations
        - Related course is not active (NOK)
    */
    @isTest static void ELR_0007_FA6() {
        MockUpFactory.InsertTestData();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        FieloELR__Module__c module = [SELECT Id, Course__c FROM Module__c WHERE Name = 'Basic'];

        Test.startTest();

        String errorMsg = '';
        try {
            ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
                module.Id,
                member.Id,
                new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
                new Set<String> {'FieloELR__QuestionText__c'},
                new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
            );
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.assert(errorMsg.contains('Course Status must be related to a Course with the Status Active') || errorMsg.contains('The related course must be active'));

        Test.stopTest();
    }

    /*  TEST-1921
        Create Module Response
        - Edit the member of a module response not submitted (NOK)
    */
    @isTest static void ELR_0007_FA18() {
        MockUpFactory.InsertTestData();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        List<FieloPLT__Member__c> members = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c ORDER BY Name];
        List<FieloELR__Module__c> modules = [SELECT Id, Course__c FROM Module__c ORDER BY Name];

        /**
         *  Order By Name:
         *  modules[0] - Basic
         *  modules[1] - Intermediate
         *
         *  member[0] - Member 0 - Program Default 0
         *  member[1] - Member 1 - Program Default 1
         *  member[2] - Member 2 - Program Default 0
        **/

        Test.startTest();

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            modules[0].Id,
            members[0].Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        String errorMsg = '';
        try{
            update new ModuleResponse__c(
                Id = moduleWrapper.moduleResponse.Id,
                Member__c = members[2].Id
            );
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.assert(errorMsg.contains('The member cannot be changed'));

        Test.stopTest();
    }

    /*  TEST-1922
        Create Module Response
        - Edit the module of a module response not submitted (NOK)
    */
    @isTest static void ELR_0007_FA19() {
        MockUpFactory.InsertTestData();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        List<FieloELR__Module__c> modules = [SELECT Id, Course__c FROM Module__c ORDER BY Name];

        /**
         *  Order By Name:
         *  modules[0] - Basic
         *  modules[1] - Intermediate
        **/

        Test.startTest();

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            modules[0].Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        String errorMsg = '';
        try{
            update new ModuleResponse__c(
                Id = moduleWrapper.moduleResponse.Id,
                Module__c = modules[1].Id
            );
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        System.debug(errorMsg);

        System.assert(errorMsg.contains('The module cannot be changed'));

        Test.stopTest();
    }

    /*  TEST-1923
        Create Module Response
        - Edit the date of a module response not submitted (OK)
    */
    @isTest static void ELR_0007_FA20() {
        MockUpFactory.InsertTestData();
        Course__c course = [SELECT Id FROM Course__c WHERE Name = 'Course 0' LIMIT 1];

        course.SubscriptionMode__c = 'Automatic';

        update course;

        MockUpFactory.activateCourse();

        FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Name = 'Member 0' LIMIT 1];
        List<FieloELR__Module__c> modules = [SELECT Id, Course__c FROM Module__c ORDER BY Name];

        /**
         *  Order By Name:
         *  modules[0] - Basic
         *  modules[1] - Intermediate
        **/

        Test.startTest();

        ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
            modules[0].Id,
            member.Id,
            new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
            new Set<String> {'FieloELR__QuestionText__c'},
            new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c','FieloELR__IsCorrect__c'}
        );

        update new ModuleResponse__c(
            Id = moduleWrapper.moduleResponse.Id,
            Date__c = System.today().addDays(1)
        );

        ModuleResponse__c mr = [SELECT Id, Date__c FROM ModuleResponse__c WHERE Id = :moduleWrapper.moduleResponse.Id];

        System.assertEquals(mr.Date__c, System.today().addDays(1));

        Test.stopTest();
    }
}