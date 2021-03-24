Set<String> fieldsCourse = new Set<String>{
    'Name',
    'FieloELR__Status__c',
    'FieloELR__Program__c'
};

Set<String> fieldsCourseDependency = new Set<String>{
    'FieloELR__Course__c',
    'FieloELR__Predecessor__c'
};

Set<String> fieldsModule = new Set<String> {
    'Name'
};

Set<String> fieldsModuleDependency = new Set<String>{
    'FieloELR__Module__c',
    'FieloELR__Predecessor__c'
};

Set<String> statuses = new Set<String>{
    'Active',
    'Scheduled',
    'Completed'
};

Id programId = 'a0l3F000004mLb6QAE';
Id memberId = 'a0Z3F000002QcLRUA0';
String dynamicFilter = '[{"field":"FieloELR__StartDate__c","value":"THIS_YEAR","operator":"equals","andOrOperator":""},{"field":"FieloELR__EndDate__c","value":"THIS_YEAR","operator":"equals","andOrOperator":"or"}]';

List<FieloELR.CourseService.CourseWrapper> courseWrappers =
    FieloELR.CourseService.getCoursesMap(
        fieldsCourse,
        fieldsCourseDependency,
        fieldsModule,
        fieldsModuleDependency,
        null,
        statuses,
        programId,
        memberId,
        false,
        false,
        null,
        0,
        'FieloELR__Order__c',
        dynamicFilter
    );

System.debug(
    'Courses: ' + courseWrappers?.size()
);