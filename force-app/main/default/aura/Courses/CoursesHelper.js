({
    getFilterFieldSet: function(component) {
        try{
            var action = component.get('c.getFilterFieldset');
            action.setParams({
                'objectName': 'FieloELR__Course__c',
                'fieldNames': component.get('v.courseFilterFields'),
                'rangedFields': component.get('v.courseRangedFilterFields'),
                'useStandardStatusList': false
            });
            action.setCallback(this, function(response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var toastEvent = $A.get("e.force:showToast");
                var state = response.getState();                
                if (component.isValid() && state === 'SUCCESS') {
                    var objectInfo = JSON.parse(response.getReturnValue());
                    component.set('v.filterFieldSet',objectInfo.fields);
                }else {
                    var errorMsg = response.getError()[0].message;
                    toastEvent.setParams({
                        "title": 'getFilterFieldSet: ' + errorMsg,
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
    getFields: function(component) {
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
                        this.getFieldSet(component);
                    } else if(objectName.toLowerCase() == 'fieloelr__coursestatus__c') {
                        component.set('v.courseStatusFieldsMeta', fieldsMap);
                        this.getFieldSet(component);
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
    getCourseFieldSet: function(component) {
        try{
            if (component.get('v.courseDetailFields')) {
                this.getFieldsMeta(component, 'FieloELR__Course__c', this.addCourseRequiredFields(component.get("v.courseDetailFields")));
            }
            if (component.get('v.courseStatusDetailFields')) {
                this.getFieldsMeta(component, 'FieloELR__CourseStatus__c', component.get('v.courseStatusDetailFields'));
            }
        } catch(e) {
            console.log(e);
        }
    },
    addCourseRequiredFields: function(courseFields) {
        try{
            console.log('addCourseRequiredFields');
            var courseFieldSet = [];
            var fieldList = courseFields.split(',');
            fieldList.forEach(function(fieldName) {
                if (courseFieldSet.join(',').toLowerCase().indexOf(fieldName.toLowerCase()) == -1) {
                    courseFieldSet.push(fieldName);
                }
            });
            this.requiredFields.forEach(function(fieldName) {
                if (courseFieldSet.join(',').toLowerCase().indexOf(fieldName.toLowerCase()) == -1) {
                    courseFieldSet.push(fieldName);
                }
            });
            return courseFieldSet.join(',');
        } catch(e) {
            console.log(e);
        }
    },
    loadCourses : function(component, event, helper, offset) {
        try{
            var spinner = $A.get("e.c:ToggleSpinnerEvent");
            var quantity = component.get('v.quantity');
            if(spinner){
                spinner.setParam('show', true);
                spinner.fire();    
            }           
            var member = component.get('v.member');
            var fieldset = component.get('v.fieldset');
            fieldset = helper.getFieldFromFieldset(fieldset).fieldset.join(',');
            
            if(fieldset != ''){
                this.requiredFields.forEach(function(fieldName) {
                    if (fieldset.toLowerCase().indexOf(fieldName.toLowerCase()) == -1) {
                        fieldset += ',' + fieldName;
                    }
                });
            }
            
            var modulesFieldset = component.get('v.courseFieldset');
            modulesFieldset = helper.getFieldFromFieldset(modulesFieldset).fieldset.join(',');
            if(modulesFieldset != '' && modulesFieldset.indexOf('FieloELR__AttemptsAllowed__c') == -1){
                modulesFieldset += ',FieloELR__AttemptsAllowed__c';
            }
            var dynamicFilterString = component.get('v.dynamicFilterString');
            var sortByClause = component.get('v.sortByClause') || component.get('v.defaultSortBy');
            if(member){            
                var action;
                var activeViewName = component.get('v.activeViewName');
                var showPointsEarned = component.get('v.showPointsEarned');
                
                if (activeViewName == 'availableCourses') {
                    action = component.get('c.getCourses');
                } else {
                    action = component.get('c.getCourseByCourseStatus');
                }
                
                var params = {
                    'member': member,
                    'coursesFieldset': fieldset.split(','),
                    'modulesFieldset': modulesFieldset.split(','),
                    'quantity': quantity + 1,
                    'offset': offset,
                    'sortByClause': sortByClause,
                    'dynamicFilter': dynamicFilterString,
                    'showPointsEarned': showPointsEarned
                };
                
                action.setParams(params);
                // Add callback behavior for when response is received
                action.setCallback(this, function(response) {
                    try{
                        var spinner = $A.get("e.c:ToggleSpinnerEvent");
                        var toastEvent = $A.get("e.force:showToast");
                        var state = response.getState();                
                        if (component.isValid() && state === 'SUCCESS') {                    
                            var member = component.get('v.member');
                            var memberId = member.Id;                                     
                            var result = JSON.parse(response.getReturnValue());
                            var courseWrappers, coursesList, courseStatus, coursePoints;
                            activeViewName = component.get('v.activeViewName');
                            if (activeViewName == 'availableCourses') {
                                coursesList = result.list;
                            } else {
                                coursesList = result.courses;
                                courseStatus = result.courseStatus;
                                coursePoints = result.coursePoints;
                            }
                            courseWrappers = result.wrappers;
                            if (courseWrappers) {
                                component.set('v.courseWrappers', courseWrappers);
                                var allowedForDependencyCourses = [];
                                var allowedForDependency
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
                            }
                            component.set('v.coursesList', coursesList);
                            component.set('v.courseStatus', courseStatus);
                            component.set('v.showCoursesList', true);
                            component.set('v.coursePoints', coursePoints);
                            helper.getFieldSet(component);
                            helper.updateButtons(component);
                        } else {
                            var errorMsg = response.getError()[0].message;
                            toastEvent.setParams({
                                "title": 'loadCourses: ' + errorMsg,
                                "message": " ",
                                "type": "error"
                            });
                            toastEvent.fire(); 
                        }
                        if(spinner){
                            spinner.setParam('show', false);
                            spinner.fire();
                        }
                    } catch(e) {
                        console.log(e);
                    }
                });      
                // Send action off to be executed
                $A.enqueueAction(action);   
            } else {
                var memberEvent = $A.get("e.FieloPLT:RefreshMemberEvent");
                if (memberEvent) {
                    memberEvent.fire();
                }
            }
        } catch(e) {
            console.log(e);
        }
    },
    updateCoursesCache: function(component, event, helper) {
        console.log('updateCoursesCache');
        var coursesCache = window.localStorage.getItem('coursesCache');        
        var memberId = component.get('v.member');        
        memberId = memberId.Id;        
        if(coursesCache){
            coursesCache = JSON.parse(coursesCache);
            if(!coursesCache[memberId]){
                coursesCache[memberId] = {};
            }
        } else {
            coursesCache = {};
            coursesCache[memberId] = {};            
        }
        window.localStorage.setItem('coursesCache', JSON.stringify(coursesCache));        
    },
    getFieldFromFieldset : function(fieldset) {
        var fields = {fieldset: ['Name'], subcomponents: []};
        fieldset.forEach(function(field){            
            if(field.type != 'subcomponent'){
                if(field.apiName != 'Name'){
                    fields.fieldset.push(field.apiName);        
                }                
            } else {
                fields.subcomponents.push(field);    
            }           
        })      
        return fields;
    },
    getConfiguration: function(component) {
        try{
            var action = component.get('c.getConfig');
            action.setCallback(this, function(response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var toastEvent = $A.get("e.force:showToast");
                var state = response.getState();                
                if (component.isValid() && state === 'SUCCESS') {                    
                    var config = response.getReturnValue();
                    component.set('v.compConfig',config);
                    
                    this.getCourseFieldSet(component);
                }else {
                    var errorMsg = response.getError()[0].message;
                    toastEvent.setParams({
                        "title": 'getConfiguration: ' + errorMsg,
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
    updateButtons: function(component) {
        var buttons = [];
        buttons.push(
            {
                "type": "subcomponent",
                "subcomponent": "c:ViewCourse",
                "apiName": "Id",
                "label": {},
                "showLabel": true,
                "config": {
                    "type": "btn",
                    "variant": "neutral",
                    "label": $A.get('$Label.c.ViewCourse'),
                    "courseStatus": component.get('v.courseStatus')
                }
            }
        );
        buttons.push(
            {
                "type": "subcomponent",
                "subcomponent": "c:CourseAction",
                "apiName": "Id",
                "label": {},
                "showLabel": true,
                "config": {
                    "label_viewModule": $A.get('$Label.c.ViewModule'),
                    "label_joinCourse": $A.get('$Label.c.JoinCourse'),
                    "activeViewName": component.get('v.activeViewName'),
                    "courseStatus": component.get('v.courseStatus'),
                    "variant": "brand",
                    "memberId": component.get('v.member').Id,
                    "allowedForDependencyCourses": component.get('v.allowedForDependencyCourses')
                }
            }
        );
        // console.log(buttons);
        component.set('v.buttons', buttons);
    },
    getFieldSet: function(component) {
        try{
            var config = component.get('v.configDefault');
            var title, fields, fieldset;
            config = JSON.parse(config);
            // TITLE
            var titleValue = component.get('v.titleValue').trim();
            if(titleValue.length > 0){
                if (titleValue.indexOf('{') == 0) {
                    title = JSON.parse(titleValue);
                } else {
                    title = {
                        "value": component.get('v.titleValue'),
                        "type": "text"
                    };                    
                }
            }
            if (title) {
                titleValue = '';
                var type = title.type.toLowerCase();
                var value = title.value;
                if(type == 'label'){
                    var label = '$Label.' + value;
                    titleValue = $A.get(label);
                    component.set('v.title', titleValue);                
                }else{
                    titleValue = value;
                    component.set('v.title', titleValue);
                }
            }
            // TITLE
            
            // FIELDSET
            fieldset = [], fields = [];                        
            var fieldsConfig = component.get('v.fields').trim();
            var courseDetailFields = component.get('v.courseDetailFields').trim();
            if(fieldsConfig.length == 0){
                fieldset = config.fieldset;                
            } else if (fieldsConfig.indexOf('[') == 0) {
                fieldset = JSON.parse(fieldsConfig);
            } else {
                var newField, nameAndType, apiName, type;
                var fieldsList = fieldsConfig.split(',');
                var detailFieldsList = courseDetailFields.split(',');
                fieldsList.join(detailFieldsList);
                fieldset.push({
                    "apiName": "Id",
                    "type": "subcomponent",
                    "subcomponent": "c:CourseContent",
                    "label": {
                        "type": "default"
                    },
                    "showLabel": false,
                    "config": component.get('v.compConfig')
                });
                fieldsList.forEach(function(field){
                    nameAndType = field.split('/');
                    apiName = nameAndType[0].trim();
                    type = nameAndType[1] ? nameAndType[1].trim().toLowerCase() : 'output';
                    if (apiName.toLowerCase() != 'name' && apiName.toLowerCase() != 'fieloelr__description__c') {
                        newField = {
                            'apiName': apiName,
                            'type': type,
                            'label': {},
                            'showLabel': true
                        }
                        fieldset.push(newField);
                    } else if (apiName.toLowerCase() == 'fieloelr__description__c') {
                        fieldset.push({
                            "apiName": "FieloELR__Description__c",
                            "type": "subcomponent",
                            "subcomponent": "c:CourseDescription",
                            "label": {
                                "type": "default"
                            },
                            "showLabel": false
                        });
                    }
                });
                fieldset.push({
                    "apiName": "FieloELR__StartDate__c",
                    "type": "subcomponent",
                    "subcomponent": "c:CourseDatesContainer",
                    "label": {
                        "type": "default"
                    },
                    "showLabel": false,
                    "config": JSON.stringify(
                        {
                            "daysToBeConsideredNew": component.get('v.daysToBeConsideredNew'),
                            "daysToBeConsideredWarning": component.get('v.daysToBeConsideredWarning')
                        }
                    )
                });
                if (component.get('v.courseDetailFields') &&
                    component.get('v.courseFieldsMeta') &&
                    component.get('v.courseStatusFieldsMeta') &&
                    component.get('v.activeViewName')
                   )
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
                                'fields': component.get('v.detailFields').trim(),
                                'fieldsMeta': component.get('v.courseFieldsMeta'),
                                'csFieldsMeta': component.get('v.courseStatusFieldsMeta'),
                                'activeViewName': component.get('v.activeViewName'),
                                'courseStatus': JSON.stringify(component.get('v.courseStatus')),
                                'pointField': component.get('v.pointFields'),
                                'coursePoints': JSON.stringify(component.get('v.coursePoints'))
                            }
                        )
                    });
            }
            component.set('v.fieldset', fieldset);
        } catch(e) {
            console.log(e);
        }
    },
    requiredFields: [
        'Name',
        'FieloELR__SubscriptionMode__c',
        'FieloELR__Status__c',
        'FieloELR__Image__c',
        'FieloELR__ExternalURL__c',
        'FieloELR__Description__c',
        'FieloELR__StartDate__c',
        'FieloELR__EndDate__c'
    ],
    getSortByOptions: function(component) {
        try {
            var action = component.get('c.getFieldsMetadata');
            action.setParams({
                'objectName': 'FieloELR__Course__c',
                'fieldNames': component.get('v.sortByFields')
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = JSON.parse(response.getReturnValue());
                    var options = [];
                    if (result.fields) {
                        result.fields.forEach(function(fieldInfo) {
                            options.push({
                                'value': fieldInfo.attributes.name,
                                'label': fieldInfo.attributes.label
                            });
                        });
                    }
                    if (options) {
                        component.set('v.sortByOptions', options);    
                    }
                } else {
                    var errorMsg = response.getError()[0].message;
                    this.showMessage('error', 'getSortByOptions: ' + errorMsg);
                }
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log(e);
        }       
    }
})