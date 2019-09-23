@isTest
public with sharing class TestModuleResponseViewController {
	@testSetup static void setup(){
        MockUpFactory.InsertTestData();
		
    }

	@isTest
	static void TestResponseView(){

		List<FieloELR__Module__c> modules = [SELECT Id FROM FieloELR__Module__c];
		FieloELR__Module__c module; 
		if(!modules.isEmpty()){
			module = modules.get(0);
		//System.assert(!module.isEmpty());

		FieloPLT__Member__c member = [SELECT Id FROM FieloPLT__Member__c LIMIT 1];
	    //System.assert(!member.isEmpty());

	    FieloELR__ModuleResponse__c moduleRes = new FieloELR__ModuleResponse__c(
	    	Module__c = module.Id
	    	,Member__c = member.Id);

		//FieloELR__ModuleResponse__c moduleRes = [SELECT Id FROM FieloELR__ModuleResponse__c LIMIT 1];
		//System.assertNotEquals(moduleRes.isEmpty());
			
		ApexPages.StandardController stdController = new ApexPages.StandardController(moduleRes);
		ModuleResponseViewController viewController = new ModuleResponseViewController(stdController);
		ModuleResponseViewController.Section section = new ModuleResponseViewController.Section();
		ModuleResponseViewController.FormField formfield = new ModuleResponseViewController.FormField();

		SObject retrieveRes = ModuleResponseViewController.retrieve(
			'Module__c'
			, module.Id
			,'FieloELR__Course__c');

		RemoteActionResult savRes = ModuleResponseViewController.save(
			moduleRes
			,new List<String>{
				'none'
				});

		RemoteActionResult savResQuest = ModuleResponseViewController.saveQuestionResponse(
			moduleRes
			,new List<String>{
				'none'
				});				


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
	    
	    List<ModuleResponseViewController.FormField> innerList = new List<ModuleResponseViewController.FormField>{formfield};
	    section.Rows = new List<List<ModuleResponseViewController.FormField>>{innerList};


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
}
