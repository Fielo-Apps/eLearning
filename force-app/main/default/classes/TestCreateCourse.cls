@isTest
private class TestCreateCourse{
    private static List<FieloPLT__Program__c> programs;
    private static List<FieloPLT__Segment__c> segments;
    private static List<FieloELR__Course__c> courses;
    private static List<FieloPLT__Member__c> members;
    private static List<FieloELR__Question__c>  questions = new List<FieloELR__Question__c>();
    private static List<FieloELR__Module__c> modules = new List<FieloELR__Module__c>();
    private static List<FieloELR__AnswerOption__c> answers = new List<FieloELR__AnswerOption__c>();

    @testSetup
    static void setup(){ 

        //Programs
        programs = MockUpFactory.createPrograms('testProgram', 2);
        insert programs;

        //Segments
        segments = MockUpFactory.createSegments('testSegment',2,'Manual');
        segments.get(0).FieloPLT__Program__c = programs.get(0).id;
        segments.get(1).FieloPLT__Program__c = programs.get(1).id;
        insert segments;

        //Courses 
        courses = MockUpFactory.createCourses(programs.get(0).id, segments.get(0).id, 5);
        
        //course to check status
        courses.get(0).FieloELR__Description__c = 'aTestCourse';
     
        //course to activate
        courses.get(1).FieloELR__Program__c = programs.get(0).id;

        //course active
        courses.get(2).FieloELR__Program__c = programs.get(0).id;
        
        //course with course status && active
        courses.get(3).FieloELR__Program__c = programs.get(1).id;
        courses.get(3).FieloELR__Segment__c = segments.get(1).id;
        insert courses;

        //set course 4 to inactive
        courses.get(4).FieloELR__Status__c = 'Inactive';
        update courses.get(4);

        //Members
        members = MockUpFactory.createMembers(programs.get(0).id, 2);
        members.get(1).FieloPLT__Program__c = programs.get(1).id;
        insert members;

        List<FieloPLT__MemberSegment__c> memberSegments = new List<FieloPLT__MemberSegment__c>();
        memberSegments.add(new FieloPLT__MemberSegment__c(FieloPLT__Member__c = members.get(0).Id,FieloPLT__Segment__c = segments.get(0).id));
        memberSegments.add(new FieloPLT__MemberSegment__c(FieloPLT__Member__c = members.get(1).Id,FieloPLT__Segment__c = segments.get(1).id));
        insert memberSegments;

        //Module
        FieloELR__Module__c moduleTest = new FieloELR__Module__c();
        moduleTest.Name = 'testModule';
        moduleTest.FieloELR__Course__c = courses.get(3).id;
        moduleTest.FieloELR__ApprovalGrade__c = 0;
        modules.add(moduleTest);
        
        FieloELR__Module__c moduleTest2 = new FieloELR__Module__c();
        moduleTest2.Name = 'testModule';
        moduleTest2.FieloELR__Course__c = courses.get(2).id;
        moduleTest2.FieloELR__ApprovalGrade__c = 0;
        modules.add(moduleTest2);

        FieloELR__Module__c moduleTest3 = new FieloELR__Module__c();
        moduleTest3.Name = 'testModule';
        moduleTest3.FieloELR__Course__c = courses.get(1).id;
        moduleTest3.FieloELR__ApprovalGrade__c = 0;
        modules.add(moduleTest3);
        insert modules;


        //Question
        FieloELR__Question__c question1 = new FieloELR__Question__c();
        question1.Name = 'question1';
        question1.FieloELR__Module__c = modules.get(0).Id;
        question1.FieloELR__QuestionText__c = 'How are you?';
        question1.FieloELR__Type__c = 'Short Answer';
        questions.add(question1);

        FieloELR__Question__c question2 = new FieloELR__Question__c();
        question2.Name = 'question2';
        question2.FieloELR__Module__c = modules.get(1).Id;
        question2.FieloELR__QuestionText__c = 'How are you?';
        question2.FieloELR__Type__c = 'Short Answer';
        questions.add(question2);

        FieloELR__Question__c question3 = new FieloELR__Question__c();
        question3.Name = 'question3';
        question3.FieloELR__Module__c = modules.get(2).Id;
        question3.FieloELR__QuestionText__c = 'How are you?';
        question3.FieloELR__Type__c = 'Short Answer';
        questions.add(question3);
        insert questions;

        //Answer
        FieloELR__AnswerOption__c answers1 = new FieloELR__AnswerOption__c();
        answers1.FieloELR__Question__c = questions.get(0).Id;
        answers1.FieloELR__IsCorrect__c = true;
        answers1.FieloELR__AnswerOptionText__c = 'Esta es correcta';
        answers.add(answers1);

        FieloELR__AnswerOption__c answers2 = new FieloELR__AnswerOption__c();
        answers2.FieloELR__Question__c = questions.get(1).Id;
        answers2.FieloELR__IsCorrect__c = true;
        answers2.FieloELR__AnswerOptionText__c = 'Esta es correcta';
        answers.add(answers2);

        FieloELR__AnswerOption__c answers3 = new FieloELR__AnswerOption__c();
        answers3.FieloELR__Question__c = questions.get(2).Id;
        answers3.FieloELR__IsCorrect__c = true;
        answers3.FieloELR__AnswerOptionText__c = 'Esta es correcta';
        answers.add(answers3);
        insert answers;

        //Active Modules
        modules.get(0).FieloELR__IsActive__c = true;
        modules.get(1).FieloELR__IsActive__c = true;
        modules.get(2).FieloELR__IsActive__c = true;
        update modules;
        //Active courses
        courses.get(3).FieloELR__Status__c = 'Active';
        courses.get(2).FieloELR__Status__c = 'Active';
        update courses.get(3);
        update courses.get(2);

        // FieloPLT.SObjectService.setStaticVariables();
          //Course Status
        FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c();
        courseStatus.FieloELR__Member__c = members.get(1).id;
        courseStatus.FieloELR__Course__c = courses.get(3).id;
        insert courseStatus;
    }

