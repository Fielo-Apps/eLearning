({
	checkDescrpDate : function(component) {
        var record = component.get('v.record');

        if( record.FieloELR__Description__c == null && record.FieloELR__StartDatetime__c == null && record.FieloELR__EndDatetime__c == null  ) {
         	component.set('v.noDescrpNoDate', 'no-description-no-date ');
        }
        else if(record.FieloELR__Description__c == null){
            component.set('v.noDescrpNoDate', 'no-description ');
        }
        else if(record.FieloELR__StartDatetime__c == null && record.FieloELR__EndDatetime__c == null){
            component.set('v.noDescrpNoDate', 'no-date ');
        }
	}
})