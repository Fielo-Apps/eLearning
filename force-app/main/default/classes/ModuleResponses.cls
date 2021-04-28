public class ModuleResponses extends SObjectDomain {
    public static Set<Id> processedIds = new Set<Id>();
    public static Set<Id> approvedIds = new Set<Id>();
    public static Set<Id> submittedIds = new Set<Id>();
    public static Boolean validateAdminFields = true;
    public static Boolean disableCommit = false;
    public static SObjectUnitOfWork questionResponseUOW;

    public ModuleResponses(List<ModuleResponse__c> records) {
        super(records);
    }

    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<ModuleResponse__c> sObjectList) {
            //If has Admin Permission allow "validateAdminFields"
            if(FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()) != null && FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()).FieloPLT__To__c >= system.now()){
                validateAdminFields = false;
            }

            return new ModuleResponses(sObjectList);
        }
    }

    public override void onApplyDefaults() {
        Set<String> mrKeys = new Set<String>();
        for(ModuleResponse__c moduleResponse : (List<ModuleResponse__c>)records){
            if (moduleResponse.Module__c != null && moduleResponse.Member__c != null) {
                moduleResponse.IsSubmitted__c = false;
                moduleResponse.IsApproved__c = false;
                moduleResponse.CorrectQuestions__c = 0;
                moduleResponse.IncorrectQuestions__c = 0;
                moduleResponse.TotalQuestions__c = 0;
                moduleResponse.ExternalKey__c = String.valueOf(moduleResponse.Module__c) + String.valueOf(moduleResponse.Member__c);
                if (moduleResponse.Date__c == null) {
                    moduleResponse.Date__c = System.today();
                }
                mrKeys.add(moduleResponse.ExternalKey__c);
            } else {
                if (moduleResponse.Module__c == null) {
                    moduleResponse.addError(Label.ModuleRequiredField);
                }
                if (moduleResponse.Member__c == null) {
                    moduleResponse.addError(Label.MemberRequiredField);
                }
                return;
            }
        }

        if (!mrKeys.isEmpty()) {
            List<AggregateResult> aggResult = new ModuleResponsesSelector().selectByKeyGroupByKey(mrKeys);
            Map<String,Decimal> maxNumbByKey = new Map<String,Decimal>();
            for(AggregateResult mr : aggResult){
                maxNumbByKey.put((String)mr.get('FieloELR__ExternalKey__c'), (Decimal)mr.get('attemptNumber'));
            }

            for(ModuleResponse__c moduleResp : (List<ModuleResponse__c>)records){
                if (moduleResp.Module__c != null && moduleResp.Member__c != null) {
                    if(maxNumbByKey.containsKey(moduleResp.ExternalKey__c)){
                        Decimal maxAttempt = maxNumbByKey.get(moduleResp.ExternalKey__c);
                        moduleResp.NumberOfAttempt__c = ++maxAttempt;
                        maxNumbByKey.put(moduleResp.ExternalKey__c, maxAttempt);
                    }else{
                        moduleResp.NumberOfAttempt__c = 1;
                        maxNumbByKey.put(moduleResp.ExternalKey__c, 1);
                    }
                }
            }
        }
    }

    public override void onValidate(){
        //store module Ids
        Set<Id> moduleIds = new Set<Id>();
        for(ModuleResponse__c moduleResponse : (List<ModuleResponse__c>)records){
            if (moduleResponse.Module__c != null && moduleResponse.Member__c != null) {
                moduleIds.add(moduleResponse.Module__c);
            } else {
                if (moduleResponse.Module__c == null) {
                    moduleResponse.addError(Label.ModuleRequiredField);
                }
                if (moduleResponse.Member__c == null) {
                    moduleResponse.addError(Label.MemberRequiredField);
                }
                return;
            }

        }

        //Creates a set to know wich are the required modules to be approved for each of the related members
        Map<Id,Module__c> modulesMap = new Map<Id,Module__c>(new ModulesSelector(new Set<String>{'Id','Course__c','Course__r.SubscriptionMode__c','Course__r.StartDatetime__c','Course__r.EndDatetime__c'}).selectByIdHavingDependencies(moduleIds));
        Set<String> mrKeysRequired = new Set<String>();
        Set<String> csKeysRequired = new Set<String>();
        Set<String> modulesProcessedIds = new Set<String>();
        for(ModuleResponse__c moduleResponse : (List<ModuleResponse__c>)records){
            if (moduleResponse.Module__c != null && moduleResponse.Member__c != null) {
                if (modulesMap.get(moduleResponse.Module__c).Course__r.StartDatetime__c != null) {
                    if (moduleResponse.Date__c < modulesMap.get(moduleResponse.Module__c).Course__r.StartDatetime__c) {
                        moduleResponse.addError(Label.OutOfCoursePeriod);
                        return;
                    }
                }
                if (modulesMap.get(moduleResponse.Module__c).Course__r.EndDatetime__c != null) {
                    if (moduleResponse.Date__c > modulesMap.get(moduleResponse.Module__c).Course__r.EndDatetime__c) {
                        moduleResponse.addError(Label.OutOfCoursePeriod);
                        return;
                    }
                }

                String moduleResponseKey = String.valueOf(moduleResponse.Module__c)+ String.valueOf(moduleResponse.Member__c);
                if(!modulesProcessedIds.contains(moduleResponseKey)){
                    for(ModuleDependency__c md : modulesMap.get(moduleResponse.Module__c).PredecessorModules__r){
                        mrKeysRequired.add(String.valueOf(md.Predecessor__c) + String.valueOf(moduleResponse.Member__c));
                    }
                    modulesProcessedIds.add(moduleResponseKey);
                }

                //add keys to query course status
                csKeysRequired.add(String.valueOf(modulesMap.get(moduleResponse.Module__c).Course__c) + String.valueOf(moduleResponse.Member__c));
            }
        }

        //query in the database only the moduleResponses that were approved for the related members
        Set<String> approvedMRKeys = new Set<String>();
        for(ModuleResponse__c mr : new ModuleResponsesSelector(new Set<String>{'ExternalKey__c'}).selectByKeyAndApproved(mrKeysRequired)){
            approvedMRKeys.add(mr.ExternalKey__c);
        }

        //query in the database only the courseStatus that exist for the related members
        Map<String,CourseStatus__c> existingCSMap = new Map<String,CourseStatus__c>();
        for(CourseStatus__c cs : new CourseStatusSelector(new Set<String>{'ExternalKey__c'}).selectByKey(csKeysRequired)){
            existingCSMap.put(cs.ExternalKey__c, cs);
        }

        //verifies for each module response if the related modules where approved for the member
        Set<String> mrKeysWithError = new Set<String>();
        SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{CourseStatus__c.SobjectType}, true);
        Map<String,CourseStatus__c> newCourseStatusMap = new Map<String,CourseStatus__c>();
        List<ModuleResponse__c> mrWithNewCourseStatus = new List<ModuleResponse__c>();
        for(ModuleResponse__c moduleResponse : (List<ModuleResponse__c>)records){
            if (moduleResponse.Module__c != null && moduleResponse.Member__c != null) {

                String cskey = String.valueOf(modulesMap.get(moduleResponse.Module__c).Course__c) + String.valueOf(moduleResponse.Member__c);

                if(mrKeysWithError.contains(moduleResponse.ExternalKey__c)){
                    moduleResponse.addError(Label.ValidateModuleResponseMemberApproved);
                    continue;
                }

                Boolean errorDependency = false;
                for(ModuleDependency__c md : modulesMap.get(moduleResponse.Module__c).PredecessorModules__r){
                    String dependentKey = String.valueOf(md.Predecessor__c) + String.valueOf(moduleResponse.Member__c);
                    if(!approvedMRKeys.contains(dependentKey)){
                        moduleResponse.addError(Label.ValidateModuleResponseMemberApproved);
                        mrKeysWithError.add(moduleResponse.ExternalKey__c);
                        errorDependency = true;
                        break;
                    }
                }

                if(errorDependency)
                    continue;

                if(existingCSMap.containsKey(cskey)){
                    moduleResponse.CourseStatus__c = existingCSMap.get(cskey).Id;
                }else{
                    if(modulesMap.get(moduleResponse.Module__c).Course__r.SubscriptionMode__c == 'Manual'){
                        moduleResponse.addError(Label.ValidateModuleResponseRegisteredMember);
                    }else{
                        if(!newCourseStatusMap.containsKey(cskey)){
                            CourseStatus__c cs = new CourseStatus__c(Course__c = modulesMap.get(moduleResponse.Module__c).Course__c, Member__c = moduleResponse.Member__c);
                            newCourseStatusMap.put(cskey, cs);
                            uow.registerNew(cs);
                        }
                        mrWithNewCourseStatus.add(moduleResponse);
                    }
                }
            }
        }

        if(!mrWithNewCourseStatus.isEmpty()){
            CourseStatus.validateAdminFields = false;

            if( Schema.sObjectType.CourseStatus__c.isCreateable() && Schema.sObjectType.CourseStatus__c.isUpdateable() ){
                 uow.commitWork();
          }else{
            throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
          }

            SObjectUnitOfWork.DatabaseResult results = uow.getResults(CourseStatus__c.SObjectType);

            Map<String,List<String>> errorMsgByCoursest = new Map<String,List<String>>();
            Integer i = 0;
            for (Database.SaveResult sr : results.insertResults) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors
                    List<String> errorMsgs = new List<String>();
                    for(Database.Error err : sr.getErrors()) {
                        errorMsgs.add(err.getMessage());
                    }
                    CourseStatus__c cs = (CourseStatus__c)uow.m_newListByType.get('FieloELR__CourseStatus__c')[i];
                    String csKey = String.valueOf(cs.Course__c) + String.valueOf(cs.Member__c);
                    errorMsgByCoursest.put(csKey, errorMsgs);
                }
                i++;
            }

            for(ModuleResponse__c mr : mrWithNewCourseStatus){
                String cskey = String.valueOf(modulesMap.get(mr.Module__c).Course__c) + String.valueOf(mr.Member__c);
                if(!errorMsgByCoursest.containsKey(cskey)){
                    mr.CourseStatus__c = newCourseStatusMap.get(cskey).Id;
                }else{
                    for(String error : errorMsgByCoursest.get(cskey)){
                        mr.addError(error);
                    }
                }
            }
        }
    }

    public override void onValidate(Map<Id,SObject> existingRecords){
        if(validateAdminFields){
            Set<Id> moduleIds = new Set<Id>();
            for(ModuleResponse__c moduleResponse : (List<ModuleResponse__c>)records){
                if(((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).IsSubmitted__c){
                    moduleResponse.addError(Label.ValidateModuleResponseSubmitted);
                }
                if (!submittedIds.contains(moduleResponse.Id)) {
                    //This part may run twice due to Workflow Rules, Rollups or Workflow proccesses.
                    // if it is a submittion we should not unset the values.
                    if(moduleResponse.IsApproved__c != ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).IsApproved__c){
                        moduleResponse.IsApproved__c = ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).IsApproved__c;
                    }
                    if(moduleResponse.GradeValue__c != ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).GradeValue__c){
                        moduleResponse.GradeValue__c = ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).GradeValue__c;
                    }
                    if(moduleResponse.GradePercent__c != ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).GradePercent__c){
                        moduleResponse.GradePercent__c = ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).GradePercent__c;
                    }
                    if(moduleResponse.CorrectQuestions__c != ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).CorrectQuestions__c){
                        moduleResponse.CorrectQuestions__c = ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).CorrectQuestions__c;
                    }
                    if(moduleResponse.IncorrectQuestions__c != ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).IncorrectQuestions__c){
                        moduleResponse.IncorrectQuestions__c = ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).IncorrectQuestions__c;
                    }
                    if(moduleResponse.TotalQuestions__c != ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).TotalQuestions__c){
                        moduleResponse.TotalQuestions__c = ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).TotalQuestions__c;
                    }
                }
                if(moduleResponse.ExternalKey__c != ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).ExternalKey__c){
                    moduleResponse.ExternalKey__c = ((ModuleResponse__c)existingRecords.get(moduleResponse.Id)).ExternalKey__c;
                }
                moduleIds.add(moduleResponse.Module__c);
            }

            Map<Id,Module__c> modulesMap = new Map<Id,Module__c>(new ModulesSelector(new Set<String>{'Id','Course__c','Course__r.SubscriptionMode__c','Course__r.StartDatetime__c','Course__r.EndDatetime__c'}).selectById(moduleIds));

            for(ModuleResponse__c moduleResponse : (List<ModuleResponse__c>)records) {
                if (moduleResponse.Date__c > modulesMap.get(moduleResponse.Module__c).Course__r.EndDatetime__c &&
                    moduleResponse.Date__c < modulesMap.get(moduleResponse.Module__c).Course__r.StartDatetime__c) {
                    moduleResponse.addError(Label.OutOfCoursePeriod);
                    return;
                }
            }
        }
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        List<ModuleResponse__c> submittedRecords = new List<ModuleResponse__c>();

        for(ModuleResponse__c moduleResp: (List<ModuleResponse__c>)records){
            //Add only submitted records.
            if( moduleResp.IsSubmitted__c ){
                if( !((ModuleResponse__c)existingRecords.get(moduleResp.Id)).IsSubmitted__c){
                    if(!submittedIds.contains(moduleResp.Id)) {
                        submittedIds.add(moduleResp.Id);
                        moduleResp.SubmitDate__c = System.now();
                        submittedRecords.add(moduleResp);
                    }
                }
            }
        }
        if(!submittedRecords.isEmpty()){
            setGradeAndApprovalFlag(submittedRecords);
        }
    }

    public override void onAfterInsert() {
        FieloPLT.SObjectService.processEmailRecords(records, null);
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        List<ModuleResponse__c> recordsToProcess = new List<ModuleResponse__c>();
        List<ModuleResponse__c> approvedRecords = new List<ModuleResponse__c>();
        Map<Id,ModuleResponse__c> mapExistingRecordsToProcess = new Map<Id,ModuleResponse__c>();

        // Submit Unsubmited Question Responses
        if (questionResponseUOW != null) {
            if (!disableCommit) {
                disableCommit = true;
                try {
                    QuestionResponses.validateAdminFields = false;
                    validateAdminFields = false;
                    questionResponseUOW.commitWork();
                    validateAdminFields = true;
                    QuestionResponses.validateAdminFields = true;
                    QuestionResponses.disableSubmit = false;
                } catch (Exception e) {
                    validateAdminFields = true;
                    QuestionResponses.validateAdminFields = true;
                    QuestionResponses.disableSubmit = false;
                    throw e;
                }
            }
            questionResponseUOW = null;
        }

        for(ModuleResponse__c record : (List<ModuleResponse__c>)records){
            recordsToProcess.add(record);
            mapExistingRecordsToProcess.put(record.Id,(ModuleResponse__c)existingRecords.get(record.Id));
            processedIds.add(record.Id);
            if(!approvedIds.contains(record.Id)) {
                if(record.IsApproved__c && !((ModuleResponse__c)existingRecords.get(record.Id)).IsApproved__c){
                    approvedRecords.add(record);
                    approvedIds.add(record.Id);
                }
            }
        }

        if(!recordsToProcess.isEmpty()){
            FieloPLT.SObjectService.processRecords(recordsToProcess, mapExistingRecordsToProcess);
        }
        if(!approvedRecords.isEmpty()){
            calculateCourseStatusProgress(approvedRecords, true);
        }
    }

    public override void onBeforeDelete(){
        List<ModuleResponse__c> approvedRecords = new List<ModuleResponse__c>();
        for(ModuleResponse__c moduleResponse : (List<ModuleResponse__c>)records){
            if(moduleResponse.IsApproved__c){
                approvedRecords.add(moduleResponse);
            }
        }

        calculateCourseStatusProgress(approvedRecords, false);
    }

    public void setGradeAndApprovalFlag(List<ModuleResponse__c> records) {
        Map<Id,ModuleResponse__c> moduleResponsesMap = new Map<Id,ModuleResponse__c>(records);
        Set<Id> moduleIds = new Set<Id>();
        for(ModuleResponse__c moduleResponse: records) {
            moduleIds.add(moduleResponse.Module__c);
        }
        Map<Id,ModuleResponse__c> existingModuleResponseMap = new Map<Id,ModuleResponse__c>(new ModuleResponsesSelector().selectByIdWithQuestionResponses(moduleResponsesMap.keySet()));
        Map<Id,Module__c> modulesMap = new Map<Id,Module__c>(new ModulesSelector(new Set<String>{'Course__c','TotalValue__c','ApprovalGrade__c','QuestionPool__c'}).selectByIdWithQuestions(moduleIds));
        Map<Id,Question__c> questionMap;

        Map<Id,QuestionResponse__c> unsubmitedQuestionResponses = new Map<Id,QuestionResponse__c>();
        // Checking for unsubmitted questions
        for (ModuleResponse__c moduleResponse: existingModuleResponseMap.values()) {
            for (QuestionResponse__c questionResponse: moduleResponse.QuestionResponses__r) {
                if ( !questionResponse.IsSubmitted__c ) {
                    unsubmitedQuestionResponses.put(questionResponse.Id,questionResponse);
                }
            }
        }

        if (!unsubmitedQuestionResponses.isEmpty()) {
            QuestionResponses.disableSubmit = true;
            Map<Id,String> mapErrors = QuestionResponses.setIsCorrect(unsubmitedQuestionResponses.values());

            questionResponseUOW = new SObjectUnitOfWork(new List<Schema.SObjectType>{QuestionResponse__c.SObjectType});
            for(Id qrId : unsubmitedQuestionResponses.keySet()){
            //for(QuestionResponse__c questionResponse : unsubmitedQuestionResponses.keySet()){
                QuestionResponse__c questionResponse = unsubmitedQuestionResponses.get(qrId);
                if(!mapErrors.containsKey(qrId)){
                    questionResponse.IsSubmitted__c = true;
                    questionResponseUOW.registerDirty(questionResponse);
                }else{
                    addError(moduleResponsesMap.get(questionResponse.ModuleResponse__c),mapErrors.get(qrId));
                }
            }
        }

        Set<String> mrKeys = new Set<String>();
        List<ModuleResponse__c> approvedResponses = new List<ModuleResponse__c>();
        for (ModuleResponse__c moduleResponse: (List<ModuleResponse__c>)records) {
            if(!hasError(moduleResponse.Id)){
                moduleResponse.GradeValue__c = 0.0;
                questionMap = new Map<Id,Question__c>(modulesMap.get(moduleResponse.Module__c).Questions__r);

                if (moduleResponse.CorrectQuestions__c == null) {
                    moduleResponse.CorrectQuestions__c = 0;
                }
                if (moduleResponse.IncorrectQuestions__c == null) {
                    moduleResponse.IncorrectQuestions__c = 0;
                }
                if (moduleResponse.TotalQuestions__c == null) {
                    moduleResponse.TotalQuestions__c = 0;
                }
                system.debug(
                    JSON.serializePretty(existingModuleResponseMap)
                );
                for (QuestionResponse__c questionResponse: existingModuleResponseMap.get(moduleResponse.Id).QuestionResponses__r) {
                    moduleResponse.GradeValue__c += questionResponse.PartialGradevalue__c;
                    if (questionResponse.IsCorrect__c) {
                        moduleResponse.CorrectQuestions__c++;
                    } else {
                        moduleResponse.IncorrectQuestions__c++;
                    }
                    moduleResponse.TotalQuestions__c++;
                }

                Decimal totalValue = modulesMap.get(moduleResponse.Module__c).QuestionPool__c == null ? modulesMap.get(moduleResponse.Module__c).TotalValue__c : modulesMap.get(moduleResponse.Module__c).QuestionPool__c;
                moduleResponse.GradePercent__c = ((moduleResponse.GradeValue__c / totalValue) * 100).setScale(2);
                moduleResponse.IsApproved__c = moduleResponse.GradePercent__c >= modulesMap.get(moduleResponse.Module__c).ApprovalGrade__c;

                if(moduleResponse.IsApproved__c){
                    mrKeys.add(moduleResponse.ExternalKey__c);
                    approvedResponses.add(moduleResponse);
                }
            }
        }

        if(!mrKeys.isEmpty()){
            List<AggregateResult> aggResult;
            if( Schema.sObjectType.ModuleResponse__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.NumberOfApprove__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.ExternalKey__c.isAccessible() ){
                aggResult = [SELECT MAX(NumberOfApprove__c) approveNumber, ExternalKey__c FROM ModuleResponse__c WHERE ExternalKey__c in : mrKeys GROUP BY ExternalKey__c];
            }
            Map<String,Decimal> maxAppByKey = new Map<String,Decimal>();
            for(AggregateResult mr : aggResult){
                maxAppByKey.put((String)mr.get('FieloELR__ExternalKey__c'), (Decimal)mr.get('approveNumber'));
            }

            for(ModuleResponse__c moduleResponse : approvedResponses){
                if(!hasError(moduleResponse.Id)){
                    if(maxAppByKey.containsKey(moduleResponse.ExternalKey__c)){
                        Decimal maxApprove = maxAppByKey.get(moduleResponse.ExternalKey__c);
                        moduleResponse.NumberOfApprove__c = ++maxApprove;
                        maxAppByKey.put(moduleResponse.ExternalKey__c, maxApprove);
                    }else{
                        moduleResponse.NumberOfApprove__c = 1;
                        maxAppByKey.put(moduleResponse.ExternalKey__c, 1);
                    }
                }
            }
        }
    }

    private static void calculateCourseStatusProgress(List<ModuleResponse__c> records, Boolean isUpdate) {
        //store module Ids and mr keys
        Set<Id> moduleIds = new Set<Id>();
        Set<String> mrKeys = new Set<String>();
        for(ModuleResponse__c moduleResponse : (List<ModuleResponse__c>)records){
            moduleIds.add(moduleResponse.Module__c);
            mrKeys.add(moduleResponse.ExternalKey__c);
        }

        //Creates a set to know wich are the required modules to be approved for each of the related members
        Map<Id,Module__c> modulesMap = new Map<Id,Module__c>(new ModulesSelector(new Set<String>{'Id','Course__c','Course__r.SubscriptionMode__c'}).selectById(moduleIds));

        //look for already approved modules
        ModuleResponsesSelector mrSelector = new ModuleResponsesSelector(new Set<String>{'Id','ExternalKey__c'});
        List<ModuleResponse__c> approvedModuleResponses = isUpdate ? mrSelector.selectByKeyAndApproved(mrKeys, new Map<Id,ModuleResponse__c>(records).keySet()) : mrSelector.selectByKeyAndApproved(mrKeys, null);
        Set<String> approvedMRKeys = new Set<String>();
        for(ModuleResponse__c mr : approvedModuleResponses){
            approvedMRKeys.add(mr.ExternalKey__c);
        }

        //store course status keys
        Set<String> csKeys = new Set<String>();
        for(ModuleResponse__c moduleResponse : (List<ModuleResponse__c>)records){
            csKeys.add(String.valueOf(modulesMap.get(moduleResponse.Module__c).Course__c) + String.valueOf(moduleResponse.Member__c));
        }

        //look for existing course status
        Map<String,CourseStatus__c> csMap = new Map<String,CourseStatus__c>();
        for(CourseStatus__c cs : new CourseStatusSelector(new Set<String>{'ExternalKey__c','ApprovedModules__c'}).selectByKey(csKeys)){
            csMap.put(cs.ExternalKey__c, cs);
        }

        SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{CourseStatus__c.SObjectType});
        for(ModuleResponse__c moduleResponse : (List<ModuleResponse__c>)records){
            //verifies if the module was not approved previously
            if(approvedMRKeys.contains(moduleResponse.ExternalKey__c)){
                continue;
            }else{
                approvedMRKeys.add(moduleResponse.ExternalKey__c);
            }

            //looks for the course status where needs to update the progress
            CourseStatus__c cs;
            Module__c module = modulesMap.get(moduleResponse.Module__c);
            String csKey = String.valueOf(modulesMap.get(moduleResponse.Module__c).Course__c) + String.valueOf(moduleResponse.Member__c);

            if(isUpdate){
                if(module.Course__r.SubscriptionMode__c == 'Manual'){
                    if(csMap.containsKey(csKey)){
                        cs = csMap.get(csKey);
                        if(cs.Id != null){
                            uow.registerDirty(cs);
                        }
                    }
                }else{
                    if(csMap.containsKey(csKey)){
                        cs = csMap.get(csKey);
                        if(cs.Id != null){
                            uow.registerDirty(cs);
                        }
                    }else{
                        cs = new CourseStatus__c(Course__c = module.Course__c, ApprovedModules__c = 0, Member__c = moduleResponse.Member__c);
                        csMap.put(csKey, cs);
                        uow.registerNew(cs);
                    }
                }

                cs.ApprovedModules__c++;
            }else{
                if(csMap.containsKey(csKey)){
                    cs = csMap.get(csKey);
                    cs.ApprovedModules__c--;
                    uow.registerDirty(cs);
                }
            }
        }

        Boolean validateAdminFields = CourseStatus.validateAdminFields;
        CourseStatus.validateAdminFields = false;
        if( Schema.sObjectType.CourseStatus__c.isCreateable() && Schema.sObjectType.CourseStatus__c.isUpdateable() ){
                uow.commitWork();
          }else{
            throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
          }
        CourseStatus.validateAdminFields = validateAdminFields;
    }
}