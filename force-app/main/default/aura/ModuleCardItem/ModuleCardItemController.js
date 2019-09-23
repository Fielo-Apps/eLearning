({
    doInit: function(component, event, helper) {
        try{
            helper.getFirstApproveModuleResponse(component);
            helper.getLastModuleResponse(component);
            var moduleWrapper = component.get('v.moduleWrapper');
            var nextModuleInCourse = component.get('v.nextModuleInCourse');
            var showModuleContent = false;
            if (nextModuleInCourse == moduleWrapper.module.Id) {
                showModuleContent = true;
            }
            if (moduleWrapper.isApproved) {
                showModuleContent = true;
            }
            if (showModuleContent) {
                component.set('v.showModuleContent', showModuleContent);
                component.set('v.iconName', 'utility:chevrondown');
            }
            
        } catch(e) {
            console.log(e);
        }
    },
    toggleModuleContent: function(component, event, helper) {
        try{
            if (event) {
                event.stopPropagation();    
            }
            component.set('v.showModuleContent', !component.get('v.showModuleContent'));
        } catch(e) {
            console.log(e);
        }
    },
    toggleContent: function(component, event, helper) {
        try{
            var params = event.getParam('arguments');
            if (params.collapse != null) {
                component.set('v.showModuleContent', !params.collapse);
                if (component.get('v.showModuleContent') ) {
                    component.set('v.iconName', 'utility:chevrondown');
                } else {
                    component.set('v.iconName', 'utility:chevronright');
                }
            }
        } catch(e) {
            console.log(e);
        }
    }
})