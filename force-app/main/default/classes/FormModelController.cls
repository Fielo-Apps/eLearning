public with sharing class FormModelController  {
  /*****  Retrieve  *****/

	@RemoteAction
	public static FieloPLT__Model__c retrieve( String objectName, Id recordId, String fields ){
    	FieloPLT__Model__c recordObject;
    	objectName = recordId.getSObjectType().getDescribe().getName();

    	if ( objectName == 'FieloPLT__Model__c' ) {
		    SObjectType convertType = Schema.getGlobalDescribe().get('FieloPLT__Model__c');
        	SecurityUtils.checkObjectIsReadable(convertType);
            // SR: CRUD Check
            if ( Schema.SObjectType.FieloPLT__Model__c.isAccessible() ) {
                if ( Schema.SObjectType.FieloPLT__Model__c.fields.FieloPLT__JSON__c.isAccessible() && Schema.SObjectType.FieloPLT__Model__c.fields.FieloPLT__Icon__c.isAccessible() && Schema.SObjectType.FieloPLT__Model__c.fields.FieloPLT__Type__c.isAccessible() && Schema.SObjectType.FieloPLT__Model__c.fields.FieloPLT__Category__c.isAccessible() && Schema.SObjectType.FieloPLT__Model__c.fields.Name.isAccessible() ) {
          	        recordObject = [SELECT ID, FieloPLT__JSON__c, FieloPLT__Icon__c, FieloPLT__Type__c, FieloPLT__Category__c, Name FROM FieloPLT__Model__c WHERE Id = : recordId ];
                } else {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__Model__c', 'FieloPLT__JSON__c, FieloPLT__Icon__c, FieloPLT__Type__c, FieloPLT__Category__c, Name'}));
                }
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__Model__c'}));
            }
    	} else if( objectName == 'FieloELR__Course__c') {
    		recordObject = new FieloPLT__Model__c( Name = 'New Model', FieloPLT__Category__c = 'Miscelaneas', FieloPLT__Type__c = 'Course' ) ;
    		recordObject.FieloPLT__JSON__c = ExportService.exportCourses(new List<Id>{recordId});
    		recordObject.FieloPLT__Icon__c = 'fielosf-icon-content';
    	}
    	return recordObject;
	}
}