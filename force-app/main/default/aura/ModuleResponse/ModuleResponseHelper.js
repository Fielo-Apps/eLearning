({
    loadQuestionResponses : function(component) {
        var questionsModule = [];
        var moduleResponse = component.get('v.moduleResponseQuestions');
        var questions = moduleResponse.questions;                
        questions.forEach(function(ques){            
            var newQuestion = {};
            newQuestion = ques.question;            
            newQuestion.FieloELR__IsCorrect__c = ques.questionResponse.FieloELR__IsCorrect__c;                
            if(newQuestion.FieloELR__Type__c == 'Short Answer'){
                newQuestion.FieloELR__TextValue__c = ques.questionResponse.FieloELR__TextValue__c;
            }else{
                newQuestion.Answers = ques.questionResponse.FieloELR__Answers__r.records;               
            }
            newQuestion.FieloELR__PartialGradeValue__c = ques.questionResponse.FieloELR__PartialGradeValue__c;
            questionsModule.push(newQuestion);
        });      
        component.set('v.questionsModule', questionsModule);
        component.set('v.showAnswers', true);
    },
    getLabels: function(component, event, helper) {
        var fieldset = component.get('v.fieldset');
        var labelValues = component.get("c.getFieldLabels");        
        // Add callback behavior for when response is received
        labelValues.setCallback(this, function(response) {
            var state = response.getState();        
            if (component.isValid() && state === "SUCCESS") {
                //success                
                var fieldLabels = response.getReturnValue();                    
                fieldset.forEach(function(field){                    
                    var labelType = field.label ? field.label.type : 'default';
                    if(labelType == 'default'){                        
                        field.label = fieldLabels[field.apiName];
                    } else if(labelType == 'label'){
                        var customLabel = '$Label.' + field.label.value;                                         
                        field.label = $A.get(customLabel);
                    }else{
                        field.label = field.label.value;
                    }                    
                })
                component.set('v.showDetail', true);
            } else {
                var errorMsg = response.getError()[0].message;
                toastEvent.setParams({
                    "title": errorMsg,
                    "message": " ",
                    "type": "error"
                });
                toastEvent.fire();                     
            }     
        });            
        // Send action off to be executed
        
        $A.enqueueAction(labelValues);      
    }
})