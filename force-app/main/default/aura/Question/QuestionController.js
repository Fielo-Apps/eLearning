({
    doInit : function(component, event, helper) {        
        var question = component.get('v.question');        
        component.set('v.title', question.FieloELR__QuestionText__c);
        component.set('v.options', question.FieloELR__AnswerOptions__r.records);        
        var type = component.get('v.type');
        if (type == 'Matching Options') {
            var matchingTextList = [];
            var options = [];
            var i = 1;
            question.FieloELR__AnswerOptions__r.records.forEach(function(option){
                if (matchingTextList.indexOf(option.FieloELR__MatchingText__c) == -1) {
                    options.push({
                        label: option.FieloELR__MatchingText__c,
                        value: option.FieloELR__MatchingText__c
                    });
                    matchingTextList.push(option.FieloELR__MatchingText__c);
                }
                i++; 
            });
            component.set('v.matchingTextList', matchingTextList);
            component.set('v.matchingOptions', options);
        }
        if(component.get('v.mode') == 'view'){
            component.set('v.isCorrect', question.FieloELR__IsCorrect__c);
            component.set('v.className', 'disabled');
            
            if (type == 'Short Answer'){
                component.set('v.shortAnswer', question.FieloELR__TextValue__c);
            } else if (type == 'Matching Options'){
                var answers = {};
                var matchingAnswer = [];
                question.Answers.forEach(function(answer){                    
                    answers[answer.FieloELR__AnswerOption__c] = answer.FieloELR__TextValue__c;
                });                
                question.FieloELR__AnswerOptions__r.records.forEach(function(ans){                    
                    var newAnswer = ans.FieloELR__AnswerOptionText__c + ' -> ' + answers[ans.Id];
                    matchingAnswer.push(newAnswer);
                });                
                component.set('v.matchingAnswer', matchingAnswer);
            } else {
                question.Answers.forEach(function(answer){                    
                    var id = answer.FieloELR__AnswerOption__c;
                    question.FieloELR__AnswerOptions__r.records.forEach(function(ans){
                        if(!ans.isSelected){
                            ans.isSelected = ans.Id == id ? true : false;
                        }
                        
                    })
                })                
            }            
        }
        component.set('v.renderQuestion', true);
    },
    getAnswers: function(component, event, helper) {
        try {
            var type = component.get('v.type');
            var answers = [];
            var answersOptions;
            if (type == 'Single Choice' || type == 'Multiple Choice' || type == 'Statement') {
                answersOptions = component.find('fielo-answer-option');
                answersOptions = answersOptions.filter(function(ao) {
                    return ao.get('v.checked') == true;
                });
                answersOptions.forEach(function(ao) {
                    answers.push({'FieloELR__AnswerOption__c':ao.get('v.value')});
                });
                component.set('v.answers', answers);
            } else if (type == 'Matching Options') {
                answersOptions = component.find('fielo-answer-option');
                answersOptions.forEach(function(ao) {
                    var optionId = ao.get('v.body')[2].get('v.body')[0];
                    var matchingText = ao.get('v.body')[1].get('v.body')[0];
                    answers.push({
                        'FieloELR__AnswerOption__c': optionId.get('v.value'),
                        'FieloELR__TextValue__c': matchingText.get('v.value')
                    });
                }.bind(this));
                component.set('v.answers', answers);
            } else if (type == 'Short Answer') {
                var textValue = component.find('fielo-answer-option');
                component.set('v.textValue', textValue.get('v.value'));
            }
        } catch(e) {
            console.log(e);
        }
    },
    uncheckOthers: function(component, event, helper) {
        try{
            var option = event.getSource();
            var selectedId = option.get('v.value');
            var answersOptions = component.find('fielo-answer-option');
            answersOptions = answersOptions.filter(function(ao) {
				return ao.get('v.value') != selectedId;
            });
            
            answersOptions.forEach(function(ao) {
                ao.set('v.checked', false);
            });
        } catch(e) {
            console.log(e);
        }
    }
})