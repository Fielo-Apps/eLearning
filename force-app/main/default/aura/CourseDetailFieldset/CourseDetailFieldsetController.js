({
	doInit : function(component, event, helper) {
        try{
            helper.setFields(component);
        } catch(e) {
            console.log(e);
        }
	}
})