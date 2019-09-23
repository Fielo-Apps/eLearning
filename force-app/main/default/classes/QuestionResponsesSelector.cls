public class QuestionResponsesSelector extends SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
                QuestionResponse__c.Id,
                QuestionResponse__c.Name,
                QuestionResponse__c.ModuleResponse__c,
                QuestionResponse__c.IsCorrect__c,
                QuestionResponse__c.IsSubmitted__c,
                QuestionResponse__c.NumberOfAttempt__c,
                QuestionResponse__c.TextValue__c,
                QuestionResponse__c.ExternalKey__c,
                QuestionResponse__c.Question__c
            };
    }

    public QuestionResponsesSelector(Set<String> fields){
        super(fields);
    }

    public QuestionResponsesSelector(){
        super();
    }

    public Schema.SObjectType getSObjectType(){
        return QuestionResponse__c.sObjectType;
    }

    public List<QuestionResponse__c> selectById(Set<Id> questionResponseIds){
        return (List<QuestionResponse__c>) selectSObjectsById(questionResponseIds);
    }

    public List<QuestionResponse__c> selectByIdWithAnswers(Set<Id> questionResponseIds) {
    
    List<QuestionResponse__c> listQuestion;

     if(Schema.sObjectType.QuestionResponse__c.isAccessible() && Schema.sObjectType.Answer__c.isAccessible()){	
        listQuestion = (List<QuestionResponse__c>) Database.query(String.format(
                'SELECT {0} ' +
                  ', (SELECT Id, AnswerOption__c, TextValue__c, Name FROM Answers__r) ' +
                  'FROM {1} ' +
                  'WHERE Id IN :questionResponseIds ' +
                  'ORDER BY {2}',
                new List<String> {
                    getFieldListString(),
                    getSObjectName(),
                    getOrderBy() } ));

                     }else{
            throw new FieloPLT.FieloException(Label.CannotAccessRecords);
          }

          return listQuestion;
    }

    public List<QuestionResponse__c> selectByKeyAndCorrect(Set<String> keys) {
        List<QuestionResponse__c> listQuestion;

     if(Schema.sObjectType.QuestionResponse__c.isAccessible()){	

        listQuestion = (List<QuestionResponse__c>) Database.query(String.format(
                'SELECT {0} ' +
                  'FROM {1} ' +
                  'WHERE ExternalKey__c IN : keys AND IsCorrect__c = true ' +
                  'ORDER BY {2}',
                new List<String> {
                    getFieldListString(),
                    getSObjectName(),
                    getOrderBy() } ));

              }else{
            throw new FieloPLT.FieloException(Label.CannotAccessRecords);
          }

          return listQuestion;
    }

    public List<QuestionResponse__c> selectByKeyAndSubmitted(Set<Id> questionResponseIds) {
        List<QuestionResponse__c> listQuestion;

     if(Schema.sObjectType.QuestionResponse__c.isAccessible()){	

        listQuestion = (List<QuestionResponse__c>) Database.query(String.format(
                'SELECT {0} ' +
                  'FROM {1} ' +
                  'WHERE Id IN :questionResponseIds AND IsSubmitted__c = true ' +
                  'ORDER BY {2}',
                new List<String> {
                    getFieldListString(),
                    getSObjectName(),
                    getOrderBy() } ));

              }else{
            throw new FieloPLT.FieloException(Label.CannotAccessRecords);
          }

          return listQuestion;
    }

    public List<AggregateResult> selectByModuleResponseGroupByModuleResponse(Set<Id> moduleResponseIds) {
    
    List<AggregateResult> listQuestion;

     if(Schema.sObjectType.QuestionResponse__c.isAccessible()){	

        listQuestion = [SELECT ModuleResponse__r.Id ModuleResponse, Question__r.Id Question, 
                    MAX(ModuleResponse__r.Module__r.QuestionPool__c) QuestionPool
                FROM QuestionResponse__c 
                WHERE ModuleResponse__c in : moduleResponseIds 
                GROUP BY ModuleResponse__r.Id, Question__r.Id
                HAVING MAX(ModuleResponse__r.Module__r.QuestionPool__c) != null 
                ORDER BY ModuleResponse__r.Id, Question__r.Id];

                 }else{
            throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
          }

          return listQuestion;
    }    
}