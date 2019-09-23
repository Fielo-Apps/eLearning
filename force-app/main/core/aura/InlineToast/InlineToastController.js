({
	showToast: function(component, event, helper) {
		helper.config(component, event.getParam('arguments').newConfig);
		helper.show(component);
	}
})