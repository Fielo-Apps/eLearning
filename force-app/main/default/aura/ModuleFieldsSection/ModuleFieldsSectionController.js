({
    doInit: function(component, event, helper) {
        try{
			var fieldsMeta = component.get('v.fieldsMeta');
            if (fieldsMeta) {
                helper.getFieldsMetaMap(component);
                helper.setFieldValues(component);
            }
        } catch(e) {
            console.log(e);
        }
    },
    setFieldValues: function(component, event, helper) {
        try{
            helper.getFieldsMetaMap(component);
            helper.setFieldValues(component);
        } catch(e) {
            console.log(e);
        }
    }
})