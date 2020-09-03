public class Modules extends SObjectDomain {

    public static Boolean validateAdminFields = true;
    public static Boolean isDelete = false;

    public Modules(List<Module__c> records) {
        super(records);
    }

    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<Module__c> sObjectList) {
            //If has Admin Permission allow "validateAdminFields"
            if(FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()) != null && FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()).FieloPLT__To__c >= system.now()){
                validateAdminFields = false;
            }

            return new Modules(sObjectList);
        }
    }

    public override void onApplyDefaults() {
        
        Set<Id> courseIds = new Set<Id>();
        for(Module__c module : (List<Module__c>)records){
            module.IsActive__c = false;
            if(module.Order__c == null) {
                courseIds.add(module.Course__c);
            }
            module.KeyDependencies__c = '';
            module.NumberOfQuestions__c = 0;
        }
        
        List<AggregateResult> aggResult = new ModulesSelector().selectByCourseGroupByCourse(courseIds);
        Map<String, Decimal> maxOrderByCourse = new Map<String, Decimal>();
        for(AggregateResult ar : aggResult){
            maxOrderByCourse.put((String)ar.get('FieloELR__Course__c'), (Decimal)ar.get('orderNumber'));
        }
        
        for(Module__c module : (List<Module__c>)records) {
            if(module.Order__c == null) {
                if(maxOrderByCourse.containsKey(module.Course__c)){
                    Decimal maxOrder = maxOrderByCourse.get(module.Course__c);
                    maxOrder = (maxOrder == null ? 0 : maxOrder);
                    module.Order__c = ++maxOrder;
                    maxOrderByCourse.put(module.Course__c, maxOrder);
                }else{
                    module.Order__c = 1;
                    maxOrderByCourse.put(module.Course__c, 1);
                }
            }
        }
    }    

    public override void onValidate(Map<Id,SObject> existingRecords) {
        if(validateAdminFields){
            if (!isDelete) {
                List<Module__c> activatedModules = new List<Module__c>();
                List<Module__c> updatedModules = new List<Module__c>();
                Module__c oldModule;

                for(Module__c module : (List<Module__c>)records) {

                    oldModule = (Module__c)(existingRecords.get(module.Id));

                    // Select only modules that are being activated
                    if(!(oldModule.IsActive__c) && module.IsActive__c) {
                        activatedModules.add(module);
                    }
                   //get PublicSettings field that check if Edit Courses is authorized
                FieloPLT__PublicSettings__c courseSettings = FieloPLT__PublicSettings__c.getInstance();
                Boolean editCourseSettings = courseSettings.EnableEditingWhileActive__c;
                   //If the field is true, there is no check 
                    if(editCourseSettings ==false ){
                        if(oldModule.IsActive__c && module.IsActive__c) {
                            addError(module, Label.ActiveModuleCannotBeEdited);
                        }
                    }/* 
                        Check if any of these fields were modified:
                        IsActive / Attempts Allowed / Approval Grade / Penalty Mode
                        Question Pool / Attempts Allowed per question / Weighted questions
                    */
                    else if((oldModule.AttemptsAllowed__c != module.AttemptsAllowed__c || 
                        oldModule.ApprovalGrade__c != module.ApprovalGrade__c || 
                        oldModule.PenaltyMode__c != module.PenaltyMode__c || 
                        oldModule.QuestionPool__c != module.QuestionPool__c || 
                        oldModule.AttemptsAllowedPerQuestion__c != module.AttemptsAllowedPerQuestion__c ||
                        oldModule.WeightedQuestions__c != module.WeightedQuestions__c) && editCourseSettings == false) {
                        updatedModules.add(module);
                    }else if((module.FieloELR__HasDependencies__c != oldModule.FieloELR__HasDependencies__c) ||
                    (module.FieloELR__KeyDependencies__c != oldModule.FieloELR__KeyDependencies__c)){
                        addError(module, 'This field can\'t be edited');
                    }
                }

                // When the module is changed to active, must validate that has at least one question.
                checkQuestions(activatedModules);

                // If the Module is active, has at least 1 related Module response, and any of the following fields was modified the Module cannot be edited or deleted 
                checkModule(updatedModules);

                // When the module is activated, should verify, for the question types "statement" and "single choice", that it has a correct answer.
                checkAnswers(activatedModules);
            }
        }
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        Set<Id> moduleIds = new Set<Id>();
        Module__c oldModule;
        for(Module__c module : (List<Module__c>)records) {
            oldModule = (Module__c)(existingRecords.get(module.Id));

            if(!(oldModule.IsActive__c) && module.IsActive__c) {
                moduleIds.add(module.Id);
            }
        }

        if (!moduleIds.isEmpty()) {
            Map<Id, Module__c> moduleMap = new Map<Id, Module__c>(new ModulesSelector(new Set<String>{'Id', '(SELECT Id FROM Questions__r)'}).selectById(moduleIds));
            Map<Id, Module__c> recordsMap = new Map<Id, Module__c>((List<Module__c>)records);
            for(Module__c module : moduleMap.values()) {
                recordsMap.get(module.Id).NumberOfQuestions__c = module.Questions__r.size();
            }
        }
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        List<Module__c> activatedModules = new List<Module__c>();
        List<Module__c> inactivatedModules = new List<Module__c>();
        Set<Module__c> modulesToChangeQuestions = new Set<Module__c>();

        Set<Id> modulesToChangeCorrectWeight = new Set<Id>();
        Set<Id> modulesToChangeIncorrectWeight = new Set<Id>();
        Set<Id> modulesToChangePenaltyPerAttempt = new Set<Id>();

        Module__c oldModule;        

        for(Module__c module : (List<Module__c>)records) {

            oldModule = (Module__c)(existingRecords.get(module.Id));

            // Select only modules that are being activated
            if(!(oldModule.IsActive__c) && module.IsActive__c) {
                activatedModules.add(module);
            }
            // Select only modules that are being inactivated
            if(oldModule.IsActive__c && !(module.IsActive__c)) {
                inactivatedModules.add(module);
            }   
            // Select modules whose question pool is changed from null to != null or weighted questions is set to false
            if((oldModule.QuestionPool__c == null && module.QuestionPool__c != null) || 
               (oldModule.WeightedQuestions__c && !(module.WeightedQuestions__c))) {
                modulesToChangeQuestions.add(module);
                modulesToChangeCorrectWeight.add(module.Id);
            }               
            // Select modules whose Penalty mode is changed from "Negative weight" to "Percent decrease" or "None"
            if((oldModule.PenaltyMode__c == 'Negative Weight' && (module.PenaltyMode__c == 'Percent Decrease' || module.PenaltyMode__c == 'None'))) {
                modulesToChangeQuestions.add(module);
                modulesToChangeIncorrectWeight.add(module.Id);
            }   
            // Select modules whose Penalty mode is changed from "Percent decrease" to "Negative weight" or "None"
            if((oldModule.PenaltyMode__c == 'Percent Decrease' && (module.PenaltyMode__c == 'Negative Weight' || module.PenaltyMode__c == 'None'))) {
                modulesToChangeQuestions.add(module);
                modulesToChangePenaltyPerAttempt.add(module.Id);
            }           
        }

        SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{Course__c.SObjectType, Question__c.SObjectType});
        updateCourses(activatedModules, inactivatedModules, uow);

        //Remove dependencies from that module
        if (!inactivatedModules.isEmpty()) {
            validateAdminFields = false;
            removeModuleDependency(inactivatedModules);
            validateAdminFields = true;
        }

        if (!activatedModules.isEmpty()) {
            validateAdminFields = false;
            addModuleDependency(activatedModules);
            validateAdminFields = true;
        }
        //If the question pool is changed from null to != null or weighted questions is set to false, then will update all the related questions will have weight = 1. (Trigger) 
        updateQuestions(new List<Module__c>(modulesToChangeQuestions), modulesToChangeCorrectWeight, modulesToChangeIncorrectWeight, modulesToChangePenaltyPerAttempt, uow);
        
        if( Schema.sObjectType.Course__c.isCreateable() && Schema.sObjectType.Question__c.isCreateable() && Schema.sObjectType.Course__c.isUpdateable() && Schema.sObjectType.Question__c.isUpdateable() ){
             uow.commitWork();
        }else{
            throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
        }
       
    }

    // Check the responses for a list of modules
    private void updateCourses(List<Module__c> activatedModules, List<Module__c> inactivatedModules, SObjectUnitOfWork uow) {
        
        Set<Id> courseIds = new Set<Id>();
        if(activatedModules != null){
            for(Module__c module : activatedModules) {
                if(!hasError(module.Id)) {
                    courseIds.add(module.Course__c);
                }               
            }
        }

        if(inactivatedModules != null){
            for(Module__c module : inactivatedModules) {
                if(!hasError(module.Id)) {
                    courseIds.add(module.Course__c);
                }
            }
        }

        Map<Id,Course__c> coursesMap = new Map<Id,Course__c>(new CoursesSelector(new Set<String> {'Id','ActiveModules__c'}).selectById(courseIds));
        if(activatedModules != null){
            for(Module__c module : activatedModules) {
                if(!hasError(module.Id)) {
                    Course__c course = coursesMap.get(module.Course__c);
                    course.ActiveModules__c++;
                }
            }
        }

        if(inactivatedModules != null){
            for(Module__c module : inactivatedModules) {
                if(!hasError(module.Id)) {
                    Course__c course = coursesMap.get(module.Course__c);
                    course.ActiveModules__c--;
                }                   
            }
        }

        uow.registerDirty(coursesMap.values());
        Courses.validateAdminFields = false;
    }

    private void removeModuleDependency(List<Module__c> inactivatedModules) {
        Set<Id> inactiveModulesIds = new Map<Id,Module__c>(inactivatedModules).keySet();
        List<Module__c> modules = new ModulesSelector(new Set<String>{'Id','KeyDependencies__c'}).selectByPredecessor(inactiveModulesIds);

        Set<String> keySetDependencies;
        List<String> keyDependencies;
        Map<Id,Module__c> modulesMap = new Map<Id,Module__c>();
        for(Module__c module: modules) {
            if (module.KeyDependencies__c != null) {
                if (!modulesMap.containsKey(module.Id)) {
                    modulesMap.put(module.Id, module);
                }
                keySetDependencies = new Set<String>(module.KeyDependencies__c.split(','));

                for (String key: keySetDependencies) {
                    if (inactiveModulesIds.contains(key)) {
                        keySetDependencies.remove(key);
                    }
                }
                keyDependencies = new List<String>(keySetDependencies);
                keyDependencies.sort();
                modulesMap.get(module.Id).KeyDependencies__c = String.join(keyDependencies,',');
                modulesMap.get(module.Id).HasDependencies__c = modulesMap.get(module.Id).KeyDependencies__c != '' &&
                    modulesMap.get(module.Id).KeyDependencies__c != null;
            }
            
        } 
        
        if(!modulesMap.values().isEmpty()) {
            SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{Module__c.SObjectType});
            uow.registerDirty(modulesMap.values());

            if( Schema.sObjectType.Module__c.isCreateable() && Schema.sObjectType.Module__c.isUpdateable()){
                  uow.commitWork();
          }else{
            throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
          }
        }
    }

    private void addModuleDependency(List<Module__c> activatedModules) {
        Set<Id> activeModulesIds = new Map<Id,Module__c>(activatedModules).keySet();
        List<ModuleDependency__c> mds = new ModuleDependenciesSelector(new Set<String>{'Predecessor__c','Module__c','Module__r.KeyDependencies__c'}).selectByPredecessor(activeModulesIds);

        Set<String> keySetDependencies;
        List<String> keyDependencies;
        Map<Id,Module__c> modulesMap = new Map<Id,Module__c>();
        for(ModuleDependency__c md: mds) {
            if (md.Module__r.KeyDependencies__c == null) {
                md.Module__r.KeyDependencies__c = String.valueOf(md.Predecessor__c);
                md.Module__r.HasDependencies__c = true;
                modulesMap.put(md.Module__c, md.Module__r);
            } else {
                keySetDependencies = new Set<String>(md.Module__r.KeyDependencies__c.split(','));

                if (!keySetDependencies.contains(String.valueOf(md.Predecessor__c))) {
                    if (!modulesMap.containsKey(md.Module__c)) {
                        modulesMap.put(md.Module__c, md.Module__r);
                    }

                    keySetDependencies.add(String.valueOf(md.Predecessor__c));
                
                    keyDependencies = new List<String>(keySetDependencies);
                    keyDependencies.sort();
                    modulesMap.get(md.Module__c).KeyDependencies__c = String.join(keyDependencies,',');
                    modulesMap.get(md.Module__c).HasDependencies__c = true;
                    
                }
            }
        }
        
        if (!modulesMap.values().isEmpty()) {
            SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{Module__c.SObjectType});
            uow.registerDirty(modulesMap.values());

            if( Schema.sObjectType.Module__c.isCreateable() && Schema.sObjectType.Module__c.isUpdateable()){
                  uow.commitWork();
          }else{
            throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
          }
        }
    }

    private void updateQuestions(List<Module__c> modulesToChangeQuestions, Set<Id> modulesToChangeCorrectWeight, Set<Id> modulesToChangeIncorrectWeight, 
                                    Set<Id> modulesToChangePenaltyPerAttempt, SObjectUnitOfWork uow) {
        
        Map<Id,Module__c> modulesMap = new Map<Id, Module__c>(modulesToChangeQuestions);

        for(Question__c question : new QuestionsSelector(new Set<String> {'Id','Module__c'}).selectByModule(modulesMap.keySet())) {
            // If the question pool is changed from null to != null or weighted questions is set to false, then will update all the related questions will have weight = 1. 
            if(modulesToChangeCorrectWeight.contains(question.Module__c)) {
                question.CorrectWeight__c = 1;
            }
            // If the Penalty mode is changed from "Incorrect weight" to "Percent decrease" or "None" then will update the related questions with Incorrect weight to 0.
            if(modulesToChangeIncorrectWeight.contains(question.Module__c)) {
                question.IncorrectWeight__c = 0;
            }
            // If the Penalty mode is changed from "Percent decrease" to "Negative weight" or "None" then will update the related questions with Penalty per Attempt to 0.
            if(modulesToChangePenaltyPerAttempt.contains(question.Module__c)) {
                question.PenaltyPerAttempt__c = 0;
            }

            uow.registerDirty(question);
        }   
    }  

    public override void onBeforeDelete() {
        isDelete = true;

        List<Module__c> activeModules = new List<Module__c>();

        for(Module__c module : (List<Module__c>)records) {
            // Select only active modules
            if(module.IsActive__c) {
                activeModules.add(module);
            }
        }

        // An active module with related module responses cannot be deleted.
        checkModule((List<Module__c>)records);

        SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{Course__c.SObjectType, ModuleDependency__c.SObjectType, Question__c.SObjectType});
        deleteModuleDependencies(uow);
        deleteQuestions(uow);
        if(!Courses.isDelete)
            updateCourses(null, activeModules, uow);
        Courses.validateAdminFields = false;
        Questions.validateAdminFields = false;

        if( Schema.sObjectType.Course__c.isDeletable() && Schema.sObjectType.Course__c.isUpdateable() && Schema.sObjectType.Course__c.isCreateable() &&
        Schema.sObjectType.ModuleDependency__c.isDeletable() && Schema.sObjectType.ModuleDependency__c.isUpdateable() &&Schema.sObjectType.ModuleDependency__c.isCreateable() && Schema.sObjectType.Question__c.isCreateable() &&        Schema.sObjectType.Question__c.isDeletable() && Schema.sObjectType.Question__c.isUpdateable() ){
             uow.commitWork();
          }else{
            throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
          }

    }


    // Check the questions for a list of modules
    private void checkQuestions(List<Module__c> activatedModules) {
        
        Map<Id,Module__c> modulesMap = new Map<Id, Module__c>(activatedModules);

        List<Module__c> modulesWithQuestion = new ModulesSelector(new Set<String> {'Id'}).selectByIdHavingQuestions(modulesMap.KeySet());
                                                                                
        for(Module__c module : modulesWithQuestion) {
            if(module.Questions__r.isEmpty()){
                modulesMap.get(module.Id).addError(Label.ValidateModuleActive);
            }else if(modulesMap.get(module.Id).QuestionPool__c != null && modulesMap.get(module.Id).QuestionPool__c > module.Questions__r.size()){
                modulesMap.get(module.Id).addError(Label.QuestionPoolGreaterThenQuestionNumber);
            }
        }
    }

    // If the Module is active, has at least 1 related Module response, and any of the following fields (see error message) was modified the Module cannot be edited or deleted 
    private void checkModule(List<Module__c> modules) {
        Map<Id,Module__c> modulesMap = new Map<Id, Module__c>(modules);

        List<Module__c> modulesWithResponse = new ModulesSelector(new Set<String>{'FieloELR__IsActive__c','FieloELR__Course__r.FieloELR__Status__c'}).selectByIdHavingModuleResponses(modulesMap.KeySet()); 
        for(Module__c module : modulesWithResponse) {
            if(module.FieloELR__IsActive__c && module.FieloELR__Course__r.FieloELR__Status__c == 'Active'){
                if(!Courses.isDelete) {
                    addError(modulesMap.get(module.Id), Label.CannotDeleteActiveModuleInActiveCourse);
                }
            }else if (!module.ModuleResponses__r.isEmpty()) {
                addError(modulesMap.get(module.Id), Label.ValidateModuleEditableFields);
            }
        }
    }

    private void deleteModuleDependencies(SObjectUnitOfWork uow) {
        Map<Id, Module__c> modulesMap = new Map<Id, Module__c>((List<Module__c>)records);
        Set<Id> moduleIds = modulesMap.KeySet();
        moduleIds.removeAll(new List<Id>(RecordErrors));
        List<ModuleDependency__c> moduleDependencies = new ModuleDependenciesSelector(new Set<String> {'Id'}).selectByModule(moduleIds);
        uow.registerDeleted(moduleDependencies);
    }

    private void deleteQuestions(SObjectUnitOfWork uow) {
        Map<Id, Module__c> modulesMap = new Map<Id, Module__c>((List<Module__c>)records);
        Set<Id> moduleIds = modulesMap.KeySet();
        moduleIds.removeAll(new List<Id>(RecordErrors));
        List<Question__c> questions = new QuestionsSelector(new Set<String> {'Id'}).selectByModule(moduleIds);
        uow.registerDeleted(questions);
    }


    // Check the answers for a list of modules
    private void checkAnswers(List<Module__c> activatedModules) {

        Map<Id,Module__c> modulesMap = new Map<Id, Module__c>(activatedModules);

        // Then check for answers for those questions
        List<Question__c> questionsWithCorrectAnswer = new QuestionsSelector(new Set<String> {'Id', 'Name', 'Module__c', 'Type__c'}).selectByModuleHavingAnswers(modulesMap.KeySet()); 
                                                                                
        for(Question__c question : questionsWithCorrectAnswer) {
            if((question.Type__c == 'Statement' || question.Type__c == 'Single Choice' || question.Type__c == 'Multiple Choice' || question.Type__c == 'Matching Options' || question.Type__c == 'Short Answer') && question.AnswerOptions__r.isEmpty()) {
                // Question types "statement", "single choice","multiple choice", "Matching" and "Short Answer" must have at least one answer option.
                addError(modulesMap.get(question.Module__c),Label.ValidateModuleActiveQuestion +' '+ question.Type__c +' '+ Label.ValidateModuleActiveQuestionAnswer +' '+ question.Name);

            } else if((question.Type__c == 'Single Choice' || question.Type__c == 'Multiple Choice' || question.Type__c == 'Matching Options') && !(question.AnswerOptions__r.size() > 1)) {
                // Question types "single choice","multiple choice" and "Matching" must have at least two answer option.
                addError(modulesMap.get(question.Module__c),Label.ValidateModuleActiveQuestion +' '+ question.Type__c +' '+ Label.TwoAnswerOptionsRequired +' '+ question.Name);

            } else if((question.Type__c == 'Statement' || question.Type__c == 'Single Choice' || question.Type__c == 'Multiple Choice') && (question.AnswerOptions__r[0].IsCorrect__c != true)) {
                // Question types "statement" and "single choice" must have a correct answer option.
                addError(modulesMap.get(question.Module__c),Label.ValidateModuleActiveQuestion +' '+ question.Type__c +' '+ Label.ValidateModuleActiveAnswer +' '+ question.Name);
            } 
        }
    }
}