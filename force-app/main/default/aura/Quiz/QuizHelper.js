({
    getNextQuestionComponent: function(component) {
        try{
            var questionComps = component.find('question-card');
            var questionComp;
            if (questionComps) {
                var currentQuestionIndex = component.get('v.currentQuestionIndex');
                if ( questionComps instanceof Array ) {
                    questionComp = questionComps[currentQuestionIndex];
                } else {
                    questionComp = questionComps;
                }
                return questionComp;
            } else {
                questionComp = component.find('unique-question-card');
                if ( questionComp instanceof Array ) {
                    questionComp = questionComp[0];
                }
                return questionComp;
            }
            return null;
        } catch(e) {
            console.log(e);
        }
    },
    getQuestionWrapper: function(component) {
        try{
            var moduleResponseWrapper = component.get('v.moduleResponseWrapper');
            var moduleResponseId = moduleResponseWrapper.moduleResponse.Id;
            var currentQuestion = component.get('v.currentQuestion');
            var questionComponent = this.getNextQuestionComponent(component);
            var questionResponseWrapper = {};
            var questionResponse = {};
            var answers;
            questionResponse.FieloELR__ModuleResponse__c = moduleResponseId;
            questionResponse.FieloELR__Question__c = currentQuestion.Id;
            
            //Get Answers
            questionComponent.getAnswers();
            
            if (currentQuestion.FieloELR__Type__c == 'Multiple Choice' ||
                currentQuestion.FieloELR__Type__c == 'Single Choice' ||
                currentQuestion.FieloELR__Type__c == 'Statement') {
                answers = questionComponent.get('v.answers');
            } else if (currentQuestion.FieloELR__Type__c == 'Short Answer') {
                questionResponse.FieloELR__TextValue__c = questionComponent.get('v.textValue');
                answers = [];
            } else if (currentQuestion.FieloELR__Type__c == 'Matching Options') {
                answers = questionComponent.get('v.answers');
            }
            
            var question = Object.assign({}, currentQuestion);
            
            delete question.FieloELR__AnswerOptions__r;
            
            questionResponseWrapper.questionResponse = questionResponse;
            questionResponseWrapper.answers = answers;
            questionResponseWrapper.question = question;
            
            return questionResponseWrapper;
        } catch(e) {
            console.log(e);
        }
    },
    showMessage: function(type, message) {
        try{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": message,
                "message": " ",
                "type": type
            });
            toastEvent.fire();    
        } catch(e) {
            console.log(e);
        }
    },
    submitQuestion: function(component, type) {
        try{
            var spinner = $A.get("e.c:ToggleSpinnerEvent");
            if (spinner) {
                spinner.setParam('show', true);
                spinner.fire();    
            }
            var moduleResponseWrapper = component.get('v.moduleResponseWrapper');
            var currentQuestionIndex = component.get('v.currentQuestionIndex');
            var questionResponseWrapper = this.getQuestionWrapper(component);
            var action = component.get('c.submitQuestion');
            action.setParams({
                'questionResponseWrapper': JSON.stringify(questionResponseWrapper)
            });
            action.setCallback(this, function(response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var correctQuestions = component.get('v.correctQuestions');
                    var incorrectQuestions = component.get('v.incorrectQuestions');
                    var noMoreAttemptsQuestions = component.get('v.noMoreAttemptsQuestions');
                    var submittedQuestions = component.get('v.submittedQuestions');
                    if (!correctQuestions) correctQuestions = [];
                    if (!incorrectQuestions) incorrectQuestions = [];
                    if (!noMoreAttemptsQuestions) noMoreAttemptsQuestions = [];
                    var questionResponseResult = JSON.parse(response.getReturnValue());
                    
                    if (questionResponseResult) {
                        if (questionResponseResult.questionResponse) {
                            if (questionResponseResult.questionResponse.FieloELR__IsCorrect__c == true) {
                                if (correctQuestions.indexOf(questionResponseResult.question.Id) == -1) {
                                    correctQuestions.push(questionResponseResult.question.Id);
                                }
                                if (type == 'question') {
                                    this.showMessage('success', $A.get('$Label.c.CorrectAnswer'));
                                    currentQuestionIndex++;
                                    if (currentQuestionIndex < moduleResponseWrapper.questions.length) {
                                        $A.enqueueAction(component.get('c.getNextQuestion'));
                                    } else {
                                        $A.enqueueAction(component.get('c.callSubmitModule'));
                                    }    
                                }
                            } else {
                                //question is wrong, try again
                                if (currentQuestionIndex < moduleResponseWrapper.questions.length) {
                                    if (questionResponseResult.canRepeatQuestion) {
                                        if (incorrectQuestions.indexOf(questionResponseResult.question.Id) == -1) {
                                            incorrectQuestions.push(questionResponseResult.question.Id);
                                        }
                                        if (type == 'question') {
                                            currentQuestionIndex--;
                                            component.set('v.currentQuestionIndex', currentQuestionIndex);
                                            this.showMessage('error', $A.get('$Label.c.WrongAnswer'));
                                            $A.enqueueAction(component.get('c.getNextQuestion'));
                                        }
                                    } else {
                                        if (noMoreAttemptsQuestions.indexOf(questionResponseResult.question.Id) == -1) {
                                            noMoreAttemptsQuestions.push(questionResponseResult.question.Id);
                                        }
                                        if (type == 'question') {
                                            this.showMessage('error', $A.get('$Label.c.MaximumAttempts'));
                                            currentQuestionIndex++;
                                            if (currentQuestionIndex < moduleResponseWrapper.questions.length) {
                                                $A.enqueueAction(component.get('c.getNextQuestion'));
                                            } else {
                                                $A.enqueueAction(component.get('c.callSubmitModule'));
                                            }
                                        }
                                    }
                                }
                            }
                            if (!submittedQuestions) {
                                submittedQuestions = [];
                            }
                            submittedQuestions.push(questionResponseResult.question.Id);
                        }
                        component.set('v.submittedQuestions', submittedQuestions);
                        component.set('v.correctQuestions', correctQuestions);
                        component.set('v.incorrectQuestions', incorrectQuestions);
                        component.set('v.noMoreAttemptsQuestions', noMoreAttemptsQuestions);
                        this.getQuestionStatus(component);
                        correctQuestions = component.get('v.correctQuestions');
                        incorrectQuestions = component.get('v.incorrectQuestions');
                        noMoreAttemptsQuestions = component.get('v.noMoreAttemptsQuestions');
                        
                        if (type == 'module') {
                            // Last Question
                            if (submittedQuestions.length == moduleResponseWrapper.questions.length) {
                                var submittedQuestionsSet = new Set(submittedQuestions);
                                this.checkModuleAndFinish(component);
                                if (incorrectQuestions.length > 0) {
                                    this.showMessage('error', $A.get('$Label.c.ReviewYourQuestions'));
                                    incorrectQuestions.forEach(function(id) {
                                        if (submittedQuestionsSet.has(id) != -1) {
                                            submittedQuestionsSet.delete(id);
                                        }
                                    });
                                    submittedQuestions = [];
                                    submittedQuestionsSet.forEach(id => submittedQuestions.push(id));
                                    component.set('v.submittedQuestions', submittedQuestions);
                                }
                                this.showResults(component);
                            }
                        }
                    }
                } else {
                    var errorMsg = response.getError()[0].message;
                    this.showMessage("error", errorMsg);
                }
                if(spinner){
                    spinner.setParam('show', false);
                    spinner.fire();
                }
            });
            $A.enqueueAction(action);
        } catch(e) {
            console.log(e);
        }
    },
    showResults: function(component) {
        try{
            var correctQuestions = component.get('v.correctQuestions');
            var incorrectQuestions = component.get('v.incorrectQuestions');
            var noMoreAttemptsQuestions = component.get('v.noMoreAttemptsQuestions');
            var questionComps = component.find('question-card');
            if (!questionComps.length) {
                questionComps = [questionComps];
            }
            var questionId;
            var status;
            
            console.log(JSON.stringify({
                '# questions': questionComps.length,
                'correctQuestions': correctQuestions,
                'incorrectQuestions': incorrectQuestions,
                'noMoreAttemptsQuestions': noMoreAttemptsQuestions
            }, null, 2));
            
            questionComps.forEach(function(cmp) {
                status = null;
                questionId = cmp.get('v.question').Id;
                if (correctQuestions.indexOf(questionId) != -1) {
                    status = 'passed';
                } else if (noMoreAttemptsQuestions.indexOf(questionId) != -1) {
                    status = 'attemptLimit';
                } else if (incorrectQuestions.indexOf(questionId) != -1) {
                    status = 'notpassed';
                }
                if (status) {
                    cmp.set('v.status', '');
                    cmp.set('v.status', status);
                    console.log(questionId + ' = ' + status);
                }
            });
        } catch(e) {
            console.log(e);
        }
    },
    getQuestionStatus: function(component) {
        try{
            var correctQuestions = component.get('v.correctQuestions');
            var incorrectQuestions = component.get('v.incorrectQuestions');
            var noMoreAttemptsQuestions = component.get('v.noMoreAttemptsQuestions');
            
            incorrectQuestions.forEach(function(id) {
                if (noMoreAttemptsQuestions.indexOf(id) != -1 || correctQuestions.indexOf(id) != -1) {
                    incorrectQuestions.splice(incorrectQuestions.indexOf(id), 1);
                }
            });
            component.set('v.correctQuestions', correctQuestions);
            component.get('v.incorrectQuestions', incorrectQuestions);
            component.get('v.noMoreAttemptsQuestions', noMoreAttemptsQuestions);
        } catch(e) {
            console.log(e);
        }
    },
    checkModuleAndFinish: function(component) {
        try{
            var incorrectQuestions = component.get('v.incorrectQuestions');
            var noMoreAttemptsQuestions = component.get('v.noMoreAttemptsQuestions');
            
            if (incorrectQuestions.length == 0) {
                $A.enqueueAction(component.get('c.callSubmitModule'));
                if (noMoreAttemptsQuestions.length > 0){
                    this.showMessage('error', $A.get('$Label.c.MaximumAttempts'));
                }
            }
        } catch(e) {
            console.log(e);
        }
    },
    refreshQuestionNumber: function(component) {
        try {
            component.set('v.showQuestionNumber', false);
            component.set('v.showQuestionNumber', true);
        } catch(e) {
            console.log(e);
        }
    }
})