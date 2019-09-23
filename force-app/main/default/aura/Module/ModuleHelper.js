({
    loadContent : function(component, event, helper) {
        var contentField = component.get('v.moduleContent');
        var moduleId = component.get('v.module').module.Id;        
        if(contentField){            
            var contentType = contentField.type;
            contentField = contentField.field;            
            component.set('v.contentFieldName', contentField);
            var getContent = component.get('c.getContent');            
            getContent.setParams({
                'contentField': contentField,
                'contentType': contentType,
                'moduleId': moduleId
            })
            // Add callback behavior for when response is received
            getContent.setCallback(this, function(response) {
                var state = response.getState();                
                if (component.isValid() && state === 'SUCCESS') {                                        
                    var moduleResponse = response.getReturnValue();                    
                    component.set('v.content', moduleResponse);
                    if (moduleResponse[contentType]) {
                        component.set('v.contentType', moduleResponse[contentType].toLowerCase().trim().replace(' ', '-'));    
                    }                    
                    if(moduleResponse[contentField]){
                        component.set('v.showContent', true);                                            
                    }                                        
                }else {
                    console.log('Failed with state: ' + state);
                }
            });      
            
            $A.enqueueAction(getContent);
        }
    }
    
})