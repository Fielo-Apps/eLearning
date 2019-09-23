({
    doInit : function(component, event, helper){        
        var module = component.get('v.record');       
        var moduleResponses = module.moduleResponses;
        if(moduleResponses && moduleResponses.length > 0){
            component.set('v.label', 'Re-take');
            component.set('v.moduleResponse', moduleResponses[moduleResponses.length-1]);
            component.set('v.showModule', true);
        }
        component.set('v.takeModule', module.showBtn);    
    },
    takeModule: function(component, event, helper){
        var toastEvent = $A.get("e.force:showToast");
        var spinner = $A.get("e.c:ToggleSpinnerEvent");
        if(spinner){
            spinner.setParam('show', true);
            spinner.fire();    
        }           
        var member = window.localStorage.getItem('member');        
        if(member){                        
            var action = component.get('c.memberTakeModule');
            var moduleId = component.get('v.record').Id;
            action.setParams({
                'memberId': JSON.parse(member).Id,
                'moduleId': moduleId
            })
            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var takeModuleEvent = $A.get("e.c:TakeModuleEvent");
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var moduleWrapper = JSON.parse(response.getReturnValue());     
                    if(takeModuleEvent){
                        takeModuleEvent.setParam('module', moduleWrapper);
                        takeModuleEvent.fire();    
                    }
                }else {
                    var errorMsg = response.getError()[0].message;
                    toastEvent.setParams({
                        "title": errorMsg,
                        "message": " ",
                        "type": "error"
                    });
                    toastEvent.fire(); 

                }                
                if(spinner){
                    spinner.setParam('show', false);
                    spinner.fire();    
                }           
                
            });      
            // Send action off to be executed
            $A.enqueueAction(action);  
        }
    },
    showModule: function(component){
        var moduleResponse = component.get('v.moduleResponse');
        var moduleResponseEvent = $A.get("e.c:ShowModuleResponseEvent");        
        var moduleName = component.get('v.record').Name;
        if(moduleResponseEvent){            
            moduleResponseEvent.setParam('moduleResponse', moduleResponse);
            moduleResponseEvent.setParam('view', true);
            moduleResponseEvent.setParam('name', moduleName);
            moduleResponseEvent.fire();
        }                
    }
})