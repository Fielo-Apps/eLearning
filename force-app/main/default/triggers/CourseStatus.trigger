trigger CourseStatus on CourseStatus__c (before insert, after insert, before update, before delete, after update) {
  if( SObjectDomain.isHandlerActive(FieloPLT__Triggers__c.CourseStatus__c)){
    SObjectDomain.triggerHandler(CourseStatus.class);
  }
}