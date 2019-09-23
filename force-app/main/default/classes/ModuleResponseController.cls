public with sharing class ModuleResponseController {
     @auraEnabled
    public static String getModuleResponse(String moduleResponseId, List<String> fieldsModuleResponse){
        try{
            Set<String> fieldsModuleResponseSet = new Set<String>(fieldsModuleResponse);
            List<String> defaultModuleResponseFields = new List<String> {'Name','FieloELR__GradeValue__c', 'FieloELR__Module__r.Name'};
            for(String moduleResponseField : defaultModuleResponseFields){
                if(!fieldsModuleResponseSet.contains(moduleResponseField)){                    
                    fieldsModuleResponseSet.add(moduleResponseField);
                }
            }            
            Set<String> fieldsQuestion = new Set<String>{'Name','FieloELR__QuestionText__c','FieloELR__Type__c'}; 
            Set<String> fieldsAnswerOption = new Set<String>{'Name','FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c'}; 
            FieloELR.ModuleService.ModuleResponseResult mrWrapper = FieloELR.ModuleService.getModuleResponse(moduleResponseId, fieldsModuleResponseSet, fieldsQuestion, fieldsAnswerOption);
            return JSON.serialize(mrWrapper);              
   } catch(DMLException e) {
           throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e){
             throw new AuraHandledException(e.getMessage());
        }     
    }

    @auraEnabled
    public static map<String, String> getFieldLabels(){
        map<String, String> mapFieldLabels = new map<String, String>();

        for(Schema.SObjectField sfield: ModuleResponse__c.sObjectType.getDescribe().fields.getMap().Values()){
            Schema.Describefieldresult dfield = sfield.getDescribe();
            mapFieldLabels.put(dfield.getName(), dfield.getLabel());
        }

        return mapFieldLabels;
    }
}