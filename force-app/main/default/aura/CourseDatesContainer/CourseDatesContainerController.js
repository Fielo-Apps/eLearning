({
    doInit: function(component, event, helper) {
        try{
            var config = JSON.parse(component.get('v.config'));
            var record = component.get('v.record');
            var newDateRange = 0;
            if (config) {
                if (config.daysToBeConsideredNew && record.FieloELR__StartDatetime__c) {
                    var startDate = new Date(record.FieloELR__StartDatetime__c);
                    var today = new Date();
                    var timeDiff = Math.abs(today.getTime() - startDate.getTime());
                    var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
                    component.set('v.isNew', diffDays <= config.daysToBeConsideredNew);
                }
            }
            if (record.FieloELR__EndDatetime__c) {
                var endDate = new Date(record.FieloELR__EndDatetime__c);
                var today = new Date();
                var timeDiff = Math.abs(endDate.getTime() - today.getTime());
                var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
                component.set('v.daysLeft', diffDays);
                if (config.daysToBeConsideredWarning) {
                    if (diffDays <= Number(config.daysToBeConsideredWarning)) {
                        component.set('v.className', 'fielo-font--warning');
                    } else {
                        component.set('v.className', 'fielo-font--early');
                    }
                }
            }
            if (record.FieloELR__Status__c == 'Scheduled') {
                var startDate = new Date(record.FieloELR__StartDatetime__c);
                var today = new Date();
                var timeDiff = Math.abs(startDate.getTime() - today.getTime());
                var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
                component.set('v.startsIn', $A.get('$Label.c.StartsIn').replace('\{0\}',String(diffDays)));
                component.set('v.className', '');
            }

            if (record.FieloELR__StartDatetime__c) {
                component.set('v.startDate', $A.localizationService.formatDate(record.FieloELR__StartDatetime__c));
            }
            if (record.FieloELR__EndDatetime__c) {
                component.set('v.endDate', $A.localizationService.formatDate(record.FieloELR__EndDatetime__c));
            }
        } catch(e) {
            console.log(e);
        }
    }
})