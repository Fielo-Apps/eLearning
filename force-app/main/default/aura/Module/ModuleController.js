({
    doInit: function(component, event, helper){
        var module = component.get('v.module');                        
  		component.set('v.questions', module.questions);
        component.set('v.showQuestions', true);
        helper.loadContent(component, event, helper);        
    }
})