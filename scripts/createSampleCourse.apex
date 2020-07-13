// CREATE TEST DATA WITH DEPENDENCY
String versionNo = 'Fielo Academy';

List<FieloPLT__Program__c> programs = new List<FieloPLT__Program__c>();
List<FieloELR__Course__c> courses = new List<FieloELR__Course__c>();
List<FieloELR__Module__c> modules = new List<FieloELR__Module__c>();
List<FieloELR__Question__c> questions = new List<FieloELR__Question__c>();
List<FieloELR__AnswerOption__c> answersOpList = new List<FieloELR__AnswerOption__c>();

programs = [SELECT Id, Name FROM FieloPLT__Program__c WHERE Name = 'Default'];

if (programs.isEmpty()) {
    programs.add(new FieloPLT__Program__c(
        Name = 'Default',
        FieloPLT__OnlineTransactionProcessing__c = true//,
    ));
    insert programs;
}

courses.add(new FieloELR__Course__c( Name = 'Fielo Course ', FieloELR__Program__c = programs.get(0).Id, FieloELR__Description__c = 'Description', FieloELR__SubscriptionMode__c = 'Automatic'));

insert courses;

modules.add(new FieloELR__Module__c(Name = '01 - Basic', FieloELR__Course__c = courses.get(0).id, FieloELR__ApprovalGrade__c = 75, FieloELR__AttemptsAllowed__c = 2, FieloELR__AttemptsAllowedPerQuestion__c = 2, FieloELR__PenaltyMode__c = 'None'));
modules.add(new FieloELR__Module__c(Name = '02 - Advanced', FieloELR__Course__c = courses.get(0).id, FieloELR__ApprovalGrade__c = 75, FieloELR__AttemptsAllowed__c = 2, FieloELR__AttemptsAllowedPerQuestion__c = 2, FieloELR__PenaltyMode__c = 'None'));
modules.add(new FieloELR__Module__c(Name = '03 - Final', FieloELR__Course__c = courses.get(0).id, FieloELR__ApprovalGrade__c = 75, FieloELR__AttemptsAllowed__c = 2, FieloELR__AttemptsAllowedPerQuestion__c = 2, FieloELR__PenaltyMode__c = 'None'));
modules.add(new FieloELR__Module__c(Name = '04 - Bonus', FieloELR__Course__c = courses.get(0).id, FieloELR__ApprovalGrade__c = 75, FieloELR__AttemptsAllowed__c = 2, FieloELR__AttemptsAllowedPerQuestion__c = 2, FieloELR__PenaltyMode__c = 'None'));

insert modules;

modules = [SELECT Id FROM FieloELR__Module__c WHERE Id in :modules ORDER BY Name];

insert new List<FieloELR__ModuleDependency__c> {
  new FieloELR__ModuleDependency__c(FieloELR__Predecessor__c = modules.get(0).Id, FieloELR__Module__c = modules.get(1).Id),
  new FieloELR__ModuleDependency__c(FieloELR__Predecessor__c = modules.get(0).Id, FieloELR__Module__c = modules.get(2).Id),
  new FieloELR__ModuleDependency__c(FieloELR__Predecessor__c = modules.get(1).Id, FieloELR__Module__c = modules.get(2).Id),
  new FieloELR__ModuleDependency__c(FieloELR__Predecessor__c = modules.get(0).Id, FieloELR__Module__c = modules.get(3).Id),
  new FieloELR__ModuleDependency__c(FieloELR__Predecessor__c = modules.get(1).Id, FieloELR__Module__c = modules.get(3).Id),
  new FieloELR__ModuleDependency__c(FieloELR__Predecessor__c = modules.get(2).Id, FieloELR__Module__c = modules.get(3).Id)
};

// Module Basic
questions.add(new FieloELR__Question__c(Name = 'Q1', FieloELR__Module__c = modules.get(0).Id, FieloELR__QuestionText__c = 'What means PLT in the FieloPLT app name', FieloELR__Type__c = 'Short Answer'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(0), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Platform'));

questions.add(new FieloELR__Question__c(Name = 'Q2', FieloELR__Module__c = modules.get(0).Id, FieloELR__QuestionText__c = 'How many apps have Fielo developed', FieloELR__Type__c = 'Single Choice'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(1), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = '1'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(1), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = '2'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(1), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = '5'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(1), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = '10'));

questions.add(new FieloELR__Question__c(Name = 'Q3', FieloELR__Module__c = modules.get(0).Id, FieloELR__QuestionText__c = 'Name the Fielo APP that is meant for training and certification', FieloELR__Type__c = 'Single Choice'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(2), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'FieloELR'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(2), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'FieloGRS'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(2), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'FieloPRP'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(2), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'FieloCMS'));

questions.add(new FieloELR__Question__c(Name = 'Q4', FieloELR__Module__c = modules.get(0).Id, FieloELR__QuestionText__c = 'Name the Fielo APP that is meant for upload invoices', FieloELR__Type__c = 'Single Choicet'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(3), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'FieloELR'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(3), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'FieloGRS'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(3), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'FieloPRP'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(3), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'FieloCMS'));

// Module Advanced
questions.add(new FieloELR__Question__c(Name = 'Q1', FieloELR__Module__c = modules.get(1).Id, FieloELR__QuestionText__c = 'What is FieloGRS?', FieloELR__Type__c = 'Single Choice'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(4), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Fielo Global Rewards System app'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(4), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Fielo Global Rewards System connector'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(4), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Fielo Global Rewards System plugin'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(4), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Fielo Global Rewards System platform'));

questions.add(new FieloELR__Question__c(Name = 'Q2', FieloELR__Module__c = modules.get(1).Id, FieloELR__QuestionText__c = 'Single action engine is represented by which object?', FieloELR__Type__c = 'Single Choice'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(5), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Challenge'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(5), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Promotion'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(5), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Point'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(5), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Redemption'));

questions.add(new FieloELR__Question__c(Name = 'Q3', FieloELR__Module__c = modules.get(1).Id, FieloELR__QuestionText__c = 'Multi action engine is represented by which object?', FieloELR__Type__c = 'Single Choice'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(6), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Challenge'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(6), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Promotion'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(6), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Point'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(6), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Redemption'));

questions.add(new FieloELR__Question__c(Name = 'Q4', FieloELR__Module__c = modules.get(1).Id, FieloELR__QuestionText__c = 'Fielo has 3 versions per Year', FieloELR__Type__c = 'Statement'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(7), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'True'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(7), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'False'));

// Module Final
questions.add(new FieloELR__Question__c(Name = 'Q1', FieloELR__Module__c = modules.get(2).Id, FieloELR__QuestionText__c = 'In wich version Fielo became an Rebate provider?', FieloELR__Type__c = 'Single Choice'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(8), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Summer 19'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(8), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Winter 20'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(8), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Spring 20'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(8), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Spring 19'));

// Module Bonus
questions.add(new FieloELR__Question__c(Name = 'Q1', FieloELR__Module__c = modules.get(3).Id, FieloELR__QuestionText__c = 'Where is Fielo HQ?', FieloELR__Type__c = 'Single Choice'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(9), FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Rio de Janeiro'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(9), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Buenos Aires'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(9), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'San Francisco'));
    answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__r = questions.get(9), FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Lisbon'));

insert questions;

for(FieloELR__AnswerOption__c ao : answersOpList) {
    ao.FieloELR__Question__c = ao.FieloELR__Question__r.Id;
}

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
