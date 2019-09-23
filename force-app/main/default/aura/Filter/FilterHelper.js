({
    getTypes: function(component) {
        var fieldInfo = component.get('v.fieldset');
        var fieldTypes = {};
        [].forEach.call(fieldInfo, function(info) {
            fieldTypes[info.attributes.name] = info.attributes.type;
        });
        component.set('v.fieldTypes', fieldTypes);
    },
    getFieldMap: function(component) {
        var fieldInfo = component.get('v.fieldset');
        var fieldMap = {};
        [].forEach.call(fieldInfo, function(info) {
            fieldMap[info.attributes.name] = info;
        });
        component.set('v.fieldMap', fieldMap);
    },
    getFilterObject: function(component) {
        try{
            var fields = component.find('fielo-filter-input');
            var addedFields = [];
            var filterObject = {};
            var fieldName, fieldValue, jsType, isQuoted;
            fields.forEach(function(fieldComp) {
                fieldValue = fieldComp.get('v.fieldValue');
                fieldName = fieldComp.get('v.fieldMeta').attributes.name;
                if (addedFields.indexOf(fieldName) != -1) {
                    fieldName += '-to';
                }
                jsType = fieldComp.get('v.fieldMeta').attributes.jsType;
                isQuoted = fieldComp.get('v.fieldMeta').attributes.isQuoted;
                if (jsType && fieldValue != null) {
                    if (jsType == 'string' || isQuoted) {
                        filterObject[fieldName] = String(fieldComp.get('v.fieldValue'));
                    } else if (jsType == 'number') {
                        filterObject[fieldName] = Number(fieldComp.get('v.fieldValue'));
                    } else if (jsType == 'boolean') {
                        filterObject[fieldName] = Boolean(fieldComp.get('v.fieldValue'));
                    } else {
                        filterObject[fieldName] = fieldComp.get('v.fieldValue');
                    }
                }
                addedFields.push(fieldName);
            });
            console.log(JSON.stringify(filterObject, null, 2));
            component.set('v.filterObject', filterObject);
        } catch(e) {
            console.log(e);
        }
    },
    assembleWhereClause : function(component, filterObject) {
        try {
            var whereConditions = [];
            var whereCondition;
            var fieldTypes = component.get('v.fieldTypes');
            var fieldMap = component.get('v.fieldMap');
            var rangedFields = component.get('v.rangedFields').split(',');
            [].forEach.call(Object.keys(filterObject), function(filterField) {
                if (filterObject[filterField] != '' && filterObject[filterField] != null && filterObject[filterField] != undefined) {
                    if (filterField.indexOf('-to') == -1) {
                        if (rangedFields.indexOf(filterField) == -1) {
                            if (fieldMap[filterField].attributes.type != 'id' && fieldMap[filterField].attributes.inputType == 'text') {
                                whereConditions.push(this.getWhereClause(filterField, filterObject[filterField].replace(new RegExp('\\*','g'),'%'), 'like', fieldTypes));    
                            } else {
                                whereConditions.push(this.getWhereClause(filterField, filterObject[filterField], '=', fieldTypes));
                            }
                        } else {
                            whereCondition = ' ( ';
                            whereCondition += this.getWhereClause(filterField, filterObject[filterField], '>=', fieldTypes);
                            if (filterObject[filterField + '-to']) {
                                whereCondition += ' AND ' + this.getWhereClause(filterField, filterObject[filterField + '-to'], '<=', fieldTypes);
                            }
                            whereCondition += ' ) ';
                            whereConditions.push(whereCondition);
                        }
                    } else if (filterField.indexOf('-to') != -1) {
                        var fieldFrom = filterObject[filterField.replace('-to','')];
                        if (fieldFrom == '' || fieldFrom == null || fieldFrom == undefined) {
                            whereConditions.push(this.getWhereClause(filterField.replace('-to',''), filterObject[filterField], '<=', fieldTypes));    
                        }
                    }
                }
            }, this);
            return whereConditions.join(' AND ');
        } catch(e) {
            console.log(e);
        }
    },
    isQuoted: {
        'address': true,
        'anytype': true,
        'base64': true,
        'boolean': false,
        'combobox': false,
        'currency': false,
        'datacategorygroupreference': false,
        'date': false,
        'datetime': false,
        'double': false,
        'email': true,
        'encryptedstring': true,
        'id': true,
        'integer': false,
        'multipicklist': true,
        'percent': false,
        'phone': true,
        'picklist': true,
        'reference': true,
        'string': true,
        'textarea': true,
        'time': false,
        'url': true
    },
    getWhereClause: function(fieldName, fieldValue, operator, fieldTypes) {
        try{
            var whereClause = '';
            if (fieldValue != null && fieldValue != '' && fieldValue != undefined) {
                if (this.isQuoted[fieldTypes[fieldName]]) {
                    if (fieldTypes[fieldName] != 'string' && fieldTypes[fieldName] != 'textarea') {
                        whereClause = fieldName + ' ' + operator + ' \'\'' + fieldValue.replace(new RegExp('\'','g'),'\\\'\'') + '\'\'';    
                    } else {
                        whereClause = fieldName + ' LIKE \'\'%' + fieldValue.replace(new RegExp('\'','g'),'\\\'\'') + '%\'\'';
                    }
                }else {
                    whereClause = fieldName + ' ' + operator + ' ' + fieldValue + '';
                }    
            }
            return whereClause;    
        } catch(e) {
            console.log(e);
        }
    },
    assembleDynamicFilter: function(component, filterObject) {
        try{
            var filterWrapperList = [];
            var filterWrapper = {};
            var fieldTypes = component.get('v.fieldTypes');
            var fieldMap = component.get('v.fieldMap');
            var rangedFields = component.get('v.rangedFields').split(',');
            [].forEach.call(Object.keys(filterObject), function(filterField) {
                if (filterObject[filterField] != '' && filterObject[filterField] != null && filterObject[filterField] != undefined) {
                    if (filterField.indexOf('-to') == -1) {
                        if (rangedFields.indexOf(filterField) == -1) {
                            filterWrapper = {};
                            filterWrapper.field = filterField;
                            filterWrapper.value = filterObject[filterField];
                            if (fieldMap[filterField].attributes.type != 'id' && fieldMap[filterField].attributes.inputType == 'text') {
                                filterWrapper.operator = 'like';
                            } else {
                                filterWrapper.operator = 'equals';
                            }
                            filterWrapperList.push(filterWrapper);
                        } else {
                            filterWrapper = {};
                            filterWrapper.field = filterField;
                            filterWrapper.value = filterObject[filterField];
                            filterWrapper.operator = 'greater or equal';
                            filterWrapperList.push(filterWrapper);
                            
                            if (filterObject[filterField + '-to']) {
                                filterWrapper = {};
                                filterWrapper.field = filterField;
                                filterWrapper.value = filterObject[filterField + '-to'];
                                filterWrapper.operator = 'less or equal';
                                filterWrapperList.push(filterWrapper);
                            }
                        }
                    } else if (filterField.indexOf('-to') != -1) {
                        var fieldFrom = filterObject[filterField.replace('-to','')];
                        if (fieldFrom == '' || fieldFrom == null || fieldFrom == undefined) {
                            filterWrapper = {};
                            filterWrapper.field = filterField.replace('-to','');
                            filterWrapper.value = filterObject[filterField];
                            filterWrapper.operator = 'less or equal';
                            filterWrapperList.push(filterWrapper);
                        }
                    }
                }
            }, this);
            for(var i = 0; i < filterWrapperList.length; i++) {
                if (filterWrapperList.length != 1) {
                    if (i > 0) {
                    	filterWrapperList[i].andOrOperator = 'and';    
                    }
                }
            }
            if (filterWrapperList.length > 0) {
            	return JSON.stringify(filterWrapperList);    
            } else {
                return '';
            }
        } catch(e) {
            console.log(e);
        }
    }
})