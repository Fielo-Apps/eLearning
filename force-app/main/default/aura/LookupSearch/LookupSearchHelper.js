({
    loadResults: function(component, event, helper, offset) {
        var spinner = $A.get("e.c:ToggleSpinnerEvent");
        if(spinner){
            spinner.setParam('show', true);
            spinner.fire();    
        }
        var fields = component.get('v.fields');
        var sObjectName = component.get('v.sObjectName');
        var whereClause = component.get('v.whereClause');
        var quantity = 10;
        var orderBy = 'Name';
        var action = component.get('c.getRecords');
        var params = {};
        params.fields = fields;
        params.sObjectName = sObjectName;
        params.whereClause = whereClause ? whereClause : '';
        params.quantity = (quantity ? quantity : 6) + 1;
        params.offset = offset > 0 && offset != null ? offset : 0;
        params.orderBy = orderBy;
        
        action.setParams(params);
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var spinner = $A.get("e.c:ToggleSpinnerEvent");
            var toastEvent = $A.get("e.force:showToast");
            var state = response.getState();
            //  console.log(JSON.stringify(response.getReturnValue(), null, 2));
            if (component.isValid() && state === 'SUCCESS') {                    
                var results = response.getReturnValue();
                if (results.length == 1) {
                    var registerFieldEvent = component.getEvent("selectOption");
                    registerFieldEvent.setParams({
                        'record': results[0]
                    });
                    registerFieldEvent.fire();
                }
                component.set('v.results', results);
            }else {
                var errorMsg = response.getError()[0].message;
                toastEvent.setParams({
                    "title": "loadProducts: " + errorMsg,
                    "message": " ",
                    "type": "error"
                });
                toastEvent.fire(); 
            }
            if(spinner){
                spinner.setParam('show', false);
                spinner.fire();    
            }
        });      
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})