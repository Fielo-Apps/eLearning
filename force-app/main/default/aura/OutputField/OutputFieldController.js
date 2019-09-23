({
    doInit : function(component, event, helper) {
        var type = component.get('v.type');
        var record = component.get('v.record');
        var fieldName = component.get('v.fieldName');
        if(fieldName){
            fieldName = fieldName.split('.');
            var content = record[fieldName[0]];
            if(content){
                for(var i = 1; i < fieldName.length; i++){
                    content = content[fieldName[i]] ;
                }
            }

            component.set('v.content', content);
        }
        if(!type || type === '') {
            component.set('v.type', 'output')
        }
        if(type == 'subcomponent'){
            component.set('v.showSubcomponent', true);
        }

    }
})