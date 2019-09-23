public with sharing class QuizController {

    @AuraEnabled
    public static String submitQuestion(String questionResponseWrapper) {
        try{
            QuestionService.QuestionResponseWrapper qrw = (QuestionService.QuestionResponseWrapper) JSON.deserializeStrict(questionResponseWrapper, QuestionService.QuestionResponseWrapper.class);
			return JSON.serialize(QuestionService.submitQuestion(qrw));
		} catch(DMLException e) {
           	throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String submitModuleResponse(FieloELR__ModuleResponse__c moduleResponse) {
        try{
			return JSON.serialize(ModuleService.submitModuleResponse(moduleResponse));
		} catch(DMLException e) {
           	throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String submitModuleAndQuestionResponses(ModuleResponse__c moduleResponse, String questionWrappers) {
        try{
            List<QuestionService.QuestionResponseWrapper> qrws = (List<QuestionService.QuestionResponseWrapper>) JSON.deserializeStrict(questionWrappers, List<QuestionService.QuestionResponseWrapper>.class);
			return JSON.serialize(ModuleService.submitModuleResponse(moduleResponse, qrws));
		} catch(DMLException e) {
           	throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}