    /*  TEST-1662
        Create Course - (OK)
    */
    @isTest
    static void ELR_0001_FB1(){

        courses = [SELECT id,FieloELR__Status__c,FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Name = 'Course 0'];
        
        System.assertEquals(0,courses.get(0).FieloELR__ActiveModules__c);
        System.assertEquals('Draft',courses.get(0).FieloELR__Status__c);
    }

    /*  TEST-1663
        Create Course
        - Validations
        - The Program is not filled (NOK)
    */
    @isTest static void ELR_0001_FA1(){
        courses = new List<FieloELR__Course__c>{
            new FieloELR__Course__c(Name = 'TestName')
        };

        try{
            insert courses.get(0);
        }catch(System.DmlException e){
            System.assert(e.getMessage().Contains('You must select a Program'));
        }
    }

    /*  TEST-1664
        Create Course
        - Validations
        - The segment is not from the same program (NOK)
    */
    @isTest static void ELR_0001_FA2(){
        courses = new List<FieloELR__Course__c>{
            new FieloELR__Course__c(Name = 'TestName')
        };

        courses.get(0).FieloELR__Program__c = [SELECT Id FROM FieloPLT__Program__c WHERE Name = 'testProgram0' LIMIT 1].id;
        courses.get(0).FieloELR__Segment__c = [SELECT Id FROM FieloPLT__Segment__c WHERE Name = 'testSegment1' LIMIT 1 ].id;

        try{
            insert courses.get(0);
        }catch(System.DmlException e){
            System.assert(e.getMessage().Contains('Segment must be on the same program.'));
        }
    }

    /*  TEST-1667
        Create Course
        - Edit a Draft Course - (OK)
    */
    @isTest static void ELR_0001_FA8() {
        courses = [SELECT Id,FieloELR__Status__c,FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Name = 'Course 1' LIMIT 1];
        
        System.assertEquals('Draft', courses.get(0).FieloELR__Status__c);
        
        courses.get(0).FieloELR__Order__c = 3;

        update courses.get(0);

        System.assertEquals(3, courses.get(0).FieloELR__Order__c);
        System.assertEquals('Draft', courses.get(0).FieloELR__Status__c);
    }

    /*  TEST-1668
        Create Course
        - Subscription Mode is null - (OK)
    */
    @isTest static void ELR_0001_FA6() {
        FieloELR__Course__c course = new FieloELR__Course__c();
        course.Name = 'Course SubscriptionLess';
        course.FieloELR__Program__c = [SELECT Id, Name FROM FieloPLT__Program__c LIMIT 1].Id;
        course.FieloELR__Description__c = 'Description';
        course.FieloELR__Segment__c = [SELECT Id, Name From FieloPLT__Segment__c WHERE FieloPLT__Program__c = :course.FieloELR__Program__c LIMIT 1].Id;

        insert course;

        System.assert(course.Id != null);
        System.assertEquals('Manual', [SELECT Id, Name, FieloELR__SubscriptionMode__c FROM FieloELR__Course__c WHERE Id = :course.Id].FieloELR__SubscriptionMode__c);
    }

