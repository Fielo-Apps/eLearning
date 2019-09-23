@isTest
public with sharing class TestFormModuleReorderController {
	@testSetup static void setup(){
        MockUpFactory.InsertTestData();
    }	

	@isTest
	static void TestFormModuleReorderController() {
	
	FormModuleReorderController reorderController = new FormModuleReorderController();
	FormModuleReorderController.Section section = new FormModuleReorderController.Section();
	FormModuleReorderController.FormField formfield = new FormModuleReorderController.FormField();
	
	reorderController.cFieldset = '{"Name":"Information","Rows":[[{"Name":"Name","Type":"input"}],[{"Name":"FieloELR__Program__c","Type":"lookup"}],[{"Name":"FieloELR__Segment__c","Type":"multiselect"}],[{"Name":"FieloELR__SubscriptionMode__c","Type":"radio"}],[{"Name":"FieloELR__Description__c","Type":"input"}],[{"Name":"FieloELR__StartDate__c","Type":"input"},{"Name":"FieloELR__EndDate__c","Type":"input"}], [{"Name":"FieloELR__Status__c","Type":"picklist"}]]}';
	reorderController.csObjectName = 'FieloELR__Course__c';
	reorderController.cFilter = '';
	FormModuleReorderController.cRecordRedirect = true;
	
	sObject course;
	List<sObject> courses = [SELECT Id FROM FieloELR__Course__c ];
	if(!courses.isEmpty()){
		 course = courses.get(0);	
	}
	System.assert(course != null);
	
	reorderController.cRecord = course;
	
    System.assert(reorderController.sections!=null);
    reorderController.fields = null;
    System.assert(reorderController.fields != null);

	System.assert(reorderController.recordObject != null);

	System.assert(reorderController.mapOptionsString != null);

	RemoteActionResult resultReorder = FormModuleReorderController.reorder(
		courses);

	section.Name =  'none';
	section.CssClass = 'none';

	System.assertEquals('none', section.Name);
	System.assertEquals('none', section.CssClass);


	//formfield.Type = 'none';
	formfield.MetaField = 'none';
	formfield.onchange = 'none';
	formfield.Label = 'none';
	formfield.Value = 'none';
  	//formfield.Name = 'none';
    formfield.WhereCondition = 'none';
    
    List<FormModuleReorderController.FormField> innerList = new List<FormModuleReorderController.FormField>{formfield};
   section.Rows = new List<List<FormModuleReorderController.FormField>>{innerList};


    //System.assertEquals('none', formfield.Type);
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