@isTest
private class TestCourseLandingController
{
	@testSetup
	static void pageSettingsSetup() {
        List<FieloPLT__PageSettings__c> pageSettings = new List<FieloPLT__PageSettings__c>();

		pageSettings.add( new FieloPLT__PageSettings__c(
				Name = 'Course > Landing',
				FieloPLT__Object__c = 'FieloELR__Course__c',
				FieloPLT__Fieldset__c = '{"Name":"FieloELR__SubscriptionMode__c"},{"Name":"FieloELR__Status__c"},{"Name":"FieloELR__Program__r.Name"}',
				FieloPLT__IsActive__c = true,
				FieloPLT__Type__c = 'Landing'
			)
		);

		pageSettings.add( new FieloPLT__PageSettings__c(
				Name = 'Course > New',
				FieloPLT__Object__c = 'FieloELR__Course__c',
				FieloPLT__Sections__c = '{"Name":"Information","Rows":[[{"Name":"Name","Type":"input"}],[{"Name":"FieloELR__Program__c","Type":"lookup","onchange":"RefreshSegments"}],[{"Name":"FieloELR__Segment__c","Type":"multiselect"}],[{"Name":"FieloELR__SubscriptionMode__c","Type":"picklist"},{"Name":"FieloELR__Status__c","Type":"picklist"}],[{"Name":"FieloELR__Description__c","Type":"input"}],[{"Name":"FieloELR__StartDatetime__c","Type":"input"},{"Name":"FieloELR__EndDatetime__c","Type":"input"}]]}',
				FieloPLT__IsActive__c = true,
				FieloPLT__Type__c = 'New'
			)
		);

		insert pageSettings;
    }

	@isTest
	static void itShouldInitPage() {
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

		ApexPages.Standardsetcontroller standardController = new ApexPages.Standardsetcontroller(
			new List<FieloELR__Course__c>{course}
		);

        CourseLandingController controller = new CourseLandingController();

        List<SelectOption> views = CourseLandingController.getStatusViews();
	}

	@isTest
	static void itShouldGetCourses() {
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

		List<FieloELR__Course__c> courses = CourseLandingController.getCourses(
			'FieloELR__Course__c',
			fields,
			null,
			null,
			'{"FieloELR__Program__c":"'+programs[0].Id+'"}',
			10,
			''
		);
	}

	@isTest
	static void itShouldCreateCourseWithoutSegments() {
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

		/*RemoteActionResult result = CourseLandingController.createCourseWithoutSegments(
			course,
			new List<String>{
				'FieloELR__StartDatetime__c',
				'FieloELR__EndDatetime__c'
			}
		);*/
	}

	@isTest
	static void itShouldCreateCourseWithSegments() {
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

		RemoteActionResult result = CourseLandingController.createCourse(
			course,
			new List<String>{
				'FieloELR__StartDatetime__c',
				'FieloELR__EndDatetime__c'
			},
			null
			,
			new List<String>{
				'test1',
				'test2'
			});

		/*RemoteActionResult result = CourseLandingController.createCourseWithSegments(
			course,
			new List<String>{
				'FieloELR__StartDatetime__c',
				'FieloELR__EndDatetime__c'
			},
			new List<String>{
				segments[0].Id,
				segments[1].Id
			}
		);*/
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

		segments = CourseLandingController.getSegments(programs[0].Id);


	}

	//
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




	//chamar a classe, chamar o metodo deixar modelid e segments null

	}

}