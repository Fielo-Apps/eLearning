public with sharing class ModuleActionsController {
	@AuraEnabled
	public static String takeModule(FieloPLT__Member__c member, Id moduleId) {
		try{
			Id memberId = member.Id;
			Id programId = member.FieloPLT__Program__c;

			ModuleService.ModuleWrapper moduleWrapper = ModuleService.takeModule(
				moduleId,
				memberId,
				new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c', 'FieloELR__QuestionDisplayMode__c'},
				new Set<String> {'Name', 'FieloELR__QuestionText__c', 'FieloELR__Order__c'},
				new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c'}
			);
			return JSON.serialize(moduleWrapper);
		} catch(DMLException e) {
           	throw new AuraHandledException(e.getDMLMessage(0));
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
	}
}