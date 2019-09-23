public with sharing class TakeModuleController {

    @auraEnabled
    public static String memberTakeModule(Id memberId, Id moduleId){        
        try{
            Set<String> fieldsModule = new Set<String>{'Name','FieloELR__Description__c', 'FieloELR__ApprovalGrade__c'}; 
            Set<String> fieldsQuestion = new Set<String>{'FieloELR__QuestionText__c','FieloELR__Type__c'}; 
            Set<String> fieldsAnswerOption = new Set<String>{'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c'}; 
            FieloELR.ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(moduleId, memberId, fieldsModule, fieldsQuestion, fieldsAnswerOption);                               
            return JSON.serialize(moduleWrapper);              
   } catch(DMLException e) {
          throw new AuraHandledException(e.getDMLMessage(0));

        } catch(Exception e){
          throw new AuraHandledException(e.getMessage());
        }     
    }
}