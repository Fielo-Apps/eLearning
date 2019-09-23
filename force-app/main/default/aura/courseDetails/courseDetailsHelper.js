({
    getDetailFields: function(component) {
        try{
            var detailFields = component.get('v.detailFields');
            detailFields = detailFields.split(',');
            var courseFields = [];
            var courseStatusFields = [];
            var apiNames = [];
            var objectName, fieldName;
            detailFields.forEach(function(fullApiName) {
                apiNames = fullApiName.split('.');
                if (apiNames.length == 1) {
                    courseFields.push(apiNames[0]);
                } else {
                    objectName = apiNames[0];
                    fieldName = apiNames[1];
                    if (objectName.trim().toLowerCase() == 'fieloelr__course__c') {
                        courseFields.push(fieldName);
                    } else if(objectName.trim().toLowerCase() == 'fieloelr__coursestatus__c') {
                        courseStatusFields.push(fieldName);
                    }
                }
                component.set('v.courseDetailFields', courseFields.join(','));
                component.set('v.courseStatusDetailFields', courseStatusFields.join(','));
            });
        } catch(e) {
            console.log(e);
        }
    },
    getFieldsMeta: function(component, objectName, fieldNames) {
        try {
            var action = component.get('c.getFieldsMetadata');
            action.setParams({
                'objectName': objectName,
                'fieldNames': fieldNames
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = JSON.parse(response.getReturnValue());
                    var fieldsMap = {};
                    if (result.fields) {
                        result.fields.forEach(function(fieldInfo) {
                            fieldsMap[fieldInfo.attributes.name] = fieldInfo;
                        });
                    }
                    if (objectName.toLowerCase() == 'fieloelr__course__c') {
                        component.set('v.courseFieldsMeta', fieldsMap);
                    } else if(objectName.toLowerCase() == 'fieloelr__coursestatus__c') {
                        component.set('v.courseStatusFieldsMeta', fieldsMap);
                    }
                } else {
                    var errorMsg = response.getError()[0].message;
                    this.showMessage('error', 'getFieldsMeta: ' + errorMsg);
                }
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log(e);
        }
    },
    getConfig: function (component) {
        try {
            var action = component.get('c.getConfig');
            action.setParams({
                'recordId': component.get('v.recordId'),
                'memberId': component.get('v.member').Id
            });
            action.setCallback(this, function (response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var toastEvent = $A.get("e.force:showToast");
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var config = JSON.parse(response.getReturnValue());
                    component.set('v.compConfig', config);
                    if (config.joinedCourse) {
                        component.set('v.activeViewName', 'myCourses');
                    } else {
                        component.set('v.activeViewName', 'availableCourses');
                    }
                    this.retrieveCourse(component);
                } else {
                    var errorMsg = response.getError()[0].message;
                    helper.showMessage('error', 'getConfig: ' + errorMsg);
                }
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log(e);
        }
    },
    retrieveCourse: function (component) {
        try {
            var action = component.get("c.getCourse");
            action.setParams({
                member: component.get('v.member'),
                courseId: component.get("v.recordId"),
                courseFields: this.addCourseRequiredFields(component.get("v.courseDetailFields")),
                moduleFields: 'Id,Name,FieloELR__Order__c',
                showPointsEarned: true
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    try{
                        var result = JSON.parse(response.getReturnValue());
                        if (result.courses) {
                            var courses = JSON.parse(result.courses);
                            component.set("v.course", courses[0]);
                            var courseWrappers = JSON.parse(result.wrappers);
                            component.set("v.courseWrappers", courseWrappers);
                            var allowedForDependencyCourses = [];
                            var allowedForDependency;
                            courseWrappers.forEach(function(cw) {
                                allowedForDependency = cw.allowedForDependency;
                                allowedForDependency = allowedForDependency != null ?
                                    allowedForDependency :
                                	true;
                                if (allowedForDependency) {
                                    allowedForDependencyCourses.push(cw.course.Id);
                                }
                            });
                            component.set('v.allowedForDependencyCourses', allowedForDependencyCourses);
                            if (result.courseStatus) {
                                var courseStatus = JSON.parse(result.courseStatus);
                                component.set("v.courseStatus", courseStatus);
                            }
                            this.loadCourseStatus(component);
                        }
                        if (result.coursePoints) {
                            component.set('v.coursePoints', JSON.parse(result.coursePoints));
                        }
                    } catch(e) {
                        console.log(e);
                    }
                } else {
                    var errorMsg = response.getError()[0].message;
                    this.showMessage('error', 'retrieveCourse: ' + errorMsg);
                }
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log(e);
        }
    },
    addCourseStatusRequiredFields: function(courseStatusFields) {
        try {
            var courseStatusFieldSet = [];
            var fieldList = courseStatusFields.split(',');
            fieldList.forEach(function(fieldName) {
                if (courseStatusFieldSet.join(',').toLowerCase().indexOf(fieldName.toLowerCase()) == -1) {
                    courseStatusFieldSet.push(fieldName);
                }
            });
            this.courseStatusRequiredFields.forEach(function(fieldName) {
                if (courseStatusFieldSet.join(',').toLowerCase().indexOf(fieldName.toLowerCase()) == -1) {
                    courseStatusFieldSet.push(fieldName);
                }
            });
            return courseStatusFieldSet.join(',');
        } catch(e) {
            console.log(e);
        }
    },
    addCourseRequiredFields: function(courseFields) {
        try{
            var courseFieldSet = [];
            var fieldList = courseFields.split(',');
            fieldList.forEach(function(fieldName) {
                if (courseFieldSet.join(',').toLowerCase().indexOf(fieldName.toLowerCase()) == -1) {
                    courseFieldSet.push(fieldName);
                }
            });
            this.courseRequiredFields.forEach(function(fieldName) {
                if (courseFieldSet.join(',').toLowerCase().indexOf(fieldName.toLowerCase()) == -1) {
                    courseFieldSet.push(fieldName);
                }
            });
            return courseFieldSet.join(',');
        } catch(e) {
            console.log(e);
        }
    },
    setFieldSet: function (component) {
        //FIELDSET
        try {
            var fieldList = component.get('v.fields');
            var fieldset = [];
            fieldset.push({
                "apiName": "Id",
                "type": "subcomponent",
                "subcomponent": "c:CourseContent",
                "label": {
                    "type": "default"
                },
                "showLabel": false,
                "config": JSON.stringify(component.get('v.compConfig'))
            });
            
            //COURSE DESCRIPTION SUBCOMPONENT
            fieldset.push({
                "apiName": "FieloELR__Description__c",
                "type": "subcomponent",
                "subcomponent": "c:CourseDescription",
                "label": {
                    "type": "default"
                },
                "showLabel": false
                
            })
            //DATE SUBCOMPONENT 
            fieldset.push({
                "apiName": "FieloELR__StartDate__c",
                "type": "subcomponent",
                "subcomponent": "c:CourseDatesContainer",
                "label": {
                    "type": "default"
                },
                "showLabel": "false",
                "config": JSON.stringify(
                    {
                        "daysToBeConsideredNew": component.get('v.daysToBeConsideredNew'),
                        "daysToBeConsideredWarning": component.get('v.daysToBeConsideredWarning')
                    }
                )
            });
            fieldset.push({
                "apiName": "Id",
                "type": "subcomponent",
                "subcomponent": "c:CourseFieldsSection",
                "label": {
                    "type": "default"
                },
                "showLabel": false,
                "config": JSON.stringify(
                    {
                        'activeViewName': component.get('v.courseStatus') ? 'myCourses' : 'availableCourses',
                        'fields': component.get('v.detailFields').trim(),
                        'fieldsMeta': component.get('v.courseFieldsMeta'),
                        'csFieldsMeta': component.get('v.courseStatusFieldsMeta'),
                        'courseStatus': JSON.stringify(component.get('v.courseStatus')),
                        'pointField': component.get('v.pointFields'),
                        'coursePoints': JSON.stringify(component.get('v.coursePoints'))
                    }
                )
            });
            component.set('v.fieldset', fieldset);
            this.getFieldNames(component);
        } catch (e) {
            console.log(e);
        }
    },    
    loadCourseStatus: function (component) {
        try {
            var courseId = component.get('v.recordId');
            var member = component.get('v.member');
            var action = component.get('c.getCourseStatus');
            var params = {
                'member': member,
                'courseId': courseId,
                'includePoints': true
            };
            action.setParams(params);
            action.setCallback(this, function (response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var moduleResponses = JSON.parse(response.getReturnValue());
                    if (moduleResponses.length !== 0) {
                        component.set('v.moduleResponses', moduleResponses);
                    }
                    this.setFieldSet(component);
                    this.setButtons(component);
                } else {
                    var errorMsg = response.getError()[0].message;
                    this.showMessage('error', 'loadCourseStatus: ' + errorMsg);
                }
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log(e);
        }
    },
    getFieldNames: function (component) {
        var fieldNames = [];
        var fieldset = component.get('v.fieldset');
        fieldset.forEach(function(fieldInfo){
            if (fieldNames.indexOf(fieldInfo.apiName) == -1) {
                fieldNames.push(fieldInfo.apiName);
            }
        });
        var courseDetailFields = component.get('v.courseDetailFields');
        courseDetailFields = courseDetailFields.split(' , ');
        courseDetailFields.forEach(function (fieldName) {
            if (fieldNames.indexOf(fieldName) == -1) {
                fieldNames.push(fieldName);
            }
        });
        component.set('v.fields', fieldNames.join(','));
    },
    setButtons: function (component) {
        var buttons = [];
        buttons.push({
            "type": "subcomponent",
            "subcomponent": "c:CourseAction",
            "apiName": "Id",
            "label": {},
            "showLabel": true,
            "config": {
                "label_viewModule": $A.get('$Label.c.ViewModule'),
                "label_joinCourse": $A.get('$Label.c.JoinCourse'),
                "activeViewName": component.get('v.courseStatus').length > 0 ? 'myCourses' : 'availableCourses',
                "variant": "brand",
                "memberId": component.get('v.member').Id,
                "moduleResponses": component.get('v.moduleResponses'),
                "allowedForDependencyCourses": component.get('v.allowedForDependencyCourses')
            }
        });
        component.set("v.buttons", buttons);
        this.setCardColor(component);
    },
    setCardColor: function (component) {
        var status = component.get('v.course.FieloELR__Status__c');
        if (status == 'Completed'){
            component.set('v.classNameCard', 'fielo-closed-course')
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
    courseRequiredFields: [
        'Name',
        'FieloELR__SubscriptionMode__c',
        'FieloELR__Status__c',
        'FieloELR__Image__c',
        'FieloELR__ExternalURL__c',
        'FieloELR__Description__c',
        'FieloELR__StartDate__c',
        'FieloELR__EndDate__c'
    ],
    courseStatusRequiredFields: [
        'Name',
        'FieloELR__ApprovedModules__c',
        'FieloELR__Progress__c'
    ]
})