({
    selectView: function(component) {
        try{
            var viewName = component.get('v.selectedView');
            if (viewName == 'detail') {
                $A.util.removeClass(component.find('modulestab'), 'slds-is-active');
                $A.util.addClass(component.find('descriptiontab'), 'slds-is-active');
            } else {
                $A.util.addClass(component.find('modulestab'), 'slds-is-active');
                $A.util.removeClass(component.find('descriptiontab'), 'slds-is-active');
            }    
        } catch(e) {
            console.log(e);
        }
    },
    hasDetails: function(component) {
        try{
            var course = component.get('v.course');
            var courseFields = component.get('v.courseDetailFields');
            courseFields = courseFields.split(',');
            var hasDetails = true;
            hasDetails = courseFields.some(function(fieldName) {
               return course[fieldName] != null &&
                   course[fieldName] != undefined &&
                   course[fieldName] != '';
            });
            return hasDetails;
        } catch(e) {
            console.log(e);
        }
    }
})