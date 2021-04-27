@isTest
public class MockUpFactory {

    private static Map<String, Id> rtMember;

    public static List<FieloPLT__Program__c> createPrograms(String basename, Integer count) {
        List<FieloPLT__Program__c> results = new List<FieloPLT__Program__c>();
        for(Integer x = 0; x < count; x++){
            FieloPLT__Program__c p = new FieloPLT__Program__c();
            p.Name = basename + String.valueOf(x);
            p.FieloPLT__OnlineTransactionProcessing__c = true;
            results.add(p);
        }
        return results;
    }

    //Created for FieloPRP
    public static List<FieloPLT__Member__c> createMembers(String programId, Integer count){
        List<FieloPLT__Member__c> membersToCreate = new List<FieloPLT__Member__c>();
        for(Integer x = 0; x < count; x++){
            membersToCreate.add(new FieloPLT__Member__c(
                    Name='Member '+String.valueOf(x),
                    FieloPLT__Email__c='email'+String.valueOf(x)+'l@example.com',
                    FieloPLT__Type__c='Individual Account',
                    FieloPLT__Program__c=programId
                )
            );
        }
        return membersToCreate;
    }

    public static List<FieloELR__Course__c> createCourses(String programId, String segmentId, Integer count){
        List<FieloELR__Course__c> coursesToCreate = new List<FieloELR__Course__c>();
        for(Integer x = 0; x < count; x++){
            coursesToCreate.add(new FieloELR__Course__c(
            		Name = 'Course ' + x,
                    FieloELR__Program__c = programId,
                    FieloELR__Description__c = 'Description',
                    FieloELR__SubscriptionMode__c = 'Manual',
                    FieloELR__Segment__c = segmentId,
                    FieloELR__StartDatetime__c = System.today(),
                    FieloELR__EndDatetime__c = System.today().addDays(30)
                )
            );
        }
        return coursesToCreate;
    }

    public static List<FieloPLT__Promotion__c> createPromotions(String basename, Integer count, Id programId){
        List<FieloPLT__Promotion__c> results = new List<FieloPLT__Promotion__c>();
        for(Integer x = 0; x < count; x++){
            FieloPLT__Promotion__c p = new FieloPLT__Promotion__c();
            p.Name = basename + String.valueOf(x);
            p.FieloPLT__Program__c = programId;
            results.add(p);
        }
        return results;
    }

    public static List<FieloPLT__Segment__c> createSegments(String basename, Integer count, String type){
        List<FieloPLT__Segment__c> results = new List<FieloPLT__Segment__c>();


        Id rtId = [SELECT Id FROM RecordType WHERE DeveloperName =: type].Id;
        for(Integer x = 0; x < count; x++){
            FieloPLT__Segment__c s = new FieloPLT__Segment__c();
            s.Name = basename + String.valueOf(x);
            s.RecordTypeId = rtId;
            results.add(s);
        }
        return results;
    }

    public static List<Question__c> createQuestions(Id moduleId, Map<String, String> questionsMap) {
        List<Question__c> questions = new List<Question__c>();
        for (String questionText: questionsMap.keySet()) {
            questions.add(
                new Question__c(
                    Name = 'Q' + questions.size(),
                    QuestionText__c = questionText,
                    Type__c = questionsMap.get(questionText),
                    Module__c = moduleId
                )
            );
        }
        return questions;
    }

    public static List<AnswerOption__c> createAnswerOptions(Id questionId, Map<String,Boolean> answerOptionsMap, Map<String, String> matchingTextMap) {
        List<AnswerOption__c> answers = new List<AnswerOption__c>();
        for (String answerOptionText: answerOptionsMap.keySet()) {
            answers.add(
                new AnswerOption__c(
                    Question__c = questionId,
                    IsCorrect__c = answerOptionsMap.get(answerOptionText),
                    AnswerOptionText__c = answerOptionText,
                    MatchingText__c = matchingTextMap.containsKey(answerOptionText) ? matchingTextMap.get(answerOptionText) : null
                )
            );
        }
        return answers;
    }