    /*  TEST-1669
        Create Course
        - Validations
        - Edit an active course (NOK)
    */
    @isTest static void ELR_0001_FA9() {
        courses = [SELECT Id,FieloELR__Status__c,FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Name = 'Course 1' LIMIT 1];
        
        courses.get(0).FieloELR__Status__c = 'Active';
        
        FieloELR.Courses.validateAdminFields = false;
        update courses.get(0);
        FieloELR.Courses.validateAdminFields = true;

        courses = [SELECT Id, Name, FieloELR__Status__c, FieloELR__SubscriptionMode__c FROM FieloELR__Course__c WHERE Id = :courses.get(0).Id LIMIT 1];

        System.assertEquals('Active', courses.get(0).FieloELR__Status__c);
        System.assertEquals('Manual', courses.get(0).FieloELR__SubscriptionMode__c);

        courses.get(0).FieloELR__SubscriptionMode__c = 'Automatic';

        try{
            update courses.get(0);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        System.assertEquals('Manual', [SELECT Id, Name, FieloELR__SubscriptionMode__c FROM FieloELR__Course__c WHERE Id = :courses.get(0).Id LIMIT 1].FieloELR__SubscriptionMode__c);
    }

    /*  TEST-1670
        Create Course
        - Delete a Draft Course (OK)
    */
    @isTest static void ELR_0001_FA11() {
        courses = [SELECT Id,FieloELR__Status__c,FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Name = 'Course 1' LIMIT 1];
        
        System.assertEquals('Draft', courses.get(0).FieloELR__Status__c);

        delete courses.get(0);

        courses = [SELECT Id,FieloELR__Status__c,FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Id = :courses.get(0).Id LIMIT 1];

        System.assertEquals(0, courses.size());
    }

    /*  TEST-1671
        Create Course
        - Delete an inactive course with no related course status - (OK)
    */
    @isTest static void ELR_0001_FA14() {
        courses = [SELECT Id,FieloELR__Status__c,FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Name = 'Course 1' LIMIT 1];
        
        System.assertEquals('Draft', courses.get(0).FieloELR__Status__c);

        courses.get(0).FieloELR__Status__c = 'Active';

        FieloELR.Courses.validateAdminFields = false;
        update courses.get(0);
        FieloELR.Courses.validateAdminFields = true;

        System.assertEquals('Active', [Select Id, Name, FieloELR__Status__c FROM FieloELR__Course__c WHERE Id = :courses.get(0).Id LIMIT 1].FieloELR__Status__c);

        courses.get(0).FieloELR__Status__c = 'Inactive';

        FieloELR.Courses.validateAdminFields = false;
        update courses.get(0);
        FieloELR.Courses.validateAdminFields = true;

        System.assertEquals('Inactive', [Select Id, Name, FieloELR__Status__c FROM FieloELR__Course__c WHERE Id = :courses.get(0).Id LIMIT 1].FieloELR__Status__c);

        delete courses.get(0);

        courses = [SELECT Id,FieloELR__Status__c,FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Id = :courses.get(0).Id LIMIT 1];

        System.assertEquals(0, courses.size());
    }

    /*  TEST-1672
        Create Course
        - Validations
        - Delete an inactive course with related course status (NOK)
    */
    @isTest static void ELR_0001_FA15() {
        courses = [SELECT Id,FieloELR__Status__c,FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Name = 'Course 3' LIMIT 1];
        
        System.assertEquals('Active', courses.get(0).FieloELR__Status__c);

        courses.get(0).FieloELR__Status__c = 'Inactive';

        FieloELR.Courses.validateAdminFields = false;
        update courses.get(0);
        FieloELR.Courses.validateAdminFields = true;

        try{
            delete courses.get(0);
        } catch (Exception e) {}

        courses = [SELECT Id,FieloELR__Status__c,FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Name = 'Course 3' LIMIT 1];

        System.assertEquals(1, courses.size());
    }

    /*  TEST-1673
        Create Course
        - Validations
        - Edit the program of a course (NOK)
    */
    @isTest static void ELR_0001_FA7() {
        courses = [SELECT Id,FieloELR__Status__c,FieloELR__ActiveModules__c,FieloELR__Program__c, FieloELR__Program__r.Name FROM FieloELR__Course__c WHERE Name = 'Course 1' LIMIT 1];
        
        System.assertEquals('Draft', courses.get(0).FieloELR__Status__c);
        System.assertEquals('testProgram0', courses.get(0).FieloELR__Program__r.Name);

        Id programId = courses.get(0).FieloELR__Program__c;

        courses.get(0).FieloELR__Program__c = [Select Id, Name FROM FieloPLT__Program__c WHERE Name = 'testProgram1' LIMIT 1].Id;

        try{
            update courses.get(0);
        } catch(Exception e) {}

        System.assertEquals('testProgram0', [SELECT Id, FieloELR__Program__r.Name FROM FieloELR__Course__c WHERE Id = :courses.get(0).Id LIMIT 1].FieloELR__Program__r.Name);
    }

    /*  TEST-1676
        Create Course
        - Delete an active course with no related course status - (OK)
    */
    @isTest static void ELR_0001_FA12() {
        courses = [SELECT Id,FieloELR__Status__c,FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Name = 'Course 1' LIMIT 1];
        
        System.assertEquals('Draft', courses.get(0).FieloELR__Status__c);

        courses.get(0).FieloELR__Status__c = 'Active';

        FieloELR.Courses.validateAdminFields = false;
        update courses.get(0);
        FieloELR.Courses.validateAdminFields = true;

        System.assertEquals('Active', [Select Id, Name, FieloELR__Status__c FROM FieloELR__Course__c WHERE Id = :courses.get(0).Id LIMIT 1].FieloELR__Status__c);

        delete courses.get(0);

        courses = [SELECT Id, Name FROM FieloELR__Course__c WHERE Id = :courses.get(0).Id];

        System.assertEquals(0, courses.size());
    }

    /*  TEST-1677
        Create Course
        - Validations
        - Delete an active course with related course status - (NOK)
    */
    @isTest static void ELR_0001_FA13() {
        courses = [SELECT Id,FieloELR__Status__c,FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Name = 'Course 3' LIMIT 1];
        
        System.assertEquals('Active', courses.get(0).FieloELR__Status__c);

        try{
            delete courses.get(0);
        } catch (Exception e) {}

        courses = [SELECT Id,FieloELR__Status__c,FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Name = 'Course 3' LIMIT 1];

        System.assertEquals(1, courses.size());
    }

    /*  TEST-1680
        Create Course
        - Edit an Inactive Course - (OK)
    */
    @isTest static void ELR_0001_FA10() {
        courses = [SELECT Id,FieloELR__Status__c,FieloELR__Order__c, FieloELR__ActiveModules__c FROM FieloELR__Course__c WHERE Name = 'Course 3' LIMIT 1];
        
        System.assertEquals('Active', courses.get(0).FieloELR__Status__c);

        courses.get(0).FieloELR__Status__c = 'Inactive';

        FieloELR.Courses.validateAdminFields = false;
        update courses.get(0);
        FieloELR.Courses.validateAdminFields = true;

        System.assertNotEquals(99,courses.get(0).FieloELR__Order__c);

        courses.get(0).FieloELR__Order__c = 99;

        update courses.get(0);

        courses = [SELECT Id,FieloELR__Status__c,FieloELR__Order__c FROM FieloELR__Course__c WHERE Name = 'Course 3' LIMIT 1];

        System.assertEquals(99, courses.get(0).FieloELR__Order__c);
    }

    /*  TEST-1760
        Create Course
        - Validations
        - Start date is earlier than the current date - (NOK)
    */
    @isTest static void ELR_0001_FA3() {
        courses = new List<FieloELR__Course__c>{
            new FieloELR__Course__c(Name = 'TestName')
        };
        FieloPLT__Segment__c segment = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Segment__c WHERE Name = 'testSegment0' LIMIT 1];
        courses.get(0).FieloELR__Program__c = segment.FieloPLT__Program__c;
        courses.get(0).FieloELR__Segment__c = segment.Id;
        courses.get(0).FieloELR__StartDate__c = Date.today() - 10;

        try{
            insert courses;
        }catch(System.Dmlexception e){
            System.assert(e.getMessage().Contains('Start Date and End Date must be equal or greater than today date.'));
        }
    }

