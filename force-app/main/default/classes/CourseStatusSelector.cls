public class CourseStatusSelector extends SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
                CourseStatus__c.Id
            };
    }

    public CourseStatusSelector(Set<String> fields){
        super(fields);
    }

    public CourseStatusSelector(){
        super();
    }

    public Schema.SObjectType getSObjectType(){
        return CourseStatus__c.sObjectType;
    }

    public List<CourseStatus__c> selectById(Set<Id> moduleIds){
        return (List<CourseStatus__c>) selectSObjectsById(moduleIds);
    }

    public List<CourseStatus__c> selectByKey(Set<String> keys) {
        List<CourseStatus__c> listCourse;
        if ( Schema.sObjectType.CourseStatus__c.isAccessible() ) {
            listCourse = (List<CourseStatus__c>) Database.query(String.format(
                'SELECT {0} ' +
                  'FROM {1} ' +
                  'WHERE ExternalKey__c IN : keys ' +
                  'ORDER BY {2}',
                new List<String> {
                    getFieldListString(),
                    getSObjectName(),
                    getOrderBy() } ));

        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c'}));
        }
        return listCourse;
    }

    public List<CourseStatus__c> selectByKeyCompleted(Set<String> keys) {
        List<CourseStatus__c> listCourse;
        if(Schema.sObjectType.CourseStatus__c.isAccessible()) {
            listCourse = (List<CourseStatus__c>) Database.query(String.format(
                'SELECT {0} ' +
                  'FROM {1} ' +
                  'WHERE ExternalKey__c IN : keys and Progress__c = 100' +
                  'ORDER BY {2}',
                new List<String> {
                    getFieldListString(),
                    getSObjectName(),
                    getOrderBy() } ));
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c'}));
        }
        return listCourse;
    }

    public List<CourseStatus__c> selectByMemberId(Set<Id> memberIds) {
        List<CourseStatus__c> listCourse;
        if ( Schema.sObjectType.CourseStatus__c.isAccessible() ) {
            listCourse = (List<CourseStatus__c>) Database.query(String.format(
                    'SELECT {0} ' +
                    'FROM {1} ' +
                    'WHERE FieloELR__Member__c IN : memberIds ' +
                    'ORDER BY {2}',
                    new List<String> {
                        getFieldListString(),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseStatus__c'}));
        }
        return listCourse;
    }
}