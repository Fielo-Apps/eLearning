/**
 * @brief      Apex API ment for extension packages and/or customization by our patrners
 * @details    SECURITY REVIEW: Due to some of our customers business processes we had to remove the with sharing keyword
 */
global class ModuleService {
	
	private static Map<String,Schema.SObjectField> moduleFieldsMap {get{
		if (moduleFieldsMap == null) {
			moduleFieldsMap = Schema.SObjectType.Module__c.fields.getMap();
		}
		return moduleFieldsMap;
	} set;}

	private static Map<String,Schema.SObjectField> moduleResponseFieldsMap {get{
		if (moduleResponseFieldsMap == null) {
			moduleResponseFieldsMap = Schema.SObjectType.ModuleResponse__c.fields.getMap();
		}
		return moduleResponseFieldsMap;
	} set;}

	private static Map<String,Schema.SObjectField> questionFieldsMap {get{
		if (questionFieldsMap == null) {
			questionFieldsMap = Schema.SObjectType.Question__c.fields.getMap();
		}
		return questionFieldsMap;
	} set;}

	private static Map<String,Schema.SObjectField> questionResponseFieldsMap {get{
		if (questionResponseFieldsMap == null) {
			questionResponseFieldsMap = Schema.SObjectType.QuestionResponse__c.fields.getMap();
		}
		return questionResponseFieldsMap;
	} set;}

	private static Map<String,Schema.SObjectField> answerOptionFieldsMap {get{
		if (answerOptionFieldsMap == null) {
			answerOptionFieldsMap = Schema.SObjectType.AnswerOption__c.fields.getMap();
		}
		return answerOptionFieldsMap;
	} set;}

	private static Map<String,Schema.SObjectField> answerFieldsMap {get{
		if (answerFieldsMap == null) {
			answerFieldsMap = Schema.SObjectType.AnswerOption__c.fields.getMap();
		}
		return answerFieldsMap;
	} set;}

	global class ModuleWrapper{
		global Module__c module {get; private set;}
		global ModuleResponse__c moduleResponse {get; private set;}
		global List<Question__c> questions {get; private set;}

		public ModuleWrapper(Module__c module, ModuleResponse__c moduleResponse, List<Question__c> questions){
			this.module = module;
			this.moduleResponse = moduleResponse;
			this.questions = questions;
		}
	}

	//Take module
	global static ModuleWrapper takeModule(Id moduleId, Id memberId, Set<String> fieldsModule, Set<String> fieldsQuestion, Set<String> fieldsAnswerOption) {
		
		SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{ModuleResponse__c.SObjectType,QuestionResponse__c.SObjectType});
		ModuleResponse__c moduleResponse;

		try{
			if( Schema.sObjectType.ModuleResponse__c.isAccessible() && Schema.sObjectType.QuestionResponse__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.Module__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.Member__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.NumberOfAttempt__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.IsSubmitted__c.isAccessible()){
        		moduleResponse = [SELECT Module__c, Member__c, NumberOfAttempt__c, (SELECT Id FROM QuestionResponses__r) FROM ModuleResponse__c WHERE Module__c =: moduleId AND Member__c =: memberId AND IsSubmitted__c = false];
			} else {
            	throw new FieloPLT.FieloException(Label.CannotAccessRecords);
           	}
			if( Schema.sObjectType.ModuleResponse__c.fields.Date__c.isCreateable() && Schema.sObjectType.ModuleResponse__c.fields.Date__c.isUpdateable()){
				moduleResponse.Date__c = System.today();
			}
			if( Schema.sObjectType.ModuleResponse__c.fields.NumberOfAttempt__c.isCreateable() && Schema.sObjectType.ModuleResponse__c.fields.NumberOfAttempt__c.isUpdateable()){
				moduleResponse.NumberOfAttempt__c++;
			}
			if( Schema.sObjectType.ModuleResponse__c.fields.IsApproved__c.isCreateable() && Schema.sObjectType.ModuleResponse__c.fields.IsApproved__c.isUpdateable()){
				moduleResponse.IsApproved__c = false;
			}
			if( Schema.sObjectType.ModuleResponse__c.fields.CorrectQuestions__c.isCreateable() && Schema.sObjectType.ModuleResponse__c.fields.CorrectQuestions__c.isUpdateable()){
				moduleResponse.CorrectQuestions__c = 0;
			}
			if( Schema.sObjectType.ModuleResponse__c.fields.IncorrectQuestions__c.isCreateable() && Schema.sObjectType.ModuleResponse__c.fields.IncorrectQuestions__c.isUpdateable()){
				moduleResponse.IncorrectQuestions__c = 0;
			}
			if( Schema.sObjectType.ModuleResponse__c.fields.TotalQuestions__c.isCreateable() && Schema.sObjectType.ModuleResponse__c.fields.TotalQuestions__c.isUpdateable()){
				moduleResponse.TotalQuestions__c = 0;
			}
			
			List<QuestionResponse__c> questionResponsesToDelete = new List<QuestionResponse__c>();
			for(QuestionResponse__c q : moduleResponse.QuestionResponses__r) {
				questionResponsesToDelete.add(new QuestionResponse__c(Id=q.Id));
			}
			uow.registerDeleted(questionResponsesToDelete);
			uow.registerDirty(moduleResponse);
		}catch(Exception e){
			moduleResponse = new ModuleResponse__c(Module__c = moduleId);
			if( Schema.sObjectType.ModuleResponse__c.fields.TotalQuestions__c.isCreateable() && Schema.sObjectType.ModuleResponse__c.fields.TotalQuestions__c.isUpdateable()){
				moduleResponse.Member__c = memberId;
			}
			uow.registerNew(moduleResponse);
		}

         if(Schema.sObjectType.QuestionResponse__c.isDeletable() && Schema.sObjectType.ModuleResponse__c.isUpdateable() && Schema.sObjectType.ModuleResponse__c.isCreateable() ){
            uow.commitWork();
          }else{
            throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
          }
		

		Set<String> fieldsModuleClone = new Set<String>(fieldsModule);
		fieldsModuleClone.add('FieloELR__QuestionPool__c');
		String moduleQuery = 'SELECT ' + String.join(new List<String>(fieldsModuleClone), ',');
		moduleQuery += ' FROM Module__c WHERE Id =: moduleId ';

		Module__c module;

		// SR: CRUD Check
		if(Schema.sObjectType.Module__c.isAccessible()){
			// SR: FLS Check
        	for (String f : fieldsModuleClone) {
				if ( moduleFieldsMap.containsKey(f.trim()) && !moduleFieldsMap.get(f.trim()).getDescribe().isAccessible() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', f.trim()}));
				}
			}

			module = Database.query(moduleQuery);
		}else{
            throw new FieloPLT.FieloException(Label.CannotAccessRecords);
        }

		Set<String> fieldsQuestionClone = new Set<String>();
		String questionQuery = 'SELECT ';

		
		if(fieldsQuestion != null) {
			fieldsQuestionClone.addAll(fieldsQuestion);
			
		}
		fieldsQuestionClone.add('FieloELR__Type__c');
			

		if(!fieldsQuestionClone.isEmpty()){
			questionQuery += String.join(new List<String>(fieldsQuestionClone), ',');
	
		}
		Set<String> fieldsAnswerOptionClone;
		if(fieldsAnswerOption != null){
			fieldsAnswerOptionClone = new Set<String>(fieldsAnswerOption);
			fieldsAnswerOptionClone.add('FieloELR__IsCorrect__c');
			if(!fieldsQuestionClone.isEmpty()){
				questionQuery += ',';
			}
			questionQuery += ' (SELECT ' + String.join(new List<String>(fieldsAnswerOptionClone), ',') + ' FROM AnswerOptions__r ORDER BY OrderFormula__c)';
			questionQuery += ' FROM Question__c WHERE Module__c =: moduleId ORDER BY OrderFormula__c';
			
		
			if(module.QuestionPool__c != null){
				questionQuery += ' LIMIT ' + module.QuestionPool__c;
			}
		}
		
		system.debug(questionQuery);	
		List<Question__c> questions ;

		if(fieldsAnswerOption != null){
			Integer currentIndex;
	    	string currentMatchingText;
	    	Integer randomIndex;
			
			// SR: CRUD Check
			if(Schema.sObjectType.Question__c.isAccessible()){
				// SR: FLS Check
				for (String f : fieldsQuestionClone) {
					if ( questionFieldsMap.containsKey(f.trim()) && !questionFieldsMap.get(f.trim()).getDescribe().isAccessible() ) {
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Question__c', f.trim()}));
					}
				}
				// SR: FLS Check
				for (String f : fieldsAnswerOptionClone) {
					if ( answerOptionFieldsMap.containsKey(f.trim()) && !answerOptionFieldsMap.get(f.trim()).getDescribe().isAccessible() ) {
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'AnswerOption__c', f.trim()}));
					}
				}
				questions = Database.query(questionQuery);
			}else{
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Question__c'}));
			}
			
			for(Question__c q : questions){
				// Shuffle Answer Options Matching Text
				if(q.Type__c == 'Matching Options'){
					currentIndex = q.AnswerOptions__r.size();
					while (currentIndex != 0) {
			    		randomIndex = Math.floor(Math.random() * currentIndex).intValue();
			      		currentIndex -= 1;
			      		currentMatchingText = q.AnswerOptions__r.get(currentIndex).MatchingText__c;
			      		q.AnswerOptions__r.get(currentIndex).MatchingText__c = q.AnswerOptions__r.get(randomIndex).MatchingText__c;
			      		q.AnswerOptions__r.get(randomIndex).MatchingText__c = currentMatchingText;
			    	}
				}
			}
		}

		return new ModuleWrapper(module, moduleResponse, questions);
	}

	global static ModuleResponse__c submitModuleResponse (ModuleResponse__c moduleResponse){
		return submitModuleResponse (moduleResponse, null);
	}

	global static ModuleResponse__c submitModuleResponse (ModuleResponse__c moduleResponse, List<QuestionService.QuestionResponseWrapper> questionWrappers){
		SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SobjectType>{QuestionResponse__c.SObjectType, Answer__c.SObjectType, ModuleResponse__c.SObjectType});
		if(questionWrappers != null){
			for(QuestionService.QuestionResponseWrapper qw : questionWrappers){
				uow.registerNew(qw.questionResponse, QuestionResponse__c.ModuleResponse__c, moduleResponse);
				for(Answer__c answer : qw.answers){
					uow.registerNew(answer, Answer__c.QuestionResponse__c, qw.questionResponse);
				}
			}
		}

		SavePoint sp = Database.setSavePoint();
		if( Schema.sObjectType.ModuleResponse__c.fields.IsSubmitted__c.isCreateable() && Schema.sObjectType.ModuleResponse__c.fields.IsSubmitted__c.isUpdateable()){
			moduleResponse.IsSubmitted__c = true;
		}
		uow.registerDirty(moduleResponse);
		try{
			if( !Schema.sObjectType.ModuleResponse__c.isCreateable() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_insertable, new List<String>{'ModuleResponse__c'}));
			}
			if( !Schema.sObjectType.ModuleResponse__c.isUpdateable() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'ModuleResponse__c'}));
			}
			if( !Schema.sObjectType.QuestionResponse__c.isCreateable() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_insertable, new List<String>{'QuestionResponse__c'}));
			} 
			if( !Schema.sObjectType.QuestionResponse__c.isUpdateable() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'QuestionResponse__c'}));
			}
			if( !Schema.sObjectType.Answer__c.isCreateable() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_insertable, new List<String>{'Answer__c'}));
			}
			if( !Schema.sObjectType.Answer__c.isUpdateable() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'Answer__c'}));
			}
			
			uow.commitWork();
		} catch(Exception e) {
			Database.rollback(sp);
			throw e;
		}

		ModuleResponse__c module;

		if(Schema.sObjectType.ModuleResponse__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.Member__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.Module__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.IsSubmitted__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.IsApproved__c.isAccessible() && Schema.sObjectType.ModuleResponse__c.fields.GradePercent__c.isAccessible() ){
			 module = [SELECT Id, Name, Member__c, Module__c, IsSubmitted__c, IsApproved__c, GradePercent__c FROM ModuleResponse__c WHERE Id =: moduleResponse.Id limit 1];
		} else {
            throw new FieloPLT.FieloException(Label.CannotAccessRecords);
        }
		return module;
	}

	global class ModuleResponseResult{
		global ModuleResponse__c moduleResponse {get; private set;}
		global List<QuestionService.QuestionResponseResult> questions {get; private set;}

		public ModuleResponseResult(ModuleResponse__c moduleResponse){
			this.moduleResponse = moduleResponse;
			this.questions = new List<QuestionService.QuestionResponseResult>();
		}

		public void addQuestion(QuestionService.QuestionResponseResult qWrapper){
			this.questions.add(qWrapper);
		}
	}
	
	global static ModuleResponseResult getModuleResponse(Id moduleResponseId,
									  Set<String> fieldsModuleResponse,
									  Set<String> fieldsQuestion,
									  Set<String> fieldsAnswerOption) {
		Set<String> fieldsModuleResponseClone = new Set<String>(fieldsModuleResponse);
		fieldsModuleResponseClone.add('FieloELR__Module__r.FieloELR__AttemptsAllowed__c');
		fieldsModuleResponseClone.add('FieloELR__NumberOfAttempt__c');
		fieldsModuleResponseClone.add('FieloELR__IsApproved__c');
		String moduleResponseQuery = 'SELECT ' + String.join(new List<String>(fieldsModuleResponseClone), ',');
		moduleResponseQuery += ' FROM ModuleResponse__c WHERE Id =: moduleResponseId ';

		ModuleResponse__c moduleResponse;

		// SR: CRUD Check
		if(Schema.sObjectType.ModuleResponse__c.isAccessible()) {
			// SR: FLS Check
			for (String f : fieldsModuleResponseClone) {
				if ( moduleResponseFieldsMap.containsKey(f.trim()) && !moduleResponseFieldsMap.get(f.trim()).getDescribe().isAccessible() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<string>{'ModuleResponse__c', f.trim()}));
				}
			}
			if ( !Schema.sObjectType.Module__c.fields.AttemptsAllowed__c.isAccessible() ) {
				throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', 'AttemptsAllowed__c'}));
			}

			moduleResponse = Database.query(moduleResponseQuery);
		} else {
			throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'ModuleResponse__c'}));
        }

		ModuleResponseResult moduleResponseWrapper = new ModuleResponseResult(moduleResponse);

		if(fieldsQuestion != null){
			Set<String> fieldsQuestionResponse = new Set<String>{'Question__c','TextValue__c','IsCorrect__c','PartialGradeValue__c'};
			String questionResponseQuery = 'SELECT ' + String.join(new List<String>(fieldsQuestionResponse), ',');
			Set<String> fieldsAnswer = new Set<String>{'AnswerOption__c','TextValue__c'};
			questionResponseQuery += ' ,(SELECT ' + String.join(new List<String>(fieldsAnswer), ',') + ' FROM Answers__r ORDER BY AnswerOption__r.Order__c)';
			questionResponseQuery += ' FROM QuestionResponse__c WHERE ModuleResponse__c =: moduleResponseId ORDER BY NumberOfAttempt__c';
			List<QuestionResponse__c> questionResponses;

			// SR: CRUD Check
			if(Schema.sObjectType.QuestionResponse__c.isAccessible()){
				// SR: FLS Check
				fieldsQuestionResponse.add('FieloELR__ModuleResponse__c');
				fieldsQuestionResponse.add('FieloELR__NumberOfAttempt__c');
				for (String f : fieldsQuestionResponse) {
					if ( questionResponseFieldsMap.containsKey(f.trim()) && !questionResponseFieldsMap.get(f.trim()).getDescribe().isAccessible() ) {
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<string>{'QuestionResponse__c', f.trim()}));
					}
				}
				for (String f : fieldsAnswer) {
					if ( answerFieldsMap.containsKey(f.trim()) && !answerFieldsMap.get(f.trim()).getDescribe().isAccessible() ) {
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<string>{'Answer__c', f.trim()}));
					}
				}

				questionResponses = Database.query(questionResponseQuery);
			} else {
            	throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'QuestionResponse__c'}));
          	}

			Map<Id,List<QuestionResponse__c>> responsesByQuestion = new Map<Id,List<QuestionResponse__c>>();
			for(QuestionResponse__c qr : questionResponses){
				if(responsesByQuestion.containsKey(qr.Question__c)){
					responsesByQuestion.get(qr.Question__c).add(qr);
				}else{
					responsesByQuestion.put(qr.Question__c, new List<QuestionResponse__c>{qr});
				}
			}

			
			Set<String> fieldsQuestionClone = new Set<String>(fieldsQuestion);
			fieldsQuestionClone.add('FieloELR__Type__c');
			fieldsQuestionClone.add('FieloELR__Module__r.FieloELR__PenaltyMode__c');
			String questionQuery = 'SELECT ' + String.join(new List<String>(fieldsQuestionClone), ',');
			
			Set<String> fieldsAnswerOptionClone = new Set<String>(fieldsAnswerOption);
			fieldsAnswerOption.add('FieloELR__IsCorrect__c');
			fieldsAnswerOption.add('FieloELR__AnswerOptionText__c');
			questionQuery += ' ,(SELECT ' + String.join(new List<String>(fieldsAnswerOption), ',') + ' FROM AnswerOptions__r ORDER BY Order__c)';
			Set<Id> questionIds = responsesByQuestion.keySet();
			questionQuery += ' FROM Question__c WHERE Id in : questionIds ORDER BY Order__c';

			Boolean showDetailedAnswers;

			// SR: CRUD Check
			if(Schema.sObjectType.Question__c.isAccessible()){
				// SR: FLS Check
				fieldsQuestionClone.add('FieloELR__Order__c');
				fieldsAnswerOption.add('FieloELR__Order__c');
				for (String f : fieldsQuestionClone) {
					if ( questionFieldsMap.containsKey(f.trim()) && !questionFieldsMap.get(f.trim()).getDescribe().isAccessible() ) {
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<string>{'Question__c', f.trim()}));
					}
				}
				for (String f : fieldsAnswerOption) {
					if ( answerOptionFieldsMap.containsKey(f.trim()) && !answerOptionFieldsMap.get(f.trim()).getDescribe().isAccessible() ) {
						throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<string>{'AnswerOption__c', f.trim()}));
					}
				}
				if ( !Schema.sObjectType.Module__c.fields.PenaltyMode__c.isAccessible() ) {
					throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c', 'PenaltyMode__c'}));
				}

				for(Question__c question : Database.query(questionQuery)){
					showDetailedAnswers =
						responsesByQuestion.get(question.Id)[responsesByQuestion.get(question.Id).size()-1].IsCorrect__c;
					moduleResponseWrapper.addQuestion(new QuestionService.QuestionResponseResult(question, responsesByQuestion.get(question.Id), showDetailedAnswers));
				}
			} else {
            	throw new FieloPLT.FieloException(Label.CannotAccessRecords);
          	}
		}
		return moduleResponseWrapper;
	}

}