@isTest
public with sharing class TestPageSettingsController {
	@testSetup static void setup(){
        MockUpFactory.InsertTestData();
		
	List<FieloPLT__PageSettings__c> pageSettings = new List<FieloPLT__PageSettings__c>();

        pageSettings.add( new FieloPLT__PageSettings__c(
                Name = 'Module > View',
                FieloPLT__Object__c = 'FieloELR__Module__c',
                FieloPLT__Fieldset__c = '{"Name":"Name"},{"Name":"FieloELR__Course__r.Name"},{"Name":"FieloELR__IsActive__c"},{"Name":"FieloELR__WeightedQuestions__c"},{"Name":"FieloELR__PenaltyMode__c"}',
                FieloPLT__IsActive__c = true,
                FieloPLT__Type__c = 'View'
            )
        );

        pageSettings.add( new FieloPLT__PageSettings__c(
                Name = 'Module > Edit',
                FieloPLT__Object__c = 'FieloELR__Module__c',
                FieloPLT__Sections__c = '{"Name":"Information","Rows":[[{"Name":"Name","Type":"input"}],[{"Name":"FieloELR__Course__c","Type":"lookup"}],[{"Name":"FieloELR__ApprovalGrade__c","Type":"input"},{"Name":"FieloELR__AttemptsAllowed__c","Type":"input"},{"Name":"FieloELR__WeightedQuestions__c","Type":"checkbox"}],[{"Name":"FieloELR__PenaltyMode__c","Type":"picklist"},{"Name":"FieloELR__QuestionPool__c","Type":"input"},{"Name":"FieloELR__ShuffleQuestions__c","Type":"checkbox"}],[{"Name":"FieloELR__AttemptsAllowedPerQuestion__c","Type":"input"},{"Name":"FieloELR__Order__c","Type":"input"},{"Name":"FieloELR__IsActive__c","Type":"checkbox"}]]}',
                FieloPLT__IsActive__c = true,
                FieloPLT__Type__c = 'Edit'
            )
        );

        insert pageSettings; 

    }

	@isTest
	static void TestPageSettingsController() {
		
	}
}