    public static ModuleResponse__c createModuleResponses(Id moduleId, Id memberId) {
        return new ModuleResponse__c(Module__c = moduleId, Member__c = memberId);
    }

    public static void InsertTestData() {
        List<FieloPLT__Program__c> programs = MockUpFactory.createPrograms('Default', 2);
        insert programs;

        List<FieloPLT__Segment__c> segments = MockUpFactory.createSegments('Segment',1,'Manual');
        insert segments;

        List<FieloELR__Course__c> courses = MockUpFactory.createCourses(programs.get(0).id, segments.get(0).id, 2);
        insert courses;

        List<FieloPLT__Member__c> members = MockUpFactory.createMembers(programs.get(0).id, 1);
        members.addAll(MockUpFactory.createMembers(programs.get(1).id, 1));
        members.addAll(MockUpFactory.createMembers(programs.get(0).id, 1));
        insert members;

        FieloPLT__MemberSegment__c memberSegment = new FieloPLT__MemberSegment__c(
            FieloPLT__Segment__c = segments.get(0).Id,
            FieloPLT__Member__c = members.get(0).Id
        );
        insert memberSegment;

        List<FieloELR__Module__c> modules = new List<FieloELR__Module__c> {
            new FieloELR__Module__c(
                Name = 'Basic',
                Course__c = courses.get(0).id,
                ApprovalGrade__c = 50,
                AttemptsAllowed__c = 2,
                AttemptsAllowedPerQuestion__c = 1
            ),
            new FieloELR__Module__c(
                Name = 'Intermediate',
                Course__c = courses.get(0).id,
                ApprovalGrade__c = 70,
                AttemptsAllowed__c = 2,
                AttemptsAllowedPerQuestion__c = 1
            ),
            new FieloELR__Module__c(
                Name = 'Basic 2',
                Course__c = courses.get(1).id,
                ApprovalGrade__c = 70,
                AttemptsAllowed__c = 2,
                AttemptsAllowedPerQuestion__c = 1
            )
        };
        insert modules;

        FieloELR__ModuleDependency__c moduleDependency = new FieloELR__ModuleDependency__c(
            Module__c = modules.get(1).Id,
            Predecessor__c = modules.get(0).Id
        );
        insert moduleDependency;

        //Question
        Map<String, String> questionsMap = new Map<String, String>{
            'Which one is the MOST popular programming language?' => 'Single Choice',
            'Select all Family-C programming languages?' => 'Multiple Choice',
            'Acronym for Personal Computer' => 'Short Answer',
            'C++ is more performatic then Java' => 'Statement',
            'Match statement with its meaning' => 'Matching Options'
        };

        List<FieloELR__Question__c> questions = createQuestions(modules.get(0).Id, questionsMap);

        questions.addAll(createQuestions(modules.get(2).Id, questionsMap));

        questionsMap = new Map<String, String>{
            'Which one is the LEAST popular programming language?' => 'Single Choice',
            'Select all loop statements' => 'Multiple Choice',
            'What is the smallest piece of information in Computing' => 'Short Answer',
            'One byte consists of 8 bits' => 'Statement',
            'Match Company with it\'s product' => 'Matching Options'
        };

        questions.addAll(createQuestions(modules.get(1).Id, questionsMap));

        insert questions;

        List<FieloELR__AnswerOption__c> answersOptions = new List<FieloELR__AnswerOption__c>();

        for (FieloELR__Question__c q: questions){
            if ((q.Module__c == modules.get(0).Id || q.Module__c == modules.get(2).Id) && q.Type__c == 'Single Choice') {
                answersOptions.addAll(
                    createAnswerOptions(q.Id,
                        new Map<String, Boolean> {
                            'Java' => false,
                            'PHP' => false,
                            'SQL' => false,
                            'Javascript' => true,
                            'C++' => false,
                            'HTML' => false
                        },
                        new Map<String, String>()
                    )
                );
            }
            if ((q.Module__c == modules.get(0).Id || q.Module__c == modules.get(2).Id) && q.Type__c == 'Multiple Choice') {
                answersOptions.addAll(
                    createAnswerOptions(q.Id,
                        new Map<String, Boolean> {
                            'Java' => true,
                            'C++' => true,
                            'PHP' => true,
                            'Python' => false,
                            'Objective-C' => true
                        },
                        new Map<String, String>()
                    )
                );
            }
            if ((q.Module__c == modules.get(0).Id || q.Module__c == modules.get(2).Id) && q.Type__c == 'Short Answer') {
                answersOptions.addAll(
                    createAnswerOptions(q.Id,
                        new Map<String, Boolean> {
                            'pc' => true,
                            'PC' => true
                        },
                        new Map<String, String>()
                    )
                );
            }
            if ((q.Module__c == modules.get(0).Id || q.Module__c == modules.get(2).Id) && q.Type__c == 'Statement') {
                answersOptions.addAll(
                    createAnswerOptions(q.Id,
                        new Map<String, Boolean> {
                            'True' => true,
                            'False' => false
                        },
                        new Map<String, String>()
                    )
                );
            }
            if ((q.Module__c == modules.get(0).Id || q.Module__c == modules.get(2).Id) && q.Type__c == 'Matching Options') {
                answersOptions.addAll(
                    createAnswerOptions(q.Id,
                        new Map<String, Boolean> {
                            'if' => true,
                            'for' => true,
                            'while' => true,
                            'break' => true,
                            'new' => true
                        },
                        new Map<String, String> {
                            'if' => 'conditional',
                            'for' => 'loop',
                            'while' => 'loop',
                            'break' => 'exit loop',
                            'new' => 'create instance'
                        }
                    )
                );
            }
            if (q.Module__c == modules.get(1).Id && q.Type__c == 'Single Choice') {
                answersOptions.addAll(
                    createAnswerOptions(q.Id,
                        new Map<String, Boolean> {
                            'Javascript' => false,
                            'C++' => false,
                            'PHP' => false,
                            'HTML' => false,
                            'Haskell' => true,
                            'Groovy' => false
                        },
                        new Map<String, String>()
                    )
                );
            }
            if (q.Module__c == modules.get(1).Id && q.Type__c == 'Multiple Choice') {
                answersOptions.addAll(
                    createAnswerOptions(q.Id,
                        new Map<String, Boolean> {
                            'if' => false,
                            'for' => true,
                            'while' => true,
                            'new' => false,
                            'do {...} while' => true
                        },
                        new Map<String, String>()
                    )
                );
            }
            if (q.Module__c == modules.get(1).Id && q.Type__c == 'Short Answer') {
                answersOptions.addAll(
                    createAnswerOptions(q.Id,
                        new Map<String, Boolean> {
                            'Bit' => true,
                            'BIT' => true,
                            'bit' => true
                        },
                        new Map<String, String>()
                    )
                );
            }
            if (q.Module__c == modules.get(1).Id && q.Type__c == 'Statement') {
                answersOptions.addAll(
                    createAnswerOptions(q.Id,
                        new Map<String, Boolean> {
                            'True' => true,
                            'False' => false
                        },
                        new Map<String, String>()
                    )
                );
            }
            if (q.Module__c == modules.get(1).Id && q.Type__c == 'Matching Options') {
                answersOptions.addAll(
                    createAnswerOptions(q.Id,
                        new Map<String, Boolean> {
                            'Apple' => true,
                            'Microsoft' => true,
                            'Ubisoft' => true,
                            'Google' => true,
                            'Mozzila' => true
                        },
                        new Map<String, String> {
                            'Apple' => 'Mac OS',
                            'Microsoft' => 'Windows',
                            'Ubisoft' => 'Unreal Tournament Game',
                            'Google' => 'Chrome',
                            'Mozzila' => 'Firefox'
                        }
                    )
                );
            }
        }
        insert answersOptions;
    }

