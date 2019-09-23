({
	setFields: function(component) {
        try{
            var record = component.get('v.record');
            var fields = component.get('v.fields');
            var fieldSet = fields.split(',');
            var fieldMeta = component.get('v.fieldMeta');
            
            if (fieldSet) {
                if (fieldSet.length > 0) {
                    //Set Output
                    var outputFields = [];
                    var row;
                    fieldSet.forEach(function(fieldName) {
                        row = {};
                        row.fieldLabel = fieldMeta[fieldName].attributes.label;
                        row.fieldName = fieldName;
                        row.fieldClass = fieldName.replace(new RegExp('[^a-zA-Z0-9]','g'),'');
                        if (record[fieldName]) {
                            row.fieldValue = record[fieldName];
                            row.untypedFieldValue = Object.prototype.valueOf.call(row.fieldValue);
                        } else {
                            row.fieldValue = null;
                            row.untypedFieldValue = null;
                        }
                        row.fieldMeta = fieldMeta[fieldName];
                        outputFields.push(row);
                    });
                    component.set('v.outputFields', outputFields);
                }
            }
        } catch(e) {
            console.log(e);
        }
    }
})