global with sharing class RecentRecordsController {

  /***** Header fields  ******/
    public String cFieldset{get;set;}
    public String cNameField{get;set;}
    public String cWhereClause{get;set;}
    public Boolean cAsync{get;set;}
    public Integer recordsInPage{get{
        if(recordsInPage == null && !cAsync){
          if ( !String.isBlank(cDataFilters) ) {
            cDataFilters = cDataFilters.replace('\'', '"');
          }
          recordsInPage = getRecords(  csObjectName,  fieldsetString, 0,  orderBy,  cDataFilters,  cRecordsPerPage + 1, cWhereClause ).size();
        }
        return recordsInPage;
      }set;}

    public class HeaderColumn {
      public String id{get;set;}
      public String Type{get;set;}
      public String Name{get;set;}
      public String Label{get;set;}
      public String recordId {get;set;}
      public String sfPage {get;set;}
      public Boolean getIsCrossFormula(){return (Name.countMatches('.') == 0 || (Name.countMatches('.') ==  1 && Name.endsWith('.Name'))) ? false : true;}
    }

  private Map<String, Schema.SObjectField> objectFieldMap { get {
    if ( objectFieldMap == null && !String.isBlank(csObjectName) ) {
      Schema.DescribeSObjectResult[] describeObjects = Schema.describeSObjects(  new List<String>{csObjectName} );
      if ( describeObjects.size() > 0 ) {
        objectFieldMap = describeObjects.get(0).fields.getMap();
      }
    }
    return objectFieldMap;
  } set;}

    public List<HeaderColumn> fields { get {
        if ( fields == null ) {
          if ( !String.isBlank(cFieldset)  ) {
            // Si empieza con [ es un valor seteado en una visual force => lo tiene que modificar para que sea json
            if ( !cFieldset.startsWith('[') ) {
              cFieldset = '[' + cFieldset.replace('\'', '"') + ']';
            }
            try {
              fields = (List<HeaderColumn>) JSON.deserialize( cFieldset, List<HeaderColumn>.class );

              // Rellenar los Labels y Types Nulos
              if ( objectFieldMap != null ) {
                for ( Integer i = 0; i < fields.size() ; i++ ) {
                  HeaderColumn c = fields[i];
                  //si tiene campo por relacion tomo lo anterior al punto nomas
                  String apiName = c.Name.indexOf('.') > 0 ? c.Name.substring(0,c.Name.indexOf('.')) : c.Name;
                  //si es un campo custom con __r lo cambio por __c
                  if(apiName.indexOf('__r') > 0){
                    apiName = apiName.substring(0, apiName.indexOf('__r') ) + '__c';
                  //si es un campo standard y no tien el id al
                  }else if(!apiName.contains('__c') && c.Name.contains('.') ){
                      apiName += 'id';
                  }
                  Schema.DescribeFieldResult fieldDescribe = objectFieldMap.get(apiName).getDescribe();
                  if(objectFieldMap.containsKey(apiName)){
                    if(!fieldDescribe.isAccessible()){
                      fields.remove(i);
                      i--;
                    }else if(c.Label == null || c.Type == null){
                      if(apiName.toLowerCase() == 'recordtypeid' || apiName.toLowerCase().contains('recordtype.id')){
                        c.Type = 'string';
                      }
                      if(c.Label == null){
                        c.Label = fieldDescribe.getLabel();
                      }
                      if(c.Type == null){
                        c.Type = fieldDescribe.getType().name();
                      }
                    }
                  }
                }
              }
            } catch( JSONException e ) {
              system.debug(LoggingLevel.ERROR, 'INVALID JSON: ' + cFieldset );
            }

          } else {
            fields = new List<HeaderColumn>();
          }
        }
        return fields;
      } set;
    }

    public String fieldsetString { get {
        if ( fieldsetString == null) {
          fieldsetString = cNameField;
          for ( HeaderColumn c :fields ){
            if ( c.Name != cNameField ) {
              fieldsetString += ','  + c.Name;
            }
          }
        }
        return fieldsetString;
      } set;
    }

  /***** Query Datos  ******/
    public String csObjectName {get; set;}
    public Integer cRecordsPerPage {get; set;}
    public String orderBy {get; set;}
    public String cDataFilters {get; set;}

    private static String getWhereCondition( String filterJson ) {
      String whereCondition = '';
      if(filterJson != null && filterJson != '{}'){
        try {
          Map<String,Object> filter = (Map<String, Object>) JSON.deserializeUntyped( filterJson);
          for ( String k :filter.keySet() ) {
            String value = (String) filter.get(k);
            if ( value.startsWith('!') ) {
              whereCondition += ' AND ' + String.escapeSingleQuotes(k) + ' <> \'' +  String.escapeSingleQuotes(value.substring(1)) + '\'';
            } else {
              whereCondition += ' AND ' + String.escapeSingleQuotes(k) + ' = \'' +  String.escapeSingleQuotes(value) + '\'';
            }
          }
          whereCondition = ' WHERE ' + whereCondition.substring(4);
        } catch( JSONException e ) {
          system.debug(LoggingLevel.ERROR, 'INVALID JSON: ' + filterJson );
        }
      }
      return whereCondition;
    }

    @RemoteAction
    global static List<SObject> getRecords( String objectName, String fields, Integer offset, String orderBy, String dataFilters, Integer recordsPerPage, String whereClause ) {
        List<String> listToDescribe = new List<String>{objectName};
        Schema.DescribeSObjectResult objectDescribe = Schema.describeSObjects(listToDescribe)[0];
        Map<String, Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
        Set<String> picklistTypes = new Set<String>{'PICKLIST','MULTIPICKLIST'};
        List<String> listFields = fields != null ? fields.deleteWhitespace().split(',') : new List<String>();
        Set<String> fieldset = new Set<String>();
        for(String fieldName: listFields){
            // SR: FLS Check
            if ( fieldsMap.containskey(fieldName) && !fieldsMap.get(fieldName).getDescribe().isAccessible() ) {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{objectName, fieldName}));
            }
            if(fieldsMap.containskey(fieldName) && picklistTypes.contains(fieldsMap.get(fieldName).getDescribe().getType().name())){
                fieldset.add('toLabel(' + fieldName + ')');
            }else{
                fieldset.add(fieldName);
            }
        }
        String query = 'SELECT Id, ' + String.join(new List<String>(fieldset), ',');
        query += ' FROM ' + objectName;
        query += getWhereCondition( dataFilters );
        if(whereClause != null && WhereClause != ''){
          query += query.contains(' WHERE ') ?  ' ' + whereClause : ' WHERE ' + whereClause;
        }
        // ORDER BY
        if ( orderBy == null ) {
            orderBy = 'LastModifiedDate DESC';
        }
        query += ' ORDER BY '+ orderBy; //DESC
        // LIMIT & OFFSET
        if ( recordsPerPage == null ) {
            recordsPerPage = 10;
        }
        query += ' LIMIT '+ String.valueOf(recordsPerPage);
        if ( offset != null ){
          query += ' OFFSET '+ String.valueOf(offset);
        }

        List<SObject> records;
        // SR: CRUD Check
        if ( objectDescribe.isAccessible() ) {
            records = Database.query(query);
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{objectName}));
        }

        return records;
    }

    public List<sObject> recentRecords { get {
      if ( recentRecords == null ) {
        if ( !String.isBlank(cDataFilters) ) {
          cDataFilters = cDataFilters.replace('\'', '"');
        }

        List<sObject> aux = getRecords(  csObjectName,  fieldsetString, 0,  orderBy,  cDataFilters,  cRecordsPerPage + 1, cWhereClause );
        recentRecords = new List<sObject>();
        for (Integer i = 0; i < aux.size(); i++) {
          recentRecords.add( aux.get(i) );
        }
      }
      return recentRecords;
    } set; }
}