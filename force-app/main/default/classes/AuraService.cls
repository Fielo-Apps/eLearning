public class AuraService {

    public static Map<String, DescribeFieldResult> getFieldsDescribe(String objectName, List<String> fieldNames) {
		DescribeSObjectResult objectDescribe = Schema.describeSObjects(new String[]{objectName})[0];
		Set<String> fieldNamesSet = new Set<String>(fieldNames);
		Map<String,Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
		Map<String, DescribeFieldResult> result = new Map<String, DescribeFieldResult>();
		for(String fieldName: fieldNamesSet) {
			if (fieldMap.containsKey(fieldName)) {
				result.put(fieldName, fieldMap.get(fieldName).getDescribe());	
			}
		}
		return result;
	}

	public static String getFieldData(String objectName, String fieldNames) {
		DescribeSObjectResult objectDescribe = Schema.describeSObjects(new String[]{objectName})[0];
		DescribeSObjectResult relatedObjectDescribe;
		Map<String,Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
		Set<String> fieldNamesSet = new Set<String>(fieldNames.split(','));
		Map<String, Object> objectInfo = new Map<String, Object>();
		List<Map<String, Object>> fieldsInfo = new List<Map<String, Object>>();
		Map<String, String> fieldAttributes;
		List<Map<String, String>> picklistEntries;
		DescribeFieldResult fieldDescribe;

		objectInfo.put('label', (Object) objectDescribe.getLabel());
		objectInfo.put('labelplural', (Object) objectDescribe.getLabelPlural());
		objectInfo.put('name', (Object) objectDescribe.getName());
		objectInfo.put('prefix', (Object) objectDescribe.getKeyPrefix());

		for (String fieldName: fieldNamesSet) {
			if (fieldMap.containsKey(fieldName)) {
				fieldsInfo.add(new Map<String, Object>());
				fieldDescribe = fieldMap.get(fieldName).getDescribe();
				fieldAttributes = new Map<String, String>();
				fieldAttributes.put('objectName', objectDescribe.getName());
				fieldAttributes.put('objectLabel', objectDescribe.getLabel());
				fieldAttributes.put('label', fieldDescribe.getLabel());
				fieldAttributes.put('name', fieldDescribe.getName());
				fieldAttributes.put('type', fieldDescribe.getType().name().toLowerCase());
				fieldAttributes.put('inputType', inputTypeMap.get(fieldDescribe.getType().name().toLowerCase()));
				fieldAttributes.put('jsType', jsPrimitiveTypeMap.get(fieldAttributes.get('type')));
				fieldAttributes.put('isQuoted', isQuoted.get(fieldAttributes.get('type')));
				fieldAttributes.put('soaptype', fieldDescribe.getSOAPType().name().toLowerCase());
				fieldAttributes.put('scale', String.valueOf(fieldDescribe.getScale()));
				fieldAttributes.put('precision', String.valueOf(fieldDescribe.getPrecision()));
				fieldAttributes.put('tooltip', fieldDescribe.getInlineHelpText());
				if (fieldDescribe.getScale()!=null) {
					fieldAttributes.put('step', '0.' + '0'.repeat(fieldDescribe.getScale()-1) + '1' );
				}
				fieldAttributes.put('helpText', fieldDescribe.getInlineHelpText());
				fieldAttributes.put('id', fieldDescribe.getName().replace('_',''));
				if (fieldAttributes.get('type') == 'picklist') {
					picklistEntries = new List<Map<String, String>>();
					for (Schema.PicklistEntry pValues: fieldDescribe.getPicklistValues()) {
						picklistEntries.add(new Map<String, String>{'value' => pValues.getValue(),'label'=> pValues.getLabel()});
					}
					if (!picklistEntries.isEmpty()) {
						fieldsInfo.get(fieldsInfo.size()-1).put('picklistentries', (Object) picklistEntries);
					}
				}
                if (fieldAttributes.get('type') == 'date') {
                    fieldAttributes.put('timeZone', UserInfo.getTimeZone().getID());
                }
                if (fieldAttributes.get('type') == 'currency') {
                    fieldAttributes.put('currencyCode', UserInfo.getDefaultCurrency());
                    fieldAttributes.put('formatter', 'currency');
                }
                if (fieldAttributes.get('type') == 'percent') {
                	fieldAttributes.put('formatter', 'percent');	
               	}
				if (fieldAttributes.get('type') == 'reference') {
					relatedObjectDescribe = fieldDescribe.getReferenceTo()[0].getDescribe();
					fieldAttributes.put('referenceTo', relatedObjectDescribe.getName());
					fieldAttributes.put('referenceToLabel', relatedObjectDescribe.getLabel());
				}
				fieldsInfo.get(fieldsInfo.size()-1).put('attributes', (Object) fieldAttributes);
			}
		}
		objectInfo.put('fields', (Object) fieldsInfo);
		return JSON.serialize(objectInfo);
	}

	public static List<Object> getImages(String parentId){
    	List<Map<String,String>> images = new List<Map<String,String>>();

		// SR: CRUD Check:
		if ( !Schema.sObjectType.Attachment.isAccessible() ) {
			throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Attachment'}));
		} else if ( !Schema.sObjectType.ContentDocumentLink.isAccessible() ) {
			throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'ContentDocumentLink'}));
		} else if ( !Schema.sObjectType.ContentVersion.isAccessible() ) {
			throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'ContentVersion'}));
		}

		// SR: FLS Check:
		SecurityUtils.checkRead(Schema.sObjectType.Attachment.getSObjectType(), new List<String>{'Name', 'ContentType', 'ParentId'});

    	// For legacy attachments
        List<Attachment> atts = [SELECT Id, Name, ContentType FROM Attachment WHERE ParentId =: parentId AND ContentType like '%image%'];
        List<String> formatList;
        String format;
        for (Attachment a: atts) {
        	formatList = a.ContentType.toLowerCase().split('/');
        	format = formatList.size() == 1 ? formatList[0] : formatList[1];
        	images.add(
        		new Map<String,String>{
        			'objectType' => 'attachment',
        			'id' => a.Id,
        			'name' => a.Name,
        			'contentType' => format,
        			'url' => '/servlet/servlet.FileDownload?file=' + a.Id + '&oid=' + UserInfo.getOrganizationId()
        		}
			);
        }

		// SR: FLS Check
		SecurityUtils.checkRead(Schema.sObjectType.ContentDocumentLink.getSObjectType(), new List<String>{'ContentDocumentId', 'LinkedEntityId'});

        // For the new Salesforce Approach of file storage
        List<ContentDocumentLink> cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: parentId];
        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink cdl: cdls) {
        	documentIds.add(cdl.ContentDocumentId);
        }
        Set<String> supportedTypes = new Set<String>{'JPG','JPEG','PNG','GIF'};

		// SR: FLS Check
		SecurityUtils.checkRead(Schema.sObjectType.ContentVersion.getSObjectType(), new List<String>{'FileType', 'Title', 'ContentDocumentId'});

        List<ContentVersion> cvs = [SELECT Id, FileType, Title FROM ContentVersion WHERE ContentDocumentId in :documentIds];
        System.debug(JSON.serializePretty(cvs));
        for (ContentVersion cv: cvs) {
    		images.add(
        		new Map<String,String>{
        			'objectType' => 'file',
        			'id' => cv.Id,
        			'name' => cv.Title,
        			'contentType' => cv.FileType.toLowerCase(),
        			'url' => '/sfc/servlet.shepherd/version/download/' + cv.Id
        		}
			);
        }

        return (List<Object>) images;
    }

	public static Map<String, String> inputTypeMap {get{
		if (inputTypeMap == null) {
			inputTypeMap = new Map<String,String>{
				'address' => 'text',
		        'anytype' => 'none',
		        'base64' => 'text',
		        'boolean' => 'checkbox',
		        'combobox' => 'checkbox',
		        'currency' => 'number',
		        'datacategorygroupreference' => 'none',
		        'date' => 'date',
		        'datetime' => 'datetime',
		        'double' => 'number',
		        'email' => 'email',
		        'encryptedstring' => 'text',
		        'id' => 'text',
		        'integer' => 'text',
		        'multipicklist' => 'text',
		        'percent' => 'number',
		        'phone' => 'text',
		        'picklist' => 'picklist',
		        'reference' => 'reference',
		        'string' => 'text',
		        'textarea' => 'text',
		        'time' => 'time',
		        'url' => 'url'
			};
		}
		return inputTypeMap;
	} set;}

	public static Map<String, String> isQuoted {get{
		if (isQuoted == null) {
			isQuoted = new Map<String,String>{
				'address' => 'true',
		        'anytype' => 'true',
		        'base64' => 'true',
		        'boolean' => 'false',
		        'combobox' => 'false',
		        'currency' => 'false',
		        'datacategorygroupreference' => 'false',
		        'date' => 'false',
		        'datetime' => 'false',
		        'double' => 'false',
		        'email' => 'true',
		        'encryptedstring' => 'true',
		        'id' => 'true',
		        'integer' => 'false',
		        'multipicklist' => 'true',
		        'percent' => 'false',
		        'phone' => 'true',
		        'picklist' => 'true',
		        'reference' => 'true',
		        'string' => 'true',
		        'textarea' => 'true',
		        'time' => 'false',
		        'url' => 'true'
			};
		}
		return isQuoted;
	} set;}

	public static Map<String, String> jsPrimitiveTypeMap {get{
		if (jsPrimitiveTypeMap == null) {
			jsPrimitiveTypeMap = new Map<String,String>{
				'address' => 'string',
			    'anytype' => 'object',
			    'base64' => 'string',
			    'boolean' => 'boolean',
			    'combobox' => 'boolean',
			    'currency' => 'number',
			    'datacategorygroupreference' => 'object',
			    'date' => 'string',
			    'datetime' => 'string',
			    'double' => 'number',
			    'email' => 'string',
			    'encryptedstring' => 'string',
			    'id' => 'string',
			    'integer' => 'number',
			    'multipicklist' => 'string',
			    'percent' => 'number',
			    'phone' => 'string',
			    'picklist' => 'string',
			    'reference' => 'string',
			    'string' => 'string',
			    'textarea' => 'string',
			    'time' => 'number',
			    'url' => 'string'
			};
		}
		return jsPrimitiveTypeMap;
	} set; }

	public static FieloPLT__PublicSettings__c settings {get{
        if (settings==null) {
            try {
                settings = FieloPLT__PublicSettings__c.getInstance(UserInfo.getProfileId());
            } catch(Exception e) {
                settings = null;
            }
        } 
        return settings;
    }
        set;
    }
}