    public static void activateCourse() {
        Map<Id, Module__c> modulesMap = new Map<Id, Module__c>();

        List<ModuleDependency__c> moduleDependencies = [SELECT Id, Module__r.Course__r.Id, Module__r.Id, Module__r.Name, Predecessor__r.Id, Predecessor__r.Name FROM ModuleDependency__c];
        List<Module__c> modules = [SELECT Id FROM Module__c];

        for (ModuleDependency__c md:moduleDependencies) {
            if (!modulesMap.containsKey(md.Predecessor__r.Id)) {
                md.Predecessor__r.IsActive__c = true;
                modulesMap.put(md.Predecessor__r.Id, md.Predecessor__r);
            }
            if (!modulesMap.containsKey(md.Module__r.Id)) {
                md.Module__r.IsActive__c = true;
                modulesMap.put(md.Module__r.Id, md.Module__r);
            }
        }
        for (Module__c module:modules) {
            if (!modulesMap.containsKey(module.Id)) {
                module.IsActive__c = true;
                modulesMap.put(module.Id, module);
            }
        }

        update modulesMap.values();

        Map<Id, Course__c> courses = new Map<Id, Course__c>([SELECT Id FROM Course__c]);

        CourseService.activateCourses(courses.keySet());
    }

    public static void inactivateCourse() {
        Map<Id, Module__c> modulesMap = new Map<Id, Module__c>();


        List<ModuleDependency__c> moduleDependencies = [SELECT Id, Module__r.Course__r.Id, Module__r.Id, Module__r.Name, Predecessor__r.Id, Predecessor__r.Name FROM ModuleDependency__c];
        List<Module__c> modules = [SELECT Id FROM Module__c];

        for (ModuleDependency__c md:moduleDependencies) {
            if (!modulesMap.containsKey(md.Module__r.Id)) {
                md.Module__r.IsActive__c = false;
                modulesMap.put(md.Module__r.Id, md.Module__r);
            }
            if (!modulesMap.containsKey(md.Predecessor__r.Id)) {
                md.Predecessor__r.IsActive__c = false;
                modulesMap.put(md.Predecessor__r.Id, md.Predecessor__r);
            }
        }
        for (Module__c module:modules) {
            if (!modulesMap.containsKey(module.Id)) {
                module.IsActive__c = false;
                modulesMap.put(module.Id, module);
            }
        }



        Map<Id, Course__c> courses = new Map<Id, Course__c>([SELECT Id FROM Course__c]);

        CourseService.inactivateCourses(courses.keySet());

        update modulesMap.values();
    }

