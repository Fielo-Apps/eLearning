({
    getModuleData : function(component) {
        try{
            var action = component.get('c.getModule');
            var member = component.get('v.member');
            var moduleResponseResult = component.get('v.moduleResponseResult');
            var moduleId;
            if (moduleResponseResult.moduleResponse.FieloELR__Module__r) {
                moduleId = moduleResponseResult.moduleResponse.FieloELR__Module__r.Id;
            }
            if (moduleId && moduleId != '') {
                var params = {
                    'member': member,
                    'moduleId': moduleId,
                    'moduleFields': this.requiredModuleFields.join(','),
                    'moduleResponseFields': this.requiredModuleResponseFields.join(',')
                };
                action.setParams(params);
                action.setCallback(this, function(response) {
                    var toastEvent = $A.get("e.force:showToast");
                    var state = response.getState();
                    if (component.isValid() && state === 'SUCCESS') {
                        try {
                            var moduleWrapper = JSON.parse(response.getReturnValue());;
                            var moduleResponses = moduleWrapper.moduleResponses;

                            if (moduleWrapper.module && moduleWrapper.module.Questions__r) {
                                moduleWrapper.module.FieloELR__NumberOfQuestions__c = moduleWrapper.module.Questions__r.length;
                            }

                            component.set('v.moduleWrapper', moduleWrapper);
                            component.set('v.module', moduleWrapper.module);
                            component.set('v.course', moduleWrapper.module.FieloELR__Course__r);
                            if (moduleWrapper.module.FieloELR__Course__r) {
                                this.getCourseStructure(component);
                            }
                            component.set('v.moduleResponses', moduleResponses);
                            if (moduleResponses[0]) {
                                component.set('v.courseStatus', moduleResponses[0].FieloELR__CourseStatus__r);
                            }
                            var moduleResponse = moduleResponses.filter(function(mr) {
                                return mr.Id == moduleResponseResult.moduleResponse.Id;
                            });
                            if (moduleResponse.length == 1) {
                                component.set('v.moduleResponse', moduleResponse[0]);
                            }
                            this.getFirstApproveModuleResponse(component);
                            this.getLastModuleResponse(component);
                            this.showQuiz(component);
                            var moduleHeaderText = '' +
                                $A.get('$Label.c.Module') + ' ' +
                                moduleWrapper.module.FieloELR__Order__c + ': <b>' +
                                moduleWrapper.module.Name + '</b>';
                            component.find('moduleHeaderText').set('v.value', moduleHeaderText);
                            component.set('v.moduleHeaderText', moduleWrapper.module.Name);
                        } catch(e) {
                            console.log(e);
                        }
                    } else {
                        var errorMsg = response.getError()[0].message;
                        toastEvent.setParams({
                            "title": errorMsg,
                            "message": " ",
                            "type": "error"
                        });
                        toastEvent.fire(); 
                    }
                });
                $A.enqueueAction(action);
            }
            
        } catch(e) {
            console.log(e);
        }
    },
    getModuleFieldsData: function(component) {
        try{
            var action = component.get('c.getFieldData');
            action.setParams({
                'sObjectName': 'FieloELR__Module__c',
                'fields': this.requiredModuleFields.join(',')
            });
            action.setCallback(this, function(response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var toastEvent = $A.get("e.force:showToast");
                var state = response.getState();                
                if (component.isValid() && state === 'SUCCESS') {                    
                    var objectInfo = JSON.parse(response.getReturnValue());
                    component.set('v.fieldsMeta', objectInfo.fields);
                } else {
                    var errorMsg = response.getError()[0].message;
                    toastEvent.setParams({
                        "title": errorMsg,
                        "message": " ",
                        "type": "error"
                    });
                    toastEvent.fire(); 
                    if(spinner){
                        spinner.setParam('show', false);
                        spinner.fire();    
                    }
                }
            });
            $A.enqueueAction(action);            
        } catch(e) {
            console.log(e);
        }
    },
    getModuleResponseFieldsData: function(component) {
        try{
            var action = component.get('c.getFieldData');
            action.setParams({
                'sObjectName': 'FieloELR__ModuleResponse__c',
                'fields': this.requiredModuleResponseFields.join(',')
            });
            action.setCallback(this, function(response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var toastEvent = $A.get("e.force:showToast");
                var state = response.getState();                
                if (component.isValid() && state === 'SUCCESS') {                    
                    var objectInfo = JSON.parse(response.getReturnValue());
                    var MRfieldsMeta = {};
                    objectInfo.fields.forEach(function(fieldInfo) {
                        MRfieldsMeta[fieldInfo.attributes.name] = fieldInfo;
                    });
                    component.set('v.MRfieldsMeta', MRfieldsMeta);
                } else {
                    var errorMsg = response.getError()[0].message;
                    toastEvent.setParams({
                        "title": errorMsg,
                        "message": " ",
                        "type": "error"
                    });
                    toastEvent.fire(); 
                    if(spinner){
                        spinner.setParam('show', false);
                        spinner.fire();    
                    }
                }
            });
            $A.enqueueAction(action);            
        } catch(e) {
            console.log(e);
        }
    },
    getModuleResponseData : function(component) {
        try{
            var action = component.get('c.getModuleResponse');
            var moduleResponseId = component.get('v.recordId');
            if (moduleResponseId && moduleResponseId != '') {
                var params = {
                    'moduleResponseId': moduleResponseId,
                    'fieldsModuleResponse': this.requiredModuleResponseFields.join(','),
                    'fieldsQuestion': this.requiredQuestionFields.join(','),
                    'fieldsAnswerOption': this.requiredAnswerOptionsFields.join(',')
                };
                action.setParams(params);
                action.setCallback(this, function(response) {
                    var toastEvent = $A.get("e.force:showToast");
                    var state = response.getState();
                    if (component.isValid() && state === 'SUCCESS') {
                        try {
                            var moduleResponseResult = JSON.parse(response.getReturnValue());
                            component.set('v.moduleResponseResult', moduleResponseResult);
                            this.getModuleData(component);
                        } catch(e) {
                            console.log(e);
                        }
                    } else {
                        var errorMsg = response.getError()[0].message;
                        toastEvent.setParams({
                            "title": errorMsg,
                            "message": " ",
                            "type": "error"
                        });
                        toastEvent.fire(); 
                    }
                });
                $A.enqueueAction(action);
            }
        } catch(e) {
            console.log(e);
        }
    },
    getCourseStructure: function(component) {
        try{
            var action = component.get('c.getCourseModules');
            var course = component.get('v.course');
            var member = component.get('v.member');

            if (course && course.Id && course.Id != '') {
                var params = {
                    'member': member,
                    'courseId': course.Id
                };
                action.setParams(params);
                action.setCallback(this, function(response) {
                    var toastEvent = $A.get("e.force:showToast");
                    var state = response.getState();
                    if (component.isValid() && state === 'SUCCESS') {
                        try {
                            var courseStructure = JSON.parse(response.getReturnValue());
                            component.set('v.courseStructure', courseStructure);
                            component.set('v.courseWrapper', courseStructure.wrappers[0]);
                            if (courseStructure.coursePoints) {
                                component.set('v.coursePoints', courseStructure.coursePoints);
                                component.set('v.showDetails', false);
                                component.set('v.showDetails', true);
                            }
                            this.getNextModule(component);
                        } catch(e) {
                            console.log(e);
                        }
                    } else {
                        var errorMsg = response.getError()[0].message;
                        toastEvent.setParams({
                            "title": errorMsg,
                            "message": " ",
                            "type": "error"
                        });
                        toastEvent.fire(); 
                    }
                });
                $A.enqueueAction(action);
            }
        } catch(e) {
            console.log(e);
        }
    },
    getNextModule: function(component) {
        try{
            
            var moduleWrapper = component.get('v.moduleWrapper');
            var courseStructure = component.get('v.courseStructure');
            var modules, moduleResponses;
            if (courseStructure) {
                modules = courseStructure.courses[0].FieloELR__Modules__r.records;
                moduleResponses = courseStructure.courseStatus[0].FieloELR__ModuleResponses__r.records;
            }
            var approvedModules = [];
            var nextModule;
            if (moduleResponses) {
                moduleResponses.forEach(function(mr) {
                    if (mr.FieloELR__NumberofApprove__c == 1) {
                        approvedModules.push(mr.FieloELR__Module__c);
                    }
                });
                var approvedModulesSet = new Set(approvedModules);
                var hasNext = false;
                if (approvedModules.length == 0 && modules.length > 0) {
                    hasNext = true;
                    nextModule = modules[0];
                } else if (modules.length > 0){
                    hasNext = modules.some(function(m) {
                        nextModule = m;
                        return !approvedModulesSet.has(m.Id);
                    });
                    if (!hasNext) {
                        nextModule = null;
                    }
                }
            }
            component.set('v.nextModule', nextModule);
            component.set('v.showBodyActions', false);
            component.set('v.showBodyActions', true);
        } catch(e) {
            console.log(e);
        }
    },
    getFirstApproveModuleResponse : function(component) {
        try{
            var moduleResponses = component.get('v.moduleResponses');
            var moduleWrapper = component.get('v.moduleWrapper');
            var passed = moduleWrapper.isApproved;
            if (moduleResponses) {
                if (passed) {
                    moduleResponses = moduleResponses.filter(function(mr) {
                        return mr.FieloELR__NumberofApprove__c == 1;
                    });
                }
            }
            if (moduleResponses) {
                if (moduleResponses.length == 1) {
                    component.set('v.firstApproveModuleResponse', moduleResponses[0]);
                }
            }
            component.set('v.moduleResponseReady', true);
        } catch(e) {
            console.log(e);
        }
    },
    getLastModuleResponse : function(component) {
        try{
            var moduleResponses = component.get('v.moduleResponses');
            var moduleWrapper = component.get('v.moduleWrapper');
            if (moduleResponses) {
                moduleResponses = moduleResponses.filter(function(mr) {
                    return mr.FieloELR__Module__c == moduleWrapper.module.Id;
                });
                var lastAttempt = Math.max.apply(Math, moduleResponses.map(function(mr) { return mr.FieloELR__NumberOfAttempt__c; }));
                moduleResponses = moduleResponses.filter(function(mr) {
                    return mr.FieloELR__NumberOfAttempt__c == lastAttempt;
                });
            }
            if (moduleResponses) {
                if (moduleResponses.length == 1) {
                    component.set('v.lastModuleResponse', moduleResponses[0]);
                }
            }
            component.set('v.moduleResponseReady', true);
        } catch(e) {
            console.log(e);
        }
    },
    showQuiz: function(component) {
        try {
            var moduleWrapper = component.get('v.moduleWrapper');
            var module = moduleWrapper.module;
            var moduleResponse = component.get('v.moduleResponse');
            var questions = this.getQuestions(component);
            var moduleResponseWrapper = {};
            var quizAttributes = {};
            
            module.FieloELR__QuestionDisplayMode__c = 'All at once';
            
            moduleResponseWrapper.module = module;
            moduleResponseWrapper.moduleResponse = moduleResponse;
            moduleResponseWrapper.questions = questions;
            window.localStorage.setItem('currentModuleReponse', JSON.stringify(moduleResponseWrapper));
            quizAttributes.overrideId = moduleResponse && moduleResponse.Id || null;
            quizAttributes.moduleResponseWrapper = moduleResponseWrapper;
            quizAttributes.questions = module.questions;
            quizAttributes.module = module;
            quizAttributes.moduleResponse = moduleResponse;
            component.set('v.quizAttributes', quizAttributes);
            component.set('v.showQuiz', true);
            var quizComp = component.find('module-quiz');
            if (quizComp instanceof Array) {
                quizComp = quizComp[0];
            }
            quizComp.set('v.hideQuiz', false);
            this.getAnswers(component);
        } catch(e) {
            console.log(e);
        }
    },
    getAnswers: function(component) {
        try {
            var moduleResponseResult = component.get('v.moduleResponseResult');
            var quizCmp = component.find('module-quiz');
            var questionCards = quizCmp.find('question-card');
            if (!(questionCards instanceof Array)) {
                questionCards = [];
                quizCmp.find('question-card') && questionCards.push(quizCmp.find('question-card'));
            }
            if (moduleResponseResult.questions && moduleResponseResult.questions.length && questionCards && questionCards.length) {
                var questionCmp;
                var questionCard;
                moduleResponseResult.questions.forEach(function(qrw) {
                    questionCard = questionCards.filter(function(cmp) {
                        return cmp && cmp.get('v.question').Id == qrw.question.Id;
                    });
                    questionCard = questionCard[0];
                    questionCard.set('v.mode', 'view');
                    if (qrw.questionResponse.FieloELR__IsCorrect__c) {
                        questionCard.set('v.status', 'passed');
                    } else {
                        questionCard.set('v.status', 'notpassed');
                    }
                    questionCmp = questionCard.find('question-component');
                    if (questionCmp instanceof Array) {
                        questionCmp = questionCmp[0];
                    }
                    if (questionCmp) {
                        if (questionCmp.get('v.type') == 'Short Answer') {
                            questionCmp.find('fielo-answer-option').set('v.value', qrw.questionResponse.FieloELR__TextValue__c);
                        }
                        if (questionCmp.get('v.type') == 'Single Choice' ||
                            questionCmp.get('v.type') == 'Multiple Choice' ||
                            questionCmp.get('v.type') == 'Statement') {
                            var answerOptions;
                            var answerCmps;
                            if (qrw.questionResponse) {
                                if (qrw.questionResponse.FieloELR__Answers__r) {
                                    answerOptions = questionCmp.find('fielo-answer-option');
                                    qrw.questionResponse.FieloELR__Answers__r.records.forEach(function(answer) {
                                        answerCmps = answerOptions.filter(function(ao) {
                                            return answer.FieloELR__AnswerOption__c == ao.get('v.value');
                                        });
                                        answerCmps.forEach(function(ao) {
                                            console.log('    ' + ao.get('v.label'));
                                            ao.set('v.checked', true);
                                        });
                                    });        
                                }
                            }
                        }
                        if (questionCmp.get('v.type') == 'Matching Options') {
                            var answerOptions;
                            var answerCmps;
                            var matchingOption;
                            if (qrw.questionResponse) {
                                if (qrw.questionResponse.FieloELR__Answers__r) {
                                    answerOptions = questionCmp.find('fielo-matching-text');
                                    qrw.questionResponse.FieloELR__Answers__r.records.forEach(function(answer) {
                                        answerCmps = answerOptions.filter(function(ao) {
                                            return answer.FieloELR__AnswerOption__c == ao.get('v.name');
                                        });
                                        answerCmps.forEach(function(ao) {
                                            ao.set('v.value', answer.FieloELR__TextValue__c);
                                        });
                                    });        
                                }
                            }
                        }
                    }
                });
            }
            
            quizCmp.toggleQuestionsContent();
        } catch(e) {
            console.log(e);
        }
    },
    getQuestions: function(component) {
        try{
            var moduleResponseResult = component.get('v.moduleResponseResult');
            var questions = [];
            
            if (moduleResponseResult.questions) {
                moduleResponseResult.questions.forEach(function(qrw) {
                    questions.push(qrw.question);
                });    
            }
            
            return questions;
        } catch(e) {
            console.log(e);
        }
    },
    getConfig: function(component) {
        try{
            var action = component.get('c.getConfig');
            action.setCallback(this, function(response) {
                var toastEvent = $A.get("e.force:showToast");
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    try {
                        var config = JSON.parse(response.getReturnValue());
                        component.set('v.config', config);
                    } catch(e) {
                        console.log(e);
                    }
                } else {
                    var errorMsg = response.getError()[0].message;
                    toastEvent.setParams({
                        "title": errorMsg,
                        "message": " ",
                        "type": "error"
                    });
                    toastEvent.fire(); 
                }
            });
            $A.enqueueAction(action);
        } catch(e) {
            console.log(e);
        }
    },
    setRequiredFields: function (component) {
        try {
            var fields = !$A.util.isUndefinedOrNull(component.get('v.modulefields_passed'))
                && component.get('v.modulefields_passed').split(',') || [];

            fields = fields.concat(!$A.util.isUndefinedOrNull(component.get('v.modulefields_notpassed'))
                && component.get('v.modulefields_notpassed').split(',') || []);

            fields = fields.concat(!$A.util.isUndefinedOrNull(component.get('v.modulefields_nottaken'))
                && component.get('v.modulefields_nottaken').split(',') || []);

            var moduleFields = new Set();
            var moduleResponseFields = new Set();

            fields.forEach(field => {
                if (field.toLowerCase().indexOf('fieloelr__moduleresponse__c') != -1) {
                    field.split('.')[1].toLowerCase() != 'fieloelr__transactions__r' &&
                        field.split('.')[1].toLowerCase() != 'fieloelr__tracker__r' &&
                        moduleResponseFields.add(field.split('.')[1]);
                } else {
                    moduleFields.add(field);
                }
            });

            if (moduleFields.size) {
                this.requiredModuleFields = Array.from(new Set(this.requiredModuleFields.concat(Array.from(moduleFields))));
            }

            if (moduleResponseFields.size) {
                this.requiredModuleResponseFields = Array.from(new Set(this.requiredModuleResponseFields.concat(Array.from(moduleResponseFields))));
            }
        } catch (e) {
            console.error(e);
        }
    },
    requiredModuleFields: [
        'Id',
        'Name',
        'FieloELR__Description__c',
        'FieloELR__AttemptsAllowed__c',
        'FieloELR__Order__c',
        'FieloELR__NumberOfQuestions__c',
        'FieloELR__ApprovalGrade__c',
        'FieloELR__Course__r.Name',
        'FieloELR__Course__r.FieloELR__Status__c',
        'FieloELR__Content__c',
        'FieloELR__ContentType__c',
        'FieloELR__ExternalURL__c',
        'FieloELR__QuestionDisplayMode__c',
        '(SELECT Id FROM Questions__r)'
    ],
    requiredModuleResponseFields: [
        'Id',
        'FieloELR__Module__c',
        'FieloELR__IsApproved__c',
        'FieloELR__NumberOfAttempt__c',
        'FieloELR__NumberofApprove__c',
        'FieloELR__GradePercent__c',
        'FieloELR__SubmitDate__c',
        'FieloELR__CorrectQuestions__c',
        'FieloELR__IncorrectQuestions__c',
        'FieloELR__CourseStatus__r.FieloELR__Progress__c'
    ],
    requiredQuestionFields: [
        'Name',
        'FieloELR__Type__c',
        'FieloELR__Module__r.FieloELR__Course__c',
        'FieloELR__QuestionText__c',
        'FieloELR__Order__c'
    ],
    requiredAnswerOptionsFields: [
        'FieloELR__Question__c',
        'FieloELR__AnswerOptionText__c',
        'FieloELR__MatchingText__c'
    ]
})