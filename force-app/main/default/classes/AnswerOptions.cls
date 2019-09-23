public class AnswerOptions extends SObjectDomain {
    public static Boolean validateAdminFields = true;

    public  AnswerOptions(List<AnswerOption__c> records) {
        super(records);
    }

    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<AnswerOption__c> sObjectList) {
            return new AnswerOptions(sObjectList);
        }
    }

    public override void onApplyDefaults() {
        setDefaultOrder(records);                   
    }

    public override void onBeforeInsert() {
        validateAnswerOptions(records, true);
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        validateAnswerOptions(records, true);
        setDefaultOrder(records);
    }

    public override void onBeforeDelete() {
        if(!Questions.isDelete){
            validateAnswerOptions(records, false);
        }
    }

    private void setDefaultOrder(List<AnswerOption__c> answerOptions){
        // If Order is null, calculate it automatically
        Set<Id> questionIds = new Set<Id>();
        for(AnswerOption__c answerOption : answerOptions){
            if(answerOption.Order__c == null) {
                questionIds.add(answerOption.Question__c);
            }
        }
         
        if(!questionIds.isEmpty()){
            List<AggregateResult> aggResult = new AnswerOptionsSelector().selectByQuestionGroupByQuestion(questionIds);
            Map<String,Decimal> maxNumbByQuestion = new Map<String,Decimal>();
            for(AggregateResult mr : aggResult){
                maxNumbByQuestion.put((String)mr.get('FieloELR__Question__c'), (Decimal)mr.get('order'));
            }
            
            for(AnswerOption__c answerOption : answerOptions){
                if(answerOption.Order__c == null) {
                    if(maxNumbByQuestion.containsKey(answerOption.Question__c)){
                        Decimal maxOrder = maxNumbByQuestion.get(answerOption.Question__c);
                        answerOption.Order__c = ++maxOrder;
                        maxNumbByQuestion.put(answerOption.Question__c, maxOrder);
                    }else{
                        answerOption.Order__c = 1;
                        maxNumbByQuestion.put(answerOption.Question__c, 1);
                    }
                }
            }
        }
        
    }

    // General validations for a list of answers
    private void validateAnswerOptions(List<AnswerOption__c> answerOptions, Boolean validateFormat) {
        if (validateAdminFields) {
            Set<Id> questions = new Set<Id>();
            for(AnswerOption__c answerOption : answerOptions) {
                questions.add(answerOption.Question__c);
            }

            Map<Id, Question__c> questionsMap = new Map<Id, Question__c>(new QuestionsSelector(new Set<String> {'Id', 'Module__c', 'Module__r.IsActive__c', 'Type__c'}).selectByIdWithQuestionResponses(questions));

            Set<Id> moduleResponses = new Set<Id>();
            for (Question__c question: questionsMap.values()) {
                moduleResponses.add(question.Module__c);
            }

            Map<Id, Module__c> modulesMap = new Map<Id, Module__c>(new ModulesSelector().selectByIdHavingModuleResponses(moduleResponses));

            //get PublicSettings field that check if Edit Courses is authorized
            FieloPLT__PublicSettings__c courseSettings = FieloPLT__PublicSettings__c.getInstance();
            Boolean editCourseSettings = courseSettings.EnableEditingWhileActive__c;
        
            for(AnswerOption__c answerOption : answerOptions) {

                // If the module is active, answers cannot be deleted, updated or added. 
                //If the field is true, there is no check 
                if(editCourseSettings == false  ){                                                                           
                    if(questionsMap.get(answerOption.Question__c).Module__r.IsActive__c) {
                        answerOption.addError(Label.ValidateAnswerActiveModules);
                        continue;
                    }
                }

                // If the question type is "Matching Options", the format for Answer Text must be validated as {"xx":"yy"}
                if(validateFormat && questionsMap.get(answerOption.Question__c).Type__c == 'Matching Options') {   
                    if(String.isBlank(answerOption.MatchingText__c)) {
                        answerOption.addError(Label.ValidateMatchingText);             
                    }
                    if (!String.isBlank(answerOption.AnswerOptionText__c)) {
                        answerOption.IsCorrect__c = true;
                    } else {
                        answerOption.IsCorrect__c = false;
                    }               
                }

                if( !questionsMap.get(answerOption.Question__c).QuestionsResponses__r.isEmpty()){
                    if(Trigger.isDelete || ((Trigger.isInsert || Trigger.isUpdate) && editCourseSettings == false)) {
                        answerOption.addError(Label.CannotChangeAnsweredModules);
                    }
                }

                if (!modulesMap.get(questionsMap.get(answerOption.Question__c).Module__c).ModuleResponses__r.isEmpty()) {
                    if(Trigger.isDelete || ((Trigger.isInsert || Trigger.isUpdate) && editCourseSettings == false)) {
                        answerOption.addError(Label.CannotChangeAnsweredModules);
                    }
                }
            }
        }
    }
}