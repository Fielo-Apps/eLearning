// CREATE TEST DATA WITH DEPENDENCY

String versionNo = String.format('Smoke Test {0}', new List<String>{
  String.valueOf(Database.countQuery('SELECT COUNT() FROM FieloELR__Course__c WHERE Name like \'%Smoke Test%\'') + 1)
});

List<FieloPLT__Program__c> programs = new List<FieloPLT__Program__c>();
List<FieloELR__Course__c> courses = new List<FieloELR__Course__c>();
List<FieloELR__Module__c> modules = new List<FieloELR__Module__c>();
List<FieloELR__Question__c> questions = new List<FieloELR__Question__c>();
List<FieloELR__AnswerOption__c> answersOpList = new List<FieloELR__AnswerOption__c>();

programs = [SELECT Id, Name FROM FieloPLT__Program__c WHERE Name = 'Default'];

courses.add(new FieloELR__Course__c( Name = 'Course ' + versionNo, FieloELR__Program__c = programs.get(0).Id, FieloELR__Description__c = 'Description', FieloELR__SubscriptionMode__c = 'Automatic'));

insert courses;

modules.add(new FieloELR__Module__c(Name = '01 - Basic', FieloELR__Course__c = courses.get(0).id, FieloELR__ApprovalGrade__c = 75, FieloELR__AttemptsAllowed__c = 2, FieloELR__AttemptsAllowedPerQuestion__c = 2, FieloELR__PenaltyMode__c = 'None', FieloELR__ContentType__c = 'Youtube Video', FieloELR__Content__c = 'https://www.youtube.com/embed/s2UYHc36UWM'));

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
questions.add(new FieloELR__Question__c(Name = 'Q1', FieloELR__Module__c = modules.get(0).Id, FieloELR__QuestionText__c = 'Which one is the most popular programming language?', FieloELR__Type__c = 'Short Answer'));
questions.add(new FieloELR__Question__c(Name = 'Q2', FieloELR__Module__c = modules.get(0).Id, FieloELR__QuestionText__c = 'Acronymn for Personal Computer', FieloELR__Type__c = 'Short Answer'));
questions.add(new FieloELR__Question__c(Name = 'Q3', FieloELR__Module__c = modules.get(0).Id, FieloELR__QuestionText__c = 'Name one Family-C programming language?', FieloELR__Type__c = 'Short Answer'));
questions.add(new FieloELR__Question__c(Name = 'Q4', FieloELR__Module__c = modules.get(0).Id, FieloELR__QuestionText__c = 'C++ is more performatic than java', FieloELR__Type__c = 'Statement'));

// Module Advanced
questions.add(new FieloELR__Question__c(Name = 'Q1', FieloELR__Module__c = modules.get(1).Id, FieloELR__QuestionText__c = 'Which one is the most popular programming language?', FieloELR__Type__c = 'Short Answer'));
questions.add(new FieloELR__Question__c(Name = 'Q2', FieloELR__Module__c = modules.get(1).Id, FieloELR__QuestionText__c = 'Acronymn for Personal Computer', FieloELR__Type__c = 'Short Answer'));
questions.add(new FieloELR__Question__c(Name = 'Q3', FieloELR__Module__c = modules.get(1).Id, FieloELR__QuestionText__c = 'Name one Family-C programming language?', FieloELR__Type__c = 'Short Answer'));
questions.add(new FieloELR__Question__c(Name = 'Q4', FieloELR__Module__c = modules.get(1).Id, FieloELR__QuestionText__c = 'C++ is more performatic than java', FieloELR__Type__c = 'Statement'));

// Module Final
questions.add(new FieloELR__Question__c(Name = 'Q1', FieloELR__Module__c = modules.get(2).Id, FieloELR__QuestionText__c = 'Salesforce is a Software or a Platform?', FieloELR__Type__c = 'Single Choice'));

// Module Bonus
questions.add(new FieloELR__Question__c(Name = 'Q1', FieloELR__Module__c = modules.get(3).Id, FieloELR__QuestionText__c = '5 ^ 2 = ?', FieloELR__Type__c = 'Single Choice'));

insert questions;

questions = [SELECT Id FROM FieloELR__Question__c WHERE Id in :questions ORDER BY FieloELR__Module__r.Name, Name];

// Answers Q1 - Basic
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(0).Id, FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'JavaScript'));

// Answers Q2 - Basic
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(1).Id, FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'PC'));

// Answers Q3 - Basic
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(2).Id, FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'C++'));

// Answers Q4 - Basic
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(3).Id, FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'True'));

// Answers Q1 - Advanced
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(4).Id, FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'JavaScript'));

// Answers Q2 - Advanced
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(5).Id, FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'PC'));

// Answers Q3 - Advanced
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(6).Id, FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'C++'));

// Answers Q4 - Advanced
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(7).Id, FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'True'));
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(7).Id, FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'False'));

// Answers Q1 - Final
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(8).Id, FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = 'Platform'));
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(8).Id, FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = 'Software'));

// Answers Q1 - Bonus
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(9).Id, FieloELR__IsCorrect__c = true, FieloELR__AnswerOptionText__c = '25'));
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(9).Id, FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = '10'));
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(9).Id, FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = '7'));
answersOpList.add(new FieloELR__AnswerOption__c(FieloELR__Question__c = questions.get(9).Id, FieloELR__IsCorrect__c = false, FieloELR__AnswerOptionText__c = '2,5'));


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
