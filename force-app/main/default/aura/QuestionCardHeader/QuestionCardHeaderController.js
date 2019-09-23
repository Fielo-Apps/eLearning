({
    doInit: function(component, event, helper) {
        try{
            var record = component.get('v.record');
            var questionNumber = component.get('v.questionNumber');
            var showQuestionName = component.get('v.showQuestionName');
            
            var questionHeaderText = '<b>' +
                $A.get('$Label.c.Question') + ' ' +
                questionNumber + '</b>';
            if (showQuestionName) {
                questionHeaderText += ': ' + record.Name;
            }
            component.find('questionHeaderText').set('v.value', questionHeaderText);   
            component.set('v.questionName', record.Name);
        } catch(e) {
            console.log(e);
        }
    },
    toggleQuestionContent: function(component, event, helper) {
        try{
            var iconName = component.get('v.iconName');
            if (iconName == 'utility:chevronright') {
                iconName = 'utility:chevrondown';
            } else {
                iconName = 'utility:chevronright';
            }
            component.set('v.iconName', iconName);
            var compEvent = component.getEvent("toggleQuestionContent");
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