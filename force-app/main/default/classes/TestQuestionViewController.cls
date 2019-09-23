@isTest
public with sharing class TestQuestionViewController {
	@testSetup static void setup(){
        MockUpFactory.InsertTestData();
    }	


	@isTest
	static void TestQuestionViewController() {
		
	FieloELR__Question__c question = [SELECT Id FROM FieloELR__Question__c LIMIT 1];	


	ApexPages.StandardController stController = new ApexPages.StandardController(question);
	QuestionViewController questViewController = new QuestionViewController(stController);
	QuestionViewController.Section section = new QuestionViewController.Section();
	QuestionViewController.FormField formfield = new QuestionViewController.FormField();
	
	questViewController.buttonString = 'none';
	questViewController.toolsString = 'none';
	QuestionViewController.secondaryParameters = 'none';


	section.Name =  'none';
	section.CssClass = 'none';

	System.assertEquals('none', section.Name);
	System.assertEquals('none', section.CssClass);


	formfield.Type = 'none';
	formfield.MetaField = 'none';
	formfield.onchange = 'none';
	formfield.Label = 'none';
	formfield.Value = 'none';
  	formfield.Name = 'none';
    formfield.WhereCondition = 'none';
    
    List<QuestionViewController.FormField> innerList = new List<QuestionViewController.FormField>{formfield};
   section.Rows = new List<List<QuestionViewController.FormField>>{innerList};


    //System.assertEquals('none', formfield.Type);
    System.assertEquals('none', formfield.MetaField);
    System.assertEquals('none', formfield.onchange);
    System.assertEquals('none', formfield.Value);
    System.assertEquals(null, formfield.Required);
    System.assertEquals('', formfield.getRequiredValue());
    
	}
}