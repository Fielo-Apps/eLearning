({
	doInit : function(component, event, helper) {
        var record = component.get('v.record');
        var icon = record.isApproved ? 'action:approval' : 'action:close';
        component.set('v.icon', icon);
	}
})