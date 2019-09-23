({
    updateMember: function(component, event, helper){
        try{
            var member = event.getParam('member');
            component.set('v.member', member);       
            window.localStorage.setItem('member', JSON.stringify(member));
            helper.loadCourseStatus(component);
        } catch(e) {
            console.log(e);
        }
    },
    toggleAll: function(component, event, helper){
        try{
            var isCollapsed = component.get('v.isCollapsed');
            var cards = component.find('module-card');
            if (cards) {
                if (cards instanceof Array) {
                    if (cards.length > 0) {
                        cards.forEach(function(cardComponent) {
                            cardComponent.toggle(!isCollapsed);
                        });
                        component.set('v.isCollapsed', !isCollapsed);
                    }    
                } else {
                    cards.toggle(!isCollapsed);
                    component.set('v.isCollapsed', !isCollapsed);
                }
            }
        } catch(e) {
            console.log(e);
        }
    },
    handleCourseViewSelected: function(component, event, helper) {
        try{
            event.stopPropagation();
            var viewName = event.getParam('viewName');
            component.set('v.activeViewName', viewName);
        } catch(e) {
            console.log(e);
        }
    }
})