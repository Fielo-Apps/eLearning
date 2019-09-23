({
    handleTabClick : function(component, event, helper) {
        try{
            var viewName = event.target.id;
            if (viewName == 'availableCourses') {
                $A.util.removeClass(component.find('mycoursestab'), 'slds-is-active');
                $A.util.addClass(component.find('availablecoursestab'), 'slds-is-active');
            } else {
                $A.util.addClass(component.find('mycoursestab'), 'slds-is-active');
                $A.util.removeClass(component.find('availablecoursestab'), 'slds-is-active');
            }
            var registerFieldEvent = component.getEvent("courseViewSelected");
            registerFieldEvent.setParams({
                'viewName': viewName
            });
            registerFieldEvent.fire();
        } catch(e) {
            console.log(e);
        }
    }
})