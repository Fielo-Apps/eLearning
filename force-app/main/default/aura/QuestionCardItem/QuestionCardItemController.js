({
	doInit: function(component, event, helper) {
		
	},
    toggleQuestionContent: function(component, event, helper) {
        try{
            if (event) {
                event.stopPropagation();    
            }
            component.set('v.showQuestionContent', !component.get('v.showQuestionContent'));
        } catch(e) {
            console.log(e);
        }
    },
    toggleContent: function(component, event, helper) {
        try{
            var params = event.getParam('arguments');
            if (params.collapse != null) {
                component.set('v.showQuestionContent', !params.collapse);
                if (component.get('v.showQuestionContent') ) {
                    component.set('v.iconName', 'utility:chevrondown');
                } else {
                    component.set('v.iconName', 'utility:chevronright');
                }
            }
        } catch(e) {
            console.log(e);
        }
    },
    getAnswers: function(component, event, helper) {
        try{
            var questionComp = component.find('question-component');
            if (questionComp) {
                questionComp.getAnswers();
                component.set('v.answers', questionComp.get('v.answers'));
                component.set('v.textValue', questionComp.get('v.textValue'));
            }
        } catch(e) {
            console.log(e);
        }
    }
})