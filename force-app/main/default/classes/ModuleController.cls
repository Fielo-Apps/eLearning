public with sharing class ModuleController {
	@auraEnabled
	public static sObject getContent(String contentField, String contentType, String moduleId){    
		if( !Schema.sObjectType.Module__c.isAccessible() ){
			throw new FieloPLT.FieloException('Insufficient permission to access modules.');
		}
		if (contentField != '' && contentField != null && !Schema.sObjectType.Module__c.fields.getMap().get(contentField).getDescribe().isAccessible()) {
    		throw new FieloPLT.FieloException('Insufficient permission to access modules.');
		}
		if (contentType != '' && contentType != null && !Schema.sObjectType.Module__c.fields.getMap().get(contentType).getDescribe().isAccessible()) {
    		throw new FieloPLT.FieloException('Insufficient permission to access modules.');
		}
    	return database.query('SELECT ' + String.escapeSingleQuotes(contentField) + ', ' + String.escapeSingleQuotes(contentType) + ' FROM FieloELR__Module__c WHERE Id = \'' + String.escapeSingleQuotes(moduleId) + '\'')[0];
  	}
}