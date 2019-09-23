({
    getModuleData : function(component) {
        try{
            var action = component.get('c.getModule');
            var moduleId = component.get('v.recordId');
            var member = component.get('v.member');
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
                        var moduleWrapper = JSON.parse(response.getReturnValue());
                        var moduleResponses = moduleWrapper.moduleResponses;
                        component.set('v.moduleWrapper', moduleWrapper);
                        component.set('v.module', moduleWrapper.module);
                        component.set('v.course', moduleWrapper.module.FieloELR__Course__r);
                        component.set('v.moduleResponses', moduleWrapper.moduleResponses);
                        if (moduleResponses) {
                            if (moduleResponses[0]) {
                            	component.set('v.courseStatus', moduleResponses[0].FieloELR__CourseStatus__r);    
                            }
                            component.set('v.showHeaderActions', false);
                            component.set('v.showHeaderActions', true);
                            component.set('v.showBodyActions', false);
                            component.set('v.showBodyActions', true);
                        }
                        this.getCourseData(component);
                        this.getFirstApproveModuleResponse(component);
                        this.getLastModuleResponse(component);
                        
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
    getFirstApproveModuleResponse: function(component) {
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
                    component.set('v.moduleResponse', moduleResponses[0]);
                }
            }
            component.set('v.moduleResponseReady', true);
        } catch(e) {
            console.log(e);
        }
    },
    getLastModuleResponse: function(component) {
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
                    if(!component.get('v.moduleResponse').Id) {
                        component.set('v.moduleResponse', moduleResponses[0]);
                    }
                }
            }
            component.set('v.moduleResponseReady', true);
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
    getCourseData: function(component) {
        try{
            var action = component.get('c.getCourseData');
            var course = component.get('v.course');
            var member = component.get('v.member');
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
                        var result = JSON.parse(response.getReturnValue());
                        var courseStatus = result.courseStatus;
                        var courseWrapper = result.courseWrapper;
                        if (result.coursePoints) {
                            component.set('v.coursePoints', result.coursePoints);
                            component.set('v.showDetails', false);
                            component.set('v.showDetails', true);
                        }
                        component.set('v.courseWrapper', courseWrapper[0]);
                        component.set('v.courseStatus', courseStatus[0]);
                        component.set('v.showHeaderActions', false);
                        component.set('v.showHeaderActions', true);
                        component.set('v.showBodyActions', false);
                        component.set('v.showBodyActions', true);
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
    requiredModuleFields: [
        'Id',
        'Name',
        'FieloELR__Description__c',
        'FieloELR__AttemptsAllowed__c',
        'FieloELR__Order__c',
        'FieloELR__NumberOfQuestions__c',
        'FieloELR__ApprovalGrade__c',
        'FieloELR__Course__r.Name',
        'FieloELR__Content__c',
        'FieloELR__ContentType__c',
        'FieloELR__ExternalURL__c',
        'FieloELR__QuestionDisplayMode__c',
        'FieloELR__Course__r.FieloELR__Status__c',
        'FieloELR__Course__r.FieloELR__SubscriptionMode__c'
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
    ]
})