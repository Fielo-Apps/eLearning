({
	doInit: function(component, event, helper) {
        var location = component.get('v.location');
        if (location == 'header') {
            helper.getHeaderActions(component);
        } else if (location == 'body') {
            helper.getBodyActions(component);
        }
		
	},
    callTakeModule: function(component, event, helper) {
        try{
            helper.callTakeModule(component);
        } catch(e) {
            console.log(e);
        }
    },
    callViewResults: function(component, event, helper) {
        try{
            helper.viewResults(component);
        } catch(e) {
            console.log(e);
        }
    },
    callViewModule: function(component, event, helper) {
        try{
            helper.viewModule(component);
        } catch(e) {
            console.log(e);
        }
    }
})