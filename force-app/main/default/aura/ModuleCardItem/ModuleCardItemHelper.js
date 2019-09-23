({
    getFirstApproveModuleResponse: function(component) {
        try{
            var moduleResponses = component.get('v.moduleResponses');
            var moduleWrapper = component.get('v.moduleWrapper');
            var passed = moduleWrapper.isApproved;
            if (moduleResponses) {
                if (passed) {
                    moduleResponses = moduleResponses.filter(function(mr) {
                        return mr.FieloELR__Module__c == moduleWrapper.module.Id &&
                            mr.FieloELR__IsApproved__c &&
                            mr.FieloELR__NumberofApprove__c == 1;
                    });
                }
            }
            if (moduleResponses) {
                if (moduleResponses.length == 1) {
                    component.set('v.firstApproveModuleResponse', moduleResponses[0]);
                }
            }
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
        } catch(e) {
            console.log(e);
        }
    }
})