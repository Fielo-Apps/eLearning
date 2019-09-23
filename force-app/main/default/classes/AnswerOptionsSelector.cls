public class AnswerOptionsSelector extends SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
                AnswerOption__c.Id,
                AnswerOption__c.Name,
                AnswerOption__c.IsCorrect__c,
                AnswerOption__c.Question__c
            };
    }

    public AnswerOptionsSelector(Set<String> fields){
        super(fields);
    }

    public AnswerOptionsSelector(){
        super();
    }

    public Schema.SObjectType getSObjectType(){
        return AnswerOption__c.sObjectType;
    }

    public List<AnswerOption__c> selectById(Set<Id> answerOptionIds) {
        return (List<AnswerOption__c>) selectSObjectsById(answerOptionIds);
    }

    public List<AggregateResult> selectByQuestionGroupByQuestion(Set<Id> questionIds) {
        List<AggregateResult> listAggre;
        
        if ( Schema.sObjectType.AnswerOption__c.isAccessible() ) {
            if (Schema.sObjectType.AnswerOption__c.fields.Question__c.isAccessible() && Schema.sObjectType.AnswerOption__c.fields.Order__c.isAccessible()) {
                listAggre = [SELECT MAX(Order__c) order, Question__c FROM AnswerOption__c WHERE Question__c in : questionIds GROUP BY Question__c];
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'AnswerOption__c', 'Question__c,Order__c'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'AnswerOption__c'}));
        }
        return listAggre;
                
    }
}