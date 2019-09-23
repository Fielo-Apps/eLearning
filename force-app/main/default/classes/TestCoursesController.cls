@isTest
public with sharing class TestCoursesController {
	@testSetup static void setup(){
        MockUpFactory.InsertTestData();
        MockUpFactory.activateCourse();
		
    }

	@isTest
	static void TestCoursesController() {
	FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c LIMIT 1];
	List<String> csFieldset = new List<String>{'FieloELR__Status__c'};
	List<String> mdFieldset = new List<String>{'FieloELR__IsActive__c'};

	/*String gCoursesReturn = CoursesController.getCourses(
		member
		,csFieldset
		,mdFieldset
		,2
		,2);
	*/
	}
}