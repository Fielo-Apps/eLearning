@isTest
public with sharing class TestFormQuestionController {
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
	static void TestFormQuestionController() {
		
		FormQuestionController questController = new FormQuestionController();
		questController.csObjectName = 'FieloELR__Course__c';
		questController.cFilter = '';
		questController.cLayout = '';
		FormQuestionController.cRecordRedirect = true;

		FieloPLT__PageSettings__c pageSettingsTest = new FieloPLT__PageSettings__c();
        pageSettingsTest  = questController.getPageSettings(
            'Module > View');


		List<sObject> courses = [SELECT Id FROM FieloELR__Course__c];
		sObject course;
		if(!courses.isEmpty()){
			course = courses.get(0);
		}
		questController.cRecord = course;

		FormQuestionController.Section section = new FormQuestionController.Section();
		FormQuestionController.FormField formfield = new FormQuestionController.FormField();		
		questController.cFieldset = '{"Name":"Information","Rows":[[{"Name":"Name","Type":"input"}],[{"Name":"FieloELR__Program__c","Type":"lookup"}],[{"Name":"FieloELR__Segment__c","Type":"multiselect"}],[{"Name":"FieloELR__SubscriptionMode__c","Type":"radio"}],[{"Name":"FieloELR__Description__c","Type":"input"}],[{"Name":"FieloELR__StartDate__c","Type":"input"},{"Name":"FieloELR__EndDate__c","Type":"input"}], [{"Name":"FieloELR__Status__c","Type":"picklist"}]]}';

		System.assert(questController.recordObject != null);

		section.Name =  'none';
		section.CssClass = 'none';

		System.assertEquals('none', section.Name);
		System.assertEquals('none', section.CssClass);
		System.assert(questController.mapOptionsString != null);

		formfield.Type = 'picklist';
		formfield.MetaField = 'none';
		formfield.onchange = 'none';
		formfield.Label = 'none';
		formfield.Value = 'none';
	  	formfield.Name = 'none';
	    formfield.WhereCondition = 'none';
	    
	    List<FormQuestionController.FormField> innerList = new List<FormQuestionController.FormField>{formfield};
	   section.Rows = new List<List<FormQuestionController.FormField>>{innerList};

	   FieloELR__Question__c question = [SELECT Id FROM FieloELR__Question__c LIMIT 1]; 
	   List<FieloELR__AnswerOption__c> ansOpt1 = [SELECT Id FROM FieloELR__AnswerOption__c LIMIT 2]; 
	   List<String> optNull = new List<String>{'listNull'};
	   Map<Id, List<String>> answOptNull = new Map<Id,List<String>>{question.Id => optNull};
	   RemoteActionResult resultSave = FormQuestionController.save(
	   		question
	   		,new List<String>{
	   			'Answer'
	   			}
	   		,ansOpt1
	   		,answOptNull
	   		,new List<Id>{
	   			question.id});


		String fields = String.join( new List<String>(Schema.describeSObjects(
			new String[]{'FieloELR__Course__c'})[0].fields.getMap().keySet()) ,',');
		FieloELR__Course__c retrievedCourse = (FieloELR__Course__c) FormQuestionController.retrieve('FieloELR__Course__c', course.Id, fields);

		

    //System.assertEquals('picklist', formfield.Type);
    System.assertEquals('none', formfield.MetaField);
    System.assertEquals('none', formfield.onchange);
    System.assertEquals('none', formfield.Value);
    System.assertEquals(null, formfield.Required);
    System.assertEquals('', formfield.getRequiredValue());
    
    formfield.Required = true;
    System.assertEquals(true, formfield.Required);
    System.assertEquals('true', formfield.getRequiredValue());


	}
}