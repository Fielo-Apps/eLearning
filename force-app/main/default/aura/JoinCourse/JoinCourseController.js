({
    doInit : function(component, event, helper){        
        var course = component.get('v.record');
        var memberId = JSON.parse(window.localStorage.getItem('member')).Id;
        var courseCache = JSON.parse(window.localStorage.getItem('coursesStatus'));  
        
        component.set('v.join', courseCache[memberId][course.Id]);        
    },
    joinCourse : function(component, event, helper) {         
        var toastEvent = $A.get("e.force:showToast");
        var course = component.get('v.record');
        var courseId = course.Id;
        var courseName = course.Name;
        var memberId = JSON.parse(window.localStorage.getItem('member')).Id;
        
        if(memberId && courseId){       
            var spinner = $A.get("e.c:ToggleSpinnerEvent");
            if(spinner){
                spinner.setParam('show', true);
                spinner.fire();    
            }    
            var joinCourseAction = component.get('c.memberJoinCourse');
            joinCourseAction.setParams({
                'memberId': memberId,
                'courseId': courseId
            })
            // Add callback behavior for when response is received
            joinCourseAction.setCallback(this, function(response) {
                var course = component.get('v.record');
                var spinner = $A.get("e.c:ToggleSpinnerEvent");
                var state = response.getState();                
                if (component.isValid() && state === 'SUCCESS') {                    
                    var joinLabel = $A.get("$Label.c.Join");
                    toastEvent.setParams({
                        "title": joinLabel + " " + courseName + "!",
                        "message": " ",
                        "type": "success"
                    });
                    toastEvent.fire();                    
                    component.set('v.join', false);
                    var courseCache = JSON.parse(window.localStorage.getItem('coursesStatus'));
                    courseCache[memberId][courseId] = false;
                    window.localStorage.setItem('coursesStatus', JSON.stringify(courseCache));
                    
                    var recordEvent = component.getEvent("showRecord");
                    var record = component.get('v.record');
                    if(recordEvent){
                        recordEvent.setParams({'record': record});
                        recordEvent.fire();
                    }

                }else {
                    var errorMsg = response.getError()[0].message;
                    toastEvent.setParams({
                        "title": errorMsg,
                        "message": " ",
                        "type": "error"
                    });
                    toastEvent.fire(); 
                    
                }
                if(spinner){
                    spinner.setParam('show', false);
                    spinner.fire();
                }
            });      
            // Send action off to be executed
            $A.enqueueAction(joinCourseAction);   
        }
        
    }
})