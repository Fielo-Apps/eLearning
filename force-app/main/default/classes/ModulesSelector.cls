public with sharing class ModulesSelector extends SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
                Module__c.Id,
                Module__c.Name,
                Module__c.ApprovalGrade__c,
                Module__c.AttemptsAllowed__c,
                Module__c.AttemptsAllowedPerQuestion__c,
                Module__c.Description__c,
                Module__c.IsActive__c,
                Module__c.QuestionPool__c,
                Module__c.Order__c,
                Module__c.PenaltyMode__c,
                Module__c.ShuffleQuestions__c,
                Module__c.TotalValue__c,
                Module__c.WeightedQuestions__c
            };
    }

    public ModulesSelector(Set<String> fields){
        super(fields);
    }

    public ModulesSelector(){
        super();
    }

    public Schema.SObjectType getSObjectType(){
        return Module__c.sObjectType;
    }

    public List<Module__c> selectById(Set<Id> moduleIds){
        return (List<Module__c>) selectSObjectsById(moduleIds);
    }

    public List<Module__c> selectByIdActive(Set<Id> moduleIds) {
        List<Module__c> listModule;
        if(Schema.sObjectType.Module__c.isAccessible()){
            listModule = (List<Module__c>) Database.query(String.format(
                'SELECT {0} ' +
                  'FROM {1} ' +
                  'WHERE Id IN :moduleIds ' +
                  '  AND IsActive__c = true ' +
                  'ORDER BY {2}',
                new List<String> {
                    getFieldListString(),
                    getSObjectName(),
                    getOrderBy() } ));
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c'}));
        }
        return listModule;
    }

    public List<Module__c> selectByIdWithQuestions(Set<Id> moduleIds) {
        List<Module__c> listModule;
        if(Schema.sObjectType.Module__c.isAccessible() && Schema.sObjectType.Question__c.isAccessible()){
            listModule = (List<Module__c>) Database.query(String.format(
                'SELECT {0} ' +
                  ', (SELECT Id, ' +
                    'IncorrectWeight__c, ' +
                    'Module__c, ' +
                    'Order__c, ' +
                    'PenaltyPerAttempt__c, ' +
                    'Type__c, ' +
                    'CorrectWeight__c, ' +
                    'Name FROM Questions__r) ' +
                  'FROM {1} ' +
                  'WHERE Id IN :moduleIds ' +
                  'ORDER BY {2}',
                new List<String> {
                    getFieldListString(),
                    getSObjectName(),
                    getOrderBy() } ));
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c, Question__c'}));
        }
        return listModule;
    }

    public List<Module__c> selectByIdHavingModuleResponses(Set<Id> moduleIds) {
        List<Module__c> listModule;
        if(Schema.sObjectType.Module__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.isAccessible()){
            listModule = (List<Module__c>) Database.query(String.format(
                'SELECT {0} ' +
                  ', (SELECT Id ' +
                  '   FROM ModuleResponses__r LIMIT 1) ' +
                  'FROM {1} ' +
                  'WHERE Id IN :moduleIds ' +
                  'ORDER BY {2}',
                new List<String> {
                    getFieldListString(),
                    getSObjectName(),
                    getOrderBy() } ));

        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c, ModuleResponse__c'}));
        }
        return listModule;
    }

    public List<Module__c> selectByIdActiveHavingModuleResponses(Set<Id> moduleIds) {
        List<Module__c> listModule;
        if(Schema.sObjectType.Module__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.isAccessible()){
            listModule =  (List<Module__c>) Database.query(String.format(
                    'SELECT {0} ' +
                    ', (SELECT Id ' +
                    '   FROM ModuleResponses__r LIMIT 1) ' +
                    'FROM {1} ' +
                    'WHERE Id IN :moduleIds ' +
                    'AND IsActive__c = true ' +
                    'ORDER BY {2}',
                    new List<String> {
                        getFieldListString(),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c, ModuleResponse__c'}));
        }
        return listModule;
    }

    public List<Module__c> selectByIdHavingQuestions(Set<Id> moduleIds) {
        List<Module__c> listModule;
        if(Schema.sObjectType.Module__c.isAccessible() && Schema.sObjectType.Question__c.isAccessible()){
            listModule =  (List<Module__c>) Database.query(String.format(
                    'SELECT {0} ' +
                        ', (SELECT Id ' +
                        '   FROM Questions__r) ' +
                        'FROM {1} ' +
                        'WHERE Id IN :moduleIds ' +
                        'ORDER BY {2}',
                    new List<String> {
                        getFieldListString(),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c, Question__c'}));
        }
        return listModule;
    }

    public List<Module__c> selectByIdHavingDependencies(Set<Id> moduleIds) {
        List<Module__c> listModule;
        if(Schema.sObjectType.Module__c.isAccessible() && Schema.sObjectType.ModuleDependency__c.isAccessible()) {
            listModule = (List<Module__c>) Database.query(String.format(
                    'SELECT {0} ' +
                    ', (SELECT Module__c, Predecessor__c ' +
                    '   FROM PredecessorModules__r) ' +
                    'FROM {1} ' +
                    'WHERE Id IN :moduleIds ' +
                    'ORDER BY {2}',
                    new List<String> {
                        getFieldListString(),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c, ModuleDependency__c'}));
        }
        return listModule;
    }

    public List<Module__c> selectByCoursesHavingPredecessor(Set<Id> courseIds, Set<String> moduleDependencyFields) {
        List<Module__c> listModule;
        if(Schema.sObjectType.Module__c.isAccessible() && Schema.sObjectType.ModuleDependency__c.isAccessible()){
            listModule = (List<Module__c>) Database.query(String.format('SELECT {0} ' +
                    ', (SELECT {1} FROM PredecessorModules__r) ' +
                    'FROM {2} ' +
                    'WHERE Course__c IN :courseIds ' +
                    'ORDER BY {3}',
                    new List<String> {
                        getFieldListString(),
                        String.join(new List<String>(moduleDependencyFields),','),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c, ModuleDependency__c'}));
        }
        return listModule;
    }

    public List<Module__c> selectByIdHavingCourses(Set<Id> recordIds) {
        List<Module__c> listModule;
        if(Schema.sObjectType.Module__c.isAccessible()){
            listModule = (List<Module__c>) Database.query(String.format(
                    'SELECT {0} ' +
                    'FROM {1} ' +
                    ( recordIds?.isEmpty() == false ? 'WHERE Course__c IN :courseIds ' : '' ) ,
                    new List<String> {
                        getFieldListString(),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );

        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c'}));
        }
        return listModule;
    }

    public List<AggregateResult> selectByCourseGroupByCourse(Set<Id> courseIds) {
        List<AggregateResult> listModule;

        if(Schema.sObjectType.Module__c.isAccessible()){
            listModule = [SELECT MAX(Order__c) orderNumber, Course__c FROM Module__c WHERE Course__c in : courseIds GROUP BY Course__c];
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c'}));
        }
        return listModule;
    }

    public List<Module__c> selectByPredecessor(Set<Id> recordIds) {
        List<Module__c> listModule;
        if(Schema.sObjectType.Module__c.isAccessible() && Schema.sObjectType.ModuleDependency__c.isAccessible()){
            listModule = (List<Module__c>) Database.query(String.format(
                    'SELECT {0} ' +
                    'FROM {1} ' +
                    'WHERE Id IN (SELECT Module__c FROM ModuleDependency__c WHERE Predecessor__c IN :recordIds)' +
                    'ORDER BY {2}',
                    new List<String> {
                        getFieldListString(),
                        getSObjectName(),
                        getOrderBy()
                    }
                )
            );
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c, ModuleDependency__c'}));
        }
        return listModule;
    }
}