/**
 * @brief      API para importar y exportar el modelo de datos
 * @details    La API contiene metodos estaticos para exportar e importar Courses
 */
public class ExportService{

    private static List<String> getObjectFields( Map<String, Schema.SObjectField> objectFields){
        List<String> fieldList = new List<String>();
        for(Schema.SObjectField f : objectFields.values() ){
            Schema.DescribeFieldResult field = f.getDescribe();
            if( (field.getName() == 'Name' || field.isCustom()) && !field.isCalculated() && !field.isAutoNumber() && field.getType() != Schema.DisplayType.Reference  ){
                fieldList.add( field.getName() );
            }
        }
        return fieldList;
    }

    public static String exportCourses(List<Id> courseIds) {

        // Carga los mapas de campos y de los recordtypes de los objetos que usa
        //Map<Id,Schema.RecordTypeInfo> segmentRecordTypes;
        Map<String, Schema.SObjectField> courseFields, courseDependencyFields, moduleFields, moduleDependencyFields, questionFields, answerOptionFields;

        Schema.DescribeSObjectResult[] describes = FieloELR.SObjectDescribe.describeSObjects(new String[]{'FieloELR__Course__c','FieloELR__CourseDependency__c', 'FieloELR__Module__c', 'FieloELR__ModuleDependency__c', 'FieloELR__Question__c', 'FieloELR__AnswerOption__c'});
        for ( Schema.DescribeSObjectResult describe :describes ) {
            if(describe.getLocalName() == 'Course__c'){
                courseFields = describe.fields.getMap();
            }else if(describe.getLocalName() == 'CourseDependency__c'){
                courseDependencyFields = describe.fields.getMap();
            }else if(describe.getLocalName() == 'Module__c'){
                moduleFields = describe.fields.getMap();
            }else if(describe.getLocalName() == 'ModuleDependency__c'){
                moduleDependencyFields = describe.fields.getMap();
            }else if(describe.getLocalName() == 'Question__c'){
                questionFields = describe.fields.getMap();
            }else if(describe.getLocalName() == 'AnswerOption__c'){
                answerOptionFields = describe.fields.getMap();
            }
        }

        List<String> courseFieldsList = getObjectFields(courseFields);
        List<String> courseDependencyFieldsList = getObjectFields(courseDependencyFields);
        List<String> moduleFieldsList = getObjectFields(moduleFields);
        List<String> moduleDependencyFieldsList = getObjectFields(moduleDependencyFields);
        List<String> questionFieldsList = getObjectFields(questionFields);
        List<String> answerOptionFieldsList = getObjectFields(answerOptionFields);

        FieloPLT__Program__c program = ProgramService.getActiveProgram();

        List<Course__c> courses = new List<Course__c>();
        Map<Id,Course__c> coursesMap = new Map<Id,Course__c>();
        Set<String> coursefieldsSet = new Set<String>(courseFieldsList);
        coursefieldsSet.remove('FieloELR__StartDatetime__c');
        coursefieldsSet.remove('FieloELR__EndDatetime__c');
        coursefieldsSet.remove('FieloELR__Status__c');
        coursefieldsSet.remove('FieloELR__ActiveModules__c');
        coursefieldsSet.remove('FieloELR__HasDependencies__c');
        courseFieldsList = new List<String>(coursefieldsSet);
        coursefieldsSet.addAll(new Set<String>{'Segment__c','Segment__r.Name','Segment__r.RecordType.DeveloperName','Segment__r.FieloPLT__RelatedSegments__c'});

        Set<String> courseDependencyFieldsSet = new Set<String>(courseDependencyFieldsList);
        courseDependencyFieldsSet.remove('FieloELR__ExternalKey__c');
        courseDependencyFieldsList = new List<String>(courseDependencyFieldsSet);
        courseDependencyFieldsSet.addAll(new Set<String>{'Predecessor__c','Predecessor__r.Name'});

        // SR: FLS Check for Course
        for( String fieldName: coursefieldsSet ) {
            if ( courseFields.containsKey(fieldName) && !courseFields.get(fieldName).getDescribe().isAccessible() ) {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c', fieldName}));
            }
        }

        // SR: FLS Check for CourseDependency
        for( String fieldName: courseDependencyFieldsSet ) {
            if ( courseDependencyFields.containsKey(fieldName) && !courseDependencyFields.get(fieldName).getDescribe().isAccessible() ) {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'CourseDependency__c', fieldName}));
            }
        }

        // SR: CRUD Check
        if ( Schema.sObjectType.Course__c.isAccessible() ) {
            if(courseIds == null){
                courses = new CoursesSelector(coursefieldsSet).selectByProgramHavingPredecessor(program.Id, courseDependencyFieldsSet);
                coursesMap = new Map<Id,Course__c>(courses);
            }else if(!courseIds.isEmpty()){
                courses = new CoursesSelector(coursefieldsSet).selectByIdHavingPredecessor(new Set<Id>(courseIds), courseDependencyFieldsSet);
                coursesMap = new Map<Id,Course__c>(courses);
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c'}));
        }

        Map<Id,List<Module__c>> modulesMap = new Map<Id,List<Module__c>>();
        List<Module__c> modules;
        if(courses != null){
            Set<String> modulefieldsSet = new Set<String>(moduleFieldsList);
            modulefieldsSet.remove('FieloELR__HasDependencies__c');
            modulefieldsSet.remove('FieloELR__IsActive__c');
            modulefieldsList = new List<String>(modulefieldsSet);
            modulefieldsSet.addAll(new Set<String>{'FieloELR__Course__c','FieloELR__Course__r.Name'});

            Set<String> moduleDependencyFieldsSet = new Set<String>(moduleDependencyFieldsList);
            moduleDependencyFieldsSet.remove('FieloELR__ExternalKey__c');
            moduleDependencyFieldsList = new List<String>(moduleDependencyFieldsSet);
            moduleDependencyFieldsSet.addAll(new Set<String>{'Predecessor__c'});

            // SR: FLS Check for Module
            for( String fieldName: modulefieldsSet ) {
                if ( moduleFields.containsKey(fieldName) && !moduleFields.get(fieldName).getDescribe().isAccessible() ) {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', fieldName}));
                }
            }

            // SR: FLS Check for ModuleDependency
            for( String fieldName: moduleDependencyFieldsSet ) {
                if ( moduleDependencyFields.containsKey(fieldName) && !moduleDependencyFields.get(fieldName).getDescribe().isAccessible() ) {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'ModuleDependency__c', fieldName}));
                }
            }

            // SR: CRUD Check
            if ( Schema.sObjectType.Module__c.isAccessible() ) {
                modules = new ModulesSelector(modulefieldsSet).selectByCoursesHavingPredecessor(coursesMap.keySet(), moduleDependencyFieldsSet);
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c'}));
            }
            for(Module__c module : modules){
                if (!modulesMap.containsKey(module.Course__c)) {
                    modulesMap.put(module.Course__c, new List<Module__c>{module} );
                }else{
                    modulesMap.get(module.Course__c).add(module);
                }
            }
        }

        Map<Id,List<Question__c>> questionsMap = new Map<Id,List<Question__c>>();
        if(modules != null){
        	Set<Id> moduleIds = new Map<Id,Module__c>(modules).keySet();
            Set<String> questionfieldsSet = new Set<String>(questionFieldsList);
            questionfieldsSet.addAll(new Set<String>{'Module__c'});
            // SR: CRUD Check
            if ( Schema.sObjectType.Question__c.isAccessible() && Schema.sObjectType.AnswerOption__c.isAccessible() ) {
                // SR: FLS Check for Question
                for( String fieldName: questionfieldsSet ) {
                    if ( questionFields.containsKey(fieldName) && !questionFields.get(fieldName).getDescribe().isAccessible() ) {
                        throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Question__c', fieldName}));
                    }
                }
                // SR: FLS Check for AnswerOption
                for( String fieldName: answerOptionFieldsList ) {
                    if ( answerOptionFields.containsKey(fieldName) && !answerOptionFields.get(fieldName).getDescribe().isAccessible() ) {
                        throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'AnswerOption__c', fieldName}));
                    }
                }
                for(Question__c question : new QuestionsSelector(questionfieldsSet).selectByModuleHavingAnswerOptions(moduleIds, new Set<String>(answerOptionFieldsList))){
                    if (!questionsMap.containsKey(question.Module__c) ) {
                        questionsMap.put(question.Module__c, new List<Question__c>{question} );
                    }else{
                        questionsMap.get(question.Module__c).add(question);
                    }
                }
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Question__c,AnswerOption__c'}));
            }
        }

        //mapa armado para obtener nombre de segmentos no queriados que se usan en metasegments
        Set<String> segmentMultiUsedIds = new Set<String>();
        for(Course__c c : courses){
            if(String.isNotEmpty(c.Segment__r.FieloPLT__RelatedSegments__c)){
                segmentMultiUsedIds.addAll(new Set<String>(c.Segment__r.FieloPLT__RelatedSegments__c.split(';')));
            }
        }

        Map<Id,FieloPLT__Segment__c> segmentsMultiUsedMap;
        // SR: CRUD Check
        if ( Schema.sObjectType.FieloPLT__Segment__c.isAccessible() ) {
            segmentsMultiUsedMap = new Map<Id,FieloPLT__Segment__c>([SELECT Id, Name FROM FieloPLT__Segment__c WHERE Id in : segmentMultiUsedIds]);
        }

        JSONGenerator genJson = JSON.createGenerator(true);
        genJson.writeStartObject();

        if(!courses.isEmpty()){
            exportCourses(genJson, courses, coursesMap, modulesMap, questionsMap, courseFieldsList, courseDependencyFieldsList, moduleFieldsList, moduleDependencyFieldsList, questionFieldsList, answerOptionFieldsList, segmentsMultiUsedMap);
        }
        genJson.writeEndObject();

        return genJson.getAsString();
    }

    private static void exportCourses(JSONGenerator genJson, List<Course__c> courses, Map<Id,Course__c> coursesMap, Map<Id,List<Module__c>> modulesMap, Map<Id,List<Question__c>> questionsMap, List<String> courseFieldsList, List<String> courseDependencyFieldsList, List<String> moduleFieldsList, List<String> moduleDependencyFieldsList, List<String> questionFieldsList, List<String> answerOptionFieldsList, Map<Id,FieloPLT__Segment__c> segmentsMultiUsedMap){
        //courses
        genJson.writeFieldName('courses');
        genJson.writeStartArray();
        for(Course__c course : courses){
            genJson.writeStartObject();
            // manda los campos que estan fuera del fieldset
            // manda los campos del fieldset
            genJson.writeObjectField( 'reference', course.Id );
            if(course.Segment__c != null){
                if(course.Segment__r.RecordType.DeveloperName != 'MetaSegment'){
                    genJson.writeObjectField( 'segmentName',  course.Segment__r.Name);
                }else{
                    exportRelatedSegments(genJson, course.Segment__r.FieloPLT__RelatedSegments__c.split(';'), segmentsMultiUsedMap);
                }
            }

            for( String f : courseFieldsList ){
                if ( course.get(f) != null ) {
                    genJson.writeObjectField( f, course.get(f) );
                }
            }

            if(!course.PredecessorCourses__r.isEmpty()){
            	exportCourseDependencies(genJson, course.PredecessorCourses__r, courseDependencyFieldsList, coursesMap);
            }

            if(modulesMap.containsKey(course.Id)){
                exportModules(genJson, modulesMap.get(course.Id), questionsMap, moduleFieldsList, moduleDependencyFieldsList, questionFieldsList, answerOptionFieldsList);
            }
            genJson.writeEndObject();
        }
        genJson.writeEndArray();
    }

    private static void exportRelatedSegments(JSONGenerator genJson, List<Id> segmentIds, Map<Id,FieloPLT__Segment__c> segmentsMultiUsedMap){
        genJson.writeFieldName('segments');
        genJson.writeStartArray();
        for(Id segmentId : segmentIds){
            genJson.writeStartObject();
            genJson.writeObjectField( 'segmentName', segmentsMultiUsedMap.get(segmentId).Name);
            genJson.writeEndObject();
        }
        genJson.writeEndArray();
    }

    private static void exportCourseDependencies(JSONGenerator genJson, List<CourseDependency__c> courseDependencies, List<String> courseDependencyFieldsList, Map<Id,Course__c> coursesMap){
        genJson.writeFieldName('predecessors');
        genJson.writeStartArray();
        for(CourseDependency__c courseDependency : courseDependencies){
            genJson.writeStartObject();

            if(coursesMap.containsKey(courseDependency.Predecessor__c)){
                genJson.writeObjectField( 'courseReference', courseDependency.Predecessor__c);
            }else{
                genJson.writeObjectField( 'courseName', courseDependency.Predecessor__r.Name);
            }

            for(String f : courseDependencyFieldsList ){
                if ( courseDependency.get(f) != null ) {
                    genJson.writeObjectField( f, courseDependency.get(f) );
                }
            }
            genJson.writeEndObject();
        }
        genJson.writeEndArray();
    }

    private static void exportModules(JSONGenerator genJson, List<Module__c> modules, Map<Id,List<Question__c>> questionsMap, List<String> moduleFieldsList, List<String> moduleDependencyFieldsList, List<String> questionFieldsList, List<String> answerOptionFieldsList){
        // Loop por cada Rule
        genJson.writeFieldName('modules');
        genJson.writeStartArray();
        for(Module__c module : modules){
            // manda los campos del fieldset
            genJson.writeStartObject();
            genJson.writeObjectField( 'reference', module.Id );
            for( String f : moduleFieldsList ){
                if ( module.get(f) != null ) {
                    genJson.writeObjectField( f, module.get(f) );
                }
            }

            if(!module.PredecessorModules__r.isEmpty()){
            	exportModuleDependencies(genJson, module.PredecessorModules__r, moduleDependencyFieldsList);
            }

            if(questionsMap.containsKey(module.Id)){
                exportQuestions(genJson, questionsMap.get(module.Id), questionFieldsList, answerOptionFieldsList);
            }
            genJson.writeEndObject();
        }
        genJson.writeEndArray();
    }

    private static void exportModuleDependencies(JSONGenerator genJson, List<ModuleDependency__c> moduleDependencies, List<String> moduleDependencyFieldsList){
        genJson.writeFieldName('predecessors');
        genJson.writeStartArray();
        for(ModuleDependency__c moduleDependency : moduleDependencies){
            genJson.writeStartObject();
            genJson.writeObjectField( 'moduleReference', moduleDependency.Predecessor__c);
            for(String f : moduleDependencyFieldsList ){
                if ( moduleDependency.get(f) != null ) {
                    genJson.writeObjectField( f, moduleDependency.get(f) );
                }
            }
            genJson.writeEndObject();
        }
        genJson.writeEndArray();
    }

    private static void exportQuestions(JSONGenerator genJson, List<Question__c> questions, List<String> questionFieldsList, List<String> answerOptionFieldsList){
        genJson.writeFieldName('questions');
        genJson.writeStartArray();
        for(Question__c question : questions){
            genJson.writeStartObject();
            for(String f : questionFieldsList ){
                if ( question.get(f) != null ) {
                    genJson.writeObjectField( f, question.get(f) );
                }
            }

            if(!question.AnswerOptions__r.isEmpty()){
                exportAnswerOptions(genJson, question.AnswerOptions__r, answerOptionFieldsList);
            }
            genJson.writeEndObject();
        }
        genJson.writeEndArray();
    }

    private static void exportAnswerOptions(JSONGenerator genJson, List<AnswerOption__c> answerOptions, List<String> answerOptionFieldsList){
        genJson.writeFieldName('answerOptions');
        genJson.writeStartArray();
        for(AnswerOption__c ao : answerOptions){
            genJson.writeStartObject();
            for(String f : answerOptionFieldsList ){
                if ( ao.get(f) != null ) {
                    genJson.writeObjectField( f, ao.get(f) );
                }
            }
            genJson.writeEndObject();
        }
        genJson.writeEndArray();
    }

    private class Relation{
        public SObject record;
        public Schema.SObjectField relationField;

        public Relation(SObject record, Schema.SObjectField relationField){
            this.record = record;
            this.relationField = relationField;
        }
    }

    public static void saveData(SObjectUnitOfWork uow){
        saveData(uow, null);
    }

    public static void saveData(SObjectUnitOfWork uow, List<MultiSegmentRelation> multiSegmentRelations){
        Set<String> objectNames = new Set<String>();
        if ( uow.m_newListByType != null && !uow.m_newListByType.isEmpty() ) {
            objectNames.addAll( uow.m_newListByType.keySet() );
        }
        if ( uow.m_dirtyMapByType != null && !uow.m_dirtyMapByType.isEmpty() ) {
            objectNames.addAll( uow.m_dirtyMapByType.keySet() );
        }
        List<Schema.DescribeSObjectResult> describeList = Schema.describeSObjects(new List<String>( objectNames ));

        // SR: Dynamic CRUD Check
        for( Schema.DescribeSObjectResult objDescribe : describeList ) {
            if ( !objDescribe.isUpdateable() ) {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{objDescribe.getName()}));
            }
            if ( !objDescribe.isCreateable() ) {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_insertable, new List<String>{objDescribe.getName()}));
            }
        }

        uow.commitWork();

        if(multiSegmentRelations != null){
            Set<String> segmentCombinations = new Set<String>();
            for(MultiSegmentRelation msr : multiSegmentRelations){
                List<String> segmentIds = new List<String>();
                for(FieloPLT__Segment__c segment : msr.relatedSegments){
                    segmentIds.add(String.valueOf(segment.Id).subString(0,15));
                }
                segmentIds.sort();
                msr.segmentsCombination = String.join(segmentIds,';');
                segmentCombinations.add(msr.segmentsCombination);
            }

            Map<String,FieloPLT__Segment__c> metaSegmentsByComb = new Map<String,FieloPLT__Segment__c>();

            // SR: CRUD Check
            if ( Schema.sObjectType.FieloPLT__Segment__c.isAccessible() ) {
                // SR: FLS Check
                if ( Schema.sObjectType.FieloPLT__Segment__c.fields.FieloPLT__RelatedSegments__c.isAccessible() ) {
                    for(FieloPLT__Segment__c metaSegment : [SELECT Id, FieloPLT__RelatedSegments__c FROM FieloPLT__Segment__c WHERE FieloPLT__RelatedSegments__c in : segmentCombinations]){
                        metaSegmentsByComb.put(metaSegment.FieloPLT__RelatedSegments__c, metaSegment);
                    }
                } else {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__Segment__c', 'FieloPLT__RelatedSegments__c'}));
                }
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__Segment__c'}));
            }

            FieloPLT__Program__c program = ProgramService.getActiveProgram();

            Id metasegmentRTId;
            // SR: CRUD Check
            if ( Schema.sObjectType.RecordType.isAccessible() ) {
                // SR: FLS Check
                if ( Schema.sObjectType.RecordType.fields.Name.isAccessible() && Schema.sObjectType.RecordType.fields.DeveloperName.isAccessible() && Schema.sObjectType.RecordType.fields.SObjectType.isAccessible() ) {
                    metasegmentRTId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'FieloPLT__Segment__c' AND DeveloperName =: 'Metasegment'].Id;
                } else {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'RecordType', 'Name, DeveloperName, SObjectType'}));
                }
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'RecordType'}));
            }

            SObjectUnitOfWork uowMetaSegments = new SObjectUnitOfWork(new List<Schema.SObjectType>{FieloPLT__Segment__c.SObjectType, Course__c.SObjectType});
            for(MultiSegmentRelation msr : multiSegmentRelations){
                if(metaSegmentsByComb.containsKey(msr.segmentsCombination)){
                    uowMetaSegments.registerDirty(msr.record, msr.relationField, metaSegmentsByComb.get(msr.segmentsCombination));
                }else{
                    FieloPLT__Segment__c newMetaSegment = new FieloPLT__Segment__c(Name = 'Multiple', FieloPLT__Program__c = program.Id, FieloPLT__RelatedSegments__c = msr.segmentsCombination, RecordtypeId = metasegmentRTId);
                    uowMetaSegments.registerNew(newMetaSegment);
                    uowMetaSegments.registerDirty(msr.record, msr.relationField, newMetaSegment);
                    metaSegmentsByComb.put(msr.segmentsCombination, newMetaSegment);
                }
            }

            if(Schema.sObjectType.FieloPLT__Segment__c.isCreateable() && Schema.sObjectType.FieloPLT__Segment__c.isUpdateable()){
                uowMetaSegments.commitWork();
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'Segment__c'}));
            }
        }
    }

    public static SObjectUnitOfWork importData(String jsonImport){
        return importData(jsonImport, null);
    }

    public static SObjectUnitOfWork importData(String jsonImport, List<MultiSegmentRelation> multiSegmentRelations){
        // Carga los mapas de campos y de los recordtypes de los objetos que usa
        Map<String, Schema.RecordTypeInfo> segmentRecordTypes;
        Map<String, Schema.DescribeFieldResult> courseFieldsMap, courseDependencyFieldsMap, moduleFieldsMap, moduleDependencyFieldsMap, questionFieldsMap, answerOptionFieldsMap;

        Schema.DescribeSObjectResult[] describes = FieloELR.SObjectDescribe.describeSObjects(new String[]{'FieloELR__Course__c','FieloELR__CourseDependency__c', 'FieloELR__Module__c', 'FieloELR__ModuleDependency__c', 'FieloELR__Question__c', 'FieloELR__AnswerOption__c'});
        for ( Schema.DescribeSObjectResult describe :describes ) {
            if(describe.getLocalName() == 'Course__c'){
                courseFieldsMap = getObjectFieldsDescribe(describe.fields.getMap());
            }else if(describe.getLocalName() == 'CourseDependency__c'){
                courseDependencyFieldsMap = getObjectFieldsDescribe(describe.fields.getMap());
            }else if(describe.getLocalName() == 'Module__c'){
                moduleFieldsMap = getObjectFieldsDescribe(describe.fields.getMap());
            }else if(describe.getLocalName() == 'ModuleDependency__c'){
                moduleDependencyFieldsMap = getObjectFieldsDescribe(describe.fields.getMap());
            }else if(describe.getLocalName() == 'Question__c'){
                questionFieldsMap = getObjectFieldsDescribe(describe.fields.getMap());
            }else if(describe.getLocalName() == 'AnswerOption__c'){
                answerOptionFieldsMap = getObjectFieldsDescribe(describe.fields.getMap());
            }
        }

        SObjectUnitOfWork uow;

        // SR: CRUD Check, in this class, only Update / Insert may happen.
        if ( Schema.sObjectType.Course__c.isUpdateable() && Schema.sObjectType.Course__c.isCreateable() && Schema.sObjectType.CourseDependency__c.isUpdateable() && Schema.sObjectType.CourseDependency__c.isCreateable() && Schema.sObjectType.Module__c.isUpdateable() && Schema.sObjectType.Module__c.isCreateable() && Schema.sObjectType.ModuleDependency__c.isUpdateable() && Schema.sObjectType.ModuleDependency__c.isCreateable() && Schema.sObjectType.Question__c.isUpdateable() && Schema.sObjectType.Question__c.isCreateable() && Schema.sObjectType.AnswerOption__c.isUpdateable() && Schema.sObjectType.AnswerOption__c.isCreateable() ) {
            uow = new SObjectUnitOfWork(new List<Schema.SobjectType>{ Course__c.SObjectType, CourseDependency__c.SObjectType, Module__c.SObjectType, ModuleDependency__c.SObjectType, Question__c.SObjectType, AnswerOption__c.SObjectType});
        }

        Map<Id,SObject> mapReferences = new Map<Id,SObject>();
        Map<Id,List<Relation>> pendingRelations = new Map<Id,List<Relation>>();

        Map<String,FieloPLT__Segment__c> segmentsByName = new Map<String,FieloPLT__Segment__c>();
        Map<String,Course__c> coursesByName = new Map<String,Course__c>();

        Set<Id> originalMultiSegmentIds = new Set<Id>();

        JSONParser parser = JSON.createParser(jsonImport);
        // SR: CRUD Check
        if ( Schema.sObjectType.FieloPLT__Segment__c.isAccessible() && Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.Course__c.isAccessible() ) {
            // SR: FLS Check
            if ( Schema.sObjectType.FieloPLT__Segment__c.fields.Name.isAccessible() && Schema.sObjectType.FieloPLT__Segment__c.fields.FieloPLT__Program__c.isAccessible() && Schema.sObjectType.FieloPLT__Segment__c.fields.RecordTypeId.isAccessible() && Schema.sObjectType.RecordType.fields.DeveloperName.isAccessible() && Schema.sObjectType.Course__c.fields.Name.isAccessible() && Schema.sObjectType.Course__c.fields.Program__c.isAccessible()) {
                while(parser.nextToken() != null){
                    if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                        FieloPLT__Program__c program = ProgramService.getActiveProgram();
                        for(FieloPLT__Segment__c segment : [SELECT Name, Id FROM FieloPLT__Segment__c WHERE FieloPLT__Program__c =: program.Id AND RecordType.DeveloperName != 'Metasegment']){
                            segmentsByName.put(segment.Name, segment);
                        }
                        for(Course__c course : [SELECT Name, Id FROM Course__c WHERE Program__c =: program.Id]){
                            coursesByName.put(course.Name, course);
                        }
                        do {
                            if ( parser.getCurrentToken() == JSONToken.FIELD_NAME )  {
                                String tokenText = parser.getCurrentName();
                                if ( tokenText == 'courses' ) {
                                    parseCourses( parser, uow, program, courseFieldsMap, courseDependencyFieldsMap, moduleFieldsMap, moduleDependencyFieldsMap, questionFieldsMap, answerOptionFieldsMap, mapReferences, pendingRelations, segmentsByName, coursesByName, originalMultiSegmentIds, multiSegmentRelations);
                                }
                            }
                        } while ( parser.nextToken() != null);
                    }
                }
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__Segment__c, RecordType, Course__c', 'FieloPLT__Segment__c.Name, FieloPLT__Segment__c.FieloPLT__Program__c, FieloPLT__Segment__c.RecordTypeId, RecordType.DeveloperName, Course__c.Name, Course__c.Program__c'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__Segment__c, RecordType, Course__c'}));
        }
        return uow;
    }

    private static void parseCourses( JSONParser parser, SObjectUnitOfWork uow, FieloPLT__Program__c program, Map<String, Schema.DescribeFieldResult> courseFieldsMap, Map<String, Schema.DescribeFieldResult> courseDependencyFieldsMap, Map<String, Schema.DescribeFieldResult> moduleFieldsMap, Map<String, Schema.DescribeFieldResult> moduleDependencyFieldsMap, Map<String, Schema.DescribeFieldResult> questionFieldsMap, Map<String, Schema.DescribeFieldResult> answerOptionsFieldsMap, Map<Id,SObject> mapReferences, Map<Id,List<Relation>> pendingRelations, Map<String,FieloPLT__Segment__c> segmentsByName, Map<String,Course__c> coursesByName, Set<Id> originalMultiSegmentIds, List<MultiSegmentRelation> multiSegmentRelations) {
        if ( parser.nextToken() == JSONToken.START_ARRAY) {
            // Loop por cada Course
            while ( parser.nextToken()!== JSONToken.END_ARRAY &&  parser.getCurrentToken() != null ) {
                if ( parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    Course__c currentCourse = new Course__c(Program__c=program.Id);

                    while(parser.nextToken() !== JSONToken.END_OBJECT && parser.getCurrentToken() != null){
                        String tokenText = parser.getCurrentName();
                        if(tokenText == 'reference'){
                            resolveReference(currentCourse, parser, uow, mapReferences, pendingRelations);
                        }else if(tokenText == 'predecessors'){
                            parseCourseDependencies ( parser, uow, currentCourse, courseDependencyFieldsMap, mapReferences, pendingRelations, coursesByName);
                        }else if(tokenText == 'modules'){
                            parseModules ( parser, uow, currentCourse, moduleFieldsMap, moduleDependencyFieldsMap, questionFieldsMap, answerOptionsFieldsMap, mapReferences, pendingRelations);
                        }else if ( tokenText == 'segmentName' ) {
                            if ( parser.nextToken() != null ) {
                                if ( segmentsByName.containsKey( parser.getText() ) ) {
                                    currentCourse.Segment__c = segmentsByName.get( parser.getText() ).Id;
                                }
                            }
                        }else if ( tokenText == 'segments' ) {
                            parseRelatedSegments(parser, currentCourse, segmentsByName, originalMultiSegmentIds, multiSegmentRelations, Course__c.Segment__c);
                        }else if ( courseFieldsMap.keySet().contains( tokenText) ) {
                            setFieldValue( (SObject)currentCourse, parser, tokenText, courseFieldsMap.get( tokenText ).getSoapType() );
                        }
                    }
                    uow.registerNew(currentCourse);
                }
            }
            // FIN Loop por cada Page
        } else { throw new FieloPLT.FieloException (String.format(Label.FieloPLT.JSONArrayRequired, new String[]{'promotions'})); }
    }

    private static void parseRelatedSegments(JSONParser parser, Course__c currentCourse, Map<String,FieloPLT__Segment__c> segmentsByName, Set<Id> originalMultiSegmentIds, List<MultiSegmentRelation> multiSegmentRelations, Schema.SobjectField segmentRelation){
        if ( parser.nextToken() == JSONToken.START_ARRAY) {
            List<FieloPLT__Segment__c> relatedSegments = new List<FieloPLT__Segment__c>();
            Set<Id> originalSegmentIdsPerRecord = new Set<Id>();
            Boolean segmentsFound = true;
            while ( parser.nextToken()!== JSONToken.END_ARRAY &&  parser.getCurrentToken() != null ) {
                if ( parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    while(parser.nextToken() !== JSONToken.END_OBJECT && parser.getCurrentToken() != null){
                        String tokenText = parser.getCurrentName();
                        if ( tokenText == 'segmentName' ) {
                            if ( parser.nextToken() != null ) {
                                if(segmentsByName.containsKey(parser.getText())){
                                    relatedSegments.add(segmentsByName.get(parser.getText()));
                                }else{
                                    segmentsFound = false;
                                }
                            }
                        }
                    }
                }
            }
            if(segmentsFound){
                multiSegmentRelations.add(new MultiSegmentRelation(currentCourse, relatedSegments, originalSegmentIdsPerRecord, segmentRelation));
                originalMultiSegmentIds.addAll(originalSegmentIdsPerRecord);
            }
        }
    }

    public class MultiSegmentRelation{
        public SObject record;
        public List<FieloPLT__Segment__c> relatedSegments;
        public Set<Id> originalSegmentIds;
        public String segmentsCombination;
        public Schema.SObjectField relationField;

        public MultiSegmentRelation(SObject record, List<FieloPLT__Segment__c> relatedSegments, Set<Id> originalSegmentIds, Schema.SObjectField relationField){
            this.record = record;
            this.relatedSegments = relatedSegments;
            this.originalSegmentIds = originalSegmentIds;
            this.relationField = relationField;
        }
    }

	private static void parseCourseDependencies( JSONParser parser, SObjectUnitOfWork uow, Course__c currentCourse, Map<String, Schema.DescribeFieldResult> courseDependencyFieldsMap, Map<Id,SObject> mapReferences, Map<Id,List<Relation>> pendingRelations, Map<String,Course__c> coursesByName) {
        if ( parser.nextToken() == JSONToken.START_ARRAY) {
            // Loop por cada Page
            while ( parser.nextToken()!== JSONToken.END_ARRAY &&  parser.getCurrentToken() != null ) {
                if ( parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    CourseDependency__c currentCourseDependency = new CourseDependency__c();

                    Boolean predecessorFound = false;
                    while(parser.nextToken() !== JSONToken.END_OBJECT && parser.getCurrentToken() != null){
                        String tokenText = parser.getCurrentName();
                        if(tokenText == 'courseReference'){
                        	setFieldReference( currentCourseDependency, parser, uow, CourseDependency__c.Predecessor__c, mapReferences, pendingRelations);
                            predecessorFound = true;
                        }else if(tokenText == 'courseName'){
                        	//setReferenceName( currentCourseDependency, parser, CourseDependency__c.Predecessor__c, coursesByNameRelations);
                            if ( parser.nextToken() != null ) {
                                if ( coursesByName.containsKey( parser.getText() ) ) {
                                    currentCourseDependency.Predecessor__c = coursesByName.get( parser.getText() ).Id;
                                    predecessorFound = true;
                                }
                            }
                        }else if(courseDependencyFieldsMap.containsKey( tokenText)){
                            setFieldValue( (SObject)currentCourseDependency, parser, tokenText, courseDependencyFieldsMap.get( tokenText ).getSoapType() );
                        }
                    }
                    if(predecessorFound){
                        uow.registerNew(currentCourseDependency, CourseDependency__c.Course__c, currentCourse);
                    }
                }
            }
            // FIN Loop por cada Page
        } else { throw new FieloPLT.FieloException (String.format(Label.FieloPLT.JSONArrayRequired, new String[]{'rules'})); }
    }

    private static void parseModules( JSONParser parser, SObjectUnitOfWork uow, Course__c currentCourse, Map<String, Schema.DescribeFieldResult> moduleFieldsMap, Map<String, Schema.DescribeFieldResult> moduleDependencyFieldsMap, Map<String, Schema.DescribeFieldResult> questionFieldsMap, Map<String, Schema.DescribeFieldResult> answerOptionsFieldsMap, Map<Id,SObject> mapReferences, Map<Id,List<Relation>> pendingRelations) {
        if ( parser.nextToken() == JSONToken.START_ARRAY) {
            // Loop por cada Page
            while ( parser.nextToken()!== JSONToken.END_ARRAY &&  parser.getCurrentToken() != null ) {
                if ( parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    Module__c currentModule = new Module__c();

                    while(parser.nextToken() !== JSONToken.END_OBJECT && parser.getCurrentToken() != null){
                        String tokenText = parser.getCurrentName();
                        if(tokenText == 'reference'){
                            resolveReference(currentModule, parser, uow, mapReferences, pendingRelations);
                        }else if(tokenText == 'predecessors'){
                        	parseModuleDependencies ( parser, uow, currentModule, moduleDependencyFieldsMap, mapReferences, pendingRelations);
                        }else if(tokenText == 'questions'){
                            parseQuestions ( parser, uow, currentModule, questionFieldsMap, answerOptionsFieldsMap);
                        }else if(moduleFieldsMap.containsKey( tokenText)){
                            setFieldValue( (SObject)currentModule, parser, tokenText, moduleFieldsMap.get( tokenText ).getSoapType() );
                        }
                    }
                    if(currentCourse != null){
                        uow.registerNew(currentModule, Module__c.Course__c, currentCourse);
                    }
                }
            }
            // FIN Loop por cada Page
        } else { throw new FieloPLT.FieloException (String.format(Label.FieloPLT.JSONArrayRequired, new String[]{'rules'})); }
    }

    private static void parseModuleDependencies( JSONParser parser, SObjectUnitOfWork uow, Module__c currentModule, Map<String, Schema.DescribeFieldResult> moduleDependencyFieldsMap, Map<Id,SObject> mapReferences, Map<Id,List<Relation>> pendingRelations) {
        if ( parser.nextToken() == JSONToken.START_ARRAY) {
            // Loop por cada Page
            while ( parser.nextToken()!== JSONToken.END_ARRAY &&  parser.getCurrentToken() != null ) {
                if ( parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    ModuleDependency__c currentModuleDependency = new ModuleDependency__c();

                    while(parser.nextToken() !== JSONToken.END_OBJECT && parser.getCurrentToken() != null){
                        String tokenText = parser.getCurrentName();
                        if(tokenText == 'moduleReference'){
                        	setFieldReference( currentModuleDependency, parser, uow, ModuleDependency__c.Predecessor__c, mapReferences, pendingRelations);
                        }else if(moduleDependencyFieldsMap.containsKey( tokenText)){
                            setFieldValue( (SObject)currentModuleDependency, parser, tokenText, moduleDependencyFieldsMap.get( tokenText ).getSoapType() );
                        }
                    }
                    uow.registerNew(currentModuleDependency, ModuleDependency__c.Module__c, currentModule);
                }
            }
            // FIN Loop por cada Page
        } else { throw new FieloPLT.FieloException (String.format(Label.JSONArrayRequired, new String[]{'rules'})); }
    }

    private static void parseQuestions( JSONParser parser, SObjectUnitOfWork uow, Module__c currentModule, Map<String, Schema.DescribeFieldResult> questionFieldsMap, Map<String, Schema.DescribeFieldResult> answerOptionsFieldsMap) {
        if ( parser.nextToken() == JSONToken.START_ARRAY) {
            // Loop por cada Page
            while ( parser.nextToken()!== JSONToken.END_ARRAY &&  parser.getCurrentToken() != null ) {
                if ( parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    Question__c currentQuestion = new Question__c();

                    while(parser.nextToken() !== JSONToken.END_OBJECT && parser.getCurrentToken() != null){
                        String tokenText = parser.getCurrentName();
                        if ( tokenText == 'answerOptions' ) {
                            parseAnswerOptions ( parser, uow, currentQuestion, answerOptionsFieldsMap);
                        }else if ( questionFieldsMap.containsKey( tokenText) ) {
                            setFieldValue( (SObject)currentQuestion, parser, tokenText, questionFieldsMap.get( tokenText ).getSoapType() );
                        }
                    }
                    uow.registerNew(currentQuestion, Question__c.Module__c, currentModule);
                }
            }
            // FIN Loop por cada Page
        } else { throw new FieloPLT.FieloException (String.format(Label.JSONArrayRequired, new String[]{'rulecriteria'})); }
    }

    private static void parseAnswerOptions( JSONParser parser, SObjectUnitOfWork uow, Question__c currentQuestion, Map<String, Schema.DescribeFieldResult> answerOptionsFieldsMap) {
        if ( parser.nextToken() == JSONToken.START_ARRAY) {
            // Loop por cada Page
            while ( parser.nextToken()!== JSONToken.END_ARRAY &&  parser.getCurrentToken() != null ) {
                if ( parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    AnswerOption__c currentAnswerOption = new AnswerOption__c();

                    while(parser.nextToken() !== JSONToken.END_OBJECT && parser.getCurrentToken() != null){
                        String tokenText = parser.getCurrentName();
                        if ( answerOptionsFieldsMap.keySet().contains( tokenText) ) {
                            setFieldValue( (SObject)currentAnswerOption, parser, tokenText, answerOptionsFieldsMap.get( tokenText ).getSoapType() );
                        }
                    }
                    uow.registerNew(currentAnswerOption, AnswerOption__c.Question__c, currentQuestion);
                }
            }
            // FIN Loop por cada Page
        } else { throw new FieloPLT.FieloException (String.format(Label.JSONArrayRequired, new String[]{'rulecriteria'})); }
    }

    public static void saveIncentives(SObjectUnitOfWork uow){
        Set<String> objectNames = new Set<String>();
        if ( uow.m_newListByType != null && !uow.m_newListByType.isEmpty() ) {
            objectNames.addAll( uow.m_newListByType.keySet() );
        }
        if ( uow.m_dirtyMapByType != null && !uow.m_dirtyMapByType.isEmpty() ) {
            objectNames.addAll( uow.m_dirtyMapByType.keySet() );
        }
        List<Schema.DescribeSObjectResult> describeList = Schema.describeSObjects(new List<String>( objectNames ));

        // SR: Dynamic CRUD Check, Only Insert / Update may happen
        for( Schema.DescribeSObjectResult objDescribe : describeList ) {
            if ( !objDescribe.isUpdateable() ) {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{objDescribe.getName()}));
            }
            if ( !objDescribe.isCreateable() ) {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_insertable, new List<String>{objDescribe.getName()}));
            }
        }
        uow.commitWork();
    }

    private static void setFieldReference( SObject currentRecord, JSONParser parser, SObjectUnitOfWork uow, Schema.SObjectField relationField, Map<Id,SObject> mapReferences, Map<Id,List<Relation>> pendingRelations) {
        if ( parser.nextToken() != null ) {
            if(mapReferences.containsKey(parser.getText())){
                uow.registerRelationship(currentRecord, relationField, mapReferences.get(parser.getText()));
            }else{
                if(pendingRelations.containsKey(parser.getText())){
                    pendingRelations.get(parser.getText()).add(new Relation(currentRecord, relationField));
                }else{
                    pendingRelations.put(parser.getText(), new List<Relation>{new Relation(currentRecord, relationField)});
                }
            }
        }
    }

    private static void setReferenceName( SObject currentRecord, JSONParser parser, Schema.SObjectField relationField, Map<String,List<Relation>> relationsByName) {
        if ( parser.nextToken() != null ) {
            if(relationsByName.containsKey(parser.getText())){
                relationsByName.get(parser.getText()).add(new Relation(currentRecord, relationField));
            }else{
                relationsByName.put(parser.getText(), new List<Relation>{new Relation(currentRecord, relationField)});
            }
        }
    }

    private static void resolveReference(SObject currentRecord, JSONParser parser, SObjectUnitOfWork uow, Map<Id,SObject> mapReferences, Map<Id,List<Relation>> pendingRelations){
        if ( parser.nextToken() != null ) {
            mapReferences.put( parser.getText() , currentRecord);
            if(pendingRelations.containsKey(parser.getText())){
                for(Relation r : pendingRelations.get(parser.getText())){
                    uow.registerRelationship(r.record, r.relationField, currentRecord);
                }
            }
        }
    }

    private static void setFieldValue( SObject o, JSONParser parser , String fieldName, Schema.SOAPType soapType ) {
        // avanza al token del valor
        if ( parser.nextToken() != null ) {
            if(soapType == Schema.SOAPType.String || soapType == Schema.SOAPType.anytype || soapType == Schema.SOAPType.ID ) {
                o.put(fieldName, parser.getText() );
            } else if ( soapType == Schema.SOAPType.Integer  )  {
                o.put(fieldName, parser.getLongValue() ); // getIntegerValue()
            } else if ( soapType == Schema.SOAPType.Boolean  )  {
                o.put(fieldName, parser.getBooleanValue() );
            } else if ( soapType == Schema.SOAPType.Date  )  {
                o.put(fieldName, parser.getDateValue() );
            } else if ( soapType == Schema.SOAPType.DateTime  )  {
                o.put(fieldName, parser.getDatetimeValue() );
            } else if ( soapType == Schema.SOAPType.Time  )  {
                o.put(fieldName, parser.getTimeValue() );
            } else if ( soapType == Schema.SOAPType.Double  )  {
                o.put(fieldName, parser.getDoubleValue() );
            } else if ( soapType == Schema.SOAPType.base64binary  )  {
                o.put(fieldName, parser.getBlobValue() );
            }
        } else {
            throw new FieloPLT.FieloException (String.format(label.FieloPLT.ValueMissing, new List<String>{fieldName}));
        }
    }

    private static Map<String, Schema.DescribeFieldResult> getObjectFieldsDescribe ( Map<String, Schema.SObjectField> objectFields){
        Map<String, Schema.DescribeFieldResult> fieldMap = new Map<String, Schema.DescribeFieldResult>();
        for(Schema.SObjectField f : objectFields.values() ){
            Schema.DescribeFieldResult field = f.getDescribe();
            if( (field.getName() == 'Name' || field.isCustom() ) && !field.isCalculated() && !field.isAutoNumber() && field.getType() != Schema.DisplayType.Reference ){
                fieldMap.put(field.getName(), field);
            }
        }
        return fieldMap;
    }

}