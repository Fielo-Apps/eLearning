({
    loadModules: function(component) {
        try{
            var courseId = component.get('v.recordId');
            var member = component.get('v.member');
            var action = component.get('c.getCourseMap');
            var modulesFieldset = component.get('v.fields');
            var courseFields = component.get('v.courseDetailFields');
            var includePoints = component.get('v.includePoints');
            var includeCompletedOn = component.get('v.includeCompletedOn');
            var includeQuestions = component.get('v.includeQuestions');
            var includeGrade = component.get('v.includeGrade');
            modulesFieldset = this.getFields(component, modulesFieldset);
            component.set('v.fields', modulesFieldset);
            var params = {
                'member': member,
                'courseId': courseId,
                'courseFields': courseFields,
                'modulesFieldset': modulesFieldset,
                'includePoints': includePoints,
                'includeQuestions': includeQuestions
            };
            action.setParams(params);
            action.setCallback(this, function(response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var toastEvent = $A.get("e.force:showToast");
                var state = response.getState();                
                if (component.isValid() && state === 'SUCCESS') {                    
                    var courseWrapper = JSON.parse(response.getReturnValue());
                    var moduleWrapperList = [];
                    if (courseWrapper.length > 0) {
                        courseWrapper[0].modules.forEach(function(moduleWrapper) {
                            moduleWrapperList.push(moduleWrapper);
                            if (moduleWrapper && moduleWrapper.module && moduleWrapper.module.FieloELR__Questions__r) {
                                moduleWrapper.module.FieloELR__NumberOfQuestions__c = moduleWrapper.module.FieloELR__Questions__r.records.length;
                            }
                        });
                        component.set('v.course', courseWrapper[0].course);
                        component.set('v.courseWrapper', courseWrapper[0]);
                        component.set('v.courseStatus', courseWrapper[0].courseStatus);
                        component.set('v.nextModuleId', this.getNextModuleId(moduleWrapperList));
                        component.set('v.moduleWrapperList', moduleWrapperList);
                        component.set('v.showModules', true);
                        this.loadFieldsMetadata(component, 'FieloELR__Module__c', component.get('v.fields'));
                        this.loadFieldsMetadata(component, 'FieloELR__Course__c', component.get('v.courseDetailFields'));
                        this.selectView(component);
                    } else {
                        toastEvent.setParams({
                            "title": 'No course found',
                            "message": " ",
                            "type": "error"
                        });
                        toastEvent.fire(); 
                        if(spinner){
                            spinner.setParam('show', false);
                            spinner.fire();    
                        }                        
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
    getFields: function(component, fieldList) {
        try{
            var modulefields_passed = component.get('v.modulefields_passed');
            var modulefields_notpassed = component.get('v.modulefields_notpassed');
            var modulefields_nottaken = component.get('v.modulefields_nottaken');
            var fieldSet = [];
            var apiNames, fieldName, objectName;
            if (modulefields_passed)
                fieldSet = fieldSet.concat(modulefields_passed.split(','));
            if (modulefields_notpassed)
                fieldSet = fieldSet.concat(modulefields_notpassed.split(','));
            if (modulefields_nottaken)
                fieldSet = fieldSet.concat(modulefields_nottaken.split(','));
            fieldSet.forEach(function(field) {
                apiNames = field.split('.');
                fieldName = apiNames.length == 2 ? apiNames[1] : apiNames[0];
                objectName = apiNames.length == 2 ? apiNames[0] : 'FieloELR__Module__c';
                if (objectName == 'FieloELR__Module__c') {
                    if (fieldList.toLowerCase().indexOf(fieldName) == -1 && fieldName) {
                        fieldList += ',' + field;
                    }    
                }
            });
            this.requiredFields.forEach(function(field) {
                if (fieldList.toLowerCase().indexOf(field) == -1) {
                    fieldList += ',' + field;
                }
            });
            return fieldList;
        } catch(e) {
            console.log(e);
        }
    },        
    requiredFields: [
        'Id',
        'Name',
        'FieloELR__Description__c',
        'FieloELR__AttemptsAllowed__c',
        'FieloELR__Order__c',
        'FieloELR__NumberOfQuestions__c',
        'FieloELR__ApprovalGrade__c',
        'FieloELR__Course__c',
        '(SELECT Id FROM FieloELR__Questions__r)'
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
        'FieloELR__Member__c',
        'FieloELR__CourseStatus__r.FieloELR__Progress__c',
        'FieloELR__CourseStatus__r.FieloELR__Course__c'
    ],
    loadFieldsMetadata: function(component, objectName, fields) {
        try{
            var action = component.get('c.getFieldData');
            action.setParams({
                'sObjectName': objectName,
                'fields': fields
            });
            action.setCallback(this, function(response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var toastEvent = $A.get("e.force:showToast");
                var state = response.getState();                
                if (component.isValid() && state === 'SUCCESS') {                    
                    var objectInfo = JSON.parse(response.getReturnValue());
                    if (objectName == 'FieloELR__Module__c') {
                        component.set('v.fieldsMeta', objectInfo.fields);
                    } else if (objectName == 'FieloELR__Course__c') {
                        var CoursefieldsMeta = {};
                        objectInfo.fields.forEach(function(field) {
                            CoursefieldsMeta[field.attributes.name] = field;
                        });
                        component.set('v.CoursefieldsMeta', CoursefieldsMeta);
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
    loadCourseStatus: function(component) {
        try{
            var courseId = component.get('v.recordId');
            var member = component.get('v.member');
            var action = component.get('c.getCourseStatus');
            var params = {
                'member': member,
                'courseId': courseId,
                'includePoints': true
            };
            action.setParams(params);
            action.setCallback(this, function(response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var toastEvent = $A.get("e.force:showToast");
                var state = response.getState();                
                if (component.isValid() && state === 'SUCCESS') {
                    var result = JSON.parse(response.getReturnValue());
                    var moduleResponses = result.moduleResponses;
                    component.set('v.moduleResponses', moduleResponses);
                    if (result.coursePoints) {
                        component.set('v.coursePoints', result.coursePoints);
                    }
                    this.loadModuleResponseFieldsMetadata(component);
                    this.loadModules(component);
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
    getNextModuleId: function(moduleWrapperList) {
        try{
            var nextModuleId;
            moduleWrapperList.some(function(moduleWrapper) {
                nextModuleId = moduleWrapper.module.Id;
                return !moduleWrapper.isApproved;
            });
            return nextModuleId;
        } catch(e) {
            console.log(e);
        }
    },
    loadModuleResponseFieldsMetadata: function(component) {
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
    selectView: function(component) {
        try {
            if (window.localStorage) {
                var viewResults = Boolean(window.localStorage.getItem('viewResults'));
                var course = component.get('v.course');
                window.localStorage.removeItem('viewResults');
                if (viewResults || !this.hasDetails(component)) {
                    component.set('v.activeViewName', 'modules');
                    var tabsCmp = component.find('tabs');
                    if (tabsCmp) {
                        tabsCmp.selectView('modules');
                        console.log(tabsCmp.get('v.selectedView'));
                    }
                }
            }
        } catch(e) {
            console.log(e);
        }
    },
    hasDetails: function(component) {
        try{
            var course = component.get('v.course');
            var courseFields = component.get('v.courseDetailFields');
            courseFields = courseFields.split(',');
            var hasDetails = true;
            hasDetails = courseFields.some(function(fieldName) {
               return course[fieldName] != null &&
                   course[fieldName] != undefined &&
                   course[fieldName] != '';
            });
            return hasDetails;
        } catch(e) {
            console.log(e);
        }
    }
})