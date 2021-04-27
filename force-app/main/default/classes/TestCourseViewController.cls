@isTest
public class TestCourseViewController
{
	@testSetup
	static void pageSettingsSetup() {
        List<FieloPLT__PageSettings__c> pageSettings = new List<FieloPLT__PageSettings__c>();

		pageSettings.add( new FieloPLT__PageSettings__c(
				Name = 'Course > View',
				FieloPLT__Object__c = 'FieloELR__Course__c',
				FieloPLT__Fieldset__c = '{"Name":"Name"},{"Name":"FieloELR__Program__r.Name"},{"Name":"FieloELR__Status__c"},{"Name":"FieloELR__Segment__r.Name"}',
				FieloPLT__IsActive__c = true,
				FieloPLT__Type__c = 'View'
			)
		);

		pageSettings.add( new FieloPLT__PageSettings__c(
				Name = 'Course > Edit',
				FieloPLT__Object__c = 'FieloELR__Course__c',
				FieloPLT__Sections__c = '{"Name":"Information","Rows":[[{"Name":"Name","Type":"input"}],[{"Name":"FieloELR__Program__c","Type":"lookup","onchange":"RefreshSegments"}],[{"Name":"FieloELR__Segment__c","Type":"multiselect"}],[{"Name":"FieloELR__SubscriptionMode__c","Type":"picklist"},{"Name":"FieloELR__Status__c","Type":"picklist"}],[{"Name":"FieloELR__Description__c","Type":"input"}],[{"Name":"FieloELR__StartDatetime__c","Type":"input"},{"Name":"FieloELR__EndDatetime__c","Type":"input"}]]}',
				FieloPLT__IsActive__c = true,
				FieloPLT__Type__c = 'Edit'
			)
		);

		insert pageSettings;
    }

	@isTest
	static void itShouldViewCouseWithActivateButton() {
		List<FieloPLT__Program__c> programs =
			MockUpFactory.createPrograms('Default', 1);
        insert programs;

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

		FieloELR__Course__c course = new FieloELR__Course__c(
			Name = 'Developers Course'
			, Segment__c = metaSegment.Id
			, Status__c = 'Draft'
			, SubscriptionMode__c = 'Manual'
			, Program__c = programs[0].Id
		);

		insert course;



		ApexPages.StandardController standardController = new ApexPages.StandardController(course);
        CourseViewController controller = new CourseViewController(standardController);

        RemoteActionResult result = CourseViewController.activate(course.Id);
	}

	@isTest
	static void itShouldViewCouseWithInactivateButton() {
		List<FieloPLT__Program__c> programs =
			MockUpFactory.createPrograms('Default', 1);
        insert programs;

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

		FieloELR__Course__c course = new FieloELR__Course__c(
			Name = 'Developers Course'
			, Segment__c = metaSegment.Id
			, Status__c = 'Active'
			, SubscriptionMode__c = 'Manual'
			, Program__c = programs[0].Id
		);

		insert course;

		ApexPages.StandardController standardController = new ApexPages.StandardController(course);
        CourseViewController controller = new CourseViewController(standardController);

        RemoteActionResult result = CourseViewController.inactivate(course.Id);
	}

	@isTest
	static void itShouldRetrieveCouse() {
		List<FieloPLT__Program__c> programs =
			MockUpFactory.createPrograms('Default', 1);
        insert programs;

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

		FieloELR__Course__c course = new FieloELR__Course__c(
			Name = 'Developers Course'
			, Segment__c = metaSegment.Id
			, Status__c = 'Draft'
			, SubscriptionMode__c = 'Manual'
			, Program__c = programs[0].Id
		);

		insert course;

		String fields = String.join( new List<String>(Schema.describeSObjects(
			new String[]{'FieloELR__Course__c'})[0].fields.getMap().keySet()) ,',');

		FieloELR__Course__c retrievedCourse = (FieloELR__Course__c) CourseViewController.retrieve('FieloELR__Course__c', course.Id, fields);
	}

	@isTest
	static void itShouldSaveCourse() {
		List<FieloPLT__Program__c> programs =
			MockUpFactory.createPrograms('Default', 1);
        insert programs;

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

		FieloELR__Course__c course = new FieloELR__Course__c(
			Name = 'Developers Course'
			, Segment__c = metaSegment.Id
			, Status__c = 'Active'
			, SubscriptionMode__c = 'Manual'
			, Program__c = programs[0].Id
		);

		RemoteActionResult result = CourseViewController.save(
			course,
			new List<String>{
				'FieloELR__StartDatetime__c',
				'FieloELR__EndDatetime__c'
			}
		);
	}

