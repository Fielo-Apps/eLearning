// CREATE TEST DATA WITH DEPENDENCY

String name = String.format('Fielo Course {0}', new List<String>{
  String.valueOf(Database.countQuery('SELECT COUNT() FROM FieloELR__Course__c WHERE Name like \'%Fielo Course%\'') + 1)
});

List<FieloPLT__Program__c> programs = new List<FieloPLT__Program__c>();
List<FieloELR__Course__c> courses = new List<FieloELR__Course__c>();
List<FieloELR__Module__c> modules = new List<FieloELR__Module__c>();
List<FieloELR__ModuleDependency__c> dependencies = new List<FieloELR__ModuleDependency__c>();
List<FieloELR__Question__c> questions = new List<FieloELR__Question__c>();
List<FieloELR__AnswerOption__c> answersOpList = new List<FieloELR__AnswerOption__c>();

programs = [SELECT Id, Name FROM FieloPLT__Program__c WHERE Name = 'Default'];

StaticResource st = ((List<StaticResource>)Database.query('SELECT Name, NamespacePrefix, Body, LastModifiedDate FROM StaticResource WHERE Name = \'CourseLogo\'')).get(0);

String logoUrl = String.format('/resource/{0}/{1}{2}', new List<String>{
    String.valueOf(st.LastModifiedDate.getTime()),
    String.isNotBlank(st.NamespacePrefix) ? (st.NamespacePrefix + '__') : '',
    st.Name
});

courses.add(new FieloELR__Course__c(
    Name = name,
    FieloELR__Program__c = programs.get(0).Id,
    FieloELR__Description__c = 'Savvy marketing, sales and channel management professionals want to provide members of their customer and ' +
                                'channel ecosystem with compelling programs that command their attention and boost their productivity. ',
    FieloELR__SubscriptionMode__c = 'Automatic',
    FieloELR__StartDatetime__c = System.today(),
    FieloELR__EndDatetime__c = System.today().addMonths(3),
    FieloELR__ExternalURL__c = logoUrl
));