    /*  TEST-1761
        Create Course
        - Validations
        - End date is earlier than the current date - (NOK)
    */
    @isTest static void ELR_0001_FA4(){
        courses = new List<FieloELR__Course__c>{
            new FieloELR__Course__c(Name = 'TestName')
        };
        FieloPLT__Segment__c segment = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Segment__c WHERE Name = 'testSegment0' LIMIT 1];
        courses.get(0).FieloELR__Program__c = segment.FieloPLT__Program__c;
        courses.get(0).FieloELR__Segment__c = segment.Id;
        courses.get(0).FieloELR__EndDate__c = Date.today() - 10;

        try{
            insert courses;
        }catch(System.Dmlexception e){
            System.assert(e.getMessage().Contains('Start Date and End Date must be equal or greater than today date.'));
        }
    } 

    /*  TEST-1762
        Create Course
        - Validations
        - Start date is later than the end date - (NOK)
    */
    @isTest static void ELR_0001_FA21(){
        courses = new List<FieloELR__Course__c>{new FieloELR__Course__c(Name = 'TestName')};
        FieloPLT__Segment__c segment = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Segment__c WHERE Name = 'testSegment0' LIMIT 1];
        courses.get(0).FieloELR__Program__c = segment.FieloPLT__Program__c;
        courses.get(0).FieloELR__Segment__c = segment.Id;
        courses.get(0).FieloELR__EndDate__c = Date.today() + 10;
        courses.get(0).FieloELR__StartDate__c = Date.today() + 20;
        
        try{
            insert courses;
        }catch(System.Dmlexception e){
            System.assert(e.getMessage().Contains('Start Date cannot be greater than End Date'));
        }
    }
}