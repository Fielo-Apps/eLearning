({
    fieldMap: {
        'text': 'stringValue',
        'reference': 'reference',
        'checkbox': 'booleanValue',
        'number': 'decimalValue',
        'date': 'stringValue',
        'datetime': 'stringValue',
        'email': 'stringValue',
        'picklist': 'stringValue',
        'time': 'decimalValue',
        'url': 'stringValue'
    },
    setFieldValue: function(component) {
        try {
            var config = component.get('v.config');
            var fieldMeta = component.get('v.fieldMeta');
            if (!fieldMeta) {
                if (config) {
                    fieldMeta = JSON.parse(config);
                    component.set('v.fieldMeta', fieldMeta);    
                }
            }
            if (fieldMeta) {
                var fieldValue = component.get('v.fieldValue');
                if (!fieldValue) {
                    var record = component.get('v.record');
                    fieldValue = record[fieldMeta.attributes.name];
                    component.set('v.fieldValue', fieldValue);
                }
                switch(this.fieldMap[fieldMeta.attributes.type]) {
                    case 'decimalValue':
                        component.set('v.decimalValue', Number(fieldValue));
                        break;
                        
                    case 'booleanValue':
                        component.set('v.booleanValue', Boolean(fieldValue));
                        break;
                        
                    case 'dateValue':
                        component.set('v.stringValue', String(fieldValue));
                        break;
                        
                    default:
                    case 'stringValue':
                        component.set('v.stringValue', fieldValue != null ? String(fieldValue) : '');
                        break;
                }    
            }
        } catch(e) {
            console.log(e);
        }
    }
})