modules.add(new FieloELR__Module__c( Name = '01 - Platform Basics', FieloELR__Course__r = courses.get(0), FieloELR__ApprovalGrade__c = 75, FieloELR__AttemptsAllowed__c = 10, FieloELR__AttemptsAllowedPerQuestion__c = 10, FieloELR__PenaltyMode__c = 'None', FieloELR__ContentType__c = 'Youtube Video', FieloELR__Content__c = 'https://www.youtube.com/embed/s2UYHc36UWM' ));
    questions.add(new FieloELR__Question__c(Name = 'Q1', FieloELR__Module__r = modules.get(0), FieloELR__QuestionText__c = 'Which object is related to the Single Action holds the configuration?', FieloELR__Type__c = 'Single Choice'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(0), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Promotion'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(0), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Mission Rewarding'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(0), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Mission'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(0), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Challenge'));

    questions.add(new FieloELR__Question__c(Name = 'Q2', FieloELR__Module__r = modules.get(0), FieloELR__QuestionText__c = 'What the PLT in the FieloPLT name stands for?', FieloELR__Type__c = 'Short Answer'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(1), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Platform'));

    questions.add(new FieloELR__Question__c(Name = 'Q3', FieloELR__Module__r = modules.get(0), FieloELR__QuestionText__c = 'Which objects are related to the incentives engine?', FieloELR__Type__c = 'Multiple Choice'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(2), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Rule Trigger'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(2), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Action'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(2), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Rule'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(2), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Contact'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(2), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Page Settings'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(2), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Course'));

    questions.add(new FieloELR__Question__c(Name = 'Q4', FieloELR__Module__r = modules.get(0), FieloELR__QuestionText__c = 'A Challenge may have many missions', FieloELR__Type__c = 'Statement'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(3), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'True'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(3), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'False'));

modules.add(new FieloELR__Module__c( Name = '02 - Apps', FieloELR__Course__r = courses.get(0), FieloELR__ApprovalGrade__c = 75, FieloELR__AttemptsAllowed__c = 2, FieloELR__AttemptsAllowedPerQuestion__c = 2, FieloELR__PenaltyMode__c = 'None', FieloELR__ContentType__c = 'Youtube Video', FieloELR__Content__c = 'https://www.youtube.com/embed/s2UYHc36UWM' ));
    questions.add(new FieloELR__Question__c(Name = 'Q1', FieloELR__Module__r = modules.get(1), FieloELR__QuestionText__c = 'Which of the following are Fielo Apps?', FieloELR__Type__c = 'Multiple Choice'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(4), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'FieloELR'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(4), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'FieloPRP'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(4), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'FieloGRS'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(4), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'FieloSHS'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(4), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'FieloPOP'));

    questions.add(new FieloELR__Question__c(Name = 'Q2', FieloELR__Module__r = modules.get(1), FieloELR__QuestionText__c = 'Which of the following objects belongs to FieloELR', FieloELR__Type__c = 'Multiple Choice'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(5), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Course'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(5), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Module'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(5), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Category'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(5), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Member'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(5), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Program'));

    questions.add(new FieloELR__Question__c(Name = 'Q3', FieloELR__Module__r = modules.get(1), FieloELR__QuestionText__c = 'Which of the following objects are related to the multi action engine?', FieloELR__Type__c = 'SiMultiplengle Choice'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(6), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Mission'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(6), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Challenge Reward'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(6), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Action'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(6), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Invoice'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(6), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Product'));

    questions.add(new FieloELR__Question__c(Name = 'Q4', FieloELR__Module__r = modules.get(1), FieloELR__QuestionText__c = 'Match package with its meaning', FieloELR__Type__c = 'Matching Options'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(7), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'FieloPLT', FieloELR__MatchingText__c = 'Incentive Automation System'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(7), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'FieloELR', FieloELR__MatchingText__c = 'E-Learning'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(7), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'FieloPRP', FieloELR__MatchingText__c = 'Proof Of Purchase'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(7), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'FieloGRS', FieloELR__MatchingText__c = 'Global Reward System Connector'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(7), FieloELR__IsCorrect__c = false, FieloELR__MatchingText__c = 'Content Management System'));

modules.add(new FieloELR__Module__c( Name = '03 - Final', FieloELR__Course__r = courses.get(0), FieloELR__ApprovalGrade__c = 75, FieloELR__AttemptsAllowed__c = 2, FieloELR__AttemptsAllowedPerQuestion__c = 2, FieloELR__PenaltyMode__c = 'None', FieloELR__ContentType__c = 'Youtube Video', FieloELR__Content__c = 'https://www.youtube.com/embed/s2UYHc36UWM' ));
    questions.add(new FieloELR__Question__c(Name = 'Q1', FieloELR__Module__r = modules.get(2), FieloELR__QuestionText__c = 'FieloPLT is responsible for the engine configuration and processing?', FieloELR__Type__c = 'Statement'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(8), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'True'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(8), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'False'));

modules.add(new FieloELR__Module__c( Name = '04 - Bonus', FieloELR__Course__r = courses.get(0), FieloELR__ApprovalGrade__c = 75, FieloELR__AttemptsAllowed__c = 2, FieloELR__AttemptsAllowedPerQuestion__c = 2, FieloELR__PenaltyMode__c = 'None', FieloELR__ContentType__c = 'Youtube Video', FieloELR__Content__c = 'https://www.youtube.com/embed/s2UYHc36UWM' ));
    questions.add(new FieloELR__Question__c(Name = 'Q1', FieloELR__Module__r = modules.get(3), FieloELR__QuestionText__c = '5 ^ 2 = ?', FieloELR__Type__c = 'Single Choice'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(9), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = '25'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(9), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = '10'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(9), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = '7'));
        answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(9), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = '2,5'));

dependencies = new List<FieloELR__ModuleDependency__c> {
    new FieloELR__ModuleDependency__c(FieloELR__Predecessor__r = modules.get(0), FieloELR__Module__r = modules.get(1)),
    new FieloELR__ModuleDependency__c(FieloELR__Predecessor__r = modules.get(0), FieloELR__Module__r = modules.get(2)),
    new FieloELR__ModuleDependency__c(FieloELR__Predecessor__r = modules.get(1), FieloELR__Module__r = modules.get(2)),
    new FieloELR__ModuleDependency__c(FieloELR__Predecessor__r = modules.get(0), FieloELR__Module__r = modules.get(3)),
    new FieloELR__ModuleDependency__c(FieloELR__Predecessor__r = modules.get(1), FieloELR__Module__r = modules.get(3)),
    new FieloELR__ModuleDependency__c(FieloELR__Predecessor__r = modules.get(2), FieloELR__Module__r = modules.get(3))
};

insert courses;

for (FieloELR__Module__c m : modules) m.FieloELR__Course__c = m.FieloELR__Course__r.Id;

insert modules;

for (FieloELR__ModuleDependency__c md : dependencies) {
    md.FieloELR__Predecessor__c = md.FieloELR__Predecessor__r.Id;
    md.FieloELR__Module__c = md.FieloELR__Module__r.Id;
}

insert dependencies;

for (FieloELR__Question__c q : questions) q.FieloELR__Module__c = q.FieloELR__Module__r.Id;

insert questions;

for (FieloELR__AnswerOption__c ao : answersOpList) ao.FieloELR__Question__c = ao.FieloELR__Question__r.Id;

insert answersOpList;


//Set Module Active
modules.get(0).FieloELR__IsActive__c = true;
modules.get(1).FieloELR__IsActive__c = true;
modules.get(2).FieloELR__IsActive__c = true;
modules.get(3).FieloELR__IsActive__c = true;
update modules;

//Set Course Active
courses.get(0).FieloELR__Status__c = 'Active';
update courses;