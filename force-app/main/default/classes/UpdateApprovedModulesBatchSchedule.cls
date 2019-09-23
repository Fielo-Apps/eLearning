global with sharing class UpdateApprovedModulesBatchSchedule implements Database.Batchable<sObject>, Schedulable  {

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new UpdateApprovedModulesBatchSchedule());
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        Database.QueryLocator queryLocator;

        // SR: CRUD Check
        if ( Schema.sObjectType.CourseStatus__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.isAccessible() && Schema.sObjectType.Module__c.isAccessible() && Schema.sObjectType.Course__c.isAccessible()) {
            // SR: FLS Check
            if ( Schema.sObjectType.CourseStatus__c.fields.ApprovedModules__c.isAccessible() && Schema.sObjectType.CourseStatus__c.fields.Course__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.IsApproved__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.NumberOfApprove__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.Module__c.isAccessible() && Schema.sObjectType.Module__c.fields.IsActive__c.isAccessible() && Schema.sObjectType.Course__c.fields.LastModifiedDate.isAccessible()) {
                queryLocator = Database.getQueryLocator(
                    'SELECT Id, FieloELR__ApprovedModules__c, ' +
                    '(SELECT Id from FieloELR__ModuleResponses__r WHERE FieloELR__IsApproved__c = TRUE ' +
                    'AND FieloELR__NumberOfApprove__c = 1 AND FieloELR__Module__r.FieloELR__IsActive__c = true) ' +
                    'FROM FieloELR__CourseStatus__c ORDER BY FieloELR__Course__r.LastModifiedDate DESC LIMIT 50000000'
                );
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c, ModuleResponse__c, Module__c, Course__c', 'ApprovedModules__c, Course__c, IsApproved__c, NumberOfApprove__c, Module__c, IsActive__c, LastModifiedDate'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c, ModuleResponse__c, Module__c, Course__c'}));
        }
        return queryLocator; 
    }

    global void execute(Database.BatchableContext bc, List<FieloELR__CourseStatus__c> scope) {
        List<FieloELR__CourseStatus__c> csList = new List<FieloELR__CourseStatus__c>();

        // SR: FLS Check
        if ( Schema.sObjectType.CourseStatus__c.fields.ApprovedModules__c.isUpdateable() ) {
            for(FieloELR__CourseStatus__c c: scope) {
                if (c.FieloELR__ModuleResponses__r != null) {
                    if (c.FieloELR__ApprovedModules__c != c.FieloELR__ModuleResponses__r.size()) {
                        c.FieloELR__ApprovedModules__c = c.FieloELR__ModuleResponses__r.size();
                        csList.add(c);
                    }
                }
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'CourseStatus__c', 'ApprovedModules__c'}));
        }
        
        // SR: CRUD Check
        if ( Schema.sObjectType.CourseStatus__c.isUpdateable() ) {
            CourseService.enableAdminPermission(true);
            update csList;
            CourseService.enableAdminPermission(false);
        }
    }

    global void finish(Database.BatchableContext bc){
        // SR: CRUD Check        
        if ( Schema.sObjectType.AsyncApexJob.isAccessible() && Schema.sObjectType.User.isAccessible() ) {
            // SR: FLS Check
            if ( Schema.sObjectType.AsyncApexJob.fields.Status.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.NumberOfErrors.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.JobItemsProcessed.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.TotalJobItems.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.CreatedById.isAccessible() && Schema.sObjectType.User.fields.Email.isAccessible()) {
                AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                                JobItemsProcessed,
                                TotalJobItems, CreatedBy.Email
                                FROM AsyncApexJob
                                WHERE Id = :bc.getJobId()];
                System.debug(job);
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'AsyncApexJob, User', 'AsyncApexJob.Status, AsyncApexJob.NumberOfErrors, AsyncApexJob.JobItemsProcessed, AsyncApexJob.TotalJobItems, AsyncApexJob.CreatedBy, User.Email'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'AsyncApexJob, User'}));
        }
    }
}