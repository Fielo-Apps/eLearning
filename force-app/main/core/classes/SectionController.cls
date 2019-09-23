public with sharing class SectionController {
/*****  Datos  *****/
  public String csObjectName{get;set;}

  public String cFormId{get;set;}
  
  public static Boolean cRecordRedirect{get;set;}

  public SObject cRecord {get;set;}

  private Boolean queryRecordNotDone = true;
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
                    if ( fieldsMap.containsKey(fieldName.trim()) && !fieldsMap.get(fieldName.trim()).getDescribe().isAccessible() ) {
                        throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{csObjectName, fieldName}));
                    }
                }

                // SR: CRUD Check
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

  private Map<String,Schema.DescribeSObjectResult> mapNameDescribeSObjectResult;

/*****  Secciones Y Fields  *****/
  public String cFieldset{get;set;}
  public String cLayout {get;set;}

  public class Section {
    public String id{get;set;}
    public String Name{get;set;}
    public List<List<FormField>> Rows{get;set;}
  }
  public class FormField {
    public String id{get;set;}
    public String Type{get;set;}
    public String MetaField{get;set;}
    public String Name{get;set;}
    public String onchange{get;set;}
    public String Label{get;set;}
    public String Folder{get;set;}
    public String Instance{get;set;}
    public String ExternalURL{get;set;}
    public String Value{get;set;}
    public String WhereCondition{get;set;}
    public Boolean Required{get;set;}
    public Boolean ReadOnly{get;set;}
    public String SearchField{get;set;}
    public String TargetField{get;set;}
    public String TargetObject{get;set;}

    public String getRequiredValue () {
      if ( Required != null ) {
        return Required ? 'true' : 'false';
      }
      return '';
    }

    public String getReadOnly () {
      if ( ReadOnly != null ) {
        return ReadOnly ? 'true' : 'false';
      }
      return '';
    }
    
  }

  private void loadSections () {  
      if ( !String.isBlank(cFieldset)  ) {
        fields = 'Id';
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
            sections = (List<Section>) JSON.deserialize( cFieldset, List<SectionController.Section>.class );
          }
          // 

        } catch( JSONException e ) {
          system.debug(LoggingLevel.ERROR, 'INVALID JSON: ' + cFieldset );        
        }
        List<FormField> fieldsToUpdate = new List<FormField>();
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        Set<String> setFields = new Set<String>();
        for ( Section s :sections ) {
          for ( List<FormField> r :s.rows ) {
            for ( FormField f :r ) {
              if ( !String.isBlank(f.Name) ) {
                // default value
                if (cRecord != null){  
                  if (queryRecordNotDone ) { 
                    fieldsToUpdate.add(f);
                  } else {
                    List<String> listFields = f.Name.split('\\.');
                    //si el campo es cross-field hay que buscar el Label del campo a mostrar
                    if(listFields.size() > 1){
                      //busca el label del campo final del cross-field
                      Schema.DescribeSObjectResult objectDescribe;
                      if(!mapNameDescribeSObjectResult.containsKey(csObjectName.toLowerCase())){
                        objectDescribe = Schema.describeSObjects(new List<String>{csObjectName})[0];
                        mapNameDescribeSObjectResult.put(objectDescribe.getName().toLowerCase(),objectDescribe);
                      }else{
                        objectDescribe = mapNameDescribeSObjectResult.get(objectDescribe.getName().toLowerCase());
                      }
                      String nextObject;
                      for(Schema.SObjectField field: objectDescribe.fields.getMap().values()){
                        if(string.ValueOf(field.getDescribe().getName()).equalsIgnoreCase(listFields[0].replace('__r','__c'))){
                          //si la primera parte es un lookup se guarda la referencia a que objeto es para hacer un describe de ese siguiente objeto
                          if(string.ValueOf(field.getDescribe().getType()) == 'REFERENCE'){
                            nextObject = string.ValueOf(field.getDescribe().getReferenceTo()).remove('(').remove(')');
                          //si no es loookup se guarda el object y field para el describe que hace el componente que renderize el campo
                          }else{
                            f.TargetObject = csObjectName;
                            f.TargetField = field.getDescribe().getLabel();                     
                          }
                          break;
                        }
                      }
                      //si hay siguiente object se van a ser los siguientes describe en loop hasta llegar al ultimo campo y encontrar el Label a mostrar
                      if(nextObject != null){
                        for(Integer i = 1 ; i <= listFields.size()-1 ; i++){
                          if(!mapNameDescribeSObjectResult.containsKey(nextObject.toLowerCase())){
                            objectDescribe = Schema.describeSObjects(new List<String>{nextObject})[0];
                            mapNameDescribeSObjectResult.put(objectDescribe.getName().toLowerCase(),objectDescribe);
                          }else{
                            objectDescribe = mapNameDescribeSObjectResult.get(objectDescribe.getName().toLowerCase());
                          }
                          for(Schema.SObjectField field: objectDescribe.fields.getMap().values()){
                            if(string.ValueOf(field.getDescribe().getName()).equalsIgnoreCase(listFields[i].replace('__r','__c'))){
                              //cuando se llega a la ultima posicion del cross-field se guarda el object y field para el describe que hace el componente que renderize el campo
                              if(i == (listFields.size()-1)){
                                f.TargetObject = nextObject;
                                f.TargetField = field.getDescribe().getName();
                              //si no se llego a la ultima posicion y es lookup se guarda el objeto name para seguir haciendo describe del siguiente objeto  
                              }else if(string.ValueOf(field.getDescribe().getType()) == 'REFERENCE'){
                                nextObject = string.ValueOf(field.getDescribe().getReferenceTo());
                                nextObject = nextObject.remove('(').remove(')');
                              }
                              break;
                            }
                          }
                        }
                      }
                      //si es cross-field se busca el valor a mostrar a traves del getSobject hasta llegar al resultado    
                      if(listFields.size() == 2){
                        sObject auxSObject1 = recordObject.getSobject(listFields[0]);
                        if(auxSObject1 != null){
                            f.Value = (String) auxSObject1.get(listFields[1]);
                        }
                      }else{
                        sObject auxSObject = recordObject.getSobject(listFields[0]);
                        for(Integer i = 1;i < listFields.size();i++){
                          if(auxSObject != null){
                              if((i + 1) == listFields.size()){
                                f.Value = (String) auxSObject.get(listFields[i]);                    
                              }else{
                                 auxSObject = auxSObject.getSobject(listFields[i]);
                              }
                           }                   
                        }
                      }
                    //si no es cross-field se hace el get directo y no se usa el TargetObject y TargetField
                    }else{
                      f.Value = String.valueOf(recordObject.get(f.Name));
                    }       
                  }
                } else if (f.Value == null) {
                  if (parameters.containsKey(cFormId + '-' + f.Name) ) {
                   f.Value = parameters.get(cFormId + '-' + f.Name);
                  } else if ( parameters.containsKey(f.Name) ) {
                   f.Value = parameters.get(f.Name);
                  }
                }
                if(!setFields.contains(f.Name.toLowerCase())){
                  fields += ', '  + f.Name;
                  setFields.add(f.Name.toLowerCase());
                    if(f.Type == 'photoupload') {
                      fields += ', '  + f.ExternalURL;
                      setFields.add(f.ExternalURL.toLowerCase());
                    }
                }            
              }
            }
          }
        }
      if(!fieldsToUpdate.isEmpty()){
        for(FormField f: fieldsToUpdate){
          if(!String.isBlank(f.Name)){
            List<String> listFields = f.Name.split('\\.');
            //si el campo es cross-field hay que buscar el Label del campo a mostrar
            if(listFields.size() > 1){
              //busca el label del campo final del cross-field
              Schema.DescribeSObjectResult objectDescribe;
              if(!mapNameDescribeSObjectResult.containsKey(csObjectName.toLowerCase())){
                objectDescribe = Schema.describeSObjects(new List<String>{csObjectName})[0];
                mapNameDescribeSObjectResult.put(objectDescribe.getName().toLowerCase(),objectDescribe);
              }else{
                objectDescribe = mapNameDescribeSObjectResult.get(objectDescribe.getName().toLowerCase());
              }
              String nextObject;
              for(Schema.SObjectField field: objectDescribe.fields.getMap().values()){
                if(string.ValueOf(field.getDescribe().getName()).equalsIgnoreCase(listFields[0].replace('__r','__c'))){
                  //si la primera parte es un lookup se guarda la referencia a que objeto es para hacer un describe de ese siguiente objeto
                  if(string.ValueOf(field.getDescribe().getType()) == 'REFERENCE'){
                    nextObject = string.ValueOf(field.getDescribe().getReferenceTo()).remove('(').remove(')');
                  //si no es loookup se guarda el object y field para el describe que hace el componente que renderize el campo
                  }else{
                    f.TargetObject = csObjectName;
                    f.TargetField = field.getDescribe().getLabel();                     
                  }
                  break;
                }
              }
              //si hay siguiente object se van a ser los siguientes describe en loop hasta llegar al ultimo campo y encontrar el Label a mostrar
              if(nextObject != null){
                for(Integer i = 1 ; i <= listFields.size()-1 ; i++){
                  if(!mapNameDescribeSObjectResult.containsKey(nextObject.toLowerCase())){
                    objectDescribe = Schema.describeSObjects(new List<String>{nextObject})[0];
                    mapNameDescribeSObjectResult.put(objectDescribe.getName().toLowerCase(),objectDescribe);
                  }else{
                    objectDescribe = mapNameDescribeSObjectResult.get(objectDescribe.getName().toLowerCase());
                  }
                  for(Schema.SObjectField field: objectDescribe.fields.getMap().values()){
                    if(string.ValueOf(field.getDescribe().getName()).equalsIgnoreCase(listFields[i].replace('__r','__c'))){
                      //cuando se llega a la ultima posicion del cross-field se guarda el object y field para el describe que hace el componente que renderize el campo
                      if(i == (listFields.size()-1)){
                        f.TargetObject = nextObject;
                        f.TargetField = field.getDescribe().getName();
                      //si no se llego a la ultima posicion y es lookup se guarda el objeto name para seguir haciendo describe del siguiente objeto  
                      }else if(string.ValueOf(field.getDescribe().getType()) == 'REFERENCE'){
                        nextObject = string.ValueOf(field.getDescribe().getReferenceTo());
                        nextObject = nextObject.remove('(').remove(')');
                      }
                      break;
                    }
                  }
                }
              }
              //si es cross-field se busca el valor a mostrar a traves del getSobject hasta llegar al resultado    
              if(listFields.size() == 2){
                sObject auxSObject1 = recordObject.getSobject(listFields[0]);
                if(auxSObject1 != null){
                    f.Value = (String) auxSObject1.get(listFields[1]);
                }
              }else{
                sObject auxSObject = recordObject.getSobject(listFields[0]);
                for(Integer i = 1;i < listFields.size();i++){
                  if(auxSObject != null){
                      if((i + 1) == listFields.size()){
                        f.Value = (String) auxSObject.get(listFields[i]);                    
                      }else{
                         auxSObject = auxSObject.getSobject(listFields[i]);
                      }
                   }                   
                }
              }
            //si no es cross-field se hace el get directo y no se usa el TargetObject y TargetField
            }else{
              f.Value = String.valueOf(recordObject.get(f.Name));
            }
          }
        }
      }          
    } else {
      sections = new List<Section>();
    }

  }

  public String fields {get{
      if ( fields == null ) {
        loadSections();
      }
      return fields;
    }set;}

  public List<Section> sections { get {
      if ( sections == null ) {
        loadSections();
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

 private static String getDependentOptions( List<Schema.PicklistEntry> ctrl_ple, List<Schema.PicklistEntry> dep_ple ){
    Map<String, List<String>> objResults =  new Map<String, List<String>>();      
    //iterate through the values and get the ones valid for the controlling field name
    SectionController.Bitset objBitSet = new SectionController.Bitset();
    //set up the results
    if(ctrl_ple != null){
      for(Integer pControllingIndex = 0; pControllingIndex < ctrl_ple.size(); pControllingIndex++){           
          Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
          String pControllingLabel = ctrl_entry.getValue();
          objResults.put(pControllingLabel,new List<String>());
      }
    }else{
      objResults.put('false',new List<String>());
      objResults.put('true',new List<String>());
    }
    //cater for null and empty
     objResults.put('',new List<String>());
     //objResults.put(null,new List<String>());
    //check the dependent values
    for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){          
        //get the pointer to the dependent index
        Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
        //get the valid for
        String pEntryStructure = JSON.serialize(dep_entry);
        SectionController.TPicklistEntry objDepPLE;              
        try{
          objDepPLE = (SectionController.TPicklistEntry)JSON.deserialize(pEntryStructure, SectionController.TPicklistEntry.class);
        } catch( JSONException e ) {
            system.debug(LoggingLevel.ERROR, 'INVALID JSON: ' + pEntryStructure );
            return null;   
        }
        //if valid for is empty, skip
        if (objDepPLE.validFor == null || objDepPLE.validFor == ''){
            continue;
        }
        //iterate through the controlling values
        if(ctrl_ple != null){
          for(Integer pControllingIndex = 0; pControllingIndex < ctrl_ple.size(); pControllingIndex++){    
              if (objBitSet.testBit(objDepPLE.validFor,pControllingIndex)){                   
                  //get the value
                  String pControllingLabel = ctrl_ple[pControllingIndex].getValue();
                  objResults.get(pControllingLabel).add(objDepPLE.value);
              }
          }
        }else{
          List<String> booleanValues = new List<String>{'false','true'};
          for(Integer pControllingIndex = 0; pControllingIndex < booleanValues.size(); pControllingIndex++){
            if (objBitSet.testBit(objDepPLE.validFor,pControllingIndex)){
              objResults.get(booleanValues[pControllingIndex]).add(objDepPLE.value);
            }
          }
        }
    }
    String validFor = '';
    for(String key: objResults.keySet()){  
      if(objResults.get(key).size() > 0){
        validFor += ', "' +  key.replace('\'', '\\\'') + '": [ "' + String.join( objResults.get(key), '","' ).replace('\'', '\\\'')  +  '"]';          
      }else{
        validFor += ', "' +  key.replace('\'', '\\\'') + '": []';
      }
    }
    if ( validFor != '' ) {
        validFor = '{' + validFor.substring(1) + '}';
    }
    return validFor;
  }

  private void initPicklistMaps () {
    mapPicklistOptions = new Map<String, List<PicklistController.Entry>>();
    mapPicklistController = new Map<String, String>();
    mapPicklistValidFor = new Map<String, String>();
    for ( Section s :sections ) {
      for ( List<FormField> ff :s.Rows ) {
        for ( FormField f :ff ) {
          if ( (f.Type == 'picklist' ||  f.Type == 'radio'|| f.Type == 'multiselect'|| f.Type == 'checkboxes') && fieldMap.containsKey(f.Name) ) {
            List<PicklistController.Entry> options = new List<PicklistController.Entry>();
            Schema.DescribeFieldResult describe = fieldMap.get(f.Name).getDescribe();
            String validFor = '';
            String controllerField = '#';
            if ( describe.getType().name() == 'PICKLIST' || describe.getType().name() == 'MULTIPICKLIST' ) {
              List<Schema.PicklistEntry> pickListValues = describe.getPickListValues();
              for (Schema.PicklistEntry a : pickListValues) {
                 options.add( new PicklistController.Entry(a.getValue(), a.getLabel() ));
              }             
              if(describe.isDependentPicklist()){
                Schema.DescribeFieldResult describeController = describe.getController().getDescribe();
                if(describeController.getType().name() == 'PICKLIST' || describeController.getType().name() == 'MULTIPICKLIST'){
                  validFor = getDependentOptions ( describeController.getPicklistValues(), pickListValues );
                }else{
                  validFor = getDependentOptions ( null, pickListValues );
                }
                controllerField =  describeController.getName().replace('_', '') ;
              }

            } else if ( describe.getType().name() == 'REFERENCE' ) {
              String query = 'SELECT ID, Name FROM ' + describe.getReferenceTo().get(0);
              if ( ! String.isBlank( f.WhereCondition )  ){
                query += ' WHERE ' + f.WhereCondition.replace('/', '\'') ;
              }
              query += ' LIMIT 500';               
              for ( SObject o : Database.query(query) ) {
                // Substring para que matche con el multipicklist (para multisegment)
                options.add( new PicklistController.Entry( ((String)o.id),  (String)o.get('Name') ));
              }
            }            
            mapPicklistController.put(f.Name, controllerField);
            mapPicklistValidFor.put(f.Name, validFor);
            mapPicklistOptions.put( f.Name , options);            
          }
        }
      }
    }
  }

  public Map<String, String> mapPicklistController { get {
    if ( mapPicklistController == null && !String.isBlank(csObjectName) ) {
      initPicklistMaps();
    }
    return mapPicklistController;
  } set; }

  public Map<String, String> mapPicklistValidFor { get {
    if ( mapPicklistValidFor == null && !String.isBlank(csObjectName) ) {
      initPicklistMaps();
    }
    return mapPicklistValidFor;
  } set; }

  public Map<String, List<PicklistController.Entry>> mapPicklistOptions { get {
    if ( mapPicklistOptions == null && !String.isBlank(csObjectName) ) {
      initPicklistMaps();
    }
    return mapPicklistOptions;
  } set;}

  private class Bitset{
      public Map<String,Integer> AlphaNumCharCodes {get;set;}
      public Map<String, Integer> Base64CharCodes { get; set; }
      public Bitset(){
          LoadCharCodes();
      }
      //Method loads the char codes
      private void LoadCharCodes(){
          AlphaNumCharCodes = new Map<String,Integer>{
              'A'=>65,'B'=>66,'C'=>67,'D'=>68,'E'=>69,'F'=>70,'G'=>71,'H'=>72,'I'=>73,'J'=>74,
              'K'=>75,'L'=>76,'M'=>77,'N'=>78,'O'=>79,'P'=>80,'Q'=>81,'R'=>82,'S'=>83,'T'=>84,
              'U'=>85,'V'=> 86,'W'=>87,'X'=>88,'Y'=>89,'Z'=>90    
          };
          Base64CharCodes = new Map<String, Integer>();
          //lower case
          Set<String> pUpperCase = AlphaNumCharCodes.keySet();
          for(String pKey : pUpperCase){
              //the difference between upper case and lower case is 32
              AlphaNumCharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey)+32);
              //Base 64 alpha starts from 0 (The ascii charcodes started from 65)
              Base64CharCodes.put(pKey,AlphaNumCharCodes.get(pKey) - 65);
              Base64CharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey) - (65) + 26);
          }
          //numerics
          for (Integer i=0; i<=9; i++){
              AlphaNumCharCodes.put(string.valueOf(i),i+48);
              //base 64 numeric starts from 52
              Base64CharCodes.put(string.valueOf(i), i + 52);
          }
      }
      public Boolean testBit(String pValidFor,Integer n){
          //the list of bytes
          List<Integer> pBytes = new List<Integer>();
          //multiply by 6 since base 64 uses 6 bits
          Integer bytesBeingUsed = (pValidFor.length() * 6)/8;
          //will be used to hold the full decimal value
          Integer pFullValue = 0;
          //must be more than 1 byte
          if (bytesBeingUsed <= 1)
              return false;
          //calculate the target bit for comparison
          Integer bit = 7 - (Math.mod(n,8)); 
          //calculate the octet that has in the target bit
          Integer targetOctet = (bytesBeingUsed - 1) - (n >> bytesBeingUsed); 
          //the number of bits to shift by until we find the bit to compare for true or false
          Integer shiftBits = (targetOctet * 8) + bit;
          //get the base64bytes
          for(Integer i=0;i<pValidFor.length();i++){
              //get current character value
              pBytes.Add((Base64CharCodes.get((pValidFor.Substring(i, i+1)))));
          }
          //calculate the full decimal value
          for (Integer i = 0; i < pBytes.size(); i++)
          {
              Integer pShiftAmount = (pBytes.size()-(i+1))*6;//used to shift by a factor 6 bits to get the value
              pFullValue = pFullValue + (pBytes[i] << (pShiftAmount));
          }
          //& is to set the same set of bits for testing
          //shift to the bit which will dictate true or false
          Integer tBitVal = ((Integer)(Math.Pow(2, shiftBits)) & pFullValue) >> shiftBits;
          return  tBitVal == 1;
      }
  }
        
  /*
  * @Summary: Entity to represent a json version of a picklist entry
  * so that the validFor property becomes exposed
  */
  private class TPicklistEntry{
      public string active {get;set;}
      public string defaultValue {get;set;}
      public string label {get;set;}
      public string value {get;set;}
      public string validFor {get;set;}
      public TPicklistEntry(){
          
      }
  } 

}