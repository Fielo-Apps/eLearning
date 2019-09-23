({
    doInit : function(component, event, helper) {
        var fieldset = [];
        var fieldsConfig = component.get('v.fields').trim();
        if (fieldsConfig == '') {
            fieldsConfig = 'Name';
        }
        var fieldsList = fieldsConfig.split(',');
        var nameAndType, apiName, type;
        fieldsList.forEach(function(fieldName) {
            if (fieldName=='Name') {
                fieldset.push({
                    "apiName": "Name",
                    "type": "subcomponent",
                    "subcomponent": "FieloELR:PickRecord",
                    "label": {
                        "type": "default"
                    },
                    "showLabel": true
                });     
            } else {
                nameAndType = field.split('/');
                apiName = nameAndType[0].trim();
                type = nameAndType[1] ? nameAndType[1].trim().toLowerCase() : 'output';
                fieldset.push({
                    'apiName': apiName,
                    'type': type,
                    'label': {
                        "type": "default"
                    },
                    'showLabel': true
                });
            }
        });
        component.set('v.fieldset', fieldset);
    },
    show: function(component,event,helper) {
        component.set('v.modalClass', 'slds-modal slds-fade-in-open');
        component.set('v.backDropClass', 'slds-backdrop slds-backdrop--open');
        var searchValue = component.get('v.searchValue');
        if (searchValue) {
            component.set('v.whereClause', 'Name Like \'\'%' + searchValue + '%\'\'');
            component.set('v.searchValue', null);
        }
        helper.loadResults(component, event, helper, 0);
    },
    hide: function(component,event,helper) {
        component.set('v.backDropClass', 'slds-backdrop');
        component.set('v.modalClass', 'slds-modal');
        component.set('v.searchValue', null);
    },
    paginator: function(component, event, helper) {
        event.stopPropagation();
        var offset = event.getParam("offset");
        helper.loadResults(component, event, helper, offset);
    },
    preventBubble: function(component, event, helper) {
        console.log('preventBubble');
        event.stopPropagation();
    },
    updateSearch: function(component, event, helper) {
        console.log('updateSearch');
        event.stopPropagation();
    },
    filterResults: function(component, event, helper) {
        event.stopPropagation();
        console.log('filterResults');
        var whereClause = event.getParam('whereClause');
        component.set('v.whereClause', whereClause);
        helper.loadResults(component, event, helper, 0);
    },
    optionSelected: function(component, event, helper) {
        var action = component.get('c.hide');
        $A.enqueueAction(action);
    }
})