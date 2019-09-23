({
    doInit: function(component, event, helper) {
        try{
            var hasDetails = helper.hasDetails(component);
            component.set('v.hasDetails', hasDetails);
            component.set('v.tabsReady', true);
            if(!hasDetails) {
                var descriptionTab = component.find('descriptiontab');
                if (descriptionTab instanceof Array) {
                    descriptionTab = descriptionTab[0];
                }
                $A.util.addClass(descriptionTab, 'hide-tab');
            }
        } catch(e) {
            console.log(e);
        }
    },
    handleTabClick : function(component, event, helper) {
        try{
            var viewName = event.target.id;
            component.set('v.selectedView', viewName);
            helper.selectView(component);
            var registerFieldEvent = component.getEvent("courseViewSelected");
            registerFieldEvent.setParams({
                'viewName': viewName
            });
            registerFieldEvent.fire();
        } catch(e) {
            console.log(e);
        }
    },
    selectView : function(component, event, helper) {
        try{
            var params = event.getParam('arguments');
            if (params.viewName) {
                component.set('v.selectedView', params.viewName);
                helper.selectView(component);
            }
        } catch(e) {
            console.log(e);
        }
    }
});