    public static void answerModuleCorrectly(ModuleService.ModuleWrapper moduleWrapper) {
        List<QuestionResponse__c> questionResponses = new List<QuestionResponse__c>();
        List<Answer__c> answers = new List<Answer__c>();

        for (Question__c question: moduleWrapper.questions) {
            questionResponses.add(
                new QuestionResponse__c(
                    ModuleResponse__c = moduleWrapper.moduleresponse.Id,
                    Question__c = question.Id
                )
            );
        }
        insert questionResponses;

        Map<Id, Question__c> questionMap = new Map<Id, Question__c>([SELECT Id, Type__c, (SELECT Id, AnswerOptionText__c, MatchingText__c, IsCorrect__c FROM AnswerOptions__r) FROM Question__c WHERE Id in : new Map<Id,Question__c>(moduleWrapper.questions).keySet()]);
        List<QuestionResponse__c> needUpdate = new List<QuestionResponse__c>();

        for (QuestionResponse__c qr: questionResponses) {
            for (AnswerOption__c ao: questionMap.get(qr.Question__c).AnswerOptions__r) {
                if (questionMap.get(qr.Question__c).Type__c == 'Short Answer') {
                    if (ao.IsCorrect__c) {
                        qr.TextValue__c = ao.AnswerOptionText__c;
                        needUpdate.add(qr);
                        break;
                    }
                } else if (questionMap.get(qr.Question__c).Type__c == 'Single Choice' || questionMap.get(qr.Question__c).Type__c == 'Statement') {
                    if (ao.IsCorrect__c) {
                        answers.add(
                            new Answer__c(
                                QuestionResponse__c = qr.Id,
                                AnswerOption__c = ao.Id
                            )
                        );
                        break;
                    }
                } else if (questionMap.get(qr.Question__c).Type__c == 'Multiple Choice') {
                    if (ao.IsCorrect__c) {
                        answers.add(
                            new Answer__c(
                                QuestionResponse__c = qr.Id,
                                AnswerOption__c = ao.Id
                            )
                        );
                    }
                } else if (questionMap.get(qr.Question__c).Type__c == 'Matching Options') {
                    if (ao.IsCorrect__c) {
                        answers.add(
                            new Answer__c(
                                QuestionResponse__c = qr.Id,
                                AnswerOption__c = ao.Id,
                                TextValue__c = ao.MatchingText__c
                            )
                        );
                    }
                }
            }
        }
        if (!needUpdate.isEmpty()) {
            update needUpdate;
        }

        insert answers;

        update new ModuleResponse__c(
            Id = moduleWrapper.moduleresponse.Id,
            IsSubmitted__c = true
        );

        System.debug(JSON.serializePretty(questionResponses));
        System.debug(JSON.serializePretty(answers));
    }

