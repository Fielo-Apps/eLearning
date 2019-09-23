public with sharing class AnswerOptionsController {
    /*****  Data  *****/
    public String csObjectName{get;set;}
    public String cFieldset{get;set;}
    public String cbuttons{get;set;}

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
        public String ClassName{get;set;}
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
                try{
                    Section s = new Section();
                    s.Name = '';
                    s.Rows =  new List<List<FormField>>();
                    s.Rows.add( (List<FormField>) JSON.deserialize( cFieldset, List<FormField>.class ));
                    sections = new List<Section>();
                    sections.add(s);

                }catch(Exception e){
                    System.debug('Erro: '+e);
                }
            } else {
                sections = new List<Section>();
            }
        }
        return sections;
    } set;}

    

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
}