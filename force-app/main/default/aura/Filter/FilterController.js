({
    doInit: function(component, event, helper) {
        try{
            var fieldset = component.get('v.fieldset');
            if (fieldset == null) {
                var objectName = component.get('v.objectName');
                var fieldList = component.get('v.filterFields');
                var rangedFields = component.get('v.rangedFields');
                var action = component.get('c.getFieldData');
                action.setParams({
                    'objectName': objectName,
                    'fieldNames': fieldList,
                    'rangedFields': rangedFields
                });
                action.setCallback(this, function(response) {
                    try{
                        var toastEvent = $A.get("e.force:showToast");
                        var spinner = $A.get("e.c:ToggleSpinnerEvent");
                        var state = response.getState();
                        if (component.isValid() && state === 'SUCCESS') {                    
                            var fieldMeta = JSON.parse(response.getReturnValue());
                            // console.log(JSON.stringify(fieldInfo, null, 2));
                            component.set('v.fieldset', fieldMeta.fields);
                            component.set('v.showFilter', true);
                            helper.getTypes(component);
                            helper.getFieldMap(component);
                        }else {
                            var errorMsg = response.getError()[0].message;
                            toastEvent.setParams({
                                "title": errorMsg,
                                "message": " ",
                                "type": "error"
                            });
                            toastEvent.fire(); 
                            if(spinner){
                                spinner.setParam('show', false);
                                spinner.fire();    
                            } 
                        }    
                    } catch(e) {
                        console.log(e);
                    }
                });
                $A.enqueueAction(action);      
            } else {
                component.set('v.showFilter', true);
                helper.getTypes(component);
                helper.getFieldMap(component);
            }
        } catch(e) {
            console.log(e);
        }
    },
    updFilterObjectEvt: function(component, event, helper) {
        event.stopPropagation();
    },
    filter: function(component, event, helper) {
        event.stopPropagation();
        var fields = component.get('v.fieldset');
        helper.getFilterObject(component);
        var filterObject = component.get('v.filterObject');
        var compEvent = component.getEvent("filterRecords");
        var whereClause;
        var dynamicFilter = '';
        if (filterObject) {
            whereClause = helper.assembleWhereClause(component, filterObject);
            dynamicFilter = helper.assembleDynamicFilter(component, filterObject);
        }
        var sortByClause = '';
        if (component.find('fielo-filter-sort-by')) {
            sortByClause = component.find('fielo-filter-sort-by').get('v.value');
        }
        var sortType = '';
        sortType = component.get('v.sortType');
        if (sortType) {
            sortByClause += ' ' + sortType;
        }
        
        sortByClause = sortByClause != null ? sortByClause : '';
        compEvent.setParams({
            "filterObject" : filterObject,
            "whereClause" : whereClause,
            "sortByClause" : sortByClause,
            "dynamicFilter": dynamicFilter
        });
        compEvent.fire();
    },
    registerComponent: function(component, event, helper) {
        event.stopPropagation();
    },
    changeSort: function(component, event, helper) {
        try{
            var iconName = component.get('v.iconName');
            if (iconName == 'utility:arrowdown') {
                component.set('v.iconName', 'utility:arrowup');
                component.set('v.sortType', 'ASC');
            } else {
                component.set('v.iconName', 'utility:arrowdown');
                component.set('v.sortType', 'DESC');
            }
            console.log('selectedValue: ' + component.find('fielo-filter-sort-by').get('v.value'));
        } catch(e) {
            console.log(e);
        }
    }
})