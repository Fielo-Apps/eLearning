({
    getFieldsMetaMap: function(component) {
        try{
            var fieldsMeta = component.get('v.fieldsMeta');
            var fieldsMetaMap = {};
            fieldsMeta.forEach(function(fieldInfo) {
                fieldsMetaMap[fieldInfo.attributes.name] = fieldInfo;
            });
            component.set('v.fieldsMetaMap', fieldsMetaMap);
        } catch(e) {
            console.log(e);
        }
    },
    setFieldValues: function(component) {
        try{
            this.getModulePoints(component);
            var modulePoints = component.get('v.modulePoints');
            var fieldsMetaMap = component.get('v.fieldsMetaMap');
            var MRfieldsMeta = component.get('v.MRfieldsMeta');
            var moduleWrapper = component.get('v.moduleWrapper');
            var module = component.get('v.module');
            var moduleResponse = component.get('v.moduleResponse');
            var useDefaultUX = component.get('v.useDefaultUX');
            var modulefields_passed = component.get('v.modulefields_passed');
            var modulefields_notpassed = component.get('v.modulefields_notpassed');
            var modulefields_nottaken = component.get('v.modulefields_nottaken');
            var fieldValues = [];
            var taken = moduleWrapper.numberOfAttempts > 0;
            var passed = taken && moduleWrapper.isApproved;
            var singleField, apiNames, fieldName, objectName, pointsAdded;
            modulefields_passed = modulefields_passed.split(',');
            modulefields_notpassed = modulefields_notpassed.split(',');
            modulefields_nottaken = modulefields_nottaken.split(',');
            
            //NOT TAKEN
            if (!taken) {
                modulefields_nottaken.forEach(function(field) {
                    apiNames = field.split('.');
                    fieldName = apiNames.length == 2 ? apiNames[1] : apiNames[0];
                    if (useDefaultUX && (fieldName == 'FieloELR__KeyDependencies__c' || fieldName == 'FieloELR__NumberOfAttempt__c' || fieldName == 'FieloELR__Transactions__r' || fieldName == 'FieloELR__Trackers__r')  ) {
                        if (fieldName == 'FieloELR__KeyDependencies__c') {
                            fieldValues.push(this.getPrerequisitesField(component));    
                        } else if (fieldName == 'FieloELR__NumberOfAttempt__c') {
                            fieldValues.push(this.getAttemptsField(component));    
                        } else if (fieldName == 'FieloELR__Transactions__r' || fieldName == 'FieloELR__Trackers__r') {
                            if (!pointsAdded) {
                                pointsAdded = true;
                                fieldValues.push(this.getPointsField(component));
                            }    
                        }
                    } else {
                        if (fieldsMetaMap[fieldName] || MRfieldsMeta[fieldName]) {
                            singleField = {};
                            singleField.label = fieldsMetaMap[fieldName].attributes.label;
                            if (module[fieldName]) {
                                singleField.value = module[fieldName];
                            }
                            fieldValues.push(singleField);
                        }
                    }
                }, this);
            } else {
                // PASSED
                if (passed) {
                    modulefields_passed.forEach(function(field) {
                        apiNames = field.split('.');
                        fieldName = apiNames.length == 2 ? apiNames[1] : apiNames[0];
                        objectName = apiNames.length == 2 ? apiNames[0] : 'FieloELR__Module__c';
                        
                        if (useDefaultUX && (fieldName == 'FieloELR__Transactions__r' ||
                                             fieldName == 'FieloELR__Trackers__r' ||
                                             fieldName == 'FieloELR__SubmitDate__c' ||
                                             fieldName == 'FieloELR__GradePercent__c' ||
                                             fieldName == 'FieloELR__NumberOfAttempt__c') ) {
                            if (fieldName == 'FieloELR__Transactions__r' || fieldName == 'FieloELR__Trackers__r') {
                                if (!pointsAdded) {
                                    pointsAdded = true;
                                    fieldValues.push(this.getPointsField(component));
                                }    
                            } else if (fieldName == 'FieloELR__SubmitDate__c') {
                                fieldValues.push(this.getCompletedOnField(component));
                            } else if (fieldName == 'FieloELR__GradePercent__c') {
                                fieldValues.push(this.getGradeField(component));
                            } else if (fieldName == 'FieloELR__NumberOfAttempt__c') {
                                fieldValues.push(this.getAttemptsField(component));
                            }
                        } else {
                            if (fieldsMetaMap[fieldName] || MRfieldsMeta[fieldName]) {
                                if (objectName == 'FieloELR__Module__c') {
                                    singleField = {};
                                    singleField.label = fieldsMetaMap[fieldName].attributes.label;
                                    
                                    if (module[fieldName]) {
                                        singleField.value = module[fieldName];
                                        
                                        if (fieldName.toLowerCase() == 'fieloelr__numberofquestions__c') {
                                            if (moduleResponse) {
                                                if (moduleResponse['FieloELR__CorrectQuestions__c']) {
                                                    singleField.value += ' (' + moduleResponse['FieloELR__CorrectQuestions__c'] + ' ' + $A.get('$Label.c.CorrectQuestions') + ')';
                                                }
                                            }
                                        }
                                    }
                                    fieldValues.push(singleField);
                                } else if (objectName == 'FieloELR__ModuleResponse__c') {
                                    singleField = {};
                                    singleField.label = MRfieldsMeta[fieldName].attributes.label;
                                    
                                    if (moduleResponse[fieldName]) {
                                        singleField.value = moduleResponse[fieldName];
                                    }
                                    fieldValues.push(singleField);
                                }
                            }
                        }
                    }, this);
                    // NOT PASSED
                } else {
                    modulefields_notpassed.forEach(function(field) {
                        apiNames = field.split('.');
                        fieldName = apiNames.length == 2 ? apiNames[1] : apiNames[0];
                        objectName = apiNames.length == 2 ? apiNames[0] : 'FieloELR__Module__c';
                        
                        if (useDefaultUX && (fieldName == 'FieloELR__Transactions__r' ||
                                             fieldName == 'FieloELR__Trackers__r' ||
                                             fieldName == 'FieloELR__SubmitDate__c' ||
                                             fieldName == 'FieloELR__GradePercent__c' ||
                                             fieldName == 'FieloELR__NumberOfAttempt__c') ) {
                            if (fieldName == 'FieloELR__Transactions__r' || fieldName == 'FieloELR__Trackers__r') {
                                if (!pointsAdded) {
                                    pointsAdded = true;
                                    fieldValues.push(this.getPointsField(component));
                                }    
                            } else if (fieldName == 'FieloELR__SubmitDate__c') {
                                fieldValues.push(this.getCompletedOnField(component));
                            } else if (fieldName == 'FieloELR__GradePercent__c') {
                                fieldValues.push(this.getGradeField(component));
                            } else if (fieldName == 'FieloELR__NumberOfAttempt__c') {
                                fieldValues.push(this.getAttemptsField(component));
                            }
                        } else {
                            if (fieldsMetaMap[fieldName] || MRfieldsMeta[fieldName]) {
                                if (objectName == 'FieloELR__Module__c') {
                                    singleField = {};
                                    singleField.label = fieldsMetaMap[fieldName].attributes.label;
                                    
                                    if (module[fieldName]) {
                                        singleField.value = module[fieldName];
                                        
                                        if (fieldName.toLowerCase() == 'fieloelr__numberofquestions__c') {
                                            if (moduleResponse) {
                                                if (moduleResponse['FieloELR__CorrectQuestions__c']) {
                                                    singleField.value += ' (' + moduleResponse['FieloELR__CorrectQuestions__c'] + ' ' + $A.get('$Label.c.CorrectQuestions') + ')';
                                                }
                                            }
                                        }
                                    }
                                    fieldValues.push(singleField);
                                } else if (objectName == 'FieloELR__ModuleResponse__c') {
                                    singleField = {};
                                    singleField.label = MRfieldsMeta[fieldName].attributes.label;
                                    
                                    if (moduleResponse[fieldName]) {
                                        singleField.value = moduleResponse[fieldName];
                                    }
                                    fieldValues.push(singleField);
                                }
                            }
                        }
                    }, this);
                }    
            }
            component.set('v.fieldValues', fieldValues);   
        } catch(e) {
            console.log(e);
        }
    },
    getPointsField: function(component) {
        try{
            var pointsField = {};
            var modulePoints = component.get('v.modulePoints');
            var points = 0;
            pointsField.label = $A.get('$Label.c.Points');
            
            if (modulePoints) {
            	pointsField.value = modulePoints;
            } else {
                pointsField.value = 0;
            }
            
            return pointsField;    
        } catch(e) {
            console.log(e);
        }
    },
    getCompletedOnField: function(component) {
        try{
            var completedOnField = {};
            var moduleWrapper = component.get('v.moduleWrapper');
            var moduleResponse = component.get('v.moduleResponse');
            completedOnField.label = $A.get('$Label.c.CompletedOn');
            
            if (moduleResponse) {
                if (moduleResponse['FieloELR__SubmitDate__c']) {
                    completedOnField.value = new Date(moduleResponse['FieloELR__SubmitDate__c']).toDateString();
                }
            }
            
            return completedOnField;    
        } catch(e) {
            console.log(e);
        }
    },
    getGradeField: function(component) {
        try{
            var gradeField = {};
            var moduleWrapper = component.get('v.moduleWrapper');
            var MRfieldsMeta = component.get('v.MRfieldsMeta');
            var moduleResponse = component.get('v.moduleResponse');
            
            gradeField.label = MRfieldsMeta['FieloELR__GradePercent__c'].attributes.label;
            
            if (moduleResponse) {
                gradeField.value = moduleResponse['FieloELR__GradePercent__c'];
                gradeField.className = moduleResponse['FieloELR__GradePercent__c'] >= moduleWrapper.module.FieloELR__ApprovalGrade__c ?
                    'fielo-module-status--passed' :
                'fielo-module-status--notpassed';
            }
            return gradeField;    
        } catch(e) {
            console.log(e);
        }
    },
    getPrerequisitesField: function(component) {
        try{
            var prerequisitesField = {};
            var moduleWrapper = component.get('v.moduleWrapper');
            var keyDependencies;
            prerequisitesField.label = $A.get('$Label.c.Prerequisites');
            
            if (moduleWrapper.module) {
                if (moduleWrapper.module['FieloELR__KeyDependencies__c']) {
                    keyDependencies = moduleWrapper.module['FieloELR__KeyDependencies__c'].split(',');
                    if (keyDependencies.length > 0) {
                        prerequisitesField.value = keyDependencies.length;
                    } else {
                        prerequisitesField.value = $A.get('$Label.c.None');
                    }
                }else {
                    prerequisitesField.value = $A.get('$Label.c.None');
                }
            }
            console.log(JSON.stringify(moduleWrapper.dependencies, null, 2));
            if (moduleWrapper.dependencies) {
                prerequisitesField.hasDependency = moduleWrapper.dependencies.length > 0;
                prerequisitesField.dependencyText = $A.get('$Label.c.DependencyHelpText') + ': ';
                var moduleNames = [];
                moduleWrapper.dependencies.forEach(function(dependency) {
                    moduleNames.push(dependency.FieloELR__Predecessor__r.Name);
                });
                moduleNames.forEach(function(moduleName) {
                    if (moduleNames.indexOf(moduleName) != 0) {
                        if (moduleNames.indexOf(moduleName) == moduleNames.length-1) {
                            prerequisitesField.dependencyText += ' ' + $A.get('$Label.c.And') + ' ';
                        } else {
                            prerequisitesField.dependencyText += ', ';
                        }    
                    }
                    prerequisitesField.dependencyText += '"' + moduleName + '"';
                });
            }
            return prerequisitesField;    
        } catch(e) {
            console.log(e);
        }
    },
    getAttemptsField: function(component) {
        try{
            var attemptsField = {};
            var moduleWrapper = component.get('v.moduleWrapper');
            var moduleResponse = component.get('v.lastModuleResponse');
            var attempts = moduleResponse && moduleResponse['FieloELR__NumberOfAttempt__c'] != null ?
                moduleResponse['FieloELR__NumberOfAttempt__c'] :
            0;
            var MRfieldsMeta = component.get('v.MRfieldsMeta');
            
            attemptsField.label = MRfieldsMeta['FieloELR__NumberOfAttempt__c'].attributes.label;
            
            attemptsField.value = attempts;
            if (moduleWrapper.module) {
                if (moduleWrapper.module['FieloELR__AttemptsAllowed__c']) {
                    attemptsField.value += ' / ' + moduleWrapper.module['FieloELR__AttemptsAllowed__c'];
                }
            }
            
            return attemptsField;    
        } catch(e) {
            console.log(e);
        }
    },
    getModulePoints: function(component) {
        try{
            var coursePoints = component.get('v.coursePoints');
            var module = component.get('v.module');
            var pointFields = component.get('v.pointFields');
            pointFields = pointFields ? pointFields : 'FieloPLT__Points__c';
            if (coursePoints) {
                if (coursePoints[module.FieloELR__Course__c]) {
                    if (coursePoints[module.FieloELR__Course__c].modulePoints) {
                        if (coursePoints[module.FieloELR__Course__c].modulePoints[module.Id]){
                            component.set('v.modulePoints', coursePoints[module.FieloELR__Course__c].modulePoints[module.Id][pointFields]);
                        }
                    }
                }    
            }
        } catch(e) {
            console.log(e);
        }
    }
})