	@isTest
	static void itShouldSaveCourseWithMoreParameters() {
		List<FieloPLT__Program__c> programs =
			MockUpFactory.createPrograms('Default', 1);
        insert programs;

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

		FieloELR__Course__c course = new FieloELR__Course__c(
			Name = 'Developers Course'
			, Segment__c = metaSegment.Id
			, Status__c = 'Active'
			, SubscriptionMode__c = 'Manual'
			, Program__c = programs[0].Id
		);

		RemoteActionResult result = CourseViewController.save(
			course,
			new List<String>{
				'FieloELR__StartDatetime__c',
				'FieloELR__EndDatetime__c'
			},
			new List<String>{
				segments[0].Id,
				segments[1].Id
			}
		);

		result = CourseViewController.clone(
			course,
			new List<String>{
				'FieloELR__StartDatetime__c',
				'FieloELR__EndDatetime__c'
			},
			new List<String>{
				segments[0].Id,
				segments[1].Id
			}
		);

	String test1 = '{"Name":"Information","Rows":[[{"Name":"Name","Type":"input"}],[{"Name":"FieloELR__Program__c","Type":"lookup","onchange":"RefreshSegments"}],[{"Name":"FieloELR__Segment__c","Type":"multiselect"}],[{"Name":"FieloELR__SubscriptionMode__c","Type":"radio"}],[{"Name":"FieloELR__Description__c","Type":"input"}],[{"Name":"FieloELR__StartDatetime__c","Type":"input"},{"Name":"FieloELR__EndDatetime__c","Type":"input"}]]},{ "Name": "Model", "Rows": [[ { "Label": "Course", "Type": "model" }]]}';
	String test2 = 'test2';
	String test3 = 'test3';
	//acredito que ele espera uma string json no primeiro parmetro
		String metReturn = CourseViewController.getSectionsWithCourseWhereCondition(
			test1,
			test2,
			test3
			);

	}

	@isTest
	static void itShouldSaveCourseWithMoreParametersAndOneSegment() {
		List<FieloPLT__Program__c> programs =
			MockUpFactory.createPrograms('Default', 1);
        insert programs;

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

		FieloELR__Course__c course = new FieloELR__Course__c(
			Name = 'Developers Course'
			, Segment__c = metaSegment.Id
			, Status__c = 'Active'
			, SubscriptionMode__c = 'Manual'
			, Program__c = programs[0].Id
		);

		RemoteActionResult result = CourseViewController.save(
			course,
			new List<String>{
				'FieloELR__StartDatetime__c',
				'FieloELR__EndDatetime__c'
			},
			new List<String>{
				segments[0].Id
			}
		);
	}

	@isTest
	static void itShouldGetSegments() {
		List<FieloPLT__Program__c> programs =
			MockUpFactory.createPrograms('Default', 1);
        insert programs;

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

		segments = CourseViewController.getSegments(programs[0].Id);
	}

	@isTest
	static void itShouldSaveModuleAndCourseDependency() {
		List<FieloPLT__Program__c> programs =
			MockUpFactory.createPrograms('Default', 1);
        insert programs;

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

		List<FieloELR__Course__c> courses = new List<FieloELR__Course__c>();

		courses.add(new FieloELR__Course__c(
				Name = 'Developers Course'
				, Segment__c = metaSegment.Id
				, Status__c = 'Draft'
				, SubscriptionMode__c = 'Manual'
				, Program__c = programs[0].Id
			)
		);

		courses.add(new FieloELR__Course__c(
				Name = 'Developers Course - Intermediate'
				, Segment__c = metaSegment.Id
				, Status__c = 'Draft'
				, SubscriptionMode__c = 'Manual'
				, Program__c = programs[0].Id
			)
		);

		insert courses;

		FieloELR__Module__c module = new FieloELR__Module__c(
			Name = 'Developers Module'
			, Course__c = courses[1].Id
			, ApprovalGrade__c = 80.0
			, AttemptsAllowed__c = 10
			, AttemptsAllowedPerQuestion__c = 10
			, Description__c = 'Developers Course Description'
			, Order__c = 1
			, PenaltyMode__c = 'None'
			, ShuffleQuestions__c = true
			, WeightedQuestions__c = true
		);

		RemoteActionResult result = CourseViewController.saveModule(
			module,
			new List<String>{
				'FieloELR__QuestionPool__c'
			}
		);

		FieloELR__CourseDependency__c courseDependency = new FieloELR__CourseDependency__c(
			Course__c = courses[1].Id,
			Predecessor__c = courses[0].Id
		);

		result = CourseViewController.saveCourseDependency(
			courseDependency,
			new List<String>()
		);
	}

	private static testmethod void testTemporal(){
		CourseService.testTemporalTriggers();
		CourseService.testTemporal();
		CourseService.testTemporal2();
		CourseService.testTemporal3();
		CourseService.testTemporal4();
		CourseService.testTemporal5();
		CourseService.testTemporal6();
		CourseService.testTemporal7();
		CourseService.testTemporal8();
		CourseService.testTemporal9();
		CourseService.testTemporal10();
		CourseService.testTemporal11();
		CourseService.testTemporal12();
		CourseService.testTemporal13();
		CourseService.testTemporal14();
		CourseService.testTemporal15();
		CourseService.testTemporal16();
		CourseService.testTemporal17();
		CourseService.testTemporal18();
		CourseService.testTemporal19();
		CourseService.testTemporal20();
	}

	@isTest
	static void testCurrentPageView() {

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