    public static void answerModuleIncorrectly(ModuleService.ModuleWrapper moduleWrapper) {
        List<QuestionResponse__c> questionResponses = new List<QuestionResponse__c>();
        List<Answer__c> answers = new List<Answer__c>();

        for (Question__c question: moduleWrapper.questions) {
            questionResponses.add(
                new QuestionResponse__c(
                    ModuleResponse__c = moduleWrapper.moduleresponse.Id,
                    Question__c = question.Id
                )
            );
        }
        insert questionResponses;


        Map<Id, Question__c> questionMap = new Map<Id, Question__c>([SELECT Id, Type__c, (SELECT Id, AnswerOptionText__c, MatchingText__c, IsCorrect__c FROM AnswerOptions__r) FROM Question__c WHERE Id in : new Map<Id,Question__c>(moduleWrapper.questions).keySet()]);
        List<QuestionResponse__c> needUpdate = new List<QuestionResponse__c>();

        for (QuestionResponse__c qr: questionResponses) {
            for (AnswerOption__c ao: questionMap.get(qr.Question__c).AnswerOptions__r) {
                if (questionMap.get(qr.Question__c).Type__c == 'Short Answer') {
                    if (!ao.IsCorrect__c) {
                        qr.TextValue__c = ao.AnswerOptionText__c;
                        needUpdate.add(qr);
                        break;
                    }
                } else if (questionMap.get(qr.Question__c).Type__c == 'Single Choice' || questionMap.get(qr.Question__c).Type__c == 'Statement') {
                    if (!ao.IsCorrect__c) {
                        answers.add(
                            new Answer__c(
                                QuestionResponse__c = qr.Id,
                                AnswerOption__c = ao.Id
                            )
                        );
                        break;
                    }
                } else if (questionMap.get(qr.Question__c).Type__c == 'Multiple Choice') {
                    if (!ao.IsCorrect__c) {
                        answers.add(
                            new Answer__c(
                                QuestionResponse__c = qr.Id,
                                AnswerOption__c = ao.Id
                            )
                        );
                    }
                } else if (questionMap.get(qr.Question__c).Type__c == 'Matching Options') {
                    if (ao.IsCorrect__c) {
                        answers.add(
                            new Answer__c(
                                QuestionResponse__c = qr.Id,
                                AnswerOption__c = ao.Id,
                                TextValue__c = '!!Wrong Value!!'
                            )
                        );
                    }
                }
            }
        }
        if (!needUpdate.isEmpty()) {
            update needUpdate;
        }

        insert answers;

        update new ModuleResponse__c(
            Id = moduleWrapper.moduleresponse.Id,
            IsSubmitted__c = true
        );

        System.debug(JSON.serializePretty(questionResponses));
        System.debug(JSON.serializePretty(answers));
    }
}