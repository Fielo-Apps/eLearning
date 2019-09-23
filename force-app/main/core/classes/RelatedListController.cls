public with sharing class RelatedListController {
/***** Badges ******/  
  public String cBadges{get;set;}
  public String cActions{get;set;}
  public List<String> cBadgesList{get{
    if(cBadgesList==null ){
      cBadgesList = cBadges.split(',');
    }
    return cBadgesList;
  }set;}


  private Map<String, Schema.SObjectField> objectFieldMap { get {
    if ( objectFieldMap == null && !String.isBlank(csObjectName) ) {
      Schema.DescribeSObjectResult[] describeObjects = Schema.describeSObjects(  new List<String>{csObjectName} );
      if ( describeObjects.size() > 0 ) {
        objectFieldMap = describeObjects.get(0).fields.getMap();
      }
    }
    return objectFieldMap;
  } set;}

/***** Columnas ******/
  public String cNameField{get;set;}
  public String cFieldset{get;set;}

  public class RelatedColumn  {
    public String id{get;set;}
    public String Type{get;set;}
    public String Name{get;set;}
    public String Label{get;set;}
    public String recordId {get;set;}
    public String sfPage {get;set;}
    public Boolean getIsCrossFormula(){return (Name.countMatches('.') == 0 || (Name.countMatches('.') ==  1 && Name.endsWith('.Name'))) ? false : true;}
    //public Boolean Sortable {get;set;}
  }

  public String nameFieldLabel { get {
      if(nameFieldLabel == null){
        if(cNameField != null && cNameField != '' && !columns.isEmpty()){
          for(RelatedColumn r :columns){
            if(r.Name == cNameField){
              if(r.Label != null && r.Label != ''){
                nameFieldLabel = r.Label;
              }else{
                nameFieldLabel = '';
              }
              break;        
            }
          }
        }
      }

      return nameFieldLabel;
    } set;
  }
  
  public List<RelatedColumn> columns { get {
      if ( columns == null ) {
        if ( !String.isBlank(cFieldset)  ) {
          // Si empieza con [ es un valor seteado en una visual force => lo tiene que modificar para que sea json
          if ( !cFieldset.startsWith('[') ) {
            cFieldset = '[' + cFieldset.replace('\'', '"') + ']';
          }
          try {
            columns = (List<RelatedListController.RelatedColumn>) JSON.deserialize( cFieldset , List<RelatedListController.RelatedColumn>.class );

            // Rellenar los Labels y Types Nulos
            if ( objectFieldMap != null ) {
              for ( Integer i = 0; i < columns.size() ; i++ ) {
                RelatedColumn c = columns[i];              
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
                    columns.remove(i);
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
            system.debug(LoggingLevel.ERROR, 'INVALID JSON ' + cFieldset );        
          }          
        } else {
          columns = new List<RelatedListController.RelatedColumn>();
        }
      }
      return columns;
    } set;
  }
  public String fieldsetString { get {
      if ( fieldsetString == null) {
        if(cNameField == ''){
          cNameField = 'Name';
        }
        fieldsetString = cNameField;

        for ( RelatedColumn r :columns ){
          if ( r.Name != cNameField ) {
            fieldsetString += ', '  + r.Name;            
          }
        }
      }

      return fieldsetString;
    } set;
  }

  public Boolean cAsync{get;set;}
  public Integer cRecordsInPage{get{
        if(cRecordsInPage == null && !cAsync){
          if ( !String.isBlank(cDataFilters) ) {
            cDataFilters = cDataFilters.replace('\'', '"'); 
          }

          cRecordsInPage = getRecords(  csObjectName,  fieldsetString, 0,  orderBy,  cDataFilters,  cRecordsPerPage + 1, cWhereClause ).size();
        }
        return cRecordsInPage;
      }set;}

  public Integer cRecordObjectsInPage { get {
    if ( cRecordObjectsInPage == null ) {
      if ( cObjects != null ) {
        cRecordObjectsInPage = cObjects.size();
      } else {
        cRecordObjectsInPage = cRecordsInPage;
      }
    }
     return cRecordObjectsInPage ;
  } set; }   

/*****  Metodos Remote Delete Record  y Refresh Data *****/
  @RemoteAction
  public static RemoteActionResult deleteRecord( Id recordId ){
    RemoteActionResult result = new RemoteActionResult();
    Savepoint sp = Database.setSavepoint();
    SObject record;

    try{
        if ( recordId == null ) {          
          result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.ERROR, String.format(Label.RequiredArgument, new String[]{'recordId'} ) ) );        
        } else {
          record = recordId.getSobjectType().newSObject();
          record.id = recordId;
          if (recordId.getSobjectType().getDescribe().isDeletable()) {
            delete record;
          }else{
            throw new FieloPLT.FieloException(Label.CannotDeleteRecords);
          }
          // TODO cambiar label
          result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, label.RecordDeletedSuccessfully) );        
        }
    }catch(DmlException e){
        Database.rollback(sp);
        if(ApexPages.hasMessages()){
            result.redirectURL = '';
            for(ApexPages.Message m : ApexPages.getMessages()){
                result.addMessage(new RemoteActionResult.RemoteActionMessage (m, record.getSobjectType().getDescribe().getName() ));
            }
        } else {
          result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
        }
    }catch(Exception e){
        result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
    }
    return result;
  }
