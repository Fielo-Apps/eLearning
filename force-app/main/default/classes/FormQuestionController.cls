global with sharing class FormQuestionController {
  /*****  Datos  *****/
    public String csObjectName{get;set;}
    public String cFilter{get;set;}
    public String cLayout{get;set;}
    public static Boolean cRecordRedirect{get;set;}
    public SObject cRecord {get;set;}
    private Boolean queryRecordNotDone = true;
    private Set<String> fieldFilter = new Set<String> {'lastreferenceddate', 'lastvieweddate'};
    public String fields {get{
      if ( fields == null ) {
      fields = 'Id';
          for ( Section s :sections ) {
              for ( List<FormField> r :s.rows ) {
                for ( FormField f :r ) {
                    if ( !String.isBlank(f.Name) ) {
                      fields += ', '  + f.Name;
                    }
                }
              }
          }
        }
    return fields;
    }set;}

    public SObject recordObject{get{
        if (queryRecordNotDone ) {
            queryRecordNotDone = false;
            if ( cRecord !=null && cRecord.Id != null ) {
                Map<String, Schema.SObjectField> fieldsMap = Schema.describeSObjects(new String[]{csObjectName})[0].fields.getMap();
                fields = String.escapeSingleQuotes(fields);
                csObjectName = String.escapeSingleQuotes(csObjectName);

                Id recordId = cRecord.Id;
                String query = 'SELECT  ' + fields;
                query += ' FROM ' + csObjectName;
                query += ' WHERE Id = : recordId ';

                // SR: FLS Check
                for (String fieldName : fields.split(',') ) {
                    if ( !fieldsMap.get(fieldName.trim().toLowerCase()).getDescribe().isAccessible() ) {
                        throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{csObjectName, fieldName}));
                    }
                }

                if( Schema.describeSObjects(new List<String>{csObjectName})[0].isAccessible() ) {
					recordObject = Database.query(query)[0];
				} else {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{csObjectName}));
                }
            } else {
                recordObject = Schema.describeSObjects(new List<String>{csObjectName})[0].getSobjectType().newSObject();
            }
        }
        return recordObject;
    }set;}

  /*****  Secciones Y Fields  *****/
    public String cFieldset{get;set;}

    public class Section {
        public String Name{get;set;}
        public List<List<FormField>> Rows{get;set;}
        public String CssClass{get;set;}
    }

    public class FormField {
        public String Type{get;set;}
        public String MetaField{get;set;}
        public String Name{get;set;}
        public String onchange{get;set;}
        public String Label{get;set;}
        public String Value{get;set;}
        public String WhereCondition{get;set;}
        public Boolean Required{get;set;}

        public String getRequiredValue () {
            if ( Required != null ) {
                return Required ? 'true' : 'false';
            }
            return '';
        }
    }

    public List<Section> sections { get {
        if ( sections == null ) {
            if ( !String.isBlank(cFieldset)  ) {
                // Si empieza con [ es un valor seteado en una visual force => lo tiene que modificar para que sea json
                if ( !cFieldset.startsWith('[') ) {
                    cFieldset = '[' + cFieldset.replace('\'', '"') + ']';
                }
                try {
                    if ( cLayout == 'inline'  ) {
                        Section s = new Section();
                        s.Name = '';
                        s.Rows =  new List<List<FormField>>();
                        s.Rows.add( (List<FormField>) JSON.deserialize( cFieldset, List<FormField>.class ));
                        sections = new List<Section>();
                        sections.add(s);
                    } else {
                        sections = (List<Section>) JSON.deserialize( cFieldset, List<Section>.class );
                    }
                } catch( JSONException e ) {
                    system.debug(LoggingLevel.ERROR, 'INVALID JSON ' + cFieldset );
                }
            } else {
                sections = new List<Section>();
            }
        }
        return sections;
        } set;
    }

  /*****  Piclklist Values *****/
    private Map<String, Schema.SObjectField> fieldMap { get {
      if ( fieldMap == null && csObjectName != null ) {
          Schema.DescribeSObjectResult[] describes = Schema.describeSObjects(new String[]{ csObjectName });
          fieldMap = describes.get(0).fields.getMap();
      }
      return fieldMap;
    } set; }

    public Map<String, String> mapOptionsString { get {
      if ( mapOptionsString == null && mapPicklistOptions != null ) {
          mapOptionsString = new Map<String, String>();
          for ( String key : mapPicklistOptions.keySet() ) {
            String options = '';
            for ( PicklistController.Entry p : mapPicklistOptions.get(key) ) {
                options += ',{ "id": "' + p.Id + '", "label": "' + p.Label + '" }';
            }
            if ( options != '') {
                mapOptionsString.put(key,'[' + options.substring(1) + ']');
            } else {
                mapOptionsString.put(key,'[]');
            }
          }
      }
      return mapOptionsString;
    } set;}

    public Map<String, List<PicklistController.Entry>> mapPicklistOptions { get {
        if ( mapPicklistOptions == null && !String.isBlank(csObjectName) ) {
            mapPicklistOptions = new Map<String, List<PicklistController.Entry>>();
            for ( Section s :sections ) {
                for ( List<FormField> ff :s.Rows ) {
                    for ( FormField f :ff ) {
                        if ( (f.Type == 'picklist' ||  f.Type == 'radio'|| f.Type == 'multiselect'|| f.Type == 'checkboxes') && fieldMap.containsKey(f.Name) ) {
                            List<PicklistController.Entry> options = new List<PicklistController.Entry>();
                            Schema.DescribeFieldResult describe = fieldMap.get(f.Name).getDescribe();
                            if ( describe.getType().name() == 'PICKLIST' || describe.getType().name() == 'MULTIPICKLIST' ) {
                                List<Schema.PicklistEntry> pickListValues = describe.getPickListValues();
                                for (Schema.PicklistEntry a : pickListValues) {
                                    options.add( new PicklistController.Entry(a.getValue(), a.getLabel() ));
                                }
                            } else if ( describe.getType().name() == 'REFERENCE' ) {
                                String query = 'SELECT ID, Name FROM ' + describe.getReferenceTo().get(0);
                                if ( ! String.isBlank( f.WhereCondition )  ){
                                    query += ' WHERE ' + f.WhereCondition.replace('/', '\'') ;
                                }
                                query += ' LIMIT 500';

                                // SR: CRUD Check
                                if (describe.getReferenceTo().get(0).getDescribe().isAccessible()) {
                                    // SR: FLS Check
                                    if ( describe.getReferenceTo().get(0).getDescribe().fields.getMap().get('Name').getDescribe().isAccessible() ) {
                                        for ( SObject o : Database.query(query) ) {
                                            // Substring para que matche con el multipicklist (para multisegment)
                                            options.add( new PicklistController.Entry( ((String)o.id).substring(0, 15),  (String)o.get('Name') ));
                                        }
                                    } else {
                                        throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{ describe.getReferenceTo().get(0).getDescribe().getName(), 'Name' }));
                                    }
                                } else {
                                    throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{ describe.getReferenceTo().get(0).getDescribe().getName() }));
                                }
                            }
                            mapPicklistOptions.put( f.Name , options);
                        }
                    }
                }
            }
        }
        return mapPicklistOptions;
    } set;}

    public FieloPLT__PageSettings__c getPageSettings(String pageSetingsName) {
        Set<String> fields = new Set<String>();
        for(String s : new List<String>(Schema.describeSObjects(new String[]{'FieloPLT__PageSettings__c'})[0].fields.getMap().keySet())){
            if(!fieldFilter.contains(s)){
                if( Schema.sObjectType.FieloPLT__PageSettings__c.fields.getMap().get(s).getDescribe().isAccessible() ){
                    fields.add(s);
                } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{'FieloPLT__PageSettings__c', s}));
                }
            }
        }

        String query = 'SELECT ';
        query += String.join(new List<String>(fields), ',');
        query += ' FROM FieloPLT__PageSettings__c';
        query += ' WHERE Name = :pageSetingsName' ;
        query += ' LIMIT 1';

        List<sObject> result;

        if(Schema.sObjectType.FieloPLT__PageSettings__c.isAccessible()){
            result = Database.query(query);
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{ 'FieloPLT__PageSettings__c' }));
        }

        return (FieloPLT__PageSettings__c) result.get(0);
    }

    public FieloPLT__PageSettings__c answerOptionsPS {get{
        return getPageSettings('Question (Question Wizard) > Related > Answer Option');
    }set;}

  /*****  Metodos Remote para Save y Retrieve *****/
    @RemoteAction
    global static RemoteActionResult save( FieloELR__Question__c question, List<String> questionNullFields, List<FieloELR__AnswerOption__c> answerOptions, Map<Id,List<String>> answerOptionsNullFields, List<Id> deletedIds){
        Savepoint sp;
        RemoteActionResult result = new RemoteActionResult();
        SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SobjectType>{FieloELR__Question__c.SObjectType, FieloELR__AnswerOption__c.SObjectType});
        SObjectUnitOfWork uowUpdateAO = new SObjectUnitOfWork(new List<Schema.SobjectType>{FieloELR__AnswerOption__c.SObjectType});
        System.debug(question);
      try{
            sp = Database.setSavepoint();
            for( String f :questionNullFields ) {
                if( Schema.sObjectType.Question__c.fields.getMap().get(f).getDescribe().isUpdateable() ){
                    question.put(f, null );
                }
            }

            if (question.Id == null) {
                uow.registerNew(question);
            } else {
                uow.registerDirty(question);
            }

            for( FieloELR__AnswerOption__c answerOption: answerOptions) {
                if(answerOptionsNullFields.containsKey(answerOption.Id)){
                    for(String f: answerOptionsNullFields.get(answerOption.Id)){
                        if( Schema.sObjectType.FieloELR__AnswerOption__c.fields.getMap().get(f).getDescribe().isUpdateable() ){
                            answerOption.put(f, null);
                        }
                    }
                }
                if(answerOption.Id == null){
                    uow.registerNew(answerOption, AnswerOption__c.Question__c, question);
                }else{
                    uowUpdateAO.registerDirty(answerOption);
                }
            }

            if (!deletedIds.isEmpty()) {
                uow.registerDeleted(new AnswerOptionsSelector().selectById(new Set<Id>(deletedIds)));
            }

            //done update in different uow to do the update before the insert of AOs to avoid validation rules.
             if(Schema.sObjectType.FieloELR__AnswerOption__c.isUpdateable()){
                uowUpdateAO.commitWork();
            }else{
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{ 'FieloELR__AnswerOption__c' }));
            }

            if( Schema.sObjectType.FieloELR__Question__c.isCreateable() && Schema.sObjectType.FieloELR__Question__c.isUpdateable() && Schema.sObjectType.FieloELR__AnswerOption__c.isDeletable() ){
                uow.commitWork();
            }else{
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{ 'FieloELR__Question__c, FieloELR__AnswerOption__c' }));
            }

          //TODO Crear Label DataSavedSuccessfully
          result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.DataSavedSuccessfully) );

      } catch(DmlException e) {
      // Agrega las Validation Rules asociadas al Campo
          Database.rollback(sp);
          if(ApexPages.hasMessages()){
              result.redirectURL = '';
              for(ApexPages.Message m : ApexPages.getMessages()){
                  result.addMessage(new RemoteActionResult.RemoteActionMessage(m, '' ));
              }
          } else {
            result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
          }
      }catch(Exception e){
          if(sp != null){
              Database.rollback(sp);
          }
          result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
      }
      return result;
   }

    @RemoteAction
    global static sObject retrieve( String objectName, String recordId, String fields ){
        Map<String, Schema.SObjectField> fieldsMap = Schema.describeSObjects(new String[]{objectName})[0].fields.getMap();
		Set<String> newFields = new Set<String>();
		for(String s : fields.split(',')){
			if( fieldsMap.get(s).getDescribe().isAccessible() ){
				newFields.add( String.escapeSingleQuotes(s) );
			}
		}

      String query = 'SELECT ' + String.join(new List<String>(newFields), ',');
        objectName = String.escapeSingleQuotes(objectName);
      if (objectName == 'FieloELR__Question__c') {
        query += ' ,(Select Id, FieloELR__IsCorrect__c, FieloELR__AnswerOptionText__c, FieloELR__MatchingText__c, FieloELR__Order__c From AnswerOptions__r ORDER BY FieloELR__Order__c, LastModifiedDate)';
      }

      query += ' FROM ' + objectName;
      query += ' WHERE ID = :recordId';
      query += ' LIMIT 1';
      List<sObject> result;

       if( Schema.describeSObjects(new String[]{objectName})[0].isAccessible()){
            if( String.escapeSingleQuotes(objectName) == 'FieloELR__Question__c' && !Schema.sObjectType.AnswerOption__c.isAccessible() || !Schema.sObjectType.AnswerOption__c.fields.IsCorrect__c.isAccessible() || !Schema.sObjectType.AnswerOption__c.fields.AnswerOptionText__c.isAccessible() || !Schema.sObjectType.AnswerOption__c.fields.MatchingText__c.isAccessible() || !Schema.sObjectType.AnswerOption__c.fields.Order__c.isAccessible()){
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'AnswerOption__c', 'IsCorrect__c, AnswerOptioNText__c, MatchingText__c, Order__c'}));
            }
            result = Database.query(query);
       } else {
           throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{objectName}));
       }

      if ( result.size() > 0 ) {
          return result.get(0);
      }
      return null;
    }
}