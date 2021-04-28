@isTest
public with sharing class TestFormController {
	@testSetup static void setup(){
        MockUpFactory.InsertTestData();
    }


    @isTest
    static void test(){
    	FormController controller = new FormController();
    	FormController.FormField formfield = new FormController.FormField();
    	FormController.Section section = new FormController.Section();

		section.Name =  'none';
		section.CssClass = 'none';

    	formfield.Type = 'multiselect';
    	formfield.Name = 'FieloELR__Segment__c';

    	controller.csObjectName = 'Course__c';
    	controller.cFormId = '';
    	//adicionar o objeto
    	controller.cFieldset = '{"Name":"Information","Rows":[[{"Name":"Name","Type":"input"}],[{"Name":"FieloELR__Program__c","Type":"lookup"}],[{"Name":"FieloELR__Segment__c","Type":"multiselect"}],[{"Name":"FieloELR__SubscriptionMode__c","Type":"radio"}],[{"Name":"FieloELR__Description__c","Type":"input"}],[{"Name":"FieloELR__StartDatetime__c","Type":"input"},{"Name":"FieloELR__EndDatetime__c","Type":"input"}], [{"Name":"FieloELR__Status__c","Type":"picklist"}], [{"Name":"FieloELR__EraseLater__c","Type":"picklist"}]]}';

    	List<FormController.FormField> innerList = new List<FormController.FormField>{formfield};
   		section.Rows = new List<List<FormController.FormField>>{innerList};

    	controller.fields = null;
    	String result =  controller.fields;

    	List<FormController.Section> sections = new List<FormController.Section>{section};

    	sObject recordCrs = [SELECT Id FROM FieloELR__Course__c LIMIT 1];

    	RemoteActionResult resultSave1 = FormController.save(
    		recordCrs,
    		new List<String>{
    			'FieloELR__StartDatetime__c',
				'FieloELR__EndDatetime__c'});

   		RemoteActionResult resultSave2 = FormController.save(
    		recordCrs,
    		new List<String>{
    			'FieloELR__StartDatetime__c',
				'FieloELR__EndDatetime__c'});

   		sObject resultRetrieve = FormController.retrieve(
   			'FieloELR__Course__c'
   			,recordCrs.Id
   			,'Name');


   		Map<String, String> resultMapOpt = new Map<String, String>();
   		resultMapOpt = controller.mapOptionsString;

		Map<String, String> resultMapPickLst = new Map<String, String>();

   		controller.mapPicklistController = null;
   		resultMapPickLst = controller.mapPicklistController;

		Map<String, String> resultMapPickVld = new Map<String, String>();
   		resultMapPickVld = controller.mapPicklistValidFor;



   	 	//sObject recordCrs = formController.recordObject;
    }

    @isTest
	static void testSectionFormField() {


	FormController.Section section = new FormController.Section();
	section.Name =  'none';
	section.CssClass = 'none';

	System.assertEquals('none', section.Name);
	System.assertEquals('none', section.CssClass);


	FormController.FormField formfield = new FormController.FormField();
	formfield.Type = 'none';
	formfield.MetaField = 'none';
	formfield.onchange = 'none';
	formfield.Label = 'none';
	formfield.Value = 'none';
  	formfield.Name = 'none';
    formfield.WhereCondition = 'none';

    List<FormController.FormField> innerList = new List<FormController.FormField>{formfield};
   section.Rows = new List<List<FormController.FormField>>{innerList};


    System.assertEquals('none', formfield.Type);
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