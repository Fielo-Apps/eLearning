public with sharing class ModelController {
    public String cModelType {get;set;}

    public Map<Id, FieloPLT__Model__c> modelsMap{get{ if(modelsMap == null){
            if( Schema.sObjectType.FieloPLT__Model__c.isAccessible() && Schema.sObjectType.FieloPLT__Model__c.fields.FieloPLT__Icon__c.isAccessible() && Schema.sObjectType.FieloPLT__Model__c.fields.FieloPLT__Description__c.isAccessible() && Schema.sObjectType.FieloPLT__Model__c.fields.FieloPLT__JSON__c.isAccessible() && Schema.sObjectType.FieloPLT__Model__c.fields.FieloPLT__Type__c.isAccessible() && Schema.sObjectType.FieloPLT__Model__c.fields.FieloPLT__Category__c.isAccessible() ){
                modelsMap = new Map<Id, FieloPLT__Model__c>([SELECT Id, FieloPLT__Icon__c, Name, FieloPLT__Description__c, FieloPLT__JSON__c, FieloPLT__Type__c, FieloPLT__Category__c FROM FieloPLT__Model__c WHERE FieloPLT__Type__c = :cModelType ]);
            }
        }
        return modelsMap;
    } set;}

    public Map<String, List<FieloPLT__Model__c>> modelsByClass {get{
        if(modelsByClass == null){
            modelsByClass = new Map<String, List<FieloPLT__Model__c>>();
            modelsByClass.put('Miscelaneas', new List<FieloPLT__Model__c>{ new FieloPLT__Model__c(FieloPLT__Icon__c ='', Name = label.FieloPLT.Blank, FieloPLT__Description__c ='', FieloPLT__JSON__c = '{}', FieloPLT__Type__c = cModelType , FieloPLT__Category__c = 'Miscellaneous' ) } );

            for(FieloPLT__Model__c m : modelsMap.values()){
                if(!modelsByClass.containsKey(m.FieloPLT__Category__c)){
                    modelsByClass.put(m.FieloPLT__Category__c, new List<FieloPLT__Model__c>());
                }
                modelsByClass.get(m.FieloPLT__Category__c).add(m);
            }
        }
        return modelsByClass;
    } set;}

    public ModelController() {
        
    }
}