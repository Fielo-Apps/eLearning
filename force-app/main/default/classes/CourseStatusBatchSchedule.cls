public with sharing class CourseStatusBatchSchedule implements Database.Batchable<sobject>, Schedulable {

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new CourseStatusBatchSchedule());
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Date today = date.today();
        Date yesterday = date.today().addDays(-1);

        Database.QueryLocator queryLocator;

        if (Schema.sObjectType.Course__c.isAccessible()) {
            if ( Schema.sObjectType.Course__c.fields.Status__c.isAccessible() && Schema.sObjectType.Course__c.fields.StartDatetime__c.isAccessible() && Schema.sObjectType.Course__c.fields.EndDatetime__c.isAccessible() ) {
                queryLocator = Database.getQueryLocator('SELECT Id, FieloELR__Status__c FROM FieloELR__Course__c WHERE (FieloELR__Status__c = \'Scheduled\' AND FieloELR__StartDatetime__c <=: today) OR (FieloELR__Status__c = \'Active\' AND FieloELR__EndDatetime__c <=: yesterday)');
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c', 'Status__c, StartDatetime__c, EndDatetime__c'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c'}));
        }
        return queryLocator;
    }

    public void execute(Database.BatchableContext BC, List<sobject> scope) {
        SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{Course__c.SObjectType});

        for(Sobject course : scope){
            Course__c c = (Course__c)course;
            if( c.Status__c == 'Scheduled'){
                c.Status__c = 'Active';
            }else{
                c.Status__c = 'Completed';
            }
            uow.registerDirty(c);
        }
        SavePoint sp = Database.setSavePoint();

        try{
            Courses.validateAdminFields = false;

            if(Schema.sObjectType.Course__c.isUpdateable() && Schema.sObjectType.Course__c.isCreateable()){
                if (Schema.sObjectType.Course__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Course__c.fields.Status__c.isCreateable()) {
                    uow.commitWork();
                } else {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c', 'Status__c'}));
                }
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c'}));
            }
        } catch ( Exception e ) {
            Database.rollback(sp);
            system.debug(e.getMessage());
        }
    }

    public void finish(Database.BatchableContext BC) {
    }
}