({
    doInit: function(component, event, helper) {
        try{
            var currentModuleReponseId = window.localStorage.getItem('currentModuleReponseId');
            if (currentModuleReponseId) {
                component.set('v.moduleInProgress', true);
                window.localStorage.setItem('currentModuleReponseId','');
            }
            helper.getConfig(component);
            helper.getModuleFieldsData(component);
            helper.getModuleResponseFieldsData(component);
        } catch(e) {
            console.log(e);
        }
    },
    updateMember: function(component, event, helper){
        try{
            var currentMember = component.get('v.member');
            var member = event.getParam('member');
            if (currentMember) {
                var spinner = $A.get("e.FieloPLT:ToggleSpinnerEvent");
                if(spinner){
                    spinner.setParam('show', false);
                    spinner.fire();    
                }
                if (currentMember.Id != member.Id) {
                    $A
                    .get("e.force:navigateToObjectHome")
                    .setParams({"scope": "FieloELR__Course__c"})
                    .fire();
                }
            } else {
            	component.set('v.member', member);
            	window.localStorage.setItem('member', JSON.stringify(member));
                helper.getModuleData(component);
            }
        } catch(e) {
            console.log(e);
        }
    },
    backToCourses: function(component, event, helper) {
        try{
            $A
            .get("e.force:navigateToObjectHome")
            .setParams({"scope": "FieloELR__Course__c"})
            .fire();
        } catch(e) {
            console.log(e);
        }
    },
    backToParentCourse: function(component, event, helper) {
        try{
            $A
            .get("e.force:navigateToSObject")
            .setParams({"recordId": component.get('v.course').Id})
            .fire();
        } catch(e) {
            console.log(e);
        }
    },
    toggleContent: function(component, event, helper){
        try{
            component.set('v.isCollapsed', !component.get('v.isCollapsed'));
        } catch(e) {
            console.log(e);
        }
    }
})