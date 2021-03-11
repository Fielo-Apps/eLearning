@isTest
public with sharing class TestJoinCourseController {

	@isTest
	static void TestJoinCourseController() {
		MockUpFactory.InsertTestData();
        MockUpFactory.activateCourse();
		FieloPLT__Member__c member = [SELECT Id FROM FieloPLT__Member__c LIMIT 1];
		FieloELR__Course__c course = [SELECT Id FROM FieloELR__Course__c LIMIT 1];

		String memberJnCourseRtrn = JoinCourseController.memberJoinCourse(
			member.Id
			,course.Id
		);
	}
}