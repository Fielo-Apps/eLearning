({    
    doInit : function(component, event, helper) {        
        var paging = component.get('v.paging');
        if(typeof paging == 'undefined'){
            paging = true;
        }
        component.set('v.paging', paging);
        var quantity = component.get('v.quantity') || 5;
        component.set('v.quantity', quantity);        
        helper.getLabels(component, event, helper);        
        var records = component.get('v.records');
        if(records ){
            helper.setRecords(component, event);
        } else {
            helper.queryRecords(component, event, helper);
        }
    },
    toggleLayout: function(component, event, helper){
        var layout = component.get('v.layout');
        if (layout.toLowerCase() == 'table'){
            layout = 'grid';
        } else {
            layout = 'table';
        }
        component.set('v.layout', layout);
    },
    updateRecords: function(component, event, helper){
        helper.setRecords(component, event);
    },
    dismissDetail: function(component, event, helper){
        component.set('v.recordDetail', null);
        component.set('v.showRecord', false);       
    },
    showRecordDetail: function(component, event, helper){        
        component.set('v.showRecord', true);
    },
    back: function(component, event, helper){
        component.set('v.showRecord', false);
    }
})