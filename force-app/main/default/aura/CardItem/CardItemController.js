({
	doInit : function(component, event, helper) {        
        var images = [];        
        var fieldset = component.get('v.fieldset');
        var record = component.get('v.record');
        fieldset.forEach(function(field){
            if (field.type && field.type.toLowerCase() == 'image') {
                images.push(field);
            }
        });
        component.set('v.imageFields', images);        
        component.set('v.showImages', images.length > 0);
        helper.checkDescrpDate(component);
	}
})