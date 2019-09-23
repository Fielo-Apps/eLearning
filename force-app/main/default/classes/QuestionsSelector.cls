public class QuestionsSelector extends SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
                FieloELR__Question__c.Id,
                FieloELR__Question__c.Name,
                FieloELR__Question__c.FieloELR__IncorrectWeight__c,
                FieloELR__Question__c.FieloELR__Module__c,
                FieloELR__Question__c.FieloELR__Order__c,
                FieloELR__Question__c.FieloELR__PenaltyPerAttempt__c,
                FieloELR__Question__c.FieloELR__Type__c,
                FieloELR__Question__c.FieloELR__CorrectWeight__c
            };
    }

    public QuestionsSelector(Set<String> fields){
        super(fields);
    }

    public QuestionsSelector(){
        super();
    }

    public Schema.SObjectType getSObjectType(){
        return Question__c.sObjectType;
    }

    public List<Question__c> selectById(Set<Id> questionIds) {
        return (List<Question__c>) selectSObjectsById(questionIds);
    }

    public List<Question__c> selectByIdWithCorrectAnswers(Set<Id> questionIds) {
        List<Question__c> listQuestion;
        if( Schema.sObjectType.Question__c.isAccessible() && Schema.sObjectType.AnswerOption__c.isAccessible() ){
            listQuestion = (List<Question__c>) Database.query(String.format(
                'SELECT {0} ' +
                  ', (SELECT Id, Name, AnswerOptionText__c, MatchingText__c FROM AnswerOptions__r WHERE IsCorrect__c = true) ' +
                  'FROM {1} ' +
                  'WHERE Id IN :questionIds ' +
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

    public List<Question__c> selectByIdWithQuestionResponses(Set<Id> questionIds) {
        List<Question__c> listQuestion;

        if( Schema.sObjectType.Question__c.isAccessible() && Schema.sObjectType.QuestionResponse__c.isAccessible() ){
            listQuestion = (List<Question__c>) Database.query(String.format(
                'SELECT {0} ' +
                  ', (SELECT Id FROM QuestionsResponses__r LIMIT 1) ' +
                  'FROM {1} ' +
                  'WHERE Id IN :questionIds ' +
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

    public List<Question__c> selectByModuleHavingAnswers(Set<Id> moduleIds) {
      List<Question__c> listQuestion;

        if( Schema.sObjectType.Question__c.isAccessible() && Schema.sObjectType.AnswerOption__c.isAccessible() ){

        listQuestion = (List<Question__c>) Database.query(String.format(
                'SELECT {0} ' +
                  ', (SELECT Id, IsCorrect__c ' +
                  '   FROM AnswerOptions__r ' +
                  '   ORDER BY IsCorrect__c DESC ' +
                  '   LIMIT 2) ' +
                  'FROM {1} ' +
                  'WHERE Module__c IN :moduleIds ' +
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

    public List<Question__c> selectByIdHavingAnswers(Set<Id> questionIds) {
      List<Question__c> listQuestion;

        if( Schema.sObjectType.Question__c.isAccessible() && Schema.sObjectType.AnswerOption__c.isAccessible() ){

        listQuestion = (List<Question__c>) Database.query(String.format(
                'SELECT {0} ' +
                  ', (SELECT Id, IsCorrect__c ' +
                  '   FROM AnswerOptions__r) ' +
                  'FROM {1} ' +
                  'WHERE Id IN :questionIds ' +
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

    public List<Question__c> selectByIdWithActiveModule(Set<Id> questionIds) {
        List<Question__c> listQuestion;

     if(Schema.sObjectType.Question__c.isAccessible()){	

        listQuestion = (List<Question__c>) Database.query(String.format(
                'SELECT {0} ' +
                  'FROM {1} ' +
                  'WHERE Module__r.IsActive__c = true ' +
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

     public List<Question__c> selectByModule(Set<Id> moduleIds) {
      List<Question__c> listQuestion;

     if(Schema.sObjectType.Question__c.isAccessible()){	

        listQuestion = (List<Question__c>) Database.query(String.format(
                'SELECT {0} ' +
                  'FROM {1} ' +
                  'WHERE (Module__c IN :moduleIds) ' +
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

    public List<Question__c> selectByModuleHavingAnswerOptions(Set<Id> moduleIds, Set<String> answerOptionFields) {
      List<Question__c> listQuestion;

        if( Schema.sObjectType.Question__c.isAccessible() && Schema.sObjectType.AnswerOption__c.isAccessible() ){

        listQuestion = (List<Question__c>) Database.query(String.format('SELECT {0} ' +
                   ', (SELECT {1} FROM AnswerOptions__r) ' +
                  'FROM {2} ' +
                  'WHERE Module__c IN :moduleIds ' +
                  'ORDER BY {3}',
                new List<String> {
                    getFieldListString(),
                    String.join(new List<String>(answerOptionFields),','),
                    getSObjectName(),
                    getOrderBy() } ));

            }else{
            throw new FieloPLT.FieloException(Label.CannotAccessRecords);
          }

          return listQuestion;
    }

    public List<AggregateResult> selectByModuleGroupByModule(Set<Id> moduleIds) {
        List<AggregateResult> listQuestion;

        if(Schema.sObjectType.Question__c.isAccessible()){	
            listQuestion =  [SELECT MAX(Order__c) order, Module__c FROM Question__c WHERE Module__c in : moduleIds GROUP BY Module__c];
        }else{
            throw new FieloPLT.FieloException(Label.CannotAccessRecords);
        }

        return listQuestion;
    }
}