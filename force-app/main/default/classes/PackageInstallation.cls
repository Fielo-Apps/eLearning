//NO DOCUMENT
/*
CLASS WITHOUT SHARING RECOMMENDED BY SALESFORCE
Partner Portal Case Number: #08027329
A new comment has been added by Anuj Varshney to your case regarding "Erron on installation script". To reply to this comment, please click the URL below to view the case in the partner portal. This area will be your primary source of feedback regarding all your tickets.
Case URL
https://sites.secure.force.com/partners/PP2PartnerLoginPage?startURL=/apex/ViewCase%3Fcid%3D5003000000O5aUJAAZ
Comment:
I do see a few known issue with R&D related to post install script.
For now I think the you just need to make sure the script is not "with sharing" and not fire code with sharing for the moment.
Could you please try and let me know if that works for you?
*/
global without sharing class PackageInstallation implements InstallHandler {

    global void onInstall(InstallContext context){
        //verify if is first version
        if(context.PreviousVersion() == null){
            install(context.installerId());
        }else{
            System.debug('Check: ' + context.previousVersion().compareTo(new Version(1,76)));
            if(context.previousVersion().compareTo(new Version(1,76)) < 0) {
                updateCourses();
            }
        }
    }

    global void install(Id userId){
        try{
            scheduleBatchs();
        }catch(Exception e){}
    }

    @Future
    public static void scheduleBatchs(){
        Datetime sysTime = System.now();
        sysTime = sysTime.addDays(1);
        //schedule to run every day at 12:00 AM
        String chron_exp = '0 0 0 * * ?';

        if(!Test.isRunningTest()){//this is in order to avoid hitting the system limit of more than 5 scheluded batches
            CourseStatusBatchSchedule courseStatusBatch = new CourseStatusBatchSchedule();
            System.schedule('courseStatusJob' + sysTime.getTime(), chron_exp, courseStatusBatch);
        }
    }

    public static void updateCourses() {
        FieloPLT__Triggers__c triggers = FieloPLT__Triggers__c.getInstance(UserInfo.getUserId());
        triggers.Course__c = false;

        if( SecurityUtils.canUpdate(FieloPLT__Triggers__c.sObjectType, new List<String>{'FieloELR__Course__c'}) ){
            upsert triggers;
        }else{
            throw new FieloException(Label.CannotInsertUpdateRecords);
        }

        List<Course__c> courses = new List<Course__c>();

        for(Course__c c : [SELECT Id, StartDate__c, EndDate__c FROM Course__c]) {
            courses.add(
                new Course__c(
                    Id = c.Id,
                    StartDatetime__c = c.StartDate__c != null ? (datetime) c.StartDate__c : null,
                    EndDatetime__c = c.EndDate__c != null ? (datetime) c.EndDate__c : null
                )
            );
        }

        if (!courses.isEmpty()) {
            update courses;
        }

        //Enable default Fielo triggers again
        SecurityUtils.checkObjectIsDeletable(FieloPLT__Triggers__c.sObjectType);
        delete triggers;
    }
}