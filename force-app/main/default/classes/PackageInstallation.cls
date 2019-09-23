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
}