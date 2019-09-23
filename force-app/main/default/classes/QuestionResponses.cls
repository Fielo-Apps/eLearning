public class QuestionResponses extends SObjectDomain {
    public static Set<Id> processedIds = new Set<Id>();
    public static Boolean disableSubmit = false;
    public static Boolean validateAdminFields = true;

    public QuestionResponses(List<QuestionResponse__c> records) {
        super(records);
    }

    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<QuestionResponse__c> sObjectList) {
            //If has Admin Permission allow "validateAdminFields"
            if(FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()) != null && FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()).FieloPLT__To__c >= system.now()){
                validateAdminFields = false;
            }

            return new QuestionResponses(sObjectList);
        }
    }

    public override void onApplyDefaults(){
        Set<String> qrKeys = new Set<String>();
        for(QuestionResponse__c questionResp : (List<QuestionResponse__c>)records){
            questionResp.IsSubmitted__c = false;
            questionResp.IsCorrect__c = false;
            if (questionResp.Question__c != null) {
                questionResp.ExternalKey__c = String.valueOf(questionResp.Question__c) + String.valueOf(questionResp.ModuleResponse__c);
                qrKeys.add(questionResp.ExternalKey__c);
            } else {
                questionResp.addError(Label.QuestionFieldRequired);
            }
        }
            

        if(!Schema.sObjectType.QuestionResponse__c.isAccessible())
            throw new FieloPLT.FieloException(Label.CannotAccessRecords);

        List<AggregateResult> aggResult = [SELECT MAX(NumberOfAttempt__c) attemptNumber, ExternalKey__c FROM QuestionResponse__c WHERE ExternalKey__c in : qrKeys GROUP BY ExternalKey__c];
        
        Map<String,Decimal> maxNumbByKey = new Map<String,Decimal>();
        for(AggregateResult qr : aggResult){
            maxNumbByKey.put((String)qr.get('FieloELR__ExternalKey__c'), (Decimal)qr.get('attemptNumber'));
        }
        
        for(QuestionResponse__c questionResp : (List<QuestionResponse__c>)records){
            if(maxNumbByKey.containsKey(questionResp.ExternalKey__c)){
                Decimal maxAttempt = maxNumbByKey.get(questionResp.ExternalKey__c);
                questionResp.NumberOfAttempt__c = ++maxAttempt;
                maxNumbByKey.put(questionResp.ExternalKey__c, maxAttempt);
            }else{
                questionResp.NumberOfAttempt__c = 1;
                maxNumbByKey.put(questionResp.ExternalKey__c, 1);
            }
        }
    }

    public override void onValidate() {

        Set<Id> moduleResponseIds = new Set<Id>();
        for(QuestionResponse__c questionResponse : (List<QuestionResponse__c>)records){
            if (questionResponse.Question__c == null) {
                questionResponse.addError(Label.QuestionFieldRequired);
            } else {
                moduleResponseIds.add(questionResponse.ModuleResponse__c);
            }
        }

        Map<Id,ModuleResponse__c> moduleResponsesMap = 
            new Map<Id,ModuleResponse__c>(new ModuleResponsesSelector().selectByIdWithQuestionPool(moduleResponseIds));

        //Builds map with remaining questions by question response to check if the number of question responses is bigger than the Question Pool
        List<AggregateResult> aggResult = new QuestionResponsesSelector().selectByModuleResponseGroupByModuleResponse(moduleResponseIds);
        Map<Id,Set<Id>> existingQuestionsMap = new Map<Id,Set<Id>>();
        Map<Id,Decimal> questionPoolsMap = new Map<Id,Decimal>();
        Id moduleResponseId;
        Id questionId;
        for(AggregateResult mr : aggResult) {
            moduleResponseId = (Id)mr.get('ModuleResponse');
            questionId = (Id)mr.get('Question');
            //Populates map with questions per question response (only those with Question Pool)
            if(existingQuestionsMap.containsKey(moduleResponseId)) {
                existingQuestionsMap.get(moduleResponseId).add(questionId);
            } else {
                existingQuestionsMap.put(moduleResponseId, new Set<Id> {questionId});
                questionPoolsMap.put(moduleResponseId, (Decimal)mr.get('QuestionPool'));            
            }
        }
     
        Decimal remainingQuestions;
        Set<Id> questions;
        for(QuestionResponse__c questionResponse : (List<QuestionResponse__c>)records) {
            moduleResponseId = questionResponse.ModuleResponse__c;
            questionId = questionResponse.Question__c;
            if(existingQuestionsMap.containsKey(questionResponse.ModuleResponse__c)) {
                questions = existingQuestionsMap.get(questionResponse.ModuleResponse__c);
                // Only adds if the current question is not yet part of the set for that module response
                if (!questions.contains(questionId)) {
                    questions.add(questionId);
                    existingQuestionsMap.put(questionResponse.ModuleResponse__c, questions);                    
                }
                if (questions.size() > questionPoolsMap.get(moduleResponseId)) {
                    questionResponse.addError(Label.QuestionsGreaterThanQuestionPool);
                }                
            } else if(moduleResponsesMap.containsKey(questionResponse.ModuleResponse__c)) {
                existingQuestionsMap.put(moduleResponseId, new Set<Id> {questionId});
                questionPoolsMap.put(moduleResponseId, moduleResponsesMap.get(moduleResponseId).Module__r.QuestionPool__c);            
            }
        }        

        if(validateAdminFields){
            validateModuleSubmitted(records);
        }
    }

    public override void onValidate(Map<Id,SObject> existingRecords){
        if(validateAdminFields){
            for(QuestionResponse__c questionResp : (List<QuestionResponse__c>)records){
                if(((QuestionResponse__c)existingRecords.get(questionResp.Id)).IsSubmitted__c){
                    questionResp.addError(Label.ValidateQuestionResponse);
                }

                if(questionResp.IsCorrect__c != ((QuestionResponse__c)existingRecords.get(questionResp.Id)).IsCorrect__c){
                    questionResp.IsCorrect__c = ((QuestionResponse__c)existingRecords.get(questionResp.Id)).IsCorrect__c;
                }
                if(questionResp.NumberOfAttempt__c != ((QuestionResponse__c)existingRecords.get(questionResp.Id)).NumberOfAttempt__c){
                    questionResp.NumberOfAttempt__c = ((QuestionResponse__c)existingRecords.get(questionResp.Id)).NumberOfAttempt__c;
                }
                if(questionResp.PartialGradeValue__c != ((QuestionResponse__c)existingRecords.get(questionResp.Id)).PartialGradeValue__c){
                    questionResp.PartialGradeValue__c = ((QuestionResponse__c)existingRecords.get(questionResp.Id)).PartialGradeValue__c;
                }
                if(questionResp.ExternalKey__c != ((QuestionResponse__c)existingRecords.get(questionResp.Id)).ExternalKey__c){
                    questionResp.ExternalKey__c = ((QuestionResponse__c)existingRecords.get(questionResp.Id)).ExternalKey__c;
                }
            }
        }

        List<QuestionResponse__c> submittedRecords = new List<QuestionResponse__c>();
        Set<String> submittedKeys = new Set<String>();
        for(QuestionResponse__c questionResp : (List<QuestionResponse__c>)records){
            //Add only submitted records.
            if( questionResp.IsSubmitted__c && !((QuestionResponse__c)existingRecords.get(questionResp.Id)).IsSubmitted__c){
                submittedRecords.add(questionResp);
                submittedKeys.add(questionResp.ExternalKey__c);
            }
        }

        List<QuestionResponse__c> correctedQuestionResponses = new QuestionResponsesSelector().selectByKeyAndCorrect(submittedKeys);
        Set<String> existingSubmittedResponses = new Set<String>();
        for(QuestionResponse__c qr : correctedQuestionResponses){
            existingSubmittedResponses.add(qr.ExternalKey__c);
        }

        for(QuestionResponse__c questionResp : submittedRecords){
            if(existingSubmittedResponses.contains(questionResp.ExternalKey__c)){
                questionResp.addError(Label.ValidateQuestionResponseSubmit);
            }
        }
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        Map<Id,QuestionResponse__c> submittedRecords = new Map<Id,QuestionResponse__c>();

        for(QuestionResponse__c questionResp: (List<QuestionResponse__c>)records){
            //Add only submitted records.
            if( questionResp.IsSubmitted__c ){
                if( !((QuestionResponse__c)existingRecords.get(questionResp.Id)).IsSubmitted__c ||
                    ((QuestionResponse__c)existingRecords.get(questionResp.Id)).IsSubmitted__c == null){
                    submittedRecords.put(questionResp.Id, questionResp);
                }
            }
        }

        if(!submittedRecords.isEmpty() && !disableSubmit){
            Map<Id,String> mapErrors = setIsCorrect(submittedRecords.values());
            if(!mapErrors.isEmpty()){
                for(Id qrId : mapErrors.keySet()){
                    submittedRecords.get(qrId).addError(mapErrors.get(qrId));
                }
            }
        }
    }

    public override void onBeforeDelete(){
        if(validateAdminFields){
            validateModuleSubmitted(records);
        }
    }

    private static void validateModuleSubmitted(List<QuestionResponse__c> questionResponses){
        Set<Id> moduleResponseIds = new Set<Id>();
        for(QuestionResponse__c questionResp : questionResponses){
            moduleResponseIds.add(questionResp.ModuleResponse__c);
        }

        Map<Id, ModuleResponse__c> moduleResponsesMap = new Map<Id, ModuleResponse__c>(
            new ModuleResponsesSelector().selectById(moduleResponseIds)
        );

        for(QuestionResponse__c questionResp : questionResponses){
            if(moduleResponsesMap.get(questionResp.ModuleResponse__c).IsSubmitted__c){
                if (Trigger.isDelete) {
                    questionResp.addError(Label.ValidateQuestionResponseDelete);
                }
                if (Trigger.isInsert) {
                    questionResp.addError(Label.ValidateQuestionResponseInsert);
                }
            }
        }
    }

    public static Map<Id,String> setIsCorrect(List<QuestionResponse__c> records) {
        Map<Id,String> mapErrors = new Map<Id,String>();
        Set<Id> questionResponseIds = new Map<Id,QuestionResponse__c>(records).keySet();
        Set<Id> questionIds = new Set<Id>();
        for (QuestionResponse__c questionResponse:records) {
            questionIds.add(questionResponse.Question__c);
        }
        Map<Id,QuestionResponse__c> existingQuestionResponses = new Map<Id,QuestionResponse__c>(new QuestionResponsesSelector().selectByIdWithAnswers(questionResponseIds));
        Map<Id,Question__c> questionsMap = new Map<Id,Question__c>(new QuestionsSelector(new Set<String>{'PenaltyPerAttempt__c','CorrectWeight__c','IncorrectWeight__c','Type__c','Module__r.PenaltyMode__c'}).selectByIdWithCorrectAnswers(questionIds));

        Double incorrectWeight;
        Double questionWeight;
        Double penaltyPerQuestion;
        Integer isCorrectInt;
        Integer questionRespAttempts;
        String penaltyMode;

        Set<String> correctKeys = new Set<String>();
        for (QuestionResponse__c questionResponse: records) {
            if (questionsMap.containsKey(questionResponse.Question__c)) {
                Question__c question = questionsMap.get(questionResponse.Question__c);
                if(question.Type__c == 'Multiple Choice' || question.Type__c == 'Single Choice' || question.Type__c == 'Statement'){
                    questionResponse.IsCorrect__c = true;
                    //verifies if the number of answers are the same as the correct ones
                    List<Answer__c> answers = existingQuestionResponses.get(questionResponse.Id).answers__r;
                    if (answers.size() == questionsMap.get(questionResponse.Question__c).AnswerOptions__r.size()) {
                        Set<Id> correctAnswerIds = new Map<Id,AnswerOption__c>(question.AnswerOptions__r).keySet();
                        
                        //loop the answers and verify that all of them are related to correct answer options
                        for(Answer__c answer : existingQuestionResponses.get(questionResponse.Id).answers__r) {
                            if (!correctAnswerIds.contains(answer.AnswerOption__c)) {
                                questionResponse.IsCorrect__c = false;
                                break;
                            }
                        }
                    } else {
                        questionResponse.IsCorrect__c = false;
                    }
                }else if (question.Type__c == 'Short Answer') {
                    questionResponse.IsCorrect__c = false;
                    for (AnswerOption__c answerOption: questionsMap.get(questionResponse.Question__c).AnswerOptions__r) {
                        if (answerOption.AnswerOptionText__c == questionResponse.TextValue__c) {
                            questionResponse.IsCorrect__c = true;
                            break;
                        }
                    }
                }/*else if (question.Type__c == 'Fill in the Blanks') {
                    questionResponse.IsCorrect__c = question.AnswerText__c == questionResponse.TextValue__c;
                }*/else if (question.Type__c == 'Matching Options') {

                    questionResponse.IsCorrect__c = true;
                    List<Answer__c> answers = existingQuestionResponses.get(questionResponse.Id).answers__r;
                    Map<Id,AnswerOption__c> correctAnswerIds = new Map<Id,AnswerOption__c>();
                    //verifies if the number of answers are the same as the correct answer options
                    if (answers.size() == questionsMap.get(questionResponse.Question__c).AnswerOptions__r.size()) {
                        correctAnswerIds = new Map<Id,AnswerOption__c>(questionsMap.get(questionResponse.Question__c).AnswerOptions__r);

                        //loop the answers and verify that all of them are related to correct answer options
                        for(Answer__c answer : existingQuestionResponses.get(questionResponse.Id).answers__r) {
                            if (!correctAnswerIds.containsKey(answer.AnswerOption__c)) {
                                questionResponse.IsCorrect__c = false;
                                break;
                            //If answer corresponds to a correct answer option, verifies if the match is correct
                            } else if(answer.TextValue__c != correctAnswerIds.get(answer.AnswerOption__c).MatchingText__c) {
                                questionResponse.IsCorrect__c = false;
                                break;
                            }
                        }                      
                    } else {
                        questionResponse.IsCorrect__c = false;
                    }
                }

                if(questionResponse.IsCorrect__c && correctKeys.contains(questionResponse.ExternalKey__c)){
                    mapErrors.put(questionResponse.Id, Label.QuestionAlreadyAnsweredCorrectly);
                    //questionResponse.addError('This question was already answered correct.');
                }else{
                    if(questionResponse.IsCorrect__c){
                        correctKeys.add(questionResponse.ExternalKey__c);                        
                    }
                
                    incorrectWeight = question.IncorrectWeight__c;
                    questionWeight = question.CorrectWeight__c;
                    penaltyPerQuestion = question.PenaltyPerAttempt__c;
                    isCorrectInt = questionResponse.IsCorrect__c ? 1 : 0;
                    questionRespAttempts = Integer.valueOf(questionResponse.NumberOfAttempt__c);
                    penaltyMode = question.Module__r.PenaltyMode__c;

                    questionResponse.PartialGradeValue__c =
                        penaltyMode == 'Percent Decrease' ?
                                isCorrectInt * (questionWeight * Math.pow((1 - penaltyPerQuestion / 100),questionRespAttempts-1)) :
                                penaltyMode == 'Negative Weight' ?
                                    (isCorrectInt * questionWeight + (1 - isCorrectInt) * incorrectWeight) :
                                    isCorrectInt * questionWeight;
                }
            }
        }
        return mapErrors;
    }
}