/***** Query Datos ******/  
  public Integer cRecordsPerPage{get;set;}
  public String orderBy {get; set;}    
  public String csObjectName{get;set;}
  public String cWhereClause{get;set;}
  public Boolean noRecords{get { return cRecordObjects.size() == 0; } } 
  public Boolean viewAll {get { return cRecordObjects.size() == cRecordsPerPage; } } 
  public String cDataFilters {get{
    return cDataFilters;
    } set;}  

  public List<Object> cRecordObjects { get {
    if ( cRecordObjects == null ) {
      if ( cObjects != null ) {
        cRecordObjects = cObjects;
      } else {
        cRecordObjects = (List<Object>) cRecords;
      }
    }
    if(cRecordObjects == null){
      return new List<object>();
    }
     return cRecordObjects ;
  } set; }    

  public List<Object> cObjects {get;set;}
  
  public List<sObject> cRecords { get {
    if ( cRecords == null && !cAsync) {
      if ( !String.isBlank(cDataFilters) ) {
        cDataFilters = cDataFilters.replace('\'', '"'); 
      }

      cRecords = getRecords(  csObjectName,  fieldsetString, 0,  orderBy,  cDataFilters,  cRecordsPerPage, cWhereClause );
    }
    return cRecords;
  } set; }    

    @RemoteAction
    public static List<SObject> getRecords( String objectName, String fields, Integer offset, String orderBy, String dataFilters, Integer recordsPerPage, String whereClause) {
        List<String> listToDescribe = new List<String>{objectName};
        Schema.DescribeSObjectResult objectDescribe = Schema.describeSObjects(listToDescribe)[0];
        Map<String, Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
        Set<String> picklistTypes = new Set<String>{'PICKLIST','MULTIPICKLIST'};
        List<String> listFields = fields != null ? fields.deleteWhitespace().split(',') : new List<String>();
        List<String> fieldset = new List<String>();
        for(String fieldName: listFields){
            fieldName = fieldName.toLowerCase();
            // SR: FLS Check
            if ( fieldsMap.containskey(fieldName) && !fieldsMap.get(fieldName).getDescribe().isAccessible() ) {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{objectName, fieldName}));
            }
            if(objectDescribe.fields.getMap().containskey(fieldName) && picklistTypes.contains(objectDescribe.fields.getMap().get(fieldName).getDescribe().getType().name())){
                fieldset.add('toLabel(' + fieldName + ')');
            }else{
                fieldset.add(fieldName);
            }
        }
        String query = 'SELECT Id ';

        if (fields != '') {
            query += ', ' + String.join(fieldset, ',');
        }
        
        query += ' FROM ' + objectName;
        query += getWhereCondition( dataFilters );
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

        // SR: CRUD Check
        List<SObject> records;
        if ( objectDescribe.isAccessible() ) {
            records = Database.query(query);
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{objectName}));
        }
        return records;
    }
  /*
  @RemoteAction
  public static Integer getRecordsQty( String objectName, String dataFilters) {
      String query = 'SELECT Id ';
      query += ' FROM ' + objectName;
      query += getWhereCondition( dataFilters );
      return Database.query(query).size();
  }    */

    private static String getWhereCondition( String filterJson ) {
      String whereCondition = '';
      if (filterJson != null ) { 
        try {
          Map<String,Object> filter = (Map<String, Object>) JSON.deserializeUntyped( filterJson);
          for ( String k :filter.keySet() ) {
            String value = string.valueOf(filter.get(k));
            if(value.startsWith('BOOLEAN:')){
              whereCondition += ' AND ' + String.escapeSingleQuotes(k) + ' = ' +  String.escapeSingleQuotes(value.removeStart('BOOLEAN:'));            
            }else{
              if ( value.startsWith('!') ) {
                whereCondition += ' AND ' + String.escapeSingleQuotes(k) + ' <> \'' +  String.escapeSingleQuotes(value.substring(1)) + '\'';            
              } else {
                whereCondition += ' AND ' + String.escapeSingleQuotes(k) + ' = \'' +  String.escapeSingleQuotes(value) + '\'';
              }
            }
          }

          if ( whereCondition != '') {          
            whereCondition = ' WHERE ' + whereCondition.substring(4);
          }
        } catch( JSONException e ) {
          system.debug(LoggingLevel.ERROR, 'INVALID JSON ' + filterJson );        
        }
      }
      return whereCondition;
    }

  public Boolean isSingleAction { get {
      List<ButtonsController.Button> actions = new List<ButtonsController.Button>();
      if (!String.isBlank(cActions)  ) {
        // Si empieza con [ es un valor seteado en una visual force => lo tiene que modificar para que sea json
        if ( !cActions.startsWith('[') ) {
          cActions = '[' + cActions.replace('\'', '"') + ']';
        }
        try {
          actions = (List<ButtonsController.Button>) JSON.deserialize( cActions, List<ButtonsController.Button>.class );
        } catch( JSONException e ) {
            system.debug(LoggingLevel.ERROR, 'INVALID JSON: ' + cActions );        
        }
      }
      return actions.size() == 1 ? true : false;
    } set;
  }

}