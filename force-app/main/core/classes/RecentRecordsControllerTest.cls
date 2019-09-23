@isTest
private class RecentRecordsControllerTest {

    @isTest(seeAllData=false) public static void unitTest(){
        RecentRecordsController controller = new RecentRecordsController();
        System.assertNotEquals(null, controller);
        //controller.objectName = 'Promotion__c';
        //controller.getRecentRecords();
    }
}