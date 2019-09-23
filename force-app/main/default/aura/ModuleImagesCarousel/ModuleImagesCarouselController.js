({
	doInit : function(component, event, helper) {
        try{
            component.set('v.urlList', component.get('v.urls').split(','));
        } catch(e) {
            console.log(e);
        }
	}
})