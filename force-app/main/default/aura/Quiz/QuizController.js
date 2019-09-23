({
    doInit : function(component, event, helper) {
        try{
            if (window.localStorage) {
                var moduleResponseWrapper = window.localStorage.getItem('currentModuleReponse');
                window.localStorage.removeItem('currentModuleReponse');
                var hideQuiz = false;
                if (moduleResponseWrapper) {
                    moduleResponseWrapper = JSON.parse(moduleResponseWrapper);
                    var recordId = component.get('v.recordId');
                    if (!recordId) {
                        recordId = component.get('v.overrideId');
                    }
                    if (moduleResponseWrapper.module && moduleResponseWrapper.moduleResponse) {
                        if (recordId == moduleResponseWrapper.module.Id || recordId == moduleResponseWrapper.moduleResponse.Id) {
                            component.set('v.moduleResponseWrapper', moduleResponseWrapper);
                            if (moduleResponseWrapper.questions) {
                                component.set('v.questions', moduleResponseWrapper.questions);
                                if (moduleResponseWrapper.questions.length > 0) {
                                    component.set('v.currentQuestion', moduleResponseWrapper.questions[0]);
                                    component.set('v.currentQuestionIndex', 0);
                                    helper.refreshQuestionNumber(component);
                                }
                            }
                            if (moduleResponseWrapper.module) {
                                component.set('v.module', moduleResponseWrapper.module);
                            }
                            if (moduleResponseWrapper.moduleResponse) {
                                component.set('v.moduleResponse', moduleResponseWrapper.moduleResponse);
                            }
                        } else {
                            component.set('v.hideQuiz', true);
                        }
                    } else {
                        component.set('v.hideQuiz', true);
                    }
                } else {
                    component.set('v.hideQuiz', true);
                }
            }    
        } catch(e) {
            console.log(e);
        }
    },
    toggleQuestionsContent: function(component, event, helper) {
        try{
            var questionComps = component.find('question-card');
            if (questionComps) {
                if (!(questionComps instanceof Array)) {
                    questionComps.toggle(component.get('v.showQuestionContent'));
                } else {
                    questionComps.forEach( function(cmp) {
                        cmp.toggle(component.get('v.showQuestionContent'));
                    }); 
                }
            } else {
                var questionComp = component.find('unique-question-card')
                if (questionComp instanceof Array) {
                    questionComp = questionComp[0];
                }
                if (questionComp) {
                	questionComp.toggle(component.get('v.showQuestionContent'));
                }
            }
            component.set('v.showQuestionContent', !component.get('v.showQuestionContent'));
        } catch(e) {
            console.log(e);
        }
    },
    getQuestionAnswers: function(component, event, helper) {
        try{
            var questionResponseWrapper = helper.getQuestionWrapper(component);
        } catch(e) {
            console.log(e);
        }
    },
    callSubmitQuestion: function(component, event, helper) {
        try{
            helper.submitQuestion(component, 'question');
        } catch(e) {
            console.log(e);
        }
    },
    callSubmitFullModule: function(component, event, helper) {
        try{
            var moduleResponseWrapper = component.get('v.moduleResponseWrapper');
            var size = moduleResponseWrapper.questions.length;
            var correctQuestions = component.get('v.correctQuestions');
            var incorrectQuestions = component.get('v.incorrectQuestions');
            var noMoreAttemptsQuestions = component.get('v.noMoreAttemptsQuestions');
            if (!correctQuestions) correctQuestions = [];
            if (!incorrectQuestions) incorrectQuestions = [];
            if (!noMoreAttemptsQuestions) noMoreAttemptsQuestions = [];
            
            var questionId;
            for(var index=0;index < size; index++) {
                questionId = moduleResponseWrapper.questions[index].Id;
                if (correctQuestions.indexOf(questionId) != -1 ||
                    noMoreAttemptsQuestions.indexOf(questionId) != -1) {
                    continue;
                } else {
                    component.set('v.currentQuestionIndex', index);
                    component.set('v.currentQuestion', moduleResponseWrapper.questions[index]);
                    helper.submitQuestion(component, 'module');
                }
            }
        } catch(e) {
            console.log(e);
        }
    },
    callSubmitModule: function(component, event, helper) {
        try {
            var moduleResponseWrapper = component.get('v.moduleResponseWrapper');
            var moduleResponse = {};
            moduleResponse.Id = moduleResponseWrapper.moduleResponse.Id;
            var action = component.get('c.submitModuleResponse');
            action.setParams({
                'moduleResponse': moduleResponse
            });
            action.setCallback(this, function(response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = JSON.parse(response.getReturnValue());
                    helper.showMessage('success', $A.get('$Label.c.ModuleSubmitted'));
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result.Id
                    });
                    navEvt.fire();
                } else {
                    var errorMsg = response.getError()[0].message;
                    helper.showMessage("error", errorMsg);
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
    getNextQuestion: function(component, event, helper) {
        try{
            var moduleResponseWrapper = component.get('v.moduleResponseWrapper');
            var nextQuestionIndex = component.get('v.currentQuestionIndex') + 1;
            nextQuestionIndex = nextQuestionIndex < moduleResponseWrapper.questions.length ? nextQuestionIndex : 0;
            component.set('v.currentQuestion', null);
            component.set('v.currentQuestion', moduleResponseWrapper.questions[nextQuestionIndex]);
            component.set('v.currentQuestionIndex', nextQuestionIndex);
            helper.refreshQuestionNumber(component);
        } catch(e) {
            console.log(e);
        }
    }
})