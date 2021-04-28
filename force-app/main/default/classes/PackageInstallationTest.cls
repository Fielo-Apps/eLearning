@isTest
public  class PackageInstallationTest {

    @isTest
    static void testSpring21Install() {
        PackageInstallation postinstall = new PackageInstallation();

        System.Test.startTest();
            List<FieloELR__Course__c> courses = new List<FieloELR__Course__c>();
            List<FieloPLT__Program__c> programs;
            List<FieloPLT__Segment__c> segments;

            programs = MockUpFactory.createPrograms('Default', 1);
            insert programs;

            courses = MockUpFactory.createCourses(programs.get(0).id, null, 1);
            courses.get(0).ActiveModules__c = 0;
            courses.get(0).Status__c = 'Draft';
            courses.get(0).KeyDependencies__c = '';
            courses.get(0).SubscriptionMode__c = 'Manual';
            courses.get(0).StartDateTime__c = null;
            courses.get(0).EndDateTime__c = null;
            courses.get(0).StartDate__c = System.today();
            courses.get(0).EndDate__c = System.today();
            insert courses;

            courses = [SELECT Id, StartDate__c, StartDatetime__c, EndDate__c, EndDatetime__c FROM Course__c];

            System.assert(courses.get(0).StartDatetime__c == null, 'Start datetime should be null');

            Test.testInstall(postinstall, new Version(1,75,1));
        System.Test.stopTest();

        courses = [SELECT Id, StartDate__c, StartDatetime__c, EndDate__c, EndDatetime__c FROM Course__c];

        System.assertEquals((Datetime) courses.get(0).StartDate__c, courses.get(0).StartDatetime__c, 'Wrong start datetime' );
        System.assertEquals((Datetime) courses.get(0).EndDate__c, courses.get(0).EndDatetime__c, 'Wrong start datetime' );
    }
}
