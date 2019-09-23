({
    show: function(component) {
        try{
            var combobox = component.find('fielo-lookup-combobox');
            if (component.find('fielo-lookup-input')) {
                // The second time it renders due to the aura:if evaluation, mysteriously it becomes an array.
                var input = component.find('fielo-lookup-input').length == undefined ? component.find('fielo-lookup-input') : component.find('fielo-lookup-input')[0];
                if (input.getElements()) {
                    input.getElements()[0].autocomplete = 'off';
                }
            }
            $A.util.addClass(combobox, 'slds-is-open');
        } catch(e) {
            console.log(e);
        }
    },
    hide: function(component) {
        try{
            var combobox = component.find('fielo-lookup-combobox');
            $A.util.removeClass(combobox, 'slds-is-open');
        } catch(e) {
            console.log(e);
        }        
    },
    getInput: function(component) {
        if (component.find('fielo-lookup-input')) {
            // The second time it renders due to the aura:if evaluation, mysteriously it becomes an array.
            var input = component.find('fielo-lookup-input').length == undefined ? component.find('fielo-lookup-input') : component.find('fielo-lookup-input')[0];
            input = input.getElements()[0];
        }
        return input;
    },
    selectOption: function(component, record) {
        try{
            var input = component.find('fielo-lookup-input');
            var formElement = component.find('fielo-lookup-combobox-form-element');
            component.set('v.selectedRecord', record);
            var handleChangeMethod = component.get('c.handleChange');
            $A.enqueueAction(handleChangeMethod);
        }catch(e) {
            console.log(e);
        }
    },
    filterOptions: function(component, searchValue) {
        try{
            var searchValue = component.get('v.searchValue');
            var records = this.getCachedOptions(component);
            var filteredResults = records.filter(function(record) {
                return record.Name.toLowerCase().indexOf(searchValue.toLowerCase()) != -1;
            });
            if (filteredResults.length==0) {
                this.hide(component);
            }
            component.set('v.options', filteredResults);   
        } catch(e) {
            console.log(e);
        }
    },
    refreshOptions: function(component) {
        var records = this.getCachedOptions(component);
        if (records) {
            component.set('v.options', records);   
        }
    },
    getCachedOptions: function(component) {
        try{
            var objectName = component.get('v.field').attributes.objectName;
            var fieldName = component.get('v.field').attributes.name;
            var fieldKey = objectName + '.' + fieldName;
            var recordsJson = localStorage.getItem(fieldKey);
            if (recordsJson) {
                var records = JSON.parse(recordsJson);
                return records;
            } else {
                return null;
            }
        } catch(e) {
            console.log(e);
        }
        return null;
    }
})