({
    doInit: function(component, event, helper) {
        try{
            var record = component.get('v.record');
            var config = component.get('v.config');
            helper.getNextModule(component);
            helper.getAllowedForDependency(component);
            var nextModule = component.get('v.nextModule');
            var order;
            if (nextModule) {
                order = String(nextModule.FieloELR__Order__c);
				component.set('v.moduleId', nextModule.Id);
                component.set('v.moduleNumber', order);
            }
        } catch(e) {
            console.log(e);
        }
    },
    gotoModuleDetail: function(component, event, helper) {
        try{
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.moduleId')
            });
            navEvt.fire();
        } catch(e) {
            console.log(e);
        }
    },
    callJoinCourse: function(component, event, helper) {
        try{
            var spinner = $A.get("e.c:ToggleSpinnerEvent");
            if(spinner){
                spinner.setParam('show', true);
                spinner.fire();    
            }           

            var record = component.get('v.record');
            var action = component.get('c.joinCourse');
            
            action.setParams({
                'memberId': component.get('v.config.memberId'),
                'courseId': record.Id
            });
            
            action.setCallback(this, function(response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var toastEvent = $A.get("e.force:showToast");
                var state = response.getState();                
                if (component.isValid() && state === 'SUCCESS') {                    
                    var courseId = response.getReturnValue();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": courseId
                    });
                    navEvt.fire();  
                }else {
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
    }
})