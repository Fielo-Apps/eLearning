@isTest
public class TestCourseStatusViewController {
	@testSetup static void setup(){
        MockUpFactory.InsertTestData();
    }	

	@isTest static void getTests(){
 		
 		List<FieloPLT__Program__c> programs = [SELECT Id FROM FieloPLT__Program__c];

 		FieloPLT__Segment__c metaSegment =
			MockUpFactory.createSegments('Segment #', 1, 'MetaSegment')[0];
		List<FieloPLT__Segment__c> segments =
			MockUpFactory.createSegments('Segment #', 2, 'Manual');

		

		for (FieloPLT__Segment__c segment:segments) {
			segment.FieloPLT__Program__c = programs[0].Id;
		}

		insert segments;

		metaSegment.FieloPLT__RelatedSegments__c = segments[0].Id + ';' + segments[1].Id;
		metaSegment.FieloPLT__Program__c = programs[0].Id;

		insert metaSegment;

		//Course
 		FieloELR__Course__c course = new FieloELR__Course__c(
 			Name = 'Dev Course'
 			, SubscriptionMode__c = 'Manual'
 			, Program__c = programs[0].Id);

 		insert course;

 		FieloELR__Module__c module = new FieloELR__Module__c(
			Name = 'Developers Module'
			, Course__c = course.Id
			, ApprovalGrade__c = 80.0
			, AttemptsAllowed__c = 10
			, AttemptsAllowedPerQuestion__c = 10
			, Description__c = 'Developers Course Description'
			, Order__c = 1
			, PenaltyMode__c = 'None'
			, ShuffleQuestions__c = true
			, WeightedQuestions__c = true
		);

		insert module;

		//TODO QUery um program e botar dentro do course
		List<FieloELR__Module__c> modules = [SELECT Id, IsActive__c FROM Module__c];
		modules.get(0).IsActive__c = true;
		upsert modules.get(0);

		System.assertEquals(true, modules.get(0).IsActive__c);

		List<FieloELR__Course__c> courses = new List<FieloELR__Course__c>();
		courses = [SELECT Id, Status__c FROM Course__c WHERE Program__c =: programs.get(0).id];
		courses.get(0).Status__c = 'Active';
		update courses;
		
		System.assertEquals('Active', courses.get(0).Status__c);

 		//Members
 		List<FieloPLT__Member__c> members = new List<FieloPLT__Member__c>();
 		members = [SELECT Id FROM FieloPLT__Member__c WHERE FieloPLT__Program__c =: programs.get(0).id];
        update members;

		FieloPLT.SObjectService.setStaticVariables();
        //CourseStatus
	   	FieloELR__CourseStatus__c record = new FieloELR__CourseStatus__c(
		Member__c = members.get(0).id
		,Course__c = courses.get(0).id);
		insert record;
	
	   	  //ModuleResponse
        FieloELR__ModuleResponse__c moduleRes = new FieloELR__ModuleResponse__c(
        	Member__c = members.get(0).id
        	,Module__c = modules.get(0).id
        	,CourseStatus__c = record.Id);

        upsert moduleRes;

	   	//StandardController
	   	ApexPages.StandardController standardController = new ApexPages.StandardController(record);

    	CourseStatusViewController crsStViewController = new CourseStatusViewController(standardController);

    	RemoteActionResult resultSave = CourseStatusViewController.save(
			record,
			new List<String>{
				'FieloELR__StartDate__c',
				'FieloELR__EndDate__c'
			}
		);

		RemoteActionResult resutSaveModuleRes = CourseStatusViewController.saveModuleResponse(
			moduleRes,
			new List<String>{
				'FieloELR__StartDate__c'}
		);
    	
		String fields = String.join( new List<String>(Schema.describeSObjects(
			new String[]{'FieloELR__Course__c'})[0].fields.getMap().keySet()) ,',');

		FieloELR__Course__c retrievedCourse = (FieloELR__Course__c) CourseStatusViewController.retrieve('FieloELR__Course__c', course.Id, fields);

	}

	
	@isTest
	static void testSectionFormField() {
	
	CourseStatusViewController.Section section = new CourseStatusViewController.Section();
	section.Name =  'none';
	section.CssClass = 'none';

	System.assertEquals('none', section.Name);
	System.assertEquals('none', section.CssClass);


	CourseStatusViewController.FormField formfield = new CourseStatusViewController.FormField();
	formfield.Type = 'none';
	formfield.MetaField = 'none';
	formfield.onchange = 'none';
	formfield.Label = 'none';
	formfield.Value = 'none';
  	formfield.Name = 'none';
    formfield.WhereCondition = 'none';
    
    List<CourseStatusViewController.FormField> innerList = new List<CourseStatusViewController.FormField>{formfield};
   section.Rows = new List<List<CourseStatusViewController.FormField>>{innerList};


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