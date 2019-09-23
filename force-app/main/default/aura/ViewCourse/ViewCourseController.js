({
    doInit: function(component, event, helper) {
        try{
            // CALCULATE IF VIEW COURSE OR VIEW RESULTS!!!
            var record = component.get('v.record');
            var config = component.get('v.config');
            var courseStatus;
            if (config.courseStatus) {
                courseStatus = config.courseStatus;
                if (courseStatus instanceof Array) {
                    courseStatus = courseStatus.filter(function(cs) {
                        return cs.FieloELR__Course__c == record.Id
                    });
                    if (courseStatus.length == 1) {
                        courseStatus = courseStatus[0];
                        if (courseStatus) {
                            if (courseStatus.FieloELR__Progress__c && courseStatus.FieloELR__Progress__c == 100) {
                                component.set('v.viewResults', true);
                            }
                            if (courseStatus.FieloELR__Progress__c && courseStatus.FieloELR__Progress__c > 0) {
                            	if (record.FieloELR__Status__c == 'Completed') {
	                                component.set('v.viewResults', true);
	                            }
                            }
                        }
                        
                    }
                }
            }
        } catch(e) {
            console.log(e);
        }
    },
    gotoDetail : function(component, event, helper) {
        try{
            var viewResults = component.get('v.viewResults');
            if (Boolean(viewResults)) {
                window.localStorage.setItem('viewResults', viewResults);
            }
            $A
            .get("e.force:navigateToSObject")
            .setParams({
                "recordId": component.get('v.record').Id,
                "slideDevName": "detail"
            })
            .fire();
        } catch(e) {
            console.log(e);
        }
    }
})