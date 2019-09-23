({
    doInit : function(component, event, helper) {
        try{
            console.log('FieldsSection.doInit');
            var config = JSON.parse(component.get('v.config'));
            var activeViewName = config.activeViewName;
            if (config.courseStatus) {
                var courseStatus = JSON.parse(config.courseStatus);
            }
            var record = component.get('v.record');
            var course = [];
            var courseField = {};
            if (config.fields) {
                var fields = config.fields.split(',');
                var pointsEarned = 0;
                var pointField;
                fields.forEach(function(field) {
                    courseField = {};
                    if (field == 'FieloELR__Modules__r') {
                        courseField.label = $A.get('$Label.c.Modules');
                        if (record[field]) {
                            if (record[field].records) {
                                courseField.value = record[field].records.length;
                            }
                        }
                        course.push(courseField);
                    } else if (activeViewName != 'availableCourses' && (field == 'FieloELR__Transactions__r' || field == 'FieloELR__Trackers__r')) {
                        if (!pointField) {
                            pointField = {};
                            pointField.label = $A.get('$Label.c.PointsEarned');
                        }
                        if (!pointsEarned) {
                            pointsEarned = 0;
                        }
                        if (courseStatus) {
                            if (courseStatus[field]) {
                                if (courseStatus[field].records) {
                                    courseStatus[field].records.forEach(function(row) {
                                        if (field == 'FieloELR__Transactions__r') {
                                            if (row.FieloPLT__Points__c) {
                                                pointsEarned += row.FieloPLT__Points__c;    
                                            }
                                        } else {
                                            if (row.FieloPLT__Transaction__r) {
                                                if (row.FieloPLT__Transaction__r.FieloPLT__Points__c) {
                                                    pointsEarned += row.FieloPLT__Transaction__r.FieloPLT__Points__c;
                                                }
                                            }
                                        }
                                    });
                                    pointField.value = pointsEarned;;
                                }
                            }
                        }
                    }
                });
                if (pointField){
                    course.push(pointField);
                }
                component.set('v.fields', course);
                
                if(record.FieloELR__Status__c) {
                    if (record.FieloELR__Status__c == 'Scheduled') {
                        component.set('v.className', ' fielo-section--scheduled');
                    } else {
                        component.set('v.className', ' fielo-section--active');
                    }
                    
                }
            }    
        } catch(e) {
            console.log(e);
        }
    }
})