@isTest
public with sharing class TestFormModelController {
	@testSetup static void setup(){
        MockUpFactory.InsertTestData();
    }	

	@isTest
	static void TestFormModelController() {
	

	sObject course = [SELECT Id FROM FieloELR__Course__c LIMIT 1];

	FieloPLT__Model__c fModelCntlr = FormModelController.retrieve(
		'Course__c'
		,course.Id
		,'Name');

	}
}