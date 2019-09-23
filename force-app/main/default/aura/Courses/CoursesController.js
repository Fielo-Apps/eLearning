({
    doInit : function(component, event, helper) {
        try{
            helper.getFields(component);
            helper.getSortByOptions(component);
            helper.getFilterFieldSet(component);
            helper.getCourseFieldSet(component);
            helper.getConfiguration(component);
        } catch(e) {
            console.log(e);
            component.set('v.error', e);
            component.set('v.showError', true);
        }
    },
    getFieldSet: function(component, event, helper) {
        try{
            helper.getFieldSet(component);
        } catch(e) {
            console.log(e);
        }
    },
    updateMember: function(component, event, helper){
        try{
            var currentMember = component.get('v.member');
            var member = event.getParam('member');
            component.set('v.member', member);
            if (currentMember) {
                if (currentMember.Id != member.Id) {
                    component.set('v.showCoursesList',false);
                }
                var spinner = $A.get("e.FieloPLT:ToggleSpinnerEvent");
                if(spinner){
                    spinner.setParam('show', false);
                    spinner.fire();    
                }
            }
            window.localStorage.setItem('member', JSON.stringify(member));
            helper.loadCourses(component, event, helper, 0);
            component.set('v.paging', false);
            component.set('v.paging', true);
        } catch(e) {
            console.log(e);
        }
    },
    handleFilterRecords: function(component, event, helper) {
        try{
            var dynamicFilterString = event.getParam('dynamicFilter');
            var sortByClause = event.getParam('sortByClause');
            component.set('v.dynamicFilterString', dynamicFilterString);
            component.set('v.sortByClause', sortByClause);
            helper.loadCourses(component, event, helper, 0);
            component.set('v.paging', false);
            component.set('v.paging', true);
        } catch(e) {
            console.log(e);
        }
    },
    handleCourseViewSelected: function(component, event, helper){
        try{
            console.log('handleCourseViewSelected');
            event.stopPropagation();
            var viewName = event.getParam('viewName');
            component.set('v.showFilter', false);
            component.set('v.showCoursesList', false);
            component.set('v.activeViewName', viewName);
            component.set('v.dynamicFilterString', null);
            component.set('v.sortByClause', null);
            $A.enqueueAction(component.get('c.getFieldSet'));
            $A.enqueueAction(component.get('c.loadCourses'));
            component.set('v.showFilter', true);
            component.set('v.paging', false);
            component.set('v.paging', true);
        } catch(e) {
            console.log(e);
        }
    },
    loadCourses: function(component, event, helper) {
        try{
            helper.loadCourses(component, event, helper, 0);
        } catch(e) {
            console.log(e);
        }
    },
    paginator: function(component, event, helper){
        try {
            var offset = event.getParam("offset");        
            helper.loadCourses(component, event, helper, offset);
        } catch(e) {
            console.log(e);
        }
    }
})