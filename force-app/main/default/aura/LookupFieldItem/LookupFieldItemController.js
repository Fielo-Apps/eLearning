({
    selectOption: function(component, event, helper) {
        try{
            var registerFieldEvent = component.getEvent("selectOption");
            registerFieldEvent.setParams({
                'record': component.get('v.option')
            });
            registerFieldEvent.fire();
        } catch(e) {
            console.log(e);
        }
    }
})