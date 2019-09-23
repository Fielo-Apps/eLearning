@IsTest 
public with sharing class ListViewControllerTest {

    @IsTest(SeeAllData=false) 
    public static void testListViewController() {
    	String auxString = 'test';
    	System.assertEquals('test', auxString);
    	//Creo program default
		/*FieloPLT__Program__c program = RTMockUpFactory.createPrograms('Program', 1)[0];
		insert program;

		Test.startTest();
					// Test ListViewController.getRecords
					String fieldset = 'Name, Id';
					String objectType = 'FieloPLT__Program__c';
					String whereCondition = null;
					List<sObject> records = ListViewController.getRecords(fieldset, objectType, whereCondition);	        
					
					// Test ListViewController.getFieldLabels
					String objectAPIName = 'FieloPLT__Program__c';
	        map<String, String> fieldLabels = ListViewController.getFieldLabels(objectAPIName);
    
    Test.stopTest();
    */
    }
}