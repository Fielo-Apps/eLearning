({
    getNextModule: function(component) {
        try{
            var record = component.get('v.record');
            var config = component.get('v.config');
            var modules, moduleResponses, courseStatus;
            var approvedModules = [];
            var nextModule;
            // Get Modules
            if (record.FieloELR__Modules__r) {
                if (record.FieloELR__Modules__r.records) {
                    modules = record.FieloELR__Modules__r.records;
                }
            }
            // Get Course Status
            if (config.courseStatus) {
                courseStatus = config.courseStatus;
                courseStatus = courseStatus.filter(function(cs) {
                    return cs.FieloELR__Course__c == record.Id;
                });
                if (courseStatus.length == 1) {
                    courseStatus = courseStatus[0];
                }
            }
            
            if (config.activeViewName) {
                component.set('v.activeViewName', config.activeViewName);
            }
            
            // Get Module Responses
            if (config.moduleResponses) {
                moduleResponses = config.moduleResponses;
            } else {
                if (courseStatus) {
                    if (courseStatus.FieloELR__ModuleResponses__r) {
                        moduleResponses = courseStatus.FieloELR__ModuleResponses__r.records;
                    }    
                }
            }
            
            if (moduleResponses) {
                moduleResponses.forEach(function(mr) {
                    if (mr.FieloELR__NumberofApprove__c == 1) {
                        approvedModules.push(mr.FieloELR__Module__c);
                    }
                });
            }
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
            }
            
            component.set('v.hasNextModule', hasNext);
            if (hasNext) {
                component.set('v.nextModule', nextModule);
            }
        } catch(e) {
            console.log(e);
        }
    },
    getAllowedForDependency: function(component) {
        try {
            var record = component.get('v.record');
            var config = component.get('v.config');
            var allowedForDependencyCourses;
            var allowedForDependency = false;
            if (config.allowedForDependencyCourses) {
                allowedForDependencyCourses = config.allowedForDependencyCourses;
                if (allowedForDependencyCourses.indexOf(record.Id) != -1) {
                    allowedForDependency = true;
                }
            }
            component.set('v.allowedForDependency', allowedForDependency);
        } catch(e) {
            console.log(e);
        }
    }
})