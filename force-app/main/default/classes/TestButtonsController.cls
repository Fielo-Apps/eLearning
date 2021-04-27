@isTest
public with sharing class TestButtonsController {

	@isTest
	static void TestButtonsController() {

	ButtonsController btnsController = new ButtonsController();

	btnsController.cParameters = 'none';
	btnsController.cRecordId = 'none';

	System.assert(btnsController.parametersForJSON != null);
	//String paramJSON = btnsController.parametersForJSON;

	String getParams = btnsController.getParametersString();

	ButtonsController.Button btnCls = new ButtonsController.Button();

	btnCls.id = 'none';
	btnCls.Icon = 'none';
	btnCls.Type = 'none';
	btnCls.Label = 'none';
	btnCls.ObjectName = 'none';
	btnCls.Action = 'none';
	btnCls.CssClass = 'none';
	btnCls.Parameters = '{"Name":"Information","Rows":[[{"Name":"Name","Type":"input"}],[{"Name":"FieloELR__Program__c","Type":"lookup"}],[{"Name":"FieloELR__Segment__c","Type":"multiselect"}],[{"Name":"FieloELR__SubscriptionMode__c","Type":"radio"}],[{"Name":"FieloELR__Description__c","Type":"input"}],[{"Name":"FieloELR__StartDatetime__c","Type":"input"},{"Name":"FieloELR__EndDatetime__c","Type":"input"}], [{"Name":"FieloELR__Status__c","Type":"picklist"}], [{"Name":"FieloELR__EraseLater__c","Type":"picklist"}]]}';
	btnCls.Confirm = true;
	btnCls.reflection = true;
	btnCls.cRecordId = 'none';
	btnCls.VisField= 'none';
	btnCls.VisValue = 'none';

	//btnCls.getVisualValueTrim = 'none';

	String getParamsJson = btnCls.getParametersForJSON();

	//String getParamsStr = btnCls.getParametersString();


	btnsController.cButtonsString = 'buttons';
	System.assert(btnsController.cButtons == null);

	btnsController.cToolsString = '{"Name":"Information","Rows":[[{"Name":"Name","Type":"input"}],[{"Name":"FieloELR__Program__c","Type":"lookup"}],[{"Name":"FieloELR__Segment__c","Type":"multiselect"}],[{"Name":"FieloELR__SubscriptionMode__c","Type":"radio"}],[{"Name":"FieloELR__Description__c","Type":"input"}],[{"Name":"FieloELR__StartDatetime__c","Type":"input"},{"Name":"FieloELR__EndDatetime__c","Type":"input"}], [{"Name":"FieloELR__Status__c","Type":"picklist"}], [{"Name":"FieloELR__EraseLater__c","Type":"picklist"}]]}';
	System.assert(btnsController.cTools != null);


	}
}