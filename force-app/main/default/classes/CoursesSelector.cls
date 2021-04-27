public with sharing class CoursesSelector extends SObjectSelector{
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
                Course__c.Id,
                Course__c.Name,
                Course__c.Description__c,
                Course__c.EndDatetime__c,
                Course__c.Program__c,
                Course__c.Segment__c,
                Course__c.StartDatetime__c,
                Course__c.Status__c,
                Course__c.SubscriptionMode__c
            };
    }

    public CoursesSelector(Set<String> fields){
        super(fields);
    }

    public CoursesSelector(){
        super();
    }

    public Schema.SObjectType getSObjectType(){
        return Course__c.sObjectType;
    }

    public List<Course__c> selectById(Set<Id> courseIds){
        return (List<Course__c>) selectSObjectsById(courseIds);
    }

    public List<Course__c> selectByIdCustom(Set<Id> courseIds) {
        List<Course__c> records;
        // SR: CRUD Check
        if (Schema.sObjectType.Course__c.isAccessible()) {
            String query = String.format(
                    'SELECT {0} ' +
                    'FROM {1} ' +
                    'WHERE Id IN :courseIds ' +
                    'ORDER BY {2}',
                    new List<String> {
                        getFieldListString(),
                        getSObjectName(),
                        getOrderBy() } );
            records = (List<Course__c>) Database.query(query);
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c'}));
        }
        return records;
    }

    public List<Course__c> selectByIdHavingCourseStatus(Set<Id> courseIds) {
        List<Course__c> records;
        // SR: CRUD Check
        if( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.CourseStatus__c.isAccessible() ) {
            records = (List<Course__c>) Database.query(String.format(
                    'SELECT {0} ' +
                    ', (SELECT Id ' +
                    '   FROM CoursesStatus__r LIMIT 1) ' +
                    'FROM {1} ' +
                    'WHERE Id IN :courseIds ' +
                    'ORDER BY {2}',
                    new List<String> {
                        getFieldListString(),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        }else{
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,CourseStatus__c'}));
        }
      return records;
    }

    public List<Course__c> selectAllByIdHavingCourseStatus(Set<Id> courseIds) {
        List<Course__c> records;
        // SR: CRUD Check
        if ( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.CourseStatus__c.isAccessible() ) {
            records = (List<Course__c>) Database.query(String.format(
                'SELECT {0} ' +
                    ', (SELECT Id ' +
                    '   FROM CoursesStatus__r) ' +
                    'FROM {1} ' +
                    'WHERE Id IN :courseIds',
                new List<String> {
                    getFieldListString(),
                    getSObjectName() } ));

        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,CourseStatus__c'}));
        }
        return records;
    }

    public List<Course__c> selectByIdHavingDependentCourses(Set<Id> courseIds) {
        List<Course__c> records;
        // SR: CRUD Check
        if ( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.CourseDependency__c.isAccessible() ) {
            records =  (List<Course__c>) Database.query(String.format(
                    'SELECT {0} ' +
                    ', (SELECT Id ' +
                    '   FROM DependentCourses__r LIMIT 1) ' +
                    'FROM {1} ' +
                    'WHERE Id IN :courseIds ' +
                    'ORDER BY {2}',
                    new List<String> {
                        getFieldListString(),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        }else{
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,CourseDependency__c'}));
        }
        return records;
    }

    public List<Course__c> selectByIdHavingPredecessorCourses(Set<Id> courseIds) {
        List<Course__c> records;
        // SR: CRUD Check
        if ( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.CourseDependency__c.isAccessible() ) {
            records = (List<Course__c>) Database.query(String.format(
                    'SELECT {0} ' +
                    ', (SELECT Id ' +
                    '   FROM PredecessorCourses__r LIMIT 1) ' +
                    'FROM {1} ' +
                    'WHERE Id IN :courseIds ' +
                    'ORDER BY {2}',
                    new List<String> {
                        getFieldListString(),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,CourseDependency__c'}));
        }
        return records;
    }

    public List<Course__c> selectByIdHavingPredecessor(Set<Id> courseIds, Set<String> courseDependencyFields) {
        List<Course__c> records;
        // SR: CRUD Check
        if ( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.CourseDependency__c.isAccessible() ) {
            records = (List<Course__c>) Database.query(String.format('SELECT {0} ' +
                    ', (SELECT {1} FROM PredecessorCourses__r) ' +
                    'FROM {2} ' +
                    'WHERE Id IN :courseIds ' +
                    'ORDER BY {3}',
                    new List<String> {
                        getFieldListString(),
                        String.join(new List<String>(courseDependencyFields),','),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,CourseDependency__c'}));
        }
        return records;
    }

    public List<Course__c> selectByProgramHavingPredecessor(Id programId, Set<String> courseDependencyFields) {
        List<Course__c> records;
        // SR: CRUD Check
        if ( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.CourseDependency__c.isAccessible() ) {
            records = (List<Course__c>) Database.query(String.format('SELECT {0} ' +
                    ', (SELECT {1} FROM PredecessorCourses__r) ' +
                    'FROM {2} ' +
                    'WHERE Program__c =: programId ' +
                    'ORDER BY {3}',
                    new List<String> {
                        getFieldListString(),
                        String.join(new List<String>(courseDependencyFields),','),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,CourseDependency__c'}));
        }
        return records;
    }

    public List<Course__c> selectByIdHavingPredecessor(Set<Id> courseIds) {
        List<Course__c> records;
        // SR: CRUD Check
        if ( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.CourseDependency__c.isAccessible() ) {
            records =  (List<Course__c>) Database.query(String.format(
                'SELECT {0} ' +
                    ', (SELECT Course__c, Predecessor__c ' +
                    '   FROM PredecessorCourses__r) ' +
                    'FROM {1} ' +
                    'WHERE Id IN :courseIds ' +
                    'ORDER BY {2}',
                    new List<String> {
                        getFieldListString(),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,CourseDependency__c'}));
        }
        return records;
    }

    public List<Course__c> selectByIdBeingAutomatic(Set<Id> courseIds) {
        String automatic = 'Automatic';
        List<Course__c> listCourse;

        // SR: CRUD Check
        if( Schema.sObjectType.Course__c.isAccessible() ) {
            listCourse = (List<Course__c>) Database.query(String.format(
               'SELECT {0} ' +
                  'FROM {1} ' +
                  'WHERE Id IN : courseIds and SubscriptionMode__c = :automatic ' +
                  'ORDER BY {2}',
                new List<String> {
                    getFieldListString(),
                    getSObjectName(),
                    getOrderBy() } ));

        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c'}));
        }
        return listCourse;
    }

    public List<Course__c> selectByIdAndStatus(Set<Id> courseIds, Set<String> status) {
        List<Course__c> listCourse;

        // SR: CRUD Check
        if(Schema.sObjectType.Course__c.isAccessible()){
            listCourse = (List<Course__c>) Database.query(String.format(
                'SELECT {0} ' +
                    'FROM {1} ' +
                    'WHERE Id IN : courseIds AND Status__c in : status ' +
                    'ORDER BY {2}',
                    new List<String> {
                        getFieldListString(),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c'}));
        }
        return listCourse;
    }

    public List<Course__c> selectByPredecessor(Set<Id> recordIds) {
        List<Course__c> listCourse;

        // SR: CRUD Check
        if( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.CourseDependency__c.isAccessible() ) {
            listCourse = (List<Course__c>) Database.query(String.format(
                    'SELECT {0} ' +
                    'FROM {1} ' +
                    'WHERE Id IN (SELECT Course__c FROM CourseDependency__c WHERE Predecessor__c IN :recordIds)' +
                    'ORDER BY {2}',
                    new List<String> {
                        getFieldListString(),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,CourseDependency__c'}));
        }
        return listCourse;
    }
}