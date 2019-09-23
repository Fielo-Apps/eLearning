({
    doInit : function(component, event, helper) {        
        var config = component.get('v.config');
        var record = component.get('v.record');
        if (config) {
            var days, endLabel, label;
            var startDate = new Date(record[config.startDate]);
            var endDate = new Date(record[config.endDate]);
            var today = new Date();
            if (today < startDate) {                
                days = Math.round((startDate - today)/(1000*60*60*24));
                endLabel = ' to begin';                
            } else if (today < endDate) {
                var days = Math.round((endDate - today)/(1000*60*60*24));
                endLabel = ' left';
                if (days <= 5) {
                    component.set('v.daysColor', 'yellow');
                } else {
                    component.set('v.daysColor', 'green');
                }
            }                            
            if (days == 1) {
                label = days + ' day' + endLabel; 
            } else {
                label = days + ' days' + endLabel;
            }
            if (days) {
                component.set('v.days', label);
            }            
            component.set('v.startDate', record[config.startDate]);
            component.set('v.endDate', record[config.endDate]);
            component.set('v.disabled', today < startDate);
        }
        
    }
})