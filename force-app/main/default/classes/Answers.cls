public class Answers extends SObjectDomain {

    public static Boolean validateAdminFields = true;

	public Answers(List<Answer__c> records) {
        super(records);
    }

    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<Answer__c> sObjectList) {
            //If has Admin Permission allow "validateAdminFields"
            if(FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()) != null && FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()).FieloPLT__To__c >= system.now()){
                validateAdminFields = false;
            }        	
            return new Answers(sObjectList);
        }
    }

    public override void onBeforeInsert() {
    	validateRecords((List<Answer__c>) records);
 		setKeys((List<Answer__c>) records);
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
		validateRecords((List<Answer__c>) records);
    }

    public override void onBeforeDelete() {
		validateRecords((List<Answer__c>) records);
	}

	private void validateRecords(List<Answer__c> answers) {
	    
		if(validateAdminFields) {
		    Set<Id> questionResponses = new Set<Id>();
		    for(Answer__c answer : answers) {
				if (Trigger.isUpdate) {
					answer.addError(Label.AnswerCannotBeEdited);
				}

				questionResponses.add(answer.QuestionResponse__c);
		    }
		    Map<Id, QuestionResponse__c> submittedQuestionResponsesMap = new Map<Id, QuestionResponse__c>(
		    												new QuestionResponsesSelector(new Set<String> {'Id', 'IsSubmitted__c'}).selectByKeyAndSubmitted(questionResponses)); 

		    for(Answer__c answer : answers) {
				// If the related Question Response was already submitted, the answer response cannot be deleted or updated (Only with Admin Permissions) or create new ones.    																		    	
		    	if(submittedQuestionResponsesMap.containsKey(answer.QuestionResponse__c)) {
		        	answer.addError(Label.ValidateAnswerQuestionResponses);
		    	}   
		    }
		}

	}

    private void setKeys(List<Answer__c> records) {
    	for(Answer__c answer : records) {
			if(answer.QuestionResponse__c != null && answer.AnswerOption__c != null) {
				answer.ExternalKey__c = String.valueOf(answer.QuestionResponse__c) + String.valueOf(answer.AnswerOption__c);
    		}
    	}
    }

}