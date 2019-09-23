public with sharing class JoinCourseController {

    @auraEnabled
    public static String memberJoinCourse(Id memberId, Id courseId){
        try{
            SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{FieloELR__CourseStatus__c.SObjectType});
            
            FieloELR__CourseStatus__c courseStatus = new FieloELR__CourseStatus__c();
            if( Schema.SObjectType.CourseStatus__c.fields.Member__c.isAccessible() ){
                courseStatus.FieloELR__Member__c = memberId;
            }
            if( Schema.SObjectType.CourseStatus__c.fields.Course__c.isAccessible() ){
                courseStatus.FieloELR__Course__c = courseId;
            }
            uow.registerNew(new FieloELR__CourseStatus__c(FieloELR__Member__c = memberId, FieloELR__Course__c = courseId));
           
            if( Schema.sObjectType.FieloELR__CourseStatus__c.isCreateable() && Schema.sObjectType.CourseStatus__c.isUpdateable()){
                uow.commitWork();
            }else{
                throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
            }
            
        } catch (DMLException e) {
            throw new AuraHandledException(e.getDMLMessage(0));
        }
        return 'Success';       
    }   
}