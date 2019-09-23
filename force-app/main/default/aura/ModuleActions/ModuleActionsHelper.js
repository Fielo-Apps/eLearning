({
    getHeaderActions: function(component) {
        try {
            var moduleWrapper = component.get('v.moduleWrapper');
            var courseWrapper = component.get('v.courseWrapper');
            var course = component.get('v.course');
            var courseStatus = component.get('v.courseStatus');
            var joined = courseStatus != null;
            var location = component.get('v.location');
            var module;
            var actions = [];
            var attemptsAllowed;
            var numberOfAttempts;
            var courseAllowedForDependency = true;
            var moduleAllowedForDependency = true;
            if (courseWrapper) {
                courseAllowedForDependency = courseWrapper.allowedForDependency;
                courseAllowedForDependency = courseAllowedForDependency != null ?
                    courseAllowedForDependency :
                true;    
            }
            if (moduleWrapper) {
                attemptsAllowed = moduleWrapper.module.FieloELR__AttemptsAllowed__c ?
                    moduleWrapper.module.FieloELR__AttemptsAllowed__c :
                moduleWrapper.numberOfAttempts + 1; // if FieloELR__AttemptsAllowed__c is null, then its unlimited
                numberOfAttempts = moduleWrapper.numberOfAttempts ?
                    moduleWrapper.numberOfAttempts :
                0;
                moduleAllowedForDependency = moduleWrapper.allowedForDependency;
                moduleAllowedForDependency = moduleAllowedForDependency != null ?
                    moduleAllowedForDependency :
                	true;
                if (moduleWrapper.isApproved) {
                    component.set('v.actions', ['passed']);
                } else {
                    if (numberOfAttempts == 0) {
                        if (course) {
                            if (course.FieloELR__Status__c == 'Active') {
                                if ((course.FieloELR__SubscriptionMode__c == 'Automatic' || course.FieloELR__SubscriptionMode__c == 'Manual' && joined) && moduleAllowedForDependency && courseAllowedForDependency) {
                                    component.set('v.actions', ['take']);
                                } else {
                                    component.set('v.actions', ['take-readonly']);
                                }        
                            } else {
                                component.set('v.actions', ['take-readonly']);
                            } 
                            
                        }
                    } else if (numberOfAttempts >= attemptsAllowed || !moduleWrapper.isApproved) {
                        component.set('v.actions', ['notpassed']);
                    }
                }
            }
        } catch(e) {
            console.log(e);
        }
    },
    getBodyActions: function(component) {
        try{
            var moduleWrapper = component.get('v.moduleWrapper');
            var courseWrapper = component.get('v.courseWrapper');
            var location = component.get('v.location');
            var course = component.get('v.course');
            var nextModule = component.get('v.nextModule');
            var module;
            var actions = [];
            var attemptsAllowed;
            var numberOfAttempts;
            var courseAllowedForDependency = true;
            var moduleAllowedForDependency = true;
            if (courseWrapper) {
                courseAllowedForDependency = courseWrapper.allowedForDependency;
                courseAllowedForDependency = courseAllowedForDependency != null ?
                    courseAllowedForDependency :
                	true;
            }
            if (moduleWrapper) {
                numberOfAttempts = moduleWrapper.numberOfAttempts ?
                    moduleWrapper.numberOfAttempts :
                	0;
                moduleAllowedForDependency = moduleWrapper.allowedForDependency;
                moduleAllowedForDependency = moduleAllowedForDependency != null ?
                    moduleAllowedForDependency :
                	true;
                attemptsAllowed = moduleWrapper.module.FieloELR__AttemptsAllowed__c != null ?
                    moduleWrapper.module.FieloELR__AttemptsAllowed__c :
                numberOfAttempts + 1; // if FieloELR__AttemptsAllowed__c is null, then its unlimited
                if (moduleWrapper.isApproved) {
                    if (numberOfAttempts >= attemptsAllowed) {
                        component.set('v.actions', ['view']);
                    } else {
                        if (course) {
                            if (course.FieloELR__Status__c == 'Active' && courseAllowedForDependency && moduleAllowedForDependency) {
                                component.set('v.actions', ['view','retake']);
                            } else {
                                component.set('v.actions', ['view','retake-readonly']);
                            }
                        }
                    }
                } else {
                    if (numberOfAttempts != 0) {
                        if (numberOfAttempts < attemptsAllowed) {
                            if (course) {
                                if (course.FieloELR__Status__c == 'Active') {
                                    component.set('v.actions', ['view','retake']);
                                } else {
                                    component.set('v.actions', ['view','retake-readonly']);
                                }
                            }
                        } else {
                            component.set('v.actions', ['view']);
                        }
                    }
                }
            }
            if (nextModule) {
                var actions = component.get('v.actions');
                if (!actions) {
                    actions = [];
                }
                actions.push('view-nextmodule');
                component.set('v.actions', actions);
            }
        } catch(e) {
            console.log(e);
        }
    },
    callTakeModule: function(component) {
        try{
            var action = component.get('c.takeModule');
            var member = component.get('v.member');
            var moduleWrapper = component.get('v.moduleWrapper');
            var params = {
                'member': member,
                'moduleId': moduleWrapper.module.Id
            };
            action.setParams(params);
            action.setCallback(this, function(response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var toastEvent = $A.get("e.force:showToast");
                var state = response.getState();                
                if (component.isValid() && state === 'SUCCESS') {                    
                    var moduleResponseWrapper = response.getReturnValue();
                    if (window.localStorage) {
                        window.localStorage.setItem('currentModuleReponse', moduleResponseWrapper);
                        moduleResponseWrapper = JSON.parse(moduleResponseWrapper);
                        window.localStorage.setItem('currentModuleReponseId', moduleResponseWrapper.module.Id);
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": moduleResponseWrapper.module.Id
                        });
                        navEvt.fire();
                    }
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
    viewResults: function(component) {
        try{
            var moduleWrapper = component.get('v.moduleWrapper');
            var moduleResponse;
            if (moduleWrapper.isApproved) {
                moduleResponse = moduleWrapper.moduleResponses.filter(function(mr) {
                    return mr.FieloELR__NumberofApprove__c == 1;
                });
                if (moduleResponse.length == 1) {
                    moduleResponse = moduleResponse[0];
                }
            } else {
                var lastAttempt = Math.max.apply(Math, moduleWrapper.moduleResponses.map(function(mr) { return mr.FieloELR__NumberOfAttempt__c; }));
                moduleResponse = moduleWrapper.moduleResponses.filter(function(mr) {
                    return mr.FieloELR__NumberOfAttempt__c == lastAttempt;
                });
                if (moduleResponse.length == 1) {
                    moduleResponse = moduleResponse[0];
                }
            }
            if (moduleResponse) {
                if (moduleResponse.Id) {
                    $A
                    .get("e.force:navigateToSObject")
                    .setParams({
                        "recordId": moduleResponse.Id
                    })
                    .fire();
                }
            }
            
        } catch(e) {
            console.log(e);
        }
    },
    viewModule: function(component) {
        try{
            $A
            .get("e.force:navigateToSObject")
            .setParams({
                "recordId": component.get('v.nextModule').Id
            })
            .fire();
        } catch(e) {
            console.log(e);
        }
    }
})