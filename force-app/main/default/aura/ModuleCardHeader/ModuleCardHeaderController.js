({
    doInit: function(component, event, helper) {
        try{
            var record = component.get('v.record');
            var moduleHeaderText = '' +
                $A.get('$Label.c.Module') + ' ' +
                record.FieloELR__Order__c + ': <b>' +
                record.Name + '</b>';
            component.find('moduleHeaderText').set('v.value', moduleHeaderText);
            component.set('v.moduleName', record.Name);
        } catch(e) {
            console.log(e);
        }
    },
    toggleModuleContent: function(component, event, helper) {
        try{
            var iconName = component.get('v.iconName');
            if (iconName == 'utility:chevronright') {
                iconName = 'utility:chevrondown';
            } else {
                iconName = 'utility:chevronright';
            }
            component.set('v.iconName', iconName);
            var compEvent = component.getEvent("toggleModuleContent");
            compEvent.fire();
        } catch(e) {
            console.log(e);
        }
    },
    goToModuleDetail: function(component, event, helper) {
        try{
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.record').Id
            });
            navEvt.fire();
        } catch(e) {
            console.log(e);
        }
    }
})