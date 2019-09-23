public class Questions extends SObjectDomain {

	public static Boolean validateAdminFields = true;
	public static Boolean isDelete = false;

	public Questions(List<Question__c> records) {
        super(records);
    }

    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<Question__c> sObjectList) {
            //If has Admin Permission allow "validateAdminFields"
            if(FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()) != null && FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()).FieloPLT__To__c >= system.now()){
                validateAdminFields = false;
            }

            return new Questions(sObjectList);
        }
    }

    public override void onApplyDefaults() {
    	// If both IncorrectWeight or PenaltyPerAttempt are null, replace them by 0 (zero)
    	checkNullValues(records);

    	// If Order is null, calculate it automatically
		Set<Id> moduleIds = new Set<Id>();
		for(Question__c question : (List<Question__c>)records){
			if(question.Order__c == null) {
				moduleIds.add(question.Module__c);
			}
		}
        
        if(!moduleIds.isEmpty()){
	        List<AggregateResult> aggResult = new QuestionsSelector().selectByModuleGroupByModule(moduleIds);
	        Map<String,Decimal> maxNumbByModule = new Map<String,Decimal>();
	        for(AggregateResult mr : aggResult){
	            maxNumbByModule.put((String)mr.get('FieloELR__Module__c'), (Decimal)mr.get('order'));
	        }
	        
	        for(Question__c question : (List<Question__c>)records){
				if(question.Order__c == null) {
		            if(maxNumbByModule.containsKey(question.Module__c)){
		                Decimal maxOrder = maxNumbByModule.get(question.Module__c);
		                question.Order__c = ++maxOrder;
		                maxNumbByModule.put(question.Module__c, maxOrder);
		            }else{
		                question.Order__c = 1;
		                maxNumbByModule.put(question.Module__c, 1);
		            }
		        }
	        }
	    }	    	
    }

    public override void onValidate(){
    	// If the module is active, questions cannot be deleted, updated or added.
    	checkModule(records, null);
    }

    public override void onBeforeInsert() {
		// Do some module related actions upon insert
		onInsertModuleRelatedActions(records);

		// If the question is updated or inserted and the weigth is null or the question pool is != null then the weight will be 1 
    	updateWeights(records);
    }

    public override void onValidate(Map<Id,SObject> existingRecords){
		// If the module is active, questions cannot be deleted, updated or added.																		
		checkModule(records, (Map<Id,Question__c>)existingRecords);
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
		// If both IncorrectWeight or PenaltyPerAttempt are null, replace them by 0 (zero)
    	checkNullValues(records);

		// If the question is updated or inserted and the weigth is null or the question pool is != null then the weight will be 1 
    	updateWeights(records);
    }

	public override void onBeforeDelete() {
		isDelete = true;
		if(validateAdminFields && !Modules.isDelete){
			// If the module is active, questions cannot be deleted, updated or added.																		
	    	checkModule(records, null);
	    }
    }

	public override void onAfterInsert() {
		//Update module counter
		updateModuleRollup(records, Trigger.isDelete);
	}

    public override void onAfterDelete() {
    	isDelete = true;
    	// Delete related answers upon question delete
    	deleteRelatedAnswers(records);

		//Update module counter
		updateModuleRollup(records, Trigger.isDelete);
    }

    private void updateWeights(List<Question__c> questions) {
	    Set<Id> modules = new Set<Id>();
	    for(Question__c question : questions) {
			modules.add(question.Module__c);
	    }

		Map<Id, Module__c> modulesMap = new Map<Id, Module__c>(new ModulesSelector(new Set<String> {'Id', 'QuestionPool__c'}).selectById(modules));

	    for(Question__c question : questions) {
	    	if(question.CorrectWeight__c == null || (modulesMap.containsKey(question.Module__c) && modulesMap.get(question.Module__c).QuestionPool__c != null)) {
	        	question.CorrectWeight__c = 1;             
	    	}
	    }
	}

	// Check the modules
    private void checkModule(List<Question__c> questions, Map<Id,Question__c> existingQuestions) {

	    Set<Id> modules = new Set<Id>();
	    for(Question__c question : questions) {
			modules.add(question.Module__c);
	    }

		Map<Id, Module__c> modulesMap = new Map<Id, Module__c>(new ModulesSelector(new Set<String> {'Id','IsActive__c'}).selectByIdHavingModuleResponses(modules));

		// If the module is active, questions cannot be deleted or added.
		//get PublicSettings field that check if Edit Courses is authorized
        FieloPLT__PublicSettings__c courseSettings = FieloPLT__PublicSettings__c.getInstance();
        Boolean editCourseSettings = courseSettings.EnableEditingWhileActive__c;
       
       //If the field is true, there is no check 
        if(editCourseSettings == false){															
		    for(Question__c question : questions) {
		    	if(modulesMap.containsKey(question.Module__c)) {
		    		if (modulesMap.get(question.Module__c).IsActive__c){
		    			if (Trigger.isInsert || Trigger.isDelete) {
		    				question.addError(Label.ValidateQuestionActiveModulesQuestions);
		    			}else{
		    				question.addError(Label.ActiveModuleQuestionNotEditable);
		    			}
		    		}else if (!modulesMap.get(question.Module__c).ModuleResponses__r.isEmpty()) {
			    		if (Trigger.isInsert || Trigger.isDelete) {
		    				question.addError(Label.ValidateQuestionActiveModulesQuestions);
		    			} else {
		    				Question__c oldQuestion = existingQuestions.get(question.Id);
	    					if(oldQuestion.CorrectWeight__c != question.CorrectWeight__c || 
		                    oldQuestion.IncorrectWeight__c != question.IncorrectWeight__c || 
		                    oldQuestion.PenaltyPerAttempt__c != question.PenaltyPerAttempt__c) {
		                    	question.addError(Label.QuestionReadOnlyFields);
			                }
		    			}
		    		}
		    	}
		    }
		}
    }

    // Set fields to zero if null
    private void checkNullValues(List<Question__c> questions) {
    	for (Question__c question: questions) {
			if( Schema.sObjectType.Question__c.fields.IncorrectWeight__c.isUpdateable() && Schema.sObjectType.Question__c.fields.IncorrectWeight__c.isCreateable() ){
    			question.IncorrectWeight__c = question.IncorrectWeight__c == null ? 0.0 : question.IncorrectWeight__c;
			}
			if( Schema.sObjectType.Question__c.fields.PenaltyPerAttempt__c.isUpdateable() && Schema.sObjectType.Question__c.fields.PenaltyPerAttempt__c.isCreateable() ){
    			question.PenaltyPerAttempt__c = question.PenaltyPerAttempt__c == null ? 0.0 : question.PenaltyPerAttempt__c;
			}
    	}
    }

    //Module related actions on Insert
    private void onInsertModuleRelatedActions(List<Question__c> questions) {

    	Set<Id> moduleIds = new Set<Id>();
	    for(Question__c question : questions) {
			moduleIds.add(question.Module__c);
	    }

		Map<Id, Module__c> modulesMap = new Map<Id, Module__c>(
			new ModulesSelector(new Set<String> {'Id','WeightedQuestions__c'}).selectById(moduleIds));

    	for (Question__c question: questions) {
			if( Schema.sObjectType.Question__c.fields.CorrectWeight__c.isUpdateable() && Schema.sObjectType.Question__c.fields.CorrectWeight__c.isCreateable() ){
				// If Module.WeightedQuestions is false, CorrectWeight = 1
				question.CorrectWeight__c = modulesMap.get(question.Module__c).WeightedQuestions__c ?
					question.CorrectWeight__c :
					1;
			}

    	}
    }

    private void deleteRelatedAnswers(List<Question__c> questions) {
    	Map<Id, Question__c> existingQuestions = new Map<Id, Question__c>(
    		new QuestionsSelector().selectByIdHavingAnswers(new Map<Id,Question__c>(questions).keySet()));

    	List<AnswerOption__c> existingAnswerOptions = new List<AnswerOption__c>();

    	for (Question__c question: questions) {
    		if(existingQuestions.get(question.Id).AnswerOptions__r.size()>0) {
    			existingAnswerOptions.addAll(existingQuestions.get(question.Id).AnswerOptions__r);
    		}
    	}

		if (!existingAnswerOptions.isEmpty()) {
			if( Schema.sObjectType.AnswerOption__c.isDeletable() ){	
				delete existingAnswerOptions;
			}else{
				throw new FieloPLT.FieloException(Label.CannotDeleteRecords);
			}
		}
    }

	private void updateModuleRollup(List<Question__c> questions, Boolean isDelete) {
		Set<Id> moduleIds = new Set<Id>();
	    for(Question__c question : questions) {
			moduleIds.add(question.Module__c);
	    }

		Map<Id, Module__c> modulesMap = new Map<Id, Module__c>(new ModulesSelector(new Set<String> {'Id','IsActive__c','NumberOfQuestions__c'}).selectByIdHavingModuleResponses(moduleIds));

		Map<Id, Module__c> updModulesMap = new Map<Id, Module__c>();

		for(Question__c question : questions) {
			if (!updModulesMap.containsKey(question.Module__c)) {
				Module__c m = new Module__c(Id = question.Module__c);
				if( Schema.sObjectType.Module__c.fields.NumberOfQuestions__c.isUpdateable() && Schema.sObjectType.Module__c.fields.NumberOfQuestions__c.isCreateable() ){
					m.NumberOfQuestions__c = modulesMap.get(question.Module__c).NumberOfQuestions__c != null ? modulesMap.get(question.Module__c).NumberOfQuestions__c : 0;
				}

				updModulesMap.put(question.Module__c, m);
			}
			if (isDelete) {
				if( Schema.sObjectType.Module__c.fields.NumberOfQuestions__c.isUpdateable() && Schema.sObjectType.Module__c.fields.NumberOfQuestions__c.isCreateable() ){
					updModulesMap.get(question.Module__c).NumberOfQuestions__c--;
				}
			} else {
				if( Schema.sObjectType.Module__c.fields.NumberOfQuestions__c.isUpdateable() && Schema.sObjectType.Module__c.fields.NumberOfQuestions__c.isCreateable() ){
					updModulesMap.get(question.Module__c).NumberOfQuestions__c++;
				}
			}
	    }
		
		if ( !updModulesMap.isEmpty() && Schema.sObjectType.Module__c.isUpdateable() ) {
			update updModulesMap.values();
		}
	}
}